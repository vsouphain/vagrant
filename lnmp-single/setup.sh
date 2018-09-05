#/bin/sh

# install some tools
sudo yum install -y git wget curl vim gcc glibc-static telnet bridge-utils

# set aliyun yum source
sudo mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
sudo wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
sudo wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
sudo yum clean all
sudo yum makecache
sudo yum -y update

sudo yum install -y tcl tcl-devel expect

sudo sh -c 'echo "192.30.252.123 www.github.com" >>  /etc/hosts'
sudo sh -c 'echo "192.30.253.113 github.com" >>  /etc/hosts'
sudo sh -c 'echo "192.30.253.116 api.github.com" >>  /etc/hosts'
sudo sh -c 'echo "151.101.72.133 assets-cdn.github.com" >>  /etc/hosts'
sudo sh -c 'echo "185.31.18.133 avatars0.githubusercontent.com" >>  /etc/hosts'
sudo sh -c 'echo "185.31.19.133 avatars1.githubusercontent.com" >>  /etc/hosts'
sudo sh -c 'echo "52.206.76.142 collector.githubapp.com" >>  /etc/hosts'

# install php 7.x
sudo yum install -y epel-release
sudo rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
sudo yum install -y --skip-broken mod_php72w php72w-*

# install nginx
sudo yum install -y nginx

# install mysql images


# set develop user
user="develop"
password="123456"
sudo groupadd $user
sudo adduser $user -g $user
sudo sh -c "echo '%$user ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/$user"

expect << EOF
spawn sudo passwd $user
expect "New password:"
send "${password}\r"
expect "Retype new password:"
send "${password}\r"
expect eof;
EOF

sudo mv /etc/ssh/sshd_config /etc/ssh/sshd_config.bk
sudo cp /vagrant/sshd_config /etc/ssh/sshd_config
sudo systemctl restart sshd
