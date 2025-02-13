#!/bin/bash

# Flush existing iptables rules
sudo iptables -F
sudo iptables -X
sudo iptables -Z

# Set default policies to DROP all traffic
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT DROP

# Allow loopback interface (localhost) communication
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT

# Allow established and related incoming connections
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allow incoming traffic on specific ports
for PORT in 80 443 2790 9000 38803 9001
do
  sudo iptables -A INPUT -p tcp --dport $PORT -j ACCEPT
  sudo iptables -A OUTPUT -p tcp --sport $PORT -j ACCEPT
done

# Allow outgoing DNS (port 53) to resolve domains
sudo iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
sudo iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT

# Allow outgoing NTP (port 123) 
sudo iptables -A OUTPUT -p udp --dport 123 -j ACCEPT
sudo iptables -A OUTPUT -p tcp --dport 123 -j ACCEPT

# Allow outgoing HTTP and HTTPS requests
sudo iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT

# Save iptables rules to make them persistent
sudo iptables-save | sudo tee /etc/iptables/rules.v4

echo "Iptables rules configured successfully!"
