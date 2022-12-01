##--------------- set terraform conf  ---------------##
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
    curl = {
      version = "0.1.4"
      source  = "anschoewe/curl"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "eu-west-3" #paris
   #region  = "eu-west-1" #dublin
  # region  = "eu-central-1" #paris
}

##--------------- VPC SC4SNMP ---------------##

resource "aws_vpc" "SC4SNMP" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"
   
 
  tags = {
    Name = "SC4SNMP"
    Build ="V1.0"
    Builder = "terraform"
    owner = "Guillaume Landy"
  }

  }

  
## --------------- Provision  2 subnet (internal / external) SC4SNMP ---------------##
 
  resource "aws_subnet" "Lan" {
  vpc_id     = aws_vpc.SC4SNMP.id
  cidr_block = "192.168.100.0/24"
availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "SC4SNMP_Lan"
  }
}
resource "aws_subnet" "Wan" {
  vpc_id     = aws_vpc.SC4SNMP.id
  cidr_block = "192.168.10.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "SC4SNMP_Wan"
  }
}
## --------------- Provision all network interface with fixed ip  -------------------##
resource "aws_network_interface" "OpenWRT_private_interface" {
  subnet_id   = aws_subnet.Lan.id
  private_ips = ["192.168.100.10"]
  source_dest_check = false
security_groups = [aws_security_group.SC4SNMP.id]
  tags = {
    Name = "OpenWRT_primary_network_interface"
  }
}
resource "aws_network_interface" "windows1_private_interface" {
  subnet_id   = aws_subnet.Lan.id
  private_ips = ["192.168.100.11"]
security_groups = [aws_security_group.SC4SNMP.id]
  tags = {
    Name = "Windows1_primary_network_interface"
  }
}
resource "aws_network_interface" "windows2_private_interface" {
  subnet_id   = aws_subnet.Lan.id
  private_ips = ["192.168.100.13"]
security_groups = [aws_security_group.SC4SNMP.id]
  tags = {
    Name = "Windows2_primary_network_interface"
  }
}
resource "aws_network_interface" "linux1_private_interface" {
  subnet_id   = aws_subnet.Lan.id
  private_ips = ["192.168.100.12"]
security_groups = [aws_security_group.SC4SNMP.id]
  tags = {
    Name = "Windows1_primary_network_interface"
  }
}
resource "aws_network_interface" "Splunk_private_interface" {
  subnet_id   = aws_subnet.Lan.id
  private_ips = ["192.168.100.20"]
security_groups = [aws_security_group.SC4SNMP.id]
  tags = {
    Name = "Splunk_primary_network_interface"
  }
}

resource "aws_network_interface" "SC4SNMP_private_interface" { ## --------------- in case wee need a dedicated machine for SC4SNMP
  subnet_id   = aws_subnet.Lan.id
  private_ips = ["192.168.100.21"]
security_groups = [aws_security_group.SC4SNMP.id]
  tags = {
    Name = "SC4SNMP_primary_network_interface"
  }
}
## --------------- Provision OpenWRT Public interface  and bind it to  WAN subnet -------------------##
resource "aws_network_interface" "SC4SNMP_OpenWRT_WAN" {
  subnet_id       = aws_subnet.Wan.id
  security_groups = [aws_security_group.SC4SNMP.id]
  source_dest_check = false
  attachment {
    instance     = aws_instance.Openwrt.id
    device_index = 1
  }
}
## --------------- Provision Windows Public interface  and bind it to  WAN subnet -------------------##
##resource "aws_network_interface" "windows1_WAN" {
 ## subnet_id       = aws_subnet.Wan.id
 ## security_groups = [aws_security_group.SC4SNMP.id]
 ## source_dest_check = false
 ## attachment {
 ##   instance     = aws_instance.windows1.id
 ##   device_index = 1
 ### }
##}
## --------------- Provision Internet gateway external SC4SNMP  -------------------##
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.SC4SNMP.id

  tags = {
    Name = "SC4SNMP_internet_gateway"
  }
}

