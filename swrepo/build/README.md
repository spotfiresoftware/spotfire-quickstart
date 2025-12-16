# Spotfire local software repository

By default, the provided `Makefile`, templates and configuration variables within the Ansible playbook and the Spotfire CDK quickstart, 
expect your Spotfire software components in this location: `<this_repo_root>/swrepo/build/<spotfire_version>` 

This is an example of the Spotfire software components for Spotfire version 14.6.0:

```
swrepo/build $ ls -1 14.6.0/
Spotfire.Dxp.netcore-linux.sdn
Spotfire.Dxp.PythonServiceLinux.sdn
Spotfire.Dxp.RServiceLinux.sdn
Spotfire.Dxp.sdn
Spotfire.Dxp.TerrServiceLinux.sdn
spotfirenodemanager-14.6.0.x86_64.tar.gz
spotfireserver-14.6.0.x86_64.tar.gz
SPOT_sfire_server_14.6.0_languagepack-multi.zip
```
