puppet-role_nbcdata
===================

Puppet Role manifest for installation of nbcdata server(s)

Todo:
-------------
- possibility for multiple repo's
- fix default instances

Classes
-------------
- role_nbcdata
- role_nbcdata::instances
- role_nbcdata::phpmyadmin
- role_nbcdata::repo
- role_nbcdata::repogeneral

Dependencies
-------------
- puppetlabs/mysql
- puppetlabs/apache2
- thias/php

Limitations
-------------
This module has been built on and tested against Puppet 3.4.3 and higher.

The module has been tested on:

- Ubuntu 14.04

Authors
-------------
Author Name <foppe.pieters@naturalis.nl>
