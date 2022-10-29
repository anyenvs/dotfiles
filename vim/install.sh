#!/usr/bin/env bash

#set -e
ls *.env && . *.env || true
DOTFILES_PATH=${DOTFILES_PATH:-..}
test -z "${A_COMMON_FUNCTIONS}" && A_COMMON_FUNCTIONS=($(find ${DOTFILES_PATH}/ -name a_common_functions.bash 2>/dev/null));. $A_COMMON_FUNCTIONS
test -n "$A_COMMON_FUNCTIONS" || _error "===> ❌ A_COMMON_FUNCTIONS env var is missing in $0"

eval which {git,gpg,bsdtar,xz,zip,unzip,7zip} || _install wget git gnupg2 libarchive-tools xz zip unzip 7zip;

## Vim
test -f ${HOME}/.vimrc && _log "===> File exist: $(ls -l ${HOME}/.vimrc)\n ===> Remove file before symlinking" || ln -svnf ${DOTFILES_PATH}/vimrc/.vimrc ${HOME}/.vimrc

### GH Cli config
#test -d ${HOME}/.config/gh || mkdir -p ${HOME}/.config/gh
#test -f ${HOME}/.config/gh/config.yml && echo -e "File exist: $(ls -l ${HOME}/.config/gh/config.yml)\n" || ln -sf ${DOTFILES_PATH}/git/gh-config.yml ${HOME}/.config/gh/config.yml

set +x
