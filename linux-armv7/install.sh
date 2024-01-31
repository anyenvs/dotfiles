#!/usr/bin/env bash

#set -e
[ -n "$ENV_DEBUG" ] && set -x

ls *.env &>/dev/null && . *.env || true
export BASH_SOURCE_DIR="$(dirname $(readlink -f ${BASH_SOURCE:-$0}))" BASH_SOURCE_DIR_UP="$(readlink -f $(dirname $(readlink -f ${BASH_SOURCE:-$0}))/../)";
export DOTFILES_PATH="$( readlink -f $(ls -d ${DOTFILES_PATH:-$BASH_SOURCE_DIR}/_helpers 2>/dev/null || ls -d ${DOTFILES_PATH:-$BASH_SOURCE_DIR_UP}/_helpers 2>/dev/null) | xargs dirname )"
test -z "${_HELPERS}" && _HELPERS=($(find "${DOTFILES_PATH}"/_helpers -name *.bash 2>/dev/null |sort));
for h in ${_HELPERS[@]} ;do . "$h" ;done
test -n "$_HELPERS" || _error "===> ❌ _HELPERS env var is missing in $0"
echo _HELPERS = "${_HELPERS[@]}"

PATH=$HOME/.local/bin:$HOME/bin:/usr/local/bin:/usr/bin:/usr/sbin:/sbin:/bin:$PATH:/lib/git-core
export OPKG_ROOT=/opt/opkg
export PATH=$(echo -n "$HOME/.local/bin:$HOME/bin:$PATH:${OPKG_ROOT}/bin:${OPKG_ROOT}/sbin" | awk -v RS=: -v ORS=: '!x[$0]++' | sed "s/\(.*\).\{1\}/\1/")
export TERM=xterm
export DATA_1=/mnt/HD/HD_a2/DATA_1
export DATA_1_APPS=${DATA_1}/opt/repos/_dotfiles
export DATA_1_ARMV7=${DATA_1_APPS}/linux-armv7 DATA_1_ARMV7_TOOLS=${DATA_1_APPS}/linux-armv7/armv7-android-tools
export BASHRC=${DATA_1_APPS}/linux-armv7/_bashrc

_dotfiles-repo() {
    test -d ${DATA_1}/opt/repos/_dotfiles || { echo "Please clone DOTFILES Repo\n git clone --branch=main --depth=1 https://x-token-auth@github.com/anyenvs/dotfiles.git ${DATA_1}/opt/repos/_dotfiles" ; return 1; }
    test -f ${DATA_1}/_dotfiles || ( cd $DATA_1 ; ln -svnf opt/repos/_dotfiles _dotfiles )
    test -f ~/.bashrc || ( cd ~ ; ln -svnf ${BASHRC} .bashrc || exit 1 )
    set +x
}

_armv7-configs() {
    test -f ~/.bashrc || ( cd ~ ; ln -svnf ${BASHRC} .bashrc || exit 1 )
    for f in bash_history htoprc gitconfig wgetrc vimrc ;do ( cd ~ ; test -f .${f} || ln -svnf ${DATA_1_APPS}/linux-amd64/_${f} .${f} ) ;done
    for d in config cache local ssh vim ;do ( cd ~ ; test -d .${d} || ln -svnf ${DATA_1}/opt/.${d} .${d} ) ;done
    set +x
}

