// Build-time access to the tutorial repositories. Everything is read straight from git,
// at the commit of the step, so nothing has to be checked out or copied.
import { execFileSync } from 'node:child_process';
import path from 'node:path';

const siteRoot = process.cwd();

export function repoPath(repo: string): string {
  return path.resolve(siteRoot, repo);
}

// A commit never changes, so what git says about it can be kept for the life of the server.
const cache = new Map<string, string>();

function git(repo: string, args: string[]): string {
  const key = [repo, ...args].join('\0');
  const cached = cache.get(key);
  if (cached !== undefined) return cached;
  const output = execFileSync('git', ['-C', repoPath(repo), ...args], {
    encoding: 'utf8',
    maxBuffer: 64 * 1024 * 1024,
    // the dev server runs without a console: without this, Windows opens one for every git call
    windowsHide: true,
    stdio: ['ignore', 'pipe', 'pipe'],
  });
  cache.set(key, output);
  return output;
}

/** The contents of `file` at `commit`. */
export function fileAt(repo: string, commit: string, file: string): string {
  try {
    return git(repo, ['show', `${commit}:${file}`]);
  } catch {
    throw new Error(`Tutorial step ${commit.slice(0, 7)} has no file '${file}'.`);
  }
}

/** The diff that the step makes to `file`, or the diff from `against` to `file` within the step. */
export function diffAt(repo: string, commit: string, file: string, against?: string): string {
  const args = against
    ? ['diff', '--no-color', `${commit}:${against}`, `${commit}:${file}`]
    : ['show', '--no-color', '--format=', commit, '--', file];
  const raw = git(repo, args);
  const lines: string[] = [];
  let inHunk = false;
  for (const line of raw.split('\n')) {
    if (line.startsWith('@@')) {
      if (inHunk) lines.push(' ⋮');
      inHunk = true;
      continue;
    }
    if (!inHunk) continue; // diff --git, index, ---, +++ headers
    if (line.startsWith('\\')) continue; // "\ No newline at end of file"
    lines.push(line);
  }
  while (lines.length && lines[lines.length - 1] === '') lines.pop();
  if (!lines.length) {
    throw new Error(`Tutorial step ${commit.slice(0, 7)} does not change '${file}'${against ? ` relative to '${against}'` : ''}.`);
  }
  return lines.join('\n');
}

/** The 0-based index of the only line containing `pattern`; an error if there is none or more than one. */
export function lineOf(text: string, pattern: string, file: string, commit: string): number {
  const lines = text.split('\n');
  const hits = lines.flatMap((line, i) => (line.includes(pattern) ? [i] : []));
  if (hits.length !== 1) {
    const where = `'${file}' at step ${commit.slice(0, 7)}`;
    throw new Error(
      hits.length === 0
        ? `Pattern ${JSON.stringify(pattern)} is not found in ${where}.`
        : `Pattern ${JSON.stringify(pattern)} is ambiguous in ${where}: lines ${hits.map((i) => i + 1).join(', ')}.`
    );
  }
  return hits[0];
}

export function languageOf(file: string): string {
  const ext = file.split('.').pop() ?? '';
  return (
    { kt: 'kotlin', kts: 'kotlin', wgsl: 'wgsl', html: 'html', css: 'css', js: 'js', json: 'json' } as Record<string, string>
  )[ext] ?? 'text';
}
