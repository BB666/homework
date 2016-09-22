python-pip:
    pkg.installed:
        - name: python-pip

pyzabbix:
    cmd.run:
        - names:
            - pip install pyzabbix
        - require:
            - pkg: python-pip
 
