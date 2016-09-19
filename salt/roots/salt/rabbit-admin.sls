install-rabbitmqadmin:
  file.managed:
    - name: /usr/local/sbin/rabbitmqadmin
    - source: http://127.0.0.1:15672/cli/rabbitmqadmin
#   - source: https://raw.githubusercontent.com/rabbitmq/rabbitmq-management/rabbitmq_v3_6_5/bin/rabbitmqadmin
    - skip_verify: True
    - user: root
    - group: root
    - mode: 755
    - require:
      - cmd: rabbit-server-restart

configure-rabbitmqadmin:
  cmd.run:
    - names:
      - sudo rabbitmq-plugins enable amqp_client
      - sudo rabbitmq-plugins enable rabbitmq_management
    - require_in:
      - service: rabbitmq-server

rabbit-server-restart:
    cmd.run:
        - name: systemctl restart rabbitmq-server
        - require:
            - cmd: configure-rabbitmqadmin

declare-bindings:
  cmd:
    - run
    - name: /usr/local/sbin/rabbitmqadmin declare binding source=central destination_type=queue destination=central routing_key=central
    - require:
      - cmd: declare-queues

declare-queues:
  cmd:
    - run
    - name: /usr/local/sbin/rabbitmqadmin declare queue name=central durable=true
    - require:
      - cmd: declare-exchanges

declare-exchanges:
  cmd:
    - run
    - name: /usr/local/sbin/rabbitmqadmin declare exchange name=central type=direct
    - require:
      - file: install-rabbitmqadmin
