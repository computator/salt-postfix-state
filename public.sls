include:
  - postfix

postfix-base-config:
  file.accumulated:
    - filename: /etc/postfix/main.cf
    - text: |
        inet_interfaces=all
        {% if salt['pillar.get']('postfix:networks') -%}
        mynetworks={% for net in salt['pillar.get']('postfix:networks') %}{{ net }}{% endfor %}
        {% else -%}
        mynetworks=
        mynetworks_style=host
        {% endif %}
        smtpd_client_restrictions=permit_mynetworks reject_unknown_client_hostname
    - require_in:
      - file: postfix-config