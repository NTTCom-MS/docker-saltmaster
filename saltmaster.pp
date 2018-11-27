class { 'saltstack::master':
  manage_service => false,
}

saltstack::master::fileroot { 'base':
  files => [ '/srv/salt-data/base' ],
}

saltstack::master::pillar { 'base':
  files => [ '/srv/salt-data/pillar' ],
}

class { 'saltstack::cloud': }

class { 'saltstack::api':
  manage_service => false,
}

class { 'saltstack::syndic': }

saltstack::master::key { $::fqdn:
  status => 'accepted'
}

saltstack::master::acl { 'saltuser':
  match => [ '.*', '@runner' ],
}

saltstack::master::acl { 'saltuser2':
  match => [ '.*', '@runner' ],
}

class { 'pam': }

pam::limit { 'nofile *':
  domain => '*',
  item => 'nofile',
  value => '123456',
}
