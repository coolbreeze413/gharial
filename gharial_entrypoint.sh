#!/bin/bash

# entrypoint references:
# 1. https://stackoverflow.com/a/48096779/3379867
# 2. https://docs.docker.com/engine/reference/run/#cmd-default-command-or-options

# exit script if any command fails with non-zero return value, terminates the docker container.
set -e

printf "\n\ngharial entrypoint script\n\n"


# add directory to PATH (already set from the Dockerfile in ENV)
#export PATH="/gharial/:${PATH}"
printf "PATH: ${PATH}\n\n"


# create symlink as 'gharial_release' to the release script
GHARIAL_RELEASE_SCRIPT_NAME=$(cd /gharial && ls gharial_release_*.sh)
printf "RELEASE_SCRIPT: ${GHARIAL_RELEASE_SCRIPT_NAME}\n\n"
# ln -s "TO" "FROM"
ln -v -s "/gharial/${GHARIAL_RELEASE_SCRIPT_NAME}" "/gharial/gharial_release"

# debug print
printf "running as:\n$(id)\n\n"

printf "\ndebug--------\n"
ls -ll | grep gharial
ls -ll /gharial
printf "debug--------\n\n"

# replace shell with CMD passed in as default process PID 1, so that the process can still get a SIGTERM on container close.
printf "exec: $@\n\n"

exec "$@"
