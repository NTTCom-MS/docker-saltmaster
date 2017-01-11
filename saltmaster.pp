
class { 'saltstack::master':
  manage_service => false,
}

class { 'pam': }

pam::limit { 'nofile *':
  domain => '*',
  item => 'nofile',
  value => '123456',
}
