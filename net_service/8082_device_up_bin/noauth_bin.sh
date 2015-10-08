#!/bin/sh

mx8_ii_bin="MX/mx8-II/340/MX.N1.1.1.16.p1.340.C0.03.bin"
#wroc2k_bin="OM/wrom/5_88_P4/OM.K1.3.4.2.1.5_88_P4.C0.03.bin"
wroc2k_bin="OM/wrom/5_88_P3/OM.K1.3.4.1.7.5_88_P3.C0.01.bin"
wroc3k_bin="OM/wroc3000/5_88_P4/OM.M1.1.2.27.11.5_88_P4.C0.02.bin"
hx4e_bin="MX/hx4e/340/MX.P1.1.1.16.p1.340.C0.03.bin"
om50_bin="OM/om50/5_92_2/OM.N1.1.1.16mt.5_92_2.C0.03.bin"
om20_bin="OM/om20/5_91/OM.P1.1.1.16.5_91.C0.06.bin"

hostname=`hostname`
echo "Your device type is $hostname"
echo "Now downloading kupdate..."
if   [ "$hostname" = "MX8-II" -o "$hostname" = "MX8A" ];then
        kupdate=kupdate.om50_om20_hx4e_mx8a.v1.1	        #mx8-II
	bin_path=$mx8_ii_bin
elif [ "$hostname" = "wroc" ];then
        kupdate=kupdate.WROC2000.v2.4	                        #wroc2K
	bin_path=$wroc2k_bin
elif [ "$hostname" = "WROC3000" ];then
        kupdate=kupdate.WROC3000.v1.0.7		                #wroc3000
	bin_path=$wroc3k_bin
elif [ "$hostname" = "HX4E" ];then
        kupdate=kupdate.om50_om20_hx4e_mx8a.v1.1	        #hx4e
	bin_path=$hx4e_bin
elif [ "$hostname" = "OM50" ];then
        kupdate=kupdate.om50_om20_hx4e_mx8a.v1.1                #om50
	bin_path=$om50_bin
elif [ "$hostname" = "OM20" ];then
        kupdate=kupdate.om50_om20_hx4e_mx8a.v1.1                #om20
	bin_path=$om20_bin
else
        echo "$hostanme NOT support!"
        exit 1
fi

bin_name=`basename $bin_path`

cd /tmp

killall -9 smbd > /dev/null 2>&1
killall -9 nmbd > /dev/null 2>&1
killall -9 pluginmgr > /dev/null 2>&1
killall -9 cloudae > /dev/null 2>&1
#rm -rf /var/run/*
echo 3 > /proc/sys/vm/drop_caches

rm -f $kupdate
rm -f $bin_name

wget ftp://hdl:hdl@192.168.20.165/$kupdate
wget ftp://hdl:hdl@192.168.20.165/$bin_path
chmod +x $kupdate

/tmp/$kupdate $bin_name
