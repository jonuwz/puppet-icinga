class icinga::web (

) {

  package{['icinga-web-module-pnp','icinga-web',"icinga-web-${::icinga::db_type}"]:
    ensure   => installed,
  }

  postgresql::database { 'icinga_web':
    owner    => $::icinga::db_user,
    charset  => 'UNICODE',
    require  => Postgresql::Database_user[$::icinga::db_user],
  }

  exec {'seed icinga web db':
    path        => ['/bin','/usr/bin'],
    user        => 'icinga',
    command     => "psql -U $::icinga::db_user -d icinga_web -h localhost -p 5432 < \$(find /usr/share/doc/icinga-web-*/schema -name ${::icinga::db_type}.sql)",
    unless      => "psql -U $::icinga::db_user -d icinga_web -h localhost -p 5432 psql -qtc '\\dt' | grep \"icinga\$\" >/dev/null 2>&1",
    require     => [ Postgresql::Database['icinga_web'], Package['icinga-web'] ],
  }

  file{'/etc/icinga-web/conf.d/databases.xml':
    owner     => root,
    group     => root,
    mode      => 0644,
    content   => template('icinga/icinga_web_databases.xml.erb'),
    require   => Package['icinga-web'],
    notify    => Exec['flush icinga php cache'],
  }

  exec {'flush icinga php cache':
    path        => ['/bin','/usr/bin'],
    command     => 'rm -rf /var/cache/icinga-web/config/*',
    refreshonly => true,
    notify      => Service['httpd'],
  }

  service {'httpd': 
    ensure     => running,
    enable     => true,
  }

}
