#!/bin/bash
# hostname and timezone
hostnamectl set-hostname kvmhost.local
timedatectl set-timezone America/Sao_Paulo
# END hostname and timezone

# adjust network interfaces
for connection in $(nmcli --fields uuid connection show | grep -vi uuid)
do
   nmcli connection modify ${connection} ipv6.method disabled
done

for device in $(nmcli --fields general.device device show | grep -v lo | cut -d \: -f 2  | grep -v ^$  | awk ' {print $1}')
do
   nmcli device reapply ${device}
done
# END adjust network interfaces

# enable and start KVM
systemctl enable libvirtd
systemctl start libvirtd
systemctl status libvirtd
# END enable and start KVM

# install terraform
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install terraform
# END install terraform

# LVM
vgcreate labvg /dev/sdb
lvcreate -l 6399 -n isolv labvg
lvcreate -l 3840 -n medialv labvg
mkfs.xfs /dev/labvg/isolv
mkfs.xfs /dev/labvg/medialv
echo "/dev/labvg/isolv /isos                 xfs     defaults        0 0" >> /etc/fstab
echo "/dev/labvg/medialv /var/lib/libvirt/images                 xfs     defaults        0 0" >> /etc/fstab
mkdir -p /var/lib/libvirt/images
mkdir /isos
systemctl daemon-reload
mount -a
# END LVM


# define an default pool
cat << EOF > /tmp/create_default_pool.txt
<pool type='dir'>
  <name>default</name>
  <target>
    <path>/var/lib/libvirt/images</path>
    <permissions>
      <mode>0755</mode>
      <owner>0</owner>
      <group>0</group>
      <label>system_u:object_r:unlabeled_t:s0</label>
    </permissions>
  </target>
</pool>
EOF

virsh pool-define /tmp/create_default_pool.txt
virsh pool-start default
virsh pool-autostart default
# END define an default pool

# define an ISO pool
cat << EOF > /tmp/create_iso_pool.txt
<pool type='dir'>
  <name>isos</name>
  <target>
    <path>/isos</path>
    <permissions>
      <mode>0755</mode>
      <owner>0</owner>
      <group>0</group>
      <label>system_u:object_r:unlabeled_t:s0</label>
    </permissions>
  </target>
</pool>
EOF

virsh pool-define /tmp/create_iso_pool.txt
virsh pool-start isos
virsh pool-autostart isos
# END define an ISO pool

curl https://mirror.uepg.br/ubuntu-releases/23.04/ubuntu-23.04-live-server-amd64.iso --output /isos/ubuntu-23.04-live-server-amd64.iso
curl http://mirror.ufscar.br/centos/8-stream/isos/x86_64/CentOS-Stream-8-20230523.0-x86_64-dvd1.iso --output /isos/CentOS-Stream-8-20230523.0-x86_64-dvd1.iso
