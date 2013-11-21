This module will be set up an installation of wordpress on Debian style distributions.

Installation includes software and configuration for mysql, apache2 and php module.

__Software__
* Wordpress v. 3.5.1
* unzip
* mysql
* php5
* php5-mysql
* libapache2-mod-php5


_Themes_
* Graphene 1.8.3
* Suffusion 4.4.6

_Plugins by default_
* Wordpress importer 0.6

_Dependencies_
* puppetlabs/apache

__Usage__

     class { 'wordpress':
       version               => '3.5.1',
       wordpress_db_name     => wordpress,
       wordpress_db_user     => wordpress,
       wordpress_db_password => 'secret123',
       wordpress_admin_mail  => 'localhorst@localhost.localhost',
       multisite             => true,
     }
