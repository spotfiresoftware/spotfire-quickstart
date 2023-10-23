#----------------------------------------
# VM instance types
#----------------------------------------

# https://aws.amazon.com/ec2/instance-types/
#
# Instance	  vCPU*	Mem Storage	    Mbps	Network Performance
# -----------------------------------------------------------------------------------------
# General Purpose:
# m3.large    2     7.5       -                                     0.133
# ...
# m4.large	    2	8	EBS-only	450	    Moderate
# m4.xlarge	    4	16	EBS-only	750	    High
# m4.2xlarge	8	32	EBS-only	1,000	High
# m4.4xlarge	16	64	EBS-only	2,000	High
# m4.10xlarge	40	160	EBS-only	4,000	10 Gigabit
# m4.16xlarge	64	256	EBS-only	10,000	25 Gigabit
# ...
# m5.xlarge	4	16	EBS-Only	Up to 10	Up to 4,750
# m5.2xlarge	8	32	EBS-Only	Up to 10	Up to 4,750
# m5.4xlarge	16	64	EBS-Only	Up to 10	4,750
# ...
# Compute Optimized:
# c4.large	  2	    3.75      EBS-Only	  500	        Moderate    0.1
# c4.xlarge	  4	    7.5	      EBS-Only	  750	        High
# c4.2xlarge  8	    15	      EBS-Only	  1,000	        High
# c4.4xlarge  16	30	      EBS-Only	  2,000	        High
# c4.8xlarge  36	60	      EBS-Only	  4,000	        10 Gigabit

variable "jumphost_instance_type" {
  description = "Number of jumphost instances"
  default     = "t3.large"
}

#----------------------------------------
# SFS sizing    S   M   L   XL
# ------------- --- --- --- ---
# CPU (# cores) 2   4   8   16
# Memory (GB)   16  32  64  128
#----------------------------------------
variable "sfs_instance_types" {
  type        = map(string)
  description = "Spotfire Server VM predefined sizes"
  default = {
    "XS" = "t3.large"
    "S"  = "m4.xlarge"
    "M"  = "c4.2xlarge"
    "L"  = "c4.4xlarge"
    "XL" = "c4.8xlarge"
  }
}
variable "sfs_size" {
  description = "Spotfire Server VM size"
  default     = "XS"
}

#----------------------------------------
# SFWP sizing   S   M   L   XL
# ------------- --- --- --- ---
# CPU (# cores) 4   8   16  32
# Memory (GB)   32  64  128 256
#----------------------------------------
variable "sfwp_instance_types" {
  type        = map(string)
  description = "Spotfire Web Player VM predefined sizes"
  default = {
    "XS" = "t3.large"
    "S"  = "m5.2xlarge"
    "M"  = "m4.4xlarge"
    "L"  = "m4.10xlarge"
    "XL" = "m4.16xlarge"
  }
}
variable "sfwp_size" {
  description = "Spotfire Web Player VM size"
  default     = "XS"
}
