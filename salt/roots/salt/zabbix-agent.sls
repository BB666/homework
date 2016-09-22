{%- set hostname = grains['id'] %}
{%- set ip4 = grains['ipv4'].2 %}

zabbix-agent:
    pkg.installed:
        - require:
            - cmd: zabbix-agent-repo
        - pkgs:
            - zabbix-agent
    service.running:
        - name: zabbix-agent
        - enable: True
        - require:
            - pkg: zabbix-agent
            - cmd: zabbix-agent
            - cmd: zabbix-register-host
    cmd.run:
        - names:
            - sed -i 's/Hostname=Zabbix server/Hostname={{ hostname }}/' /etc/zabbix/zabbix_agentd.conf
            - sed -i 's/Server=127.0.0.1/Server={{ opts['zabbix.server'] }}/' /etc/zabbix/zabbix_agentd.conf
            - sed -i 's/ServerActive=127.0.0.1/ServerActive={{ opts['zabbix.server'] }}/' /etc/zabbix/zabbix_agentd.conf
        - require:
            - pkg: zabbix-agent

zabbix-agent-repo:
    cmd.run:
        - name: rpm -U --force http://repo.zabbix.com/zabbix/3.2/rhel/7/x86_64/zabbix-release-3.2-1.el7.noarch.rpm

zabbix-register-host:
    cmd.run:
        - name: /usr/local/bin/zabbix-create-host
{#      - unless: salt-call zabbix.host_exists host='{{ hostname }}' #}
        - require:
            - cmd: zabbix-agent
