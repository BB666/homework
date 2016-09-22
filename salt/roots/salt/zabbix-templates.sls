pika:
    cmd.run:
        - name: pip install pyzabbix
        - require:
            - pkg: python-pip

import-templates:
    cmd.run:
        - name: /usr/local/bin/zabbix-import-templates
        - require:
            - cmd: pika

