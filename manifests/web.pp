class icinga::web (

  $db_user   =  'icinga',
  $db_type   =  'pgsql',
  $db_pass,

) {

  package{['icinga-web',"icinga-web-${db_type}"]:
    ensure   => installed,
  }

  postgresql::database { 'icinga_web':
    owner    => $db_user,
    charset  => 'UNICODE',
    require  => Postgresql::Database_user[$db_user],
  }

  exec {'seed icinga web db':
    path        => ['/bin','/usr/bin'],
    environment => ["PGPASSWORD=$db_pass"],
    user        => 'icinga',
    command     => "env > /tmp/john;psql -U $db_user -d icinga_web -h localhost -p 5432 < \$(find /usr/share/doc/icinga-web-*/schema -name ${::icinga::db_type}.sql)",
    unless      => "psql -U $db_user -d icinga_web -h localhost -p 5432 psql -qtc '\\dt' | grep \"icinga\$\" >/dev/null 2>&1",
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

  class {'apache':
    default_mods        => ['php','ssl','rewrite']
  }

  file {"${apache::confd_dir}/icinga-web.conf":
    owner      => root,
    group      => root,
    mode       => 0644,
    source     => 'puppet:///modules/icinga/icinga-web.conf',
    require    => Class['apache'],
  }

}
