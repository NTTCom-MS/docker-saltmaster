FROM centos:centos7
MAINTAINER Jordi Prats

ENV INIT_SALT_REPOS=""

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

RUN yum install git which wget net-tools epel-release cronie -y

RUN mkdir -p /usr/local/src

# puppet
RUN rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
RUN yum install puppet-agent -y

# puppet-masterless
RUN mkdir -p /usr/local/src/puppet-masterless
RUN git clone https://github.com/jordiprats/puppet-masterless.git /usr/local/src/puppet-masterless

RUN mkdir -p /usr/local/src/localpuppetmaster/master

COPY saltmaster.pp /usr/local/src/localpuppetmaster/

# eyp-saltstack && eyp-pam
RUN /bin/bash /usr/local/src/puppet-masterless/localpuppetmaster.sh -d /usr/local/src/localpuppetmaster/master eyp-saltstack
RUN /bin/bash /usr/local/src/puppet-masterless/localpuppetmaster.sh -d /usr/local/src/localpuppetmaster/master eyp-pam

# puppet apply - installation
RUN /bin/bash /usr/local/src/puppet-masterless/localpuppetmaster.sh -d /usr/local/src/localpuppetmaster/master -s /usr/local/src/localpuppetmaster/saltmaster.pp

# When starting up, salt minions connect _back_ to a master defined in the minion config file.
# The connect to two ports on the master:
#   TCP: 4505 This is the connection to the master Publisher. It is on this port that the minion receives jobs
#     from the master.
#   TCP: 4506 This is the connection to the master ReqServer. It is on this port that the minion sends job
#     results back to the master.

# supervisor conf

RUN yum install supervisor -y

COPY supervisor/salt-master.ini /etc/supervisord.d/
COPY supervisor/salt-api.ini /etc/supervisord.d/
COPY supervisor/crond.ini /etc/supervisord.d/
COPY supervisor/puppet-agent.ini /etc/supervisord.d/

RUN bash -c 'if [ -s /var/run/supervisor/supervisor.sock ]; then unlink /var/run/supervisor/supervisor.sock; fi'

COPY runme.sh /usr/bin/runme.sh

EXPOSE 4505 4506 8000

# - create volumes for:
#  * keys and configuration -> /etc/salt
#  * state files -> /srv/salt-data
#  * logs -> /var/log

RUN mkdir -p /srv/salt-data
VOLUME [ "/etc/salt", "/srv/salt-data", "/var/log" ]

CMD /bin/bash /usr/bin/runme.sh
