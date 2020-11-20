## <b>Article Goal</b>

The primary goal of this article is to  :

* Describe configuration & infrastructure build out and testing of Google Cloud Platform (GCP) HTTP Load Balancer using [Hashicorp Terraform](https://www.terraform.io/), an open source "Infrastructure As Code" (IaC) tool.   

* Provide a high-level overview of Terraform and highlight a number of key elements of Hashicorp's Configuration Language (HCL) used in the configuring resources for deploying HTTP Load Balancer.

Google Cloud (GCP) load balancing is implemented at the edge of GCP network, offering load balancing to distribute incoming network traffic across multiple virtual machines (VM) instances. This allows for your network traffic to be distributed & load balanced across single or multiple regions close to your users.  

Some of the features offered by GCP Load Balancing are :
* Automatic intelligent autoscaling of your backends based on CPU utilization, load capacity & monitoring metrics.
* Traffic routing to the closest virtual instance.
* Global load balancing for when your applications are available across the world.
* High availability & redundancy  which means that if a component(e.g virtual instance) fails, it is automatically restarted or replaced.

***

## <b>Prerequisites / Setup</b>

This article will assume that you have some familiarity with cloud computing infrastructure & resources,  Infrastructure as Code (IaC)  and Terraform. In order to set up your environment & create components you will need a Google account , have access to [Google Cloud Console](https://console.cloud.google.com/) and rights within that account to create and administer projects via Google Console.

## <b>GCP SETUP</b>
Setup needed within GCP : <BR>
1. Create project
2. Create Service Account & associated key to allow Terraform to access GCP Project.  We will only grant the Service Account  minimum permission required for this effort.
3. Create a storage bucket to store infrastructure state via Terraform.
4. Add public SSH key to GCP so that Terraform can connect to GCP via remote SSH with a private key. 
<BR><BR>
## Create Project
Log into your google account and use URL below to create project. For this effort we can name the project "http-loadbalancer". <BR>
https://console.cloud.google.com/projectcreate

![alt text](https://storage.googleapis.com/http-loadbalancer/images/gcp_NewProject.png "GCP Project Create")
<BR>
## Service Account
Before we start creating infrastructure resources via Terraform we need to create a <b>Service Account</b> via Google Console. Service Accounts can be used by applications(e.g Terraform) to make authorized API calls to create infrastructure resources. Service Accounts are not user accounts and it does not have passwords associated with them. Service Accounts are associated with private/public RSA key-pairs that are used for authentication to Google.
Select your project, Click <b>IAM & Admin</b> menu, <b>Service Accounts</b> option and then click <b>+ Create Service Account</b> button.


![alt text](https://storage.googleapis.com/http-loadbalancer/images/gcp_CreateServiceAccount_1.png "Create Service Account-1")
<BR>

Enter a name  and description for the Service Account and click the <b>CREATE</b> button.  

![alt text](https://storage.googleapis.com/http-loadbalancer/images/gcp_CreateServiceAccount_2.png "Create Service Account-2")
<BR>

Give the newly created Service Account project permissions. Add the following roles (Compute Admin & Storage Admin) below and click the <b>CONTINUE</b> button. 

![alt text](https://storage.googleapis.com/http-loadbalancer/images/gcp_CreateServiceAccount_ProjectAccess.png "ServiceAccount ProjectAccess")
<BR>
 
Next is to generate our authentication key file (<b>JSON</b>) that will be used by Terraform to log into to GCP. Click the on <b>Actions</b> column as shown and select <b>Create key</b> to create key. 
![alt text](https://storage.googleapis.com/http-loadbalancer/images/gcp_CreateServiceAccount_CreateKey_Select.png "ServiceAccount Create Key")
<BR>
Select JSON , click on the <b>CREATE</b> button and JSON file is downloaded to your computer. Rename the  file to "http-loadbalancer.json" and store in a secure folder for use later in our Terraform project. 

![alt text](https://storage.googleapis.com/http-loadbalancer/images/gcp_CreateServiceAccount_PrivateKey_Saved.png "ServiceAccount Save Private Key")


## Storage Bucket
We will need to create a GCP storage bucket to support the remote state feature of Terraform backends.   By default, Terraform stores infrastructure state locally in a file, <code>terraform.tfstate</code>. We could have used local state for this effort, we however are using remote state(GCP storage bucket) to highlight this feature in Terraform.  With remote state enabled Terraform writes the state (infrastructure) data to a remote data store. Remote state can be shared between team members and depending on the provider allows for locking & versioning. <BR> <BR>
Click on the Storage menu in Google Console or use URL below to get to Storage, in order to create a storage bucket for the http-loadbalancer project.
https://console.cloud.google.com/storage/browser?project=http-loadbalancer <BR><BR>
Click the <b>CREATE BUCKET</b> menu, enter <code>http-loadbalancer</code> for bucket name and then click the <b> CREATE</b> button to create a storage bucket.   


![alt text](https://storage.googleapis.com/http-loadbalancer/images/gcp_CreateStorageBucket_Create.png "CreateStorage Bucket")

After creating the bucket, if you select the <code>http-loadbalancer</code> bucket and go the the <b>Permissions</b> tab you should see <code>terraform-account</code> service account as a member with Admin Role for this storage bucket.
<BR>
In Google Console, from the Navigation menu (top left) select the <b>Compute Engine</b> to make sure the Compute Engine API is enabled from your project (http-loadbalancer).
<BR>

## SSH Key
If you don't already have an SSH key you can use the following [link](https://confluence.atlassian.com/bitbucketserver/creating-ssh-keys-776639788.html) to generate it first. This will result in two files (e.g <i><b>id_rsa</b></i> & <i><b>id_rsa.pub</b></i>).  Contents of your  xxxx.pub file needs to be added to GCP and the associated key (<i><b>id_rsa</b></i>) file needs to be stored for use later with Terraform.

Within GCP , go to <b>Compute Engine → Metadata</b> 
<BR>
![alt text](https://storage.googleapis.com/http-loadbalancer/images/gcp_SSHKey_Metadata.png "GCP Metadata")

Select <b>SSH Keys</b> tab and add contents of your xxxx.pub (e.g id_rsa.pub) file.
<BR>
![alt text](https://storage.googleapis.com/http-loadbalancer/images/gcp_SSHKey_Edit.png "GCP SSH Keys")
<BR><BR>

The net result of the above steps should result in two files (service account JSON & SSH private key) that will be needed to be placed into the Terraform project once it has been downloaded.  

## <b>Getting Started with Terraform on GCP </b>
 
***

## <b>Terraform Basics</b>

The  HTTP Load Balancer can manually be configured and provisioned via Google Console. We, however, want to take advantage of key benefits that IaC (e.g Terraform) provides with respects to provisioning and maintaining cloud infrastructure. We are essentially applying the same principles around developing software applications to infrastructure definition and provisioning.  These benefits include :<BR>
* <b>Reuse & Efficiency </b> -  Reliaby rebuild any resource of infrastructure reducing risk. With IaC, once you have created code to set up one environment(e.g DEV), it can be easily configured to replicate another environment (QA/PRPD). Code once and reuse many times (e.g Terraform modules)<BR>
* <b>Version Control & Collaboration</b> - Provide history of changes & traceability of infrastructure when your infrastructure is managed via code. Allows for internal teams to share code between and applies policies to manage infrastructure as it would apply to code.<BR>
* <b>Validation</b> - Allows for effective testing of components individually or entire systems to support specific workflow. <BR>
* <b>Documentation</b> - Code/comments serves to document infrastructure.<BR>


Terraform is an IaC tool for provisioning, updating and managing infrastructure via Hashicorp Configuration Language(HCL). HCL is a declarative language where you specify(declare) the end state and terraform executes a plan to build out that infrastructure. Using providers plug-ins Terraform supports multiple cloud environments  (AWS, Google, Azure & many more). The HCL language & core concepts are applicable to all providers and do not change per provider.  

### <b>Introduction to Hashicorp Terraform</b> <BR>
Below is an excellent overview of Terraform.
<BR>
[![Introduction to HashiCorp Terraform with Armon Dadgar](http://i3.ytimg.com/vi/h970ZBgKINg/hqdefault.jpg)](http://www.youtube.com/watch?v=h970ZBgKINg)

The Terraform lifecycle/workflow consist of :

<b>INIT</b> - Terraform initializes the working directory containing the configuration files and installs all the required plug-ins that are referenced in configuration files. 

<b>PLAN</b> -  Stage where Terraform determines what needs to be created, updated, or destroyed to move from the real/current state of the infrastructure to the desired state. Plan run will result in an update of Terraform state to reflect the intended state.  

<b>APPLY</b> - Terraform apply executes that the generated plan to apply the changes in order to move infrastructure  resources to the desired state.

<b>DESTROY</b> - Terraform destroy is used to remove/delete <b>only</b> Terraform managed resources. 

![alt text](https://storage.googleapis.com/http-loadbalancer/images/terraform_Workflow.png "Terraform Workflow")
<BR><BR>

Below are some key terms used in Terraform that will touch upon are part of this article. 

<b>Provider:</b> It is a plugin to interact with APIs of public cloud providers (GCP, AWS, Azure) in order to access & create Terraform managed resources.

<b>Variables:</b> Also used as input-variables, it is a key-value pair used by Terraform modules to allow customization. Instead of using hard-coded strings in your resource definition/module you can seperate the values out into data files(vars) and reference
via variables.

<b>State:</b> It consists of cached information about the infrastructure managed by Terraform and the related configurations.

<b>Modules:</b> Reusable  container for one or more resources that are used together. Modules have defined input variables which are used to create/update resources and allow for defined output variables that other resources or modules can use.

<b>Data Source:</b> It is implemented by providers to return reference on resources within infrastructure to Terraform.

<BR>

## <b>Install Terraform </b>

The Terraform distribution is a single binary file that you can download and install on your system   [Hashicorp Download](https://www.terraform.io/downloads.html). Find the right binary for your operating system (Windows, Mac,etc) to install. A single binary named <i>terraform</i> from zip file is needed and it has to be added to your system PATH.

After completing installation verify install by running <code>'terraform -version'</code> on command line:
<div class="highlight"><pre class="highlight plaintext"><code>$ terraform -version
Terraform v0.13.4
</code></pre></div>

You can get list of available commands by running <code>'terraform'</code> without any arguments :
<div class="highlight"><pre class="highlight plaintext"><code>$ terraform
Usage: terraform [-version] [-help] <command> [args]

The available commands for execution are listed below.
...
...
</code></pre></div>

## <b>Install GIT & Clone project</b>
If you don't already have GIT installed, use this  [link](https://git-scm.com/downloads) to install GIT locally in order to pull down Terraform code for this effort. After installing GIT, clone the project locally by running :
<BR>
<div class="highlight"><pre class="highlight plaintext"><code>git clone https://github.com/KawiNeal/http-loadbalancer.git

cd http-loadbalancer/envs
</code></pre></div>



Copy the generated service account JSON file and private key file (e.g http-loadbalancer.json & id_rsa) into the  <b><code>envs</code></b> folder of project. In the  <b><code>envs</code></b> folder edit <code>dev.env.tfvars</code> to make sure that the variable assignments for <code>gcp_auth_file</code> and <code>id_rsa</code> match the names of the files. 
<BR>
 <code>../http-loadbalancer/envs/dev.env.tfvars</code>
<div class="highlight"><pre class="highlight plaintext">
<code>
# GCP authentication file
gcp_auth_file = "http-loadbalancer.json"
</code></pre></div>

<div class="highlight"><pre class="highlight plaintext">
<code>
# remote provisioning - private key file
stress_vm_key = "id_rsa"
</code></pre></div>

<BR>

## <b>Project Structure</b>
The diagram below provides the components that are used to build out and test your GCP HTTP Load Balancer.  Having a clear picture of the components of your infrastructure & their relationships serves as a guide to defining Terraform project code for provisioning your infrastructure.

![alt text](https://storage.googleapis.com/http-loadbalancer/images/Architecture_Overview.png "Architecture Overview")


This infrastructure can be broken down into these sets of resources :
   1. Compute Resources - Instance Group manager for creating/scaling compute resources.
   2. Network - Cloud Network and subnets 
   3. Network Services - Network components for cloud balancing service.
   4. Stress Test VM - Virtual machine to test load balancer.
<BR>

The Terraform folder structure has been defined to map to the resource grouping with each component within the group represented as a module.  
<div class="highlight"><pre class="highlight plaintext">
<code>   
├───compute
│   ├───auto_scaler
│   ├───instance_template
│   └───region_instancegroupmgr
├───envs
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
</code></pre></div>
<BR>


The <b><code>envs</code></b> folder is where the Http Load Balancer Terraform project is defined.  It contains the provisioner,  variables, remote backend, modules and data sources for this project.  We will start with the <code>main.tf</code>, which serves as the root module (starting point) for the Terraform configuration. The root module makes all the calls to child-modules & data sources needed to create all resources for HTTP Load Balancer.


<div class="highlight"><pre class="highlight plaintext">
<code>
├───envs              			
│   │   dev.env.tf    		    ----> all variables needed for DEV environment
│   │   dev.env.tfvars		    ----> variables assignments for DEV
│   │   http-loadbalancer.json  * copied into project (service account)
│   │   id_rsa                  * copied into project (SSH key)
│   │   main.tf       		     -----> terraform, GCP provider & modules 
</code></pre></div>
The <code>dev.env.tf</code> has all the variables associated with the DEV configuration including Terraform block to define require version and cloud provider (GCP).  Took the approach of isolating all variables for a specific environment into one file.

<u><b><code>dev.env.tf</code></b></u>
<script src="https://gist.github.com/KawiNeal/6f0dbe46045cfb444d66646bbe6c59fd.js"></script>

{% gist https://gist.github.com/KawiNeal/6f0dbe46045cfb444d66646bbe6c59fd.js %}


The <span style="color: #ff0000">terraform</span> block sets which provider to retrieve from the Terraform Registry. Given that this is for GCP infrastructure we need to use the google provider source ("hashicorp/google"). Within the <span style="color: #ff0000">terraform</span> block the <code>'required_version'</code> sets a version of Terraform to use in your configuration when the configuration is initialized.  The <code>'required_version'</code> takes a  [version constraint string](https://www.terraform.io/docs/configuration/version-constraints.html) which ensures that a range of acceptable versions can be used. In our project we are specifying that any version that is greater than or equal to 0.13.

The <span style="color: #ff0000">provider</span> block sets which provider to retrieve from the Terraform Registry. [Providers](https://www.terraform.io/docs/configuration/providers.html) are essentially plug-ins that give the Terraform configuration access to a set of resource types per each provider. Note that multiple providers can be specified in one configuration. You can also define multiple configurations for the same provider and select the provider to use within each module or by resource. The <span style="color: #ff0000">provider</span> block sets the version, project & GCP credentials to allow for access  to a specific project within GCP. The provider uses  variables that are declared and defined in <code>dev.env.tf</code> and <code>dev.env.tfvars</code>. 

The <span style="color: #da70d6">backend</span> block enables storing the infrastructure state in a remote data store. Remote backends are highly recommended when working in teams to modify same infrastructure or parts of the same infrastructure. Advantages are with collaboration, security (sensitive info) and remote operations. The backend we have defined is GCP ("gcs") using the storage bucket we defined as part of the setup. Access to the storage bucket is obtained with a service account key(JSON).  One thing to note, you can not use variables within the definition of backend, all input must be hard-coded.  You can see that difference between the definition of the <span style="color: #ff0000">provider</span> block and the <span style="color: #da70d6">backend</span> block.<BR><BR>
The variables after the <span style="color: #da70d6">backend</span> block defines that variable types that are needed to be passed to all the modules. 

<u><b><code>dev.env.tfvars</code></b></u>
<script src="https://gist.github.com/KawiNeal/73171999e47eb57246b65f438dbd4902.js"></script>

{% gist https://gist.github.com/KawiNeal/73171999e47eb57246b65f438dbd4902.js %}

Hard-coding values in Terraform configuration is not recommended. The use of variables is to ensure configuration can be easily maintain, reused and also serve as parameters to Terraform modules.  Variables declarations are put defined in variables TF file and their associated values assignments are put into TFVARS file. The variables in these files represent sets of inputs to modules for this infrastructure. 

For example, the VPC Network and Subnets input from <code>dev.env.tfvars</code> is defined as :

<script src="https://gist.github.com/KawiNeal/182b0a8c7b2acc88c3280d3dba362afd.js"></script>

{% gist https://gist.github.com/KawiNeal/182b0a8c7b2acc88c3280d3dba362afd.js %}


The inputs (<code>project_id, vpc,vpc_subnets</code>) are passed to the network_subnet module within the network group folder(../network/network_subnet).
<script src="https://gist.github.com/KawiNeal/e7ddb523615e97ce01bd4e6f4f8f187d.js"></script>

{% gist https://gist.github.com/KawiNeal/e7ddb523615e97ce01bd4e6f4f8f187d.js %}

## Modules

The <code>network_subnet</code> module illustrates how a module can be used to call/re-use other modules.  The <code>network_subnet</code> module calls "version 2.5.0" of an available & verified [network module](https://registry.terraform.io/namespaces/terraform-google-modules) that creates network/subnets using required input parameters. There is a [Terraform registry of modules](https://registry.terraform.io/) that can be used to create resources for multiple providers (AWS, GCP, Azure, etc). <BR>
<u><b><code>Module network_vpc</code></b></u>
<script src="https://gist.github.com/KawiNeal/b6bcbc1969970a917fa6af39d68559aa.js"></script>
{% gist https://gist.github.com/KawiNeal/b6bcbc1969970a917fa6af39d68559aa.js %}
Modules not only allow you to re-use configuration but also makes it easier to organize your configuration into clear and logical components of your infrastructure. Proper definition and grouping of modules will allow for easier navigation & understanding of larger cloud infrastructures that could exist across multiple cloud providers and have hundreds of resources.<BR>
Similar to web services, modules should follow an "input-output" pattern.  We want to have a clear contract that defines our inputs to the module and outputs from the module.  These reusable pieces of components(modules) can then be logically glued together to produce a functional infrastructure.

Example of two <code>network services</code> modules below : 
<div class="highlight"><pre class="highlight plaintext">
<code>
...
...
│   │───target_proxy
│   │     ├───input.tf
│   │     ├───output.tf
│   │     └───target_proxy.tf
│   │───url_map
│   │     ├───input.tf
│   │     ├───output.tf
│   │     └───url_map.tf
...
...
</code></pre></div>
Output values defined in <code>output.tf</code> are the return values of the Terraform module that can be used to pass resource attributes/references to the parent module. Other modules in the root module can use these attributes as input, creating an <b>implicit</b> dependency.  In the example above, the <code>target_proxy</code> has a dependency on an url map. The output from <code>url_map</code> child-module to the root module is <code>url_map_id</code>, which is passed as an input to the <code>target_proxy</code> child-module.
<u><b><code>Module url_map output</code></b></u>
<script src="https://gist.github.com/KawiNeal/e3d1d8cc9f4fe00a410f6bb8f4ed7991.js"></script>
{% gist https://gist.github.com/KawiNeal/e3d1d8cc9f4fe00a410f6bb8f4ed7991.js %}
In the root/parent module, outputs from the child module can be referenced and made available as <b>module.MODULE_NAME.OUTPUT_NAME</b>. In case of <code>url_map</code> output it can be referenced as <code>module.url_map.id</code> as shown below from the root module in <code>main.tf</code>.
<u><b><code>Module http_proxy input</code></b></u>
<script src="https://gist.github.com/KawiNeal/fab947ab01a6890de4d036e5a6c01e8c.js"></script>
{% gist https://gist.github.com/KawiNeal/fab947ab01a6890de4d036e5a6c01e8c.js %}

Terraform by default will take into account the implicit dependency as far as the order in which resources are created. In the case of <code>url_map</code> and <code>target_proxy</code> above, the url_map will be created prior <code>target_proxy</code>.
Terraform also allows for declaring <b>explicit</b> dependencies with the use of <code>depends_on</code>.
One method of testing the HTTP Load Balancer was to create a virtual instance (<code>stress_test_vm</code>) and drive traffic from that virtual instance to the load balancer.  The load balancer should forward traffic to the region that is closest to the virtual machine's region/location. The (<code>stress_test_vm</code>) is a stand-alone instance that has no implicit dependency on resources/modules defined in the root module. The (<code>stress_test_vm</code>) does require that the resources associated with HTTP Load Balancer be in place in order to forward traffic to it. The <code>depends_on = [module.network_subnet, module.fowarding_rule]</code> sets this explicit dependency. Before creating a test VM we want to ensure that the network/subnets and  externally exposed IP address are in place prior to generating traffic to external IP.

<u><b><code>Module - test</code></b></u>
<script src="https://gist.github.com/KawiNeal/a2de9a38bde26a9ec0b6da15ec888023.js"></script>
{% gist https://gist.github.com/KawiNeal/a2de9a38bde26a9ec0b6da15ec888023.js %}

## Load Balancer & Testing

Additional details for configuring GCP Load Balancer can be found [here](https://console.cloud.google.com/). From GCP perspective per our architecture diagram, our configuration consists of:<BR>
 1. <b>HTTP, health check, and SSH firewall rules</b> <BR>
 To allow HTTP traffic to backends, TCP traffic from GCP Health checker & remote SSH from Terraform to stress test VM.<BR>

 2. <b>Instance templates (2)</b> <BR>
 Resource to create VM instances and managed instance groups(mig). Templates define machine type, boot disk, and other instance properties. Startup script is also executed on all instances create by instance template to install Apache.
 3. <b>Managed instance groups (2)</b> <BR>
 Managed instance groups use instance templates to create a group of identical instances that offers autoscaling based on autoscaling policy/metrics.
 4. <b>HTTP Load Balancer(IPv4 & IPV6)</b> <BR>
 Load balancer consists of backend service to balance traffic between two backend managed instance groups( mig in US & EU). Load balancer includes creating HTTP health checks(port80) to determine when instances will receive new connections. Forwarding-rule(frontend) is created as part of load balancer. Frontends determine how traffic will be directed. For our configuration we are defaulting to http port(80). 

 5. <b>Stress Test VM</b>
<BR>VM is created to simulate load on the HTTP Load Balancer. As part of VM startup <b>siege</b>, a http load testing utility is installed. Via Terraform's <code>remote-exec</code> we execute <b>siege</b> utility to direct traffic to HTTP Load Balancer. 

Terraform <b>data sources</b> were used in the <code>test</code> module to retrieve the external IP address (frontend) of the load balancer, in order for <b>siege</b> to route traffic to it. Data sources allow Terraform to retrieve existing resource configuration information.  One item to note here is that Terraform's data source can query any resource within the provider, it does not have to be a resource managed/created by Terraform. 

<u><b><code>Module - "test" (stress_test_vm.tf)</code></b></u>
<div class="highlight"><pre class="highlight plaintext">
<code>
# get forward rule to obtain frontend IP
data "google_compute_global_forwarding_rule" "http" {
  name = var.forward_rule_name

}
</code></pre></div>
<div class="highlight"><pre class="highlight plaintext">
<code>
inline = [
      "sleep 20",
      "siege -c255 -time=8M http://${data.google_compute_global_forwarding_rule.http.ip_address} &",
      "sleep 500"
    ]
</code></pre></div>

The inline block contains the command line for executing <b>siege</b> utility on the <code>stress_test_vm</code>. The command generates 255 concurrent user requests at a rate of  1-3 seconds between each request for 8 minutes. One notable & interesting  issue I ran into was the <b>siege</b> command would not continue running over a time period. After SSH connection and command line was executed it would immediately end the session and terminate the <b>siege</b> process.  Work-around this issue was to run <b>siege</b> as background process and add <code>sleep</code> to delay closing of SSH session and terminating <b>siege</b> prior to the needed execution time.
<BR>
Although available, provisioning an instance with Terraform over SSH(remote-exec) is not recommended by Hashicorp. The issue faced with the <b>siege</b> process seems to highlight their recommendation.  For this effort it was convenient for testing purposes. Hashicorp provides configuration management provisioner product, [Hashicorp Packer](https://packer.io/), that automates creation of a VM instance image.


## INIT 
We can now proceed to go through this Terraform project lifecycle : INIT, PLAN , APPLY and eventually DESTROY when done. <BR>
Run <b><code>'terraform init'</code></b>
<div class="highlight"><pre class="highlight plaintext">
<code>
C:\http-loadbalancer\envs>terraform init
Initializing modules...
Initializing the backend...
Initializing provider plugins...
- Using previously-installed hashicorp/google v3.46.0
Terraform has been successfully initialized!.
</code></pre></div>

## PLAN
Terraform PLAN needs to be executed with the <code>-var-file</code> flag set to variables from the <code>dev.env.tfvars</code> file. Terminal output will display all resources that will be generated and provide the number of resources at the end of plan output.

Run <b><code>'terraform plan -var-file dev.env.tfvars -auto-approve'</code></b> <BR>
The 'auto-approve' parameter removes interactive approval prompt to accept running the plan command.
<div class="highlight"><pre class="highlight plaintext">
<code>
C:\http-loadbalancer\envs>terraform plan -var-file dev.env.tfvars -auto-approve

..
..
Plan: 22 to add, 0 to change, 0 to destroy.
</code></pre></div>

## APPLY
Terraform PLAN will indicate that 22 GCP resources will be created. Next we will to run APPLY to execute the generated plan  in order to move our infrastructure to desired stated.  Note when we run APPLY the <code>stress_test_vm</code> will also be provisioned after all other resources. After that short period of time (1-2 minutes) web traffic will be directed to the load balancer.

Run <b><code>'terraform apply -var-file dev.env.tfvars -auto-approve'</code></b>
<div class="highlight"><pre class="highlight plaintext">
<code>
C:\http-loadbalancer\envs>terraform apply -var-file dev.env.tfvars -auto-approve
PS C:\Users\Kawi\Terraform\Repos\http-loadbalancer\envs> terraform apply -var-file dev.env.tfvars -auto-approve
module.network_subnet.module.network_vpc.module.vpc.google_compute_network.network: Creating...
module.healthcheck.google_compute_health_check.healthcheck: Creating...
module.healthcheck.google_compute_health_check.healthcheck: Creation complete after 3s [id=projects/http-loadbalancer/global/healthChecks/http-lb-health-check]
module.network_subnet.module.network_vpc.module.vpc.google_compute_network.network: Still creating... [10s elapsed]
module.network_subnet.module.network_vpc.module.vpc.google_compute_network.network: Creation complete after 15s [id=projects/http-loadbalancer/global/networks/http-lb]
..
..
</code></pre></div>

After Terraform has created GCP resources and the <code>remote-exec</code> process is running, you can use GCP console to view traffic flow to [backends](https://console.cloud.google.com/net-services/loadbalancing/advanced/backendServices/details/http-lb-backend?project=http-loadbalancer&duration=PT1H).  Given that <code>stress_test_vm</code> is in a closer region the majority of traffic will be routed to <code>europe-west</code> managed instance groups. The managed instance group will create additional VMs to handle the uptick in web traffic to the load balancer.<BR>
From the the GCP console navigation menu select : <BR>
<b>Network Services --> Load Balancing --> Backend (tab) </b> Select "http-lb-backend" from list below.

![alt text](https://storage.googleapis.com/http-loadbalancer/images/gcp_BackEnd_Traffic.png "Architecture Overview")


To view the instances created to handle traffic from <code>stress_test_vm</code>.  From the the GCP console navigation menu select : <BR>
<b>Compute Engine --> VM instances</b> 

After the <code>remote-exec</code> process completes the number of instances created would scale down via instance group manager. If you need to run testing again, the <code>stress_test_vm</code> can be marked as TAINTed and APPLY can be re-executed which will only destroy the <code>stress_test_vm</code> and then re-created it.  

Run <b><code>'terraform taint module.test.google_compute_instance.stress_test_vm'</code></b> and then <BR> 
<b><code>'terraform apply -var-file dev.env.tfvars'</code></b>


<div class="highlight"><pre class="highlight plaintext">
<code>
C:\http-loadbalancer\envs>terraform taint module.test.google_compute_instance.stress_test_vm
Resource instance module.test.google_compute_instance.stress_test_vm has been marked as tainted.

C:\http-loadbalancer\envs> terraform apply -var-file dev.env.tfvars
..
..
Plan: 1 to add, 0 to change, 1 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:
</code></pre></div>

## DESTROY
Terraform DESTROY needs to be executed to clean up all resources. To be able to check that destroy will remove 22 resources,  run DESTROY without the <code>-auto-approve</code> parameter.  You will then get prompted to answer 'yes' to accept removal of all resources. <BR>
Run <b><code>'terraform destroy -var-file dev.env.tfvars'</code></b> <BR>
<div class="highlight"><pre class="highlight plaintext">
<code>
C:\http-loadbalancer\envs>terraform destroy -var-file dev.env.tfvars -auto-approve
..
..
Plan: 0 to add, 0 to change, 22 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: 
</code></pre></div>

Last but not least, the resources (storage bucket, service account) created as part of the project setup will need to be deleted when you are done.

And that's all folks...hope this post provided some insight into Terraform. 


