postfix:
  pkg.installed: []
  service.running:
    - enable: true
    - require:
      - pkg: postfix

postfix-config:
  file.blockreplace:
    - name: /etc/postfix/main.cf
    - content: |
        myhostname={{ salt['pillar.get']('postfix:hostname', grains.get('fqdn')) }}
        mydestination=$myhostname, localhost
        smtp_tls_security_level=may
        smtp_tls_loglevel=1
    - append_if_not_found: true
    - require:
      - file: postfix-base-config # from postfix.local or postfix.public
    - watch_in:
      - service: postfix

postfix-aliases:
  file.blockreplace:
    - name: /etc/aliases
    - content: |
        {% for alias, target in salt['pillar.get']('postfix:aliases', {}).iteritems() -%}
        {{ alias }}: {{ target }}
        {% endfor %}
    - append_if_not_found: true
  cmd.run:
    - name: postalias /etc/aliases
    - onchanges:
      - file: postfix-aliases

mail:
  pkg.installed:
    - name: mailutils
