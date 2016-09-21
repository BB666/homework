zabbix-server:
    pkg.installed:
        - require:
            - cmd: zabbix-repo
            - service: mariadb
            - service: httpd
        - pkgs:
            - zabbix-server-mysql
            - zabbix-web-mysql
    service.running:
        - name: zabbix-server
        - enable: True
        - require:
            - pkg: zabbix-server
            - cmd: zabbix-server
            - file: /etc/zabbix/web/zabbix.conf.php
    cmd.run:
        - names:
            - sed -i '/# DBPassword=/a DBPassword={{ opts['zabbix.db_password'] }}' /etc/zabbix/zabbix_server.conf
            - sed -i '/# php_value date.timezone /s/# //' /etc/httpd/conf.d/zabbix.conf; systemctl restart httpd
            - gzip -d /usr/share/doc/zabbix-server-mysql-*/create.sql.gz; mysql -u root zabbix < /usr/share/doc/zabbix-server-mysql-*/create.sql
            - mysql -u root -e "create database zabbix character set utf8 collate utf8_bin; grant all privileges on zabbix.* to {{ opts['zabbix.db_user'] }}@localhost identified by '{{ opts['zabbix.db_password'] }}'"
        - unless:
            - test -f /usr/share/doc/zabbix-server-mysql-*/create.sql
        - require:
            - pkg: zabbix-server

httpd:
    pkg.installed:
        - pkgs:
            - httpd
            - php
            - php-common
            - php-mysql
    service.running:
        - name: httpd
        - enable: True
        - require:
            - pkg: httpd

mariadb:
    pkg.installed:
        - pkgs:
            - mariadb
            - mariadb-server
    service.running:
        - name: mariadb
        - enable: True
        - require:
            - pkg: mariadb

zabbix-repo:
    cmd.run:
        - name: rpm -U --force http://repo.zabbix.com/zabbix/3.2/rhel/7/x86_64/zabbix-release-3.2-1.el7.noarch.rpm

/etc/zabbix/web/zabbix.conf.php: 
    file.managed:
        - user: zabbix
        - group: zabbix
        - mode: 0644
        - source: salt://zabbix.conf.php.template
        - template: jinja
        - require:
            - pkg: zabbix-server

{# delete default 'Zabbix server' will add it later with Zabbix agent installation #}
zabbix-delete-host:
    cmd.run:
        - name: salt-call zabbix.host_delete 10084 
{#      - onlyif: salt-call zabbix.host_exists host='Zabbix server' #}
        - require:
            - service: zabbix-server
