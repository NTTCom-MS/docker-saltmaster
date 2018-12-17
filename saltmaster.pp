class { 'saltstack::repo':
  version       => '2018.3',
  version_minor => '2',
}

class { 'saltstack::master':
  manage_service => false,
  require        => Class['saltstack::repo'],
}

saltstack::master::fileroot { 'base':
  files => [ '/srv/salt-data/base' ],
}

saltstack::master::pillar { 'base':
  files => [ '/srv/salt-data/pillar' ],
}

saltstack::master::key { $::fqdn:
  status => 'deleted'
}

saltstack::master::acl { 'saltuser':
  match => [ '.*', '@runner' ],
}

saltstack::master::acl { 'saltuser2':
  match => [ '.*', '@runner' ],
}

class { 'saltstack::cloud':
  require => Class['saltstack::repo'],
}

class { 'saltstack::minion':
  master         => '127.0.0.1',
  manage_service => false,
  require        => Class['saltstack::repo'],
}

->

class { 'saltstack::api':
  manage_service => false,
  require        => Class['saltstack::repo'],
}

class { 'pam': }

pam::limit { 'nofile *':
  domain => '*',
  item => 'nofile',
  value => '123456',
}
