#!/bin/bash


# Script to take deployed 'hello world' spring boot JIT compiled app
# running in cloud foundry (TAS6+) and restage a sibling version that's
# natively compiled, deployed to same ingress route as original
#
# script sources the original jar from the platform

if [ "$#" -ne 1 ];
  then 
     echo "Usage cf-java-optimizer.sh <app-name>" 
     exit 1
fi

servicename="customer-database"
appexecutable="com.example.customerprofile.Application"


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

#pathtojar="./tmp/$appname.jar"

cat << EOF > ./tmp/manifest.yaml
---
applications:
- name: $appname-native
  memory: 8G
  instances: 1
  path: $appname.jar
  buildpack: java_native_image_cnb_beta
  stack: tanzu-jammy-full-stack
  command: "export SPRING_DATASOURCE_URL=\$(echo \$VCAP_SERVICES  | jq -r '.postgres[] | select(.name==\"$servicename\")' | jq -r .credentials.jdbcUrl) && ./$appexecutable"
  services:
    - customer-database
EOF

cf push -f ./tmp/manifest.yaml
echo cf scale "$appname-native" -m 128M -f
echo cf map-route "$appname-native" "$ingressdomain" --hostname $appname

rm -f ./tmp/$appname.jar
rmdir ./tmp
