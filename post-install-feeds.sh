#!/bin/bash

echo "CONFIG_PACKAGE_luci-theme-argon=y" >> .config

# Add some custom default settings
mkdir -p files/etc/uci-defaults

# Configure time
cat > files/etc/uci-defaults/99-timezone << EOF
uci set system.@system[0].timezone='Asia/Jakarta'
uci delete system.ntp.server
uci add_list system.ntp.server='0.id.pool.ntp.org'
uci add_list system.ntp.server='1.id.pool.ntp.org'
uci add_list system.ntp.server='2.id.pool.ntp.org'
uci commit system
/etc/init.d/system restart
EOF

# Change default LAN IP Address
cat > files/etc/uci-defaults/99-network << EOF
uci set network.lan.ipaddr='10.11.12.13'
uci commit network
EOF

# Change wireless default configurations
cat > files/etc/uci-defaults/99-wireless << EOF
uci -q delete wireless.@wifi-device[0].disabled
uci set wireless.@wifi-device[0].country='ID'
uci set wireless.@wifi-device[0].channel='11'
uci set wireless.@wifi-iface[0].ssid='Ryzen'
uci set wireless.@wifi-iface[0].encryption='psk-mixed'
uci set wireless.@wifi-iface[0].key='hehehehe'
uci commit wireless
EOF

# Disable rebind protection
cat > files/etc/uci-defaults/99-disable-rebind-protection << EOF
uci set dhcp.@dnsmasq[0].rebind_protection='0'
uci commit dhcp
EOF

# Add firewall
cat > files/etc/uci-defaults/99-firewall << EOF
uci add firewall redirect
uci set firewall.@redirect[-1].dest='lan'
uci set firewall.@redirect[-1].target='DNAT'
uci set firewall.@redirect[-1].name='WEB'
uci set firewall.@redirect[-1].src='wan'
uci set firewall.@redirect[-1].src_dport='8080'
uci set firewall.@redirect[-1].dest_ip='192.168.1.1'
uci set firewall.@redirect[-1].dest_port='80'
uci commit firewall

uci add firewall redirect
uci set firewall.@redirect[-2].dest='lan'
uci set firewall.@redirect[-2].target='DNAT'
uci set firewall.@redirect[-2].name='SSH'
uci set firewall.@redirect[-2].src='wan'
uci set firewall.@redirect[-2].src_dport='22'
uci set firewall.@redirect[-2].dest_ip='192.168.1.1'
uci set firewall.@redirect[-2].dest_port='22'

uci commit firewall
EOF

# Scheduled reboot
cat > files/etc/uci-defaults/99-scheduled-reboot << EOF
#!/bin/sh

[ -e /etc/crontabs/root ] && exit 0

cat << "IOF" >> /etc/crontabs/root
# Reboot at 4:30am every day
# Note: To avoid infinite reboot loop, wait 70 seconds
# and touch a file in /etc so clock will be set
# properly to 4:31 on reboot before cron starts.
19 4 * * * sleep 70 && touch /etc/banner && reboot

IOF

EOF

