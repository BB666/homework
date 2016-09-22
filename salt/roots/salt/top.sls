base:
  'central':
    - rabbit-server
    - rabbit-admin
    - rabbit-java-client
    - rabbit-client
    - app-server
    - zabbix-server
    - python-pyzabbix
    - zabbix-agent
    - zabbix-templates
  'worker*':
    - python-pyzabbix
    - zabbix-agent
    - python-packages
