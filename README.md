homework
========
Project to deploy virtual machines with Vagrant and customize them with SaltStack.

### Source: 
https://github.com/bb666/homework

### What is inside?
 - Vagrantfile, which deploys one CENTRAL box and up to 150 WORKERS
 - Salt masterless minion configuration files
 - Applications and scripts to import Zabbix templates, autoregister Zabbix agents and to clog RabbitMQ queue to trigger Zabbix alarm

### Requirements:
Internet connection and following software are required:
 - Vagrant (tested with 1.8.5)
 - VirtualBox (tested with 5.1.6)
 - ssh, rsync (tested from CygWin 2.876)

### Installation:
1. Download and install Oracle VirtualBox for your operating system. Package can be obtained from official download page https://www.virtualbox.org/wiki/Downloads
2. Download and install Vagrant https://www.vagrantup.com/downloads.html (see notes below)
3. Download project archive from GitHub https://github.com/BB666/homework/archive/master.zip or clone it with git: `git clone https://github.com/BB666/homework.git`
4. You may optionally change default configuration with your values and credentials (see below)

### Configuration:
Start VirtualBox and configure two network adapters _NAT_ and _Host only_. _Host only_ adapter should be able to provide DHCP addresses for guests with IP range 192.168.56.101 to 192.168.56.250.

Number of initially deployed workers defined in `Vagrantfile` in variable WORKERS_COUNT. It can be from 0 and up to 150, depends on your host resources. The default value is 1:
```
    WORKERS_COUNT = 1
```
Alternatively you can start with default value and adjust number of WORKERS later, followed by `vagrant up` command to start extra worker machine.

Zabbix credentials and database password stored in `/salt/minion` file. The default values are as follows:
```
    zabbix.user: Admin
    zabbix.password: zabbix
    zabbix.server: 192.168.56.101
    zabbix.url: http://192.168.56.101/zabbix/api_jsonrpc.php
    zabbix.db_user: zabbix
    zabbix.db_password: password
```
### Usage:
Enter project directory and run `vagrant up` command. If you start it for the first time Vagrant will download and install additional plugins automatically:
```
homework> vagrant up
Installing the 'virtualbox' plugin. This can take a few minutes...
Installed the plugin 'virtualbox (0.8.6)'!
Installing the 'vagrant-vbguest' plugin. This can take a few minutes...
Installed the plugin 'vagrant-vbguest (0.13.0)'!
Re-run 'vagrant up' now that required plugins are installed
```
All required packages and plugins will be downloaded and installed automatically.
When deployment finished you can login to deployed guests with `vagrant ssh <machine_name>` command. Deployed machines named as follows:
```
central
worker1
worker2
...
worker150
```
There are number of scripts deployed to `/usr/local/bin`. One Java application gets compiled during deployment from `/usr/src/Send.java` to `/usr/src/Send.class`

To send message to RabbitMQ queue use `/usr/local/bin/app-server <message>` where <message> is a number:
```
[vagrant@central ~]$ app-server 1
 [x] Sent '1' to queue
[vagrant@central ~]$
```
To clog RabbitMQ queue and trigger alarm on Zabbix server run `/usr/local/bin/clog`. It will clog the queue and remain queue filled within one minute to trigger alarm on Zabbix server:
```
[vagrant@central ~]$ clog
Trying to clog the queue for 60 seconds - 5%
```
You can check status and clear queue `central` with RabbitMQ web interface http://192.168.56.101:15672/#/queues
Login and password for RabbitMQ console: guest/guest

Deployed machines automatically registers with Zabbix server and can be monitored with Zabbix web console. Also you can check RabbitMQ queue depth and alarm status at Zabbix dashboard http://192.168.56.101/zabbix/zabbix.php?action=dashboard.view
Login and password for Zabbix: Admin/zabbix

On each worker available Python script `/usr/local/bin/app-client`, which can be started to constantly consume messages from RabbitMQ server queue.
```
[vagrant@worker1 ~]$ app-client
 [*] Waiting for messages. To exit press CTRL+C
 [x] Payload received, sleeping for '5'
```

For stress test you can deploy abnormally high number of workers and start `/usr/local/bin/app-client` on each of them to consume messages. Then run `/usr/local/bin/clog` on central and check queue depth, queue alarm and health status of each machine with Zabbix dashboard. Number of workers can be adjusted according to your host CPU and memory resources. 

### Notes:
* RabbitMQ Web Management console available at http://192.168.56.101:15672 with login/password: `guest/guest`
* Zabbix Web Management available at http://192.168.56.101/zabbix with login/password: `Admin/zabbix`
* Known bug with authentication failure for Vagrant 1.8.5 (incorrect permissions for guest authorized_keys file), more info https://github.com/mitchellh/vagrant/issues/7610
  Following quick fix :
``` diff
diff -uNr vagrant-original/plugins/guests/linux/cap/public_key.rb vagrant/plugins/guests/linux/cap/public_key.rb
--- vagrant-original/plugins/guests/linux/cap/public_key.rb     2016-07-19 12:06:56.575045974 -0500
+++ vagrant/plugins/guests/linux/cap/public_key.rb      2016-07-19 12:07:34.303376009 -0500
@@ -54,6 +54,7 @@
        if test -f ~/.ssh/authorized_keys; then
            grep -v -x -f '#{remote_path}' ~/.ssh/authorized_keys > ~/.ssh/authorized_keys.tmp
            mv ~/.ssh/authorized_keys.tmp ~/.ssh/authorized_keys
+           chmod 0600 ~/.ssh/authorized_keys
        fi

        rm -f '#{remote_path}'
```
