#!/usr/bin/env bash

#set -e

###
# Installation of packages, configurations, and dotfiles.
###
ls *.env && . *.env || true
export DOTFILES_PATH=$(pwd);
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