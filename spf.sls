policyd-spf:
  pkg.installed:
    - name: postfix-policyd-spf-python

postfix-spf-master:
  file.append:
    - name: /etc/postfix/master.cf
    - text: |
        policy_spf unix - n n - 0 spawn
          user=policyd-spf argv=/usr/bin/policyd-spf
    - require:
      - pkg: policyd-spf
    - watch_in:
      - service: postfix

postfix-spf-config:
  file.accumulated:
    - filename: /etc/postfix/main.cf
    - text: |
        check_policy_service = unix:private/policy_spf
        policy_spf_time_limit = 3600
    - require:
      - file: postfix-spf-master
    - require_in:
      - file: postfix-config