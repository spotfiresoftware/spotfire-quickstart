# Troubleshoot SSH connectivity

Show hosts:
```bash
<swrepo>/terraform/aws$ make show-hosts
> Prefix: sandbox-mario
> Resource Group: sandbox-mario-spotfire-rg

Name            PrivateIpAddres PublicIpAddress PublicDnsName
--------------- --------------- --------------- ---------------
sandbox-mario-jumphost-0        10.0.10.177     13.51.161.37    ec2-13-51-161-37.eu-north-1.compute.amazonaws.com
sandbox-mario-sfs-0     10.0.0.53       None
sandbox-mario-sfs-1     10.0.1.124      None
sandbox-mario-wp-0      10.0.0.47       None
sandbox-mario-wp-1      10.0.1.71       None
```

Export variables:
```bash
export JUMPHOST_USER=admin
export JUMPHOST_PRIVATE_KEY=~/.ssh/id_rsa_aws
export JUMPHOST_PRIVATE_KEY=id_rsa_aws.pem

export TARGET_USER=admin
export TARGET_PRIVATE_KEY=~/.ssh/id_rsa_aws

export JUMPHOST_ADDRESS=13.51.161.37 
export TARGET_ADDRESS=10.0.0.53 
```
**Note**: In AWS, the default user for Debian is "admin", for Ubuntu is "ubuntu", for CentOS is "centos", for RHEL is "ec2-user".

Programatically:
```bash
export JUMPHOST_ADDRESS=$(make show-hosts | grep jumphost | awk '{print $3}')
export TARGET_ADDRESS=$(make show-hosts | grep sfs-0 | awk '{print $2}')
echo $JUMPHOST_ADDRESS
echo $TARGET_ADDRESS
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
$ curl 10.0.0.53:80 -v -H "Host: spotfire.local" -L
```
