### Build an OCI image from a droplet

To build the Dockerfile for your TAS droplet run:
`./buildDockerfile.sh -d <DROPLET>`
(where `<DROPLET>` is the full path of the droplet)

To build the container from the newly created Dockefile and push to your registry use the following:
`docker build . -t <REGISTRY>/<IMAGE>:<TAG>`
`docker push <REGISTRY>/<IMAGE>:<TAG>`
(change `<REGISTRY>/<IMAGE>:<TAG>` appropriately to match your enviroment and application name)

### NOTE: you will need to provide env variables like in the following docker run example:
`docker run  -e CF_INSTANCE_GUID=17800b52-2857-4b1c-7428-e2fc -e CF_INSTANCE_INDEX=0 test:latest -p 8080:8080`
