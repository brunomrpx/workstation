#!/usr/bin/env bash
set -euo pipefail

if ! command -v apt-get >/dev/null 2>&1; then
  echo "Unsupported OS (apt not found). Only Debian/Ubuntu supported today." >&2
  exit 1
fi

sudo apt update
sudo apt install -y ansible

ansible-playbook site.yml --ask-become-pass
