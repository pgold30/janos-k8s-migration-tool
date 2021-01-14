#Download base image ubuntu 20.04
FROM ubuntu:20.04
# LABEL about the custom image
LABEL maintainer="loschi.pablo@gmail.com"
LABEL version="0.1"
LABEL description="This is custom Docker Image for migrating K8s yaml files to 1.1.6."
# Disable Prompt During Packages Installation
ARG DEBIAN_FRONTEND=noninteractive
# Update Ubuntu Software repository
RUN apt update
# Install nginx, php-fpm and supervisord from ubuntu repository
RUN apt install -y git vim wget tar build-essential apt-utils && \
    rm -rf /var/lib/apt/lists/* && \
    apt clean
#Install Kubeval for K8s validation 
RUN wget https://github.com/instrumenta/kubeval/releases/latest/download/kubeval-linux-amd64.tar.gz && \
    tar xf kubeval-linux-amd64.tar.gz && \
    cp kubeval /usr/local/bin
#Install YQ for yaml parsing 
RUN wget https://github.com/mikefarah/yq/releases/download/v4.3.2/yq_linux_amd64.tar.gz && \
    tar xf yq_linux_amd64.tar.gz && \
    mv yq_linux_amd64 /usr/local/bin/yq
# Copy sh script and define default command for the container
COPY janos.sh /janos.sh
CMD ["./janos.sh"]
