# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
./bootstrap.sh                                    # fresh install: installs ansible + runs playbook
ansible-playbook site.yml --ask-become-pass       # apply all roles
ansible-playbook site.yml --tags gnome            # apply a single role
ansible-playbook site.yml --check --diff          # dry-run
```

The playbook always runs against `localhost` via local connection (no SSH involved).

## Architecture

Each role is self-contained under `roles/<name>/tasks/main.yml`. Roles run in order: `base → shell → dev → apps → gnome`.

**Configuration lives in `group_vars/all.yml`** — this is where to add apt packages, VSCode extensions, and Brave extension IDs. Tasks read from these lists; avoid hardcoding values in task files.

**GPG key pattern:** All third-party apt repositories follow the same pattern — a single `shell` task with `creates:` pointing to the final keyring file in `/etc/apt/keyrings/`. This skips the network entirely on subsequent runs. Do not use `get_url` + separate dearmor tasks.

**GNOME settings** (`roles/gnome`) use `gsettings` and `xdg-settings` grouped in a `block:` that sets `DBUS_SESSION_BUS_ADDRESS`. All tasks use `changed_when: false` since gsettings set is idempotent by nature.

**Brave extensions** are force-installed via managed policy at `/etc/brave/policies/managed/extensions.json`, templated from `roles/apps/templates/brave_extensions.json.j2`. Add Chrome Web Store extension IDs to `brave_extension_ids` in `group_vars/all.yml`.

**VSCode extensions** are installed via `code --install-extension`, but only after checking `code --list-extensions` first — so only missing extensions trigger a change.

**Known quirk:** The VSCode `.deb` post-install script creates `/etc/apt/sources.list.d/vscode.sources` pointing to a different keyring path, conflicting with the Ansible-managed `vscode.list`. The `apps` role removes this file after installing VSCode.
