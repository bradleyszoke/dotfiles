export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME=""  # using starship

plugins=(git)

source "$ZSH/oh-my-zsh.sh"

fpath+=~/.zfunc
autoload -Uz compinit
compinit

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

eval "$(zoxide init zsh)"

export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$HOME/go/bin:$PATH"

function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  command yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}

[ -f ~/.zshrc.local ] && source ~/.zshrc.local

eval "$(starship init zsh)"
