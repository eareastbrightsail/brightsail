#!/usr/bin/bash
#作者：brightsail
#
#
#
#
#
#
while true
do
clear
PS3='请选择想要部署的MySQL版本:'
select bbb in "MySQL5.7"  "MySQL5.6" "exit"
do
read -p "请确定："  bb
case $bb in 
            1) clear
               PS3='请选择想要部署Mysql的方式：'
#使用select语句创建菜单
               select ss in " m" "Source code" "binary system" "yum" "exit"
               do
                    read -p "请选择：" aaa
#使用case语句进行选项判断
                    case  $aaa  in
                             1)  echo "这是rpm安装MySQL"

#禁用SELINUX，firewalld，清除iptables
                                 sed -ri '/^SELINUX=/cSELINUX=disabled' /etc/selinux/config  &> /dev/null
                                 iptables -F &> /dev/null
                                 iptables -t nat -F &/dev/null
                                 systemctl stop firewalld &> /dev/null
                                 systemctl disabled firewalld &> /dev/null


                                 systemctl status mysqld | grep Active &> /dev/null
                                 if [ $? -eq 0 ]
                                 then
                                       echo "MySQL已经安装！"
                                       exit 1
                                 else
                                       echo "正在安装中！"
                                 fi
                                 ls | grep  mysql5.7._rpm.tar.gz 
                                 if [ $? -eq 0 ]
                                 then
                                           echo "Source code package已经上传！"
                                           tar xf mysql5.7._rpm.tar.gz  &> /dev/null
                                 else
                                           echo " not source code package!"
                                           exit 2

                                 fi

#删除系统自带的mariadb包
                                 rpm -e --nodeps mariadb-libs 
 rpm -ivh mysql-community-common-5.7.24-1.el7.x86_64.rpm &> /dev/null
 rpm -ivh mysql-community-libs-5.7.24-1.el7.x86_64.rpm   &> /dev/null
 rpm -ivh mysql-community-client-5.7.24-1.el7.x86_64.rpm &> /dev/null
 rpm -ivh mysql-community-server-5.7.24-1.el7.x86_64.rpm &> /dev/null
#初始化数据库
#跳过主机名解析，提高连接速度
 echo skip-name-resolve >> /etc/my.cnf

#启动数据库服务
systemctl start mysqld &> /dev/null
systemctl enable mysqld &> /dev/null

#获取随机的初始密码 (mysql5.7开始第一次产生随机密码，且登录后必须修改，否则无法操作数据库)
                            password=$(cat /usr/local/src/var/mysqld.log | grep "root@localhost:" |awk '{print $NF }')
                                     echo "MySQL5.7安装成功！"                                     
                                     echo "这是MySQL初始化密码：$password "
                                     echo "请进入数据库修改密码！"
                             ;;
                             2)  echo "这是Source code安装MySQL"
