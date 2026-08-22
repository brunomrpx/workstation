# Arch + Hyprland handoff

Directional doc for the Arch track of this repo. This is the starting point
for building the config the right way from the first commit — not a writeup
of the research that led here.

## Overview

Build a from-scratch Arch + Hyprland setup as a leaner, hand-picked
alternative to Omarchy: same tiling-WM daily-driver experience, but
assembled piece by piece instead of inheriting an opinionated shell.

Setup lives alongside Omarchy and Ubuntu on the same machine (triple-boot).
Omarchy remains the daily driver until this setup meets the requirements
below; only then does a migration make sense.

Editor, shell, dev toolchain (mise, docker, etc.) are explicitly out of
scope for this phase. Add them incrementally via Ansible as needed, same
pattern as the `dev`/`apps` roles on the Ubuntu side.

## Requirements

A tiling Hyprland setup, minimal by design (hand-picked pieces, not an
all-in-one opinionated shell), where the following are stable out of the box:

- Lock screen, idle handling
- Bluetooth, Wi-Fi/network, VPN
- Notifications, volume (with an OSD popup), display/resolution incl. dock
  hotplug
- Keyboard (ABNT2 layout, including this model's scancode quirk below)
- Screen sharing and reliable audio/video in meeting apps
- Fingerprint auth (login + lock screen)
- `SUPER + Space` → one launcher for apps, settings toggles, etc.
- Ability to "install" a web app so it opens as its own native-feeling window
- Terminal/keybinding-first UI throughout — prefer TUI tools over GUI where
  an equivalent exists

VPN and meeting-app reliability (camera, mic, screen share) are treated as
hard requirements, not nice-to-haves — this setup isn't considered
daily-driver-ready until both are verified end-to-end.

## Architecture decision: classic stack, not a Quickshell shell

Considered DMS (Dank Material Shell) and Noctalia — both Quickshell-based,
both good, both closer in spirit to "Omarchy but reskinned" (opinionated,
batteries-included, heavier). Went instead with individually assembled
pieces, because that's what "minimal and hand-picked" means here, and each
piece stays independently swappable later.

## Tool shortlist

Starting point — confirm exact package vs. AUR status while building the
pacman role.

| Area | Tool |
|---|---|
| Compositor | `hyprland` |
| Session mgmt | `uwsm` (isolates each launched app in its own systemd scope) |
| Polkit agent | `hyprpolkitagent` |
| Login (TUI) | `greetd` + `tuigreet` (or `ly`) |
| Lock / idle | `hyprlock` / `hypridle` |
| Bar | `waybar` |
| Notifications | `mako` |
| Launcher (`SUPER+Space`) | `walker` |
| Power menu | `wlogout` |
| Volume/brightness OSD | `swayosd` |
| Network | `networkmanager` + `impala` (TUI) |
| Bluetooth | `bluez` + `bluetui` (TUI) |
| Audio stack | `pipewire` + `wireplumber` + `pulsemixer` (TUI mixer) |
| Mic noise suppression | `easyeffects` + RNNoise plugin |
| Fingerprint | `fprintd` + `libfprint`, wired through PAM (`pam_fprintd.so`) — must work for both `tuigreet`/`ly` and `hyprlock` |
| Screen sharing | `xdg-desktop-portal-hyprland` + `xdg-desktop-portal` + `pipewire` |
| Monitor/dock profiles | `kanshi` |
| Clipboard | `wl-clipboard` + `cliphist` |
| X11 compat safety net | `xorg-xwayland` |
| Web apps as native windows | `ice-ssb` or `webapp-make` (AUR) |
| Screenshot/recording | `grim` + `slurp`, `wf-recorder` |
| Fonts | `noto-fonts` + `noto-fonts-emoji` |
| VPN | Protocol TBD. WireGuard/OpenVPN are easy (`wireguard-tools` / `networkmanager-openvpn`). Corporate clients (Cisco AnyConnect, GlobalProtect, FortiClient) are the risky ones — no solid official Linux client, need `openconnect` + AUR wrappers. Identify the actual protocol needed and test it explicitly before relying on this as a daily driver. |

An AUR helper (`yay` or `paru`) will be needed for at least `walker` and
`ice-ssb`/`webapp-make`, possibly `bluetui` too — bootstrap it early and
confirm which of the above are AUR vs. official `extra` while building the
role.

## Known device-specific requirement

This ThinkPad T14 Gen 6 (BR SKU, DMI `pn21QD002HBO`) has a hardware quirk:
the physical "/" "?" key near the arrow cluster sends the standard AT
scancode for Right Ctrl (`0x9d`) instead of a slash scancode — the same known
issue as the T14 Gen 1 AMD BR keyboard upstream. Fixed on Omarchy via:

- `kb_layout = "br"`, `kb_model = "abnt2"` in the Hyprland input config
- a udev hwdb rule remapping scancode `0x9d` → `ro`
  (`KEYBOARD_KEY_9d=ro`), scoped to this DMI product

Port this as an actual Ansible task/template (hwdb file + `systemd-hwdb
update` + `udevadm trigger`), not a manual one-off, so it survives a
reinstall.

Also carry over the touchpad preference: `natural_scroll = true`.

## Working method

- Ansible is the source of truth from day one — this is not "configure
  manually now, write the playbook later." Any change applied interactively
  (including anything done live via Claude Code on the box) gets encoded
  into a role in the same session.
- Mirror the Ubuntu playbook's conventions (see root `CLAUDE.md`): one role
  per concern, package lists in `group_vars`, idempotent tasks, no
  hardcoded values in task files. Swap `apt` for `community.general.pacman`,
  and decide the AUR-install pattern (helper bootstrap role) up front.
- Dotfiles (Hyprland/waybar/mako/etc. configs) live in this repo and get
  deployed via `template`/`copy`/symlink tasks — not hand-edited on the box
  and forgotten.
- Validate incrementally: WM + basics stable first, then VPN + meeting-app
  testing (camera, mic, screen share) as its own explicit checkpoint before
  ever considering this a daily-driver candidate.
