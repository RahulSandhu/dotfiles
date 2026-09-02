# AGENTS.md

Compact repo guide for OpenCode sessions.

## What this repo is

Personal Arch Linux dotfiles managed with **GNU Stow**. The repo root holds
top-level home files (`.zshrc`, `.bashrc`, `.p10k.zsh`, `.zprofile`, etc.) and
the tree under `.config/` is the actual configuration. `docs/` holds prose
install/setup guides and the exported package manifests consumed by
`docs/setup.md`. There is no `.gitconfig` tracked here; global git config lives
outside the repo.

## Deploying changes

- `make install` runs `stow --adopt -R -t $(HOME) -d $(STOW_DIR) $(STOW_PKG)`
(STOW_DIR is the repo's parent, STOW_PKG the repo name, so it must be run from
the repo dir). This symlinks (or replaces) dotfiles in `$HOME`.
- **Do not copy files manually**; the intended workflow is Stow.
- **`--adopt` is two-way**: if a local `$HOME` file differs from the repo copy,
Stow copies it back over the tracked file. After `make install`, check `git
status` and revert or keep the adopted changes.
- Files Stow ignores live in `.stow-local-ignore` (Perl regexes; currently
`AGENTS.md`, `Makefile`, `README.md`, `LICENSE`, `.gitignore`,
`.stow-local-ignore`, `docs`, `images`, `.git`). They stay in the repo but are
not symlinked into `$HOME`.
- **`.gitignore` ignores only `AGENTS.md`** — so after editing it you must `git
add -f AGENTS.md` (or drop that rule) to commit changes here.

## Package manifests

- `docs/native-pkgs.txt` and `docs/foreign-pkgs.txt` list installed Arch
packages; `make sync-packages` regenerates them via `pacman -Qenq` / `pacman
-Qmeq`. Run it only when explicitly refreshing them.
- `docs/setup.md` step 14 consumes them (`pacman -S --needed - < ...`) but
references the bare filenames without the `docs/` prefix; from the repo root
the paths need `docs/` added. Known mismatch, worth fixing if editing
`setup.md`.

## How to work on it safely

- **No build, test suite, lint step, or CI.** Review changes by reading the
affected file. Verify syntax where possible:
  - `sway -c .config/sway/config -C`
  - `zsh -n .zshrc` / `bash -n <script>`
- Many paths under `.config/` are loaded by live tools (Sway, Waybar, Zsh,
Kitty, Neovim); a typo in `.config/sway/config` or `.zshrc` breaks the next
reload or login.
- `.zshrc` is the main shell entry point; `.bashrc` is intentionally minimal.

## Key file boundaries

| Area                           | Files / directories                                      | Notes                                                                                                                        |
| ------------------------------ | -------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| Shell                          | `.zshrc`, `.zprofile`, `.bashrc`, `.bash_profile`        | `.zprofile` execs Sway on `tty1` login.                                                                                      |
| Window manager                 | `.config/sway/`, `.config/sway/scripts/`                 | Reload via `Super+Shift+r`; starts Waybar/Swaync/Swayosd; `autotiling.py` + `workspaces.py` run here.                        |
| Top bar / notifications        | `.config/waybar/`, `.config/swaync/`, `.config/swayosd/` | Status scripts (`battery*.sh`, `wifi*.sh`, `bluetooth*.sh`, etc.) live in `.config/swaync/scripts/`.                          |
| Editor                         | `.config/nvim/`                                          | Lazy.nvim; `init.lua` loads `core/` + `plugins/`.                                                                             |
| Terminal/launcher              | `.config/kitty/`, `.config/wofi/`                        | Wofi menus/capture scripts under `.config/wofi/scripts/`.                                                                    |
| Emoji picker                   | `.config/wofi/scripts/emoji-picker.sh`                   | `Super+.` in Sway; singleton via `/tmp/wofi-emoji.pid`.                                                                      |
| AI agent multiplexer           | `.config/herdr/`                                         | Terminal multiplexer for AI coding agents.                                                                                   |
| Music player                   | `.config/kew/`                                           | `kewrc`.                                                                                                                     |
| Email                          | `.config/betterbird/`                                    | `toggle-betterbird.sh` bound in Sway.                                                                                        |
| Clipboard manager              | `.config/clipse/`                                        | Toggle script in `.config/clipse/scripts/`.                                                                                  |
| Calendar/notes                 | `.config/galendae/`, `.config/notse/`                    |                                                                                                                              |
| Trash wrapper                  | `.config/gtrash/`                                        | `rm` aliases in `.zshrc` route to `gtrash`.                                                                                  |
| Sync/cloud                     | `.config/rclone/`                                        | `scripts/sync-drive.sh` drives `sync-drive.service`.                                                                         |
| LocalSend (file transfer)      | `.config/lsq/scripts/`                                   | `localsend-autostart.sh` runs headless `lsq receive`; `lsend`/`lreceive`/`lscan` aliases in `.zshrc`.                        |
| Systemd user units             | `.config/systemd/`                                       | `sync-drive`, `pia-autoconnect`, `deepseek-balance`, `gtrash-prune`, `timeshift-weekly`. |
| Snapshot scheduling            | `.config/timeshift/`                                     | Weekly snapshot script + service/timer.                                                                                      |
| PDF reader                     | `.config/zathura/`                                       |                                                                                                                              |
| XDG dirs                       | `.config/user-dirs.dirs`, `.config/user-dirs.locale`     |                                                                                                                              |
| Package lists                  | `docs/native-pkgs.txt`, `docs/foreign-pkgs.txt`          | Generated by `make sync-packages`.                                                                                           |
| Docs                           | `docs/install.md`, `docs/setup.md`                       | Human-only Arch install/setup prose.                                                                                         |

## Existing OpenCode config

`.config/opencode/opencode.json` is the source of truth for OpenCode runtime
settings and references this file via `instructions`. It pins models
(`opencode-go/deepseek-v4-pro` plan/default, `opencode-go/deepseek-v4-flash`
build) and enables the `superpowers` plugin plus MCP servers (`brave-search`,
`consensus`, `github`, `pdf-extraction`, `sqlite`). Do not duplicate those
defaults here.

## Gotchas worth remembering

- **No package manager metadata files** (no `package.json`, `Cargo.toml`, etc.)
at root; tooling versions come from the package lists in `docs/`.
- `lsq` (Rust CLI for LocalSend) is a prebuilt binary at `~/.local/bin/lsq`,
not in the package lists. The `lsend`/`lreceive`/`lscan` aliases use port
`53318` so they don't collide with the always-on receiver service, which
listens on `53317`.
- The Wayland env vars (`GDK_BACKEND`, `QT_QPA_PLATFORM`, etc.) are set in
`.zshrc` because Sway launches from `.zprofile`.
- `emoji-picker.sh` fetches the Unicode emoji list from unicode.org on first
run and caches it at `~/.cache/wofi-emoji/picker.txt` for 30 days; a fresh
cache requires internet. It is emoji-only — there is no curated inline icon
list anymore.
- `.config/systemd/user/sync-drive.service` hardcodes the repo path
(`%h/desktop/projects/dotfiles/...`); moving the repo breaks the rclone sync
timer.
- Commit messages use conventional-commit prefixes (`feat:`, `fix:`, `chore:`,
`docs:`) — match that style when committing.

## If you need to make changes

1. Prefer small, focused edits to the exact file that belongs to a tool.
2. Verify syntax: `sway -c .config/sway/config -C`, `zsh -n .zshrc`, `bash -n
<script>`.
3. There is no test command; read the changed file to confirm intent.
