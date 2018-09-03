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

# install docker
sudo yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager -y --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce

# sudo sh -c 'echo "{\"registry-mirrors\": [\"https://registry.docker-cn.com\"]}" > /etc/docker/daemon.json'

# start docker service
sudo groupadd docker
sudo usermod -aG docker vagrant
sudo systemctl start docker


# set develop user
#sudo groupadd develop
#sudo adduser develop -g develop
#sudo usermod -aG develop develop
#sudo sh -c 'echo "%develop ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/develop'
sudo chmod +x /vagrant/user.sh && /vagrant/user.sh
sudo systemctl restart sshd