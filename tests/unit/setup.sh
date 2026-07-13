#!/usr/bin/bash
set -e

echo "Copy the providers.tf file to the root module directory"
cp -f ./tests/unit/setup/providers.tf ./providers.tf

# Pre-download Terraform modules with retries to work around concurrent
# git clone races in Terraform's module installer when multiple modules
# share the same source git repository (e.g. the three peering submodule
# calls in modules/virtual-network/main.tf all clone
# Azure/terraform-azurerm-avm-res-network-virtualnetwork). The race can
# manifest as `BUG: refs/files-backend.c:3023` or
# `error: could not lock config file ... .git/config` during `terraform init`.
if command -v terraform >/dev/null 2>&1; then
  attempt=0
  max_attempts=5
  until terraform get -update >/dev/null 2>&1; do
    attempt=$((attempt + 1))
    if [ "$attempt" -ge "$max_attempts" ]; then
      echo "ERROR: 'terraform get' failed after ${max_attempts} attempts" >&2
      exit 1
    fi
    echo "terraform get attempt ${attempt} failed, retrying..." >&2
    rm -rf .terraform/modules
    sleep $((attempt * 2))
  done
fi
