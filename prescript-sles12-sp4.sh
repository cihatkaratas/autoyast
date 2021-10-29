#! /bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin:$PATH
export PATH
ACTIVE_INTERFACE=`/sbin/ifconfig | grep eth | awk '{print $1}'`
IP_ADDRESS=`/sbin/ifconfig $ACTIVE_INTERFACE | grep 'inet addr' | awk '{print $2}' | sed 's/addr://'`
MASK=`/sbin/ifconfig $ACTIVE_INTERFACE | grep 'inet addr' | awk '{print $4}' | sed 's/Mask://'`
PREFIX=`echo $MASK |perl -ne 'chomp $_; foreach $byte (split /\./,$_) {$bin.=sprintf ("%08b",$byte )}; $cidr=index $bin,"0"; print "$cidr\n";'`
GATEWAY=`route -n | grep UG | awk '{print $2}'`
CUSTOMERHOSTNAME=`ip -r route get $IP_ADDRESS | awk '/^local/{print tolower($2)}' | sed 's/\..*$//'`
CUSTOMERDOMAIN=$(ip -r route get $IP_ADDRESS | awk '/^local/{print tolower($2)}' | cut -d '.' -f 2-)
HARDWAREVENDOR=`dmidecode -s system-manufacturer`

for i in $(ifconfig -a | sed 's/[ \t].*//;/^\(lo\|\)$/d'|sed 's/://'| grep -v lo)
do
ifconfig $i up
done
sleep 5

for i in $(ifconfig -a | sed 's/[ \t].*//;/^\(lo\|\)$/d'|sed 's/://'| grep -v lo)
do
STATUS=$(ethtool $i | grep 'Link detected' | awk -F: '{print $2}')

if [ $STATUS == 'yes' ]; then
        COUNTER=$((COUNTER+1))
        NIC[$COUNTER]="$i"
fi
done

cat > swinclude << EOF
  <add-on></add-on>
  <host>
    <hosts config:type="list">
      <hosts_entry>
        <host_address>@@IPADDR@@</host_address>
        <names config:type="list">
          <name>@@HOSTNAME@@.@@DOMAIN@@ @@HOSTNAME@@</name>
        </names>
      </hosts_entry>
    </hosts>
  </host>
  <software>
    <image/>
    <install_recommended config:type="boolean">true</install_recommended>
    <instsource/>
    <packages config:type="list">
      <package>snapper</package>
      <package>sles-release</package>
      <package>openssh</package>
      <package>numactl</package>
      <package>ntp</package>
      <package>kexec-tools</package>
      <package>kdump</package>
      <package>irqbalance</package>
      <package>grub2</package>
      <package>glibc</package>
      <package>e2fsprogs</package>
      <package>btrfsprogs</package>
    </packages>
    <patterns config:type="list">
      <pattern>Minimal</pattern>
      <pattern>base</pattern>
      <pattern>yast2</pattern>
    </patterns>
  </software>
EOF

if [[ $HARDWAREVENDOR == "VMware, Inc." ]]
then
ACTIVATIONKEY=sles12-sp4.sh
cat > hp-bonding << EOF
  <networking>
    <keep_install_network config:type="boolean">false</keep_install_network>
    <dns>
      <domain>@@DOMAIN@@</domain>
      <hostname>@@HOSTNAME@@</hostname>
      <nameservers config:type="list">
        <nameserver>192.168.108.10</nameserver>
      </nameservers>
      <resolv_conf_policy>auto</resolv_conf_policy>
      <searchlist config:type="list">
        <search>@@DOMAIN@@</search>
      </searchlist>
    </dns>
    <interfaces config:type="list">
      <interface>
        <bootproto>static</bootproto>
        <device>eth0</device>
        <hostname>@@HOSTNAME@@</hostname>
        <ipaddr>@@IPADDR@@</ipaddr>
        <netmask>@@NETMASK@@</netmask>
        <startmode>auto</startmode>
        <usercontrol>no</usercontrol>
      </interface>
    </interfaces>
    <routing>
      <ip_forward config:type="boolean">false</ip_forward>
      <routes config:type="list">
        <route>
          <destination>default</destination>
          <device>-</device>
          <gateway>@@GATEWAY@@</gateway>
          <netmask>-</netmask>
        </route>
      </routes>
    </routing>
    <managed config:type="boolean">false</managed>
  </networking>
EOF
cat > susemanager-addon-cd << EOF
  <add-on>
    <add_on_products config:type="list">
    <listentry>
      <ask_on_error config:type="boolean">true</ask_on_error>
      <media_url>http://sumacka01.ckalab.suse.com/ks/dist/child/dc1-sles12-sp4-prod-sles12-sp4-updates-x86_64/dc1-sles12-sp4-prod</media_url>
      <name>dc1-sles12-sp4-prod-sles12-sp4_installation_update_channel</name>
      <product>dc1-sles12-sp4-prod-sles12-sp4_installation_update_channel</product>
      <product_dir>/</product_dir>
    </listentry>
    <listentry>
      <ask_on_error config:type="boolean">true</ask_on_error>
      <media_url>http://sumacka01.ckalab.suse.com/ks/dist/child/dc1-sles12-sp4-prod-sle-module-containers12-pool-x86_64-sp4/dc1-sles12-sp4-prod</media_url>
      <name>dc1-sles12-sp4-prod-sles12-sp4_container_module_pool_channel</name>
      <product>dc1-sles12-sp4-prod-sles12-sp4_container_module_pool_channel</product>
      <product_dir>/</product_dir>
    </listentry>
    <listentry>
      <ask_on_error config:type="boolean">true</ask_on_error>
      <media_url>http://sumacka01.ckalab.suse.com/ks/dist/child/dc1-sles12-sp4-prod-sle-module-containers12-updates-x86_64-sp4/dc1-sles12-sp4-prod</media_url>
      <name>dc1-sles12-sp4-prod-sles12-sp4_container_module_update_channel</name>
      <product>dc1-sles12-sp4-prod-sles12-sp4_container_module_update_channel</product>
      <product_dir>/</product_dir>
    </listentry>
    <listentry>
      <ask_on_error config:type="boolean">true</ask_on_error>
      <media_url>http://sumacka01.ckalab.suse.com/ks/dist/child/dc1-sles12-sp4-prod-sle-manager-tools12-updates-x86_64-sp4/dc1-sles12-sp4-prod</media_url>
      <name>dc1-sles12-sp4-prod-sles12-sp4_suse_manager_tools_update_channel</name>
      <product>dc1-sles12-sp4-prod-sles12-sp4_suse_manager_tools_update_channel</product>
      <product_dir>/</product_dir>
    </listentry>
    </add_on_products>
  </add-on>
