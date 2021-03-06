#!/bin/bash

GCFLOC="/usr/local/bin/gcf"
IRODSLOC="${HOME}/src/iRODS"
SRCGENICREDPATH=""
DSTGENICREDPATH=""
SRCGENIJKSPATH=""
DSTGENIJKSPATH=""
IRODSPATH=""

_usage() {
cat <<EOF
        Usage: credconfig.sh -g <geni-cert-path> [ -f <keystore-path> ] [ -i <irods-conf-path> ]
	Required:
		-g   --geni           Configures the geni certificate
        Options:
                -f   --flukes         Configures Flukes to use the keystore 
                -h   --help           Show this message
		-i   --irods          Configures the irods client
                -c   --cert           Configures the certificate to use for irods GSI
                -k   --key            Configures the key to use for irods GSI
                -b   --browser        Imports pkcs12 certificate into browsers

EOF
}

# options may be followed by one colon to indicate they have a required argument
if ! options=$(getopt -o g:f:i:c:k:b:-h -l geni:,flukes:,irods:,cert:,key:,browser:,help -- "$@")
then
    # something went wrong, getopt will put out an error message for us
    _usage 1>&2
    exit 1
fi

set -- $options

while [ $# -gt 0 ]
do
    case $1 in
    -g|--geni) SRCGENICREDPATH=`echo $2 | sed -e "s/'//g"` ; shift;;
    -f|--flukes) SRCGENIJKSPATH=`echo $2 | sed -e "s/'//g"`; shift;;
    -i|--irods) IRODSPATH=`echo $2 | sed -e "s/'//g"` ; shift;;
    -c|--cert) IRODSCERT=`echo $2 | sed -e "s/'//g"` ; shift;;
    -k|--key) IRODSKEY=`echo $2 | sed -e "s/'//g"` ; shift;;
    -b|--browser) PK12PATH=`echo $2 | sed -e "s/'//g"` ; shift;;
    -h|--help) _usage 1>&2;exit 0;;
    (--) shift; break;;
    (-*) echo "$0: error - unrecognized option $1" 1>&2; _usage 1>&2; exit 1;;
    (*) break;;
    esac
    shift
done

if [ "${SRCGENICREDPATH}" = "" ]; then
    echo "Must provide path to GENI credential"
    _usage 1>&2
    exit 1
fi

if [ ! -r ${SRCGENICREDPATH} ]; then
    echo "Cannot read ${SRCGENICREDPATH}"
    _usage 1>&2
    exit 1
fi

KEYISTHERE=`cat ${SRCGENICREDPATH} | grep "BEGIN RSA PRIVATE KEY"`
CERTISTHERE=`cat ${SRCGENICREDPATH} | grep "BEGIN CERTIFICATE"`
if [ "${KEYISTHERE}" = "" -o "${CERTISTHERE}" = "" ]; then
    echo "Invalid GENI credential at ${SRCGENICREDPATH}"
    _usage 1>&2
    exit 1
fi 

# Make sure the certificate file is in $HOME/.ssl
CREDFILE=`basename ${SRCGENICREDPATH}`
DSTGENICREDPATH="${HOME}/.ssl/${CREDFILE}"
if [ "${SRCGENICREDPATH}" != "${DSTGENICREDPATH}" ]; then
    if [ ! -d ${HOME}/.ssl ]; then
        mkdir ${HOME}/.ssl
    fi
    cp ${SRCGENICREDPATH} ${DSTGENICREDPATH}
fi

# Create the omni_config file
if [ -r ${HOME}/.gcf/omni_config ]; then
    mv ${HOME}/.gcf/omni_config ${HOME}/.gcf/omni_config.bak
    echo "omni_config file exists, moving to omni_config.bak"
fi
if [ -r ${HOME}/.ssh/geni_key ]; then
    mv ${HOME}/.ssh/geni_key ${HOME}/.ssh/geni_key.bak
    echo "key pair exists, moving to backup"
    if [ -r ${HOME}/.ssh/geni_key.pub ]; then
        mv ${HOME}/.ssh/geni_key.pub ${HOME}/.ssh/geni_key.pub.bak
    fi
fi
echo "Creating public key from private key in GENI certificate"
echo "Creating public key from private key in GENI certificate"
echo "Creating omni_config"
${GCFLOC}/src/omni-configure.py -p ${DSTGENICREDPATH} -f pg 

# Add no StrictHostKeyChecking 
grep ^StrictHostKeyChecking ${HOME}/.ssh/config > /dev/null
if [ $? -eq 1 ]; then
    echo "StrictHostKeyChecking no" >> ${HOME}/.ssh/config
fi

# Add key to the ssh-agent
echo -e "\nAdding key to ssh-agent\n"
ssh-add ${HOME}/.ssh/geni_key
 
# Add PROTOGENI_CERTIFICATE to .bashrc
sed -e 's/^export PROTOGENI_CERTIFICATE/#export PROTOGENI_CERTIFICATE/g' ${HOME}/.bashrc > ${HOME}/.bashrc.temp
mv ${HOME}/.bashrc.temp ${HOME}/.bashrc
echo "export PROTOGENI_CERTIFICATE=\"${DSTGENICREDPATH}\"" >> ${HOME}/.bashrc

