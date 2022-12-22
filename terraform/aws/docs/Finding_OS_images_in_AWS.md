
# Finding OS VM images in AWS 

Quick notes on finding OS VM images in AWS.

> An Amazon Machine Image (AMI) is a template that contains a software configuration (for example, an operating system, an application server, and applications). From an AMI, you launch an instance, which is a copy of the AMI running as a virtual server in the cloud

References:
- https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instances-and-amis.html
- https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/finding-an-ami.html
- https://aws.amazon.com/ec2/instance-types/
- https://aws.amazon.com/ec2/previous-generation/
- https://aws.amazon.com/blogs/compute/query-for-the-latest-amazon-linux-ami-ids-using-aws-systems-manager-parameter-store/
- https://wiki.debian.org/Amazon/EC2/HowTo/awscli
- https://docs.aws.amazon.com/cli/latest/reference/ec2/
- https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-images.html

## Examples

Get list of all official Debian AMIs:
```bash
aws ec2 describe-images --region eu-north-1 --owners 136693071363 --query 'sort_by(Images, &CreationDate)[].[CreationDate,Name,ImageId]' --output table
```
Get list of all official Debian AMIs using a filter:
```bash
aws ec2 describe-images --region eu-north-1 --owners 136693071363 --filters 'Name=architecture,Values=x86_64' 'Name=name,Values=debian-11*' --query 'sort_by(Images, &CreationDate)[].[CreationDate,Name,ImageId]' --output table
```

## How to obtain the ownerId

Browsing in AWS Marketplace for Debian images, we find the [Debian 11 AMI](https://aws.amazon.com/marketplace/pp/prodview-l5gv52ndg5q6i).

Click on the "Continue" button, and you will be redirected to the Launch on EC2 page. 
From this page, we actually just want to extract the productId for the AMI from the page’s URL.

For example, for https://aws.amazon.com/marketplace/server/procurement?productId=a264997c-d509-4a51-8e85-c2644a3f8ba2 , 
the productId is `a264997c-d509-4a51-8e85-c2644a3f8ba2`.

Now, we can search images filtering by that productId to obtain the common ownerId:
```bash
$ aws ec2 describe-images --owners aws-marketplace --filters "Name=name,Values=*a264997c-d509-4a51-8e85-c2644a3f8ba2*" | jq -r '.Images[] | "\(.OwnerId)\t\(.Name)"'
679593333241	debian-11-amd64-20221020-1174-a264997c-d509-4a51-8e85-c2644a3f8ba2
679593333241	debian-11-amd64-20220816-1109-a264997c-d509-4a51-8e85-c2644a3f8ba2
679593333241	debian-11-amd64-20220613-1045-a264997c-d509-4a51-8e85-c2644a3f8ba2
...
```

Finally, we can search the images' imageId from that ownerId:
```bash
$ aws ec2 describe-images --region eu-north-1 --owners 679593333241 --filters 'Name=architecture,Values=x86_64' 'Name=name,Values=debian-11*' --query 'sort_by(Images, &CreationDate)[].[CreationDate,Name,ImageId]' --output table
...
|  2022-09-12T01:34:32.000Z|  debian-11-amd64-20220911-1135-a264997c-d509-4a51-8e85-c2644a3f8ba2  |  ami-032a7dbd87be77844  |
|  2022-10-21T16:01:50.000Z|  debian-11-amd64-20221020-1174-a264997c-d509-4a51-8e85-c2644a3f8ba2  |  ami-089ecf42810752757  |
|  2022-11-10T00:40:39.000Z|  debian-11-amd64-20221108-1193-a264997c-d509-4a51-8e85-c2644a3f8ba2  |  ami-09561a092f2052f25 
```
