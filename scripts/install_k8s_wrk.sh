#!/bin/bash

######### ** FOR WORKER NODE ** #########

hostname k8s-wrk-${worker_number}
echo "k8s-wrk-${worker_number}" > /etc/hostname

export AWS_ACCESS_KEY_ID=${access_key}
export AWS_SECRET_ACCESS_KEY=${private_key}
export AWS_DEFAULT_REGION=${region}


apt update
apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"

#Installing Docker
apt update
apt-cache policy docker-ce
apt install docker-ce -y
apt install awscli -y

#Be sure to understand, if you follow official Kubernetes documentation, in Ubuntu 20 it does not work, that is why, I did modification to script
#Adding Kubernetes repositories

#Next 2 lines are different from official Kubernetes guide, but the way Kubernetes describe step does not work
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add
echo "deb https://packages.cloud.google.com/apt kubernetes-xenial main" > /etc/apt/sources.list.d/kurbenetes.list

#Turn off swap
swapoff -a

#Installing Kubernetes tools
apt update
apt install kubelet kubeadm kubectl -y

#next line is getting EC2 instance IP, for kubeadm to initiate cluster
#we need to get EC2 internal IP address- default ENI is eth0
export ipaddr=`ip address|grep eth0|grep inet|awk -F ' ' '{print $2}' |awk -F '/' '{print $1}'`


# the kubeadm init won't work entel remove the containerd config and restart it.
rm /etc/containerd/config.toml
systemctl restart containerd

# to insure the join command start when the installion of master node is done.
sleep 1m

aws s3 cp s3://${s3buckit_name}/join_command.sh /tmp/.
chmod +x /tmp/join_command.sh
bash /tmp/join_command.sh