# Add HTTPS_KEY_FILE and HTTPS_CERT_FILE to .bashrc
sed -e 's/^export HTTPS_KEY_FILE/#export HTTPS_KEY_FILE/g' ${HOME}/.bashrc > ${HOME}/.bashrc.temp
sed -e 's/^export HTTPS_CERT_FILE/#export HTTPS_CERT_FILE/g' ${HOME}/.bashrc.temp > ${HOME}/.bashrc
rm -f ${HOME}/.bashrc.temp
echo "export HTTPS_KEY_FILE=\"${DSTGENICREDPATH}\"" >> ${HOME}/.bashrc
echo "export HTTPS_CERT_FILE=\"${DSTGENICREDPATH}\"" >> ${HOME}/.bashrc

# Configure iRODS
if [ "${IRODSPATH}" != "" ]; then
    if [ ! -r ${IRODSPATH} ]; then
        echo "Cannot read ${IRODSPATH}"
    else
        CHECKIHOST=`grep irodsHost ${IRODSPATH}`
        CHECKIPORT=`grep irodsPort ${IRODSPATH}`
        CHECKIDEFRES=`grep irodsDefResource ${IRODSPATH}`
        CHECKIUSERNAME=`grep irodsUserName ${IRODSPATH}`
        CHECKIHOME=`grep irodsHome ${IRODSPATH}`
        CHECKICWD=`grep irodsCwd ${IRODSPATH}`
        CHECKIZONE=`grep irodsZone ${IRODSPATH}`
        if [[ ("${CHECKIHOST}" = "") || \
              ("${CHECKIPORT}" = "") || \
              ("${CHECKIDEFRES}" = "") || \
              ("${CHECKIUSERNAME}" = "") || \
              ("${CHECKIHOME}" = "") || \
              ("${CHECKICWD}" = "") || \
              ("${CHECKIZONE}" = "") ]]; then
            echo "Invalid irods configuration"
        else 
            if [ ! -d ${HOME}/.irods ]; then
                mkdir ${HOME}/.irods
            fi
            cp ${IRODSPATH} ${HOME}/.irods/.irodsEnv
            IRODSUSER=`grep irodsUserName ${HOME}/.irods/.irodsEnv | awk '{print $2}' | sed -e "s/'//g"`
#            echo -e "\nInitializing irods password for user ${IRODSUSER}..."
#            ${IRODSLOC}/clients/icommands/bin/iinit
            if [ ! -d ${HOME}/.globus ]; then
                mkdir ${HOME}/.globus
            fi
            if [ "${IRODSCERT}" != "" ]; then
                cp ${IRODSCERT} ${HOME}/.globus/usercert.pem
            fi
            if [ "${IRODSKEY}" != "" ]; then
                cp ${IRODSKEY} ${HOME}/.globus/userkey.pem
                chmod 600 ${HOME}/.globus/userkey.pem
            fi
        fi
    fi
fi

# Import certificate into browsers 
if [ "${PK12PATH}" != "" ]; then
    if [ ! -r ${PK12PATH} ]; then
        echo "Cannot read ${PK12PATH}"
    else
        FNAME=`basename ${PK12PATH}`
        FEXT=`echo ${FNAME} | cut -f2 -d.`
        if [ "${FEXT}" != "p12" ]; then
            echo "Certificate file must be pkcs12 format"
        else 
            # Determine the Firefox directory
            FFDIR=`ls -d ${HOME}/.mozilla/firefox/*.default`
            # Import into Firefox
            echo -e "\nImporting GENI certificate into Firefox"
            pk12util -d ${FFDIR} -i ${PK12PATH} 
            # Import into Chrome 
            echo -e "\nImporting GENI certificate into Chrome"
            pk12util -d sql:${HOME}/.pki/nssdb -i ${PK12PATH} 
        fi
    fi
fi

# If a keystore file is specified, add cert and private key to flukes.properties
if [ "${SRCGENIJKSPATH}" != "" ]; then
    # Make sure the keystore file is in $HOME/.ssl
    JKSFILE=`basename ${SRCGENIJKSPATH}`
    DSTGENIJKSPATH="${HOME}/.ssl/${JKSFILE}"
    if [ "${SRCGENIJKSPATH}" != "${DSTGENIJKSPATH}" ]; then
        if [ ! -d ${HOME}/.ssl ]; then
            mkdir ${HOME}/.ssl
        fi
        cp ${SRCGENIJKSPATH} ${DSTGENIJKSPATH}
    fi

    if [ ! -r ${HOME}/.flukes.properties ]; then
        echo "Cannot read ${HOME}/.flukes.properties"
    elif [ ! -r ${DSTGENIJKSPATH} ]; then
        echo "Cannot read ${DSTGENIJKSPATH}"
    else
        grep -v ^user.keystore= ${HOME}/.flukes.properties > ${HOME}/.flukes.temp
        mv ${HOME}/.flukes.temp ${HOME}/.flukes.properties
        echo "user.keystore=${DSTGENIJKSPATH}" >> ${HOME}/.flukes.properties

        grep -v ^ssh.key= ${HOME}/.flukes.properties > ${HOME}/.flukes.temp
        mv ${HOME}/.flukes.temp ${HOME}/.flukes.properties
        echo "ssh.key=${HOME}/.ssh/geni_key" >> ${HOME}/.flukes.properties

        grep -v ^ssh.pubkey= ${HOME}/.flukes.properties > ${HOME}/.flukes.temp
        mv ${HOME}/.flukes.temp ${HOME}/.flukes.properties
        echo "ssh.pubkey=${HOME}/.ssh/geni_key.pub" >> ${HOME}/.flukes.properties
    fi
fi

