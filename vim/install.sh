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
    } || ln -svnf "${DOTFILES_PATH}"/vim/.vimrc ${HOME}/.vimrc
}

_vim-plugins() {
    # ############
    # Vim Plugins
    # ############
    test -d ~/.vim/bundle/Vundle.vim || {
      _log "===> Installing Vundle + Plugins" ;
      git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim ;
      vim +PluginInstall +qall ;

    }
}

_vim-poweline-fonts() {
    test -d /opt/fonts || {
      _log "===> Installing PowerLine Fonts" ;
      git clone --depth=1 https://github.com/powerline/fonts.git /opt/fonts || return 1
      cd /opt/fonts && ./install.sh ;
    }
}


__main__() {
    _vim-poweline-fonts    
    _vimrc-config || true
    _vim-plugins
}

# ######
# Main
# ######
test -n "$1" && $1 || __main__
set +x
