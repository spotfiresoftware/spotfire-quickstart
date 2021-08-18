
# Finding OS VM images in AWS 

Quick notes on finding OS VM images in AWS.

> An Amazon Machine Image (AMI) is a template that contains a software configuration (for example, an operating system, an application server, and applications). From an AMI, you launch an instance, which is a copy of the AMI running as a virtual server in the cloud

References:

- https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instances-and-amis.html
- https://aws.amazon.com/ec2/instance-types/
- https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/finding-an-ami.html

## Instances

S m4.xlarge
M

----
EC2 Hardware:		Current OS	Windows	Windows	Windows	Linux	Linux	Linux	Windows	Windows	Linux
------------|----------------------
            Tss	        Wp 	        As          St          Py      	Edge    	Jump    	Tc          Vnat
Test:		m3.large	m5.xlarge	m3.medium	c4.large	c4.large	m3.medium	t2.medium	m3.xlarge	m3.medium
Small:		m4.xlarge	m5.2xlarge	m4.xlarge	c4.xlarge	c4.xlarge	m3.medium	t2.medium	m3.xlarge	m3.medium
Medium:		c4.2xlarge	m4.4xlarge	m4.2xlarge	c4.2xlarge	c4.2xlarge	m3.medium	t2.medium	m3.xlarge	m3.medium
Large:		c4.4xlarge	m4.10xlarge	m4.4xlarge	c5.4xlarge	c5.4xlarge	m4.large	t2.medium	m3.xlarge	m3.medium
Xlarge:		c4.8xlarge	m4.16xlarge	m4.10xlarge	c5.9xlarge	c5.9xlarge	m4.large	t2.medium	m3.xlarge	m3.medium

## Login to Azure

After you installed az cli, you need to login to Azure.

```bash
$ az login
You have logged in. Now let us find all the subscriptions to which you have access...
[
  {
    "cloudName": "AzureCloud",
    "homeTenantId": "00000000-0000-0000-0000-000000000000",
    "id": "00000000-0000-0000-0000-000000000000",
    "isDefault": true,
    "managedByTenants": [],
    "name": "azrspotfiredev01-SpotfireDevelopment",
    "state": "Enabled",
    "tenantId": "00000000-0000-0000-0000-000000000000",
    "user": {
      "name": "myself@tibco.com",
      "type": "user"
    }
  }
]
```

## Generic Queries

List locations

```bash
$ az account list-locations > build/azure.locations.txt
```

List popular images (this query takes long time):

```bash
az vm image list --output table > build/azure.image_list.txt
```

List publishers:

```bash
az vm image list-publishers --location northeurope --output table > build/northeurope.publishers.txt
```

## Find out what you are looking for

Listing offers from OpenLogic (CentOS publisher):

```bash
az vm image list-offers --location northeurope --publisher OpenLogic --output table > build/northeurope.publishers.OpenLogic.txt
```   

Finding out the available skus for CentOS:

```bash
az vm image list-skus --location northeurope --publisher OpenLogic --offer CentOS --output table > build/northeurope.publishers.OpenLogic.Centos.txt
```   

Querying after a specific CentOS version.

```bash
az vm image list --location northeurope --publisher OpenLogic --offer CentOS --sku 8_2 --all --output table > build/northeurope.publishers.OpenLogic.Centos.versions.txt
```

Generic queries for CentOS, RHEL, SUSE, openSUSE, Debian images.

```bash
az vm image list --location northeurope --publisher OpenLogic --all --output table > build/northeurope.publishers.OpenLogic.txt
az vm image list --location northeurope --publisher RedHat --all --output table > build/northeurope.publishers.RedHat.txt
az vm image list --location northeurope --publisher SUSE --all --output table > build/northeurope.publishers.SUSE.txt
az vm image list --location northeurope --publisher Debian --all --output table > build/northeurope.publishers.Debian.txt
```

Querying after Windows offers.

```bash
az vm image list-offers --location northeurope --publisher MicrosoftWindowsServer --output table > build/northeurope.publishers.MicrosoftWindowsServer.txt
az vm image list-skus --location northeurope --publisher MicrosoftWindowsServer --offer WindowsServer --output table > build/northeurope.publishers.MicrosoftWindowsServer.WindowsServer.txt
```
