#!/usr/bin/env bash

[ -n "${DEBUG}" ] && { export PS4='+ [${BASH_SOURCE##*/}:${LINENO}] ' ; set -x; }

ls *.env &>/dev/null && . *.env || true
DOTFILES_PATH="${DOTFILES_PATH:-$(readlink -f ..)}"
test -z "${_HELPERS}" && _HELPERS=($(find "${DOTFILES_PATH}"/ -name _helpers.bash 2>/dev/null |sort));. $_HELPERS;
test -n "$_HELPERS" || _error "===> ❌ _HELPERS env var is missing in $0"

eval which {git,gpg,wget} || _install wget gnupg2 git ;
#eval which {sops,} ||

## Git
_git-configs() {
    test -f "${HOME}/.gitconfig" && _log "===> File exists: $(ls -l ${HOME}/.gitconfig)\n ===> Remove file before symlinking"
    test -f "${HOME}/.gitconfig" -a -L "${HOME}/.gitconfig" -a -f "$(command -v sops)" || {
        sops -d "${DOTFILES_PATH}"/git/cfg/.gitconfig &> /dev/null || _error "===> File not encrypted: $(ls -l "${DOTFILES_PATH}"/git/cfg/.gitconfig)\n===> Otherwise check if correct keys used\n";
        sops -d "${DOTFILES_PATH}"/git/cfg/.gitconfig &> /dev/null && sops -d "${DOTFILES_PATH}"/git/cfg/.gitconfig > "${DOTFILES_PATH}"/git/cfg/.gitconfig_raw;
        test -L "${HOME}/.gitconfig" || ln -svnf "${DOTFILES_PATH}"/git/cfg/.gitconfig_raw ${HOME}/.gitconfig;
    }
    test -f "${HOME}/.gitignore" && {
        _log "===> File exist: $(ls -l ${HOME}/.gitignore)" ;
        return ;
    } || ln -svnf $( readlink -f "${DOTFILES_PATH}"/git/cfg/.gitignore ) ${HOME}/.gitignore
    test -f "${HOME}/.gitattributes" && {
        _log "===> File exist: $(ls -l ${HOME}/.gitattributes)" ;
        return ;
    } || ln -svnf $( readlink -f "${DOTFILES_PATH}"/git/cfg/.gitattributes ) ${HOME}/.gitattributes
}

## GH Cli config
_github-cli-configs() {
    test -d "${HOME}/.config/gh" || mkdir -p ${HOME}/.config/gh
    test -f "${HOME}/.config/gh/config.yml" && {
        _log "===> File exist: $(ls -l ${HOME}/.config/gh/config.yml)" ;
        return ;
    } || ln -svnf "${DOTFILES_PATH}"/git/cfg/gh-config.yml ${HOME}/.config/gh/config.yml
}

## Gitlab Cli config
_gitlab-cli-configs() {
    test -d "${HOME}/.config/glab-cli" || mkdir -p ${HOME}/.config/glab-cli
    test -f "${HOME}/.config/glab-cli/config.yml" -a -L "${HOME}/.config/glab-cli/config.yml" -a -f "$(command -v sops)" || {
        sops -d "${DOTFILES_PATH}"/git/glab/config.yml &> /dev/null || _error "===> File not encrypted: $(ls -l "${DOTFILES_PATH}"/git/glab/config.yml)\n===> Otherwise check if correct keys used\n";
        sops -d "${DOTFILES_PATH}"/git/glab/config.yml &> /dev/null && sops -d "${DOTFILES_PATH}"/git/glab/config.yml > "${DOTFILES_PATH}"/git/glab/config_raw_yml;
    }
    test -f "${HOME}/.config/glab-cli/config.yml" && {
        _log "===> File exist: $(ls -l ${HOME}/.config/glab-cli/config.yml)" ;
        return ;
    } || ln -svnf "${DOTFILES_PATH}"/git/glab/config_raw_yml ${HOME}/.config/glab-cli/config.yml
    ## Glab Aliases
    test -f "${HOME}/.config/glab-cli/glab_aliases.yml" && ln -svnf "${DOTFILES_PATH}"/git/glab/glab_aliases.yml ${HOME}/.config/glab-cli/aliases.yml
}

__main__() {
    _git-configs || exit 1 ;
    _github-cli-configs || true ;
    _gitlab-cli-configs || true ;
}
# ######
# Main
# ######
test -n "$1" && $1 || __main__
set +x
