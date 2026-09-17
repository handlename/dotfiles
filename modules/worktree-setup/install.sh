#!/usr/bin/env bash
#
# install.sh (installed as `worktree-setup-install`)
#
# Installs a `post-checkout` dispatcher into a repository so that
# `git worktree add` runs setup-worktree.sh for newly created worktrees.
#
# The dispatcher is a few lines that run a single shared copy of
# setup-worktree.sh. The shared copy is deployed by home-manager
# (see default.nix), NOT by this script -- so updating the body only requires
# `make switch/home`, never a re-install in every repository.
#
# Usage:
#   worktree-setup-install [<repo-path>]              install into a repository
#   worktree-setup-install [<repo-path>] --uninstall  remove the dispatcher
#
# Safety properties:
#   - Never overwrites a `post-checkout` this tool did not write in full.
#   - Never writes through a symlink.
#   - Writes via a temporary file + mv, so hard links are not followed.
#   - Installing twice is a no-op.

set -u

readonly MARKER_PREFIX='# Installed by worktree-setup.'
readonly CURRENT_VERSION=1
# Every version whose template must still be recognised as "written by us".
readonly KNOWN_VERSIONS='1'

BODY_PATH="${XDG_DATA_HOME:-$HOME/.local/share}/worktree-setup/setup-worktree.sh"

warn() { echo "worktree-setup-install: $*" >&2; }
# Unprefixed stderr, for blocks meant to be copied verbatim.
note() { echo "$*" >&2; }
die() { warn "$*"; exit 1; }

# Print the exact bytes of the dispatcher for the given version.
#
# This is the single source of truth for the dispatcher: both writing and the
# `own` comparison in classify_hook() go through it. Splitting the two would
# silently break `own` detection on the next version bump.
dispatcher_template() {
    local version="$1"
    case "$version" in
        1) ;;
        *) return 1 ;;
    esac
    cat <<'TEMPLATE'
#!/usr/bin/env bash
# Installed by worktree-setup. v1
# https://github.com/handlename/dotfiles modules/worktree-setup
body="${XDG_DATA_HOME:-$HOME/.local/share}/worktree-setup/setup-worktree.sh"
if [ ! -x "$body" ]; then
    # Only complain when a worktree is created (null previous HEAD); stay
    # silent on ordinary branch switches. Never fail the checkout.
    case "${1-}" in
        *[!0]*) ;;
        *) echo "worktree-setup: $body is missing; run 'make switch/home' in your dotfiles" >&2 ;;
    esac
    exit 0
fi
"$body" "$@"
exit 0
TEMPLATE
}

# Classify an existing hook file. Prints one of:
#   own <version>   the file is byte-for-byte a dispatcher we wrote
#   appended        not ours, but carries our marker line (someone followed the
#                   append instructions) -- never rewrite or delete it
#   foreign         no marker at all
#
# Byte-for-byte comparison is deliberate. Heuristics based on where the marker
# line appears misclassify short foreign hooks: a 1-2 line hook plus the
# appended snippet puts the marker near the top, which would look like a file
# we wrote in full, and the next version bump would replace it wholesale.
classify_hook() {
    local hook="$1" version
    for version in $KNOWN_VERSIONS; do
        if diff -q <(dispatcher_template "$version") "$hook" >/dev/null 2>&1; then
            echo "own $version"
            return 0
        fi
    done
    if grep -Eq "^${MARKER_PREFIX} v[0-9]+\$" "$hook"; then
        echo appended
        return 0
    fi
    echo foreign
}

# Resolve the directory git will look for hooks in.
#
# `git config --get core.hooksPath` must NOT be used: it returns the raw
# configured value, so a relative path resolves against the caller's cwd and a
# `~/...` value is taken literally. `rev-parse --git-path hooks` expands all of
# those correctly.
#
# The one case git itself cannot make unambiguous is a *relative*
# core.hooksPath: it resolves per worktree, so main and linked worktrees use
# different directories. We install into the main worktree's copy and warn.
resolve_hooks_dir() {
    local repo="$1" configured main_wt

    configured=$(git -C "$repo" config --get core.hooksPath 2>/dev/null) || configured=''

    case "$configured" in
        ''|/*|'~'*)
            git -C "$repo" rev-parse --path-format=absolute --git-path hooks 2>/dev/null
            ;;
        *)
            main_wt=$(git -C "$repo" worktree list --porcelain 2>/dev/null | sed -n '1s/^worktree //p')
            [[ -n "$main_wt" ]] || return 1
            warn "core.hooksPath is relative ('$configured'); installing into the main worktree copy."
            warn "  git resolves it per worktree, so the hook will NOT fire for:"
            warn "    - 'git worktree add' run from inside a linked worktree"
            warn "    - 'git checkout' inside a linked worktree"
            warn "  Use an absolute core.hooksPath to avoid this."
            printf '%s/%s\n' "$main_wt" "$configured"
            ;;
    esac
}

warn_hook_managers() {
    local repo="$1" main_wt marker found=0

    main_wt=$(git -C "$repo" worktree list --porcelain 2>/dev/null | sed -n '1s/^worktree //p')
    [[ -n "$main_wt" ]] || return 0

    for marker in lefthook.yml lefthook.yaml lefthook.toml lefthook.json .lefthook .husky .pre-commit-config.yaml; do
        if [[ -e "$main_wt/$marker" ]]; then
            [[ "$found" -eq 0 ]] && warn "a hook manager seems to be in use in this repository:"
            warn "  - $marker"
            found=1
        fi
    done
    [[ "$found" -eq 0 ]] && return 0
    warn "  It may overwrite or bypass .git/hooks/post-checkout. Consider registering"
    warn "  setup-worktree.sh with that manager instead of installing here."
}

# Explain how to wire an existing foreign hook up by hand.
#
# Two shapes cannot be handled by appending and get a different message:
#   - a hook ending in `exit`/`exec`, where an appended block is dead code
#   - a hook that is not a shell script at all, where appending breaks it
explain_manual_wiring() {
    local hook="$1" shebang last

    shebang=$(head -n 1 "$hook")
    case "$shebang" in
        '#!'*sh|'#!'*sh\ *|'#!'*/env\ *sh)
            ;;
        *)
            warn "  $hook is not a shell script ($shebang)."
            warn "  Appending would break it. Split the hook, or register setup-worktree.sh"
            warn "  with whatever tool owns it."
            return 0
            ;;
    esac

    warn "  To wire it up by hand, add this to $hook:"
    note ''
    note '    # Installed by worktree-setup. v1'
    note '    _wts_rc=$?'
    note '    _wts="${XDG_DATA_HOME:-$HOME/.local/share}/worktree-setup/setup-worktree.sh"'
    note '    [ -x "$_wts" ] && "$_wts" "$@"'
    note '    exit "$_wts_rc"'
    note ''
    warn "  Keep the blank line before it: without one it can run into an unterminated"
    warn "  last line and both break the hook and hide the marker."

    last=$(grep -vE '^\s*(#|$)' "$hook" | tail -n 1)
    case "$last" in
        exit*|exec*)
            warn "  NOTE: $hook ends with '$last'. Put the block immediately BEFORE that"
            warn "  line -- appended after it, it would never run."
            ;;
    esac
}