## --------------- Create Security group tcp 22 80 3389 -------------------##
resource "aws_security_group" "SC4SNMP" {
  name        = "SC4SNMP inbound 22 443 80 3389"
  description = "SC4SNMP SG Rules"
  vpc_id      = aws_vpc.SC4SNMP.id

  
   ingress {
    description      = "all proto interne"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [aws_vpc.SC4SNMP.cidr_block]
    #cidr_blocks      =  ["0.0.0.0/0"]
  }
  
  
  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    #cidr_blocks      = [aws_vpc.SC4SNMP.cidr_block]
    cidr_blocks      =  ["0.0.0.0/0"]
  }

ingress {
    description      = "http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    #cidr_blocks      = [aws_vpc.SC4SNMP.cidr_block]
    cidr_blocks      =  ["0.0.0.0/0"]
    
  }
  ingress {
    description      = "https"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    #cidr_blocks      = [aws_vpc.SC4SNMP.cidr_block]
    cidr_blocks      =  ["0.0.0.0/0"]
    
  }
ingress {
    description      = "rdpt_ranlate"
    from_port        = 8389
    to_port          = 8390
    protocol         = "tcp"
   # cidr_blocks      = [aws_vpc.SC4SNMP.cidr_block]
 cidr_blocks      =  ["0.0.0.0/0"]
  }
  ingress {
    description      = "rdp"
    from_port        = 3389
    to_port          = 3390
    protocol         = "tcp"
   # cidr_blocks      = [aws_vpc.SC4SNMP.cidr_block]
 cidr_blocks      =  ["0.0.0.0/0"]
  }
 ingress {
    description      = "Splunk interface"
    from_port        = 8000
    to_port          = 8000
    protocol         = "tcp"
   # cidr_blocks      = [aws_vpc.SC4SNMP.cidr_block]
 cidr_blocks      =  ["0.0.0.0/0"]
  }
  ingress {
    description      = "Splunk HEC"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
   # cidr_blocks      = [aws_vpc.SC4SNMP.cidr_block]
 cidr_blocks      =  ["0.0.0.0/0"]
  }
   ingress {
    description      = "Splunk curl token"
    from_port        = 8089
    to_port          = 8089
    protocol         = "tcp"
   # cidr_blocks      = [aws_vpc.SC4SNMP.cidr_block]
 cidr_blocks      =  ["0.0.0.0/0"]
  }
ingress {
    description      = "openwrt_http"
    from_port        = 65080
    to_port          = 65080
    protocol         = "tcp"
   # cidr_blocks      = [aws_vpc.SC4SNMP.cidr_block]
 cidr_blocks      =  ["0.0.0.0/0"]
  }
  ingress {
    description      = "openwrt_https"
    from_port        = 65443
    to_port          = 65443
    protocol         = "tcp"
   # cidr_blocks      = [aws_vpc.SC4SNMP.cidr_block]
 cidr_blocks      =  ["0.0.0.0/0"]
  }
   ingress {
    description      = "openwrt_ssh"
    from_port        = 65022
    to_port          = 65022
    protocol         = "tcp"
   # cidr_blocks      = [aws_vpc.SC4SNMP.cidr_block]
 cidr_blocks      =  ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
   
  }

  tags = {
    Name = "allow_22_80_3389"
    Workspace = terraform.workspace
  }
} 
## --------------- Create OpenWrt instance -------------------##
resource "aws_instance" "Openwrt" {
 #ami           = "ami-043ed0998d147c176"
 ami           = "ami-0fac7389be786f63a" ##V4 current paris   
   #ami           = "ami-0fac7389be786f63a" ##V4 current dublin 
  instance_type = "t2.micro"
  tags = {
    Name="SC4SNMP_Openwrt"
  Workspace = terraform.workspace
 }
  #associate_public_ip_address = false
  #subnet_id = aws_subnet.Lan.id
  #source_dest_check = false
  availability_zone = data.aws_availability_zones.available.names[0]
  key_name = var.AWS_KEY_NAME
 network_interface {
    network_interface_id = aws_network_interface.OpenWRT_private_interface.id
    device_index         = 0
  }
  
  #security_groups = [aws_security_group.SC4SNMP.id]
  root_block_device {
    volume_size = var.Openwrt_volume_size
    volume_type = "gp2"
  }
 
    
}  




