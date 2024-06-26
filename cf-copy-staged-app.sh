#!/bin/bash

# Clone app (staged-droplet) into new space in single command
if [ "$#" -ne 5 ];
  then 
     echo "Usage cf-copy-staged-app.sh <app name> <target org> <target space> <new app hostname> <target copy memory>"
     exit 1
fi

appname=$1
targetorg=$2
targetspace=$3
newhostname=$4
newappmemory=$5

approute=$(cf app $appname | grep routes | awk '{print $2}')
ingressdomain="${approute#*.}"


tmpdir=$(mktemp -d)
echo tmpdir = $tmpdir
pushd $tmpdir
cf download-droplet $appname -p $appname-droplet.tgz
cf target -o $targetorg -s $targetspace 
cf push $appname --droplet $appname-droplet.tgz  --no-route -m $newappmemory --no-start
cf map-route $appname $ingressdomain --hostname $newhostname
cf start $appname
popd
rm -fr $tmpdir
