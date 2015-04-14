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
  $webdirs                                = ['/var/www/htdocs'],
  $rwwebdirs                              = ['/var/www/htdocs/cache'],
  $php_memory_limit                       = '128M',
  $upload_max_filesize                    = '2M',
  $post_max_size                          = '8M',
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
  $instances                              =
          {'nbcdata.naturalis.nl' => {
            'serveraliases'   => '*.naturalis.nl',
            'docroot'         => '/var/www/htdocs',
            'directories'     => [{ 'path' => '/var/www/htdocs', 'options' => '-Indexes +FollowSymLinks +MultiViews', 'allow_override' => 'All' }],
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

# install php module php-gd
  php::module { [ 'gd','mysql','curl' ]: }

  php::ini { '/etc/php.ini':
    memory_limit              => $php_memory_limit,
    upload_max_filesize       => $upload_max_filesize,
    post_max_size             => $post_max_size,
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
          }
        }
    }
  }
# Install and configure phpMyadmin
  if $enable_phpmyadmin {
    class { 'role_nbcdata::phpmyadmin': }
  }
}
