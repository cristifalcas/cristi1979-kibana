# == Class: kibana::configure
#
# This class configures kibana.  It should not be directly called.
#
#
# === Authors
#
# * Justin Lambert <mailto:jlambert@letsevenup.com>
#
#
# === Copyright
#
# Copyright 2013 EvenUp.
#
class kibana::config (
  $es_host          = '',
  $es_port          = 9200,
  $modules          = [
    'histogram',
    'map',
    'table',
    'filtering',
    'timepicker',
    'text',
    'fields',
    'hits',
    'dashcontrol',
    'column',
    'derivequeries',
    'trends',
    'bettermap',
    'query',
    'terms'],
  $logstash_logging = false,
  $default_board    = 'default.json',) {
  $es_real = $es_host ? {
    ''      => "http://'+window.location.hostname+':${es_port}",
    default => "http://${es_host}:${es_port}"
  }

  file { '/var/www/html/kibana/config.js':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    content => template('kibana/config.js'),
  }

  include apache

  apache::vhost { 'kibana':
    servername    => $::fqdn,
    serveraliases => [$::domain, "*.${::domain}", $::ipaddress, $::hostname],
    docroot       => '/var/www/html/kibana',
    access_log_syslog => '|/usr/bin/logger -p local6.info -t httpd_kibana',
    error_log_syslog  => 'syslog:local7',
  }

  firewall { '200 http and https':
    port   => [80, 443],
    proto  => tcp,
    action => accept,
  }

  if $default_board != 'default.json' {
    file { '/var/www/html/kibana/app/dashboards/default.json':
      ensure => link,
      target => "/var/www/html/kibana/app/dashboards/${default_board}",
      force  => true,
    }
  }

}
