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
    - require_in:
      - file: postfix-config