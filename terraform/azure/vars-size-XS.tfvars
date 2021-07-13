#----------------------------------------
# control resources creation
#----------------------------------------
create_spotfire_db   = true
create_appgw         = false
tss_create_public_ip = true
create_bastion       = false

#----------------------------------------
# instances number
#----------------------------------------
# VM instances number
jumphost_instances = 1

# VM instances number
tss_instances = 1

# VM instances number
wp_instances = 1

#----------------------------------------
# instances size
#----------------------------------------
# VM size
# https://docs.microsoft.com/en-us/azure/virtual-machines/sizes
#    Size	vCore	Memory: GiB	Temp storage (SSD) GiB	Max temp storage throughput: IOPS/Read MBps/Write MBps	Max data disks/throughput: IOPS	Max NICs	Expected network bandwidth (Mbps)
#    Standard_A1_v2	1	2	10	1000/20/10	2/2x500	2	250
#    Standard_A2_v2	2	4	20	2000/40/20	4/4x500	2	500
#    Standard_A4_v2	4	8	40	4000/80/40	8/8x500	4	1000
#    Standard_A8_v2	8	16	80	8000/160/80	16/16x500	8	2000
#    ...
#    Standard_D2_v4	2	8	Remote Storage Only	4	2	1000
#    Standard_D4_v4	4	16	Remote Storage Only	8	2	2000
#    Standard_D8_v4	8	32	Remote Storage Only	16	4	4000
#    Standard_D16_v4	16	64	Remote Storage Only	32	8	8000
#    Standard_D32_v4	32	128	Remote Storage Only	32	8	16000
#    ...
jumphost_vm_size = "Standard_A1_v2" // 1cores, 2GiB, 10 GB SSD, 250Mbps

# VM size
tss_vm_size = "Standard_A2_v2" // 2cores, 4GiB, 20 GB SSD, 500Mbps
//tss_vm_size = "Standard_A4_v2" // 4cores, 8GiB, 40 GB SSD, 4000/80/40, 8/8x500	4	1000
//tss_vm_size = "Standard_D2_v4" // 2	8	Remote Storage Only	4	2	1000

# VM size
wp_vm_size = "Standard_A2_v2" // 2cores, 4GiB, 20 GB SSD, 500Mbps
//wp_vm_size = "Standard_A4_v2" // 4cores, 8GiB, 40 GB SSD, 4000/80/40, 8/8x500	4	1000
//wp_vm_size = "Standard_D2_v4" // 2	8	Remote Storage Only	4	2	1000

# VM Operating System
//# CentOS 8.2
//wp_os_publisher = "OpenLogic"
//wp_os_offer = "Centos"
//wp_os_sku = "8_2"
//wp_os_version = "8.2.2020111800"

//# SUSE
//wp_os_publisher = "SUSE"
//wp_os_offer = "SLES"
//wp_os_sku = "12-sp4-gen2"
//wp_os_version = "latest"

//# OpenSUSE
//wp_os_publisher = "SUSE"
//wp_os_offer = "openSUSE-Leap"
//wp_os_sku = "15-2"
//wp_os_version = "latest"
