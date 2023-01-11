#!/usr/bin/env bash

#set -e
ls *.env &>/dev/null && . *.env || true
#DOTFILES_PATH=${DOTFILES_PATH:-$(dirname $(readlink -f ${BASH_SOURCE:-$0}))}
DOTFILES_PATH="${DOTFILES_PATH:-$(readlink -f ..)}"
test -z "${A_COMMON_FUNCTIONS}" && A_COMMON_FUNCTIONS=($(find "${DOTFILES_PATH}"/ -name a_common_functions.bash 2>/dev/null));. $A_COMMON_FUNCTIONS
test -n "$A_COMMON_FUNCTIONS" || _error "===> ❌ A_COMMON_FUNCTIONS env var is missing in $0"

_warp_install() {
    echo -e "
    ## https://github.com/warpdotdev
    ## https://www.warp.dev/blog/how-to-open-warp-vscode
    ## git clone https://github.com/warpdotdev/themes.git warp-themes
    "
    eval which brew && brew install --cask warp || _error "===> ❌ BREW not installed..."
}
_warp_themes() {
    test -f "${HOME}/.warp" && {
        _log "===> File: $(ls -l ${HOME}/.warp)\n ===> Remove file before symlinking" ;
        return ;
    } || ( cd $HOME ; ln -svnf "${DOTFILES_PATH}"/warp .warp )
}

__main__() {
    _log 'Warp Terminal' ;
    _warp_install ;
    _warp_themes ;
}
# ######
# Main
# ######
test -n "$1" && $1 || __main__
set +x
