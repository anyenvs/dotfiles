#!/usr/bin/env bash

#set -e
DOTFILES_PATH=${DOTFILES_PATH:-.}
test -z "${A_COMMON_FUNCTIONS}" && A_COMMON_FUNCTIONS=($(find ${DOTFILES_PATH}/ -name a_common_functions.bash 2>/dev/null));. $A_COMMON_FUNCTIONS;
test -n "$A_COMMON_FUNCTIONS" || _error "===> ❌ A_COMMON_FUNCTIONS env var is missing in $0"

eval which {git,gpg,wget} || _install wget gnupg2 git-core;
#eval which {sops,} ||

## Git
test -f ${HOME}/.gitconfig && _log "===> File exists: $(ls -l ${HOME}/.gitconfig)\n ===> Remove file before symlinking"
test -f ${HOME}/.gitconfig -a -L ${HOME}/.gitconfig -a -f $(command -v sops) && {
    sops -d ${DOTFILES_PATH}/git/.gitconfig 2&>1 /dev/null || _error "===> File not encrypted: $(ls -l ${DOTFILES_PATH}/git/.gitconfig)\n===> Otherwise check if correct keys used\n";
    sops -d ${DOTFILES_PATH}/git/.gitconfig 2&>1 /dev/null && sops -d ${DOTFILES_PATH}/git/.gitconfig > ${DOTFILES_PATH}/git/.gitconfig_raw;
    ln -svnf ${DOTFILES_PATH}/git/.gitconfig_raw ${HOME}/.gitconfig;
}
test -f ${HOME}/.gitignore && _log "===> File exist: $(ls -l ${HOME}/.gitignore)" || ln -svnf ${DOTFILES_PATH}/git/.gitignore ${HOME}/.gitignore
test -f ${HOME}/.gitattributes && _log "===> File exist: $(ls -l ${HOME}/.gitattributes)" || ln -svnf ${DOTFILES_PATH}/git/.gitattributes ${HOME}/.gitattributes

## GH Cli config
test -d ${HOME}/.config/gh || mkdir -p ${HOME}/.config/gh
test -f ${HOME}/.config/gh/config.yml && _log "===> File exist: $(ls -l ${HOME}/.config/gh/config.yml)" || ln -sf ${DOTFILES_PATH}/git/gh-config.yml ${HOME}/.config/gh/config.yml

set +x
