# Etherpad-Lite Dockerfile
#
# https://github.com/ether/etherpad-docker
#
# Developed from a version by Evan Hazlett at https://github.com/arcus-io/docker-etherpad 
#
# Version 1.0

# Use Docker's nodejs, which is based on ubuntu
FROM node:latest
MAINTAINER John E. Arnold, iohannes.eduardus.arnold@gmail.com

# Get Etherpad-lite's other dependencies
RUN apt-get update
RUN apt-get install -y gzip git-core curl python libssl-dev pkg-config build-essential supervisor
RUN echo "mysql-server mysql-server/root_password simplepass" | debconf-set-selections && \
    echo "mysql-server mysql-server/root_password_again simplepass" | debconf-set-selections && \
    apt-get install -y mysql-server
# for debug
RUN apt-get install -y vim

# create db
RUN /bin/bash -c "/usr/bin/mysqld_safe &" && \
    sleep 5 && \
    mysql -u root -p simplepass -e "CREATE DATABASE store"

# Grab the latest Git version
RUN cd /opt && git clone https://github.com/ether/etherpad-lite.git etherpad

# Install node dependencies
RUN /opt/etherpad/bin/installDeps.sh

# Add conf files
ADD settings.json /opt/etherpad/settings.json
ADD supervisor.conf /etc/supervisor/supervisor.conf

EXPOSE 9001
CMD ["/usr/bin/mysqld_safe"]
CMD ["supervisord", "-c", "/etc/supervisor/supervisor.conf", "-n"]
