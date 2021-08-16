# How to connect with RDP using a jumphost

It is possible to connect to your remote MS Windows server via RDP using a jumphost.

In your localhost, you can execute:

     ssh -L 13389:<windows-server-ip-address>:3389 <jumphost-ip-address> -l <jumphost-ssh-user> -N

After that, you can open MS Remote Desktop Manager in Windows or alternative in Linux (e.g. [Remmina](https://remmina.org/))
as usual and connect to 127.0.0.1:13389, and it will be tunneled to the remote server.
