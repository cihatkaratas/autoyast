#! /bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin:$PATH
export PATH

if [ -d /sys/firmware/efi ]
then
cat > uefilvm << EOF
  <partitioning config:type="list">
    <drive>
      <disklabel>gpt</disklabel>
      <device>/dev/system</device>
      <lvm2 config:type="boolean">true</lvm2>
      <partitions config:type="list">
        <partition>
          <create config:type="boolean">true</create>
          <filesystem config:type="symbol">ext4</filesystem>
          <format config:type="boolean">true</format>
          <lv_name>root</lv_name>
          <mount>/</mount>
          <mountby config:type="symbol">uuid</mountby>
          <size>2G</size>
        </partition>
        <partition>
          <create config:type="boolean">true</create>
          <filesystem config:type="symbol">swap</filesystem>
          <format config:type="boolean">true</format>
          <lv_name>swap</lv_name>
          <mount>swap</mount>
          <mountby config:type="symbol">uuid</mountby>
          <size>1G</size>
        </partition>
        <partition>
          <create config:type="boolean">true</create>
          <filesystem config:type="symbol">ext4</filesystem>
          <format config:type="boolean">true</format>
          <lv_name>tmp</lv_name>
          <mount>/tmp</mount>
          <mountby config:type="symbol">uuid</mountby>
          <size>1G</size>
        </partition>
        <partition>
          <create config:type="boolean">true</create>
          <filesystem config:type="symbol">ext4</filesystem>
          <format config:type="boolean">true</format>
          <lv_name>usr</lv_name>
          <mount>/usr</mount>
          <mountby config:type="symbol">uuid</mountby>
          <size>3G</size>
        </partition>
        <partition>
          <create config:type="boolean">true</create>
          <filesystem config:type="symbol">ext4</filesystem>
          <format config:type="boolean">true</format>
          <lv_name>var</lv_name>
          <mount>/var</mount>
          <mountby config:type="symbol">uuid</mountby>
          <size>5G</size>
        </partition>
        <partition>
          <create config:type="boolean">true</create>
          <filesystem config:type="symbol">ext4</filesystem>
          <format config:type="boolean">true</format>
          <lv_name>srv</lv_name>
          <mount>/srv</mount>
          <mountby config:type="symbol">uuid</mountby>
          <size>1G</size>
        </partition>
        <partition>
          <create config:type="boolean">true</create>
          <filesystem config:type="symbol">ext4</filesystem>
          <format config:type="boolean">true</format>
          <lv_name>opt</lv_name>
          <mount>/opt</mount>
          <mountby config:type="symbol">uuid</mountby>
          <size>1G</size>
        </partition>
      </partitions>
      <pesize>4M</pesize>
      <type config:type="symbol">CT_LVM</type>
      <use>all</use>
    </drive>
    <drive>
      <disklabel>gpt</disklabel>
      <initialize config:type="boolean">true</initialize>
      <partitions config:type="list">
       <partition>
          <create config:type="boolean">true</create>
          <filesystem config:type="symbol">vfat</filesystem>
          <format config:type="boolean">true</format>
          <mount>/boot/efi</mount>
          <mountby config:type="symbol">uuid</mountby>
          <partition_id config:type="integer">259</partition_id>
          <partition_nr config:type="integer">1</partition_nr>
          <size>100M</size>
        </partition>
        <partition>
          <create config:type="boolean">true</create>
          <filesystem config:type="symbol">ext4</filesystem>
          <format config:type="boolean">true</format>
          <mount>/boot</mount>
          <mountby config:type="symbol">uuid</mountby>
          <partition_id config:type="integer">131</partition_id>
          <partition_nr config:type="integer">1</partition_nr>
          <partition_type>primary</partition_type>
          <size>1G</size>
        </partition>
        <partition>
          <create config:type="boolean">true</create>
          <lvm_group>system</lvm_group>
          <partition_id config:type="integer">142</partition_id>
          <partition_nr config:type="integer">2</partition_nr>
          <partition_type>primary</partition_type>
          <size>max</size>
        </partition>
      </partitions>
      <use>all</use>
    </drive>
  </partitioning>
EOF

