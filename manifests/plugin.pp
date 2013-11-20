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

  exec { "download plugin ${archive}":
    command => "wget -q ${location}/${archive} -O /tmp/",
    path    => [
      '/usr/local/sbin',
      '/usr/local/bin',
      '/usr/sbin',
      '/usr/bin:/sbin',
      '/bin'
    ],
    notify  => Exec["plugin: ${name} entpacken"],
    require => Package['wget'],
    unless  => "test -d /opt/wordpress/wp-content/plugins/${name}",
  }

  exec { "plugin: ${name} entpacken":
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
