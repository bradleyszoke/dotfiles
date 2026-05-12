#!/bin/sh
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$HOME/.config"

ln -sf "$DOTFILES/nvim"      "$HOME/.config/nvim"
ln -sf "$DOTFILES/.zshrc"    "$HOME/.zshrc"
ln -sf "$DOTFILES/.tmux.conf" "$HOME/.tmux.conf"

echo "Dotfiles installed."
