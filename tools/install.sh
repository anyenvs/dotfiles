#!/usr/bin/env $SHELL

[ -n "${DEBUG}" ] && { export PS4='+ [${BASH_SOURCE##*/}:${LINENO}] ' ; set -x; }
#set -e
ls *.env &>/dev/null && . *.env || true
DOTFILES_PATH="${DOTFILES_PATH:-$(readlink -f ..)}"
test -z "${_HELPERS}" && _HELPERS=($(find "${DOTFILES_PATH}"/ -name _helpers.bash 2>/dev/null |sort));. $_HELPERS
test -n "$_HELPERS" || _error "===> ❌ _HELPERS env var is missing in $0"

eval which {git,gpg,bsdtar,wget,xz,zip,unzip,7zip} || _install wget git gnupg2 libarchive-tools zip unzip xz-utils p7zip-full;

_htop-configs(){
    ###############
    ## htop
    ###############
    _log "===> 🚀 htop config"
    local _HTOP_PATH=.config/htop
    test -f ${HOME}/${_HTOP_PATH}/htoprc -a -L ${HOME}/${_HTOP_PATH} && {
        _log "===> File: $(ls -l ${HOME}/${_HTOP_PATH})\n ===> Remove before symlinking" ;
        return ;
    }   || ln -svnf "${DOTFILES_PATH}"/tools/htop ${HOME}/${_HTOP_PATH} ;
}

_htop-install() {
    _log "===> 🚀 htop install \n ===> 🚀 brew install htop" ;
    brew install htop ;
}

# ######
# Main
# ######
__main__() {
    _htop-install || exit 1 ;
    _htop-configs  || true ;
}
test -n "$1" && $1 || __main__
set +x
