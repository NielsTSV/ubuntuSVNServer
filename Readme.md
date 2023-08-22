# SVN server Docker deployment
This repo shows you how to deploy an svn server on a ubuntu image, and how to expose it to your local machine. This test case simulates the environment of an SVN server deployed on Linux server. This tutorial is based on the ubuntu documentation (https://help.ubuntu.com/community/Subversion).

First the steps will be given to setup the server, thereafter the docker file and other files will be explained.

## Steps Server Setup

1. Start up docker container
    - Run *`sh run_docker_server.sh`*
    - Or run lines in *`sh run_docker_server.sh`* manually
2. Run *`/etc/init.d/apache2 restart`* in the container to      restart the apache2 web server
3. Create a user and password with *`htpasswd -c /etc/subversion/passwd user_name`*
4. Login over http://localhost/svn/, where *`helloworld.py`* will be displayed.



## Docker Image
Get a ubuntu image for amd64. Since upgrade binaries are only available for amd64, add --platform=linux/amd64 when trying to upgrade svn version on an arm64 architecture.
```
FROM --platform=linux/amd64 ubuntu:20.04 
```

Set non-interactive package installation, as some installation may user require input, halting the docker container creation.
```
ENV DEBIAN_FRONTEND noninteractive
```

Install standard Ubuntu packages
```
RUN apt-get update && apt-get install -y curl && \
    apt-get install -y vim && apt-get install -y wget
```

Install subversion and apache2 packages
```
RUN apt-get install -y subversion && apt-get install -y apache2 && \
    apt-get install -y apache2-utils && apt-get install libapache2-mod-svn
```

Copy in deployment files containing *dav_svn.conf* and *dav_svn.conf* (explained below).
```
COPY deployment_files /home/deployment_files
```
The http configuration is stored in *dav_svn.conf*. The ubuntu repo stored in *SVNPath /home/svn/svnrepo* will be published in *<Location /svn>*, so localhost/svn. 

<sup>Note that only a single repo is published, to publish mutiple repos see https://help.ubuntu.com/community/Subversion. <sup>
```
RUN cat home/deployment_files/dav_svn.conf > etc/apache2/mods-available/dav_svn.conf
```

The following script creates a repo in */home/svn/svnrepo*, checks out a working copy in */home/workingcopy/*, adds a helloworld.py to the repo and commits it.
```
RUN bash home/deployment_files/subversion_project_setup.sh
```

Expose port for means of connection. Port 80 is used for regular webdav protocol (http://localhost/svn), port 3690 can be used for the custom protocol (svn://localhost:3690)
```
EXPOSE 80
```

## subversion_project_setup.sh
This script setups a basic svn repo with hello-world.py. It creates a repo in /home/svn/svnrepo, checks out a working copy in /home/workingcopy/, adds a helloworld.py to the repo and commits it.

## dav_svn.conf
The http configuration is stored in *dav_svn.conf*. The ubuntu repo stored in *SVNPath /home/svn/svnrepo* will be published in *<Location /svn>*, so localhost/svn. For more info see https://help.ubuntu.com/community/Subversion. 

## run/stop_docker_server.sh
These files automate the docker process (build/expose/run), as well as remove all images and container after finishing the test.
