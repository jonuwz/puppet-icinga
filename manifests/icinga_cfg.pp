define icinga::icinga_cfg (

  $key = $title,
  $value

) {

  $context = "/etc/icinga/icinga.cfg"

  augeas { "icinga.cfg $key":
    context => "/files${$context}",
    incl    => $context,
    lens    => 'Shellvars_novalidate.lns',
    onlyif  => "get $key != '$value'",
    changes => "set $key '$value'",
    notify  => Service['icinga'],
    require => Package['icinga'],
  }

}



