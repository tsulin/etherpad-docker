# Etherpad-Lite Dockerfile
#
# https://github.com/ether/etherpad-docker
#
# Developed from a version by Evan Hazlett at https://github.com/arcus-io/docker-etherpad 
#
# Version 1.0

# Use Docker's nodejs, which is based on ubuntu
FROM node:latest
MAINTAINER Sid Qu, sid.qulin@gmail.com

# add ubuntu mirror to speed up
# RUN mv /etc/apt/sources.list /tmp/ && echo "deb mirror://mirrors.ubuntu.com/mirrors.txt precise main restricted universe multiverse" > /etc/apt/sources.list && \
#     echo "deb mirror://mirrors.ubuntu.com/mirrors.txt precise-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
#     echo "deb mirror://mirrors.ubuntu.com/mirrors.txt precise-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
#     echo "deb mirror://mirrors.ubuntu.com/mirrors.txt precise-security main restricted universe multiverse" >> /etc/apt/sources.list && \
#     cat /tmp/sources.list >> /etc/apt/sources.list && rm /tmp/sources.list

# Get Etherpad-lite's other dependencies
RUN apt-get update
RUN apt-get install -y --force-yes gzip git-core curl python libssl-dev pkg-config build-essential supervisor
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes mysql-server
# for debug
RUN apt-get install -y --force-yes vim

# create db

RUN echo "mysqld_safe &" > /tmp/config \
    && echo "mysqladmin --silent --wait=30 ping || exit 1" >> /tmp/config \
    && echo "mysql -u root -e \"CREATE DATABASE store\"" >> /tmp/config \
    && bash /tmp/config \
    && rm -f /tmp/config
    
# Grab the latest Git version
RUN cd /opt && git clone https://github.com/ether/etherpad-lite.git etherpad

# Install node dependencies
RUN /opt/etherpad/bin/installDeps.sh
# mkdir
RUN mkdir /opt/mysql

# Add conf files
ADD settings.json /opt/etherpad/settings.json
ADD supervisor.conf /etc/supervisor/supervisor.conf

EXPOSE 9001
CMD ["supervisord", "-c", "/etc/supervisor/supervisor.conf", "-n"]
