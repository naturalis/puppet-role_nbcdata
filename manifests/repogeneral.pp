# == Class: role_nbcdata::repogeneral
#
# === Authors
#
# Author Name <hugo.vanduijn@naturalis.nl>
#
#
class role_nbcdata::repogeneral ()
{

# ensure git package for repo checkouts
  package { 'git':
    ensure => installed,
  }

# copy known_hosts.sh file from puppet module
  file { '/usr/local/sbin/known_hosts.sh' :
    ensure    => present,
    mode      => '0750',
    group     => 'git',
    source    => 'puppet:///modules/role_nbcdata/known_hosts.sh'
  }

# create group git
  group { 'git':
    ensure    => present
  }

# create /opt/git
  file { '/opt/git':
    ensure      => directory,
    mode        => '0775',
    group       => 'git',
    require     => Group['git']
  }

}


