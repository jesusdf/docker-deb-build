# docker-deb-build
Debian based image (stable-slim) to build a debian package.

Mount your package folder over /usr/src:

    cd ~/src/deb/mypackage && docker run --volume $(pwd):/usr/src jesusdf/docker-deb-build

~/src/deb/mypackage/build.sh will be run inside the container.

See the docker-compose.yml file for an example enabling Azure DevOps Server Agent.