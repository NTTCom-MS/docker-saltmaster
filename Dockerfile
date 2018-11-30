FROM centos:centos7
MAINTAINER Jordi Prats

# TODO
# http://label-schema.org/rc1/#build-time-labels
LABEL org.label-schema.vendor="" \
      org.label-schema.url="https://github.com/NTTCom-MS" \
      org.label-schema.name="saltmaster" \
      org.label-schema.license="" \
      org.label-schema.version="0.1.10"\
      org.label-schema.vcs-url="https://github.com/NTTCom-MS/docker-saltmaster" \
      org.label-schema.vcs-ref="" \
      org.label-schema.build-date="2018-11-30T10:00:00.52Z" \
org.label-schema.schema-version="1.0"

ENV HOME /root

# update current base

RUN yum clean all
RUN yum update -y

# basics

RUN yum install git which wget net-tools epel-release -y

RUN mkdir -p /usr/local/src

# puppet
RUN rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
RUN yum install puppet-agent -y

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

# supervisor conf

RUN yum install supervisor -y

COPY supervisor/saltmaster.ini /etc/supervisord.d/
COPY supervisor/saltapi.ini /etc/supervisord.d/

RUN bash -c 'if [ -s /var/run/supervisor/supervisor.sock ]; then unlink /var/run/supervisor/supervisor.sock; fi'

EXPOSE 4505 4506

CMD /usr/bin/supervisord -c /etc/supervisord.conf
