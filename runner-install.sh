#!/bin/bash

# Installing make-profiler
sudo apt update -y && sudo apt upgrade -y 
sudo apt install -y python3-pip graphviz gawk
pip3 install slack slackclient
sudo pip3 install https://github.com/konturio/make-profiler/archive/master.zip
sudo apt-get install -y cmake
sudo apt install -y unzip
sudo apt-get -y install python3-boto3 python3-botocore # amazon.aws.aws_s3
sudo apt-get install -y cron
sudo apt install -y osmium-tool
sudo apt-get install -y parallel pigz jq zip pbzip2
sudo apt-get install -y libtiff-dev libcurl4-openssl-dev
sudo apt install -y golang-go
sudo apt-get install -y pspg

# Installing aria2 pyosmium (osm dump downloader)
sudo apt install -y aria2
sudo apt install -y pyosmium

# installing proj
sudo apt-get install -y proj-bin

# Install gdal
sudo apt-get install -y liblcms2-dev libtiff-dev libpng-dev libz-dev libjson-c-dev libpq-dev libgdal30 python3-gdal libgeotiff-dev liblz4-dev liblcms2-dev 
sudo apt-get install -y gdal-bin

# python-is-python3 is a convenient way to set up a symlink for /usr/bin/python, pointing to /usr/bin/python3
sudo apt install -y python-is-python3

# osm
pip3 install osmnx geopandas pandas pathlib

# healtsites 
pip3 install coreapi