class icinga (

  $db_type    =  'pgsql',
  $db_user    =  'icinga',
  $db_pass,
  $web        =  true,
  $pnp4nagios =  true,
  $plugins    =  ['disk','http','load','ping','procs','ssh','swap','users'],

) {

  package{['icinga',"icinga-idoutils-libdbi-${db_type}",'icinga-doc']:
    ensure   => installed,
  }

  icinga::plugin {$plugins: }

  class {'postgresql::server': }
  postgresql::database_user { $db_user:
    password_hash => postgresql_password($db_user,$db_pass),
    require       => Class['postgresql::server'],
  }
  postgresql::database { 'icinga':
    owner    => 'icinga',
    charset  => 'UNICODE',
    require  => Postgresql::Database_user[$db_user],
  }

  exec {'create lang':
    path        => ['/bin','/usr/bin'],
    user        => 'postgres',
    command     => 'createlang -d icinga plpgsql',
    unless      => 'createlang -d icinga -l 2>/dev/null| grep plpgsql >/dev/null',
    require     => Postgresql::Database['icinga'],
  }

  exec {'seed icinga db':
    path        => ['/bin','/usr/bin'],
    environment => ["PGPASSWORD=$db_pass"],
    user        => 'icinga',
    command     => "psql -U $db_user -d icinga -h localhost -p 5432 < \$(find /usr/share/doc/icinga-idoutils-libdbi-${db_type}* -name ${db_type}.sql)",
    unless      => "psql -U $db_user -d icinga -h localhost -p 5432 psql -qtc '\\dt' | grep \"icinga\$\" >/dev/null 2>&1",
    require     => [ Postgresql::Database['icinga'], Package["icinga-idoutils-libdbi-${db_type}"], Exec['create lang'] ],
    before      => Service['icinga'],
  }

  icinga::ido2db_cfg {
    'db_servertype': value => $db_type;
    'db_pass':       value => $db_pass;
    'db_user':       value => $db_user;
  }

  service {'icinga':
    ensure     => 'running',
    enable     => true,
    require    => Package['icinga'],

  }

  service {'ido2db':
    ensure     => 'running',
    enable     => true,
    require    => Package['icinga',"icinga-web-${db_type}"],
  }

  if $web == true {
    class {'icinga::web': db_user => $db_user, db_pass => $db_pass }
  }

  if $pnp4nagios == true {
    class {'icinga::pnp4nagios': }
  }

}
