#----------------------------------------
# control resources creation
#----------------------------------------
create_spotfire_db   = true
create_appgw         = true
//create_tss_public_ip = false // only for troubleshooting
//create_bastion       = false // only for troubleshooting

#----------------------------------------
# instances number
#----------------------------------------
# Jumphost instances number
jumphost_instances = 1

# TIBCO Spotfire Server instances number
tss_instances = 2

# TIBCO Spotfire Web Player instances number
wp_instances = 2

#----------------------------------------
# instances size
#----------------------------------------
# TIBCO Spotfire Server VM size
tss_size = "XS"

# TIBCO Spotfire Web Player VM size
wp_size = "XS"
