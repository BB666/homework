homework
========

Project to deploy virtual machines with Vagrant and customize them with SaltStack.
Deploy RabbitMQ and monitor hosts and RabbitMQ queue with Zabbix.

 - Vagrantfile with one CENTRAL box and up to 150 WORKERS
 - RabbitMQ AMQP broker installation on CENTRAL box

#### Source: 
https://github.com/bb666/homework

#### Requirements:
 - Vagrant 1.8.5
 - VirtualBox 5.1.6
 - ssh, rsync

#### Installation:
1. Install VirtualBox
2. Install Vagrant
3. Install Vagrant plugins for VirtualBox:
    vagrant plugin install virtualbox
    vagrant plugin install vagrant-vbguest
4. Extract archive and setup configuration (see below)
5. Start deployment with `vagrant up`

#### Configuration:
Edit `Vagrantfile` and set desired number of WORKERS.
The default values are as follows:
    WORKERS_COUNT = 1

You can change default Zabbix values in `/salt/minion` file:
    zabbix.user: Admin
    zabbix.password: zabbix
    zabbix.server: 192.168.56.100
    zabbix.url: http://192.168.56.100/zabbix/api_jsonrpc.php
    zabbix.db_password: password 

You may optionally change a provided `/etc/zabix/rabbitmq/sctipts/.rab.auth` with your values:
    USERNAME=guest
    PASSWORD=guest
    CONF=/etc/zabbix/zabbix_agent.conf

#### Notes:
* RabbitMQ Web Management console available at http://192.168.56.100:15672 with login/password: `guest/guest`

* Zabbix Web Management available at http://192.168.56.100/zabbix with login/password: `Admin/zabbix`

* Known bug with authentication failure for Vagrant 1.8.5 (incorrect permissions for authorized_keys file), more info: https://github.com/mitchellh/vagrant/issues/7610
  Apply following quick fix before issuing "vagrant up" command:
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

