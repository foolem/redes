#!/bin/bash
echo "Setup nat configuration..."
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
echo "done."
echo "Setup dnat configuration..."
echo "Host 1"
iptables -t nat -A PREROUTING -p tcp --dport 60001 -j DNAT --to 192.168.0.2:60001
echo "Host 2"
iptables -t nat -A PREROUTING -p tcp --dport 60002 -j DNAT --to 192.168.0.3:60002
echo "done."
exit
