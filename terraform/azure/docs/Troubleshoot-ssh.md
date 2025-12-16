# Troubleshoot SSH connectivity

Show hosts:
```bash
<swrepo>/terraform/azure$ make show-hosts
> Prefix: sandbox
> Resource Group: sandbox-spotfire-rg

az vm list-ip-addresses \
	--resource-group sandbox-spotfire-rg \
	--output table
VirtualMachine         PublicIPAddresses    PrivateIPAddresses
---------------------  -------------------  --------------------
sandbox-jumphost-0-vm  4.231.228.131        10.0.0.4
sandbox-tss-0-vm                            10.0.1.4
sandbox-tss-1-vm                            10.0.1.6
sandbox-wp-0-vm                             10.0.1.5
sandbox-wp-1-vm                             10.0.1.7
```

Export variables:
```bash
export JUMPHOST_USER=spotfire
export JUMPHOST_PRIVATE_KEY=~/.ssh/id_rsa_azure

export TARGET_USER=spotfire
export TARGET_PRIVATE_KEY=~/.ssh/id_rsa_azure

export JUMPHOST_ADDRESS=4.231.228.131 
export TARGET_ADDRESS=10.0.1.4 
```

Programatically:
```bash
export JUMPHOST_ADDRESS=$(make show-hosts | grep jumphost | awk '{print $2}')
export TARGET_ADDRESS=$(make show-hosts | grep sfs-0 | awk '{print $2}')
```

Verify SSH to jumphost (first hop):
```bash
ssh ${JUMPHOST_USER}@${JUMPHOST_ADDRESS} \
  -i ${JUMPHOST_PRIVATE_KEY} \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -vv
```

Verify SSH to target via jumphost (two hops):
```bash
ssh -o "User=${TARGET_USER}" \
  -i ${JUMPHOST_PRIVATE_KEY} \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -o StrictHostKeyChecking=no \
  -o ConnectTimeout=40 \
  -o "ProxyCommand ssh -W %h:%p ${JUMPHOST_USER}@${JUMPHOST_ADDRESS} -i ${TARGET_PRIVATE_KEY} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" ${TARGET_ADDRESS}
```

Example of OK connection (only if direct connection, better use the LB address:
```bash
$ curl 127.0.0.1:80 -v -H "Host: spotfire.local" -L
$ curl 10.0.1.4:80 -v -H "Host: spotfire.local" -L
```
