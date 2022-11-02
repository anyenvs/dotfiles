#!/usr/bin/env bash

#set -e
ls *.env && . *.env || true
DOTFILES_PATH=${DOTFILES_PATH:-..}
test -z "${A_COMMON_FUNCTIONS}" && A_COMMON_FUNCTIONS=($(find ${DOTFILES_PATH}/ -name a_common_functions.bash 2>/dev/null));. $A_COMMON_FUNCTIONS
test -n "$A_COMMON_FUNCTIONS" || _error "===> ❌ A_COMMON_FUNCTIONS env var is missing in $0"

####
# PyEnv Dev Dependencies
####

case $(getInstaller) in
  *apt*) _install curl git gcc make zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev libssl-dev libffi-dev python3-distutils ;;
  *yum*|*dnf*) _install @development zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel xz xz-devel libffi-devel findutils ;;
  *) _error "$(_myOS) not supported" ;;
esac

###
# PIP
###
eval which {pip,} && pip install -U pip || _error "===> ❌ No PIP installed"

####
# PIP dependencies
####
eval which {pip,} && pip install -Ur requirements.txt

__main__() {
}
# ######
# Main
# ######
test -n "$1" && $1 || __main__
set +x
