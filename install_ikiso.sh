#!/bin/bash
if [ "$USER" != "root" ];then
	echo "Need to be root"
	exit
fi
if [ "$1" = "x32" -o "$1" = "x64" ];then
	sysbit=$1
else
	echo "Usage:"
	echo "  sudo $0 x32"
	echo "  sudo $0 x64"
	exit 1
fi

gw_iface=($(ip route |awk '$1=="default"{print $3,$5;exit}'))
if [ ! "${gw_iface[1]}" ];then
	echo "Not found default gateway"
	exit 1
fi

ip=$(ip -4 add list dev ${gw_iface[1]} |awk '$1=="inet"{print $2;exit}')


iso=iKuai8_${sysbit}_3.6.0_Build202202171351
write_grub_menu()
{
cat >> /etc/grub.d/40_custom <<EOF
menuentry "$iso" {
loopback loop (hd0,1)/root/ik.iso
linux (loop)/boot/vmlinuz bootguide=cd
initrd (loop)/boot/rootfs
}
EOF

sed -r -i '/GRUB_TIMEOUT_STYLE/d; /GRUB_HIDDEN_TIMEOUT/d; s/GRUB_CMDLINE_LINUX_DEFAULT.*/GRUB_CMDLINE_LINUX_DEFAULT="text"/' /etc/default/grub
sed -r -i 's/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=5/' /etc/default/grub

update-grub
echo "address: $ip"
echo "gateway: ${gw_iface[0]}"
echo "install successfully, please restart system."
}

if wget -c https://www.ikuai8.com/download.php?n=/3.x/iso/$iso.iso -O /root/ik.iso ;then
	write_grub_menu
fi
