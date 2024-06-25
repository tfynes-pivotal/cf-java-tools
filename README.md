



### cf-java-optimizer.sh

Takes an java spring boot application running in cloud foundry and restage an deploy an adjacent natively compiled implementation, mapped to the same ingress route as the original

Script will download the 'jar' archive from the platform before re-pushing it for staging with the native image buildpack

## Usage

### Prerequisites

- Spring boot application maven/gradle packaged usign the '-Pnative' flag and includes graalvm dependency

`mvn clean package -Pnative`

- Spring boot application running in cloud foundry, as a 'normal' staged JIT compiled application

`cf push <appName>`

- Script is run at prompt where cf cli is logged into cloud foundry already

`cf-java-optimizer.sh <appName>`

### What script does

- uses name of deployed application to locate and download the unstaged 'jar' archive
- pushes the jar to be staged with the native image buildpack, under a name of '<appName>-native'
- scales memory down to just 32MB (8GB provided for native image compilation stager task)
- maps native app to same route as original application

  ![image](https://github.com/tfynes-pivotal/cf-java-tools/assets/6810491/f6b48bd2-3b0e-4785-b978-e46a90da96cf)

![image](https://github.com/tfynes-pivotal/cf-java-tools/assets/6810491/d50d6b29-0150-45b5-88b6-eec535fdd710)