cat > uefibtrfs << EOF
<partitioning config:type="list">
  <drive>
    <device>/dev/sda</device>
    <disklabel>gpt</disklabel>
    <enable_snapshots config:type="boolean">true</enable_snapshots>
    <initialize config:type="boolean">true</initialize>
    <partitions config:type="list">
      <partition>
        <create config:type="boolean">true</create>
        <crypt_fs config:type="boolean">false</crypt_fs>
        <filesystem config:type="symbol">vfat</filesystem>
        <format config:type="boolean">true</format>
        <fstopt>umask=0002,utf8=true</fstopt>
        <loop_fs config:type="boolean">false</loop_fs>
        <mount>/boot/efi</mount>
        <mountby config:type="symbol">uuid</mountby>
        <partition_id config:type="integer">259</partition_id>
        <partition_nr config:type="integer">1</partition_nr>
        <resize config:type="boolean">false</resize>
        <size>100M</size>
      </partition>
      <partition>
        <create config:type="boolean">true</create>
        <crypt_fs config:type="boolean">false</crypt_fs>
        <filesystem config:type="symbol">swap</filesystem>
        <format config:type="boolean">true</format>
        <fstopt>defaults</fstopt>
        <loop_fs config:type="boolean">false</loop_fs>
        <mount>swap</mount>
        <mountby config:type="symbol">uuid</mountby>
        <partition_id config:type="integer">130</partition_id>
        <partition_nr config:type="integer">2</partition_nr>
        <resize config:type="boolean">false</resize>
        <size>1G</size>
      </partition>
      <partition>
        <create config:type="boolean">true</create>
        <crypt_fs config:type="boolean">false</crypt_fs>
        <filesystem config:type="symbol">btrfs</filesystem>
        <format config:type="boolean">true</format>
        <fstopt>defaults</fstopt>
        <loop_fs config:type="boolean">false</loop_fs>
        <mount>/</mount>
        <mountby config:type="symbol">uuid</mountby>
        <partition_id config:type="integer">131</partition_id>
        <partition_nr config:type="integer">3</partition_nr>
        <resize config:type="boolean">false</resize>
        <size>max</size>
        <subvolumes config:type="list">
          <listentry>
            <copy_on_write config:type="boolean">true</copy_on_write>
            <path>boot/grub2/i386-pc</path>
          </listentry>
          <listentry>
            <copy_on_write config:type="boolean">true</copy_on_write>
            <path>boot/grub2/x86_64-efi</path>
          </listentry>
          <listentry>
            <copy_on_write config:type="boolean">true</copy_on_write>
            <path>opt</path>
          </listentry>
          <listentry>
            <copy_on_write config:type="boolean">true</copy_on_write>
            <path>srv</path>
          </listentry>
          <listentry>
            <copy_on_write config:type="boolean">true</copy_on_write>
            <path>tmp</path>
          </listentry>
          <listentry>
            <copy_on_write config:type="boolean">true</copy_on_write>
            <path>usr/local</path>
          </listentry>
          <listentry>
            <copy_on_write config:type="boolean">true</copy_on_write>
            <path>var/cache</path>
          </listentry>
          <listentry>
            <copy_on_write config:type="boolean">true</copy_on_write>
            <path>var/crash</path>
          </listentry>
          <listentry>
            <copy_on_write config:type="boolean">false</copy_on_write>
            <path>var/lib/libvirt/images</path>
          </listentry>
          <listentry>
            <copy_on_write config:type="boolean">true</copy_on_write>
            <path>var/lib/machines</path>
          </listentry>
          <listentry>
            <copy_on_write config:type="boolean">true</copy_on_write>
            <path>var/lib/mailman</path>
          </listentry>
          <listentry>
            <copy_on_write config:type="boolean">false</copy_on_write>
            <path>var/lib/mariadb</path>
          </listentry>
          <listentry>
            <copy_on_write config:type="boolean">false</copy_on_write>
            <path>var/lib/mysql</path>
          </listentry>
          <listentry>
            <copy_on_write config:type="boolean">true</copy_on_write>
            <path>var/lib/named</path>
          </listentry>
          <listentry>
            <copy_on_write config:type="boolean">false</copy_on_write>
            <path>var/lib/pgsql</path>
          </listentry>
          <listentry>
            <copy_on_write config:type="boolean">true</copy_on_write>
            <path>var/log</path>
          </listentry>
          <listentry>
            <copy_on_write config:type="boolean">true</copy_on_write>
            <path>var/opt</path>
          </listentry>
          <listentry>
            <copy_on_write config:type="boolean">true</copy_on_write>
            <path>var/spool</path>
          </listentry>
          <listentry>
            <copy_on_write config:type="boolean">true</copy_on_write>
            <path>var/tmp</path>
          </listentry>
        </subvolumes>
      </partition>
      <partition>
        <create config:type="boolean">true</create>
        <crypt_fs config:type="boolean">false</crypt_fs>
        <filesystem config:type="symbol">xfs</filesystem>
        <format config:type="boolean">true</format>
        <fstopt>defaults</fstopt>
        <loop_fs config:type="boolean">false</loop_fs>
        <mount>/home</mount>
        <mountby config:type="symbol">uuid</mountby>
        <partition_id config:type="integer">131</partition_id>
        <partition_nr config:type="integer">4</partition_nr>
        <resize config:type="boolean">false</resize>
        <size>1G</size>
      </partition>
    </partitions>
    <pesize/>
    <type config:type="symbol">CT_DISK</type>
    <use>all</use>
  </drive>
