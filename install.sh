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
export DOTFILES_PATH=$(dirname $(realpath ${BASH_SOURCE:-$0}));
cd $DOTFILES_PATH ; ls *.env &>/dev/null && . *.env || true
export A_COMMON_FUNCTIONS=($(find ${DOTFILES_PATH:-.}/ -name a_common_functions.bash 2>/dev/null));. $A_COMMON_FUNCTIONS

###
# Install dependencies
###
_DEFAULT_PACKAGES=(
    git
    anyenv
    go
    pip
    vim
    brew
    starship
)
case $(_myOS) in linux) _PACKAGES=( ${1:-${_DEFAULT_PACKAGES[@]/brew}} ) ;; *) _PACKAGES=( ${1:-${_DEFAULT_PACKAGES[@]}} ) ;; esac

for pkg in "${_PACKAGES[@]}"; do printf " ===> 📣 Starting %s\n" "${pkg}" && DOTFILES_PATH=${DOTFILES_PATH:-.} A_COMMON_FUNCTIONS=$A_COMMON_FUNCTIONS bash $DOTFILES_PATH/dotfiles install $pkg ;done
#./bin/dotfiles install omz
#./bin/dotfiles install zsh
#./bin/dotfiles install brew
#./bin/dotfiles install vscode
#./bin/dotfiles install git
#./bin/dotfiles install github
#./bin/dotfiles install node
#./bin/dotfiles install mongodb
#./bin/dotfiles install starship
#./bin/dotfiles install tmux
#./bin/dotfiles install vim

set +x
