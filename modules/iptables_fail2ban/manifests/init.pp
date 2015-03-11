##
## Manage iptables and fail2ban
##
class iptables_fail2ban {

    if ! ( $::operatingsystem == 'Debian' ) {
        fail('FAIL: This module (iptables_fail2ban) is only for Debian based distributions! Aborting...')
    }

    include iptables_fail2ban::install, iptables_fail2ban::config, iptables_fail2ban::service

}
