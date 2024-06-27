



### cf-java-optimizer.sh

Takes a java spring boot application running in cloud foundry and stages an adjacent natively-compiled implementation, mapped to the same ingress route as the original.

Script will download the 'jar' archive from the platform before re-pushing it for staging with the native image buildpack.

## Usage

### Prerequisites

- Compile/package spring boot app with the '-Pnative' flag, including the graalvm maven dependency

`mvn clean package -Pnative`

- Push to cloud foundry as a 'normal' staged JIT compiled application

`cf push <appName>`

- Trigger script to co-deploy native optimized implementation

`cf-java-optimizer.sh <appName>`

### What script does

- uses name of deployed application to locate and download the unstaged 'jar' archive
- pushes the jar to be staged with the native image buildpack, under a name of '<appName>-native'
- scales memory down to just 32MB (8GB provided for native image compilation stager task)
- maps native app to same route as original application

  ![image](https://github.com/tfynes-pivotal/cf-java-tools/assets/6810491/f6b48bd2-3b0e-4785-b978-e46a90da96cf)

![image](https://github.com/tfynes-pivotal/cf-java-tools/assets/6810491/d50d6b29-0150-45b5-88b6-eec535fdd710)



### cf-npush.sh
- Script to push an application directly to TAS as a native image
- Pushes the app, sets required BP* env-vars, resizes app after successful stage.

`cf-npush.sh <app-name> <ingress-domain> <path-to-jar> <memory to allocate (eg 32M)>`

e.g.
`cf-npush.sh tdemo mycfdomain.com ./samples/tdemo/target/tdemo-0.0.1-SNAPSHOT.jar 32M`

### cf-copy-staged-app.sh
What if I want to levergage an isolation segment for staging native images, providing cpu isolation and perhaps higher-cpu diego cells to optimize the compilation efforts. Stage applications natively in isolated high-cpu org/space then copy staged droplet to production org/space.

- Script to copy a staged app from current org/space to new org/space

`cf-copy-staged-app.sh <app name> <target org> <target space> <new app hostname> <target copy memory>`


## DEMO SCRIPTS

Hello world (tdemo) rest app and "Customer-Profile" spring data jpa sample applications included.

### Hello world rest app in 32MB on TAS

* compile/package and 'cf push' sample application
```
pushd samples/tdemo
mvn clean package -Pnative
cf push tdemo -p ./target/tdemo-0.0.1-SNAPSHOT.jar
popd
```

* setup a loop testing the application endpoint
```
while true; do sleep 2 && curl https://tdemo.<app-domain>; done
```

* trigger optimizer script to parallel deploy a memory optimized instance on same route
```
./cf-java-optimizer.sh tdemo
```

* 5-10minutes later the client will show responses being load-balanced
across the JIT and natively compiled instances of the application.
The native version will be running in just 32mb


### Spring Data Rest Service on Postgres DB

* create 'customer-database' instance of postgres service
```
cf create-service postgres <plan-name> customer-database
```

* Deploy 'customer-profile' application
```
pushd samples/Customer-Profile
mvn clean package -Pnative
cf push customer-profile --no-start
cf bind-service customer-profile customer-database
cf start customer-profile
```

* Run a create operation on the data-service
```
curl https://customer-profile.<cf-domain>/api/customer-profiles -X POST -d '{"firstName":"Joe","lastName":"Soap","email":"a@b.com"}' -H "Content-Type: application/json"
```

* Setup looping read api request 
```
while true ; do sleep 5 && curl -s https://customer-profile.<cf-domain>/api/customer-profiles | jq . ; done
```

* run experimental optimizer script to deploy java native version of service, bound to same database, exposed on same route using just 128MB allocated memory.
```
./experimental/cf-java-optimizer-app-with-bindings.sh customer-profile
```

* Results in dual implementations of the rest service, bound to same database instance, and ingress route.
* NOTE: beta cnb-buildpack cannot directly bind to services "vcap_services" env-var in platform.. workaround uses custom launch command to create a spring_datasource_url env-var with value from vcap_services in the custom launch command.