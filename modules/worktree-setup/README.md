# worktree-setup

Sets up newly created linked git worktrees automatically, via a `post-checkout`
hook.

When you run `git worktree add`, the new worktree starts out with only the
tracked files. Everything gitignored -- `.env.local`, `.mise.local.toml`,
`.claude/settings.local.json` -- is missing, and whatever bootstrap commands the
project needs (`mise trust`, `aqua policy allow`, ...) have not been run. This
module fills that gap at the moment the worktree is created, no matter what
created it: the CLI, an editor, or a tool.

## How it works

`git worktree add` fires the repository's `post-checkout` hook with a null
previous HEAD. The hook runs `setup-worktree.sh` in the new worktree, which
performs two phases in order:

1. **Copy** -- copies untracked files declared in the main worktree's
   `.worktreeinclude` into the new worktree.
2. **Run** -- executes setup scripts declared in the main worktree
   (`.worktreesetup`), but only when the repository is trusted. See
   [Trust model](#trust-model).

Both declarations are read from the **main worktree root**, so a worktree gets
set up from the configuration you already have checked out there.

In detail, the script:

1. Exits silently unless the previous HEAD is the null SHA. An ordinary
   `git checkout` passes a real SHA and needs no setup.
2. Exits silently unless the current directory is a *linked* worktree (detected
   by comparing `git rev-parse --git-dir` with `--git-common-dir`). This also
   excludes `git clone`, which fires with a null SHA too but creates a main
   worktree.
3. Locates the main worktree (first entry of `git worktree list --porcelain`).
4. **Copy phase** -- reads the declarations in the main worktree root
   (gitignore-style patterns) and copies each matching untracked file
   (`git ls-files --others --ignored --exclude-from=...`) into the worktree,
   preserving permissions and timestamps (`cp -p`). Skipped if neither file
   exists:
   - `.worktreeinclude` -- team-shared list, usually tracked
   - `.worktreeinclude.local` -- personal additions, untracked
5. **Run phase** -- if the repository is trusted, executes the setup scripts
   found in the main worktree root, in order, with `bash` and the worktree root
   as the working directory:
   - `.worktreesetup` -- team-shared setup script, usually tracked
   - `.worktreesetup.local` -- personal setup script, untracked

Messages appear on **stderr** of the `git worktree add` command. Git redirects a
hook's stdout to stderr, so capture `2>` when scripting against the output.

## Installation

Two steps, **in this order**.

First, deploy the scripts with home-manager. This puts `setup-worktree.sh` at
`~/.local/share/worktree-setup/setup-worktree.sh` and the installer at
`~/bin/worktree-setup-install`:

```sh
make switch/home
```

Then, in each repository you want it active in:

```sh
worktree-setup-install
```

The order matters: `worktree-setup-install` refuses to write a hook until the
body script is deployed, and tells you to run `make switch/home` first.

`.git/hooks` is not tracked by git, so this is once per clone. The hook is
written to the repository's common hooks directory, so it covers every worktree
of that repository -- installing from a linked worktree works the same as from
the main one.

What gets written is a small dispatcher that runs the shared copy of
`setup-worktree.sh`. Updating the body therefore only requires
`make switch/home`; you never have to re-install in every repository.

### When a `post-checkout` hook already exists

`worktree-setup-install` never overwrites a hook it did not write in full.
Instead it prints the block to add by hand:

```bash

# Installed by worktree-setup. v1
_wts_rc=$?
_wts="${XDG_DATA_HOME:-$HOME/.local/share}/worktree-setup/setup-worktree.sh"
[ -x "$_wts" ] && "$_wts" "$@"
exit "$_wts_rc"
```

Keep the leading blank line: without it the block can run into an unterminated
last line. `_wts_rc` preserves the existing hook's exit status, which matters
because git propagates a `post-checkout` exit code to `git worktree add`.

Two shapes get different advice instead:

- A hook ending in `exit` or `exec` -- an appended block would be dead code, so
  put it immediately *before* that line.
- A hook that is not a shell script (`#!/usr/bin/env python3`, ...) -- appending
  would break it. Split the hook, or register `setup-worktree.sh` with whatever
  tool owns it.

Once the block is present, `worktree-setup-install` recognizes the file as
externally managed and leaves it alone from then on -- it will neither rewrite
nor delete it.

## Per-project setup

Put a `.worktreeinclude` file in the repository root, listing the gitignored
files to carry over:

```gitignore
.env.*
.claude/settings.local.json
.claude/**/*.local.md
```

When `.worktreeinclude` is shared with your team (tracked in git), declare
personal, machine-local files in `.worktreeinclude.local` instead -- it is read
in addition to the shared file and should stay untracked:

```gitignore
# .worktreeinclude.local
.mise.local.toml
zed.local
```

To run bootstrap commands, add a `.worktreesetup` script to the repository root
(and, for machine-local commands, an untracked `.worktreesetup.local`):

```bash
#!/usr/bin/env bash
# .worktreesetup -- runs on every worktree creation; keep it idempotent.
mise trust
aqua policy allow
```

Then add the repository (or its org) to your trust allowlist so the script is
allowed to run -- see [Trust model](#trust-model):

```sh
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/worktree-setup"
echo "github.com/your-org" >> "${XDG_CONFIG_HOME:-$HOME/.config}/worktree-setup/trusted"
```

Projects with none of these files are left untouched, and produce no output.

### Declarations added later do not reach existing worktrees

The hook fires **only when a worktree is created**. Adding an entry to
`.worktreeinclude` afterwards has no effect on worktrees that already exist. To
apply it to one, run the script there by hand -- with no arguments it always
proceeds:

```sh
cd /path/to/existing/worktree
~/.local/share/worktree-setup/setup-worktree.sh
```

## Trust model

Copying files is low-risk: a repository can only copy its own untracked files
into its own worktrees. **Executing setup scripts is different** -- an arbitrary
`.worktreesetup` shipped by a cloned repository could run any code. To contain
this, setup scripts run **only when the repository is on a trust allowlist that
lives outside any repository**, so a clone cannot authorize itself.

The allowlist is a plain text file:

```
${XDG_CONFIG_HOME:-$HOME/.config}/worktree-setup/trusted
```

One entry per line; `#` comments and blank lines are ignored. Each entry names
either a whole organization or a single repository:

```
# ~/.config/worktree-setup/trusted
github.com/handlename                 # trust every repo under this org
github.com/someorg/somerepo           # trust just this one repo
```

The repository's identity is derived from its `origin` remote
(`git remote get-url origin`), normalized to `host/org/repo`. Both
`.worktreesetup` and `.worktreesetup.local` are gated: if the repository (or its
org) is not listed -- or the repository has no `origin` remote -- neither setup
script runs. The copy phase is unaffected by the allowlist.

When setup scripts exist but the repository is not trusted, the script does not
stay silent. It names the scripts it did **not** run and prints the exact
command to opt in:

```
setup-worktree: setup scripts found but NOT run — this repository is not trusted:
  - /path/to/main/.worktreesetup
  To run them, add this repository (or its org) to the trust allowlist:
    echo 'github.com/your-org/your-repo' >> "/Users/you/.config/worktree-setup/trusted"
```

### What trusting a repository actually grants

Worth understanding before adding an entry:

- **Org-wide entries are broad.** `github.com/your-org` grants execution to
  *every* repository under that org, including ones created after you added the
  entry. Prefer `host/org/repo` when you only mean one repository.
- **`.worktreesetup` is usually tracked**, so trusting a repository means
  trusting what your collaborators commit to it. The next worktree you create
  after a `git pull` runs whatever the script says at that point.
- **It is read from the main worktree's working tree**, not from a fixed
  revision. If you have a PR branch checked out in the main worktree, creating a
  worktree runs *that branch's* script.
- **Subgroups are not matched.** The org is computed by stripping the last path
  segment, so for `gitlab.com/org/sub/repo` the org is `gitlab.com/org/sub`. An
  entry of `gitlab.com/org` will not match. This fails closed -- the script does
  not run -- so it is safe, just surprising.

## Safety properties

- **Never overwrites** existing files in the worktree (copy phase).
- **Never follows symlinks** -- a symlinked declaration or setup script is
  skipped, so a repository cannot use one to reach files outside itself.
- **Copy phase is idempotent** -- a second run copies nothing new.
- **Setup scripts run on every worktree creation**, so they must be written to
  be idempotent. There is no first-run marker; `mise trust` and
  `aqua policy allow` are safe to re-run.
- A failing setup script is reported to stderr but does **not** fail the
  checkout.
- **Always exits 0**, so `git worktree add` is never reported as failed. This is
  not cosmetic: git propagates a `post-checkout` exit code to its caller, and a
  non-zero status would break `git worktree add ... && cd ...` and anything else
  chaining off it.
- `worktree-setup-install` **never overwrites a hook it did not write**, never
  writes through a symlink, and writes via a temporary file plus `mv` so an
  existing hard link is not followed.

## Updating and uninstalling

To update the body, edit `setup-worktree.sh` here and run `make switch/home`.
Repositories pick it up automatically; no re-install needed.

To remove the hook from a repository:

```sh
worktree-setup-install --uninstall
```

This only removes a dispatcher this tool wrote in full. If you wired up an
existing hook by hand, it says so and leaves the file alone -- delete the block
yourself. Uninstalling works even when the body script is not deployed, which is
exactly when you are most likely to need it.

**Removing the module does not remove the installed hooks.** Dropping
`./modules/worktree-setup` from `home.nix`, rolling back a home-manager
generation, or using a machine where you have not run `make switch/home` all
remove the body -- but every dispatcher you installed stays where it is. They
are written to be harmless in that state: they exit 0 and, only when a worktree
is created, print a line telling you to run `make switch/home`. There is no
record of which repositories you installed into, so a complete removal means
running `--uninstall` in each one.

## Known limitations

- **jujutsu is not supported.** `jj workspace add` does not run git hooks at
  all, so nothing fires. There is no workaround short of running
  `setup-worktree.sh` by hand in the new workspace.
- **`git worktree add --no-checkout` is not supported.** No checkout happens, so
  `post-checkout` never fires.
- **Hook managers may conflict.** lefthook, husky, and pre-commit manage
  `.git/hooks` themselves and can overwrite or bypass the dispatcher.
  `worktree-setup-install` warns when it spots one. In that case register
  `setup-worktree.sh` with that manager instead -- for lefthook, in
  `lefthook.yml`:

  ```yaml
  post-checkout:
    commands:
      worktree-setup:
        run: ${XDG_DATA_HOME:-$HOME/.local/share}/worktree-setup/setup-worktree.sh {0}
  ```

  Note that this has to live in the repository's committed config, which makes
  it a poor fit for a personal, cross-repository setup -- the manager resolves
  its config from the *new* worktree, where your untracked personal config does
  not exist yet.
- **A relative `core.hooksPath` resolves per worktree.** The hook is installed
  under the main worktree, so it will not fire for `git worktree add` run from
  inside a linked worktree, nor for `git checkout` there.
  `worktree-setup-install` warns when it sees one. Use an absolute path to avoid
  this.

## Requirements

- bash 3.2+ (the macOS default is sufficient)
- git 2.31+ (for `rev-parse --path-format=absolute`; on older git the script
  silently no-ops)

On very large working trees the `git ls-files --others` scan can take a few
seconds. It only runs in linked worktrees of projects that opted in via
`.worktreeinclude`.
