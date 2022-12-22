#----------------------------------------
# control resources creation
#----------------------------------------
#create_spotfire_db   = true
#create_alb           = true  # WARN: not supported to disable
#create_tss_public_ip = false # WARN: not supported to disable
#create_wp_linux      = true

#----------------------------------------
# instances number
#----------------------------------------
# Jumphost instances number
jumphost_instances = 1

# TIBCO Spotfire Server instances number
tss_instances = 3

# TIBCO Spotfire Web Player instances number
wp_instances = 3

#----------------------------------------
# instances size
#----------------------------------------
# TIBCO Spotfire Server VM size
tss_size = "XS"

# TIBCO Spotfire Web Player VM size
wp_size = "XS"
