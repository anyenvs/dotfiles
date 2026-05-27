#!/usr/bin/env bash

[ -n "${DEBUG}" ] && { export PS4='+ [${BASH_SOURCE##*/}:${LINENO}] ' ; set -x; }

ls *.env &>/dev/null && . *.env || true
DOTFILES_PATH="${DOTFILES_PATH:-$(readlink -f ..)}"
test -z "${_HELPERS}" && _HELPERS=($(find "${DOTFILES_PATH}"/ -name _helpers.bash 2>/dev/null |sort));. $_HELPERS
test -n "$_HELPERS" || _error "===> ❌ _HELPERS env var is missing in $0"

eval which {git,} || _install git ;

_FZF_CONFIG_DIR="${HOME}/.fzf"

_fzf-install() {
    # ######
    # FZF
    # ######
    test -d $_FZF_CONFIG_DIR && {
      _log "===> FZF exist: $( ls -l $_FZF_CONFIG_DIR )\n ===> Remove it before installing" ;
      return ;
    } || {
      _log "===> Installing FZF" ;
      git clone --depth 1 https://github.com/junegunn/fzf.git $_FZF_CONFIG_DIR ;
      $_FZF_CONFIG_DIR/install --completion --no-update-rc --no-key-bindings
    }
}


__main__() {
    _fzf-install || return 1
}

# ######
# Main
# ######
test -n "$1" && $1 || __main__
set +x
