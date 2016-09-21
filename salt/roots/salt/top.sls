base:
  'central':
    - rabbit-server
    - rabbit-admin
    - rabbit-java-client
    - rabbit-client
    - app-server
    - zabbix-server
    - zabbix-agent
    - zabbix-templates
  'worker*':
    - python-packages
    - zabbix-agent
