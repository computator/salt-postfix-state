dkim:
  pkg.installed:
    - name: opendkim
  service.running:
    - name: opendkim
    - enable: true
    - require:
      - pkg: dkim

dkim-tools:
  pkg.installed:
    - name: opendkim-tools

dkim-keys:
  cmd.run:
    - name: opendkim-genkey -D /etc/dkimkeys
    - creates: /etc/dkimkeys/default.private
    - require:
      - pkg: dkim
      - pkg: dkim-tools
    - require_in:
      - service: dkim
  file.managed:
    - name: /etc/dkimkeys/default.private
    - user: opendkim
    - create: false
    - replace: false
    - require:
      - cmd: dkim-keys
    - require_in:
      - service: dkim

dkim-config:
  file.blockreplace:
    - name: /etc/opendkim.conf
    - content: |
        Mode sv
        Domain {{ salt['pillar.get']('postfix:signing_domain', grains.get('fqdn')) }}
        KeyFile /etc/dkimkeys/default.private
        Selector default
        SubDomains {% if salt['pillar.get']('postfix:sign_subdomains', False) %}yes{% else %}no{% endif %}
        LogWhy true
    - append_if_not_found: true
    - require:
      - pkg: dkim
    - watch_in:
      - service: dkim

dkim-socket-dir:
  file.directory:
    - name: /var/spool/postfix/opendkim
    - user: opendkim
    - group: postfix
    - mode: 2755
    - require:
      - pkg: postfix

dkim-socket:
  file.replace:
    - name: /etc/default/opendkim
    - pattern: ^SOCKET=.*
    - repl: SOCKET="/var/spool/postfix/opendkim/opendkim.sock"
    - append_if_not_found: true
    - require:
      - pkg: dkim
      - file: dkim-socket-dir
    - watch_in:
      - service: dkim

postfix-dkim-config:
  file.accumulated:
    - filename: /etc/postfix/main.cf
    - text: |
        non_smtpd_milters=local:/opendkim/opendkim.sock
        smtpd_milters=local:/opendkim/opendkim.sock
    - require_in:
      - file: postfix-config