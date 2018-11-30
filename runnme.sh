#!/bin/bash

#
# prepare environment
#
if [ ! -z "${INIT_SALT_REPOS}"];
then
  cd /srv/salt-data
  for gitrepo in ${INIT_SALT_REPOS};
  do
    git clone $gitrepo;
  done
  cd -
fi

#
# launch saltmaster
#
exec /usr/bin/supervisord -c /etc/supervisord.conf -n
