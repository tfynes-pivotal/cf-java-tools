

cf-java-optimizer.sh
Takes an java spring boot application running in cloud foundry and restage an deploy an adjacent natively compiled implementation, mapped to the same ingress route as the original

Script will download the 'jar' archive from the platform before re-pushing it for staging with the native image buildpack
