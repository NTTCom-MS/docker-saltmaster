class { 'saltstack::master':
  manage_service => false,
}

saltstack::master::fileroot { 'base':
  files => [ '/srv/salt-data/base' ],
}

saltstack::master::pillar { 'base':
  files => [ '/srv/salt-data/pillar' ],
}

saltstack::master::key { $::fqdn:
  status => 'accepted'
}

saltstack::master::acl { 'saltuser':
  match => [ '.*', '@runner' ],
}

saltstack::master::acl { 'saltuser2':
  match => [ '.*', '@runner' ],
}

class { 'saltstack::cloud': }

class { 'saltstack::minion':
  master         => '127.0.0.1',
  manage_service => false,
}

->

class { 'saltstack::api':
  manage_service => false,
}

class { 'pam': }

pam::limit { 'nofile *':
  domain => '*',
  item => 'nofile',
  value => '123456',
}