resource "aws_eip" "WAN_eip" {
  vpc                       = true
   depends_on = [aws_internet_gateway.gw]
  
}
resource "aws_eip_association" "WAN_eip_assoc" {
  #instance_id   = aws_instance.Openwrt.id
  allocation_id = aws_eip.WAN_eip.id
  network_interface_id = aws_network_interface.SC4SNMP_OpenWRT_WAN.id
  
}

## --------------- create "Public" route table and bind it to subnet "WAN" (Internet gateway)## -------------------##
resource "aws_route_table" "public_network_route" {
  vpc_id = aws_vpc.SC4SNMP.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}
resource "aws_route_table_association" "wan" {
  subnet_id      = aws_subnet.Wan.id
  route_table_id = aws_route_table.public_network_route.id
}
  

  ## --------------- create "Private" route table and bind it to subnet "LAN" (openWRt interface)## -------------------##

 data "aws_availability_zones" "available" {
  state = "available"
}


resource "aws_route_table" "private_network_route" {
  vpc_id = aws_vpc.SC4SNMP.id
  route {
    cidr_block = "0.0.0.0/0"
    network_interface_id  = aws_instance.Openwrt.primary_network_interface_id
  }
}
resource "aws_route_table_association" "Lan" {
  subnet_id      = aws_subnet.Lan.id
  route_table_id = aws_route_table.private_network_route.id
}



## --------------- Provision linux instance attachement on LAN side -------------------##
resource "aws_instance" "linux1" {
  #ami           = "ami-0a1ee2fb28fe05df3"
  ami           = "ami-0d1533530bc7a81ba" #paris
 #ami           = "ami-0d71ea30463e0ff8d" #dublin
 # instance_type = "m5.4xlarge"
  instance_type = "t2.micro"
  #"aws_security_group" "SC4SNMP"
  #associate_public_ip_address = true
  #subnet_id = aws_subnet.Lan.id
  #source_dest_check = false
  availability_zone = data.aws_availability_zones.available.names[0]
  #security_groups = [aws_security_group.SC4SNMP.id]
  key_name = var.AWS_KEY_NAME
   network_interface {
    network_interface_id = aws_network_interface.linux1_private_interface.id
    device_index         = 0
  }
  root_block_device {
    volume_size = "8"
    volume_type = "gp2"
  }
     tags = {  
    Name = "linux1"
    Workspace = terraform.workspace
  }
}




## --------------- Provision Windows instance dual attachement LAN / WAN (for troubleshooting) -------------------##














## --------------- Provision splunk server -------------------##
  
resource "aws_instance" "splunk_server" {
  #ami           = "ami-0a1ee2fb28fe05df3"
  ami           = "ami-08cfb7b19d5cd546d" #paris
  #ami           = "ami-08cfb7b19d5cd546d" # #dublin
 tags = {
   Name="Splunk"
  Workspace = terraform.workspace
 }
  instance_type = "m5.4xlarge"
  key_name = var.AWS_KEY_NAME
   network_interface {
    network_interface_id = aws_network_interface.Splunk_private_interface.id
    device_index         = 0
  }

    root_block_device {
    volume_size = var.Splunk_volume_size_name
    volume_type = "gp3"
  }
  
  #security_groups = "sg-07320658b3c34e3a9"
 

}


