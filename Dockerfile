# Use phusion/baseimage as base image. To make your builds reproducible, make
# sure you lock down to a specific version, not to `latest`!
# https://github.com/phusion/baseimage-docker
# See https://github.com/phusion/baseimage-docker/blob/master/Changelog.md for
# a list of version numbers.
FROM phusion/baseimage:0.9.18

MAINTAINER Pawan Kumar <pawan.kumar@gmail.com>

# Set correct environment variables.
ENV HOME /root

# Fix for $HOME:
RUN echo /root > /etc/container_environment/HOME

# Set the locale
RUN locale-gen en_US.UTF-8 && echo 'LANG="en_US.UTF-8"' > /etc/default/locale
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Regenerate SSH host keys. baseimage-docker does not contain any, so you
# have to do that yourself. You may also comment out this instruction; the
# init system will auto-generate one during boot.
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get install -y build-essential && \
  apt-get install -y software-properties-common && \
  apt-get install -y byobu curl git htop man unzip vim wget sed original-awk gawk ca-certificates rpl pwgen && \
  add-apt-repository -y ppa:webupd8team/java

# Add files.
ADD scripts/.bashrc /root/.bashrc
ADD scripts/.gitignore /root/.gitignore
#ADD ~/root/.scripts /root/.scripts

RUN sudo apt-get update && \ 
  sudo echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  sudo apt-get -y install oracle-java8-installer && \
  sudo apt-get install -y oracle-java8-set-default && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /tmp/* && \
  rm -rf /var/tmp/* && \
  rm -rf /var/cache/oracle-jdk8-installer

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

VOLUME ["/opt/workspace"]

CMD ["/bin/bash"]