#禁用SELINUX，firewalld，清除iptables
                                 sed -ri '/^SELINUX=/cSELINUX=disabled' /etc/selinux/config  &> /dev/null
                                 iptables -F &> /dev/null
                                 iptables -t nat -F &/dev/null
                                 systemctl stop firewalld &> /dev/null
                                 systemctl disabled firewalld &> /dev/null


                                 systemctl status mysqld | grep Active &> /dev/null
                                 if [ $? -eq 0 ]
                                 then
                                       echo "MySQL已经安装！"
                                       exit 1
                                 else
                                       echo "正在安装中！"
                                 fi
                                 ls | grep  mysql-5.7.19_source.tar.gz
                                 if [ $? -eq 0 ]
                                 then
                                           echo "Source code package已经上传！"
                                           tar xf mysql-5.7.19_source.tar.gz  &> /dev/null
                                 else
                                           echo " not source code package!"
                                           exit 2

                                 fi
                                 
                                  yum install wget -y &> /dev/null
           wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo &> /dev/null
           wget -O /etc/yum.repos.d/epel.repo https://mirrors.aliyun.com/repo/epel-7.repo &> /dev/null

                                     yum clean all &> /dev/null
                                     yum makecache &> /dev/null
                                     mv boost_1_59_0 /usr/local/boost   &> /dev/null
                                     tar xf mysql-5.7.19.tar.gz -C /usr/local/src &> /dev/null
                                     cd /usr/local/src/mysql-5.7.19/                   
                                     yum -y install gcc-c++ cmake ncurses-devel &> /dev/null
                                     if [ $? -eq 0 ]
                                     then
                                           echo "编译环境准备完成！"
                                     else  
                                           echo "编译环境准备失败，请检查网络！"
                                           exit 3
                                     fi 
                                     yum remove $(rpm -qa | grep mqriadb) -y &> /dev/null
                                     groupadd  mysql -g 27 &> /dev/null
                                     useradd mysql -u 27 -g mysql -s /sbin/nologin &> /dev/null
                                     mkdir -p /usr/local/src/{mysql,data,var}
                                     chown mysql:mysql /usr/local/src/{mysql,data,var}                
                                     cmake  -DCMAKE_INSTALL_PREFIX=/usr/local//src/mysql -DMYSQL_DATADIR=/usr/local/src/data  -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DMYSQL_TCP_PORT=3306 -DMYSQL_UNIX_ADDR=/tmp/mysql.sock  -DMYSQL_USER=mysql -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1    -DDOWNLOAD_BOOST=1 -DWITH_BOOST=/usr/local/boost    &> /dev/null
                                     make  &> /dev/null
                                     make install &> /dev/null
                                     mv /etc/my.cnf /etc/my.cnf.bak
                                     cat >/etc/my.cnf<<cwf
