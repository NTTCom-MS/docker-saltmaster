FROM centos:centos7
MAINTAINER Jordi Prats

RUN yum install git which wget supervisor net-tools -y

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

COPY supervisor/saltmaster /etc/supervisord.d/
COPY supervisor/saltapi /etc/supervisord.d/

EXPOSE 4505 4506

CMD /usr/bin/salt-master
