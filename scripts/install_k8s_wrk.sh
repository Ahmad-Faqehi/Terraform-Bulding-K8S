#!/bin/bash

######### ** FOR WORKER NODE ** #########

# hostname k8s-wrk-01
# echo "k8s-wrk-01" > /etc/hostname

export AWS_ACCESS_KEY_ID=${access_key}
export AWS_SECRET_ACCESS_KEY=${private_key}
export AWS_DEFAULT_REGION=us-east-1


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

#this adds .kube/config for root account, run same for ubuntu user, if you need it
# mkdir -p /root/.kube
# cp -i /etc/kubernetes/admin.conf /root/.kube/config

#Line bellow only if you need to run for user ubuntu

#Installing network CNI, here are examples of Calico and Flannel, but you can replace with others
#You need to uncomment one of 2 next lines — flannel and calico used here as an example. Example below is using calico

#Uncomment next line if you want flannel Cluster Pod Network
#curl -o /root/kube-flannel.yml https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
#kubectl — kubeconfig /root/.kube/config apply -f /root/kube-flannel.yml

#Uncomment next line if you want calico Cluster Pod Network
#curl -o /root/calico.yaml https://docs.projectcalico.org/v3.16/manifests/calico.yaml
#kubectl --kubeconfig /root/.kube/config apply -f /root/calico.yaml