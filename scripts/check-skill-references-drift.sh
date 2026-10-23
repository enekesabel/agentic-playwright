#!/usr/bin/env bash
# check-skill-references-drift.sh [root-dir]
#
# Link check over the rule trees, the root docs and the gate scripts. Kept
# under its historical name (it started as the SKILL.md -> references/ drift
# lint) because docs and the npm script `check:skills-references` point at it.
#
# Files checked (tracked files when root-dir is a git work tree's top level,
# otherwise every file found under it):
#   .claude/**  .cursor/**  .github/**
#   CLAUDE.md  README.md  AI-WORKFLOWS.md  CONTRIBUTING.md
#   eslint.config.mts  scripts/*.sh
#
# Failure modes:
#   1. Broken link      -- a relative Markdown link [text](path) in a .md/.mdc
#                          file, or a bare <file>.md#<anchor> / .mdc#<anchor> token in any other
#                          text file (a comment in a gate script, hook or
#                          config), names a file that does not exist.
#   2. Broken anchor    -- the #anchor matches neither a heading slug (GitHub
#                          style, any level) nor an inline <a id="..."> /
#                          <a name="..."> in the target file.
#   3. Orphan reference -- a skill's references/*.md file is not mentioned by
#                          the skill's entry file (README.md is exempt).
#
# Paths resolve relative to the containing file. Two shapes kept from the
# original references lint, for skill entry files only:
#   - a bare `references/...` token (usually in backticks) counts as a link,
#     resolved against the skill directory;
#   - in a flat Copilot file .github/instructions/<name>.instructions.md, a
#     path starting with references/ resolves against the sibling <name>/
#     folder, which is where that layout keeps its reference files.
# Absolute URLs are skipped. Fenced code blocks and inline code spans are
# ignored when extracting Markdown links and headings.
#
# Semantic drift (a rule contradicted by an example) needs an LLM and is out
# of scope for this lint.
#
# Exits non-zero on any drift so CI and the pre-commit hook can gate.

set -euo pipefail

ROOT="$(cd "${1:-$(dirname "${BASH_SOURCE[0]}")/..}" && pwd -P)"

# Git hooks export GIT_DIR / GIT_INDEX_FILE, which would make any root
# (a fixture tree, say) look like the top of the hook's repository. Let git
# discover the repository from ROOT instead.
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE

SCOPE_RE='^(\.claude/|\.cursor/|\.github/|(CLAUDE|README|AI-WORKFLOWS|CONTRIBUTING)\.md$|eslint\.config\.mts$|scripts/[^/]+\.sh$)'

# Relative paths (from ROOT) of every in-scope file.
list_files() {
    if [[ "$(git -C "${ROOT}" rev-parse --show-toplevel 2>/dev/null || true)" == "${ROOT}" ]]; then
        git -C "${ROOT}" ls-files
    else
        (cd "${ROOT}" && find . \( -name .git -o -name node_modules -o -path ./.claude/worktrees \) -prune \
            -o -type f -print | sed 's|^\./||')
    fi | grep -E "${SCOPE_RE}" | grep -vE '^\.claude/worktrees/' | sort || true
}

# "<line>\t<target>" for every Markdown link target outside code.
extract_md_links() {
    LC_ALL=C awk '
        /^[ \t]*(```|~~~)/ { fence = !fence; next }
        fence { next }
        {
            l = $0
            gsub(/`[^`]*`/, "", l)
            while (match(l, /\]\([^) \t]+/)) {
                print NR "\t" substr(l, RSTART + 2, RLENGTH - 2)
                l = substr(l, RSTART + RLENGTH)
            }
        }' "$1"
}

