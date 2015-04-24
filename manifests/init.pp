# == Class: role_nbcdata
#
#
# === Authors
#
# Author Name <foppe.pieters@naturalis.nl>
#
#
class role_nbcdata (
  $docroot                                = '/var/www/htdocs',
  $gitrepos                               =
    [
  {'datamignbc' => {
            'reposource'   => 'git@github.com:naturalis/datamigratie_nbc.git',
            'repokey'      => 'PRIVATE KEY here',
          },
        },
#  {'qawnbc' => {
#            'reposource'   => 'git@github.com:naturalis/qaw.git',
#            'repokey'      => 'PRIVATE KEY here',
#   },
# },
    ],
  $webdirs                                = ['/var/www/htdocs'],
  $rwwebdirs                              = ['/var/www/htdocs/cache'],
  $php_memory_limit                       = '512M',
  $upload_max_filesize                    = '256M',
  $post_max_size                          = '384M',
  $max_execution_time                     = '-1',
  $max_input_vars                         = '3000',
  $max_input_time                         = '6000',
  $xdebug_max_nesting_level               = '500',
  $extra_packages                         = ['unixodbc','freetds-common','tdsodbc','php5-mssql','php5-xdebug'],
  $enable_mysql                           = true,
  $enable_phpmyadmin                      = true,
  $mysql_root_password                    = 'rootpassword',
  $mysql_manage_config_file               = true,
  $mysql_key_buffer_size                  = 64M,
  $mysql_query_cache_limit                = 2M,
  $mysql_query_cache_size                 = 64M,
  $mysql_innodb_buffer_pool_size          = 512M,
  $mysql_innodb_additional_mem_pool_size  = 512M,
  $mysql_innodb_log_buffer_size           = 256M,
  $mysql_max_connections                  = 500,
  $mysql_max_heap_table_size              = 512M,
  $mysql_lower_case_table_names           = undef,  # nog een probleem
  $mysql_innodb_file_per_table            = ON,
  $mysql_tmp_table_size                   = 512M,
  $mysql_table_open_cache                 = 450,
  $mysql_sql_mode                         = 'TRADITIONAL',
  $mysql_long_query_time                  = 5,
  $mysql_character_set_server             = 'utf8',
  $mysql_collation_server                 = 'utf8_general_ci',

  $instances                              =
        {'nbcdata.naturalis.nl' => {
          'serveraliases'   => '*.naturalis.nl',
          'docroot'         => '/var/www/htdocs',
          'directories'     => [{ 'path' => '/var/www/htdocs', 'options' => '-Indexes +FollowSymLinks +MultiViews', 'allow_override' => 'All' },{ 'path' => '/var/www/htdocs/qaw/public', 'options' => '+Indexes +FollowSymLinks +MultiViews', 'allow_override' => 'All' }],
          'port'            => 80,
          'serveradmin'     => 'webmaster@naturalis.nl',
          'priority'        => 10,
          },
        },
  $keepalive                            = 'On',
  $max_keepalive_requests               = '100',
  $keepalive_timeout                    = '1500',
){

    file { $webdirs:
      ensure                  => 'directory',
      mode                    => '0750',
      owner                   => 'root',
      group                   => 'www-data',
      require                 => Class['apache']
    }->
    file { $rwwebdirs:
      ensure                  => 'directory',
      mode                    => '0777',
      owner                   => 'www-data',
      group                   => 'www-data',
      require                 => File[$webdirs]
    }

# index and info page
    file { '/var/www/htdocs/index.php':
      ensure                => present,
      mode                  => '0644',
      content               => template('role_nbcdata/index.php.erb'),
      require               => File[$webdirs]
    }
    file { '/var/www/htdocs/info.php':
      content => '<?php phpinfo(); ?>',
    }

# install php module php-gd
  php::module { [ 'gd','mysql','curl' ]: }

  php::ini { '/etc/php5/apache2/php.ini':
    memory_limit              => $php_memory_limit,
    upload_max_filesize       => $upload_max_filesize,
    post_max_size             => $post_max_size,
    max_execution_time        => $max_execution_time,
    max_input_vars            => $max_input_vars,
    max_input_time            => $max_input_time,
  }
  file { '/etc/php5/mods-available/xdebug.ini':
    ensure                    => present,
    content                   => template('role_nbcdata/xdebug.ini.erb'),
    require                   => [Package[$extra_packages]]
    }

# Install apache and enable modules
  class { 'apache':
    default_mods              => true,
    mpm_module                => 'prefork',
    keepalive                 => $keepalive,
    max_keepalive_requests    => $max_keepalive_requests,
    keepalive_timeout         => $keepalive_timeout,
  }

  include apache::mod::php
  include apache::mod::rewrite
  include apache::mod::speling

# Create instances (vhosts)
  class { 'role_nbcdata::instances':
      instances               => $instances,
  }

# Configure MySQL Security and finetuning if needed
  if $enable_mysql {
    class { 'mysql::server::account_security':}
    class { 'mysql::server':
        root_password         => $mysql_root_password,
        service_enabled       => true,
        service_manage        => true,
        manage_config_file    => $mysql_manage_config_file,
        override_options      => {
          'mysqld'            => {
            'key_buffer_size'                 => $mysql_key_buffer_size,
            'query_cache_limit'               => $mysql_query_cache_limit,
            'query_cache_size'                => $mysql_query_cache_size,
            'innodb_buffer_pool_size'         => $mysql_innodb_buffer_pool_size,
            'innodb_additional_mem_pool_size' => $mysql_innodb_additional_mem_pool_size,
            'innodb_log_buffer_size'          => $mysql_innodb_log_buffer_size,
            'max_connections'                 => $mysql_max_connections,
            'max_heap_table_size'             => $mysql_max_heap_table_size,
            'lower_case_table_names'          => $mysql_lower_case_table_names,
            'innodb_file_per_table'           => $mysql_innodb_file_per_table,
            'tmp_table_size'                  => $mysql_tmp_table_size,
            'table_open_cache'                => $mysql_table_open_cache,
            'sql_mode'                        => $mysql_sql_mode,
            'long_query_time'                 => $mysql_long_query_time,
            'character_set_server'            => $mysql_character_set_server,
            'collation_server'                => $mysql_collation_server,

          }
        }
    }
  }

# General repo settings
  class { 'role_nbcdata::repogeneral': }

# Check out repositories
  create_resources('role_nbcdata::repo', $gitrepos)

# make symlink
  file { '/var/www/htdocs/crs':
    ensure => 'link',
    target => '/opt/git/datamignbc/QAW/Web',
  }
#  file { '/var/www/htdocs/qaw':
#    ensure => 'link',
#    target => '/opt/git/qawnbc',
#  }

# install extra packages
  package { $extra_packages:
    ensure => installed,
  }

# setup odbc
  file { '/etc/odbc.ini':
    ensure                => present,
    mode                  => '0644',
    content               => template('role_nbcdata/odbc.ini.erb'),
    require               => [Package[$extra_packages]]
  }
  file { '/etc/odbcinst.ini':
    ensure                => present,
    mode                  => '0644',
    content               => template('role_nbcdata/odbcinst.ini.erb'),
    require               => [Package[$extra_packages]]
  }
  file { '/etc/freetds/freetds.conf':
    ensure                => present,
    mode                  => '0644',
    content               => template('role_nbcdata/freetds.conf.erb'),
    require               => [Package[$extra_packages]]
  }

# Install and configure phpMyadmin
  if $enable_phpmyadmin {
    class { 'role_nbcdata::phpmyadmin': }
  }
}
