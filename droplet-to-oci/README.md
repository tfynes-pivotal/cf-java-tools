Build an OCI image from a droplet

To build the Dockerfile for your TAS droplet run:
`./buildDockerfile.sh -d <DROPLET>`
(where <DROPLET> is the full path of the droplet)

To build the container from the newly created Dockefile and push to your registry use the following:
`docker build . -t <REGISTRY>/<IMAGE>:<TAG>`
`docker push <REGISTRY>/<IMAGE>:<TAG>`
(change <REGISTRY>/<IMAGE>:<TAG> appropriately to match your enviroment and application name)

