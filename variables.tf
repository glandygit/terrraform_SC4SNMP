variable "Splunk_instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "Splunk"
}
variable "Openwrt_instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "SC4SNMP_OpenWRT"
}

variable "Openwrt_volume_size" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "1"
}
variable "Splunk_volume_size_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "100"
}

### AWS certificat Location ### 
variable "paris_private_key_path"{
  type        = string
  #default = "./certificat/GLY_AWS_Paris.pem"
  default = "./certificat/GLY_AWS_Paris.pem"
}

variable "franckfurt_private_key_path"{
  type        = string
  default = "./certificat/gly_AWS.pem"
}
### AWS Keyname ### 
variable "AWS_KEY_NAME"{
  type        = string
  default = "GLY_AWS_Paris"
  #default = "GLY_AWS"
}



### user variables ###
variable "ec2_ssh_user" {
  default = "ec2-user"
}
### user variables ###
variable "Openwrt_ssh_user" {
  default = "root"
}








### Splunk license file variables ###
variable "splunk_enterprise_license_file_name" {
  default = "core.lic"
}
variable "splunk_ITSI_license_file_name" {
  default = "itsi.lic"
}
### Splunk ITSI Variables ###



variable "splunk_app_for_content_packs_filename" {
  ## default = "splunk-app-for-content-packs_170.spl"
  default = "splunk-app-for-content-packs_180.spl"
}
variable "splunk_it_service_intelligence_filename" {
  ## default = "splunk-it-service-intelligence_4131.spl"
  default = "splunk-it-service-intelligence_4150.spl"
}
variable "splunk_itsi_version" {
  default = "4.15"
}
variable "splunk_synthetic_monitoring_add_on_filename" {
  default = "splunk-synthetic-monitoring-add-on_110.tgz"
}
variable "splunk_infrastructure_monitoring_add_on_filename" {
  default = "splunk-infrastructure-monitoring-add-on_121.tgz"
}
variable "splunk_config_explorer_filename" {
  default = "config-explorer_149.tgz"
}
variable "splunk_deep_learning_toolkit_explorer_filename" {
  default = "deep-learning-toolkit-for-splunk_370.tgz"
}
variable "jdk_file_name" {
  default = "jdk-17_linux-x64_bin.rpm"
}
variable "splunk_indfrastructure_monitoring_dashboard_filename" {
  default = "splunk-infrastructure-monitoring-dashboards-app_100.tgz"
}
variable "splunk_machine_learning_toolkit_filename" {
  default = "splunk-machine-learning-toolkit_531.tgz"
}
variable "splunk_core_filename" {
  # default = "splunk-8.2.4-87e2dda940d1-Linux-x86_64.tgz"
  # default = "splunk-8.2.7.1-c2b65bc24aea-Linux-x86_64.tgz"
  default = "splunk-9.0.2-17e00c557dc1-Linux-x86_64.tgz"
}
variable "splunk_core_version" {
  # default = "8.2.4"
  # default = "8.2.7.1"
  default = "9.0.2"
}

