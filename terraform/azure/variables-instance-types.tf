#----------------------------------------
# VM instance types
#----------------------------------------

# https://docs.microsoft.com/en-us/azure/virtual-machines/sizes
# Size	            CPU Mem	SSD disks disks thr/put NICs MBps
# -----------------------------------------------------------
# Standard_A1_v2	1	2	10	1000/20/10	2/2x500	2	250
# Standard_A2_v2	2	4	20	2000/40/20	4/4x500	2	500
# Standard_A4_v2	4	8	40	4000/80/40	8/8x500	4	1000
# Standard_A8_v2	8	16	80	8000/160/80	16/16x500	8	2000
# ...
# Standard_A2m_v2	2	16	20	2000/40/20	4/4x500	2	500
# Standard_A4m_v2	4	32	40	4000/80/40	8/8x500	4	1000
# Standard_A8m_v2	8	64	80	8000/160/80	16/16x500	8	2000
#  ...
# Standard_D2_v4	2	8	Remote Storage Only	4	2	1000
# Standard_D4_v4	4	16	Remote Storage Only	8	2	2000
# Standard_D8_v4	8	32	Remote Storage Only	16	4	4000
# Standard_D16_v4	16	64	Remote Storage Only	32	8	8000
# Standard_D32_v4	32	128	Remote Storage Only	32	8	16000
# ...
# (*) Max temp storage throughput: IOPS/Read MBps/Write MBps
# (**) Max NICs / Network bandwidth
variable "jumphost_size" {
  description = "Number of jumphost instances"
  default     = "Standard_A1_v2"
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
    "XS" = "Standard_A2_v2"
    "S"  = "Standard_A2m_v2"
    "M"  = "Standard_A4m_v2"
    "L"  = "Standard_D16_v4"
    "XL" = "Standard_D32_v4"
  }
}
variable "sfs_size" {
  description = "Spotfire Server VM size"
  default     = "XS"
}

# https://docs.microsoft.com/en-us/azure/virtual-machines/sizes
# Ev3-series
# Size	            CPU Mem	SSD disks disks thr/put NICs MBps
# -----------------------------------------------------------
# Standard_E2_v31	2	16	50	4	3000/46/23	    2/1000
# Standard_E4_v3	4	32	100	8	6000/93/46	    2/2000
# Standard_E8_v3	8	64	200	16	12000/187/93	4/4000
# Standard_E16_v3	16	128	400	32	24000/375/187	8/8000
# Standard_E20_v3	20	160	500	32	30000/469/234	8/10000
# Standard_E32_v3	32	256	800	32	48000/750/375	8/16000
# ...
# (*) Max temp storage throughput: IOPS/Read MBps/Write MBps
# (**) Max NICs / Network bandwidth

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
    "XS" = "Standard_A2_v2"
    "S"  = "Standard_A4m_v2"
    "M"  = "Standard_A8m_v2"
    "L"  = "Standard_E16_v3"
    "XL" = "Standard_E32_v3"
  }
}
variable "sfwp_size" {
  description = "Spotfire Web Player VM size"
  default     = "XS"
}
