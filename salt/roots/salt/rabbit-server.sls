erlang:
  pkg.installed:
    - name: erlang

socat:
  pkg.installed:
    - name: socat

add-rabbitmq-signing-key:
  cmd.run:
    - name: rpm --import http://www.rabbitmq.com/rabbitmq-signing-key-public.asc
    - require:
      - pkg: socat

rabbitmq-server:
  pkg.installed:
    - pkg: rabbitmq-server
    - require:
      - cmd: add-rabbitmq-signing-key
      - pkg: erlang

rabbitmq-server-service:
  service.running:
    - name: rabbitmq-server
    - enable: True
    - require:
      - pkg: rabbitmq-server
