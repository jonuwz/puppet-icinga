class icinga::pnp4nagios (
  
) {
  
  package {'pnp4nagios':
    ensure   => installed,
  }    

  package {'icinga-web-module-pnp':
    ensure   => installed,
    require  => Package['pnp4nagios'],
    notify   => Exec['flush icinga php cache'],
  }

  icinga::icinga_cfg {
    'process_performance_data':                  value => '1';
    'host_perfdata_file':                        value => '/usr/local/pnp4nagios/var/host-perfdata';
    'service_perfdata_file':                     value => '/usr/local/pnp4nagios/var/service-perfdata';
    'service_perfdata_file_mode':                value => 'a';
    'host_perfdata_file_mode':                   value => 'a';
    'service_perfdata_file_processing_interval': value => '30';
    'host_perfdata_file_processing_interval':    value => '30';
    'service_perfdata_file_processing_command':  value => 'process-service-perfdata-file';
    'host_perfdata_file_processing_command':     value => 'process-host-perfdata-file';
    'service_perfdata_file_template':            value => 'DATATYPE::SERVICEPERFDATA\tTIMET::$TIMET$\tHOSTNAME::$HOSTNAME$\tSERVICEDESC::$SERVICEDESC$\tSERVICEPERFDATA::$SERVICEPERFDATA$\tSERVICECHECKCOMMAND::$SERVICECHECKCOMMAND$\tHOSTSTATE::$HOSTSTATE$\tHOSTSTATETYPE::$HOSTSTATETYPE$\tSERVICESTATE::$SERVICESTATE$\tSERVICESTATETYPE::$SERVICESTATETYPE$';
    'host_perfdata_file_template':               value => 'DATATYPE::HOSTPERFDATA\tTIMET::$TIMET$\tHOSTNAME::$HOSTNAME$\tHOSTPERFDATA::$HOSTPERFDATA$\tHOSTCHECKCOMMAND::$HOSTCHECKCOMMAND$\tHOSTSTATE::$HOSTSTATE$\tHOSTSTATETYPE::$HOSTSTATETYPE$';
  }

  file {"${apache::confd_dir}/pnp4nagios.conf":
    owner      => root,
    group      => root,
    mode       => 0644,
    source     => 'puppet:///modules/icinga/pnp4nagios.conf',
    require    => Class['apache'],
    notify     => Service['httpd'],
  }

}
