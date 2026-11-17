// Builds the running demo of every step whose sidecar says `demo: true`, into
// public/demos/<tutorial>/<number>/. To save disk space, all steps of a tutorial are
// built one after the other in a single reused worktree, next to the tutorial repo,
// and only the distribution is copied out. A demo is rebuilt only if its commit changed.
//
//   node scripts/build-demos.mjs            build what is missing or outdated
//   node scripts/build-demos.mjs --clean    afterwards, remove the worktree and its build dir
import { execFileSync, execSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';

const siteRoot = process.cwd();
const tutorials = JSON.parse(fs.readFileSync(path.join(siteRoot, 'tutorials.json'), 'utf8'));
const clean = process.argv.includes('--clean');

function run(cmd, args, cwd) {
  return execFileSync(cmd, args, { cwd, encoding: 'utf8', stdio: ['ignore', 'pipe', 'inherit'], windowsHide: true });
}
// gradle is a .bat on Windows, which only a shell can start
const gradle = (args, cwd) => execSync(['gradle', ...args].join(' '), { cwd, stdio: ['ignore', 'pipe', 'inherit'], windowsHide: true });
const git = (repo, args) => run('git', ['-C', repo, ...args]);

for (const t of tutorials) {
  const repo = path.resolve(siteRoot, t.repo);
  // next to the repo, so that relative paths in the build (e.g. to ../../webgpumath) still work
  const worktree = path.join(path.dirname(repo), `.demo-build-${t.id}`);
  const log = git(repo, ['log', '--reverse', '--format=%H%x1f%(trailers:key=Step,valueonly)%x1e', t.branch]);
  const steps = log.split('\x1e').map((r) => r.trim()).filter(Boolean)
    .map((r) => r.split('\x1f').map((s) => s.trim()))
    .filter(([, stepId]) => stepId);

  for (const [commit, stepId] of steps) {
    const number = stepId.split('.').pop();
    const sidecar = git(repo, ['show', `${commit}:.tutorial/${number}.mdx`]);
    if (!/^demo:\s*true\s*$/m.test(sidecar)) continue;

    const outDir = path.join(siteRoot, 'public/demos', t.id, number);
    const stamp = path.join(outDir, '.commit');
    if (fs.existsSync(stamp) && fs.readFileSync(stamp, 'utf8') === commit) {
      console.log(`${t.id} ${number}: up to date`);
      continue;
    }

    if (!fs.existsSync(worktree)) git(repo, ['worktree', 'add', '--detach', worktree, commit]);
    else run('git', ['checkout', '--quiet', '--detach', commit], worktree);

    console.log(`${t.id} ${number}: building ${commit.slice(0, 7)}...`);
    gradle(['jsBrowserDistribution', '-q'], worktree);

    const dist = path.join(worktree, 'build/dist/js/productionExecutable');
    fs.rmSync(outDir, { recursive: true, force: true });
    fs.cpSync(dist, outDir, { recursive: true });
    fs.writeFileSync(stamp, commit);
  }

  if (clean && fs.existsSync(worktree)) {
    git(repo, ['worktree', 'remove', '--force', worktree]);
    console.log(`${t.id}: removed ${worktree}`);
  }
}