write_dispatcher() {
    local hook="$1" tmp
    # Write and rename so an existing hard link keeps pointing at the old file.
    tmp=$(mktemp "${hook}.XXXXXX") || die "cannot create a temporary file next to $hook"
    if ! dispatcher_template "$CURRENT_VERSION" > "$tmp"; then
        rm -f "$tmp"
        die "no template for version $CURRENT_VERSION"
    fi
    chmod +x "$tmp" || { rm -f "$tmp"; die "cannot make $tmp executable"; }
    mv -f "$tmp" "$hook" || { rm -f "$tmp"; die "cannot install $hook"; }
}

main() {
    local repo='' uninstall=0 arg
    for arg in "$@"; do
        case "$arg" in
            --uninstall) uninstall=1 ;;
            -h|--help)
                sed -n '3,22p' "$0" | sed 's/^# \{0,1\}//'
                return 0
                ;;
            -*) die "unknown option: $arg" ;;
            *)
                [[ -n "$repo" ]] && die "too many arguments: $arg"
                repo="$arg"
                ;;
        esac
    done
    [[ -n "$repo" ]] || repo="$PWD"

    git -C "$repo" rev-parse --git-dir >/dev/null 2>&1 || die "not a git repository: $repo"

    # The body check and mkdir below are install-only. Uninstalling has to work
    # precisely when the body is gone -- that is when it is needed most.
    if [[ "$uninstall" -eq 0 && ! -x "$BODY_PATH" ]]; then
        warn "$BODY_PATH is missing or not executable."
        warn "  It is deployed by home-manager. Run 'make switch/home' in your dotfiles first,"
        warn "  then re-run this command."
        return 1
    fi

    local hooks_dir
    hooks_dir=$(resolve_hooks_dir "$repo") || die "cannot resolve the hooks directory for $repo"
    [[ -n "$hooks_dir" ]] || die "cannot resolve the hooks directory for $repo"

    local hook="$hooks_dir/post-checkout"

    # -L before -e: a symlink to a missing target is still a symlink, and
    # writing through one would clobber whatever it points at.
    if [[ -L "$hook" ]]; then
        warn "$hook is a symlink to $(readlink "$hook")."
        warn "  Refusing to write through it. Resolve it by hand and re-run."
        return 1
    fi

    local kind version
    if [[ -e "$hook" ]]; then
        read -r kind version <<<"$(classify_hook "$hook")"
    else
        kind=absent
        version=''
    fi

    if [[ "$uninstall" -eq 1 ]]; then
        case "$kind" in
            own)
                rm -f "$hook" || die "cannot remove $hook"
                echo "worktree-setup-install: removed $hook"
                ;;
            appended)
                warn "$hook was not written by this tool; it only carries our marker."
                warn "  Not removing it. Delete the block starting at the marker line by hand:"
                warn "    $(grep -n "^${MARKER_PREFIX} v[0-9]\+\$" "$hook" | head -n 1)"
                ;;
            foreign)
                warn "$hook was not installed by this tool. Leaving it alone."
                ;;
            absent)
                echo "worktree-setup-install: nothing to remove ($hook does not exist)"
                ;;
        esac
        # Uninstall ends here. Falling through would re-install what we just
        # removed, and would replace a foreign hook wholesale.
        return 0
    fi

    warn_hook_managers "$repo"

    case "$kind" in
        own)
            if [[ "$version" == "$CURRENT_VERSION" ]]; then
                echo "worktree-setup-install: already installed at $hook"
                return 0
            fi
            write_dispatcher "$hook"
            echo "worktree-setup-install: updated $hook (v$version -> v$CURRENT_VERSION)"
            return 0
            ;;
        appended)
            echo "worktree-setup-install: $hook already runs setup-worktree.sh (appended form); leaving it alone"
            return 0
            ;;
        foreign)
            warn "$hook already exists and was not written by this tool."
            warn "  Refusing to overwrite it."
            explain_manual_wiring "$hook"
            return 0
            ;;
    esac

    mkdir -p "$hooks_dir" || die "cannot create $hooks_dir"
    write_dispatcher "$hook"
    echo "worktree-setup-install: installed $hook"
}

main "$@"
