FROM node:8-alpine

RUN apk add --update \
  rsync \
  python \
  openssh


# docker build . -t node8-rsync-python-ssh
