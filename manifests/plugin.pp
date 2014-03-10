define icinga::plugin (

  $plugin = $title

) {

  package {"nagios-plugins-${plugin}":
    ensure => installed,
  }

}
