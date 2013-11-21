# == Class: wordpress::config
# Setup of the wordpress database bevore installing wordpress itself
#
# === Parameters
#
# === Variables
#
# === Authors
# 
# Volker Schmitz <v.schmitz@tarent.de>
# Viktor Hamm <v.hamm@tarent.de>
# Sebastian Reimers <s.reime@tarent.de>
# Max Marche <m.march@tarent.de>
#
# === Sample Usage
#
# include wordpress::config
#
class wordpress::config inherits wordpress {

  file { '/opt/wordpress/db_backup':
    ensure => directory,
  }

  file { '/opt/wordpress/db_backup/initial_dump.sql':
    ensure  => file,
    content => template('wordpress/initial_dump.sql.erb'),
    require => File['/opt/wordpress/db_backup'],
  }

  exec { 'install initial database':
    command => "mysql -u $wordpress_db_user -p$wordpress_db_password $wordpress_db_name < /opt/wordpress/db_backup/initial_dump.sql",
    require => File['/opt/wordpress/db_backup/initial_dump.sql'],
    path    => [
      '/usr/local/sbin',
      '/usr/local/bin',
      '/usr/sbin',
      '/usr/bin:/sbin',
      '/bin',
    ],
    unless  => "mysql -u $wordpress_db_user -h localhost -p$wordpress_db_password --database $wordpress_db_name -e 'show tables;' | grep Tables_in_$wordpress_db_name -c",
  }
}
