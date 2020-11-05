

# <b>Article Goal </b>

The primary goal of this article is to  :

* Configure & deploy infrastructure to build out and test Google Cloud Platform (GCP) HTTP Load Balancer using [Hashicorp Terraform](https://www.terraform.io/), an open source "Infrastruture As Code" (IaC) tool.   

* This article will describe and highlight a number of key elements in Hashicorp's Configuration Language (HCL) used in the configuring and deploying HTTP Load Balancer within GCP infrastucture.


***

Google Cloud (GCP) load balancing is implemented at the edge of GCP network, offering load balancing in order to distribute incoming network traffic across multiple virtual machines (VM) instances. This allows for your network traffic to be distributed & load balanced across single or multiple regions close to your users.  

GCP Load Balancing offers the following features:
* Single IP address to serve as the frontend
* Automatic intelligent autoscaling of your backends based on CPU utilization, load capacity & monitoring metrics
* Traffic routing to closest virtual instance 
* Global load balancing for when your applications are available across the world
* High availability & reducancy which means that if a component(e.g virtual instance) fails, it is automatically restarted or replaced.

The  HTTP Load Balancer can manually be configured and provisioned via Google Console. We, however, want to take advantage of key benefits that IaC (Terraform) provides with respects to provisioning and maintaining cloud infrastructure. We are essentially applying the same principles around developing software applications to infrastructure definition and provisioning.  These benefits include :
* Repeatability / Speed - Reliaby rebuild any resource of infrastructure reducing risk.
* Reuse - Code once and reuse many times (e.g Terraform modules)
* Documentation - Code/comments serves to document infrastructure.
* Version Control - Provide history of changes & traceability
* Validation - Test code with effective automated testing


<b>Prerequisites / Setup</b>
==================

## <b>Assumptions </b>
The article will assumes that you have familiarity with cloud computing infrastructure & resources,  Infrastructure as Code (IaC)  and Terraform. In order to set up your environement & create components you will need a Google account , have access to Google Cloud Console and rights within that account to create and administer projects via Google Console.


## <b>GCP Setup</b>

1. Log into your google account and use URL below to create project. For this effort we will name project "http-loadbalancer".
https://console.cloud.google.com/projectcreate

   Add gcp_NewProject.png


2.  Before we start creating infrastructure resources via Terraform we need to create a <b>Service Account</b> in Google Console. Service Account can be used by application(e.g Terraform) to make authorized API calls to create infrastructure resources. Service Accounts are not a user accounts and it does not have passwords associated with them. Service Account are associated with private/public RSA key-pairs that are used for authentication to Google. <BR><BR>
Select your project, Click <b>IAM & Admin</b> menu, <b>Servie Accounts</b> option and then <b>+ Create Service Account</b> button.   "Add gcp_CreateServiceAccount_1 image below."  <BR> <BR>
Enter a name  and description for the Service Account and click the <b>CREATE</b> button.  "Add gcp_CreateServiceAccount_2 image below." <BR><BR>
Give the newly created Service Account project permissions. Add the following roles (Compute Admin & Storage Admin) below and click the <b>CONTINUE</b> button. "Add gcp_CreateServiceAccount_ProjectAccess image below"  <BR><BR> 
We then grant users access to the Service Account. We can grant our gmail account user be able to perform actions as this service and click <b>DONE</b> to crate Service Accout "Add gcp_CreateServiceAccount_UserAccess image" <BR><BR> 
Next is to generate our authentication key file (<b>JSON</b>) that will be used by Terraform to authenticate to GCP. Click the on <b>Actions</b> for newly created key are show below to create key. "Add gcp_CreateServiceAccount_CreateKey_Select image below." <BR><BR>
Select JSON , click on  <b>CREATE</b> button and JSON file is downloaded to your computer. Store file in a secure folder for use later with Terraform.

## <b>Install Terraform </b>

Download and install Terraform on your system   [Hashicorp Download](https://www.terraform.io/downloads.html). Find the right binary to install on your system. A single binary named <i>terraform</i> from zip file is need and it has to be add to your PATH. Depending on your operating system is process my vary.

After completing installation verify install but running 'terraform' on command line.


<div class="highlight"><pre class="highlight plaintext"><code>$ terraform -version
Terraform v0.13.4
</code></pre></div>


***

The diagram below provides the compoments that are used to build out and test your GCP HTTP Load Balancer.  Having a clear picture of the components of your infrastucture & their relationships serves as guide to defining Terraform code that will provision your infrastructure.

![alt text][logo]

[logo]: https://raw.githubusercontent.com/KawiNeal/dynamic_block/master/HttpLoadBalancer.png "HTTP Load Balancer"



This infrastructure can be broken down into these sets of resources :
   1. Compute Resources - Instance Group manager for creating/scaling compute resources.
   2. Network - Cloud Network and subnets 
   3. Network Services - Network components for cloud balancing service.
   4. Stress Test VM - Virtual machine to test load balancer.



<div class="highlight"><pre class="highlight plaintext"><code>   
├───compute
│   ├───auto_scaler
│   ├───health_check
│   ├───instance_template
│   └───region_instancegroupmgr
├───dev
├───network
│   ├───firewall_rule
│   └───network_subnet
├───networkservices
│   └───load_balancer
│       ├───backend_service
│       ├───forwarding_rule
│       ├───target_proxy
│       └───url_map
└───test
    └───dev
        └───stress_test_vm
 
</code></pre></div>




<script src="https://gist.github.com/KawiNeal/4fa8f77e8ba9a6e2a69bf80b68f9544c.js"></script>







