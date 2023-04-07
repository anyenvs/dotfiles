#!/usr/bin/env bash

#set -e
ls *.env &>/dev/null && . *.env || true
DOTFILES_PATH="${DOTFILES_PATH:-$(readlink -f ..)}"
test -z "${_HELPERS}" && _HELPERS=($(find "${DOTFILES_PATH}"/ -name _helpers.bash 2>/dev/null |sort));. $_HELPERS
test -n "$_HELPERS" || _error "===> ❌ _HELPERS env var is missing in $0"

eval which {git,gpg,bsdtar,xz,zip,unzip,7z} || _install wget git gnupg2 libarchive-tools zip unzip xz-utils p7zip-full;

_vimrc-config() {
    # ######
    # Vimrc
    # ######
    test -f ${HOME}/.vimrc && {
      _log "===> File exist: $(ls -l ${HOME}/.vimrc)\n ===> Remove file before symlinking" ;
      return ;
    } || ln -svnf "${DOTFILES_PATH}"/vimrc/.vimrc ${HOME}/.vimrc
}

__main__() {
    _vimrc-config || true
}
# ######
# Main
# ######
test -n "$1" && $1 || __main__
set +x