resource "null_resource" "scriptexec" {
  provisioner "remote-exec" {
      connection {
    host = aws_eip.WAN_eip.public_ip
    type = "ssh"
    user = var.ec2_ssh_user
    private_key = file(var.paris_private_key_path)
    agent = "false"
  }
  
    inline = [
   ## Create Splunk Ent Vars
      
      "sudo yum update -y",
      "sudo yum upgrade -y",
      "wget https://download.splunk.com/products/splunk/releases/${var.splunk_core_version}/linux/${var.splunk_core_filename}",
      "sudo cp /home/${var.ec2_ssh_user}/${var.splunk_core_filename} /opt",
      "sudo tar xvzf /opt/${var.splunk_core_filename} -C /opt/",

    # create temp licenses folder
     # "sudo rmdir -d -y -f /home/${var.ec2_ssh_user}/licenses/",
      # "sudo mkdir /home/${var.ec2_ssh_user}/licenses/",
       #"sudo chown ec2-user:ec2-user /home/${var.ec2_ssh_user}/licenses",
             ]
  }
  provisioner "local-exec" {
    # copy apps and content pack on the remote srv
      command = "scp  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q -P 22  -i ${var.paris_private_key_path} -r ./binaires/*  ${var.ec2_ssh_user}@${aws_eip.WAN_eip.public_ip}:/home/${var.ec2_ssh_user}"
  }
provisioner "local-exec" {
    # copy license files to the remote srv 
      command = "scp  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q -P 22  -i ${var.paris_private_key_path} -r ./licenses/*  ${var.ec2_ssh_user}@${aws_eip.WAN_eip.public_ip}:/home/${var.ec2_ssh_user}"
   
  }
  provisioner "local-exec" {
    # copy config files to the remote srv 
      command = "scp  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q -P 22  -i ${var.paris_private_key_path} -r ./config_files/*  ${var.ec2_ssh_user}@${aws_eip.WAN_eip.public_ip}:/home/${var.ec2_ssh_user}"
   
  }
 provisioner "remote-exec" {
      connection {
    host = aws_eip.WAN_eip.public_ip
    type = "ssh"
    user = var.ec2_ssh_user
    private_key = file(var.paris_private_key_path)
    agent = "false"
  }
  
    inline = [
  
       #move file from /home/xxuserxx/ to /opt/splunk/etc/apps/ 
      "sudo cp /home/${var.ec2_ssh_user}/*.tgz /opt/splunk/etc/apps/",
      "sudo cp /home/${var.ec2_ssh_user}/* /opt/splunk/etc/apps/",
      
      #"sudo rm -f -y /opt/splunk/etc/apps/*.lic",
      # extract add-on and apps
      "sudo tar -xvzf /opt/splunk/etc/apps/${var.splunk_it_service_intelligence_filename} -C /opt/splunk/etc/apps",
      "sudo tar -xvzf /opt/splunk/etc/apps/${var.splunk_app_for_content_packs_filename} -C /opt/splunk/etc/apps",
      "sudo tar -xvzf /opt/splunk/etc/apps/${var.splunk_synthetic_monitoring_add_on_filename} -C /opt/splunk/etc/apps",
      "sudo tar -xvzf /opt/splunk/etc/apps/${var.splunk_infrastructure_monitoring_add_on_filename} -C /opt/splunk/etc/apps",
      "sudo tar -xvzf /opt/splunk/etc/apps/${var.splunk_config_explorer_filename} -C /opt/splunk/etc/apps",
      "sudo tar -xvzf /opt/splunk/etc/apps/${var.splunk_deep_learning_toolkit_explorer_filename} -C /opt/splunk/etc/apps",
      "sudo tar -xvzf /opt/splunk/etc/apps/${var.splunk_indfrastructure_monitoring_dashboard_filename} -C /opt/splunk/etc/apps",
      "sudo tar -xvzf /opt/splunk/etc/apps/${var.splunk_machine_learning_toolkit_filename} -C /opt/splunk/etc/apps",
      "sudo tar -xvzf /opt/splunk/etc/apps/${var.jdk_file_name} -C /opt",
      "sudo yum -y install /opt/${var.jdk_file_name}",
    # Start Splunk

    "sudo /opt/splunk/bin/splunk start --accept-license --answer-yes --no-prompt --seed-passwd ${var.splunk_password}",
    ### add licenses file 
    "sudo /opt/splunk/bin/splunk add licenses /home/${var.ec2_ssh_user}/${var.splunk_ITSI_license_file_name} -auth admin:${var.splunk_password}",
    "sudo /opt/splunk/bin/splunk add licenses /home/${var.ec2_ssh_user}/${var.splunk_enterprise_license_file_name} -auth admin:${var.splunk_password}",
    ### change license pool to enterprise 
    "sudo /opt/splunk/bin/splunk edit licenser-groups -name \"Enterprise\" -is_active \"1\" -auth admin:${var.splunk_password}",
    
    ### restart splunk
    "sudo /opt/splunk/bin/splunk restart --accept-license",
    # "sudo mkdir /home/${var.ec2_ssh_user}/licenses/",
    # "sudo chown ec2-user:ec2-user  /home/${var.ec2_ssh_user}/licenses",

     ## --------------------create SplunkSC4SNMP APP  and Splunk Indexes ---------------##
    "sudo mkdir /opt/splunk/etc/apps/SC4SNMP",
    "sudo mkdir /opt/splunk/etc/apps/SC4SNMP/default",
    "sudo mkdir /opt/splunk/etc/apps/SC4SNMP/local",
    "sudo bash -c 'echo -e \"[em_metrics]\n    coldPath = $SPLUNK_DB/em_metrics/colddb\n    homePath = $SPLUNK_DB/em_metrics/db\n    thawedPath = $SPLUNK_DB/em_metrics/thaweddb\ndatatype = metric\n\" >> /opt/splunk/etc/apps/SC4SNMP/local/indexes.conf'",
    "sudo bash -c 'echo -e \"[netmetrics]\n    coldPath = $SPLUNK_DB/netmetrics/colddb\n    homePath = $SPLUNK_DB/netmetrics/db\n    thawedPath = $SPLUNK_DB/netmetrics/thaweddb\ndatatype = metric\n\" >> /opt/splunk/etc/apps/SC4SNMP/local/indexes.conf'",
    "sudo bash -c 'echo -e \"[em_logs]\n    coldPath = $SPLUNK_DB/em_logs/colddb\n    homePath = $SPLUNK_DB/em_logs/db\n    thawedPath = $SPLUNK_DB/em_logs/thaweddb\ndatatype = event\n\" >> /opt/splunk/etc/apps/SC4SNMP/local/indexes.conf'",
    "sudo bash -c 'echo -e \"[netops]\n    coldPath = $SPLUNK_DB/netops/colddb\n    homePath = $SPLUNK_DB/netops/db\n    thawedPath = $SPLUNK_DB/netops/thaweddb\ndatatype = event\n\" >> /opt/splunk/etc/apps/SC4SNMP/local/indexes.conf'",
   "sudo /opt/splunk/bin/splunk restart",
## -------------------- Install Micro K8s ---------------##
    ##"sudo yum -y install /home/${var.ec2_ssh_user}/snap-confine-2.36.3-0.amzn2.x86_64.rpm /home/${var.ec2_ssh_user}/snapd-2.36.3-0.amzn2.x86_64.rpm",
    "sudo yum -y install /home/${var.ec2_ssh_user}/snap-confine-2.56.2-1.amzn2.1.x86_64.rpm /home/${var.ec2_ssh_user}/snapd-2.56.2-1.amzn2.1.x86_64.rpm",
    "sudo systemctl enable --now snapd.socket",
    "sudo systemctl restart snapd.socket ",
    "sudo yum install -y iscsi-initiator-utils",
   "sudo snap wait system seed.loaded",
    "sudo snap install microk8s --classic --channel=1.24/stable",
"sudo usermod -a -G microk8s $USER",
"sudo chown -f -R $USER ~/.kube",
"sudo systemctl enable iscsid",
            ]
 
  }
  


##--- need to reload ssh session for user context ---##
provisioner "remote-exec" {
      connection {
    host = aws_eip.WAN_eip.public_ip
    type = "ssh"
    user = var.ec2_ssh_user
    private_key = file(var.paris_private_key_path)
    agent = "false"
  }
  
    inline = [
"microk8s status --wait-ready",
"microk8s enable rbac" , 
"microk8s status --wait-ready",
"microk8s enable storage",
"microk8s status --wait-ready",
"microk8s enable dns:192.168.100.10,8.8.8.8",
"microk8s status --wait-ready",
"microk8s enable metallb:192.168.100.20-192.168.100.20",
"microk8s status --wait-ready",
"microk8s enable helm3",
"microk8s status --wait-ready",
"microk8s enable metrics-server",
"microk8s status --wait-ready",
"microk8s enable community",
"microk8s status --wait-ready",
"microk8s enable openebs",
"microk8s status --wait-ready",
"microk8s helm3 repo add splunk-otel-collector-chart https://signalfx.github.io/splunk-otel-collector-chart",
"microk8s helm3 upgrade --install sck \\",
 " --set=\"clusterName=SC4SNMP_Cluster\" \\",
 " --set=\"splunkPlatform.endpoint=https://192.168.100.20/services/collector\" \\",
 " --set=\"splunkPlatform.insecureSkipVerify=true\" \\",
 " --set=\"splunkPlatform.token=4d22911c-18d9-4706-ae7b-dd1b976ca6f7\" \\",
 " --set=\"splunkPlatform.metricsEnabled=true\" \\",
 " --set=\"splunkPlatform.metricsIndex=em_metrics\" \\",
 " --set=\"splunkPlatform.index=em_logs\" \\",
 "splunk-otel-collector-chart/splunk-otel-collector",
"microk8s helm3 repo add splunk-connect-for-snmp https://splunk.github.io/splunk-connect-for-snmp",
"microk8s helm3 repo update",
"microk8s helm3 search repo snmp",
"microk8s helm3 install snmp -f values.yaml splunk-connect-for-snmp/splunk-connect-for-snmp --namespace=sc4snmp --create-namespace",

"microk8s helm3 upgrade --install snmp -f values.yaml splunk-connect-for-snmp/splunk-connect-for-snmp --namespace=sc4snmp --create-namespace",

##----- create symbolic link to values.yaml
"sudo mkdir /opt/splunk/SC4SNMP",
"sudo ln -s /home/${var.ec2_ssh_user}/values.yaml /opt/splunk/SC4SNMP/values.yaml",

            ]
}
}

