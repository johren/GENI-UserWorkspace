#!/bin/bash

if [[ ${EUID} -ne 0 ]]; then
    echo "You must be root user.  Run command with sudo." 
    exit 1
fi

# options may be followed by one colon to indicate they have a required argument
# n = slicename 
if ! options=$(getopt -o n:u: -l slice:,user: -- "$@")
then
    # something went wrong, getopt will put out an error message for us
    exit 1
fi

set -- $options

SLICENAME=""
USERNAME=""

while [ $# -gt 0 ]
do
    case $1 in
    -n|--slice) SLICENAME=`echo $2 | sed -e "s/'//g"` ; shift;;
    -u|--user) USERNAME=`echo $2 | sed -e "s/'//g"` ; shift;;
    (--) shift; break;;
    (-*) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
    (*) break;;
    esac
    shift
done

if [ "${SLICENAME}" != "" ]; then
    echo "Slice name is ${SLICENAME}"
fi

if [ "${USERNAME}" != "" ]; then
    echo "User name is ${USERNAME}"
fi

# Change the OML server to emmy9.casa.umass.edu
OMFECDIR=/etc/omf-expctl-5.4
if [ -w ${OMFECDIR}/omf-expctl.yaml ]; then 
    mv ${OMFECDIR}/omf-expctl.yaml ${OMFECDIR}/omf-expctl.bak
    sed -e 's/srv\.mytestbed\.net/emmy9\.casa\.umass\.edu/g' ${OMFECDIR}/omf-expctl.bak > ${OMFECDIR}/omf-expctl.yaml
fi

