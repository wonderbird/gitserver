# An ssh server allowing users to push to a git repository.
#
# To run this container, please specify the AUTHORIZED_KEYS environment variable
# on the command line. The docker-entrypoint.sh script will replace the file
# /home/git/.ssh/authorized_keys with the contents of this environment variable.
#
# Further, mount a folder for the repositories to /opt/git in order to keep the
# repositories when rebooting the container.
#
# Example:
# $ docker run -p 8022:22 -it --rm --name git --env AUTHORIZED_KEYS=<some_keys> -v /my/repo/folder:/opt/git gitserver
#
# If you would like to run the container and connect a shell to it, then you
# can simply pass "/bin/sh" to the docker command line. This will instruct
# docker-entrypoint.sh to run the "/bin/sh" command instead of /usr/bin/top.
#
# Example:
# $ docker run -it --rm --name git gitserver /bin/sh
#
FROM alpine:latest

LABEL maintainer="Stefan.Boos@gmx.de"

ENV AUTHORIZED_KEYS # Please set the environment variable AUTHORIZED_KEYS when running the container.

EXPOSE 22/tcp

RUN apk update \
    && apk add --no-cache git \
    	    		  openssh \
#
#####
# Set up the git user and the associated group
#
# docker-entrypoint.sh will configure the account and sshd such that the git
# user can only log in with a key.
#####
#
    && addgroup -S git \
    && adduser -S -s /usr/bin/git-shell -g 'Manages git version control' -G git -h /home/git git \
    && mkdir /home/git/.ssh \
    && chown git:git /home/git/.ssh \
    && chmod 700 /home/git/.ssh \
#
#####
# The git repositories shall be mounted to /opt/git
#####
#
    && mkdir -p /opt/git

#####
# Setup and run the docker-entrypoint.sh script
#####
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod u+x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["gitserver"]
