# == Class: wordpress::app
#
# Install wordpress application and its dependencies
#
# === Parameters
#
# [*location*]
#   Defines the download url of the plugin
# [*archive*]
#   Defines the specific archive file
#   has to be a zip file.
# [*activate*]
#   If set to true the plugin will be enabled by default,
#   requires an auto-activation.sql in th plugin sql directory.
#
# === Variables
#
#
# === Examples
#
# wordpress::app { 'superplugin':
#   loction  => http://wordpress/plugins/,
#   archive  => superplugin-3.1.4-1,
#   activate => falce,
#
# === Authors
#
# Volker Schmitz <v.schmitz@tarent.de>
# Viktor Hamm <v.hamm@tarent.de>
# Sebastian Reimers <s.reime@tarent.de>
# Max Marche <m.march@tarent.de>
#
# === Todos:
#
# * add backup by auto avtivation
#
define wordpress::plugin(
  $location,
  $archive,
  $activate = false,
){

  $wordpress_dir = '/opt/wordpress'
  $setup_dir = "${wordpress_dir}/setup_files"

  exec { "plugin: ${name} download":
    command => "wget -q ${location}/${archive} \
      -O /opt/wordpress/setup_files/plugins/${archive}",
    path    => [
      '/usr/local/sbin',
      '/usr/local/bin',
      '/usr/sbin',
      '/usr/bin:/sbin',
      '/bin'
    ],
    notify  => Exec["plugin: ${name} extract"],
    unless  => "test -f ${setup_dir}/plugins/${archive}",
    require => [
      Exec['wordpress_extract_installer', 'install initial database'],
      Package['unzip', 'wget']
    ],
  }


  exec { "plugin: ${name} extract":
    refreshonly => true,
    command     => "unzip -o ${setup_dir}/plugins/${archive} \
      -d /opt/wordpress/wp-content/plugins/${name}",
    path        => [
      '/usr/local/sbin',
      '/usr/local/bin',
      '/usr/sbin',
      '/usr/bin:/sbin',
      '/bin',
    ],
  }
  if $activate == true {
    exec { "plugin: ${name} activation":
      subscribe   => Exec["plugin: ${name} extract"],
      command     => "mysql -u ${wordpress::wordpress_db_user} \
        -p${wordpress::wordpress_db_password} \
        -D ${wordpress::wordpress_db_name} \
        < /opt/wordpress/wp-content/plugins/${name}/sql/auto-activation.sql",
      path        => [
        '/usr/local/sbin',
        '/usr/local/bin',
        '/usr/sbin',
        '/usr/bin:/sbin',
        '/bin',
      ],
      refreshonly => true,
    }
  }
}
