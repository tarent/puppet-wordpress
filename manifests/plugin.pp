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
    unless  => "test -d ${setup_dir}/plugins/${archive}",
    require => [
      Exec['wordpress_extract_installer', 'install initial database'],
      Package['unzip', 'wget']
    ],
  }


  exec { "plugin: ${name} extract":
    refreshonly => true,
    command     => "unzip ${setup_dir}/plugins/${archive} \
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
