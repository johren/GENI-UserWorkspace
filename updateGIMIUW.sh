#!/bin/bash


# Add GIMI test code to the PATH 
grep "includes GIMI acceptance test code" ${HOME}/.bashrc  > /dev/null
if [ $? -eq 1 ]; then
    echo "Adding GIMI test code to path"
    cat << EOF >> ${HOME}/.bashrc 
# set PATH so it includes GIMI acceptance test code if it exists
if [ -d "\${HOME}/src/GIMI-AccTest" ] ; then
    PATH="\${HOME}/src/GIMI-AccTest:\$PATH"
fi   
EOF
else
    echo "GIMI test code already in path"
fi

