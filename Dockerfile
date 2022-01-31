# we can setup and use a non-root user while building the image.
# however, most of the time, the use-cases do not need to have an actual non-root user
# defined within the image.
# if there are files generated/created from within a running container, then the files will
# have the permissions according to the user running the executable in the container which is
# generating the files.
# if these files need to be used on the HOST machine, for example they are binary files generated
# from a toolchain on the docker container, they need to be used further or flashed using the HOST
# then it is good to have the permissions on such files match the user running the container on the 
# HOST machine itself.
# Toward this end, while running the docker container, we pass in the UID/GID that we wish to run as.
# This does not need any changes in the Dockerfile, and it is easier to let all the steps in the Dockerfile
# run as root user, so we have all the permissions available at this point.
# Note that, the entrypoint script will run as the user specified while running the container itself.



# use focal 20.04 as runner
FROM ubuntu:20.04 AS gharial_runner

# inputs to use while building the docker image: the release script
# default script if not passed in:
ARG GHARIAL_RELEASE_SCRIPT="release-artifacts/gharial_release_31_Dec_2021_12_08_54.sh"

# use bash as the default shell instead of sh
SHELL ["/bin/bash", "-c"]

# https://serverfault.com/questions/949991/how-to-install-tzdata-on-a-ubuntu-docker-image
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ='Asia/Kolkata'

# dependencies
RUN apt-get update && apt-get install -y wget

# setup a root password 'docker' for debugging
RUN echo 'root:docker' | chpasswd

# Set up non-root user with uid, gid 1000 as it is the most common value for most Linux distros
#RUN groupadd -g 1000 gharialrunner \
#    && useradd -m -u 1000 -g gharialrunner gharialrunner

# set the HOME and USER env variables
#ENV HOME=/home/gharialrunner
#ENV USER=gharialrunner

# switch to non-root user
#USER gharialrunner

# copy the release script
RUN mkdir /gharial
COPY ./${GHARIAL_RELEASE_SCRIPT} /gharial/

# world rw permissions so that we can execute with userid:groupid same as user from HOST, if needed
#RUN ls -ll /gharial
RUN chmod ugo+rwx /gharial
RUN chmod ugo+rwx /gharial/${GHARIAL_RELEASE_SCRIPT}

# set ENV variables
ENV PATH=/gharial:$PATH
#RUN echo $PATH


# default ENTRYPOINT + CMD
# control the CMD using the docker run command - wrapper scripts to provide examples
COPY ./gharial_entrypoint.sh /
RUN chmod ugo+x /gharial_entrypoint.sh


# switch to non-root user before starting to run
#USER gharialrunner

# connect the docker image to the github repo:
# https://docs.github.com/en/packages/learn-github-packages/connecting-a-repository-to-a-package#connecting-a-repository-to-a-container-image-using-the-command-line
LABEL org.opencontainers.image.source=https://github.com/coolbreeze413/gharial

ENTRYPOINT ["/gharial_entrypoint.sh"]

CMD ["gharial_release"]
