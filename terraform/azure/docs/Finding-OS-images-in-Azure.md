
# Finding OS images in Azure 

Quick notes on finding OS images in Azure.

References:

- https://docs.microsoft.com/en-us/azure/virtual-machines/linux/cli-ps-findimage
- https://lnx.azurewebsites.net/how-to-search-all-vm-images-in-azure/

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
