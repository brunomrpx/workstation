# workstation

Ansible playbook to provision my dev workstation from a clean install.

Target: Ubuntu / Debian-based.

## Roles

- **base** — essential CLI packages via apt
- **shell** — zsh + starship, `.zshrc`, `.gitconfig`
- **dev** — mise + Docker
- **apps** — VSCode, Brave

## Bootstrap

```bash
sudo apt install -y git
git clone <repo-url> ~/Projects/workstation
cd ~/Projects/workstation
./bootstrap.sh
```

## Day-to-day

```bash
ansible-playbook site.yml --check --diff      # dry-run
ansible-playbook site.yml --ask-become-pass   # apply
ansible-playbook site.yml --tags apps         # single role
```
