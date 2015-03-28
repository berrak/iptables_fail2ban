##
## Manage iptables and fail2ban
##
class iptables_fail2ban::config {

    include stdlib

    # HIERA lookups
    $fail2ban_trusted_ipaddr = hiera( 'iptables_fail2ban::config::fail2ban_trusted_ipaddr' )

    # Fail2ban true ot false flags (naturally these must be installed first!)
    $fail2ban_modsec         = hiera( 'iptables_fail2ban::config::fail2ban_modsec' )
    $fail2ban_apache         = hiera( 'iptables_fail2ban::config::fail2ban_apache' )
    $fail2ban_postfix        = hiera( 'iptables_fail2ban::config::fail2ban_postfix' )

    $mydomain = $::domain
    $myhostname = $::hostname

    ## Fail2ban configuration

    file { '/etc/fail2ban/jail.local':
        content =>  template( 'iptables_fail2ban/jail.local.erb' ),
        owner   => 'root',
        group   => 'root',
        mode    => '0640',
        require => Class['iptables_fail2ban::install'],
        notify  => Class['iptables_fail2ban::service'],
    }

    # HIERA lookups
    $is_server               = hiera( 'iptables_fail2ban::config::is_server' )

    $iptables_home_net       = hiera( 'iptables_fail2ban::config::iptables_home_net' )
    $iptables_google_net     = hiera( 'iptables_fail2ban::config::iptables_google_net' )

    $iptables_trusted_addr   = hiera( 'iptables_fail2ban::config::iptables_trusted_addr' )
    $iptables_nfs_host_addr  = hiera( 'iptables_fail2ban::config::iptables_nfs_host_addr' )

    $is_virtual = $::is_virtual

    ## Iptables configuration

    file { '/etc/rc.local' :
        source  => 'puppet:///modules/iptables_fail2ban/rc.local',
        owner   => 'root',
        group   => 'root',
        mode    => '0700',
        require => Class['iptables_fail2ban::install'],
    }

    file { '/root/bin/fw.clear_iptables' :
        source  => 'puppet:///modules/iptables_fail2ban/fw.clear_iptables',
        owner   => 'root',
        group   => 'root',
        mode    => '0700',
        require => Class['iptables_fail2ban::install'],
    }

    ## Server specifics iptables rules

    if ( str2bool($is_server) and ! str2bool($is_virtual) ) {

        file { '/root/bin/fw.server':
            content =>  template( 'iptables_fail2ban/fw.server.erb' ),
            owner   => 'root',
            group   => 'root',
            mode    => '0640',
            require => Class['iptables_fail2ban::install'],
        }

        exec { 'Refreshing_SERVER_firewall_policy' :
            command     => '/bin/bash /root/bin/fw.server',
            subscribe   => File['/root/bin/fw.server'],
            require     => File['/root/bin/fw.server'],
            refreshonly => true,
            notify      => Class['iptables_fail2ban::service'],
        }

    ## VM (on server) specifics iptables rules

    } elsif ( str2bool($is_server) and str2bool($is_virtual) ) {

        file { '/root/bin/fw.virtual':
            content =>  template( 'iptables_fail2ban/fw.virtual.erb' ),
            owner   => 'root',
            group   => 'root',
            mode    => '0640',
            require => Class['iptables_fail2ban::install'],
        }

        exec { 'Refreshing_VIRTUAL_SERVER_firewall_policy' :
            command     => '/bin/bash /root/bin/fw.virtual',
            subscribe   => File['/root/bin/fw.vm'],
            require     => File['/root/bin/fw.vm'],
            refreshonly => true,
            notify      => Class['iptables_fail2ban::service'],
        }


    ## Workstation/desktop specific iptables rules

    } else {

        file { '/root/bin/fw.desktop':
            content =>  template( 'iptables_fail2ban/fw.desktop.erb' ),
            owner   => 'root',
            group   => 'root',
            mode    => '0640',
            require => Class['iptables_fail2ban::install'],
        }

        exec { 'Refreshing_WORKSTATION_firewall_policy' :
            command     => '/bin/bash /root/bin/fw.desktop',
            subscribe   => File['/root/bin/fw.desktop'],
            require     => File['/root/bin/fw.desktop'],
            refreshonly => true,
            notify      => Class['iptables_fail2ban::service'],
        }

    }

}
