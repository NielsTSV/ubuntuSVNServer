# Use the official Ubuntu 20.04 base image
FROM --platform=linux/amd64 ubuntu:20.04 

# Set non-interactive package installation
ENV DEBIAN_FRONTEND noninteractive

# Update and install standard ubuntu packages
RUN apt-get update && apt-get install -y curl && \
    apt-get install -y vim && apt-get install -y wget

# Update and install subversion & apache packages
RUN apt-get install -y subversion && apt-get install -y apache2 && \
    apt-get install -y apache2-utils && apt-get install libapache2-mod-svn

# Create required files and directories
RUN mkdir /home/svn/ && touch /etc/subversion/passwd 

# Copy in deployment file
COPY deployment_files /home/deployment_files

# add webdav conf to http file
RUN cat home/deployment_files/dav_svn.conf > etc/apache2/mods-available/dav_svn.conf

# setup svn server
RUN bash home/deployment_files/subversion_project_setup.sh

# create user
# /etc/init.d/apache2 restart
# RUN htpasswd -c /etc/subversion/passwd user_name password

EXPOSE 80

CMD ["sleep", "infinity"]
