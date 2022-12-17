# Terraform to Bulding Kubernetes Cluster
I build this project to create my own lab for Kuberntes cluster on AWS cloud. I found [Terraform](https://www.terraform.io) is best tool to create my K8S lab fastly with only one command.


## How going to build the k8s cluster?
The goals is to build k8s cluster with one master node and one worker node, so in `main.tf` will find two EC2 instance resources and S3 bucket, the s3 bucket is for shairing the join command between master node and worker node.
<br>
* First, the master node will boots up and will start installing <b>kubeadm</b>, <b>kubelet</b>, <b>kubectl</b>, and <b>docker</b>. Then will run `kubeadm init` to initial the k8s cluster.<br>
Here the challenge become, how to get the join commadn that showed after init the cluster and send it to worker node to joining the worker node into the cluster? <br>
To solve this problem I use <b>S3 bucket</b>. First I get the join command and saved into file, then push it to s3 object. Now we finish from master node and is ready.
<br>
* The worker node, will boots up and will start installing <b>kubeadm</b>, <b>kubelet</b>, <b>kubectl</b>, and <b>docker</b>. Then will featch the joind command from <b>S3 bucket</b> and excuted to join the worker node into cluster.
