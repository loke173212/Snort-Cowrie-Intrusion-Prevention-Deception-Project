#!/bin/bash

# Snort-Cowrie Automation Script (Simplified)
# Author: Lokesh Lankalapalli
# Project: Snort-Cowrie Intrusion Prevention & Deception Project

# Paths and ports
SNORT_IFACE="eth0"
SNORT_CONF="/etc/snort/snort.lua" #change according to your path
COWRIE_HOME="/home/cowrie/cowrie"
COWRIE_PORT=2222
MAIN_SSH_PORT=22
ALT_SSH_PORT=2223
NFQUEUE_NUM=0
COWRIE_USER="cowrie"

# Graceful cleanup
cleanup() {
    echo "[*] Cleaning up: stopping Snort and Cowrie, resetting iptables."
    sudo pkill -f "snort"
    sudo -u $COWRIE_USER $COWRIE_HOME/bin/cowrie stop
    sudo iptables -F
    echo "[*] Done!"
    exit 0
}

trap cleanup SIGINT SIGTERM

echo "[*] Starting Cowrie on port $COWRIE_PORT..."
sudo -u $COWRIE_USER $COWRIE_HOME/bin/cowrie start
echo "[*] Cowrie started!"

echo "[*] Configuring iptables to send traffic to Snort (except 22, 2222, 2223)..."
sudo iptables -F
sudo iptables -I INPUT -p tcp -m multiport ! --dports $MAIN_SSH_PORT,$COWRIE_PORT,$ALT_SSH_PORT -j NFQUEUE --queue-num $NFQUEUE_NUM
echo "[*] iptables NFQUEUE rule set."

echo "[*] Starting Snort in IPS mode..."
sudo /usr/local/snort/bin/snort -Q --daq nfq --daq-var queue=$NFQUEUE_NUM -c $SNORT_CONF -i $SNORT_IFACE &
echo "[*] Snort started!"

echo "[*] Press Ctrl+C to stop Snort and Cowrie and reset iptables."

# Keep script alive
while true; do
    sleep 1
done
