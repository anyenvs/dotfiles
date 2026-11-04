#!/usr/bin/env bash

##
## SOPS encrypted configs
##

_sops-encrypt() { set +x; return; }

_sops-decrypt() {
    local _files=("$@")
    eval which sops || _error "===> SOPS not installed... files not decrypted = ${_files[@]}" ;

    for f in ${_files[@]} ;do
        f_dec=$(dirname $f)/$(basename ${f//\./_dec\.}) ;
        test -f "$f" -a "$(eval which sops)" && {
            sops -d "$f" &> "$f_dec" || ( _error "\n ===> File not encrypted: $(ls ${f})\n ===> Otherwise check if correct keys used\n  sops -d $f > $f_dec\n"; rm -f $f_dec )  ;
        }
        test -f "${f_dec}" && _log "===> File: ${f} \n ===> Decrypted: ${f_dec}" || _error "\n ===> File not found or not decrypted successfully\n  ${f_dec}\n" ;
    done
    set +x
}
