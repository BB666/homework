python-pip:
    pkg.installed:
        - name: python-pip

python-devel:
    pkg.installed:
        - name: python-devel

pika:
    cmd.run:
        - names:
            - pip install pika
            - pip install twisted
        - require:
            - pkg: python-pip
            - pkg: python-devel
 
