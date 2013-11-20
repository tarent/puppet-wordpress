This module will be set up an installation of wordpress on Debian style distributions.

Installation includes software and configuration for mysql, apache2 and php module.

__Software__
* Wordpress v. 3.5.1
* unzip
* mysql
* apache2
* php5
* php5-mysql
* libapache2-mod-php5


_Themes_
* Graphene 1.8.3
* Suffusion 4.4.6

_Plugins_
* Wordpress importer 0.6

__Usage__

    class {
      wordpress:
      wordpress_db_name =>      "<name of database>",
      wordpress_db_user =>      "<database user>",
      wordpress_db_password =>  "<database password>"
    }
