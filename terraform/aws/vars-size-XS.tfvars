#----------------------------------------
# control resources creation
#----------------------------------------
#create_spotfire_db   = true
#create_alb           = true  # WARN: not supported to disable
#create_sfs_public_ip = false # WARN: not supported to disable
#create_sfwp_linux      = true

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
