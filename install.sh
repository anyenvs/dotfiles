#!/usr/bin/env bash

#set -e

###
# Installation of packages, configurations, and dotfiles.
###
#export DOTFILES_PATH=$(pwd);
#export DOTFILES_PATH=$(dirname $0);
#dirname $0
#dirname $(readlink -f ${BASH_SOURCE:-$0})
#dirname $(realpath ${BASH_SOURCE:-$0})
#export DOTFILES_PATH="$(dirname $(readlink -f ${BASH_SOURCE:-$0}))";
export BASH_SOURCE_DIR="$(dirname $(readlink -f ${BASH_SOURCE:-$0}))" BASH_SOURCE_DIR_UP="$(readlink -f $(dirname $(readlink -f ${BASH_SOURCE:-$0}))/../)";
export DOTFILES_PATH="$( readlink -f $(ls -d ${DOTFILES_PATH:-$BASH_SOURCE_DIR}/_helpers 2>/dev/null || ls -d ${DOTFILES_PATH:-$BASH_SOURCE_DIR_UP}/_helpers 2>/dev/null) | xargs dirname )"
cd "$DOTFILES_PATH" ; ls *.env &>/dev/null && . *.env || true
export _HELPERS=($(find "${DOTFILES_PATH}/_helpers" -name *.bash 2>/dev/null |sort));
for h in ${_HELPERS[@]} ;do . "$h" ;done

###
# Install dependencies
###
_DEFAULT_PACKAGES=(
    brew
    git
    fzf
    anyenv
    go
    pip
    vim
    vscode
    starship
    tools
)
case $(_myOS) in linux) _PACKAGES=( ${1:-${_DEFAULT_PACKAGES[@]/brew}} ) ;; *) _PACKAGES=( ${1:-${_DEFAULT_PACKAGES[@]}} ) ;; esac

echo _HELPERS=${_HELPERS[@]}
for pkg in "${_PACKAGES[@]}"; do printf " ===> 📣 Starting %s\n" "${pkg}" && DOTFILES_PATH="${DOTFILES_PATH:-.}" _HELPERS=$_HELPERS bash "$DOTFILES_PATH"/dotfiles install $pkg ;done
#./dotfiles install brew
#./dotfiles install git
#./dotfiles install fzf
#./dotfiles install vim
#./dotfiles install vscode

set +x
