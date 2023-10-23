#----------------------------------------
# control resources creation
#----------------------------------------
#create_spotfire_db   = true
#create_appgw         = true
#create_sfs_public_ip = false
#create_bastion       = false

#----------------------------------------
# instances number
#----------------------------------------
# Jumphost instances number
jumphost_instances = 1

# Spotfire Server instances number
sfs_instances = 3

# Spotfire Web Player instances number
sfwp_instances = 3

#----------------------------------------
# instances size
#----------------------------------------
# Spotfire Server VM size
sfs_size = "XS"

# Spotfire Web Player VM size
sfwp_size = "XS"
