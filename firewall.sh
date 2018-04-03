#!/bin/sh

# Launch original firewall binary and pass over parameters
/usr/sbin/firewall $@

# Set custom firewall rules
source /etc/iptables_rules
