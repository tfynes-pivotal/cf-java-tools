#!/bin/bash

# push a jar for an existing running boot app in platform, but via native image builder
# then wire it to same route and existing app
if [ "$#" -ne 4 ];
  then 
     echo "Usage cf-npush.sh <app-name> <ingress-domain> <path-to-jar> <memory to allocate (eg 32M)>"
     exit 1
fi

appname=$1
ingressdomain=$2
pathtojar=$3
appsize=$4

cf push "$appname" -p "$pathtojar" -b java_native_image_cnb_beta -s tanzu-jammy-full-stack -m 8G --no-start
cf set-env "$appname" BP_MAVEN_ACTIVE_PROFILES native
cf set-env "$appname" BP_JVM_VERSION 21
cf start "$appname"
cf scale "$appname" -m $appsize -f
cf map-route "$appname" "$ingressdomain" --hostname $appname
