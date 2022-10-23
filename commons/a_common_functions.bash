#!/usr/bin/env bash

_setX() { _allOpts=$- ; set +x ; [[ $_allOpts =~ [x] ]] && { set +x ; echo 'x' ; }; }  # set -x wrapper
isSetX=$(_setX)
test -n "${isSetX^^}" && set +x
#-- Colors escape seqs
YEL='\033[1;33m'
CYN='\033[0;36m'
GRN='\033[1;32m'
RED='\033[1;31m'
NRM='\033[0m'

_log() {
    _allOpts=$- ; set +x
    [[ $_allOpts =~ [x] ]] && { set +x ; _isSetX=1 ; }
    [[ $_allOpts =~ [e] ]] && { set +e ; _isSetE=1 ; }
    local _cmd2=$(eval "echo -e \"${@}\"" 2>&1 )
    echo -e "${CYN}[${FUNCNAME[1]:-alias}]${NRM}\n ${GRN}$*${NRM}"
    unset _cmd2;
    [[ $_isSetE =~ 1 ]] && { unset _isSetE ; set -e ; }
    [[ $_isSetX =~ 1 ]] && { unset _isSetX ; set -x ; }
}

_error() {
    _allOpts=$- ; set +xe
    [[ $_allOpts =~ [x] ]] && { set +x ; _isSetX=1 ; }
    [[ $_allOpts =~ [e] ]] && { set +e ; _isSetE=1 ; }
    local _cmd2=$(eval "echo -e \"${@}\"")
    echo -e "===> ${CYN}[${FUNCNAME[1]}]${NRM} ${RED}ERROR${NRM}: ${RED}$*${NRM}"
    return -1
    unset _cmd2;
    [[ $_isSetE =~ 1 ]] && { unset _isSetE ; set -e ; }
    [[ $_isSetX =~ 1 ]] && { unset _isSetX ; set -x ; }
}

## Common OS validations
_RELEASE() { . /etc/os-release ; case $ID in debian) echo "${ID^}_${VERSION_ID}" ;; ubuntu) echo "x${ID^}_${VERSION_ID}" ;; esac; set +x; }
_myOS()    { echo -n $(uname -s | tr '[:upper:]' '[:lower:]:'|sed 's/mingw64_nt.*/windows/' ); }
_myARCH()  { echo -n $(uname -m | sed 's/x86_64/amd64/g'); }
_myMARCH() { echo -n $(uname -m); }
_myOSCap() { echo -n $(uname -s | sed 's/mingw64_nt.*/Windows/' ); }
_isOSX()   { case $(_myOS) in darwin) echo osx ;; *) _myOS ;; esac; }
_isMac()   { case $(_myOS) in darwin) echo mac;; *) echo $(_myOS);; esac; }
_isMacOS() { case $(_myOS) in darwin) echo macOS;; *) echo $(_myOS);; esac; }

__git_info ()
{
    local last_cmd=${1:-0};
    local GIT_BRANCH_CHANGED_SYMBOL='+';
    local GIT_PULL_SYMBOL='⇣';
    local GIT_PUSH_SYMBOL='⇡';
    local RESET="$(tput sgr0)";
    BRANCH="$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --always 2>/dev/null)" || return;
    local aheadN;
    local behindN;
    local branch;
    local marks;
    local stats;
    stats="$(git status -uno --porcelain --branch -s)";
    aheadN="$(echo $stats | grep -o 'ahead [[:digit:]]\+')";
    behindN="$(echo $stats | grep -o 'behind [[:digit:]]\+')";
    marks=" ${aheadN//ahead /$GIT_PUSH_SYMBOL}${behindN//behind /$GIT_PULL_SYMBOL}";
    [ -z "${stats}" ] || printf " %s" "$BRANCH$marks";
    return $last_cmd
}

# test if bash parameter set
# set -x; if is_shell_attribute_set x; then echo "yes"; else echo "no"; fi # yes
# set -o pipefail; if is_shell_option_set pipefail; then echo "yes"; else echo "no"; fi # no
is_shell_attribute_set() { # attribute, like "x"
  case "$-" in
    *"$1"*) echo 0; return 0 ;;
    *)      echo 1; return 1 ;;
  esac
}
# set -o pipefail; if is_shell_option_set pipefail; then echo "yes"; else echo "no"; fi # no
is_shell_option_set() { # option, like "pipefail"
  case "$(set -o | grep "$1")" in
    *on) echo 0; return 0 ;;
    *)   echo 1; return 1 ;;
  esac
}

# runs the given command as root (detects if we are root already)
: ${USE_SUDO:="true"}
runAsRoot()   { if [ $EUID -ne 0 -a "$USE_SUDO" = "true" ]; then sudo "${@}"; else ${@}; fi || su -c "${@}" ; }
runAsUser()   { if [ $EUID -eq 0 -a "$USE_SUDO" = "true" ]; then sudo su - $USER bash -c "${@}"; else ${@}; fi || su - $USER -c "${@}" ; }
setUserHome() { [[ $(id -u $USER) -eq 0 ]] && echo /root || echo /home/$USER ; }
isBunaryInstalled() { eval which {$1,} && { _log "===> Binary: $(command -v $1)"; return 0; } || { _error "Missing Binary in PATH:\n $(command -v $1)"; return -1; }; set +x; }
isAnyEnvInstalled() { test -n "$(command -v $1)" -a -d $(ls -d1 ${HOME}/{.*,*} | grep $1 | head -1) && { _log "===> Binary: $(command -v $1)\n ===> DIR: $(ls -d1 ${HOME}/{.*,*} | grep $1)"; return 0; } || { _error "Missing or Binary in PATH\n ===> DIR: $(ls -d1 ${HOME}/{.*,*} | grep $1) \n ===> Binary in PATH: $(command -v $1)"; return -1; }; set +x; }
getOpts()      { _allOpts=$- ; set +x ; [[ $_allOpts =~ [x] ]] && { set +x ; _isSetX=1 ; }; echo "$@" ; test -z "$_isSetX" || { unset _isSetX;set -x; }; }  # set -x wrapper
getInstaller() { _cmd=( $(eval which {apt-get,dnf,yum,brew}) ); test -n ${_cmd} || return 1; echo ${_cmd}; } #echo ${_cmd[@]};
_install() { case $(getInstaller) in *apt*) $(getInstaller) install "${@}" --no-install-recommends -y ;; *brew) $(getInstaller) install "$@" ;; *yum*|*dnf*) $(getInstaller) install "$@" -y ;; *) echo "Package manager not found to install: $@";; esac; }
#aptGetInstall() { runAsRoot $(_aptget) update -yqq  && runAsRoot $(_aptget) install "${@}" --no-install-recommends -y >/dev/null; }
#aptGetInstall() { if $(command -v apt-get >/dev/null); then runAsRoot apt-get update -yqq && runAsRoot apt-get install "${@}" --no-install-recommends -y >/dev/null; fi; }
#_aptget(){ _allOpts=$- ; set +x ; [[ $_allOpts =~ [x] ]] && { set +x ; _isSetX=1 ; }; local _aptget=({$(command -v apt-get),$(command -v apt),$(command -v yum),$(command -v brew)}); echo ${_aptget[${1:-0}]}; test -z "$_isSetX" || { unset _isSetX;set -x ; }; }  # get possible package manager in order: echo ${_apt[*]} ${_apt[@]} ${!_apt[@]}

#set -x
test -n "${isSetX^^}" && set -x
