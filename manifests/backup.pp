# == Class: wordpress::backup
# Triggers a database backup after each update. Main purpose of this class
# is to use the backup file for selenium-tests.
#
# === Parameters 
#
# [*backup_dir*]
#  Defines the file location to store the backup file.
# [*backup_name*]
#  Defines the name of the backup file.
define wordpress::backup(
  $backup_dir,
  $backup_name,
){
  
  file { 'db backup directory' : 
    ensure   => directory,
    path     => "${backup_dir}",
    before   => Exec['db database backup'],
  }

  exec { 'db database backup' : 
    command  =>  "mysqldump --xml -t -uroot \
    --password=${::wordpress::wordpress_db_password} \
    ${::wordpress::wordpress_db_name} > ${backup_dir}${backup_name}",
    path     =>  [
      '/usr/local/sbin',
      '/usr/local/bin',
      '/usr/sbin',
      '/usr/bin:/sbin',
      '/bin',
    ],
    unless   =>  "mysql -uroot -p${::wordpress::wordpress_db_passoword} -e \"use ${::wordpress::wordpress_db_name}\"",
    
  }


}

