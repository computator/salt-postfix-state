include:
  - postfix

postfix-base-config:
  file.accumulated:
    - filename: /etc/postfix/main.cf
    - text: |
        inet_interfaces=loopback-only
        mynetworks=
        mynetworks_style=host
    - require_in:
      - file: postfix-config