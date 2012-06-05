#!/bin/bash

SRCDIR=`dirname $0`

# Add GEMINI test code to the PATH 
grep "includes GEMINI acceptance test code" ${HOME}/.bashrc  > /dev/null
if [ $? -eq 1 ]; then
    echo "Adding GEMINI test code to path"
    cat << EOF >> ${HOME}/.bashrc 
# set PATH so it includes GEMINI acceptance test code if it exists
if [ -d "\${HOME}/src/GEMINI-AccTest" ] ; then
    PATH="\${HOME}/src/GEMINI-AccTest:\$PATH"
fi   
EOF
else
    echo "GEMINI test code already in path"
fi

echo "Updating placelampcert.sh"
sudo cp $SRCDIR/placelampcert.sh /opt/lamp

