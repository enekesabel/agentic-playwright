#!/usr/bin/env bash
# check-skill-references-drift.sh [root-dir]
#
# Checks root rule/docs files, .github/prompts/*.md, canonical skill Markdown,
# and comment tokens in scripts/, .claude/scripts/, .husky/, eslint.config.mts
# (also skill-local scripts). The generated .agents/ tree is checked by sync.
# Failure modes: missing relative-link file; missing heading/HTML anchor;
# reference-style definition; backticked rule-file path named in prose;
# missing references/ pointer; orphan references/**/*.md (README.md exempt).
# Vendored skills from skills-lock.json skip prose/orphan checks only.
# STRICT_PROSE_PATHS defaults to 1; set 0 only for legacy prose fixtures.
# Strict prose checks cover AGENTS.md, CLAUDE.md, qualified skill SKILL.md
# paths and references/*.md, including missing targets and mixed code spans.
# Generic SKILL.md names, skill names, code paths, YAML frontmatter,
# the standalone Claude @AGENTS.md import, a pruned file marked
# "<path> (omitted)" by the initializer, and vendored prose are exempt.
# Fences and inline code hide links; angle targets and GFM headings work.
# Bare comment tokens resolve relative to the source, with AGENTS.md rooted.
# Exits nonzero with source, line and reason. Python standard library only.
set -euo pipefail
export STRICT_PROSE_PATHS="${STRICT_PROSE_PATHS:-1}"
ROOT="$(cd "${1:-$(dirname "${BASH_SOURCE[0]}")/..}" && pwd -P)"
python3 - "${ROOT}" <<'PY'
import json
import os
import re
import sys
import unicodedata
from pathlib import Path
from urllib.parse import unquote

root = Path(sys.argv[1])
skills = root / '.claude/skills'
if not skills.is_dir():
    skills = root / '.agents/skills'
lock = root / 'skills-lock.json'
vendored = set(json.loads(lock.read_text()).get('skills', {})) if lock.exists() else set()
errors = []
checked = 0


def fail(src, line, reason, raw):
    errors.append(f'DRIFT {src.relative_to(root)}:{line} :: {reason} -- {raw}')


def lines_outside_fences(text):
    fence = None
    for num, line in enumerate(text.splitlines(), 1):
        match = re.match(r'^ {0,3}(`{3,}|~{3,})(.*)$', line)
        if match:
            marker, tail = match.groups()
            if fence is None and not (marker[0] == '`' and '`' in tail):
                fence = marker
                continue
            if fence and marker[0] == fence[0] and len(marker) >= len(fence) and not tail.strip():
                fence = None
                continue
        if fence is None:
            yield num, line


CODE = re.compile(r'(`+)(?!`)(.+?)(?<!`)\1(?!`)', re.S)
LINK = re.compile(r'!?\[(?:\\.|[^\]\\])*\]\(\s*(<[^>\n]*>|(?:\\.|[^\s()\\]|\([^()]*\))*)(?:\s+[\'\"][^\n]*?[\'\"])?\s*\)')


def blank(match):
    return re.sub(r'[^\n]', ' ', match[0])


def visible(text):
    # Preserve offsets for diagnostics, even across fences and comments.
    kept = dict(lines_outside_fences(text))
    text = '\n'.join(line if n in kept else ' ' * len(line)
                     for n, line in enumerate(text.splitlines(), 1))
    text = re.sub(r'\A---\n.*?\n---(?:\n|$)', blank, text, flags=re.S)
    text = re.sub(r'^@AGENTS\.md$', lambda m: ' ' * len(m[0]), text, flags=re.M)
    return re.sub(r'<!--.*?(?:-->|\Z)', blank, text, flags=re.S)


def slug(text):
    text = re.sub(r'<[^>]*>', '', text)
    text = re.sub(r'\[([^]]*)\]\([^)]*\)', r'\1', text).lower()
    return ''.join(c for c in text if c in ' _-' or unicodedata.category(c)[0] in 'LN').replace(' ', '-')


anchor_cache = {}


def anchors(path):
    if path in anchor_cache:
        return anchor_cache[path]
    found, used = set(), set()
    previous = ''
    text = visible(path.read_text())
    found.update(re.findall(r'<a\b[^>]*\b(?:id|name)=[\'"]([^\'"]+)[\'"]', CODE.sub(blank, text)))
    for line in text.splitlines():
        match = re.match(r'^ {0,3}#{1,6}\s+(.*?)\s*#*\s*$', line)
        heading = match[1] if match else previous if re.match(r'^ {0,3}(?:=+|-+)\s*$', line) and previous.strip() else None
        if heading is not None:
            base = slug(heading.strip())
            candidate, i = base, 0
            while candidate in used:
                i += 1
                candidate = f'{base}-{i}'
            used.add(candidate)
            found.add(candidate)
        previous = line
    anchor_cache[path] = found
    return found


