#!/bin/bash
#
#Author			yuankun
#Date			2022-09-29
#Filename		install_mysql-8.0.28-linux-glibc2.12-x86_64.sh

. /etc/init.d/functions

color='echo -e \E[01;31m'

end='\E[0m'

# 设置mysql root用户密码
MYSQL_ROOT_PASSWD=123456
MYSQL_VERSION=mysql-8.0.28-linux-glibc2.12-x86_64.tar.xz

check(){
	${color}安装前环境检查......${end}	

	# 判断当前用户是否是root用户，不是则退出安装
	if [ ${UID} -ne 0 ];then
		action "当前用户不是root,安装失败!" false
		exit
	fi
	# 判断是否安装wget，没有安装则使用yum安装wget
	rpm -q wget || yum install -y wget
	
	# 判断/usr/local/mysql目录是否存在，存在则exit
	if [ -e /usr/local/mysql ];then
		${color}"mysql已经安装,安装失败!"${end}
		exit
	fi
	# 下载二进制程序包	
	wget https://cdn.mysql.com/archives/mysql-8.0/mysql-8.0.28-linux-glibc2.12-x86_64.tar.xz || ｛ echo '下载失败'; exit; }
	
	# 判断二进制程序包是否存在
	if [ ! -e ${MYSQL_VERSION} ];then
		${color}"文件不存在,安装失败!"${end}
		${color}"请检查脚本以及主机环境，然后再次尝试安装。即将退出安装流程!"${end}
		exit
	else
		${color}"安装前环境检查完毕,环境要求满足!"${end}
	fi
}
# 安装mysql
install_mysql(){
	${color}"开始安装mysql......"${end}
	# 安装依赖
	yum install -y -q libaio numactl-libs
	# 解压缩
	tar xf ${MYSQL_VERSION} -C /usr/local/
	cd /usr/local/
	MYSQL_FILE=`echo ${MYSQL_VERSION} | sed -nr 's/^(.*[0-9]).*/\1/p'`
	ln -s /usr/local/${MYSQL_FILE} /usr/local/mysql
	chown -R root.root /usr/local/mysql/
	id mysql &> /dev/null || { useradd -s /sbin/nologin -r mysql ; action "创建mysql用户"; }
	
	# 环境变量
	echo 'PATH=/usr/local/mysql/bin/:$PATH' > /etc/profile.d/mysql.sh
	. /etc/profile.d/mysql.sh
	ln -s /usr/local/mysql/bin/* /usr/bin/
	# 配置文件
	cat > /etc/my.cnf <<-EOF
[mysqld]
server-id=1
log-bin
datadir=/data/mysql
socket=/data/mysql/mysql.sock
log-error=/data/mysql/mysql.log
pid-file=/data/mysql/mysql.pid
[client]
socket=/data/mysql/mysql.sock
EOF
	[ -d /data ] || mkdir /data
	mysqld --initialize --user=mysql --datadir=/data/mysql
	cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
	chkconfig --add mysqld
	chkconfig mysqld on
	service mysqld start
	[ $? -ne 0 ] && { $color"数据库启动失败，退出!"$end;exit; }
	sleep 3
	MYSQL_OLDPASSWORD=`awk '/A temporary password/{print $NF}' /data/mysql/mysql.log`
	mysqladmin -uroot -p${MYSQL_OLDPASSWORD} password ${MYSQL_ROOT_PASSWD} &>/dev/null
	action "数据库安装完成"
}
# 调用函数
check
install_mysql
