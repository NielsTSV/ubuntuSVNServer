# script to launch docker container expose ports
docker build --platform linux/amd64 -t ubuntu_svn_image:20.04 .
docker run -d -p 80:80 -p 3690:3690 --name ubuntu_svn_container ubuntu_svn_image:20.04
docker exec -it ubuntu_svn_container /bin/bash