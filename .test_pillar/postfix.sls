postfix:
  hostname: postfix-test
  # if networks is set, it's a list of trusted networks allowed
  # to send email through the server
  networks:
    - 127.0.0.1/8
  aliases:
    webmaster: root