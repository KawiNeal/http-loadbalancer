

## <b>Article Goal</b>


The primary goal of this article is to  :

* Configure & deploy infrastructure to build out and test Google Cloud Platform (GCP) HTTP Load Balancer using [Hashicorp Terraform](https://www.terraform.io/), an open source "Infrastructure As Code" (IaC) tool.   

* This article provides high-level overview of Terraform and highlights  a number of key elements in Hashicorp's Configuration Language (HCL) used in the configuring and deploying HTTP Load Balancer within GCP infrastructure.




Google Cloud (GCP) load balancing is implemented at the edge of GCP network, offering load balancing to distribute incoming network traffic across multiple virtual machines (VM) instances. This allows for your network traffic to be distributed & load balanced across single or multiple regions close to your users.  

Some of the features offered by GCP Load Balancing are :
* Single IP address to serve as the frontend.
* Automatic intelligent autoscaling of your backends based on CPU utilization, load capacity & monitoring metrics.
* Traffic routing to the closest virtual instance.
* Global load balancing for when your applications are available across the world.
* High availability & redundancy  which means that if a component(e.g virtual instance) fails, it is automatically restarted or replaced.


***

## <b>Prerequisites / Setup</b>


This article will assume that you have familiarity with cloud computing infrastructure & resources,  Infrastructure as Code (IaC)  and Terraform. In order to set up your environment & create components you will need a Google account , have access to Google Cloud Console and rights within that account to create and administer projects via Google Console.


## <b>GCP Setup</b>

Log into your google account and use URL below to create project. For this effort we will name project "http-loadbalancer".
https://console.cloud.google.com/projectcreate

![alt text](https://storage.googleapis.com/http-loadbalancer/images/gcp_NewProject.png "GCP Project Create")
<BR><BR>

Before we start creating infrastructure resources via Terraform we need to create a <b>Service Account</b> in Google Console. Service Account can be used by application(e.g Terraform) to make authorized API calls to create infrastructure resources. Service Accounts are not user accounts and it does not have passwords associated with them. Service Accounts are associated with private/public RSA key-pairs that are used for authentication to Google.
Select your project, Click <b>IAM & Admin</b> menu, <b>Service Accounts</b> option and then click <b>+ Create Service Account</b> button.


![alt text](https://storage.googleapis.com/http-loadbalancer/images/gcp_CreateServiceAccount_1.png "Create Service Account-1")
<BR>

Enter a name  and description for the Service Account and click the <b>CREATE</b> button.  

![alt text](https://storage.googleapis.com/http-loadbalancer/images/gcp_CreateServiceAccount_2.png "Create Service Account-2")
<BR>

Give the newly created Service Account project permissions. Add the following roles (Compute Admin & Storage Admin) below and click the <b>CONTINUE</b> button. 

![alt text](https://storage.googleapis.com/http-loadbalancer/images/gcp_CreateServiceAccount_ProjectAccess.png "ServiceAccount ProjectAccess")
<BR>

We then grant users access to the Service Account. We can grant our gmail account user be able to perform actions as this service and click <b>DONE</b> to create Service Account.

![alt text](https://storage.googleapis.com/http-loadbalancer/images/gcp_CreateServiceAccount_UserAccess.png "ServiceAccount UserAccess")
<BR>
 
Next is to generate our authentication key file (<b>JSON</b>) that will be used by Terraform to log into to GCP. Click the on <b>Actions</b> column as shown and select <b>Create key</b> to create key. 
![alt text](https://storage.googleapis.com/http-loadbalancer/images/gcp_CreateServiceAccount_CreateKey_Select.png "ServiceAccount Create Key")
<BR>
Select JSON , click on the <b>CREATE</b> button and JSON file is downloaded to your computer. Store the file in a secure folder for use later with Terraform.

![alt text](https://storage.googleapis.com/http-loadbalancer/images/gcp_CreateServiceAccount_PrivateKey_Saved.png "ServiceAccount Save Private Key")

<BR><BR>

We will need to create a GCP storage bucket to support the remote state feature of Terraform backends.   By default, Terraform stores infrastructure state locally in a file, <code>terraform.tfstate</code>. With remote state enabled Terraform write the state (infrastructure) data to a remote data store. Remote state can be shared between team members and depending on the provider allows for locking & versioning. <BR> <BR>
Click on the Storage menu in Google Console or use URL below to get to Storage, in order to create a storage bucket for the http-loadbalancer project.
https://console.cloud.google.com/storage/browser?project=http-loadbalancer <BR><BR>
Click the <b>CREATE BUCKET</b> menu, enter <code>http-loadbalancer</code> for bucket name and then click the <b> CREATE</b> button to create a storage bucket.   


![alt text](https://storage.googleapis.com/http-loadbalancer/images/gcp_CreateStorageBucket_Create.png "CreateStorage Bucket")

<BR>
After creating the bucket, if you select the <code>http-loadbalancer</code> bucket and go the the <b>Permissions</b> tab you should see <code>terraform-account</code> service account as a member with Admin Role for this storage bucket.
<BR><BR>

From the Navigation menu (top left) select the <b>Compute Engine</b> to make sure the Compute Engine API is enabled from your project (http-loadbalancer).

<BR><BR>

## <b>Install Terraform </b>

The Terraform distribution is a single binary file that you can download and install on your system   [Hashicorp Download](https://www.terraform.io/downloads.html). Find the right binary to install on your system. A single binary named <i>terraform</i> from zip file is needed and it has to be added to your PATH and can be executed.

After completing installation verify install by running <code>'terraform -version'</code> on command line:
<div class="highlight"><pre class="highlight plaintext"><code>$ terraform -version
Terraform v0.13.4
</code></pre></div>

You can get list of available commands by running <code>'terraform'</code> without any arguments :
<div class="highlight"><pre class="highlight plaintext"><code>$ terraform
Usage: terraform [-version] [-help] <command> [args]
... help content omitted
</code></pre></div>

***

## <b>Terraform Basics</b>

The  HTTP Load Balancer can manually be configured and provisioned via Google Console. We, however, want to take advantage of key benefits that IaC (e.g Terraform) provides with respects to provisioning and maintaining cloud infrastructure. We are essentially applying the same principles around developing software applications to infrastructure definition and provisioning.  These benefits include :<BR>
* <b>Reuse & Efficiency </b> -  Reliaby rebuild any resource of infrastructure reducing risk. With IaC, once you have created code to set up one environment(e.g DEV), it can be easily configured to replicate another environment (QA/PRPD). Code once and reuse many times (e.g Terraform modules)<BR>
* <b>Version Control & Collaboration</b> - Provide history of changes & traceability of infrastructure when your infrastructure is managed via code. Allows for internal teams to share code between and applies policies to manage infrastructure as it would apply to code.<BR>
* <b>Validation</b> - Allows for effective testing of components individually or entire systems to support specific workflow. <BR>
* <b>Documentation</b> - Code/comments serves to document infrastructure.<BR>


Terraform is an IaC tool for provisioning, updating and managing infrastructure via Hashicorp Configuration Language(HCL). HCL is a declarative language where you specify(declare) the end state and terraform executes a plan to build out that infrastructure. Using providers plug-ins Terraform supports multiple cloud environments  (AWS, Google, Azure & many more). The HCL language & core concepts are applicable to all providers and do not change per provider.  The specific parameters for creating resources within a provider such as AWS or GCP resources would vary depending on the provider being used. 

### <b>Introduction to Hashicorp Terraform with Armon Dadgar</b> <BR>
[![Introduction to HashiCorp Terraform with Armon Dadgar](http://i3.ytimg.com/vi/h970ZBgKINg/hqdefault.jpg)](http://www.youtube.com/watch?v=h970ZBgKINg)

As described in video, the Terraform lifecycle/workflow consist of :

<b>INIT</b> - Terraform initializes the working directory containing the configuration files and installs all the required plug-ins that are referenced in configuration files. 

<b>PLAN</b> -  Stage where Terraform determines what needs to be created, updated, or destroyed to move from the real/current state of the infrastructure to the desired state. Plan run will result in an update of Terraform state to reflect the intended state.  

<b>APPLY</b> - Terraform apply executes that the generated plan to apply the changes in order to move infrastructure  resources to the desired state.

<b>DESTROY</b> - Terraform destroy is used to remove/delete <b>only</b> Terraform managed resources. 

![alt text](https://storage.googleapis.com/http-loadbalancer/images/terraform_Workflow.png "Terraform Workflow")
<BR><BR>


Below are the key terms used in Terraform:

Provider: It is a plugin to interact with APIs of public cloud providers (GCP, AWS, Azure) in order to access & create Terraform managed resources.

Resources: Resources are a block of one or more infrastructure objects (virtual networks, computer & network resources, etc.), used in configuring and managing the infrastructure.

State: It consists of cached information about the infrastructure managed by Terraform and the related configurations.

Variables: Also used as input-variables, it is a key-value pair used by Terraform modules to allow customization. Instead of using hard-coded strings in your resource definition/module you can seperate the values out into data file(vars) and reference
via variables.

Module: It is a folder with Terraform templates where all the configurations are defined.

Output Values: These are return values of a terraform module that can be used by other configurations.

Data Source: It is implemented by providers to return information on external objects to terraform.



***

The diagram below provides the compoments that are used to build out and test your GCP HTTP Load Balancer.  Having a clear picture of the components of your infrastucture & their relationships serves as guide to defining Terraform code that will provision your infrastructure.

![alt text](https://storage.googleapis.com/http-loadbalancer/images/Architecture_Overview.png "Architecture Overview")



This infrastructure can be broken down into these sets of resources :
   1. Compute Resources - Instance Group manager for creating/scaling compute resources.
   2. Network - Cloud Network and subnets 
   3. Network Services - Network components for cloud balancing service.
   4. Stress Test VM - Virtual machine to test load balancer.



<div class="highlight"><pre class="highlight plaintext"><code>   
├───compute
│   ├───auto_scaler
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
│       ├───health_check
│       ├───target_proxy
│       └───url_map
└───test
    └───dev
        └───stress_test_vm
</code></pre></div>




<script src="https://gist.github.com/KawiNeal/4fa8f77e8ba9a6e2a69bf80b68f9544c.js"></script>

{% gist https://gist.github.com/KawiNeal/4fa8f77e8ba9a6e2a69bf80b68f9544c.js %}

{% github KawiNeal/http-loadbalancer %}

