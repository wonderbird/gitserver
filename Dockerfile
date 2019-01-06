# git server
#
# To run this container, please specify the AUTHORIZED_KEYS environment variable
# on the command line. The docker-entrypoint.sh script will replace the file
# /home/git/.ssh/authorized_keys with the contents of this environment variable.
#
# Example:
# $ docker run -it --rm --name git --env AUTHORIZED_KEYS=<some_keys> git
#
# If you would like to run the container and connect a shell to it, then you
# can simply pass "/bin/sh" to the docker command line. This will instruct
# docker-entrypoint.sh to run the "/bin/sh" command instead of /usr/bin/top.
#
# Example:
# $ docker run -it --rm --name git --env AUTHORIZED_KEYS=<some_keys> git /bin/sh
#
FROM alpine:latest

LABEL maintainer="Stefan.Boos@gmx.de"

ENV AUTHORIZED_KEYS # Please set the environment variable AUTHORIZED_KEYS when running the container.

EXPOSE 22/tcp

RUN apk add --no-cache bash coreutils
RUN apk add --no-cache git

#####
# Set up the git user and the associated group
#
# The git user may not log in and has no password
#####
RUN addgroup -S git \
    && adduser -S -s /usr/bin/git-shell -g 'Manages git version control' -G git -D -h /home/git git \
    && mkdir /home/git/.ssh \
    && chown git:git /home/git/.ssh \
    && chmod 700 /home/git/.ssh

#####
# Setup and run the docker-entrypoint.sh script
#####
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod u+x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["gitserver"]
