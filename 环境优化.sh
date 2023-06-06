#! /usr/bin/bash
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config &> /dev/null
setenforce 0
systemctl stop firewalld &> /dev/null
systemctl disable firewalld &> /dev/null
iptables -F
iptables -t nat -F
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
yum install -y iptables-services
service iptables save 
systemctl stop NetworkManager &> /dev/null
systemctl disable NetworkManager &> /dev/null
echo 1 > /proc/sys/net/ipv4/ip_forward
yum install -y vim lrzsz wget net-tools zip unzip elinks bash-completion
wget -O /etc/yum.repos.d/epel.repo https://mirrors.aliyun.com/repo/epel-7.repo
yum clean all
yum makecache

exit 0

