# -*- mode: ruby -*-
# vi: set ft=ruby :

### Number of WORKER boxes to deploy, from 0 up to 150
WORKERS_COUNT = 1

### Check for required plugins
required_plugins = %w( virtualbox vagrant-vbguest )
logger = Vagrant::UI::Colored.new
result = false
required_plugins.each do |plugin|
    unless Vagrant.has_plugin? plugin
        system "vagrant plugin install #{plugin}"
        result = true
    end
end
if result
    logger.warn("Re-run 'vagrant up' now that required plugins are installed")
    exit
end

Vagrant.configure(2) do |config|

### Install and configure CENTRAL

    config.vm.define "central" do |main|
        main.vm.box = "centos/7"
        main.vm.hostname = "central"
        # main.vm.network "forwarded_port", guest: 80, host: 8000
        # main.vm.network "public_network"
        main.vm.network "private_network", ip: "192.168.56.100"
        main.vm.provider "virtualbox" do |v|
            v.name = "central"
            v.memory = 1024
            v.cpus = 2
            v.linked_clone = true
        end

        # RabbitMQ server configuration file
        main.vm.provision :file, source: "etc/rabbitmq/rabbitmq.config", destination: "/tmp/rabbitmq.config"

        # Java application wrapper
        main.vm.provision :file, source: "usr/local/bin/app-server", destination: "/tmp/app-server"

        # Java application to deploy on CENTRAL box
        main.vm.provision :file, source: "usr/src/Send.java", destination: "/tmp/Send.java"

        # Zabbix configuration files
        main.vm.provision :file, source: "etc/zabbix/", destination: "/tmp/zabbix/"
        main.vm.provision :file, source: "etc/sudoers.d/zabbix", destination: "/tmp/zabbix_sudoers"

        # Additional tools for Zabbix and to clog RabbitMQ queue
        main.vm.provision :file, source: "usr/local/bin/", destination: "/tmp/apps/"

        main.vm.provision "shell", inline: <<-SHELL
            setenforce 0
            if [ ! -d /etc/rabbitmq ]; then mkdir /etc/rabbitmq; fi; mv -f /tmp/rabbitmq.config /etc/rabbitmq/rabbitmq.config
            mv -f /tmp/apps/* /usr/local/bin/; chmod 755 /usr/local/bin/*
            if [ ! -d /etc/zabbix/zabbix_agentd.d ]; then mkdir -p /etc/zabbix/zabbix_agentd.d; fi; mv -f /tmp/zabbix/zabbix_agentd.d/* /etc/zabbix/zabbix_agentd.d/
            mv -f /tmp/zabbix/*.template.* /etc/zabbix/
            mv -f /tmp/Send.java /usr/src/Send.java
            mv -f /tmp/zabbix_sudoers /etc/sudoers.d/zabbix; chown root:root /etc/sudoers.d/zabbix; chmod 440 /etc/sudoers.d/zabbix
        SHELL

        main.vm.synced_folder "salt/roots/salt", "/srv/salt/"
        main.vm.provision :salt do |salt|
            salt.masterless = true
            salt.minion_config = "salt/minion"
            salt.run_highstate = true
            # for verbose Salt output uncomment 2 lines below
            # salt.verbose = true
            # salt.log_level = "info"
        end
    end

### Install and configure WORKERS

    if(WORKERS_COUNT > 150)
        puts "Number of workers should be within 0..150"
        exit
    end
    
    WORKERS_COUNT.times do |i|
        i = i + 1
        worker_name = "worker#{i}"
        worker_port = 8000 + i
        worker_ip = 100 + i

        config.vm.define "#{worker_name}" do |main|
            main.vm.box = "centos/7"
            main.vm.hostname = "#{worker_name}"
            # main.vm.network "forwarded_port", guest: 80, host: #{worker_port}
            # main.vm.network "public_network"
            main.vm.network "private_network", ip: "192.168.56.#{worker_ip}"

            main.vm.provider "virtualbox" do |v|
                v.name = "#{worker_name}"
                v.memory = 512
                v.cpus = 2
                v.linked_clone = true
            end

            # Application to deploy on WORKERS
            main.vm.provision :file, source: "usr/local/bin/app-client", destination: "/tmp/app-client"

            # Script for host autoregistration with Zabbix server
            main.vm.provision :file, source: "usr/local/bin/zabbix-create-host", destination: "/tmp/zabbix-create-host"

            main.vm.provision "shell", inline: <<-SHELL
                setenforce 0
                mv -f /tmp/app-client /usr/local/bin/app-client; chmod 755 /usr/local/bin/app-client
                mv -f /tmp/zabbix-create-host /usr/local/bin/zabbix-create-host; chmod 755 /usr/local/bin/zabbix-create-host
            SHELL

            main.vm.synced_folder "salt/roots/salt", "/srv/salt/"
            main.vm.provision :salt do |salt|
                salt.masterless = true
                salt.minion_config = "salt/minion"
                salt.run_highstate = true
                # for verbose Salt output uncomment 2 lines below
                # salt.verbose = true
                # salt.log_level = "info"
            end
		end
    end
end
