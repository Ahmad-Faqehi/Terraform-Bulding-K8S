# Terraform to Bulding Kubernetes Cluster
I build this project to create my own lab for Kuberntes cluster on AWS cloud. I found [Terraform](https://www.terraform.io) is best tool to create my K8S lab fastly with only one command 🚀.

![Terraform](https://i.imgur.com/PuS3rmb.png)

## Terraform Resources Used
- EC2
  - One Master Node
  - One Worker Node (can be increased)
- VPC
  - Public Subnet
  - Internet Gateway
  - Route Table
  - Security Group
- S3 Bucket

<hr>

## How Will the Kubernetes Cluster Be Built?
The goals is to build K8S cluster with one master node and one worker node.
<br>

* First, the master node will boots up and will start installing <b>kubeadm</b>, <b>kubelet</b>, <b>kubectl</b>, and <b>docker</b>. Then will run `kubeadm init` to initial the k8s cluster.<br>
Here the challenge become, how to get the join command that showed after init the cluster and send it to the workers node for joining the worker node into the cluster 🤔? <br>
To solve this problem I use <b>s3 bucket</b>. First I extract the join command and saved into a file, then push it to s3 object. Now we finish from master node and is ready.
<br>

* Second, the workers node will boots up and will start installing <b>kubeadm</b>, <b>kubelet</b>, <b>kubectl</b>, and <b>docker</b>. Then will featch the joind command from <b>s3 bucket</b> and excuted to join the worker node into cluster.

<hr>

## Accessing Your Cluster
* You can access your cluster by accessing the master node throw <b>ssh</b>, you cat get the public IP from terrform outputs. below is example of ssh command:
``` shell
ssh -i <Your_Key_Piar> ubuntu@<MasterNode_Public_IP>
```
Then switch to root user to use `kubectl` command 