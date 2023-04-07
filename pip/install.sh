#!/usr/bin/env bash

#set -e
ls *.env &>/dev/null && . *.env || true
DOTFILES_PATH="${DOTFILES_PATH:-$(readlink -f ..)}"
test -z "${_HELPERS}" && _HELPERS=($(find "${DOTFILES_PATH}"/ -name _helpers.bash 2>/dev/null |sort));. $_HELPERS
test -n "$_HELPERS" || _error "===> ❌ _HELPERS env var is missing in $0"

# ######
# PyEnv Dev Dependencies
# ######
case $(getInstaller) in
    *apt*) _install curl git gcc make zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev libssl-dev libffi-dev python3-distutils libarchive-tools zip unzip xz-utils p7zip-full >/dev/null ;;
    *yum*|*dnf*) _install @development zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel xz-devel libffi-devel findutils >/dev/null ;;
    *) _error "$(_myOS) not supported" ;;
esac

# #####
# PIP
# #####
eval which {pip,} && pip install -U pip || { _error "===> ❌ No PIP installed" ; curl https://bootstrap.pypa.io/get-pip.py -o- | python; }

_pip-deps() {
    # ######
    # PIP dependencies
    # ######
    eval which {pip,} && ( pip install -Ur requirements.txt || true )
}

__main__() {
    _pip-deps || true ;
}
# ######
# Main
# ######
test -n "$1" && $1 || __main__
set +x