def resolve(src, raw, comment=False):
    path = unquote(raw.split('#', 1)[0].split('?', 1)[0])
    if comment and path == 'AGENTS.md':
        return root / path
    return (src.parent / path).resolve() if path else src


def check_link(src, line, raw, comment=False):
    global checked
    raw = raw.removeprefix('<').removesuffix('>')
    if re.match(r'^[A-Za-z][A-Za-z0-9+.-]*:', raw) or raw.startswith('//'):
        return None
    checked += 1
    target = resolve(src, raw, comment)
    if not target.exists():
        fail(src, line, 'broken link (file not found)', raw)
    elif '#' in raw and raw.split('#', 1)[1] and target.is_file():
        anchor = unquote(raw.split('#', 1)[1])
        if anchor not in anchors(target):
            fail(src, line, 'broken anchor (no heading or <a id> matches)', raw)
    return target


markdown = [root / name for name in ('AGENTS.md', 'CLAUDE.md', 'README.md', 'CONTRIBUTING.md', 'AI-WORKFLOWS.md')]
markdown += list((root / '.github/prompts').glob('*.md'))
markdown += list(skills.rglob('*.md'))
files = sorted(set(p for p in markdown if p.is_file()))
for src in files:
    rel = src.relative_to(root)
    skill = rel.parts[2] if src.is_relative_to(skills) else None
    entry = skill and src == skills / skill / 'SKILL.md'
    mentioned = set()
    text = visible(src.read_text())
    plain = CODE.sub(blank, text)
    for match in re.finditer(r'^ {0,3}\[[^]\n]+\]:\s*\S', plain, re.M):
        fail(src, plain[:match.start()].count('\n') + 1,
             'reference-style link definition, use an inline link', match[0])
    for match in LINK.finditer(plain):
        target = check_link(src, plain[:match.start()].count('\n') + 1, match[1])
        if target:
            mentioned.add(target)
    # Labels may contain code; erase complete links before inspecting prose.
    prose = LINK.sub(blank, text)
    pattern = r'(?<![\w/.-])(?:[\w.-]+/)*(?:AGENTS\.md|CLAUDE\.md|(?:\.claude|\.agents)/skills/[\w.-]+/SKILL\.md|references/[\w./-]+\.md)(?:#[\w.-]+)?'
    for match in re.finditer(pattern, prose):
        raw = match[0]
        line_no = prose[:match.start()].count('\n') + 1
        # The initializer marks a pruned file "<path> (omitted)"; honour the
        # marker only while the file is really absent.
        omitted = prose.startswith(' (omitted)', match.end()) and not (src.parent / raw.split('#')[0]).exists()
        if os.environ['STRICT_PROSE_PATHS'] == '1' and skill not in vendored and not omitted:
            fail(src, line_no, 'path named in prose, make it a link', raw)
        # Non-strict historical trees still require real reference pointers.
        if entry and 'references/' in raw:
            mentioned.add(check_link(src, line_no, raw))
    if entry and skill not in vendored:
        for ref in (src.parent / 'references').rglob('*.md'):
            if ref.name != 'README.md' and ref.resolve() not in mentioned:
                fail(src, 1, 'orphan reference', str(ref.relative_to(root)))

# Scan comments, including scan-constitution.sh in the canonical skill tree.
code_files = {root / 'eslint.config.mts'}
for folder in (root / 'scripts', root / '.claude/scripts', root / '.husky', skills):
    code_files.update(p for p in folder.rglob('*') if p.is_file() and p.suffix != '.md')
for src in sorted(code_files):
    if not src.is_file() or 'tests' in src.relative_to(root).parts or '__pycache__' in src.parts:
        continue
    try:
        text = src.read_text()
    except (UnicodeError, OSError):
        continue
    for line_no, line in enumerate(text.splitlines(), 1):
        # Gate annotations use line comments; also accept block-comment lines.
        if not re.match(r'^\s*(?:#|//|/\*|\*)', line) and not re.search(r'\s(?:#|//)\s', line):
            continue
        line = re.sub(r'[A-Za-z][A-Za-z0-9+.-]*://\S+', '', line)
        for raw in re.findall(r'[\w./-]+\.md#[\w.-]+', line):
            check_link(src, line_no, raw, comment=True)

for error in errors:
    print(error)
print(f'Checked {len(files)} Markdown file(s) and {checked} link(s); {len(errors)} drift(s).')
sys.exit(bool(errors))
PY
