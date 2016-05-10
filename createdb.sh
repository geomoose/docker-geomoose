#!/bin/bash

psql -c "create user gis with password 'mngislis' login superuser"
psql -c "create database gis with owner gis"
psql "host=localhost dbname=gis user=gis password=mngislis" -c "create extension postgis"

# And LOAD the data!
shp2pgsql -s 4269:4326 -W "LATIN1" -g geom /data/places/tl_2015_27_place.shp minnesota_places | sed -e "s/MULTIPOLYGON/GEOMETRY/" | psql "dbname=gis user=gis password=mngislis host=localhost"
