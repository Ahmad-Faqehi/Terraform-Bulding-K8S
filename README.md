# Terraform to Bulding Kubernetes Cluster using EC2 instances
[![LinkedIn][linkedin-shield]][linkedin-url]
[![Twitter][twitter-shield]][twittwe-url]
[![Twitter][github-shield]][github-url]

I build this project to create my own lab for [Kuberntes](https://kubernetes.io/) cluster on AWS cloud using EC2 instances. I found [Terraform](https://www.terraform.io) is best tool to create my K8S lab fastly with one command 🚀.
<p align="center">

![Terraform](https://i.imgur.com/PuS3rmb.png)
</p>

## Terraform Resources Used
- EC2
  - One Master Node
  - Two Worker Node (can be increased)
- VPC
  - Public Subnet
  - Internet Gateway
  - Route Table
  - Security Group
- S3 Bucket

<hr>

## How Will the Kubernetes Cluster Be Built?
The goals is to build K8S cluster with one master node and two worker nodes.
<br>

* First, the master node will boots up and will start installing <b>kubeadm</b>, <b>kubelet</b>, <b>kubectl</b>, and <b>docker</b>. Then will run `kubeadm init` to initial the k8s cluster. <br>
Here the challenge become, how to get the join command that showed after init the cluster and send it to the workers node for joining the worker node into the cluster 🤔? <br>
To solve this problem I use <b>s3 bucket</b>. First I extract the join command and saved into a file, then push it to s3 object. Now we finish from master node and is ready.
<br>

* Second, the workers node will boots up and will start installing <b>kubeadm</b>, <b>kubelet</b>, <b>kubectl</b>, and <b>docker</b>. Then will featch the joind command from <b>s3 bucket</b> and excuted to join the worker node into cluster.

<hr>

## Incress Number of Worker Nodes
* By default there are two workers on the cluster, to incress it go to `variables.tf` file and looking for <b>number_of_worker</b> variable, you can incress the default number.

<hr>

## Requirements Before Running
1- Make sure you have the terrafrom tools installed on your machine.

2- Add your Access key, Secret key and Key Pair name on `variables.tf` file.

3- Make sure your IAM user has right permission to creating EC2, VPC, S3, Route Table, Security Group and Internet Gateway.

## Running the Script
After doing the requirements, you are ready now, start clone the repo to your machine:
``` shell
git clone https://github.com/Ahmad-Faqehi/Terraform-Bulding-K8S.git
cd Terraform-Bulding-K8S/
```
Now execute terraform commands:
``` shell
terraform init
terraform plan #to show what going to build
terraform apply
```

## Accessing Your Cluster
* You can access your cluster by accessing the master node throw <b>ssh</b>, you can get the public IP of master node from terrform outputs. Below is example of ssh command:
``` shell
ssh -i <Your_Key_Piar> ubuntu@<MasterNode_Public_IP>
```

* Another way to access the cluster by download the `admin.conf` file from master node to your machine, find below the way to download it and aceess the cluster remotely.
``` shell
scp -i <Your_Key_Piar> ubuntu@<MasterNode_Public_IP>:/tmp/admin.conf .
```
This will download the kubernetes config file on your machine. Before using this config file, you have to replace the private ip to public ip of master node. Then you can fastly used by following commann to start accessing the cluster.
```shell
kubectl --kubeconfig ./admin.conf get nodes
```

## Removing and Destroying Kuberntes Cluster
To destroy the hole resources that created after applying the script, just run the following command:
```shell
terraform destroy
```


<!-- CONTACT -->
## Contact Me

Ahmad Faqehi - [iAhmad.info](https://iAhmad.info) - alfaqehi775@hotmail.com

Project Link: [https://github.com/Ahmad-Faqehi/Terraform-Bulding-K8S](https://github.com/Ahmad-Faqehi/Terraform-Bulding-K8S)


<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/ahmad-faqehi
[twitter-shield]: https://img.shields.io/badge/-twitter-black.svg?style=for-the-badge&logo=twitter&colorB=555
[twittwe-url]: https://twitter.com/A_F775
[github-shield]: https://img.shields.io/badge/-github-black.svg?style=for-the-badge&logo=github&colorB=555
[github-url]: https://github.com/Ahmad-Faqehi