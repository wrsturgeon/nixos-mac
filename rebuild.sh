#!/bin/sh

set -eux

nix-env --delete-generations 14d

git add -A
git commit -m 'Automatic update with `rebuild.sh`'

nix-channel --add https://nixos.org/channels/nixos-unstable nixos
nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs

nixos-rebuild switch --upgrade

nix-store --gc

echo 'Done'
