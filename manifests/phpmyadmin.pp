# Install phpmyadmin
class role_nbcdata::phpmyadmin ()
{
  package { 'phpmyadmin':
    ensure                  => 'installed',
    require                 => Package['apache2'],
    notify                  => Exec['link-phpmyadmin', 'enable-mcrypt'],
  }
  exec { 'link-phpmyadmin':
    command                 => 'ln -sf /usr/share/phpmyadmin /var/www/htdocs/phpmyadmin',
    path                    => ['/bin'],
    require                 => File['/var/www/htdocs'],
    refreshonly             => true,
  }
  exec { 'enable-mcrypt':
  command                   => 'php5enmod mcrypt',
  path                      => ['/bin', '/usr/bin', '/usr/sbin'],
  require                   => Package['phpmyadmin', 'apache2'],
  refreshonly               => true,
  notify                    => Service['apache2'],
}
}
