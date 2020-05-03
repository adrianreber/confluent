#!/bin/bash
echo "Installing certificates"
echo '<authorized_keys xmlns="http://www.suse.com/1.0/yast2ns" xmlns:config="http://www.suse.com/1.0/configns" config:type="list">' > /tmp/rootkeys.xml
for pub in /ssh/*.rootpubkey; do
    echo '<listentry>'$(cat $pub)'</listentry>' >> /tmp/rootkeys.xml
done
echo '</authorized_keys>' >> /tmp/rootkeys.xml
/usr/bin/cp /tls/*.0 /var/lib/ca-certificates/openssl/
/usr/bin/cp /tls/*.0 /etc/ssl/certs/
echo "LineMode: 1" > /etc/linuxrc.d/01-confluent
autocons=""
if ! grep console /proc/cmdline > /dev/null; then
	autocons=$(/opt/confluent/bin/autocons)
	if [ ! -z "$autocons" ]; then
		echo "ConsoleDevice: ${autocons%,*}" >> /etc/linuxrc.d/01-confluent
	fi
fi
cd /sys/class/net
for nic in *; do
	ip link set $nic up
done
echo -n "Discovering confluent..."
/opt/confluent/bin/copernicus -t > /tmp/confluent.info
while ! grep MANAGER: /tmp/confluent.info > /dev/null; do
	/opt/confluent/bin/copernicus -t > /tmp/confluent.info
done
nodename=$(grep ^NODENAME: /tmp/confluent.info | head -n 1 | sed -e 's/NODENAME: //')
echo "done ($nodename)"
echo "Hostname: $nodename" >> /etc/linuxrc.d/01-confluent
mgr=$(grep ^MANAGER: /tmp/confluent.info | head -n 1 | sed -e 's/MANAGER: //')
echo -n "Acquiring configuration from $mgr..."
bootifidx=${mgr#*%}
for nic in *; do
	if [ "$(cat $nic/ifindex)" = "$bootifidx" ]; then
		bootif=$nic
	fi
done
cd -
echo "NetDevice: $bootif" >> /etc/linuxrc.d/01-confluent
/opt/confluent/bin/clortho $nodename $mgr > /tmp/confluent.apikey
mgr="[$mgr]"
curl -H "CONFLUENT_NODENAME: $nodename" -H "CONFLUENT_APIKEY: $(cat /tmp/confluent.apikey)" https://$mgr/confluent-api/self/deploycfg > /tmp/confluent.deploycfg

tz=$(grep timezone: /tmp/confluent.deploycfg | awk '{print $2}')
echo "<timezone>${tz}</timezone>" > /tmp/timezone
autoconfigmethod=$(grep ipv4_method /tmp/confluent.deploycfg)
autoconfigmethod=${autoconfigmethod#ipv4_method: }
if [ "$autoconfigmethod" = "dhcp" ]; then
	echo "DHCP: 1" >> /etc/linuxrc.d/01-confluent
else
	v4addr=$(grep ^ipv4_address: /tmp/confluent.deploycfg)
	v4addr=${v4addr#ipv4_address: }
	v4gw=$(grep ^ipv4_gateway: /tmp/confluent.deploycfg)
	v4gw=${v4gw#ipv4_gateway: }
	v4nm=$(grep ipv4_netmask: /tmp/confluent.deploycfg)
	v4nm=${v4nm#ipv4_netmask: }
	echo "HostIP: $v4addr" >> /etc/linuxrc.d/01-confluent
	echo "Netmask: $v4nm" >> /etc/linuxrc.d/01-confluent
	if [ "$v4gw" != "null" ]; then
		echo "Gateway: $v4gw" >> /etc/linuxrc.d/01-confluent
	fi
	nameserversec=0
	while read -r entry; do
		if [ $nameserversec = 1 ]; then
			if [[ $entry == "-"* ]]; then
				echo Nameserver: ${entry#- } >> /etc/linuxrc.d/01-confluent
				continue
			fi
		fi
		nameserversec=0
		if [ ${entry%:*} = "nameservers" ]; then
			nameserversec=1
			continue
		fi
	done < /tmp/confluent.deploycfg
fi
echo done
mgr=$(grep ^ipv4_server: /tmp/confluent.deploycfg)
mgr=${mgr#ipv4_server: }
profilename=$(grep ^profile: /tmp/confluent.deploycfg)
profilename=${profilename#profile: }
proto=$(grep ^protocol: /tmp/confluent.deploycfg)
proto=${proto#protocol: }

echo "<media_url>${proto}://${mgr}/confluent-public/os/${profilename}/distribution/2</media_url>" > /tmp/pkgurl

echo "AutoYaST: $proto://$mgr/confluent-public/os/$profilename/autoyast" >> /etc/linuxrc.d/01-confluent
echo "Install: $proto://$mgr/confluent-public/os/$profilename/distribution/1" >> /etc/linuxrc.d/01-confluent
exec /init