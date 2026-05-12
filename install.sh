#!/bin/sh
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
OS="$(uname -s)"

mkdir -p "$HOME/.local/bin" "$HOME/.config"

is_installed() { command -v "$1" >/dev/null 2>&1; }
is_musl()      { ldd /bin/sh 2>&1 | grep -q musl; }

# Use sudo for package managers unless already root
SUDO=""
[ "$(id -u)" != "0" ] && is_installed sudo && SUDO="sudo"

# ── Oh My Zsh ─────────────────────────────────────────────────────────────────
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# ── Starship ──────────────────────────────────────────────────────────────────
if ! is_installed starship; then
  if is_installed apt-get; then $SUDO apt-get install -y starship
  elif is_installed apk;   then $SUDO apk add --no-cache starship
  else curl -sS https://starship.rs/install.sh | sh -s -- --yes --bin-dir "$HOME/.local/bin"
  fi
fi

# ── Zoxide ────────────────────────────────────────────────────────────────────
if ! is_installed zoxide; then
  if is_installed apt-get; then $SUDO apt-get install -y zoxide
  elif is_installed apk;   then $SUDO apk add --no-cache zoxide
  else curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
  fi
fi

# ── FZF ───────────────────────────────────────────────────────────────────────
if [ ! -d "$HOME/.fzf" ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
  "$HOME/.fzf/install" --all --no-bash --no-fish
fi

# ── Neovim ────────────────────────────────────────────────────────────────────
if ! is_installed nvim; then
  if is_installed apt-get;   then $SUDO apt-get install -y neovim
  elif is_installed apk;     then $SUDO apk add --no-cache neovim
  else echo "Install Neovim on macOS: brew install neovim"
  fi
fi

# ── ripgrep + fd (required by Telescope) ─────────────────────────────────────
if ! is_installed rg; then
  if is_installed apt-get; then $SUDO apt-get install -y ripgrep
  elif is_installed apk;   then $SUDO apk add --no-cache ripgrep
  fi
fi

if ! is_installed fd && ! is_installed fdfind; then
  if is_installed apt-get; then $SUDO apt-get install -y fd-find
  elif is_installed apk;   then $SUDO apk add --no-cache fd
  fi
fi

# ── Yazi ──────────────────────────────────────────────────────────────────────
if ! is_installed yazi; then
  case "$OS" in
    Linux)
      if is_musl; then YAZI_TARGET="x86_64-unknown-linux-musl"
      else             YAZI_TARGET="x86_64-unknown-linux-gnu"
      fi
      YAZI_TAG="$(curl -sSf https://api.github.com/repos/sxyazi/yazi/releases/latest | grep '"tag_name"' | cut -d'"' -f4)"
      [ -z "$YAZI_TAG" ] && echo "Failed to fetch Yazi version" && exit 1
      curl -sSfLo /tmp/yazi.zip "https://github.com/sxyazi/yazi/releases/download/${YAZI_TAG}/yazi-${YAZI_TARGET}.zip"
      unzip -o /tmp/yazi.zip -d /tmp/yazi-extract
      mv "/tmp/yazi-extract/yazi-${YAZI_TARGET}/yazi" "$HOME/.local/bin/yazi"
      rm -rf /tmp/yazi.zip /tmp/yazi-extract
      ;;
    Darwin)
      echo "Install Yazi on macOS: brew install yazi"
      ;;
  esac
fi

# ── Symlinks ──────────────────────────────────────────────────────────────────
ln -sf "$DOTFILES/nvim"       "$HOME/.config/nvim"
ln -sf "$DOTFILES/.zshrc"     "$HOME/.zshrc"
ln -sf "$DOTFILES/.tmux.conf" "$HOME/.tmux.conf"

echo "Dotfiles installed."
