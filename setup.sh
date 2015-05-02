#!/bin/sh
### BEGIN INIT INFO
# Provides:          iptables
# Required-Start:    $network
# Required-Stop:     $network
# Default-Start:     2 3 4 5
# Default-Stop:      
# Short-Description: Iptables rules
### END INIT INFO

case "$1" in
start|restart|reload|forse-reload)
iptables -F
iptables -t filter -P INPUT DROP
iptables -t filter -P FORWARD DROP
iptables -t filter -P OUTPUT ACCEPT

# Allow loppback
iptables -A INPUT  -i lo -j ACCEPT

iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -m conntrack --ctstate INVALID -j LOG --log-level warning --log-prefix "[IPT] Packet INVALID: "
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP

iptables -A INPUT -p tcp -m multiport --dports 22,80,443 -j ACCEPT
#iptables -A INPUT -p tcp --syn -m conntrack --ctstate NEW --dport 22 -j ACCEPT
#iptables -A INPUT -p tcp --syn -m conntrack --ctstate NEW --dport 80 -j ACCEPT

iptables -A INPUT -p icmp --icmp-type 8 -m conntrack --ctstate NEW -j ACCEPT # PING

iptables -A INPUT -p udp -m conntrack --ctstate NEW --dport 53 -j ACCEPT # DNS

iptables -A INPUT -j LOG --log-level info --log-prefix "[IPT] Drop INPUT: "
iptables -A INPUT -p tcp -j REJECT --reject-with tcp-reset 
iptables -A INPUT -p udp -j REJECT --reject-with icmp-port-unreachable
iptables -A INPUT -j REJECT --reject-with icmp-proto-unreach
;;

stop)
iptables -F
iptables -t filter -P INPUT ACCEPT
iptables -t filter -P FORWARD ACCEPT
iptables -t filter -P OUTPUT ACCEPT
;;
status)
iptables -L
;;
*)
echo "Unknown option"
exit 1
esac
