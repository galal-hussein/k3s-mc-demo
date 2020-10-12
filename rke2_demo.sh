#!/bin/bash

#single master multi agent demo
#1 server
#2 agents

NAME_PREFIX=hgalalrke2

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

if [ ! -d rke2 ]; then
	cp -r infra rke2
fi
pushd rke2
terraform init
terraform apply --auto-approve --var 'instance_count=5' --var 'name=hgalalrke2'
ips=$(terraform output k3s_demo_ips)
sleep 10
sed -i.bu -n '3,/#startdemo/p;/#enddemo/,$p' /etc/hosts
sed -i.bu '/#startdemo/,/#enddemo/d' /etc/hosts
echo "#startdemo" >> /etc/hosts
count=0
echo
info 'Embedded DB HA Setup'
info '=================================================================='
for i in `echo $ips | sed "s/,/ /g"`; do
	echo "$i ${NAME_PREFIX}-${count}" >> /etc/hosts
	ssh -i ~hussein/.ssh/id_rsa -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" ubuntu@${NAME_PREFIX}-${count} "sudo hostnamectl set-hostname $NAME_PREFIX-${count}" 2> /dev/null &
	count=$((count+1))
done
echo "#enddemo" >> /etc/hosts
info '=================================================================='
popd