# "<line>\t<token>" for every bare <file>.md#<anchor> token (non-Markdown files).
extract_bare_anchor_tokens() {
    LC_ALL=C awk -v q="'" '
        BEGIN { url = "[A-Za-z][A-Za-z0-9+.-]*://[^ \t\"" q "`)>]*" }
        {
            l = $0
            gsub(url, "", l)
            while (match(l, /[A-Za-z0-9._\/-]+\.mdc?#[A-Za-z0-9._-]+/)) {
                print NR "\t" substr(l, RSTART, RLENGTH)
                l = substr(l, RSTART + RLENGTH)
            }
        }' "$1"
}

# "<line>\t<token>" for every bare references/... token in a skill entry file,
# outside Markdown link targets (those are covered by extract_md_links).
extract_reference_tokens() {
    sed -E 's/\]\([^)]*\)/]/g' "$1" \
        | grep -noE '(^|[^/A-Za-z0-9._-])references/[A-Za-z0-9._/-]+(#[A-Za-z0-9._-]+)?' \
        | sed -E 's/^([0-9]+):[^r]?/\1	/; s/\.+$//' || true
}

# Every anchor a Markdown file defines: GitHub heading slugs (duplicates get
# -1, -2, ...) and inline <a id="..."> / <a name="..."> ids. Non-ASCII
# characters are dropped from slugs; setext headings are not recognised.
collect_anchors() {
    LC_ALL=C awk '
        /^[ \t]*(```|~~~)/ { fence = !fence; next }
        fence { next }
        {
            l = $0
            while (match(l, /<a[ \t][^>]*(id|name)="[^"]*"/)) {
                s = substr(l, RSTART, RLENGTH)
                sub(/.*(id|name)="/, "", s)
                sub(/"$/, "", s)
                print s
                l = substr(l, RSTART + RLENGTH)
            }
        }
        /^#+[ \t]/ {
            h = $0
            match(h, /^#+/)
            if (RLENGTH > 6) next
            h = substr(h, RLENGTH + 1)
            sub(/[ \t]+#+[ \t]*$/, "", h)
            sub(/^[ \t]+/, "", h)
            sub(/[ \t]+$/, "", h)
            gsub(/<[^>]*>/, "", h)
            gsub(/\]\([^)]*\)/, "]", h)
            h = tolower(h)
            gsub(/[^a-z0-9 _-]/, "", h)
            gsub(/ /, "-", h)
            if (h in seen) { print h "-" seen[h]; seen[h]++ } else { seen[h] = 1; print h }
        }' "$1"
}

errors=0
checked_files=0
checked_links=0

# Check one link. Args: source rel path, line, raw link, base dir (absolute)
# against which the path part resolves.
check_link() {
    local src="$1" line="$2" raw="$3" base="$4"
    local path="${raw%%#*}" anchor="" target
    [[ "${raw}" == *"#"* ]] && anchor="${raw#*#}"
    checked_links=$((checked_links + 1))

    if [[ -z "${path}" ]]; then
        target="${ROOT}/${src}"
    else
        target="${base}/${path}"
        if [[ ! -e "${target}" ]]; then
            echo "DRIFT ${src}:${line} :: broken link -- ${raw} (file not found)"
            errors=$((errors + 1))
            return 0
        fi
    fi

    [[ -n "${anchor}" && -f "${target}" ]] || return 0
    case "${target}" in *.md | *.mdc) ;; *) return 0 ;; esac
    if ! collect_anchors "${target}" | grep -F -x -q -- "${anchor}"; then
        echo "DRIFT ${src}:${line} :: broken anchor -- ${raw} (no heading or <a id> matches #${anchor})"
        errors=$((errors + 1))
    fi
}

# Skill directory for a skill entry file, or empty if the file is not one.
skill_dir_of() {
    case "$1" in
        .claude/skills/*/SKILL.md | .cursor/skills/*/SKILL.md | .github/skills/*/SKILL.md | .github/instructions/*/SKILL.md)
            [[ "$1" == */*/*/*/* ]] && { echo ""; return; }
            dirname "$1" ;;
        .github/instructions/*.instructions.md)
            [[ "$1" == */*/*/* ]] && { echo ""; return; }
            echo ".github/instructions/$(basename "$1" .instructions.md)" ;;
        *) echo "" ;;
    esac
}

entry_files=""

while IFS= read -r rel; do
    [[ -z "${rel}" ]] && continue
    file="${ROOT}/${rel}"
    [[ -f "${file}" ]] || continue
    grep -Iq . "${file}" || continue
    checked_files=$((checked_files + 1))
    dir="$(dirname "${file}")"
    skill_dir="$(skill_dir_of "${rel}")"
    [[ -n "${skill_dir}" ]] && entry_files="${entry_files}${rel}"$'\n'

    case "${rel}" in
        *.md | *.mdc)
            while IFS=$'\t' read -r line raw; do
                [[ -z "${raw}" ]] && continue
                raw="${raw#<}"
                raw="${raw%>}"
                [[ "${raw}" =~ ^[A-Za-z][A-Za-z0-9+.-]*: || "${raw}" == //* ]] && continue
                base="${dir}"
                if [[ -n "${skill_dir}" && "${rel}" == *.instructions.md && "${raw}" == references/* ]]; then
                    base="${ROOT}/${skill_dir}"
                fi
                check_link "${rel}" "${line}" "${raw}" "${base}"
            done < <(extract_md_links "${file}")

            if [[ -n "${skill_dir}" ]]; then
                while IFS=$'\t' read -r line raw; do
                    [[ -z "${raw}" ]] && continue
                    check_link "${rel}" "${line}" "${raw}" "${ROOT}/${skill_dir}"
                done < <(extract_reference_tokens "${file}")
            fi
            ;;
        *)
            while IFS=$'\t' read -r line raw; do
                [[ -z "${raw}" ]] && continue
                check_link "${rel}" "${line}" "${raw}" "${dir}"
            done < <(extract_bare_anchor_tokens "${file}")
            ;;
    esac
done < <(list_files)

# Orphan check: every references/**/*.md in a skill directory must be
# mentioned (Markdown link or bare token) by the skill's entry file.
while IFS= read -r rel; do
    [[ -z "${rel}" ]] && continue
    skill_dir="$(skill_dir_of "${rel}")"
    refs_dir="${ROOT}/${skill_dir}/references"
    [[ -d "${refs_dir}" ]] || continue
    mentioned="$( { extract_md_links "${ROOT}/${rel}"; extract_reference_tokens "${ROOT}/${rel}"; } \
        | cut -f2 | sed -E 's/#.*//; s|^\./||')"
    while IFS= read -r ref_file; do
        nested="${ref_file#"${ROOT}/${skill_dir}/"}"
        [[ "$(basename "${ref_file}")" == "README.md" ]] && continue
        if ! printf '%s\n' "${mentioned}" | grep -F -x -q -- "${nested}"; then
            echo "DRIFT ${rel} :: orphan reference -- ${skill_dir}/${nested} exists but ${rel} does not link to it"
            errors=$((errors + 1))
        fi
    done < <(find "${refs_dir}" -type f -name '*.md' | sort)
done <<< "${entry_files}"

echo
echo "Checked ${checked_files} file(s) and ${checked_links} link(s); ${errors} drift(s)."
[[ "${errors}" -eq 0 ]] || exit 1
