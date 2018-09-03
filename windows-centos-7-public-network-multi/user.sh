#!/bin/bash
user=develop
password=123456

sudo groupadd $user
sudo adduser $user -g $user
sudo sh -c 'echo "%$user ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$user'

expect << EOF
spawn sudo passwd $user
expect "New password:"
send "${password}\r"
expect "Retype new password:"
send "${password}\r"
expect eof;
EOF