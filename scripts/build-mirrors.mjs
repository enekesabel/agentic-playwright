#!/usr/bin/env node
// build-mirrors.mjs
//
// Regenerates the Cursor and Copilot rule trees from the canonical Claude tree
// (`CLAUDE.md` + `.claude/skills/`). The mirrors are build output: edit the
// canonical tree, then run `npm run build:mirrors`.
//
//   Cursor   .cursor/skills/<x>/**                  <- .claude/skills/<x>/**
//            .cursor/rules/rules.mdc                <- CLAUDE.md + Cursor frontmatter
//   Copilot  .github/instructions/<x>.instructions.md   <- SKILL.md body + applyTo
//            .github/instructions/<x>/references/**     <- references/**
//            .github/copilot-instructions.md            <- CLAUDE.md + Copilot header
//
// Not generated: `.github/skills/skill-creator/` (hand-kept folder-form copy)
// and `.github/prompts/` (hand-written Copilot prompt for pr-reviewer).
//
// Rewriting, applied to every non-vendored file:
//   - Markdown link targets are resolved against the canonical file, mapped to
//     their mirror path, and made relative to the mirror file again, so links
//     stay inside the tree that contains them. A link to a canonical rule-tree
//     file that has no counterpart in a mirror fails the build. Exception: in a
//     flat Copilot instructions file, `references/...` targets stay verbatim;
//     the references check resolves them against `.github/instructions/<x>/`.
//   - Path mentions in prose (`.claude/...`, `CLAUDE.md`) are substituted with
//     the mirror's paths.
// Vendored skills (listed in skills-lock.json) are copied verbatim so their
// upstream content and code stay intact.
//
// Node built-ins only (no npm install needed). Path arithmetic for relative
// links is why this is not bash.
//
// Usage: node scripts/build-mirrors.mjs [root-dir]   (default: this repo)

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = path.resolve(
    process.argv[2] ??
        path.join(path.dirname(fileURLToPath(import.meta.url)), '..')
);

const CANON_SKILLS = '.claude/skills';
const CONSTITUTION = 'CLAUDE.md';

// Copilot `applyTo` globs, one per mirrored skill. A canonical skill missing
// here has no Copilot instructions file (pr-reviewer ships as a prompt).
const COPILOT_APPLY_TO = {
    'ai-native-workflow': '**/*',
    'api-testing': 'fixtures/api/**/*.ts,tests/**/api/**/*.ts',
    'common-tasks':
        'pages/**/*.ts,tests/**/*.ts,fixtures/**/*.ts,test-data/**/*',
    config: 'config/**/*.ts',
    'data-strategy': 'test-data/**/*,tests/**/*.ts',
    debugging: 'tests/**/*.ts',
    enums: 'enums/**/*.ts',
    fixtures: 'fixtures/**/*.ts',
    helpers: 'helpers/**/*.ts',
    'page-objects': 'pages/**/*.ts',
    'playwright-cli': '**/*',
    'refactor-values': 'enums/**/*.ts,test-data/static/**/*.ts',
    selectors: 'pages/**/*.ts',
    'skill-creator': '.github/instructions/**/*.md',
    'test-standards': 'tests/**/*.ts',
    'type-safety': '**/*.ts',
};

const CURSOR_FRONTMATTER = [
    '---',
    'description: Agentic Playwright orchestrator -- constitution, workflow, and skills index',
    'globs:',
    'alwaysApply: true',
    '---',
    '',
    '',
].join('\n');

// Replaces everything above the Constitution's first `---` rule.
const COPILOT_HEADER = [
    '# Agentic Playwright -- Copilot Instructions',
    '',
    'This file is always loaded by GitHub Copilot. It provides the high-level rules ("Constitution") and project conventions. Detailed, file-scoped instructions live in `.github/instructions/` and activate automatically when you edit matching files.',
    '',
    '',
].join('\n');

// Constitution lines that only apply to Claude Code; dropped from both mirrors.
const CLAUDE_ONLY_LINES = [
    '- **Claude Code CLI** is pre-installed globally — use `claude` directly',
];

