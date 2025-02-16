#!/usr/bin/env $SHELL

[ -n "${DEBUG}" ] && { export PS4='+ [${BASH_SOURCE##*/}:${LINENO}] ' ; set -x; }
#set -e
ls *.env &>/dev/null && . *.env || true
DOTFILES_PATH="${DOTFILES_PATH:-$(readlink -f ..)}"
test -z "${_HELPERS}" && _HELPERS=($(find "${DOTFILES_PATH}"/ -name _helpers.bash 2>/dev/null |sort));. $_HELPERS
test -n "$_HELPERS" || _error "===> ❌ _HELPERS env var is missing in $0"

eval which {git,gpg,bsdtar,wget,xz,zip,unzip,7zip} || _install wget git gnupg2 libarchive-tools zip unzip xz-utils p7zip-full;

_starship-configs(){
    ###############
    ## Starship
    ###############
    _log "===> 🚀 Starship config"
    ## Symlink all starship-*.toml files
    for f in ${DOTFILES_PATH}/starship/starship-*.toml ;do
        _log "===> Symlink: $f to ${HOME}/.config/$(basename $f)" ;
        test -f $f && ln -svnf $f ${HOME}/.config/$(basename $f) ;
    done
    ## Symlink main starship.toml file
    test -f ${HOME}/.config/starship.toml -a -L ${HOME}/.config/starship.toml && {
        _log "===> File: $(ls -l ${HOME}/.config/starship.toml)\n ===> Remove file before symlinking" ;
        return ;
    }   || ln -svnf "${DOTFILES_PATH}"/starship/starship.toml ${HOME}/.config/starship.toml ;
}

_starship-install() {
    _log "===> 🚀 Starship install"
    #curl -sSL https://starship.rs/install.sh | sh -s -- --bin-dir /opt/starship/bin
    which starship 2>/dev/null || wget -qO- https://starship.rs/install.sh | sh -s -- --yes
    echo 'eval "$(starship init $SHELL)"' > ~/.starshiprc
    grep -q starshiprc ~/.bashrc ||echo 'test -f ~/.starshiprc && . ~/.starshiprc' >> ~/.bashrc
    test -f ~/.starshiprc && . ~/.starshiprc
}

# ######
# Main
# ######
__main__() {
    _starship-install || exit 1 ;
    _starship-configs  || true ;
}
test -n "$1" && $1 || __main__
set +x