</partitioning>
EOF
sed  -e "s|<partitioning>partitioning</partitioning>|`cat uefilvm | sed -e 's/$/\\\\n/' | tr -d '\n'`|" /tmp/profile/modified-software.xml > /tmp/profile/modified_lvm.xml
sed  -e "s|<partitioning>partitioning</partitioning>|`cat uefibtrfs | sed -e 's/$/\\\\n/' | tr -d '\n'`|" /tmp/profile/modified-software.xml > /tmp/profile/modified_uefi.xml
fi

if [ ! -d /sys/firmware/efi ]
then
cat > legacylvm << EOF
  <partitioning config:type="list">
    <drive>
      <device>/dev/system</device>
      <lvm2 config:type="boolean">true</lvm2>
      <partitions config:type="list">
        <partition>
          <create config:type="boolean">true</create>
          <filesystem config:type="symbol">ext4</filesystem>
          <format config:type="boolean">true</format>
          <lv_name>root</lv_name>
          <mount>/</mount>
          <mountby config:type="symbol">uuid</mountby>
          <size>2G</size>
        </partition>
        <partition>
          <create config:type="boolean">true</create>
          <filesystem config:type="symbol">swap</filesystem>
          <format config:type="boolean">true</format>
          <lv_name>swap</lv_name>
          <mount>swap</mount>
          <mountby config:type="symbol">uuid</mountby>
          <size>1G</size>
        </partition>
        <partition>
          <create config:type="boolean">true</create>
          <filesystem config:type="symbol">ext4</filesystem>
          <format config:type="boolean">true</format>
          <lv_name>tmp</lv_name>
          <mount>/tmp</mount>
          <mountby config:type="symbol">uuid</mountby>
          <size>1G</size>
        </partition>
        <partition>
          <create config:type="boolean">true</create>
          <filesystem config:type="symbol">ext4</filesystem>
          <format config:type="boolean">true</format>
          <lv_name>usr</lv_name>
          <mount>/usr</mount>
          <mountby config:type="symbol">uuid</mountby>
          <size>3G</size>
        </partition>
        <partition>
          <create config:type="boolean">true</create>
          <filesystem config:type="symbol">ext4</filesystem>
          <format config:type="boolean">true</format>
          <lv_name>var</lv_name>
          <mount>/var</mount>
          <mountby config:type="symbol">uuid</mountby>
          <size>5G</size>
        </partition>
        <partition>
          <create config:type="boolean">true</create>
          <filesystem config:type="symbol">ext4</filesystem>
          <format config:type="boolean">true</format>
          <lv_name>srv</lv_name>
          <mount>/srv</mount>
          <mountby config:type="symbol">uuid</mountby>
          <size>1G</size>
        </partition>
        <partition>
          <create config:type="boolean">true</create>
          <filesystem config:type="symbol">ext4</filesystem>
          <format config:type="boolean">true</format>
          <lv_name>opt</lv_name>
          <mount>/opt</mount>
          <mountby config:type="symbol">uuid</mountby>
          <size>1G</size>
        </partition>
      </partitions>
      <pesize>4M</pesize>
      <type config:type="symbol">CT_LVM</type>
      <use>all</use>
    </drive>
    <drive>
      <initialize config:type="boolean">true</initialize>
      <partitions config:type="list">
        <partition>
          <create config:type="boolean">true</create>
          <filesystem config:type="symbol">ext4</filesystem>
          <format config:type="boolean">true</format>
          <mount>/boot</mount>
          <mountby config:type="symbol">uuid</mountby>
          <partition_id config:type="integer">131</partition_id>
          <partition_nr config:type="integer">1</partition_nr>
          <partition_type>primary</partition_type>
          <size>1G</size>
        </partition>
        <partition>
          <create config:type="boolean">true</create>
          <lvm_group>system</lvm_group>
          <partition_id config:type="integer">142</partition_id>
          <partition_nr config:type="integer">2</partition_nr>
          <partition_type>primary</partition_type>
          <size>max</size>
        </partition>
      </partitions>
      <use>all</use>
    </drive>
  </partitioning>
EOF

