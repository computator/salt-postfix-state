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
  cmd.run:
    # comments lines so values are only set once, leaving only the last line
    - name: cp /etc/postfix/main.cf /etc/postfix/main.cf.tmp && awk -F '[= \t]' '/^[ \t]*[^# \t]/ {if($1 "" in k) {l[k[$1 ""]] = "#" l[k[$1 ""]]; k[$1 ""] = NR}}; {l[NR] = $0; k[$1 ""] = NR}; END {for(i=1;i<=NR;i++) print l[i]}' /etc/postfix/main.cf.tmp > /etc/postfix/main.cf; rm -f /etc/postfix/main.cf.tmp
    - onchanges:
      - file: postfix-config
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
