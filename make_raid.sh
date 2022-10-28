raid换盘常用命令
查看磁盘状态
sudo megacli -pdlist -aall   |   grep "Firmware state"
清除外来磁盘信息
sudo megacli -cfgforeign -clear -a0
查看e:s
sudo megacli -pdlist -aall |grep  good  -B20 
设置热备盘
sudo /usr/sbin/megacli -PDHSP -Set -Dedicated -Array1 -physdrv[32:7] -a0
调整rebuild速度
sudo /usr/sbin/megacli -AdpSetProp {RebuildRate -40} -aALL
查看rebuild进度
sudo megacli -PDRbld -ShowProg -PhysDrv[32:7] -aAll

设置为good状态
sudo megacli  -PDMakeGood -PhysDrv[24:11] -a0

sudo megacli -cfgforeign -clear -a0
sudo megacli -pdlist -aall |grep  good  -B20  >good.txt
cat good.txt | grep "Enclosure Device ID" |cut -d : -f 2 |cut -d " " -f 2 >e.txt
cat good.txt | grep "Slot Number" |cut -d : -f 2|cut -d " " -f 2 >s.txt
paste e.txt s.txt -d ":" >es.txt
for i in `cat es.txt`;do sudo /usr/sbin/megacli -PDHSP -Set -Dedicated -Array1 -physdrv[$i] -a0 ;done
sudo /usr/sbin/megacli -AdpSetProp {RebuildRate -40} -aALL

查看JBOD模式
sudo /usr/sbin/megacli -AdpGetProp -enablejbod -aALL

关闭jbod模式
sudo /usr/sbin/megacli -AdpSetProp -EnableJBOD -0 -aALL
打开jbod模式
sudo /usr/sbin/megacli  -AdpSetProp -EnableJBOD -1 -aALL

sudo megacli -pdlist -aall   |grep "Predictive Failure Count" 
sudo megacli -pdlist -aall    |grep "Media Error Count"


old_raid=`cat /proc/mdstat|grep md |awk '{print $1}'`
sudo  mdadm -S /dev/${old_raid}
cat /dev/null  |sudo  tee  /etc/mdadm/mdadm.conf
disk=`lsblk |grep disk |grep -v G |awk '{print $1}'|sed "s/^/\/dev\//g"`
sudo mdadm --zero-superblock $disk
num=`echo $disk |xargs -n 1 |wc -l`
echo y |sudo mdadm -v -C /dev/md0 -l 0 -n $num   $disk
sudo mkfs.xfs /dev/md0 -f
sudo mkdir -p /data
sudo chown -R ipfsbit. /data
uuid=`ls -l /dev/disk/by-uuid/  |grep md0 |awk '{print $9}'`
sudo sed -i "s#.*/data .*#UUID=\"$uuid\" /data xfs noatime,discard 0 0#g" /etc/fstab
sudo mount /data
