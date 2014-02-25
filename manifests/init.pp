# == Class: wordpress
#
# This class and its subclasses installs a wordpress on a debian system.
#
# === Parameters
#
# [*wordpress_db_name*]
#   Defines the database wich will used by wordpress
# [*wordpress_db_user*]
#   Defines the user wich will used by wordpress
#   to connect to the database.
# [*wordpress_db_password*]
#   Defines the  wordpress user password.
# [*wordpress_db_admin*]
#   Defines the name of the site admin in wordpress
# [*wordpress_db_admin_mail*]
#   Defines the wordpress admin e-mail
# [*wordpress_version*]
#   Defines the wordpress version you want to install.
#   This field isn't testet jet.
#   Please use the default value 3.5.1
# [*blogname*]
#   Defines the "blogname"
# [*multisite*]
#   Enables multisite if bool is set to true.
# [*path_current_site*]
#   Configures the default path to your site http::<fqdn or ip>/path
#   Node: start with an /
#
#
# === Variables
#
#
# === Examples
#
# class { 'wordpress':
#   version               => '3.5.1',
#   wordpress_db_name     => wordpress,
#   wordpress_db_user     => wordpress,
#   wordpress_db_password => 'secret123',
#   wordpress_admin_mail  => 'localhorst@localhost.localhost',
#   multisite             => true,
# }
#
# === Authors
#
# Volker Schmitz <v.schmitz@tarent.de>
# Viktor Hamm <v.hamm@tarent.de>
# Sebastian Reimers <s.reime@tarent.de>
# Max Marche <m.march@tarent.de>
#
# === Todos:
# * backup wordpress database
#
class wordpress(
  $wordpress_db_name='wordpress',
  $wordpress_db_user='wordpress',
  $wordpress_db_password='password',
  $wordpress_admin = 'admin',
  $wordpress_db_user_bak ='wordpress_bak',
  $wordpress_db_password_bak = 'password_bak',
  $wordpress_admin_mail = 'localhost@localhost',
  $wordpress_version = '3.7.1',
  $blogname = 'wordpress blog',
  $multisite = false,
  $path_current_site = '/',
  $wordpress_install_dir = 'wordpress',
  $wordpress_path = '',
) {
  $db_name = $wordpress_db_name
  $db_user = $wordpress_db_user
  $db_password = $wordpress_db_password
  $db_user_bak = $wordpress_db_user_bak
  $db_password_bak = $wordpress_password_bak

  include 'apache2'
  include 'wordpress::install'

  class { 'wordpress::app':
    require => Class['apache2'],
  }

  class {'wordpress::db':
    require => Class['apache2']
  }

  class { 'wordpress::config':
    require => Class['wordpress::app', 'wordpress::db']
  }

}
