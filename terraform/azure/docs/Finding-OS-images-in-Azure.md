# Finding OS images in Azure 

Quick notes on finding OS images in Azure.

References:
- [Find Azure Marketplace image information using the Azure CLI](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/cli-ps-findimage)
- [How to search all VM images in Azure](https://lnx.azurewebsites.net/how-to-search-all-vm-images-in-azure/)

## Login to Azure

After you installed az cli, you need to log in to Azure.
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

List locations:
```bash
$ az account list-locations > build/azure.locations.txt
```

List popular images (this query takes very long time, see below for more specific searches):
```bash
az vm image list --output table > build/az-vm-image-list.txt
```

## How to find out what you are looking for

A top-down approach:

1. List publishers in a location:
    ```bash
    export LOCATION=northeurope
    az vm image list-publishers --location northeurope --output table > build/az-vm-image-list-publishers--location-${LOCATION}.txt
    ```

2. List offers from that publisher (Debian) in the specified location (North Europe):
    ```bash
    export PUBLISHER=Debian
    az vm image list-offers --location ${LOCATION} --publisher ${PUBLISHER} --output table > build/az-vm-image-list--location-${LOCATION}--publisher-${PUBLISHER}.txt
    ```  

3. Finding out the available SKUs (versions) for `debian-12`:
    ```bash
    export OFFER=debian-12
    az vm image list-skus --location ${LOCATION} --publisher ${PUBLISHER} --offer ${OFFER} --output table > build/az-vm-image-list--location-${LOCATION}--publisher-${PUBLISHER}--offer-${OFFER}.txt
    ```   

4. Querying after as specific SKU:
   ```bash
   export SKU=12
   az vm image list --location northeurope --publisher ${PUBLISHER} --offer ${OFFER} --sku ${SKU} --all --output table > build/az-vm-image-list--location-${LOCATION}--publisher-${PUBLISHER}--offer-${OFFER}--sku-11.txt
   ```

As a generic approach, theses are generic queries for CentOS, RHEL, SUSE, openSUSE, Debian images:
```bash
export PUBLISHER=Debian    && az vm image list --location ${LOCATION} --publisher ${PUBLISHER} --all --output table > build/az-vm-image-list--location-${LOCATION}--publisher-${PUBLISHER}.txt
export PUBLISHER=Ubuntu    && az vm image list --location ${LOCATION} --publisher ${PUBLISHER} --all --output table > build/az-vm-image-list--location-${LOCATION}--publisher-${PUBLISHER}.txt
export PUBLISHER=OpenLogic && az vm image list --location ${LOCATION} --publisher ${PUBLISHER} --all --output table > build/az-vm-image-list--location-${LOCATION}--publisher-${PUBLISHER}.txt
export PUBLISHER=RedHat    && az vm image list --location ${LOCATION} --publisher ${PUBLISHER} --all --output table > build/az-vm-image-list--location-${LOCATION}--publisher-${PUBLISHER}.txt
export PUBLISHER=SUSE      && az vm image list --location ${LOCATION} --publisher ${PUBLISHER} --all --output table > build/az-vm-image-list--location-${LOCATION}--publisher-${PUBLISHER}.txt
```

And, for querying after Microsoft Windows Server offers:
```bash
export PUBLISHER=MicrosoftWindowsServer
az vm image list-offers --location ${LOCATION} --publisher ${PUBLISHER} --output table > build/az-vm-image-list-offers--location-${LOCATION}--publisher-${PUBLISHER}.txt
az vm image list-skus   --location ${LOCATION} --publisher ${PUBLISHER} --offer WindowsServer --output table > build/az-vm-image-list-skus--location-${LOCATION}--publisher-${PUBLISHER}--offer-WindowsServer.txt
```
