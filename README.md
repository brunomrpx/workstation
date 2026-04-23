# workstation

Ansible playbook para provisionar uma workstation de desenvolvimento a partir de uma instalação limpa.

## Status

- **Suportado hoje:** Ubuntu / Debian-based
- **Planejado:** macOS, Fedora (quando houver demanda real)

## O que faz

- **base** — pacotes CLI essenciais via apt (git, tmux, ripgrep, fzf, jq, etc.)
- **shell** — zsh como default, starship (prompt), `.zshrc` e `.gitconfig`
- **dev** — mise (runtime version manager) + Docker via repo oficial
- **apps** — VSCode e Chrome via repo/.deb oficial (sem snap/flatpak)

## Uso em máquina nova

```bash
sudo apt install -y git
git clone <repo-url> ~/Projects/workstation
cd ~/Projects/workstation
./bootstrap.sh
```

## Uso no dia-a-dia

```bash
ansible-playbook site.yml --check --diff         # preview do que mudaria
ansible-playbook site.yml --ask-become-pass      # aplica
ansible-playbook site.yml --tags apps            # roda só uma role
```

## Estendendo

Cada role é independente. Para adicionar algo novo: ou estenda uma role existente, ou crie uma nova e registre em `site.yml`.
