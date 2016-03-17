#!/bin/sh

password=$1
if [ -z "${password}" ]; then
    echo "Please specify the password for the AP"
    exit 1
fi
sed -i -e '/^SSID=/d' /etc/Wireless/RT2870AP/RT2870AP.dat
sed -i -e '/^WPAPSK=/d' /etc/Wireless/RT2870AP/RT2870AP.dat
echo "SSID=ipad-360" >> /etc/Wireless/RT2870AP/RT2870AP.dat
echo "WPAPSK=${password}" >> /etc/Wireless/RT2870AP/RT2870AP.dat

ifconfig ra0 down
#remove the driver before
if lsmod |grep -q -e '^mt7601Usta'; then
    rmmod mt7601Usta
fi
#add new ap driver
if ! lsmod |grep -q -e '^rtutil7601Uap'; then
    modprobe rtutil7601Uap
fi
if ! lsmod |grep -q -e '^mt7601Uap'; then
    modprobe mt7601Uap
fi
if ! lsmod |grep -q -e '^rtnet7601Uap'; then
    modprobe rtnet7601Uap
fi
#set ip
ifconfig ra0 up
ifconfig ra0 192.168.199.1
#dhcp the network
dhcpd ra0
#make if forward work from eth0
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
iptables -t filter -F
iptables -t nat -F
#iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE
