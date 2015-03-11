#
# Manage iptables and fail2ban
#
class iptables_fail2ban::service {

    service { 'fail2ban':
        ensure  => running,
        enable  => true,
        require => Class['iptables_fail2ban::config'],
    }

}
