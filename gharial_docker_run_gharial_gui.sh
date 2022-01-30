#! /bin/bash 

# directly run the appropriate program using CMD, in this case gharial_release
# pass in a 'workdir' and 'image' to use
# the HOST 'workdir' is mapped onto /gharial/workdir in the container

HOST_WORKDIR=""
GHARIAL_IMAGE=""
IMAGE_WORKDIR="/gharial/workdir"

# getopt based parsing

# option strings
SHORT=w:i:
LONG=workdir:,gharial-image:

# read the options
OPTS=$(getopt --options $SHORT --long $LONG --name "$0" -- "$@")

if [ $? != 0 ] ; then echo "ERROR: failed to parse options...exiting." >&2 ; exit 1 ; fi

eval set -- "$OPTS"

# extract options and their arguments into variables
while true ; do
  case "$1" in
    -w | --workdir )
      HOST_WORKDIR="$2"
      shift 2
      ;;
    -i | --gharial-image )
      GHARIAL_IMAGE="$2"
      shift 2
      ;;
    -- )
      shift
      break
      ;;
    *)
      echo "OOPS!"
      exit 1
      ;;
  esac
done


if [ -z "${HOST_WORKDIR}" ] ; then echo "ERROR: please specify a HOST workdir with --workdir" >&2 ; exit 1 ; fi
if [ -z "${GHARIAL_IMAGE}" ] ; then echo "ERROR: please specify the docker image with --gharial-image" >&2 ; exit 1 ; fi

echo "mapping HOST workdir: $HOST_WORKDIR to $IMAGE_WORKDIR"
echo "running IMAGE: $GHARIAL_IMAGE"

# automatically find the XAUTHORITY file on the HOST
XAUTHORITY=$(xauth info | grep "Authority file" | awk '{ print $3 }')

docker run -it --rm --cap-drop=all \
    --net=host \
    --env DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
    -v $XAUTHORITY:/home/gharialrunner/.Xauthority:ro \
    -v $HOST_WORKDIR:$IMAGE_WORKDIR \
    --volume="/etc/group:/etc/group:ro" \
    --volume="/etc/passwd:/etc/passwd:ro" \
    --volume="/etc/shadow:/etc/shadow:ro" \
    --user=$(id -u):$(id -g) \
    --env HOST_UID=$(id -u) \
    --env HOST_GID=$(id -g) \
    --env TERM=xterm-256color \
    $GHARIAL_IMAGE \
    gharial_release
