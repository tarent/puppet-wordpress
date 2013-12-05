# == Class: wordpress::app
#
# Install wordpress application and its dependencies
#
# === Parameters
#
# [*wordpress_url*]
#   Defines the download url for wordpress
# [*wordpress_archive*]
#   Defines the archive name
#
# === Variables
#
#
# === Examples
#
# include wordpress::app
#
# === Authors
#
# Volker Schmitz <v.schmitz@tarent.de>
# Viktor Hamm <v.hamm@tarent.de>
# Sebastian Reimers <s.reime@tarent.de>
# Max Marche <m.march@tarent.de>
#
# === Todos:
# * update wordpress extract themes
# * put content in install
#
class wordpress::app inherits wordpress {

  $wp_install_dir = "/opt/${wordpress_path}/${wordpress_install_dir}"

  $wordpress_url     =
    "wordpress.org/wordpress-${::wordpress::wordpress_version}.zip"
  $wordpress_archive = "wordpress-${::wordpress::wordpress_version}.zip"

  $apache = $::operatingsystem ? {
    Ubuntu   => apache2,
    CentOS   => httpd,
    Debian   => apache2,
    default  => httpd
  }

  $phpmysql = $::operatingsystem ? {
    Ubuntu   => php5-mysql,
    CentOS   => php-mysql,
    Debian   => php5-mysql,
    default  => php-mysql
  }

  $php = $::operatingsystem ? {
    Ubuntu   => libapache2-mod-php5,
    CentOS   => php,
    Debian   => libapache2-mod-php5,
    default  => php
  }

  package { ['unzip',$php,$phpmysql]:
    ensure => latest
  }

  $vhost_path = $apache ? {
    httpd    => '/etc/httpd/conf.d/wordpress.conf',
    apache2  => '/etc/apache2/sites-enabled/000-wordpress',
    default  => '/etc/httpd/conf.d/wordpress.conf',
  }

  file { 'wordpress_application_dir':
    ensure  =>  directory,
    path    =>  "${wp_install_dir}",
    before  =>  File['wordpress_setup_files_dir'],
  }

  file { 'wordpress_setup_files_dir':
    ensure  =>  directory,
    path    =>  "${wp_install_dir}/setup_files",
    before  =>  [
      File[
        'wordpress_php_configuration',
        'wordpress_themes',
        'wordpress_plugins'
      ],
      Exec[
        'wordpress_installer'
      ],
    ],
  }

  exec { 'wordpress_installer':
    command => "wget -q ${wordpress_url} -O \
      /opt/wordpress/setup_files/${wordpress_archive}",
    path    => [
      '/usr/bin/',
    ],
    notify  => Exec['wordpress_extract_installer'],
    unless  => "test -e ${wp_install_dir}/setup_files/${wordpress_archive}",
  }


  file {'wordpress_php_configuration':
    ensure     =>  file,
    path       =>  "${wp_install_dir}/wp-config.php",
    content    =>  template('wordpress/wp-config.erb'),
    subscribe  =>  Exec['wordpress_extract_installer'],
  }

  file { 'wordpress_themes':
    ensure     => directory,
    path       => "${wp_install_dir}/setup_files/themes",
    source     => 'puppet:///modules/wordpress/themes/',
    recurse    => true,
    purge      => true,
    ignore     => '.svn',
    notify     => Exec['wordpress_extract_themes'],
    subscribe  => Exec['wordpress_extract_installer'],
  }

  file { 'wordpress_plugins':
    ensure     => directory,
    path       => "${wp_install_dir}/setup_files/plugins",
    source     => 'puppet:///modules/wordpress/plugins/',
    recurse    => true,
    ignore     => '.svn',
    notify     => Exec['wordpress_extract_plugins'],
    subscribe  => Exec['wordpress_extract_installer'],
  }

  /* file { 'wordpress_vhost':
    ensure   => file,
    path     => $vhost_path,
    source   => 'puppet:///modules/wordpress/wordpress.conf',
    replace  => true,
    require  => Class['apache2'],
  } */

  if $::wordpress::multisite == true {
    file { "${wp_install_dir}/.htaccess":
      ensure  => file,
      content => template('wordpress/htaccess.erb'),
      require => File['wordpress_setup_files_dir'],
    }
  }

  exec {
  'wordpress_extract_installer':
    command      => "unzip -o\
                    ${wp_install_dir}/setup_files/${wordpress_archive}\
                    -d /opt/",
    refreshonly  => true,
    require      => Package['unzip'],
    path         => ['/bin','/usr/bin','/usr/sbin','/usr/local/bin']
  }

  exec { 'wordpress_extract_themes':
    command      => "/bin/sh -c \'for themeindex in `ls \
                    ${wp_install_dir}/setup_files/themes/*.zip`; \
                    do unzip -o \
                    $themeindex -d \
                    ${wp_install_dir}/wp-content/themes/; done",
    path         => ['/bin','/usr/bin','/usr/sbin','/usr/local/bin'],
    refreshonly  => true,
    require      => Package['unzip'],
    subscribe    => File['wordpress_themes'];
  }

  exec { 'wordpress_extract_plugins':
    command      => "/bin/sh -c \'for pluginindex in `ls \
                    ${wp_install}/setup_files/plugins/*.zip`; \
                    do unzip -o \
                    $pluginindex -d \
                    ${wp_install_dir}/wp-content/plugins/; done",
    path         => ['/bin','/usr/bin','/usr/sbin','/usr/local/bin'],
    refreshonly  => true,
    require      => Package['unzip'],
    subscribe    => File['wordpress_plugins'];
  }
}