EOF
else
# ACTIVATIONKEY=sles12-sp4.sh
cat > hp-bonding << EOF
  <networking>
    <keep_install_network config:type="boolean">false</keep_install_network>
    <dns>
      <domain>@@DOMAIN@@</domain>
      <hostname>@@HOSTNAME@@</hostname>
      <nameservers config:type="list">
        <nameserver>192.178.110.10</nameserver>
      </nameservers>
      <resolv_conf_policy>auto</resolv_conf_policy>
      <searchlist config:type="list">
        <search>@@DOMAIN@@</search>
      </searchlist>
    </dns>
    <interfaces config:type="list">
      <interface>
        <bonding_master>yes</bonding_master>
        <bonding_module_opts>mode=active-backup miimon=100</bonding_module_opts>
        <bonding_slave0>@@FIRSTNIC@@</bonding_slave0>
        <bonding_slave1>@@SECONDNIC@@</bonding_slave1>
        <bootproto>static</bootproto>
        <device>bond0</device>
        <hostname>@@HOSTNAME@@</hostname>
        <ipaddr>@@IPADDR@@</ipaddr>
        <netmask>@@NETMASK@@</netmask>
        <prefixlen>@@BONDPREFIX@@</prefixlen>
        <startmode>auto</startmode>
        <usercontrol>no</usercontrol>
      </interface>
      <interface>
        <bootproto>none</bootproto>
        <device>@@FIRSTNIC@@</device>
        <startmode>off</startmode>
        <usercontrol>no</usercontrol>
      </interface>
      <interface>
        <bootproto>none</bootproto>
        <device>@@SECONDNIC@@</device>
        <startmode>off</startmode>
        <usercontrol>no</usercontrol>
      </interface>
    </interfaces>
    <routing>
      <ip_forward config:type="boolean">false</ip_forward>
      <routes config:type="list">
        <route>
          <destination>default</destination>
          <device>-</device>
          <gateway>@@GATEWAY@@</gateway>
          <netmask>-</netmask>
        </route>
      </routes>
    </routing>
  </networking>
EOF
cat > susemanager-addon-cd << EOF
  <add-on>
    <add_on_products config:type="list">
      <listentry>
        <ask_on_error config:type="boolean">true</ask_on_error>
        <media_url>http://sumacka01.ckalab.suse.com/ks/dist/child/dc1-sles12-sp4-prod-sles12-sp4-updates-x86_64/dc1-sles12-sp4-prod</media_url>
        <name>dc1-sles12-sp4-prod-sles12-sp4_installation_update_channel</name>
        <product>dc1-sles12-sp4-prod-sles12-sp4_installation_update_channel</product>
        <product_dir>/</product_dir>
        </listentry>
    </add_on_products>
  </add-on>
EOF
fi
if [ -d /sys/firmware/efi ]
then
cat > loadertype << EOF
<loader_type>grub2-efi</loader_type>
EOF
else
cat > loadertype << EOF
<loader_type>grub2</loader_type>
EOF
fi
sed -i -e "s/\@\@IPADDR\@\@/$IP_ADDRESS/i" swinclude
sed -i -e "s/\@\@HOSTNAME\@\@/$CUSTOMERHOSTNAME/ig" swinclude
sed -i -e "s/\@\@DOMAIN\@\@/$CUSTOMERDOMAIN/ig" swinclude
sed -i -e "s/\@\@IPADDR\@\@/$IP_ADDRESS/i" hp-bonding
sed -i -e "s/\@\@NETMASK\@\@/$MASK/i" hp-bonding
sed -i -e "s/\@\@GATEWAY\@\@/$GATEWAY/i" hp-bonding
sed -i -e "s/\@\@HOSTNAME\@\@/$CUSTOMERHOSTNAME/ig" hp-bonding
sed -i -e "s/\@\@BONDPREFIX\@\@/$PREFIX/ig" hp-bonding
sed -i -e "s/\@\@FIRSTNIC\@\@/${NIC[1]}/ig" hp-bonding
sed -i -e "s/\@\@SECONDNIC\@\@/${NIC[2]}/ig" hp-bonding
sed -i -e "s/\@\@DOMAIN\@\@/$CUSTOMERDOMAIN/ig" hp-bonding

sed -i -e "s|<add-on></add-on>|`cat susemanager-addon-cd | sed -e 's/$/\\\\n/' | tr -d '\n'`|" swinclude
sed -i -e "s|<networking>networking</networking>|`cat hp-bonding | sed -e 's/$/\\\\n/' | tr -d '\n'`|" /tmp/profile/autoinst.xml
sed -e "s|<software>software</software>|`cat swinclude | sed -e 's/$/\\\\n/' | tr -d '\n'`|" /tmp/profile/autoinst.xml > /tmp/profile/modified-software.xml
