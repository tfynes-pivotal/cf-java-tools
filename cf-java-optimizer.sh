#!/bin/bash


# Script to take deployed 'hello world' spring boot JIT compiled app
# running in cloud foundry (TAS6+) and restage a sibling version that's
# natively compiled, deployed to same ingress route as original
#
# script sources the original jar from the platform

if [ "$#" -ne 1 ] && [ "$#" -ne 2 ];
  then 
     echo "Usage cf-java-optimizer.sh <app-name> [<native-app-size (e.g. 32M)>]" 
     exit 1
fi

if [ ! -z "$2" ];
  then
     appsize=$2
  else
     appsize="32M"
fi

appname=$1

approute=$(cf app $appname | grep routes | awk '{print $2}')
ingressdomain="${approute#*.}"
#echo ingressdomain = $ingressdomain

# get the jar from the previous app push
token=$(cf oauth-token)
#echo token = $token

appguid=$(cf app $appname --guid)
echo appguid = $appguid

apppackageurl=$(cf curl /v3/apps/$appguid/packages | jq -r .resources[0].links.download.href)
echo apppackageurl = $apppackageurl

mkdir tmp
curl -s -L -H "Authorization: $token" $apppackageurl -o tmp/$appname.jar
ls tmp/

pathtojar="./tmp/$appname.jar"

export CF_STAGING_TIMEOUT=1800
cf push "$appname-native" -p "$pathtojar" -b java_native_image_cnb_beta -s tanzu-jammy-full-stack -m 8G --no-start
cf set-env "$appname-native" BP_MAVEN_ACTIVE_PROFILES native
cf set-env "$appname-native" BP_JVM_VERSION 21
cf start "$appname-native"
cf scale "$appname-native" -m $appsize -f
cf map-route "$appname-native" "$ingressdomain" --hostname $appname

rm -f ./tmp/$appname.jar
rmdir ./tmp
