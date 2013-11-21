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
    require     => [
      Exec['wordpress_extract_installer'],
      Package['unzip']
    ],
    notify      => $activate ? {
      true      => Exec["plugin: ${name} activation"],
      default   => Notify["plugin: ${name} no activation"],
    },
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

  exec { "plugin: ${name} activation":
    command     => "mysql -u ${wordpress::wordpress_db_user}" +
    "-p${wordpress::wordpress_db_password} " +
    "< /opt/wordpress/wp-content/${name}/sql/auto-activation.sql",
    require     => Exec["plugin: ${name} extract"],
    path        => [
      '/usr/local/sbin',
      '/usr/local/bin',
      '/usr/sbin',
      '/usr/bin:/sbin',
      '/bin',
    ],
    refreshonly => true,
  }

  notify { "plugin: ${name} no activation":
    message => "plugin:  ${name} will not be auto activated",
  }
}
