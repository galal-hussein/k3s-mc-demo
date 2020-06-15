#!/bin/bash

#single master multi agent demo
#1 server
#2 agents

NAME_PREFIX=demo3

info()
{
    echo '[INFO] ' "$@"
}
fatal()
{
    echo '[ERROR] ' "$@" >&2
    exit 1
}


set -e

if [ ! -d external_db ]; then
	cp -r infra external_db
fi
pushd external_db
terraform init
terraform apply --auto-approve --var 'instance_count=4' --var 'name=hgalaldemo3'
ips=$(terraform output k3s_demo_ips)
sleep 10
sed -i -n '3,/#startdemo3/p;/#enddemo3/,$p' /etc/hosts
sed -i '/#startdemo3/,/#enddemo3/d' /etc/hosts
echo "#startdemo3" >> /etc/hosts
count=0
echo 
info 'External DB HA'
info '=================================================================='
for i in `echo $ips | sed "s/,/ /g"`; do
	echo "$i ${NAME_PREFIX}-${count}" >> /etc/hosts
	ssh -i /home/hussein/.ssh/id_rsa -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" ubuntu@${NAME_PREFIX}-${count} "sudo hostnamectl set-hostname $NAME_PREFIX-${count}" 2> /dev/null &
	if [ $count -eq 0 ]; then
		info "name: $NAME_PREFIX-$count, command to run: (docker run -d -p 3306:3306 -e MYSQL_ROOT_PASSWORD=k3spass mysql:5.7)"
		MYSQL_IP=$i
	else
		info "name: $NAME_PREFIX-$count, command to run: (curl -sfL https://get.k3s.io | sh -s - server --token k3sdemo3 --datastore-endpoint='mysql://root:k3spass@tcp("${MYSQL_IP}":3306)/k3sdb')"
	fi
	count=$((count+1))
done
echo "#enddemo3" >> /etc/hosts
info '=================================================================='
popd
