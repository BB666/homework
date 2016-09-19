base:
  'central':
    - rabbit-server
    - rabbit-admin
    - rabbit-client
    - rabbit-java-client
    - app-server
    - zabbix-server
    - zabbix-agent
    - zabbix-templates

  'worker*':
    - rabbit-client
    - zabbix-agent
    - python-packages
