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

{# additional kwargs not passing to module, using temporary shell script /usr/local/bin/zabbix-create-host #}
{#
zabbix-register-host:
    module.run:
        - require:
            - cmd: zabbix-agent
            - cmd: zabbix-server-fake
        - name: zabbix.host_create
        - host: {{ hostname }}
        - groups: 2
        - interfaces: { type: 1, main: 1, useip: 1, ip: "{{ ip4 }}", dns: "", port: 10050 }
        - kwargs: { 
            - templates: { templateid: 10001 }
        }
#}
{# module zabbix requires zabbix_server, creating empty file /usr/sbin/zabbix_server #}
{#
zabbix-server-fake:
    cmd.run:
        - name: if [ ! -a /usr/sbin/zabbix_server ]; then touch /usr/sbin/zabbix_server; chmod 755 /usr/sbin/zabbix_server; fi
        - require:
            - cmd: zabbix-agent
#}

zabbix-register-host:
    cmd.run:
        - name: /usr/local/bin/zabbix-create-host
{#      - unless: salt-call zabbix.host_exists host='{{ hostname }}' #}
        - require:
            - cmd: zabbix-agent
