#!/usr/bin/env bash

#set -e
ls *.env &>/dev/null && . *.env || true
DOTFILES_PATH="${DOTFILES_PATH:-$(readlink -f ..)}"
test -z "${_HELPERS}" && _HELPERS=($(find "${DOTFILES_PATH}"/ -name _helpers.bash 2>/dev/null |sort));. $_HELPERS
test -n "$_HELPERS" || _error "===> ❌ _HELPERS env var is missing in $0"

eval which {git,} || _install git ;

_fzf-istall() {
    # ######
    # FZF
    # ######
    test -d ${HOME}/.fzf && {
      _log "===> FZF exist: $(ls -l ${HOME}/.fzf)\n ===> Remove it before installing" ;
      return ;
    } || {
      _log "===> Installing FZF" ;
      git clone --depth 1 https://github.com/junegunn/fzf.git ${HOME}/.fzf ;
      ${HOME}/.fzf/install --completion --no-update-rc --no-key-bindings
    }
}


__main__() {
    _fzf-istall || return 1    
}

# ######
# Main
# ######
test -n "$1" && $1 || __main__
set +x
