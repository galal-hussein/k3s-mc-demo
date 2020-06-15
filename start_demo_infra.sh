#!/bin/bash

set -e

terraform init
terraform apply --auto-approve

ips=$(terraform output k3s_demo_ips)


sed -i -n '3,/#start/p;/#end/,$p' /etc/hosts
sed -i '/#start/,/#end/d' /etc/hosts
echo "#start" >> /etc/hosts
count=0
for i in `echo $ips | sed "s/,/ /g"`; do
	echo "$i demo${count}" >> /etc/hosts
        sleep 30
	ssh -i /home/hussein/.ssh/id_rsa -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" ubuntu@demo${count} "sudo hostnamectl set-hostname demo${count}"
	count=$((count+1))
done
	
echo "#end" >> /etc/hosts

