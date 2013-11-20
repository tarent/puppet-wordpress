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
}
