python-pip:
    pkg.installed:
        - name: python-pip

pika:
    cmd.run:
        - name: pip install pika
        - require:
            - pkg: python-pip