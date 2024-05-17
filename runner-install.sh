#!/bin/bash

# Installing make-profiler
apt install -y python3-pip graphviz gawk
pip3 install slack slackclient
pip3 install https://github.com/konturio/make-profiler/archive/master.zip
apt-get install -y cmake
apt install -y unzip
apt-get -y install python3-boto3 python3-botocore # amazon.aws.aws_s3
apt-get install -y cron

apt install -y osmium-tool
apt-get install -y parallel pigz jq zip pbzip2
apt-get install -y libtiff-dev libcurl4-openssl-dev
apt install -y golang-go
apt-get install -y pspg

# Installing aria2 pyosmium (osm dump downloader)
apt install -y aria2
apt install -y pyosmium

# installing proj
apt-get install -y proj-bin

# Install gdal
apt-get install -y liblcms2-dev libtiff-dev libpng-dev libz-dev libjson-c-dev libpq-dev libgdal30 python3-gdal libgeotiff-dev liblz4-dev liblcms2-dev 
apt-get install -y gdal-bin

# python-is-python3 is a convenient way to set up a symlink for /usr/bin/python, pointing to /usr/bin/python3
apt install -y python-is-python3

# osm
pip3 install osmnx geopandas pandas pathlib

# healtsites 
pip3 install coreapi
