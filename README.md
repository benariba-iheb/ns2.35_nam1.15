![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/benariba-iheb/ns2.35_nam1.15) | ![Docker Image Size](https://img.shields.io/docker/image-size/prometh1us/ns2.35_nam1.15)

make sure to enable access to xhost for docker

xhost +local      			#this will allow access by any

xhost +local:docker     

-------------------------------------------------------------
using docker-compose:

- install the docker-compose file to your working directory

- start the simulator as root (or make sure your user has access to /tmp/.X11-unix/) and make sure to inc>

- run the compose in the same directory as the compose-file:
#> docker-compose up -d

-attach to the container:
#> docker attach ns2-simulator

---------------------------------------------------------------
using docker:

start the simulator as root (or make sure your user has access to /tmp/.X11-unix/) and make sure to include the DISPLAY env-variable as an argument:

docker run -it --rm \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v /tmp/.Xauthority_docker:/root/.Xauthority:ro \
  -v "$(pwd)/simulations:/simulations:rw" \		# (optional) links a directory from the hosts user to the container for data persistance
  -v "$(pwd)/results:/results:rw" \ 			# (optional) links a directory from the host's user to the container for data persistance
  prometh1us/ns2.35_nam1.15:latest

- test if you have access to the graphical interface by running an x-app:
#> xclock

!!if the clock does not lunch from the container. it means the container still does not have access to the x11 library!! 



!!if the clock does not lunch from the container. it means the container still does not have access to the X11 Unix socket for GUI display!!
