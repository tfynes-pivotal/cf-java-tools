#!/bin/bash

read -n 1 -r -s -p $'Ensure you have a postgres service instance called customer-database created!\nPress any key to continue\n'

if [ "$#" -ne 1 ];
  then 
     echo "Usage deploy-demos.sh <App/Route Prefix>"
     exit 1
fi
prefix=$1


cf push $prefix-tdemo -p ./samples/tdemo/target/tdemo-0.0.1-SNAPSHOT.jar --no-start
cf set-env $prefix-tdemo JBP_CONFIG_OPEN_JDK_JRE "{\"jre\":{\"version\":\"21.+\"}}"
cf start $prefix-tdemo
sleep 1
#curl https://tdemo.homelab.fynesy.com
curl https://$prefix-tdemo.apps.dhaka.cf-app.com
sleep 1
./cf-java-optimizer.sh $prefix-tdemo
sleep 1
cf stop $prefix-tdemo

cf push $prefix-customer-profile -p ./samples/Customer-Profile/target/customer-profile-0.0.1-SNAPSHOT.jar --no-start
cf set-env $prefix-customer-profile JBP_CONFIG_OPEN_JDK_JRE "{\"jre\":{\"version\":\"21.+\"}}"
cf bs $prefix-customer-profile customer-database
cf start $prefix-customer-profile
sleep 1
#curl https://customer-profile.homelab.fynesy.com/api/customer-profiles
#curl https://customer-profile.homelab.fynesy.com/api/customer-profiles -X POST -d '{"firstName":"Mark","lastName":"Fynes","email":"a@b.com"}' -H "Content-Type: application/json"

curl https://$prefix-customer-profile.apps.dhaka.cf-app.com/api/customer-profiles
curl https://$prefix-customer-profile.apps.dhaka.cf-app.com/api/customer-profiles -X POST -d '{"firstName":"Mark","lastName":"Fynes","email":"a@b.com"}' -H "Content-Type: application/json"

sleep 1
./experimental/cf-java-optimizer-app-with-binding.sh $prefix-customer-profile
sleep 1
cf stop $prefix-customer-profile
