#!/bin/bash

cf push tdemo -p ./samples/tdemo/target/tdemo-0.0.1-SNAPSHOT.jar --no-start
cf set-env tdemo JBP_CONFIG_OPEN_JDK_JRE "{\"jre\":{\"version\":\"21.+\"}}"
cf start tdemo
sleep 1
curl https://tdemo.homelab.fynesy.com
./cf-java-optimizer.sh tdemo

cf push customer-profile -p ./samples/Customer-Profile/target/customer-profile-0.0.1-SNAPSHOT.jar --no-start
cf set-env customer-profile JBP_CONFIG_OPEN_JDK_JRE "{\"jre\":{\"version\":\"21.+\"}}"
cf bs customer-profile customer-database
cf start customer-profile
sleep 1
curl https://customer-profile.homelab.fynesy.com/api/customer-profiles
./experimental/cf-java-optimizer-app-with-binding.sh customer-profile

