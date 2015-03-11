##
## Manage iptables and fail2ban
##
class iptables_fail2ban::install {

    package { 'iptables':
        ensure        => installed,
        allow_virtual => true,
    }

    package { [ 'fail2ban', 'python-pyinotify' ]:
        ensure        => installed,
        allow_virtual => true,
        require       => Package['iptables'],
    }

}
