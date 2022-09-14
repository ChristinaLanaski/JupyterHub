<h2>What is JupyterHub?</h2>

JupyterHub is open source and creates a space for groups to collaborate on notebooks. It is customizable, flexible, scalable, and portable, used for Jupyter Notebook, Jupyter Lab, RStudio, nteract and more. It can be deployed on Kubernetes using Docker allowing it to be scaled and maintained. 

![image](https://user-images.githubusercontent.com/89024359/187980876-c4eaba28-bb0d-4ed5-826d-40ef83a71267.png)

<h2>What is HELM?</h2>

HELM is a package manager for Kubernetes. Instead of having a bunch of yaml files for a service or application you want to deploy into Kubernetes (like ConfigMap, secret, services, K8s User with permissions, etc), Helm compiles all of these files into one which is called a Helm Chart. You can create a Helm Chart and push it to a repository for other Developers to use, or you can download and use exiting ones. Database and Monitoring Apps all have configurations developers have already made. You can view these charts by using command line “help search 'keyword' " or searching on Helm Hub. There are also private registries to share in organizations.

It is also a templating Engine, meaning it can be used for multiple pods that have almost the same yaml config and use dynamic replacement of values.

![image](https://user-images.githubusercontent.com/89024359/187981293-1f4ccb73-1c95-45ab-bc90-9bc5fba90549.png)


Helm Chart Structure:
1.	Top Level maycart folder > name fo the chart
2.	Chart.yaml > meta info about your chart
3.	Values.yaml > values for the template files
4.	Charts folder > chart dependencies
5.	Templates folder > the actual template files

![image](https://user-images.githubusercontent.com/89024359/187981540-d3233a8b-be3c-42f1-a6dd-47f5ea002dff.png)

What does this mean!?
When you execute “helm install 'chartname' ” the template files will be filled with the values from values.yaml. You can have other fields like README or license files.
____
<h2>Prerequisites</h2>

- [Visual Studio Code](https://code.visualstudio.com/) for Desktop installed on your machine
- Azure Cloud Subscription - [AIS MPN VS Enterprise Sub](https://appliedis.sharepoint.com/sites/Developers1/SitePages/aisU-Labs--Initial-Access.aspx)
- Connect VSCode with Azure Sub
  - Open VScode and a new terminal, run the following commands
    - az cloud set --name AzureCloud
    - az account set --subscription 'subscription ID'
      - the correct subscription ID will be under the name "VIsual Stuido Enterprise Subscirption" from the previous command
- Clone Git repo/Have a GitHub Account
  - In the terminal run git clone https://github.com/ChristinaLanaski/JupyterHub.git
  - Then select "File" "Open File..." on the top task bar and C:\Users\your_name (or where ever you store your git repos), look for a "Jupyterhub" folder. Open the folder and you will have this repo in your VSCode. 



______

<h2>Creating your own JupyterHub</h2>

> Here is the official documentation from Jupyter on how to create your own [JupyterHub](https://zero-to-jupyterhub.readthedocs.io/en/latest/)

> If using your MPN Enterprise account, it may be easier to go through the command line with these steps [here](https://zero-to-jupyterhub.readthedocs.io/en/stable/kubernetes/microsoft/step-zero-azure.html)


<h4>Step One: Create the AKS Service</h4>

The terraform for a basic AKS Service is already made in the "JuypterHub" folder. This is a very basic deployment of AKS and deploys just what is needed. More info on what you can add to this deployment can be viewed [here](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) in the Terraform Registry.

The code deploys a resource group and an AKS cluster. The AKS cluster is what will be used to make configurations and host the site. (If you wish to start from scratch, the JupyterHub documentation above takes you through a walkthrough on how to deploy an AKS cluster through the portal using CLI)

Run through the following steps to deploy the code:



```bash
1. Open a bash terminal
2. cd into the vars folder (cd ./vars)
3. run **source kubernetes.d.sh**
   1. this stores the environment variables. run **env** to ensure the variables are stored
4. cd into the kubernetes folder (cd ../Kubernetes)
5. run **terraform init**
6. run **terraform plan**
   1. A kubernetes cluster and resource group will be created
7. run **terraform apply**, then **yes** at the prompt.
8. Double check in the portal that everything deployed correctly
```
Know that the terraform current does not include the ACR used for HELM. If you choose to follow this method without connecting AKS to the ACR registry that has all the required software installed, you will be prompted for a sudo password which is unknown. To avoid this, follow "Azure DevOps to ACR to AKS until" the terraform is updated

*Kubernetes can rack up in costs so make sure you either stop them or destroy them when they are not being used.*

<h4>Step 1.5: DevOps to ACR to AKS</h4>

In order to avoid any authentication errors and ensure that all required software is installed, you can push a docker container to an ACR registry connected to AKS through Azure Pipelines:

1. Create ACR through the portal, you can leave the defaults
2. [Create DevOps with Dockerfile and push to ACR](https://docs.microsoft.com/en-us/azure/devops/pipelines/ecosystems/containers/acr-template?view=azure-devops)
   1. Use this JupyterHub repo when pulling from GitHub
   2. For step 7 in the docs, choose the ACR you created in step 1 above
   3. For step 8, name it jupyterhubdocker and the file path should be .devcontainer/Dockerfile
   4. You can copy the code from [azure-pipelines](azure-pipelines.yml)
  After the pipeline ran successfully, go to your ACR in the portal and check to make sure that the repository is there:

![acrrepo](https://github.com/ChristinaLanaski/JupyterHub/blob/84c9b5e4ebdd73befd399e379dffeaccb4eab904/images/acrrepo.PNG)

The end result should look like what is in the [azure-pipelines.yml](azure-pipelines.yml), but in devops:

![devopsyml.PNG](https://github.com/ChristinaLanaski/JupyterHub/blob/604a324182f37fa583a3db009d20f083b7e55504/images/devopsyaml.PNG))

1. Create AKS
   1. Through the portal, create an AKS and ensure when you get to the "Integrations" tab, for Container registry, you select the one you created in step 1.

<h4>Step 2:Connect to the AKS Service</h4>

Once the AKS cluster is deployed from terraform, make sure it is in a running state and click the “Connect” button.  

![image](https://user-images.githubusercontent.com/89024359/187981741-ef4d4a6c-dc3b-4fe0-aad1-7c695d6c160a.png)

A window will pop up asking to connect to the cluster through CLI. Click on the CLI icon on the top task bar which will open up the cloud shell:

![images\cliconnect.PNG](https://github.com/ChristinaLanaski/JupyterHub/blob/84c9b5e4ebdd73befd399e379dffeaccb4eab904/images/cliconnect.PNG))

Copy and paste the first two commands into the cmd:

```bash
- az account set --subscription subscription id
- az aks get-credentials --resource-group AZ-MDSOTA-D-JUPYTER-01 --name AZ-MDSOTA-JUPYTER-AKS-01
```
 
![image](https://user-images.githubusercontent.com/89024359/187981897-0acdbc0a-a451-46fb-9f9d-e4d774046819.png)

<h4>Step 3: Install HELM and HELM Repo for JupyterHub</h4>

Execute the following command to install Helm:

Install HELM:
```bash
- curl https://raw.githubusercontent.com/helm/helm/HEAD/scripts/get-helm-3 | bash
```
to verify installation, execute:
```bash
 helm version
```

Now that you have Helm installed, you can pull the latest Helm repo for Juypter:
```bash
- helm repo add jupyterhub https://jupyterhub.github.io/helm-chart/
- helm repo update
```
You should get “….Happy Helming!” message back:

![HelmInstall.png](https://github.com/ChristinaLanaski/JupyterHub/blob/b46ea75419ea6ed6d549bcf5fa9c265740dafd54/images/HelmInstall.PNG)

<h4>Step 4: Create the Namespace</h4>

First execute the following to list all deployments in all namespaces in the cluster:

```bash
kubectl get namespaces
```

You can think of Namespaces as Folders within Windows Explorer. They provide a logical separation between different services. Usually you would want to create different namespaces for different environments: one for Prod and Staging. For this example, we just used "dev".

Create the namespace by executing the following command:

```bash
kubectl create namespace <name-of-namespace>
```
![namespacecreate.PNG](https://github.com/ChristinaLanaski/JupyterHub/blob/9925fdecaf1143f8d04cebe27594d307588246f1/images/namespacecreate.PNG)

Then execute the following to verify that the namesapce was created:

```bash
kubectl get namespaces
```



![devnamespace.png](https://github.com/ChristinaLanaski/JupyterHub/blob/9925fdecaf1143f8d04cebe27594d307588246f1/images/devnamespace.PNG))



<h4>Step 5: Create config.yaml</h4>

First create a directory where the config.yaml file will be stored:
```bash
mkdir <directory-name>
```
CD into that directory and make the config.yaml file with:
```bash
touch config.yaml
```
Ensure the file is there by executing "ls":

![step3.PNG](https://github.com/ChristinaLanaski/JupyterHub/blob/9925fdecaf1143f8d04cebe27594d307588246f1/images/step3.PNG))


This is the file that will hold all the configurations for your JuypterHub. For now, put some comments in the file (JupyterHub may not run if nothing is in the config.yaml file). You can modify the file contents by running:
```bash
vim config.yaml
```
To modify the contents of the file, press "i" on the keyboard. Then paste:
```bash
# This file can update the JupyterHub Helm chart's default configuration values.
#
# For reference see the configuration reference and default values, but make
# sure to refer to the Helm chart version of interest to you!
#
# Introduction to YAML:     https://www.youtube.com/watch?v=cdLNKUoMc6c
# Chart config reference:   https://zero-to-jupyterhub.readthedocs.io/en/stable/resources/reference.html
# Chart default values:     https://github.com/jupyterhub/zero-to-jupyterhub-k8s/blob/HEAD/jupyterhub/values.yaml
# Available chart versions: https://jupyterhub.github.io/helm-chart/
#
```

- once done, press "esc" then shift+: wq!, enter


Verify you saved the contents inside the file by running "cat config.yaml":

![images\initalyamlcomment.PNG](https://github.com/ChristinaLanaski/JupyterHub/blob/9925fdecaf1143f8d04cebe27594d307588246f1/images/initalyamlcomment.PNG))


<h4>Step 6: Install the JupyterHub HELM Chart onto your config file</h4>

Now that you have an AKS Service, helm and the JupyterHub repo installed, a namespace for the cluster and the config.yaml file created, the last thing that needs to be done is installing the JupyterHub helm chart onto your cofnig.yaml file. This is done by executing the following command:
```bash
helm upgrade --cleanup-on-fail \
  --install <helm-release-name> jupyterhub/jupyterhub \
  --namespace <k8s-namespace> \
  --create-namespace \
  --version=<chart-version> \
  --values config.yaml
```

- Helm-release-name: The [Helm Release Name](https://helm.sh/docs/glossary/#release) is the name of the instance that the chart will be installed on. You will need it when you are changing or deleteling the configuration of chart installation. There is no standardize naming convention, but use something that makes sense. For me, I used “jupyterhubv1.0"
- K8s-namespace: kubernetes namespace you created in step 6.
- chart-version: Make sure you install the lastest and stable versions of these charts listed [here](https://jupyterhub.github.io/helm-chart/)

>NOTE: This command will need to be ran anytime an update is made to the config.yaml file. Depending on the changes made, the update could take anywhere from a couple of seconds to a few minutes.

Once the update is completed, you will get the following message:

![images/JHHelmChartInstall.PNG](https://github.com/ChristinaLanaski/JupyterHub/blob/b46ea75419ea6ed6d549bcf5fa9c265740dafd54/images/JHHelmChartInstall.PNG)

Once you recieve that message, make sure your hub and proxy are ready and running:

```bash
kubectl --namespace=jupyterhub get pod
```

![images/HUB.PNG](https://github.com/ChristinaLanaski/JupyterHub/blob/9925fdecaf1143f8d04cebe27594d307588246f1/images/HUB.PNG)

In order to actually access your JuypterHub, execute 

```bash
kubectl --namespace=jupyterhub get svc proxy-public
```

Copy and past the EXTERNAL-IP into the bowser and it will take you to the login of your JupyterHub! :)

![images/externalip.PNG](https://github.com/ChristinaLanaski/JupyterHub/blob/105fc0a4cb9d6e9eb50b0d6b1f2ed61235b3381d/images/externalip.PNG)


And there you have it! You created your very own JupyterHub! A couple things to note is...
- JupyterHub is initially over an unsecured HTTP connection. There are instructions below on how to make it secure. It is HIGHLY recommened to do this as soon as you are able to get your Hub up and running....or even put it in your config.yaml file before initial deployment
- There is no set username or password to actually get into the Hub. You can fill out anything for the username and password and you will be able to access the Hub. Configuration of this is instructed below.

------
<h2>Configuration of JupyterHub</h2>

>This is only walking through very basic configuration of JupyterHub. There are MANY different ways you can configure your Hub to fit your needs. You can find all this info [here](https://zero-to-jupyterhub.readthedocs.io/en/latest/jupyterhub/customization.html)

In order to create a secure site, you will need to create an A Record for your JupyterHub. Follow [Microsofts instructions](https://docs.microsoft.com/en-us/azure/dns/dns-getstarted-portal) to create one. The IP address will be the EXTERNAL IP. To find it, run:
```bash
kubectl --namespace=jupyterhub get svc proxy-public
```

Once the DNS record is created, open your config.yaml file within your namespace and input the following:
```bash
proxy:
  https:
    enabled: true
    hosts:
      - <your-domain-name>
    letsencrypt:
      contactEmail: <your-email-address>
```
*NOTE: this method is using letsencrypt which is a nonprofit CA provider TLS certificates. It works well for this demo but make sure to use the best method listed in the Project Juypter docs for your use case*


Run the helm-upgrade command listed in step 6 to apply the changes to your site:
```bash
helm upgrade --cleanup-on-fail \
  --install <helm-release-name> jupyterhub/jupyterhub \
  --namespace <k8s-namespace> \
  --create-namespace \
  --version=<chart-version> \
  --values config.yaml
```
 After the upgrade is completed, you should now be able to browse to https://<DOMAIN_NAME>.com and not http://<EXTERNAL_IP>.

<h4>Configuring Users</h4>

You can configure users many different ways, even through authenticating through GitLab. But for this example, we are just going to a very simple admin and allowed_users configuration. Enter the following into your config.yaml file and the helm-upgrade command after:
```bash
hub:
  config:
    Authenticator:
      admin_users:
        - user1
        - user2
      allowed_users:
        - user3
        - user4
    # ...
    DummyAuthenticator:
      password: a-shared-secret-password
    JupyterHub:
      authenticator_class: dummy
```

Now you will only be able to login to your JupyterHub with a username and password listed above. You will no longer be able to access it by entering any set of charaters for the username/password into JupyterHub.

<h4>Customizing the UI</h4>

Just like everything else, there are a LOT of different ways to customize your UI. Jupyter works with Docker Images to pull specific images for different use cases. You can view this repository [here](https://github.com/jupyter/docker-stacks/) and [which images to use](https://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html).  The jupyter/datascience-notebook image is used in this example which comes with Python, R, Julia, a terminal, Markdown, and more. Enter the following into your config.yaml file and run the helm-upgrade command:
```bash
singleuser:
  image:
    # You should replace the "latest" tag with a fixed version from:
    # https://hub.docker.com/r/jupyter/datascience-notebook/tags/
    # Inspect the Dockerfile at:
    # https://github.com/jupyter/docker-stacks/tree/HEAD/datascience-notebook/Dockerfile
    name: jupyter/datascience-notebook
    tag: latest
  # `cmd: null` allows the custom CMD of the Jupyter docker-stacks to be used
  # which performs further customization on startup.
  cmd: null
  ```

*Note: The comments do not NEED to be in the config, but good to have them for later reference*

This is will take a couple of minutes to update, but once it does, browse to your JupyterHub and you will see a new UI once you login:

![images/ConfiguredUI.PNG](https://github.com/ChristinaLanaski/JupyterHub/blob/9925fdecaf1143f8d04cebe27594d307588246f1/images/ConfiguredUI.PNG)

With all these configurations, this is what the final config.yaml file looks like:

![images/configend.PNG](https://github.com/ChristinaLanaski/JupyterHub/blob/9925fdecaf1143f8d04cebe27594d307588246f1/images/configend.PNG)

#### Useful Links ###
[Using ACR with AKS](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-get-started-azure-cli)

[HELM CLI Commands](https://docs.microsoft.com/en-us/cli/azure/acr/helm?view=azure-cli-latest)
