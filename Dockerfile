FROM ubuntu:18.04
MAINTAINER Jordi Prats

# TODO
# http://label-schema.org/rc1/#build-time-labels
LABEL org.label-schema.vendor="" \
      org.label-schema.url="https://github.com/NTTCom-MS" \
      org.label-schema.name="puppetdb" \
      org.label-schema.license="" \
      org.label-schema.version="5.5.6"\
      org.label-schema.vcs-url="https://github.com/NTTCom-MS/docker-puppetmaster5" \
      org.label-schema.vcs-ref="" \
      org.label-schema.build-date="2018-10-05T16:00:00.52Z" \
      org.label-schema.schema-version="1.0"

ENV HOME /root
ENV PATH /usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/opt/puppetlabs/bin:/opt/puppetlabs/puppet/bin:/opt/puppet-masterless:/root/bin

#
# timezone and locale
#
RUN echo "Europe/Andorra" > /etc/timezone && \
	dpkg-reconfigure -f noninteractive tzdata

RUN export LANGUAGE=en_US.UTF-8 && \
	export LANG=en_US.UTF-8 && \
	export LC_ALL=en_US.UTF-8 && \
	locale-gen en_US.UTF-8 && \
	DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales

RUN DEBIAN_FRONTEND=noninteractive apt-get update

#
# basics
#

RUN DEBIAN_FRONTEND=noninteractive apt-get install gcc -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install make -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install wget -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install strace -y


RUN DEBIAN_FRONTEND=noninteractive apt-get install git -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install supervisor -y

RUN mkdir -p /usr/local/src

# puppet
RUN DEBIAN_FRONTEND=noninteractive apt-get install puppet -y

# puppet-masterless
RUN mkdir -p /usr/local/src/puppet-masterless
RUN git clone https://github.com/jordiprats/puppet-masterless.git /usr/local/src/puppet-masterless

RUN mkdir -p /usr/local/src/localpuppetmaster/master

COPY saltmaster.pp /usr/local/src/localpuppetmaster/

# eyp-saltstack
RUN /bin/bash /usr/local/src/puppet-masterless/localpuppetmaster.sh -d /usr/local/src/localpuppetmaster/master eyp-saltstack

# eyp-pam & puppet apply
RUN /bin/bash /usr/local/src/puppet-masterless/localpuppetmaster.sh -d /usr/local/src/localpuppetmaster/master -s /usr/local/src/localpuppetmaster/saltmaster.pp eyp-pam

# When starting up, salt minions connect _back_ to a master defined in the minion config file.
# The connect to two ports on the master:
#   TCP: 4505 This is the connection to the master Publisher. It is on this port that the minion receives jobs
#     from the master.
#   TCP: 4506 This is the connection to the master ReqServer. It is on this port that the minion sends job
#     results back to the master.

COPY runme.sh /usr/local/bin/runme.sh
RUN chmod +x /usr/local/bin/runme.sh

EXPOSE 4505 4506

CMD /usr/bin/salt-master
