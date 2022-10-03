#!/bin/bash
sudo amazon-linux-extras install epel
sudo yum update -y
sudo yum install wget -y
cd /tmp/
sudo yum install epel-release
sudo amazon-linux-extras install epel
sudo yum install erlang
sudo yum install rabbitmq-server -y
sudo systemctl start rabbitmq-server
sudo systemctl enable rabbitmq-server
sudo systemctl status rabbitmq-server
sudo sh -c 'echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config'
sudo rabbitmqctl add_user test test
sudo rabbitmqctl set_user_tags test administrator
sudo systemctl restart rabbitmq-server
sudo systemctl status rabbitmq-server
