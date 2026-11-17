# Computer Graphics tutorials site

The tutorials of the 3gr and is courses, step by step, published at https://bme-iit-cg.github.io/.

Each tutorial is a branch of a course repository (e.g. `BME-IIT-CG/kog-3gr`): a chain of
commits, one per step, each with a `Step:` trailer and its notes in `.tutorial/<number>.mdx`.
This site turns them into pages, slides and running demos.

## Layout

- `tutorials.json`: which branch of which repository is which tutorial, and where it goes in the site.
  Repository paths are relative to this folder; the course repositories are expected in `../tutorials/`.
- `scripts/sync-tutorials.mjs`: writes a page per step (and an overview page per tutorial) into
  `src/content/docs/<section>/`. Generated, not committed.
- `src/components/tutorial/`: `Snippet`, `Diff`, `Note`, `Demo`, used in the notes. They read the code
  from git at build time. A pattern that matches no line or more than one fails the build.
- `scripts/build-demos.mjs`: builds the steps marked `demo: true` with Gradle into `public/demos/`.
  The demos are committed, so the site can be built without Gradle.
- `src/pages/slides/`: all steps of a tutorial as slides.

## Commands

| Command | Action |
| :-- | :-- |
| `npm install` | Install dependencies |
| `npm run dev` | Sync the tutorials, start the dev server at `localhost:4321` |
| `npm run build` | Sync the tutorials, build the site into `./dist/` |
| `npm run demos` | Build the demos that are missing or outdated (`-- --clean` removes the build worktree after) |

Needs Node ≥ 22.23 (Astro 7).
