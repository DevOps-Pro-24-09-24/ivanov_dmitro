vpc-xxxxxxxx: Ідентифікатор створеної VPC.
subnet-xxxxxxxx: Ідентифікатор публічної підмережі.
subnet-yyyyyyyy: Ідентифікатор приватної підмережі.
igw-xxxxxxxx: Ідентифікатор Internet Gateway.
rtb-xxxxxxxx: Ідентифікатор маршрутної таблиці.



1. **Створення VPC**
{
    "Vpc": {
        "OwnerId": "180294197747",
        "InstanceTenancy": "default",
        "Ipv6CidrBlockAssociationSet": [],
        "CidrBlockAssociationSet": [
            {
                "AssociationId": "vpc-cidr-assoc-070e5c92da4dbcb68",
                "CidrBlock": "192.168.0.0/24",
                "CidrBlockState": {
                    "State": "associated"
                }
            }
        ],
        "IsDefault": false,
        "VpcId": "vpc-0f23c63e2df730c92",
        "State": "pending",
        "CidrBlock": "192.168.0.0/24",
        "DhcpOptionsId": "dopt-0e6882b007c17c65e"
    }
}
2. **Створення підмереж**
Публічна підмережа:
aws ec2 create-subnet --vpc-id vpc-0f23c63e2df730c92 --cidr-block 192.168.0.0/25
{
    "Subnet": {
        "AvailabilityZoneId": "euc1-az2",
        "OwnerId": "180294197747",
        "AssignIpv6AddressOnCreation": false,
        "Ipv6CidrBlockAssociationSet": [],
        "SubnetArn": "arn:aws:ec2:eu-central-1:180294197747:subnet/subnet-0eb0eddb61d1b8c30",
        "EnableDns64": false,
        "Ipv6Native": false,
        "PrivateDnsNameOptionsOnLaunch": {
            "HostnameType": "ip-name",
            "EnableResourceNameDnsARecord": false,
            "EnableResourceNameDnsAAAARecord": false
        },
        "SubnetId": "subnet-0eb0eddb61d1b8c30",
        "State": "available",
        "VpcId": "vpc-0f23c63e2df730c92",
        "CidrBlock": "192.168.0.0/25",
        "AvailableIpAddressCount": 123,
        "AvailabilityZone": "eu-central-1a",
        "DefaultForAz": false,
        "MapPublicIpOnLaunch": false
    }
}
Приватна підмережа:
aws ec2 create-subnet --vpc-id vpc-0f23c63e2df730c92 --cidr-block 192.168.0.128/25
{
    "Subnet": {
        "AvailabilityZoneId": "euc1-az2",
        "OwnerId": "180294197747",
        "AssignIpv6AddressOnCreation": false,
        "Ipv6CidrBlockAssociationSet": [],
        "SubnetArn": "arn:aws:ec2:eu-central-1:180294197747:subnet/subnet-038071795ca4dd3e4",
        "EnableDns64": false,
        "Ipv6Native": false,
        "PrivateDnsNameOptionsOnLaunch": {
            "HostnameType": "ip-name",
            "EnableResourceNameDnsARecord": false,
            "EnableResourceNameDnsAAAARecord": false
        },
        "SubnetId": "subnet-038071795ca4dd3e4",
        "State": "available",
        "VpcId": "vpc-0f23c63e2df730c92",
        "CidrBlock": "192.168.0.128/25",
        "AvailableIpAddressCount": 123,
        "AvailabilityZone": "eu-central-1a",
        "DefaultForAz": false,
        "MapPublicIpOnLaunch": false
    }
}
3. **Створення Security group**
aws ec2 authorize-security-group-egress --group-id sg-0190270be72b919bd --protocol -1 --port all --cidr 0.0.0.0/0


