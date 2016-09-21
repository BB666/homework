rabbit-java-client:
    cmd.run:
     - require:
        - archive: rabbit-java-client-arc
        - pkg: java-1.7.0-openjdk-devel
     - cwd: /usr/src
     - name: if [ ! -f "rabbitmq-client.jar" ]; then  mv rabbitmq-java-client-bin-3.6.5/rabbitmq-client.jar .; rm -f rabbitmq-java-client-bin-3.6.5/*; rmdir rabbitmq-java-client-bin-3.6.5/; chown root:root rabbitmq-client.jar;  rm -f rabbitmq-java-client-bin-3.6.5.tar.gz; fi

rabbit-java-client-arc:
    archive.extracted:
        - name: /usr/src/
        - source: http://www.rabbitmq.com/releases/rabbitmq-java-client/v3.6.5/rabbitmq-java-client-bin-3.6.5.tar.gz
        - source: https://github.com/rabbitmq/rabbitmq-server/releases/download/rabbitmq_v3_6_5/rabbitmq-java-client-bin-3.6.5.tar.gz
        - source_hash: md5=84811184fddff4bd1f875a369dbe652f
        - archive_format: tar
        - tar_options: z
        - if_missing: /usr/src/rabbitmq-java-client-bin-3.6.5/

java-1.7.0-openjdk-devel:
    pkg.installed:
        - name: java-1.7.0-openjdk-devel
