docker-geomoose 
===============

## Credits

Fork of : https://github.com/srounet/docker-mapserver

## What is this?

This will create a GeoMOOSE docker image based on Ubuntu/Trusty with:

* MapServer (GitHub Master)
* Apache 2.6
* PHP 5 
* GeoMOOSE (GitHub Master)
* PostgreSQL 9.3
* PostGIS 2.1
* TinyOWS (GitHub Master)

## Building docker-geomoose

Running this will build a docker image with mapserver 7
```
    git clone https://github.com/geomoose/docker-geomoose
    cd docker-geomoose
    docker build -t geomoose .
```

## How to use this Image

### As a simple demo

The following command will run GeoMOOSE and make it available on the localhost 8080 port:

```
	sudo docker run -p 127.0.0.1:8080:80 --rm=true --name geomoose_demo geomoose
```

Use http://localhost:8080/geomoose/geomoose_dev.html to view GeoMOOSE in the web browser.

Press `CTRL+C` to stop the image from running.
	
### For Testing

This image exposes ports 22 for ssh and 80 for Apache which serves MapServer and GeoMOOSE.
```
    sudo docker run -d -P --name geomoose geomoose
```
    
You can then login using:

	`ssh root@[ipaddress] -p DOCKER_22_PORT`

### For Development

This will start the image in the 'foreground' and map the local GeoMOOSE directory to where it is expected by the image:
```
    sudo docker run -p 127.0.0.1:8080:80 --rm=true -v [LOCAL_GEOMOOSE_PATH]:/usr/local/geomoose --name geomoose_dev geomoose
```

## Image active users

The root password is `toor`.

## Data Sources

* U.S. Census TIGER Shapefiles are provided for places in the state of Minnesota.  For more information see [here](https://www.census.gov/geo/maps-data/data/tiger-line.html).  The files included here were downloaded on 10 May 2016 from [this url](ftp://ftp2.census.gov/geo/tiger/TIGER2015/PLACE/tl_2015_27_place.zip).


