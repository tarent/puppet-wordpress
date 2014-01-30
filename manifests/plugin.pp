# == Class: wordpress::plugin
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
  $wordpress_path,
  $wordpress_install_dir,
){

  $wp_install_dir = "/opt/${wordpress_path}/${wordpress_install_dir}" 
  $setup_dir = "/opt/setup_files"

  exec { "plugin: ${name} download":
    command => "wget -q ${location}/${archive} \
      -O ${setup_dir}/plugins/${archive}",
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
      -d ${wp_install_dir}/wp-content/plugins/${name}",
    path        => [
      '/usr/local/sbin',
      '/usr/local/bin',
      '/usr/sbin',
      '/usr/bin:/sbin',
      '/bin',
    ],
  }
  if $activate == true {
    exec { "plugin: ${name} backup trigger":
      command     => "mysqldump --databases --opt -Q \
      -u${::wordpress::wordpress_db_user} \
      -p${::wordpress::wordpress_db_password} \
      ${::wordpress::wordpress_db_name} \
      > ${wp_install_dir}/db_backup/befor_activate__${archive}.sql",
      path        => [
        '/usr/local/sbin',
        '/usr/local/bin',
        '/usr/sbin',
        '/usr/bin:/sbin',
        '/bin',
      ],
      refreshonly => true,
      subscribe   => Exec["plugin: ${name} extract"],
      notify      => Exec["plugin: ${name} activation"],
    }

    file { "plugin: ${name} activation file" : 
      source  => 'puppet:///modules/wordpress/auto-activation.sql',
      path    => '/tmp/auto-activation.sql',
      before  => Exec["plugin: ${name} activation"],
    }

    exec { "plugin: ${name} activation":
      command     => "mysql -u ${wordpress::wordpress_db_user} \
        -p${wordpress::wordpress_db_password} \
        -D ${wordpress::wordpress_db_name} \
        < /tmp/auto-activation.sql",
      path        => [
        '/usr/local/sbin',
        '/usr/local/bin',
        '/usr/sbin',
        '/usr/bin:/sbin',
        '/bin',
      ],
      refreshonly => true,
      require     => File["plugin: ${name} activation file"],
    }
  }
}