[client]
port=3306
socket=/tmp/mysql.sock
[mysqld]
character-set-server=utf8
collation-server=utf8_general_ci
skip-name-resolve
user=mysql
port=3306
basedir=/usr/local/src/mysql
datadir=/usr/local/src/data/
tmpdir=/tmp
socket=/tmp/mysql.sock
log-error=/usr/local/src/var/mysqld.log
pid-file=/usr/local/src/data/mysqld.pid
cwf
                                     echo "export PATH=\$PATH:/usr/local/src/mysql/bin" >> /etc/profile
                                     source /etc/profile
                                     /usr/local/src/mysql/bin/mysqld --defaults-file=/etc/my.cnf --initialize --user=mysql
                                     if [ $? -eq 0 ]
                                     then
                                          echo "MySQL初始化成功！"
                                     else 
                                          exit 4
                                     fi
                                     #将MySQL服务添加到systemctl服务程序进行管理
                                     cp /usr/local/src/mysql/support-files/mysql.server /etc/rc.d/init.d/mysqld   
                                     systemctl daemon-reload
                                     systemctl start mysqld                  
                                     password=$(cat /usr/local/src/var/mysqld.log | grep "root@localhost:" |awk '{print $NF }')
                                     echo "MySQL5.7安装成功！"                                     
                                     echo "这是MySQL初始化密码：$password "
                                     echo "请执行source /etc/profile 刷新下环境！并进入数据库修改密码！"
                                      
                                ;;
                             3)  systemctl status mysqld | grep Active &> /dev/null
                                 if [ $? -eq 0 ]
                                 then  
                                       echo "MySQL已经安装！"
                                       exit 1
                                 else
                                       echo "正在安装中！"
                                 fi
                
                                 
               
               
               
                                 ls | grep  mysql-5.7.30-linux-glibc2.12-x86_64.tar.gz 
                                 if [ $? -eq 0 ]
                                 then
                                           echo "binary system 包已经上传！"
                                           tar xf mysql-5.7.30-linux-glibc2.12-x86_64.tar.gz &> /dev/null
                                 else   
                                           echo " not binary system package!"
                                           exit 2                             
                                  
                                 fi 
                                 yum remove $(rpm -qa | grep mqriadb) -y &> /dev/null
                                 groupadd  mysql -g 27 &> /dev/null
                                 useradd mysql -u 27 -g mysql -s /sbin/nologin &> /dev/null
                                 mkdir -p /mysql/{mysql,data,var} &> /dev/null
                                 chown -Rf mysql:mysql /mysql/{mysql,data,var} &> /dev/null
                                 echo "export PATH=\$PATH:/mysql/mysql/bin "  >> /etc/profile 
                                 source /etc/profile 
                                 tar xvf mysql-5.7.30-linux-glibc2.12-x86_64.tar.gz &> /dev/null
                                 mv mysql-5.7.30-linux-glibc2.12-x86_64/* /mysql/mysql/ &> /dev/null
                                   cat > /etc/my.cnf << cwf
[mysqld]
user=mysql #指定用户
basedir=/mysql/mysql #应用程序所在目录
datadir=/mysql/data #数据库数据存储目录路径
server_id=6 #id号,主从中主要用，指定master id
log-error=/mysql/var/error.log #错误日志存放路径。
pid-file=/mysql/data/mysql.pid #进程pid文件。
port=3306 #默认端口号
socket=/tmp/mysql.sock #sock连接的接口
[mysql]
socket=/tmp/mysql.sock 
cwf
                                  mysqld --initialize  --user=mysql --basedir=/mysql/mysql --datadir=/mysql/data &> /dev/null
                                  if [ $? -eq 0 ]
                                  then
                                         echo "MySQL 初始化成功!"
                                  else 
                                         echo "MySQL 初始化失败!"
                                         exit 3
                                  fi     
                
                                   cp /mysql/mysql/support-files/mysql.server /etc/rc.d/init.d/mysqld &> /dev/null
                                   chkconflg --add mysqld &> /dev/null
                                     password=$(cat /mysql/var/error.log | grep "root@localhost:" |awk '{print $NF }')
                                     echo "这是MySQL初始化密码：$password "
                                     systemctl enable mysqld  &> /dev/null
                                     systemctl restart mysqld &> /dev/null
                                    if [ $? -eq 0 ] 
                                    then
                                          echo "MySQL binary system install successful ！"
                                    else
                                             cat /mysql/var/error.log | grep error 
                                      fi
                
                
                
                              ;;
                              4)  echo "这是yum安装MySQL"
wget http://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm &> /dev/null
rpm -ivh mysql57-community-release-el7-11.noarch.rpm &> /dev/null
yum -y install mysql-server --nogpgcheck &> /dev/null
systemctl start mysqld &> /dev/null
systemctl enabled mysqld &> /dev/null
password=$(cat /var/log/mysqld.log | grep "root@localhost:" |awk '{print $NF }')
                                     echo "这是MySQL初始化密码：$password "
                                     echo "MySQLrpm安装成功！"
                              ;;
                              5) exit 0
                              ;;
                        
                     esac
                        
                
                done
                ;;

           2)  clear
               echo "这是MySQL5.6！"
              clear
               PS3='请选择想要部署Mysql的方式：'
#使用select语句创建菜单
               select ss in " m" "Source code" "binary system" "yum" "exit"
               do
                    read -p "请选择：" aaa
#使用case语句进行选项判断
                    case  $aaa  in
                             1)  echo "这是rpm安装MySQL"
                             ;;
                             2)  echo "这是Source code安装MySQL"
#禁用SELINUX，firewalld，清除iptables
                                 sed -ri '/^SELINUX=/cSELINUX=disabled' /etc/selinux/config  &> /dev/null
                                 iptables -F &> /dev/null
                                 iptables -t nat -F &>/dev/null
                                 systemctl stop firewalld &> /dev/null
                                 systemctl disabled firewalld &> /dev/null


                                 systemctl status mysqld | grep Active &> /dev/null
                                 if [ $? -eq 0 ]
                                 then
                                       echo "MySQL已经安装！"
                                       exit 1
                                 else
                                       echo "正在安装中！"
                                 fi
                                 ls | grep  mysql-5.6.19.tar.gz
                                 if [ $? -eq 0 ]
                                 then
                                           echo "Source code package已经上传！"
                                           tar xf mysql-5.6.19.tar.gz -C /usr/local/src  &> /dev/null
                                 else
                                           echo " not source code package!"
                                           exit 2

                                 fi
                                 
                                  yum install wget -y &> /dev/null
           wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo &> /dev/null
           wget -O /etc/yum.repos.d/epel.repo https://mirrors.aliyun.com/repo/epel-7.repo &> /dev/null

                                     yum clean all &> /dev/null
                                     yum makecache &> /dev/null
#                                     mv boost_1_59_0 /usr/local/boost   &> /dev/null
#                                     tar xf mysql-5.6.19.tar.gz -C /usr/local/src &> /dev/null
                                     cd /usr/local/src/mysql-5.6.19/                   
                                     yum -y install gcc-c++ cmake ncurses-devel perl* --skip-broken &> /dev/null
                                     
                                     if [ $? -eq 0 ]
                                     then
                                           echo "编译环境准备完成！"
                                     else  
                                           echo "编译环境准备失败，请检查网络！"
                                           exit 3
                                     fi 
#删除Linux系统内置的mariadb
                                     yum remove $(rpm -qa | grep mqriadb) -y &> /dev/null
#创建mysql用户和组
                                     groupadd  mysql -g 27 &> /dev/null
                                     useradd mysql -u 27 -g mysql -s /sbin/nologin &> /dev/null
#创建mysql安装目录和数据存放目录和日志目录，并给予权限
                                     mkdir -p /usr/local/src/{mysql,data,var}
                                     chown mysql:mysql /usr/local/src/{mysql,data,var}
#用cmake进行预编译                
                                     cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/src/mysql -DMYSQL_DATADIR=/usr/local/src/data -DSYSCONFDIR=/etc/   &> /dev/null
                                     make  &> /dev/null
                                     make install &> /dev/null
                                     mv /etc/my.cnf /etc/my.cnf.bak
#修改配置文件
                                     cat >/etc/my.cnf<<cwf
[client]
port=3306
socket=/tmp/mysql.sock
[mysqld]
character-set-server=utf8
collation-server=utf8_general_ci
skip-name-resolve
user=mysql
port=3306
basedir=/usr/local/src/mysql
datadir=/usr/local/src/data/
tmpdir=/tmp
socket=/tmp/mysql.sock
log-error=/usr/local/src/var/mysqld.log
pid-file=/usr/local/src/data/mysqld.pid
cwf
                                     echo "export PATH=\$PATH:/usr/local/src/mysql/bin" >> /etc/profile
                                     source /etc/profile
                                     cd /usr/local/src/mysql
                                     /usr/local/src/mysql/scripts/mysql_install_db --defaults-file=/etc/my.cnf --user=mysql --basedir=/usr/local/src/mysql --datadir=/usr/local/src/data

                                     if [ $? -eq 0 ]
                                     then
                                          echo "MySQL初始化成功！"
                                     else 
                                          exit 4
                                     fi
                                     #将MySQL服务添加到systemctl服务程序进行管理
                                     cp /usr/local/src/mysql/support-files/mysql.server /etc/rc.d/init.d/mysqld  
                                     chmod 755 /etc/rc.d/init.d/mysqld &> /dev/null 
                                     systemctl daemon-reload
                                     systemctl start mysqld  
                                     password=1
                                     /usr/local/src/mysql/bin/mysqladmin -u root password "$password"

                                     password=$(cat /usr/local/src/var/mysqld.log | grep "root@localhost:" |awk '{print $NF }')
                                     echo "MySQL5.6安装成功！"                                     
                                     echo "这是MySQL初始化密码：$password "
                                     echo "请执行source /etc/profile 刷新下环境！并进入数据库修改密码！"
                                      
                             
                                
                                      
                             
                                ;;
                              3);;
                              4)
                                wget http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm &> /dev/null
                               rpm -ivh mysql-community-release-el7-5.noarch.rpm &> /dev/null
                               yum install mysql-server -y &> /dev/null
                               systemctl start mysqld &> /dev/null
                               systemctl status mysqld &> /dev/null
                               echo "MySQLyum安装完成，root密码默认为空！"

                              ;;
                              5) exit 0
                              ;;
                   esac
                  done
                  ;;
                          3)  exit 0
                          ;;
esac
done
done
