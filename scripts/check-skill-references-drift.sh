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
#   3. Orphan reference -- a non-vendored skill entry does not link to one of
#                          its references/**/*.md files (README.md exempt).
#   4. Path in prose   -- a backticked path names an existing rule-tree Markdown
#                          file instead of linking it. Vendored prose is exempt.
#   5. Reference-style  -- a [label]: target definition. Only inline links are
#      definition          accepted, so one syntax resolves everywhere.
#
# Paths resolve relative to the containing file, or from the repository root
# for repo-relative prose mentions. Only Markdown links count for orphans.
# Vendored skills are read from skills-lock.json; their links are still checked.
# Absolute URLs, fenced code (closed only by a matching fence marker) and inline
# code are ignored; <angle-bracket> targets are read without the brackets.
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
        /^[ \t]*(```+|~~~+)/ {
            m = $0; sub(/^[ \t]*/, "", m); match(m, /^(`+|~+)/); mk = substr(m, 1, RLENGTH)
            if (fence == "") { fence = mk; next }
            if (substr(mk, 1, 1) == substr(fence, 1, 1) && length(mk) >= length(fence)) { fence = ""; next }
        }
        fence != "" { next }
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

# Backticked paths outside fences, Markdown links and link targets.
extract_prose_paths() {
    LC_ALL=C awk '
        /^[ \t]*(```+|~~~+)/ {
            m = $0; sub(/^[ \t]*/, "", m); match(m, /^(`+|~+)/); mk = substr(m, 1, RLENGTH)
            if (fence == "") { fence = mk; next }
            if (substr(mk, 1, 1) == substr(fence, 1, 1) && length(mk) >= length(fence)) { fence = ""; next }
        }
        fence != "" { next }
        {
            l = $0
            gsub(/\[[^]]*\]\([^)]*\)/, "", l)
            while (match(l, /`[^`]+`/)) {
                print NR "\t" substr(l, RSTART + 1, RLENGTH - 2)
                l = substr(l, RSTART + RLENGTH)
            }
        }' "$1"
}

# "<line>\t<label>" for every reference-style link definition ([label]: target)
# outside fences. The check rejects these: inline links are the one form the
# link check, the mirror build and GitHub all resolve the same way.
extract_reference_definitions() {
    LC_ALL=C awk '
        /^[ \t]*(```+|~~~+)/ {
            m = $0; sub(/^[ \t]*/, "", m); match(m, /^(`+|~+)/); mk = substr(m, 1, RLENGTH)
            if (fence == "") { fence = mk; next }
            if (substr(mk, 1, 1) == substr(fence, 1, 1) && length(mk) >= length(fence)) { fence = ""; next }
        }
        fence != "" { next }
        /^[ \t]{0,3}\[[^]]+\]:[ \t]+[^ \t]/ {
            l = $0; sub(/^[ \t]*\[/, "", l); sub(/\]:.*$/, "", l)
            print NR "\t" l
        }' "$1"
}

# Read keys immediately inside the lock's skills object, without Node or jq.
vendored_skills=""
if [[ -f "${ROOT}/skills-lock.json" ]]; then
    vendored_skills="$(LC_ALL=C awk '
        { text = text $0 }
        END {
            sub(/^.*"skills"[ \t]*:[ \t]*\{/, "", text)
            depth = 1
            while (match(text, /"[^"\\]*(\\.[^"\\]*)*"|[{}]/)) {
                token = substr(text, RSTART, RLENGTH)
                text = substr(text, RSTART + RLENGTH)
                if (token == "{") depth++
                else if (token == "}") { depth--; if (!depth) break }
                else if (depth == 1 && text ~ /^[ \t]*:/) {
                    print substr(token, 2, length(token) - 2)
                }
            }
        }' "${ROOT}/skills-lock.json")"
fi

is_vendored() {
    local skill
    case "$1" in
        .claude/skills/* | .cursor/skills/* | .github/skills/* | .github/instructions/*)
            skill="${1#*/*/}"
            skill="${skill%%/*}"
            skill="${skill%.instructions.md}"
            printf '%s\n' "${vendored_skills}" | grep -F -x -q -- "${skill}" ;;
        *) return 1 ;;
    esac
}

# Resolve prose only to existing Markdown files in the scanned rule trees.
check_prose_path() {
    local src="$1" line="$2" raw="$3" candidate target rel skill_dir
    skill_dir="$(dirname "${src}")"
    [[ "${skill_dir}" == */references* ]] && skill_dir="${skill_dir%%/references*}"
    raw="${raw%%#*}"
    case "${raw}" in *.md | *.mdc) ;; *) return 0 ;; esac
    [[ "${raw}" == *'{'* || "${raw}" == *'<'* || "${raw}" == /* ]] && return 0
    for candidate in "${ROOT}/$(dirname "${src}")/${raw}" "${ROOT}/${raw}" "${ROOT}/.claude/skills/${raw}" "${ROOT}/${skill_dir}/${raw}"; do
        [[ -f "${candidate}" ]] || continue
        target="$(cd "$(dirname "${candidate}")" && pwd -P)/$(basename "${candidate}")"
        rel="${target#"${ROOT}/"}"
        case "${rel}" in
            CLAUDE.md | .claude/* | .cursor/* | .github/*)
                echo "DRIFT ${src}:${line} :: path named in prose, make it a link -- ${raw}"
                errors=$((errors + 1))
                return 0 ;;
        esac
    done
}

# Every anchor a Markdown file defines: GitHub heading slugs (duplicates get
# -1, -2, ...) and inline <a id="..."> / <a name="..."> ids. Non-ASCII
# characters are dropped from slugs; setext headings are not recognised.
collect_anchors() {
    LC_ALL=C awk '
        /^[ \t]*(```+|~~~+)/ {
            m = $0; sub(/^[ \t]*/, "", m); match(m, /^(`+|~+)/); mk = substr(m, 1, RLENGTH)
            if (fence == "") { fence = mk; next }
            if (substr(mk, 1, 1) == substr(fence, 1, 1) && length(mk) >= length(fence)) { fence = ""; next }
        }
        fence != "" { next }
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
                check_link "${rel}" "${line}" "${raw}" "${dir}"
            done < <(extract_md_links "${file}")

            while IFS=$'\t' read -r line label; do
                [[ -z "${label}" ]] && continue
                errors=$((errors + 1))
                echo "DRIFT ${rel}:${line} :: reference-style link definition, use an inline link -- [${label}]: ..."
            done < <(extract_reference_definitions "${file}")

            if ! is_vendored "${rel}"; then
                while IFS=$'\t' read -r line raw; do
                    [[ -z "${raw}" ]] && continue
                    check_prose_path "${rel}" "${line}" "${raw}"
                done < <(extract_prose_paths "${file}")
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
# linked by the skill's entry file. Vendored skills are exempt.
while IFS= read -r rel; do
    [[ -z "${rel}" ]] && continue
    skill_dir="$(skill_dir_of "${rel}")"
    is_vendored "${rel}" && continue
    refs_dir="${ROOT}/${skill_dir}/references"
    [[ -d "${refs_dir}" ]] || continue
    mentioned="$(extract_md_links "${ROOT}/${rel}" | cut -f2 | sed -E 's/^<//; s/>$//; s/#.*//; s|^\./||')"
    while IFS= read -r ref_file; do
        nested="${ref_file#"${ROOT}/${skill_dir}/"}"
        [[ "$(basename "${ref_file}")" == "README.md" ]] && continue
        entry_ref="${nested}"
        [[ "${rel}" == *.instructions.md ]] && entry_ref="$(basename "${skill_dir}")/${nested}"
        if ! printf '%s\n' "${mentioned}" | grep -F -x -q -- "${entry_ref}"; then
            echo "DRIFT ${rel} :: orphan reference -- ${skill_dir}/${nested} exists but ${rel} does not link to it"
            errors=$((errors + 1))
        fi
    done < <(find "${refs_dir}" -type f -name '*.md' | sort)
done <<< "${entry_files}"

echo
echo "Checked ${checked_files} file(s) and ${checked_links} link(s); ${errors} drift(s)."
[[ "${errors}" -eq 0 ]] || exit 1
