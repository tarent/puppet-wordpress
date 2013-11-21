# == Class: wordpress::install
# 
# Installation of additional software packages.
#
# === Parameters
#
# === Variables
#
# === Authors
#
# Volker Schmitz <v.schmitz@tarent.de>
# Viktor Hamm <v.hamm@tarent.de>
# Sebastian Reimers <s.reime@tarent.de>
# Max Marche <m.march@tarent.de>
#
# === Sample Usage
#
# include wordpress::install

class wordpress::install {
  package { 'wget':
    ensure => installed,
  }
}
