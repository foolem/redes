#!/bin/bash
echo "Setup nat configuration..."
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
echo "done."
echo "Setup dnat configuration..."
echo "Host 1"
iptables -t nat -A PREROUTING -p tcp -d 200.0.0.0/24 --dport 60003 -j DNAT --to 192.168.0.3:60003
echo "Host 2"
iptables -t nat -A PREROUTING -p tcp -d 200.0.0.0/24 --dport 60004 -j DNAT --to 192.168.0.4:60004
echo "done."
exit
