#/bin/sh

# install some tools
sudo yum install -y git wget curl vim gcc glibc-static telnet bridge-utils net-tools lrzsz zip unzip kde-l10n-Chinese ntp bash-completion

#auto completion
sudo source /usr/share/bash-completion/bash_completion

# set aliyun yum source
sudo mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
sudo wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
sudo wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
sudo yum clean all
sudo yum makecache
sudo yum -y update

# set github hosts map 

sudo sh -c 'echo "192.30.252.123 www.github.com" >>  /etc/hosts'
sudo sh -c 'echo "192.30.253.113 github.com" >>  /etc/hosts'
sudo sh -c 'echo "192.30.253.116 api.github.com" >>  /etc/hosts'
sudo sh -c 'echo "151.101.72.133 assets-cdn.github.com" >>  /etc/hosts'
sudo sh -c 'echo "185.31.18.133 avatars0.githubusercontent.com" >>  /etc/hosts'
sudo sh -c 'echo "185.31.19.133 avatars1.githubusercontent.com" >>  /etc/hosts'
sudo sh -c 'echo "52.206.76.142 collector.githubapp.com" >>  /etc/hosts'

# sync time
sudo systemctl enable ntpd
sudo systemctl start ntpd
sudo timedatectl set-timezone Asia/Shanghai
sudo timedatectl set-ntp yes
sudo ntpq -p

# set develop user
sudo yum install -y tcl tcl-devel expect

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

#update ssh login config
sudo sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
sudo systemctl restart sshd

#install chinese charset
sudo yum reinstall -y glibc-common
sudo \cp  /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
sudo sh -c "echo 'LANG=\"zh_CN.UTF-8\"' > /etc/locale.conf"

#install java jdk development
sudo yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel
sudo sh -c 'cat /vagrant/profile >> /etc/profile' && sudo source /etc/profile

# install docker
sudo yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager -y --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce
# sudo sh -c 'echo "{\"registry-mirrors\": [\"https://registry.docker-cn.com\"]}" > /etc/docker/daemon.json'

# install php 7.x
sudo yum install -y epel-release
sudo rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
sudo yum install -y --skip-broken mod_php72w php72w-*

# install hiredis
sudo wget https://github.com/redis/hiredis/archive/v0.13.3.tar.gz
sudo tar xzvf v0.13.3.tar.gz && cd hiredis-0.13.3/ && sudo make -j && sudo make install && sudo ldconfig && cd ..

# install nghttp2
sudo wget https://github.com/nghttp2/nghttp2/releases/download/v1.33.0/nghttp2-1.33.0.tar.gz
sudo tar zxvf nghttp2-1.33.0.tar.gz && cd nghttp2-1.33.0/ && sudo ./configure && sudo make && sudo make install && cd ..

# install swoole devel
sudo yum install -y pcre-devel glibc-headers gcc-c++ openssl-devel
sudo wget https://github.com/swoole/swoole-src/archive/v4.2.11.tar.gz
sudo tar zxvf v4.2.11.tar.gz && cd swoole-src-4.2.11 && sudo phpize
sudo ./configure  --enable-openssl --enable-http2 --enable-async-redis --enable-sockets --enable-mysqlnd && sudo make && sudo make install && cd ..
sudo sh -c 'echo "/usr/local/lib" >> /etc/ld.so.conf' && sudo ldconfig
sudo sh -c 'echo "extension=swoole.so" > /etc/php.d/swoole.ini'

# install nginx
sudo yum install -y nginx
sudo sh -c 'echo "Welcome to Nginx" >  /usr/share/nginx/html/index.html'

#create web user www
sudo groupadd www
sudo useradd www -g www

sudo sed -i "s/user nginx/user www/g"  /etc/nginx/nginx.conf
sudo \cp /vagrant/default.conf /etc/nginx/conf.d/default.conf
sudo chown www.www -R /var/lib/php
sudo chown www.www -R /var/lib/nginx


sudo sed -i "s/user = apache/user = www/g"  /etc/php-fpm.d/www.conf
sudo sed -i "s/group = apache/group = www/g"  /etc/php-fpm.d/www.conf
sudo sed -i "s/;listen.owner = nobody/listen.owner = www/g"  /etc/php-fpm.d/www.conf

#set start service
#先关闭selinux，否者无法通过systemctl启动nginx
sudo setenforce 0
sudo sed -i "s/SELINUX=enforcing/SELINUX=disabled/g"  /etc/selinux/config

#共享文件夹开机挂载
sudo sh -c 'echo "/data                                    /data          vboxsf  defaults        0 0" >>  /etc/fstab'

#优化系统内核参数
sudo sed -i '/^#DefaultLimitNOFILE=/aDefaultLimitNOFILE=655350' /etc/systemd/system.conf 
sudo sed -i '/^#DefaultLimitNPROC=/aDefaultLimitNPROC=655350' /etc/systemd/system.conf
sudo sed -i "s/4096/655350/g"  /etc/security/limits.d/20-nproc.conf
sudo sh -c 'cat /vagrant/limits.conf >> /etc/security/limits.conf'
sudo sh -c 'cat /vagrant/sysctl.conf >> /etc/sysctl.conf'
sudo sysctl -p

sudo systemctl enable php-fpm
sudo systemctl enable nginx
sudo systemctl enable docker

echo "安装完成，请在git bash下再次执行vagrant halt && vagrant up命令，进行重启生效"

sudo halt


