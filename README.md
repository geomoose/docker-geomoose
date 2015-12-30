docker-geomoose 
===============

This will create a GeoMOOSE docker image based on Ubuntu/Trusty with:

* MapServer (GitHub Master)
* Apache
* PHP 5 
* GeoMOOSE (GitHub Master)

## Building docker-geomoose

Running this will build a docker image with mapserver 7

    git clone https://github.com/geomoose/docker-geomoose
    cd docker-geomoose
    docker build -t geomoose .


## Running docker-geomoose

This image expose three ports 22 for ssh and 80 for Mapserver

    sudo docker run -d -P -v /usr/local/mapserver:/maps --name geomoose geomoose

## Image active users

The root password is `toor`.


## Test it

http://HOST_IP:DOCKER_80_PORT/cgi-bin/mapserv
