#!/bin/bash

#single master multi agent demo
#1 server
#2 agents

NAME_PREFIX=demo1

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

if [ "$EUID" -ne 0 ]
  then fatal "Please run as root"
  exit
fi

if [ ! -d single_server_multi_agents ]; then
	cp -r infra single_server_multi_agents
fi
pushd single_server_multi_agents
terraform init
terraform apply --auto-approve --var 'instance_count=4'
ips=$(terraform output k3s_demo_ips)
sleep 10
sed -i.bu -n '3,/#startdemo1/p;/#enddemo1/,$p' /etc/hosts
sed -i.bu '/#startdemo1/,/#enddemo1/d' /etc/hosts
echo "#startdemo1" >> /etc/hosts
count=0
echo 
info 'Single Server Multi Agents'
info '=================================================================='
for i in `echo $ips | sed "s/,/ /g"`; do
	echo "$i ${NAME_PREFIX}-${count}" >> /etc/hosts
	ssh -i ~hussein/.ssh/id_rsa -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" ubuntu@${NAME_PREFIX}-${count} "sudo hostnamectl set-hostname $NAME_PREFIX-${count}" 2> /dev/null &
	if [ $count -eq 0 ]; then
		info "name: $NAME_PREFIX-$count, command to run: (curl -sfL https://get.k3s.io | sh -s - server --token k3sdemo1)"
		SERVER_IP=$i
	else
		info "name: $NAME_PREFIX-$count, command to run: (curl -sfL https://get.k3s.io | sh -s - agent --server https://${SERVER_IP}:6443 --token k3sdemo1)"
	fi
	count=$((count+1))
done
echo "#enddemo1" >> /etc/hosts
info '=================================================================='
popd
