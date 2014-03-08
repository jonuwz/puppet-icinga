define icinga::ido2db_cfg (

  $key = $title,
  $value

) {

  $context = "/etc/icinga/ido2db.cfg"

  augeas { "ido2db.cfg $key":
    context => "/files${$context}",
    incl    => $context,
    lens    => 'Shellvars.lns',
    onlyif  => "get $key != '$value'",
    changes => "set $key '$value'",
    notify  => Service['icinga','ido2db'],
    require => Package["icinga-idoutils-libdbi-${::icinga::db_type}"],
  }

}



