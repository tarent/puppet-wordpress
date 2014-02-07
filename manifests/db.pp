# == Class: wordpress::db
#
# Install mysql server
# and set up initial wordpress database and user
#
# === Parameters
#
# [*mysqlserver*]
#   Defines the mysql server package name.
# [*mysqlclient*]
#   Defines the mysql client name.
# [*mysqlservice*]
#   Defines the mysql service name.
#
# === Variables
#
#
# === Examples
#
# include wordpress::db
#
# === Authors
#
# Volker Schmitz <v.schmitz@tarent.de>
# Viktor Hamm <v.hamm@tarent.de>
# Sebastian Reimers <s.reime@tarent.de>
# Max Marche <m.march@tarent.de>
#
# === Todos:
# * should include the offical puppetlabs mysql module
#
class wordpress::db {

  $setup_dir = '/opt/setup_files'

  $mysqlserver = $::operatingsystem ? {
    Ubuntu   => mysql-server,
    CentOS   => mysql-server,
    default  => mysql-server
  }

  $mysqlclient = $::operatingsystem ? {
    Ubuntu   => mysql-client,
    CentOS   => mysql,
    Debian   => mysql-client,
    default  => mysql
  }

  $mysqlservice = $::operatingsystem ? {
    Ubuntu   => mysql,
    CentOS   => mysqld,
    Debian   => mysql,
    default  => mysqld
  }

  package { [ $mysqlclient, $mysqlserver ]: ensure => latest }

  service { $mysqlservice:
    ensure      => running,
    enable      => true,
    hasrestart  => true,
    hasstatus   => true,
    require     => Package[ $mysqlserver, $mysqlclient ],
  }

  file { 'wordpress_sql_script':
    ensure   => file,
    path     => "${setup_dir}/create_wordpress_db.sql",
    content  => template('wordpress/create_wordpress_db.erb');
  }

  exec {
    'create_schema':
      path     => '/usr/bin:/usr/sbin:/bin',
      command  => "mysql -uroot -p${wordpress::db_password} <\
                  ${setup_dir}/create_wordpress_db.sql",
      unless   => "mysql -uroot -p${wordpress::db_password} -e \"use ${wordpress::db_name}\"",
      notify   => Exec['grant_privileges'],
      require  => [
        Service[ $mysqlservice ],
        File['wordpress_sql_script'],
      ];
    'grant_privileges':
      path         => '/usr/bin:/usr/sbin:/bin',
      command      => "mysql -uroot -p${wordpress::db_password} \
                      -e \"grant all privileges on\
                      ${wordpress::db_name}.* to\
                      '${wordpress::db_user}'@'localhost'\
                      identified by '${wordpress::db_password}'\"",
      unless       => "mysql -u${wordpress::db_user}\
                      -p${wordpress::db_password}\
                      -D${wordpress::db_name} -hlocalhost",
      refreshonly  => true;
  }
}
