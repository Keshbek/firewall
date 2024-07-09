#!/usr/bin/env bash
set -e

SS_PORT=58388
export SSH_PORT=62222
export DEBIAN_FRONTEND=noninteractiv

ufw disable

# disable ipv6
# echo 1 > /proc/sys/net/ipv6/conf/default/disable_ipv6 
# echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6 
# echo 1 > /proc/sys/net/ipv6/conf/lo/disable_ipv6
# echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
# echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
# echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf

apt install -y iptables-persistent

# Change ssh port
sed -i "s/#Port 22/Port $SSH_PORT/" /etc/ssh/sshd_config
systemctl restart sshd.service

iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p tcp -m tcp --tcp-flags ALL SYN,ACK -j ACCEPT
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport $SSH_PORT -j ACCEPT
iptables -A INPUT -p udp -m udp --dport $SS_PORT -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport $SS_PORT -j ACCEPT
iptables -P INPUT DROP
iptables -P FORWARD DROP

iptables-save > /etc/iptables/rules.v4

echo
echo '******************************************'
echo '* Firewall sepup completed successfully! *'
echo '*                                        *'
echo "* Your new ssh port: $SSH_PORT               *"
echo '******************************************'
echo
