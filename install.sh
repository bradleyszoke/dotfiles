#!/bin/sh
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
OS="$(uname -s)"

# Use sudo for apt-get unless already root
APT="sudo apt-get"
[ "$(id -u)" = "0" ] && APT="apt-get"

is_installed() { command -v "$1" >/dev/null 2>&1; }

# ── Oh My Zsh ─────────────────────────────────────────────────────────────────
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# ── Starship ──────────────────────────────────────────────────────────────────
if ! is_installed starship; then
  curl -sS https://starship.rs/install.sh | sh -s -- --yes
fi

# ── Zoxide ────────────────────────────────────────────────────────────────────
if ! is_installed zoxide; then
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

# ── FZF ───────────────────────────────────────────────────────────────────────
if [ ! -d "$HOME/.fzf" ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
  "$HOME/.fzf/install" --all --no-bash --no-fish
fi

# ── Neovim ────────────────────────────────────────────────────────────────────
if ! is_installed nvim; then
  case "$OS" in
    Linux)
      mkdir -p "$HOME/.local"
      curl -sSLo /tmp/nvim.tar.gz https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
      tar -xzf /tmp/nvim.tar.gz -C "$HOME/.local" --strip-components=1
      rm /tmp/nvim.tar.gz
      ;;
    Darwin)
      echo "Install Neovim on macOS: brew install neovim"
      ;;
  esac
fi

# ── ripgrep + fd (required by Telescope) ─────────────────────────────────────
if ! is_installed rg && is_installed apt-get; then
  $APT install -y ripgrep
fi

if ! is_installed fd && ! is_installed fdfind && is_installed apt-get; then
  $APT install -y fd-find
fi

# ── Yazi ──────────────────────────────────────────────────────────────────────
if ! is_installed yazi; then
  case "$OS" in
    Linux)
      YAZI_TAG="$(curl -sSf https://api.github.com/repos/sxyazi/yazi/releases/latest | grep '"tag_name"' | cut -d'"' -f4)"
      curl -sSLo /tmp/yazi.zip "https://github.com/sxyazi/yazi/releases/download/${YAZI_TAG}/yazi-x86_64-unknown-linux-gnu.zip"
      unzip -o /tmp/yazi.zip -d /tmp/yazi-extract
      mv /tmp/yazi-extract/yazi-x86_64-unknown-linux-gnu/yazi "$HOME/.local/bin/yazi"
      rm -rf /tmp/yazi.zip /tmp/yazi-extract
      ;;
    Darwin)
      echo "Install Yazi on macOS: brew install yazi"
      ;;
  esac
fi

# ── Symlinks ──────────────────────────────────────────────────────────────────
mkdir -p "$HOME/.config" "$HOME/.local/bin"

ln -sf "$DOTFILES/nvim"       "$HOME/.config/nvim"
ln -sf "$DOTFILES/.zshrc"     "$HOME/.zshrc"
ln -sf "$DOTFILES/.tmux.conf" "$HOME/.tmux.conf"

echo "Dotfiles installed."
