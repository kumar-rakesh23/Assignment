# Assignment
This code will create the basic infrastructure including VPC, Subnet, RouteTable, InternetGateway, SecurityGroups, ELB, AutoScaling and Ec2 Instances.All the Ec2 instance are linux system and can be connected over SSH by using Keypair.

# Prerequisite
To execute the code a terraform server need to create. To launch the infrastructure in AWS environment Terraform server should be configured with the required Access key and Secrate key. We can also pass the Access key and Secrate key through the CI tool variable at the time of deployment.

A S3 buckect "testcreate" should be created before to store the state file.
A KeyPair should be created before to launch the instance at the time of deployment.
