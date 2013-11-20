# Definition: wordpress::plugin
#
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# wordpress::plugins { 'superplugin': }
#
define wordpress::plugin(
  $location,
  $archive,
  $activate = false,
){

  exec { "plugin: ${name} download":
    command => "wget -q ${location}/${archive} -O /tmp/${archive}",
    path    => [
      '/usr/local/sbin',
      '/usr/local/bin',
      '/usr/sbin',
      '/usr/bin:/sbin',
      '/bin'
    ],
    notify  => Exec["plugin: ${name} extract"],
    require => Package['wget'],
    unless  => "test -d /opt/wordpress/wp-content/plugins/${name}",
  }

  exec { "plugin: ${name} extract":
    refreshonly => true,
    require     => Package['unzip'],
    command     =>
      "unzip /tmp/${archive} -d /opt/wordpress/wp-content/plugins/${name}",
    path        => [
      '/usr/local/sbin',
      '/usr/local/bin',
      '/usr/sbin',
      '/usr/bin:/sbin',
      '/bin',
    ],
  }

  if $activate == true {
    exec { "mysql -u ${wordpress::wordpress_db_user}
      -p${wordpress::wordpress_db_password} ${wordpress::wordpress_db_name}
      < /opt/wordpress/wp-content/${name}/sql/auto-activation.sql":
      require => Exec["plugin: ${name} extract"],
      path    => [
        '/usr/local/sbin',
        '/usr/local/bin',
        '/usr/sbin',
        '/usr/bin:/sbin',
        '/bin',
      ],
      unless  => "mysql -u ${wordpress::wordpress_db_user}
        -h localhost -p${wordpress::wordpress_db_password}
        --database ${wordpress::wordpress_db_name}
        -e 'show tables;' |
        grep Tables_in_${wordpress::wordpress_db_name} -c",
    }
  }
}
