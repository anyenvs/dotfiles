#!/usr/bin/env $SHELL

#set -e
ls *.env 2>/dev/null && . *.env || true
#DOTFILES_PATH="${DOTFILES_PATH:-..}"
DOTFILES_PATH="${DOTFILES_PATH:-$(realpath ..)}"
test -z "${A_COMMON_FUNCTIONS}" && A_COMMON_FUNCTIONS=($(find "${DOTFILES_PATH}"/ -name a_common_functions.bash 2>/dev/null));. $A_COMMON_FUNCTIONS
test -n "$A_COMMON_FUNCTIONS" || _error "===> ❌ A_COMMON_FUNCTIONS env var is missing in $0"

eval which {git,gpg,bsdtar,xz,zip,unzip,7zip} || _install wget git gnupg2 libarchive-tools xz zip unzip 7zip;

##
test -f "${HOME}/Library/Application Support/Code/User/settings.json" && {
        _log "===> File: $(ls -l "${HOME}/Library/Application Support/Code/User/settings.json")\n ===> Remove file before symlinking" ;
        return ;
    } || ln -svnf "${DOTFILES_PATH}"/vscode/settings.json "${HOME}/Library/Application Support/Code/User/settings.json"

__main__() { _log '' ; }
# ######
# Main
# ######
test -n "$1" && $1 || __main__
set +x
