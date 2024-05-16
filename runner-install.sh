#!/bin/bash

# Installing make-profiler
apt install -y python3-pip graphviz gawk

pip3 install https://github.com/konturio/make-profiler/archive/master.zip
apt-get install -y cmake
apt install -y unzip
apt-get -y install python3-boto3 python3-botocore # amazon.aws.aws_s3
apt-get install -y cron

# python-is-python3 is a convenient way to set up a symlink for /usr/bin/python, pointing to /usr/bin/python3
apt install -y python-is-python3

# osm
pip3 install osmnx geopandas pandas pathlib

# healtsites 
pip3 install coreapi
