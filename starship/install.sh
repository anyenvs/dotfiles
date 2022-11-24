#!/usr/bin/env $SHELL

#set -e
ls *.env &>/dev/null && . *.env || true
DOTFILES_PATH="${DOTFILES_PATH:-$(realpath ..)}"
test -z "${A_COMMON_FUNCTIONS}" && A_COMMON_FUNCTIONS=($(find "${DOTFILES_PATH}"/ -name a_common_functions.bash 2>/dev/null));. $A_COMMON_FUNCTIONS
test -n "$A_COMMON_FUNCTIONS" || _error "===> ❌ A_COMMON_FUNCTIONS env var is missing in $0"

eval which {git,gpg,bsdtar,wget,xz,zip,unzip,7zip} || _install wget git gnupg2 libarchive-tools zip unzip xz-utils p7zip-full;

_starship-configs(){
    ###############
    ## Starship
    ###############
    _log "===> 🚀 Starship config"
    test -f ${HOME}/.config/starship.toml -a -L ${HOME}/.config/starship.toml && {
        _log "===> File: $(ls -l ${HOME}/.config/starship.toml)\n ===> Remove file before symlinking" ;
        return ;
    }   || ln -svnf "${DOTFILES_PATH}"/starship/starship.toml ${HOME}/.config/starship.toml ;
}

_startship-install() {
    _log "===> 🚀 Starship install"
    #curl -sSL https://starship.rs/install.sh | sh -s -- --bin-dir /opt/starship/bin
    wget -qO- https://starship.rs/install.sh | sh -s -- --yes
    echo 'eval "$(starship init $SHELL)"' > ~/.starshiprc
    grep -q starshiprc ~/.bashrc ||echo 'test -f ~/.starshiprc && . ~/.starshiprc' >> ~/.bashrc
    test -f ~/.starshiprc && . ~/.starshiprc
}

# ######
# Main
# ######
__main__() {
    _startship-install || exit 1 ;
    _starship-configs  || true ;
}
test -n "$1" && $1 || __main__
set +x
