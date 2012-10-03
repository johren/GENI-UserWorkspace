#!/bin/bash

GENIUSER=$1
AGG=$2

if [ "${AGG}" = "" ]; then
    AGG=exosm
fi
if [ "${GENIUSER}" = "" ]; then
   echo "$0 <username> [aggregate]"
   exit 1
fi

SLICES=`omni.py listmyslices ${GENIUSER} 2>&1 | grep urn:publicid | awk -F'+' '{print $4}'`

for i in ${SLICES}; do 
    echo "   $i"
    omni.py -a ${AGG} listresources $i 2>&1 | grep "possible aggregates"
done
