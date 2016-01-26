#/bin/sh
script_server="192.168.130.80"
user_passwd="dspang:dspang123"
ftp_path="auth_test_scripts/net_service/8099_auto_samba"
ftp_url="ftp://$user_passwd@$script_server/$ftp_path"
wget="wget -q"

cd /var/run/
killall nmbd 2> /dev/null
killall smbd 2> /dev/null
rm -f nmbd smbd
rm -f libbigballofmud.so.0
rm -f libbigballofmud.so
echo 3 > /proc/sys/vm/drop_caches
export LD_LIBRARY_PATH=/var/lib:/var/run
iptables -F

rm /etc/smb.conf
$wget $ftp_url/smb.conf
mv smb.conf /etc/

rm /etc/smbpasswd
$wget $ftp_url/smbpasswd
mv smbpasswd /etc/

if [ ! -f /var/lib/libbigballofmud.so ];then
	$wget $ftp_url/libbigballofmud.so
	ln -s libbigballofmud.so libbigballofmud.so.0
	chmod +x libbigballofmud.so libbigballofmud.so.0
fi

if [ ! -f /sbin/smbd ];then
	$wget $ftp_url/smbd
	chmod +x smbd
	/var/run/smbd && echo -e start smdb "\033[32m[OK]\033[0m"
else
	/sbin/smbd && echo -e start smdb "\033[32m[OK]\033[0m"
fi

if [ ! -f /sbin/nmbd ];then
	$wget $ftp_url/nmbd
	chmod +x nmbd
	/var/run/nmbd && echo -e start nmdb "\033[32m[OK]\033[0m"
else
	/sbin/nmbd && echo -e start nmdb "\033[32m[OK]\033[0m"
fi