aws ec2 create-security-group --group-name Back --description "Back security group" --vpc-id vpc-0f23c63e2df730c92
{
    "GroupId": "sg-0ed9df91934602203",
    "SecurityGroupArn": "arn:aws:ec2:eu-central-1:180294197747:security-group/sg-0ed9df91934602203"
}
4. **Створення Internet Gateway**
{
    "InternetGateway": {
        "Attachments": [],
        "InternetGatewayId": "igw-0b6a4167a74b8d6ac",
        "OwnerId": "180294197747",
        "Tags": []
    }
}
5. **Прив'язка Internet Gateway до VPC**
aws ec2 attach-internet-gateway --vpc-id vpc-0f23c63e2df730c92 --internet-gateway-id igw-0b6a4167a74b8d6ac
6. **Створення маршрутної таблиці для публічної підмережі**
aws ec2 create-route-table --vpc-id vpc-0f23c63e2df730c92
{
    "RouteTable": {
        "Associations": [],
        "PropagatingVgws": [],
        "RouteTableId": "rtb-05f073e71f8ea33be",
        "Routes": [
            {
                "DestinationCidrBlock": "192.168.0.0/24",
                "GatewayId": "local",
                "Origin": "CreateRouteTable",
                "State": "active"
            }
        ],
        "Tags": [],
        "VpcId": "vpc-0f23c63e2df730c92",
        "OwnerId": "180294197747"
    },
    "ClientToken": "ed3321aa-7731-4a41-9ec5-d99292f1b736"
}
7. **Додавання маршруту до Internet Gateway**
aws ec2 create-route --route-table-id rtb-05f073e71f8ea33be --destination-cidr-block 0.0.0.0/0 --gateway-id igw-0b6a4167a74b8d6ac
{
    "Return": true
}
8. **Прив'язка публічної підмережі до маршрутної таблиці**
aws ec2 associate-route-table --subnet-id subnet-0eb0eddb61d1b8c30 --route-table-id rtb-05f073e71f8ea33be
{
    "AssociationId": "rtbassoc-0ca3a624198faab17",
    "AssociationState": {
        "State": "associated"
    }
}
9. **Встановлення публічної підмережі як публічної**
aws ec2 modify-subnet-attribute --subnet-id subnet-0eb0eddb61d1b8c30 --map-public-ip-on-launch
10. **Приватна підмережа**
Приватна підмережа створена, але без доступу до Інтернету через відсутність маршруту до Internet Gateway.

11. **Створення ключа доступу**
aws ec2 create-key-pair --key-name NewKeyPair --query 'KeyMaterial' --output text > ~/keys/NewKeyPair.pem
chmod 400 ~/keys/NewKeyPair.pem
12. **Створення WEB інстанса у публічній підмережі**
aws ec2 run-instances --image-id ami-00ac244ee0ad9050d --count 1 --instance-type t2.micro --key-name NewKeyPair --subnet-id subnet-0eb0eddb61d1b8c30 --associate-public-ip-address


{
    "ReservationId": "r-03978aea135ab8777",
    "OwnerId": "180294197747",
    "Groups": [],
    "Instances": [
        {
            "Architecture": "x86_64",
            "BlockDeviceMappings": [],
            "ClientToken": "f262e1eb-d099-416e-82aa-e26f47c4c98c",
            "EbsOptimized": false,
            "EnaSupport": true,
            "Hypervisor": "xen",
            "NetworkInterfaces": [
                {
                    "Attachment": {
                        "AttachTime": "2024-11-23T13:04:11+00:00",
                        "AttachmentId": "eni-attach-0fc4e429b048c9edf",
                        "DeleteOnTermination": true,
                        "DeviceIndex": 0,
                        "Status": "attaching",
                        "NetworkCardIndex": 0
                    },
                    "Description": "",
                    "Groups": [

13. **Створення DB інстанса у приватній підмережі**
aws ec2 run-instances --image-id ami-00ac244ee0ad9050d --count 1 --instance-type t2.micro --key-name MyKeyPair --subnet-id subnet-038071795ca4dd3e4
{
    "ReservationId": "r-07ae8004811fd1fdd",
    "OwnerId": "180294197747",
    "Groups": [],
    "Instances": [
        {
            "Architecture": "x86_64",
            "BlockDeviceMappings": [],
            "ClientToken": "9cf8c6f0-c149-4bc8-a991-0a4a19ba69ff",
            "EbsOptimized": false,
            "EnaSupport": true,
            "Hypervisor": "xen",
            "NetworkInterfaces": [
                {
                    "Attachment": {
                        "AttachTime": "2024-11-23T13:47:42+00:00",
                        "AttachmentId": "eni-attach-05700e5f16baf4b80",
                        "DeleteOnTermination": true,
                        "DeviceIndex": 0,
:




Подключение к серверу
host web-host
    HostName 3.121.219.144
    User ec2-user
    IdentityFile ~/keys/NewKeyPair.pem

Host db-host
    HostName 192.168.0.155
    User ec2-user
    IdentityFile ~/keys/NewKeyPair.pem
    ProxyJump web-host
