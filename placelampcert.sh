#! /bin/bash
MANIFESTFILE=$1
CERTFILE=$2

if [ "${MANIFESTFILE}" = "" ]; then
    echo "Must provide path to manifest file"
    exit 1
fi

if [ "${CERTFILE}" = "" ]; then
    echo "Must provide path to certificate file"
    exit 1
fi

NODES=`grep login $MANIFESTFILE | sed -e 's/^ *//g;s/ *$//g' | awk '{print $9, $10}' | sed -e 's/hostname=//g' | sed -e 's/port=//g' | sed -e 's/"//g' | sed -e 's/ /:/g'`

for node in $NODES; do
    HOST=`echo $node | cut -d":" -f1` 
    PORT=`echo $node | cut -d":" -f2`
    echo "Placing certificate on node $HOST port $PORT" 
    scp -P $PORT lampcert.pem johren@$HOST:
    #ssh -p $PORT johren@$HOST "sudo install -o root -g perfsonar -m 440 lampcert.pem /usr/local/etc/protogeni/ssl/"
#    ssh -p $PORT johren@$HOST "sudo mv lampcert.pem /usr/local/etc/protogeni/ssl/lampcert.pem"
#    ssh -p $PORT johren@$HOST "sudo chown root.perfsonar /usr/local/etc/protogeni/ssl/lampcert.pem"
#    ssh -p $PORT johren@$HOST "sudo chmod 440 /usr/local/etc/protogeni/ssl/lampcert.pem"
    #ssh -p $PORT johren@$HOST "sudo /usr/local/etc/protogeni/ssl/getcacerts"
#    ssh -p $PORT johren@$HOST "sudo /etc/init.d/psconfig restart"
done

for node in $NODES; do
    HOST=`echo $node | cut -d":" -f1` 
    PORT=`echo $node | cut -d":" -f2`
    #ssh -p $PORT johren@$HOST "sudo ls /usr/local/etc/protogeni/ssl/lampcert.pem"
    ssh -p $PORT johren@$HOST "sudo ls lampcert.pem"
    if [ $? -ne 0 ]; then
        echo "No certificate on $HOST"
    fi
done

