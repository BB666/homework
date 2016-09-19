app-server:
    cmd.run:
        - require:
            - cmd: rabbit-java-client
        - name: javac -cp rabbitmq-client.jar Send.java
        - cwd: /usr/src
        - creates: /usr/src/Send.class