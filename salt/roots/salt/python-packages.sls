python-devel:
    pkg.installed:
        - name: python-devel

pika:
    cmd.run:
        - names:
            - pip install pika
            - pip install twisted
        - require:
            - pkg: python-devel
            - pkg: python-pip
