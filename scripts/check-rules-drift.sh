#!/usr/bin/env bash
# check-rules-drift.sh [root-dir]
#
# Checks that every Constitution row has a rule anchor and is linked from
# at least one non-vendored scaffold skill's Critical block. Reports owners
# per row and rejects Critical-block links to missing Constitution rows.
# Failure modes: missing/duplicate row anchor; uncovered row; broken row link.
# Uses .agents/skills when .claude/skills was pruned at init (--no-claude).
# Exit codes: 0 clean (explicit coverage exceptions reported), 1 drift,
# 2 missing required input. Bash and Python standard library only.
set -euo pipefail
ROOT="$(cd "${1:-$(dirname "${BASH_SOURCE[0]}")/..}" && pwd -P)"
python3 - "${ROOT}" <<'PY'
import ast
import warnings
import json
import re
import sys
from pathlib import Path
from urllib.parse import unquote

# Visible coverage gaps from the conversion; remove exceptions when owned.
ALLOW_UNLINKED = {
    'rule-type-safety': 'Type Safety is not linked in any converted Critical block.',
    'rule-test-steps': 'Test Steps is linked in procedures, not a Critical block.',
}

root = Path(sys.argv[1])
constitution = root / 'AGENTS.md'
skills = root / '.claude/skills'
if not skills.is_dir():
    skills = root / '.agents/skills'
if not constitution.is_file() or not skills.is_dir():
    print('ERROR: AGENTS.md and a scaffold skills tree are required.')
    sys.exit(2)
lock = root / 'skills-lock.json'
vendored = set(json.loads(lock.read_text()).get('skills', {})) if lock.exists() else set()
section = re.search(r'^## Constitution\s*\n(.*?)(?=^## |\Z)', constitution.read_text(), re.M | re.S)
if not section:
    print('ERROR: AGENTS.md Constitution section missing.')
    sys.exit(2)
rows = {}
errors = []
for line in section[1].splitlines():
    match = re.match(r'^- \*\*([^*]+)\*\*(.*)', line)
    if not match:
        continue
    name, tail = match.groups()
    anchor = re.match(r'<a id="(rule-[a-z0-9-]+)"></a>', tail)
    if not anchor or anchor[1] in rows:
        errors.append(f'AGENTS.md :: missing or duplicate row anchor: {name}')
    else:
        rows[anchor[1]] = name
if not rows:
    errors.append('AGENTS.md :: no anchored Constitution rows found')
# The row annotation above each hook rule id is the mapping; no side table.
ANNOTATION = re.compile(r'^# (AGENTS\.md#rule-[a-z0-9-]+(?:, AGENTS\.md#rule-[a-z0-9-]+)*)$')
hook = root / '.claude/scripts/enforce_constitution.py'
if not hook.is_file():
    if (root / '.claude').is_dir():
        errors.append('hook :: enforce_constitution.py not found')
else:
    source = hook.read_text()
    with warnings.catch_warnings():
        warnings.simplefilter('ignore', SyntaxWarning)
        tree = ast.parse(source)
    tables = [node.value for node in tree.body if isinstance(node, ast.Assign)
              and any(isinstance(t, ast.Name) and t.id == 'RULES' for t in node.targets)]
    ids = set()
    for table in tables:
        for item in table.elts:
            hid = ast.literal_eval(item.elts[0])
            ids.add(hid)
            # The row annotation belongs immediately before this tuple's id.
            annotation = source.splitlines()[item.elts[0].lineno - 2].strip()
            if '# hook-rule-id' not in source.splitlines()[item.elts[0].lineno - 1]:
                errors.append(f'hook :: {hid} missing hook-rule-id marker')
            found = ANNOTATION.match(annotation)
            if not found:
                errors.append(f'hook :: {hid} has no matching Constitution annotation')
            elif any(token.split('#')[1] not in rows for token in found[1].split(', ')):
                errors.append(f'hook :: {hid} annotation targets a missing row')
    if not tables:
        errors.append('hook :: RULES table missing')
    # Special gates are outside RULES. protected-path protects infrastructure
    # and has no Constitution row; exploration carries its own annotation.
    for hid in ('protected-path', 'explore-before-generate'):
        if f'[{hid}]' not in source:
            errors.append(f'hook :: special gate {hid} missing')
    annotation = '# AGENTS.md#rule-explore-before-generate, AGENTS.md#rule-no-substitute-ui-exploration'
    if annotation not in source or any(a not in rows for a in ('rule-explore-before-generate', 'rule-no-substitute-ui-exploration')):
        errors.append('hook :: explore-before-generate annotation missing or broken')
owners = {anchor: set() for anchor in rows}
link_pattern = re.compile(r'\[(?:\\.|[^\]\\])*\]\(\s*(<[^>\n]+>|[^\s()]+)(?:\s+[\'\"][^\n]*?[\'\"])?\s*\)')
def rendered(text):
    return re.sub(r'[`*_]', '', text).strip()


for skill in sorted(skills.glob('*/SKILL.md')):
    if skill.parent.name in vendored:
        continue
    critical = False
    fence = None
    text = re.sub(r'<!--.*?(?:-->|\Z)', lambda m: re.sub(r'[^\n]', ' ', m[0]), skill.read_text(), flags=re.S)
    for number, line in enumerate(text.splitlines(), 1):
        marker = re.match(r'^ {0,3}(`{3,}|~{3,})(.*)$', line)
        if marker:
            token, tail = marker.groups()
            if fence is None:
                fence = token
            elif token[0] == fence[0] and len(token) >= len(fence) and not tail.strip():
                fence = None
            continue
        if fence:
            continue
        if line.startswith('## '):
            critical = line.strip() == '## Critical'
            continue
        if not critical:
            continue
        # Inline code is an example, not a link carrying rule ownership.
        plain = re.sub(r'(`+)(?!`)(.+?)(?<!`)\1(?!`)', lambda m: ' ' * len(m[0]), line)
        for match in link_pattern.finditer(plain):
            target = unquote(match[1].strip('<>'))
            path, _, anchor = target.partition('#')
            if not path.endswith('AGENTS.md') or not anchor.startswith('rule-'):
                continue
            if (skill.parent / path).resolve() != constitution.resolve() or anchor not in rows:
                errors.append(f'{skill.relative_to(root)}:{number} :: broken Constitution row link: {target}')
            else:
                label = line[match.start() + 1:line.index('](', match.start())]
                if rendered(label) != rendered(rows[anchor]):
                    errors.append(f'{skill.relative_to(root)}:{number} :: ownership label differs from row name: {label} != {rows[anchor]}')
                else:
                    owners[anchor].add(skill.parent.name)
for anchor, name in rows.items():
    if owners[anchor]:
        if anchor in ALLOW_UNLINKED:
            errors.append(f'AGENTS.md :: stale coverage exception: {anchor} has an owner')
        print(f'OK    {name} ({anchor}) :: {", ".join(sorted(owners[anchor]))}')
    elif anchor in ALLOW_UNLINKED:
        print(f'ALLOW {name} ({anchor}) :: {ALLOW_UNLINKED[anchor]}')
    else:
        errors.append(f'AGENTS.md :: {name} ({anchor}) linked from no skill Critical block')
for error in errors:
    print(f'DRIFT {error}')
print(f'Checked {len(rows)} Constitution row(s); {len(errors)} drift(s).')
sys.exit(bool(errors))
PY