const MIRRORS = {
    cursor: {
        present: () => exists('.cursor'),
        outputs: ['.cursor/skills', '.cursor/rules/rules.mdc'],
        constitution: '.cursor/rules/rules.mdc',
        // Every canonical skill file has a counterpart at the same depth.
        mapSkillFile: (skill, rest) => `.cursor/skills/${skill}/${rest}`,
        prose: [
            [/\.claude\//g, '.cursor/'],
            [/CLAUDE\.md/g, '.cursor/rules/rules.mdc'],
        ],
    },
    copilot: {
        present: () =>
            exists('.github/instructions') ||
            exists('.github/copilot-instructions.md'),
        outputs: ['.github/instructions', '.github/copilot-instructions.md'],
        constitution: '.github/copilot-instructions.md',
        mapSkillFile: (skill, rest) => {
            if (!(skill in COPILOT_APPLY_TO)) return null;
            if (rest === 'SKILL.md')
                return `.github/instructions/${skill}.instructions.md`;
            if (rest.startsWith('references/'))
                return `.github/instructions/${skill}/${rest}`;
            return null;
        },
        prose: [
            [
                /\.claude\/skills\/([A-Za-z0-9_{}<>*-]+)\/SKILL\.md/g,
                '.github/instructions/$1.instructions.md',
            ],
            [/\.claude\/skills\//g, '.github/instructions/'],
            [/CLAUDE\.md/g, '.github/copilot-instructions.md'],
        ],
    },
};

function abs(rel) {
    return path.join(ROOT, rel);
}

function exists(rel) {
    return fs.existsSync(abs(rel));
}

function listFiles(relDir) {
    const out = [];
    for (const entry of fs
        .readdirSync(abs(relDir), { withFileTypes: true })
        .sort((a, b) => a.name.localeCompare(b.name))) {
        const rel = `${relDir}/${entry.name}`;
        if (entry.isDirectory()) out.push(...listFiles(rel));
        else if (entry.isFile()) out.push(rel);
    }
    return out;
}

function vendoredSkills() {
    if (!exists('skills-lock.json')) return new Set();
    const lock = JSON.parse(fs.readFileSync(abs('skills-lock.json'), 'utf8'));
    return new Set(Object.keys(lock.skills ?? {}));
}

// Mirror path of a repo-relative canonical path, or null if the canonical
// path is part of the Claude rule tree but has no counterpart in the mirror.
// Paths outside the Claude rule tree map to themselves.
function mapPath(mirror, rel) {
    if (rel === CONSTITUTION) return mirror.constitution;
    if (rel.startsWith(`${CANON_SKILLS}/`)) {
        const [skill, ...rest] = rel.slice(CANON_SKILLS.length + 1).split('/');
        if (rest.length === 0) return null;
        return mirror.mapSkillFile(skill, rest.join('/'));
    }
    if (rel === '.claude' || rel.startsWith('.claude/')) return null;
    return rel;
}

const LINK = /\]\(([^)\s]+)((?:\s+"[^"]*")?)\)/g;

function isExternal(target) {
    return /^(?:[a-z][a-z0-9+.-]*:|#|\/|<)/i.test(target);
}

// Rewrite one file's text for a mirror. `src` and `dest` are repo-relative.
function rewrite(text, src, dest, mirror, errors) {
    const links = [];
    const flatCopilotFile = dest.endsWith('.instructions.md');
    let out = text.replace(LINK, (match, target, title) => {
        let next = target;
        if (
            !isExternal(target) &&
            !(flatCopilotFile && target.startsWith('references/'))
        ) {
            const hash = target.indexOf('#');
            const file = hash === -1 ? target : target.slice(0, hash);
            const anchor = hash === -1 ? '' : target.slice(hash);
            const resolved = path.posix.normalize(
                path.posix.join(path.posix.dirname(src), file)
            );
            if (!resolved.startsWith('../')) {
                const mapped = mapPath(mirror, resolved);
                if (mapped === null) {
                    errors.push(
                        `${src}: link '${target}' points to ${resolved}, which has no counterpart in ${dest.split('/')[0]}/`
                    );
                } else {
                    next =
                        path.posix.relative(path.posix.dirname(dest), mapped) +
                        anchor;
                }
            }
        }
        links.push(`](${next}${title})`);
        return `\u0000${links.length - 1}\u0000`;
    });
    for (const [pattern, replacement] of mirror.prose) {
        out = out.replace(pattern, replacement);
    }
    return out.replace(/\u0000(\d+)\u0000/g, (_, i) => links[Number(i)]);
}

function writeFile(dest, content, modeFrom) {
    fs.mkdirSync(path.dirname(abs(dest)), { recursive: true });
    fs.writeFileSync(abs(dest), content);
    if (modeFrom) fs.chmodSync(abs(dest), fs.statSync(abs(modeFrom)).mode);
}

function stripFrontmatter(text) {
    const match = /^---\n[\s\S]*?\n---\n/.exec(text);
    return match ? text.slice(match[0].length) : text;
}

function constitutionBody(text) {
    return text
        .split('\n')
        .filter((line) => !CLAUDE_ONLY_LINES.includes(line))
        .join('\n');
}

function buildMirror(name, mirror, vendored, errors) {
    for (const out of mirror.outputs) {
        fs.rmSync(abs(out), { recursive: true, force: true });
    }

    for (const src of listFiles(CANON_SKILLS)) {
        const [skill, ...restParts] = src
            .slice(CANON_SKILLS.length + 1)
            .split('/');
        if (restParts.length === 0) continue;
        const rest = restParts.join('/');
        const dest = mirror.mapSkillFile(skill, rest);
        if (dest === null) continue;

        let content = fs.readFileSync(abs(src));
        if (vendored.has(skill)) {
            if (name === 'copilot' && rest === 'SKILL.md') {
                content = copilotInstructions(skill, content.toString('utf8'));
            }
        } else {
            let text = content.toString('utf8');
            if (name === 'copilot' && rest === 'SKILL.md') {
                text = copilotInstructions(skill, text);
            }
            if (/\.(md|mdc)$/.test(src)) {
                text = rewrite(text, src, dest, mirror, errors);
            } else {
                for (const [pattern, replacement] of mirror.prose) {
                    text = text.replace(pattern, replacement);
                }
            }
            content = text;
        }
        writeFile(dest, content, src);
    }

    let constitution = constitutionBody(
        fs.readFileSync(abs(CONSTITUTION), 'utf8')
    );
    if (name === 'cursor') {
        constitution = CURSOR_FRONTMATTER + constitution;
    } else {
        const rule = constitution.search(/^---$/m);
        constitution = COPILOT_HEADER + constitution.slice(rule);
    }
    writeFile(
        mirror.constitution,
        rewrite(constitution, CONSTITUTION, mirror.constitution, mirror, errors)
    );
}

function copilotInstructions(skill, text) {
    return `---\napplyTo: '${COPILOT_APPLY_TO[skill]}'\n---\n${stripFrontmatter(text)}`;
}

function main() {
    if (!exists(CANON_SKILLS) || !exists(CONSTITUTION)) {
        console.log(
            'SKIP: canonical Claude tree not present (pruned at init) -- nothing to build.'
        );
        return 0;
    }

    const errors = [];
    const skills = fs
        .readdirSync(abs(CANON_SKILLS))
        .filter((d) => exists(`${CANON_SKILLS}/${d}/SKILL.md`));
    for (const skill of Object.keys(COPILOT_APPLY_TO)) {
        if (!skills.includes(skill)) {
            errors.push(
                `build-mirrors.mjs: Copilot applyTo mapping names '${skill}', but ${CANON_SKILLS}/${skill}/SKILL.md does not exist`
            );
        }
    }

    const vendored = vendoredSkills();
    for (const [name, mirror] of Object.entries(MIRRORS)) {
        if (!mirror.present()) {
            console.log(`SKIP  ${name}: tree not present (pruned at init)`);
            continue;
        }
        buildMirror(name, mirror, vendored, errors);
        console.log(`BUILT ${name}: ${mirror.outputs.join(', ')}`);
    }

    if (errors.length > 0) {
        for (const error of errors) console.error(`ERROR ${error}`);
        console.error(
            `\n${errors.length} error(s). Fix the canonical files or the mapping in scripts/build-mirrors.mjs.`
        );
        return 1;
    }
    return 0;
}

process.exitCode = main();
