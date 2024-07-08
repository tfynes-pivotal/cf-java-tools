Build an OCI image from a droplet

To build the Dockerfile for your TAS droplet run:
`./buildDockerfile.sh -d <DROPLET>`
(where `<DROPLET>` is the full path of the droplet ex: ./buildDockerfile.sh -d ~/Downloads/droplet_baeb95ff-3cd3-40f1-9017-278ac50d06fc.tgz)

To build the container from the newly created Dockefile and push to your registry use the following:
`docker build . -t <REGISTRY>/<IMAGE>:<TAG>`
`docker push <REGISTRY>/<IMAGE>:<TAG>`
(change `<REGISTRY>/<IMAGE>:<TAG>` appropriately to match your enviroment and application name)

To test locally:
`docker run <REGISTRY>/<IMAGE>:<TAG> -p 18080:8080`
(docker run marygabry1508/cf-push:vcap -p 18080:8080)

