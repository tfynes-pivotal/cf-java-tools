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

appname=$1

approute=$(cf app tdemo3 | grep routes | awk '{print $2}')
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
  command: "export SPRING_DATASOURCE_URL=\$(echo \$VCAP_SERVICES  | jq -r '.postgres[] | select(.name==\"customer-database\")' | jq -r .credentials.jdbcUrl) && ./com.example.customerprofile.Application"
  services:
    - customer-database
EOF

#cf push "$appname-native" -p "$pathtojar" -b java_native_image_cnb_beta -s tanzu-jammy-full-stack -m 8G --no-start -c "export SPRING_DATASOURCE_URL=\$(echo \$VCAP_SERVICES | jq -r '.postgres[] | select(.name==\"customer-database\")' | jq -r .credentials.jdbcUrl) && ./com.example.customerprofile.Application"
cf push -f ./tmp/manifest.yaml
#cf bind-service "$appname-native" "customer-database"
#cf set-env "$appname-native" BP_MAVEN_ACTIVE_PROFILES native
#cf set-env "$appname-native" BP_JVM_VERSION 21
#cf start "$appname-native"
echo cf scale "$appname-native" -m 128M -f
echo cf map-route "$appname-native" "$ingressdomain" --hostname $appname

#rm -f ./tmp/$appname.jar
#rmdir ./tmp