resource "aws_instance" "windows1" {
  #ami = "ami-0a82c0ac10187c355"
  #ami = #cami-0c0986e56543271b2" #paris
  ami = "ami-02b9b5dd18ee7d162"  #parisV2
  
  #ami = "ami-0a4722105d5286695" #dublin
   instance_type = "m5.large"
 
  user_data = "${file("/scripts/userdata.txt")}"
 
    get_password_data = true   
  availability_zone = data.aws_availability_zones.available.names[0]
  key_name = var.AWS_KEY_NAME
     network_interface {
    network_interface_id = aws_network_interface.windows1_private_interface.id
    device_index         = 0
  }
  root_block_device {
    volume_size = "50"
    volume_type = "gp2"
  }
     tags = {  
       Workspace = terraform.workspace
    Name = "windows1"
  }
}

resource "aws_instance" "windows2" {
  #ami = "ami-0a82c0ac10187c355"
  #ami = "ami-0c0986e56543271b2" #paris
  ami = "ami-02b9b5dd18ee7d162"  #parisV2
  #ami = "ami-0a4722105d5286695" #dublin
   instance_type = "m5.large"
 
  user_data = "${file("/scripts/userdata.txt")}"
 
    get_password_data = true   
  availability_zone = data.aws_availability_zones.available.names[0]
  key_name = var.AWS_KEY_NAME
     network_interface {
    network_interface_id = aws_network_interface.windows2_private_interface.id
    device_index         = 0
  }
  root_block_device {
    volume_size = "50"
    volume_type = "gp2"
  }
     tags = {  
       Workspace = terraform.workspace
    Name = "windows2"
  }
}

## ---------------Output provisioning data  -------------------##



output "server-ip" {
  value = "${aws_eip.WAN_eip.public_ip}" # output  
}
output "password_decrypted" {
  value=rsadecrypt(aws_instance.windows1.password_data, file("/certificat/GLY_AWS_Paris.pem") ) 
}
output "password_decrypted_reminder" {
  value=rsadecrypt(aws_instance.windows1.password_data, file("/certificat/GLY_AWS_Paris.pem") ) 
}
output "password_decrypted_windows2" {
  value=rsadecrypt(aws_instance.windows2.password_data, file("/certificat/GLY_AWS_Paris.pem") ) 
}