cat > legacybtrfs << EOF
<partitioning config:type="list">
  <drive>
    <device>/dev/sda</device>
    <disklabel>msdos</disklabel>
    <enable_snapshots config:type="boolean">true</enable_snapshots>
    <initialize config:type="boolean">true</initialize>
    <partitions config:type="list">
      <partition>
        <create config:type="boolean">true</create>
        <crypt_fs config:type="boolean">false</crypt_fs>
        <filesystem config:type="symbol">swap</filesystem>
        <format config:type="boolean">true</format>
        <fstopt>defaults</fstopt>
        <loop_fs config:type="boolean">false</loop_fs>
        <mount>swap</mount>
        <mountby config:type="symbol">uuid</mountby>
        <partition_id config:type="integer">130</partition_id>
        <partition_nr config:type="integer">1</partition_nr>
        <partition_type>primary</partition_type>
        <resize config:type="boolean">false</resize>
        <size>1G</size>
      </partition>
      <partition>
        <create config:type="boolean">true</create>
        <crypt_fs config:type="boolean">false</crypt_fs>
        <filesystem config:type="symbol">btrfs</filesystem>
        <format config:type="boolean">true</format>
        <fstopt>defaults</fstopt>
        <loop_fs config:type="boolean">false</loop_fs>
        <mount>/</mount>
        <mountby config:type="symbol">uuid</mountby>
        <partition_id config:type="integer">131</partition_id>
        <partition_nr config:type="integer">2</partition_nr>
        <partition_type>primary</partition_type>
        <resize config:type="boolean">false</resize>
        <size>max</size>
        <subvolumes config:type="list">
          <listentry>
            <copy_on_write config:type="boolean">true</copy_on_write>
            <path>boot/grub2/i386-pc</path>
          </listentry>
          <listentry>
            <copy_on_write config:type="boolean">true</copy_on_write>
            <path>boot/grub2/x86_64-efi</path>
          </listentry>
          <listentry>
            <copy_on_write config:type="boolean">true</copy_on_write>
            <path>opt</path>
          </listentry>
          <listentry>
            <copy_on_write config:type="boolean">true</copy_on_write>
            <path>srv</path>
          </listentry>
          <listentry>
            <copy_on_write config:type="boolean">true</copy_on_write>
            <path>tmp</path>
          </listentry>
          <listentry>
            <copy_on_write config:type="boolean">true</copy_on_write>
            <path>usr/local</path>
          </listentry>
          <listentry>
            <copy_on_write config:type="boolean">true</copy_on_write>
            <path>var/cache</path>
          </listentry>
          <listentry>
            <copy_on_write config:type="boolean">true</copy_on_write>
            <path>var/crash</path>
          </listentry>
          <listentry>
            <copy_on_write config:type="boolean">false</copy_on_write>
            <path>var/lib/libvirt/images</path>
          </listentry>
          <listentry>
            <copy_on_write config:type="boolean">true</copy_on_write>
            <path>var/lib/machines</path>
          </listentry>
          <listentry>
            <copy_on_write config:type="boolean">true</copy_on_write>
            <path>var/lib/mailman</path>
          </listentry>
          <listentry>
            <copy_on_write config:type="boolean">false</copy_on_write>
            <path>var/lib/mariadb</path>
          </listentry>
          <listentry>
            <copy_on_write config:type="boolean">false</copy_on_write>
            <path>var/lib/mysql</path>
          </listentry>
          <listentry>
            <copy_on_write config:type="boolean">true</copy_on_write>
            <path>var/lib/named</path>
          </listentry>
          <listentry>
            <copy_on_write config:type="boolean">false</copy_on_write>
            <path>var/lib/pgsql</path>
          </listentry>
          <listentry>
            <copy_on_write config:type="boolean">true</copy_on_write>
            <path>var/log</path>
          </listentry>
          <listentry>
            <copy_on_write config:type="boolean">true</copy_on_write>
            <path>var/opt</path>
          </listentry>
          <listentry>
            <copy_on_write config:type="boolean">true</copy_on_write>
            <path>var/spool</path>
          </listentry>
          <listentry>
            <copy_on_write config:type="boolean">true</copy_on_write>
            <path>var/tmp</path>
          </listentry>
        </subvolumes>
      </partition>
      <partition>
        <create config:type="boolean">true</create>
        <crypt_fs config:type="boolean">false</crypt_fs>
        <filesystem config:type="symbol">xfs</filesystem>
        <format config:type="boolean">true</format>
        <fstopt>defaults</fstopt>
        <loop_fs config:type="boolean">false</loop_fs>
        <mount>/home</mount>
        <mountby config:type="symbol">uuid</mountby>
        <partition_id config:type="integer">131</partition_id>
        <partition_nr config:type="integer">3</partition_nr>
        <partition_type>primary</partition_type>
        <resize config:type="boolean">false</resize>
        <size>1G</size>
      </partition>
    </partitions>
    <pesize/>
    <type config:type="symbol">CT_DISK</type>
    <use>all</use>
  </drive>
</partitioning>
EOF
sed  -e "s|<partitioning>partitioning</partitioning>|`cat legacylvm | sed -e 's/$/\\\\n/' | tr -d '\n'`|" /tmp/profile/modified-software.xml > /tmp/profile/modified_lvm.xml
sed  -e "s|<partitioning>partitioning</partitioning>|`cat legacybtrfs | sed -e 's/$/\\\\n/' | tr -d '\n'`|" /tmp/profile/modified-software.xml > /tmp/profile/modified_uefi.xml
fi
