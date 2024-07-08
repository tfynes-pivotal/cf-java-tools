### Hello Tanzu Demo

Simple 'hello world' java rest application

Package/compile as follows;
`
mvn clean package -Pnative
`

script available to deploy to CF as a natively compiled image - needing only 32MB RAM

`
../../cf-npush.sh tdemo homelab.fynesy.com ./target/tdemo-0.0.1-SNAPSHOT.jar 32M
`

Script deploys using a 8GB footprint for application staging, then resizes the running app once staging is complete.