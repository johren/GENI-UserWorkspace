#!/bin/bash

CERTFILE=$1
if [ "${CERTFILE}" == "" ]; then
    echo "Must provide path of certificate file"
    exit 1
fi
if [ ! -r ${CERTFILE} ]; then
    echo "Could not read ${CERTFILE}"
    exit 1
fi

NEWFILE=$2
if [ "${NEWFILE}" == "" ]; then
    NEWFILE=ct${CERTFILE}
fi
if [ -e ${NEWFILE} ]; then
    echo "${NEWFILE} already exists"
    exit 1
fi

openssl rsa -in ${CERTFILE} -out ${NEWFILE} 
openssl x509 -in ${CERTFILE} >> ${NEWFILE}
chmod 400 ${NEWFILE} 