_armv7-tools() {
    test -d "${DATA_1_ARMV7_TOOLS}" || echo "git clone --branch=main --depth=1 https://x-token-auth@github.com/anyenvs/armv7-android-tools.git ${DATA_1_ARMV7_TOOLS}"
    #echo "git clone --branch=main --depth=1 https://github.com/Allespro/armv7-android-tools.git ${DATA_1_ARMV7_TOOLS}"
    for f in ${DATA_1_ARMV7_TOOLS}/bin/* ;do eval which ${f##*/} || ( cd /usr/local/bin ; test -f ${f} && ln -svnf ${f} ${f##*/} ; chmod +x ${f##*/} ) ;done
    ## ArmV7 Libraries
    for i in ${DATA_1_ARMV7_TOOLS}/lib/lib* ;do ( cd ${DATA_1_ARMV7_TOOLS} ; test -f ${i} && cp -fv ${i} /lib/ || cp -fv ${i} /lib/ ) ;done #-a ! -s /lib/${i##*/}
    for i in ${DATA_1_ARMV7_TOOLS}/lib/git-core.tar.gz ;do ( cd ${DATA_1_ARMV7_TOOLS} ; test -f ${i} -a ! -d /lib/git-core && tar zxvf ${i} -C /lib/ ) ;done
    ## Busybox
    eval which {/usr/local/bin/busybox,} || ( f=/usr/local/bin/busybox ; test -f $f || wget -qO $f https://raw.githubusercontent.com/anyenvs/armv7-android-tools/main/bin/${f##*/} ; chmod +x $f ; $f --install ${f%/*} )
    eval which {/usr/local/bin/busybox,} || ( f=/usr/local/bin/busybox ; test -f $f || wget -qO $f http://bin.entware.net/armv7sf-k3.2/installer/chroot/${f##*/} ; chmod +x $f ; $f --install ${f%/*} )
    ## GNU-Sed if not exist
    eval which {gsed,} || ( cd /usr/local/bin ; ln -svnf $(which sed) gsed );
    set +x
}

## anyenv
_anyenv-install() {
    test -d ~/.anyenv -a -f ~/.anyenvrc || ( cd ~ ; ln -svnf ${DATA_1}/opt/.anyenv .anyenv ; ln -svnf ln -svnf ${DATA_1}/opt/_anyenvrc .anyenvrc ) ;
    test -f ~/.anyenvrc && . ~/.anyenvrc ;
    test -d ~/.anyenv && anyenv envs | xargs -n1 anyenv install --force --link ;
    set +x ;
}

## opkg
_opkg-dirs() { local _dirs="${@:-bin etc home lib libexec pkg root sbin share tmp usr var}" ;( cd /opt ; for d in ${_dirs}; do test -d ${d} || ln -svnf opkg/${d} ${d} ;done ) ; }
_opkg-install() {
    test -d /opt/opkg || ( path=$_ ; cd ${path%/*} ; ln -svnf ${DATA_1}/opt/${path##*/} ${path##*/} )
    _opkg-dirs bin etc home lib libexec pkg root sbin share tmp usr var
    eval which {opkg,} || ( wget -qO- https://bin.entware.net/armv7sf-k3.2/installer/alternative.sh | sed 's%/opt%/opt/pkg%g; /wget.*etc\/opkg.conf/ a \\nsed -i "s%/opt%/opt/opkg%g" /opt/pkg/etc/opkg.conf;\nfor i in bin etc home lib libexec pkg root sbin share tmp usr var; do cd /opt ; ln -svnf opkg/${i} ${i} ;done' | bash )
    #wget -qO- https://bin.entware.net/armv7sf-k3.2/installer/alternative.sh | sed 's%/opt%/otp%g; s%bin/opkg %bin/opkg -f /otp/etc/opkg.conf %g; /wget.*etc\/opkg.conf/ a \\nsed -i "s%/opt%/otp%g" /otp/etc/opkg.conf;\nfor i in etc tmp; do ln -svnf /otp/${i} /opt/${i} ;done'
    set +x
}

#export GIT_TRACE2=2 GIT_CURL_VERBOSE=1
###--- Main ---###
__main__() {
    ###--- dirs
    test -d /opt/DATA_1 || ( cd /opt ; ln -svnf ${DATA_1} DATA_1 )
    test -d /otp || ( path=$_ ; cd / ; ln -svnf ${DATA_1_APPS}/linux-armv7/${path##*/} ${path##*/} )

    _dotfiles-repo  || return 1 ;
    _armv7-configs  || return 1 ;
    _armv7-tools    || return 1 ;
    _opkg-install   || return 1 ;
    _anyenv-install || return 1 ;
}
# ######
# Main
# ######
test -n "$1" && $1 || __main__
set +x
