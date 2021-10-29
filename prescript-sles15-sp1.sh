#! /bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin:$PATH
export PATH
ACTIVE_INTERFACE=$(ip a | grep eth[0-9]: | awk '{print $2}'|cut -d ':' -f1)
IP_ADDRESS=$(ip a sh dev $ACTIVE_INTERFACE|grep '\<inet\>' | awk '{print $2}' |cut -d '/' -f1)
MASK=$(grep NETMASK /run/netconfig/$(echo ${ACTIVE_INTERFACE} |cut -d ' ' -f1)/netconfig0 |cut -d "'" -f2)
PREFIX=$(grep PREFIXLEN /run/netconfig/$ACTIVE_INTERFACE/netconfig0 |cut -d "'" -f2)
GATEWAY=$(ip route|grep default|cut -d ' ' -f 3)
CUSTOMERHOSTNAME=`ip -r route get $IP_ADDRESS | awk '/^local/{print tolower($2)}' | sed 's/\..*$//'`
CUSTOMERDOMAIN=$(ip -r route get $IP_ADDRESS | awk '/^local/{print tolower($2)}' | cut -d '.' -f 2-)
HARDWAREVENDOR=`dmidecode -s system-manufacturer`

for i in $(ip a | grep eth[0-9]: | awk '{print $2}'|cut -d ':' -f1)
do
ip link set $i up
done
sleep 5

for i in $(ip a | grep eth[0-9]: | awk '{print $2}'|cut -d ':' -f1)
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
      <package>wicked</package>
      <package>sles-release</package>
      <package>sle-module-basesystem-release</package>
      <package>openssh</package>
      <package>numactl</package>
      <package>lvm2</package>
      <package>kexec-tools</package>
      <package>kdump</package>
      <package>irqbalance</package>
      <package>grub2</package>
      <package>glibc</package>
      <package>e2fsprogs</package>
      <package>chrony</package>
      <package>autoyast2</package>
    </packages>
    <patterns config:type="list">
      <pattern>base</pattern>
      <pattern>enhanced_base</pattern>
      <pattern>minimal_base</pattern>
      <pattern>yast2_basis</pattern>
    </patterns>
    <products config:type="list">
      <product>SLES</product>
    </products>
  </software>
EOF

if [[ $HARDWAREVENDOR == "VMware, Inc." ]]
then
ACTIVATIONKEY=sles15-sp1.sh
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
      <media_url>http://sumacka01.ckalab.suse.com/ks/dist/child/dc1-sles15-sp1-prod-sle-module-basesystem15-sp1-pool-x86_64/dc1-sles15-sp1-prod</media_url>
      <name>dc1-sles15-sp1-prod-sle-module-basesystem15-sp1-pool_channel</name>
      <product>dc1-sles15-sp1-prod-sle-module-basesystem15-sp1-pool_channel</product>
      <product_dir>/</product_dir>
    </listentry>
    <listentry>
      <ask_on_error config:type="boolean">true</ask_on_error>
      <media_url>http://sumacka01.ckalab.suse.com/ks/dist/child/dc1-sles15-sp1-prod-sle-product-sles15-sp1-updates-x86_64/dc1-sles15-sp1-prod</media_url>
      <name>dc1-sles15-sp1-prod-sle-product-sles15-sp1-updates_channel</name>
      <product>dc1-sles15-sp1-prod-sle-product-sles15-sp1-updates_channel</product>
      <product_dir>/</product_dir>
    </listentry>
    <listentry>
      <ask_on_error config:type="boolean">true</ask_on_error>
      <media_url>http://sumacka01.ckalab.suse.com/ks/dist/child/dc1-sles15-sp1-prod-sle-module-basesystem15-sp1-updates-x86_64/dc1-sles15-sp1-prod</media_url>
      <name>dc1-sles15-sp1-prod-sle-module-basesystem15-sp1-updates_channel</name>
      <product>dc1-sles15-sp1-prod-sle-module-basesystem15-sp1-updates_channel</product>
      <product_dir>/</product_dir>
    </listentry>
    <listentry>
      <ask_on_error config:type="boolean">true</ask_on_error>
      <media_url>http://sumacka01.ckalab.suse.com/ks/dist/child/dc1-sles15-sp1-prod-sle-module-server-applications15-sp1-pool-x86_64/dc1-sles15-sp1-prod</media_url>
      <name>dc1-sles15-sp1-prod-sle-module-server-applications15-sp1-pool_channel</name>
      <product>dc1-sles15-sp1-prod-sle-module-server-applications15-sp1-pool_channel</product>
      <product_dir>/</product_dir>
    </listentry>
    <listentry>
      <ask_on_error config:type="boolean">true</ask_on_error>
      <media_url>http://sumacka01.ckalab.suse.com/ks/dist/child/dc1-sles15-sp1-prod-sle-module-server-applications15-sp1-updates-x86_64/dc1-sles15-sp1-prod</media_url>
      <name>dc1-sles15-sp1-prod-sle-module-server-applications15-sp1-updates_channel</name>
      <product>dc1-sles15-sp1-prod-sle-module-server-applications15-sp1-updates_channel</product>
      <product_dir>/</product_dir>
    </listentry>
    <listentry>
      <ask_on_error config:type="boolean">true</ask_on_error>
      <media_url>http://sumacka01.ckalab.suse.com/ks/dist/child/dc1-sles15-sp1-prod-sle-manager-tools15-updates-x86_64-sp1/dc1-sles15-sp1-prod</media_url>
      <name>prod-sles15-sp1_suse_manager_tools_update_channel</name>
      <product>prod-sles15-sp1_suse_manager_tools_update_channel</product>
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
        <prefixlen>@@NETPREFIX@@</prefixlen>
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
        <media_url>http://sumacka01.ckalab.suse.com/ks/dist/child/dc1-sles15-sp1-prod-sle-product-sles15-sp1-updates-x86_64/dc1-sles15-sp1-prod</media_url>
        <name>dc1-sles15-sp1-prod-sle-product-sles15-sp1-updates_channel</name>
        <product>dc1-sles15-sp1-prod-sle-product-sles15-sp1-updates_channel</product>
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
sed -i -e "s/\@\@NETPREFIX\@\@/$PREFIX/ig" hp-bonding
sed -i -e "s/\@\@FIRSTNIC\@\@/${NIC[1]}/ig" hp-bonding
sed -i -e "s/\@\@SECONDNIC\@\@/${NIC[2]}/ig" hp-bonding
sed -i -e "s/\@\@DOMAIN\@\@/$CUSTOMERDOMAIN/ig" hp-bonding

sed -i -e "s|<add-on></add-on>|`cat susemanager-addon-cd | sed -e 's/$/\\\\n/' | tr -d '\n'`|" swinclude
sed -i -e "s|<networking>networking</networking>|`cat hp-bonding | sed -e 's/$/\\\\n/' | tr -d '\n'`|" /tmp/profile/autoinst.xml
sed -e "/software/,/software/c `cat swinclude | sed -e 's/$/\\\\n/' | tr -d '\n'`|" /tmp/profile/autoinst.xml > /tmp/profile/modified-software.xml
