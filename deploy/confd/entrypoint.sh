#!/usr/bin/env sh

## forward stderr to stdout for use with runit svlogd
exec 2>&1

echo "["$(date "+%F-%T.%Z")"] Confd Controller started"

SV_VARS="./confd.vars"

while true; do

    echo "["$(date "+%F-%T.%Z")"] Initiating restart of Confd service..."

    ## Run confd to render out the config
    confd -onetime -backend env -log-level debug

    test -f "$SV_VARS" && . $SV_VARS

    ## Wait for RUNIT_TIMER_CONFD seconds
    sleep ${RUNIT_TIMER_CONFD:-3601}

    echo "["$(date "+%F-%T.%Z")"] Confd Controller restart completed."
done
