#!/bin/bash


USERNAME="admin"
PASSWORD="admin"
SERVER="192.168.1.254"
PORT="80"
SEED="$(date +%s)tester$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -bw 12 | head -n1)"


COMMON_CURL_PARMS="-k -s --header 'Accept: application/json, text/plain, */*' --header 'X-XSRF-TOKEN: ciao' --header 'DNT: 1' --header 'Accept-Encoding: gzip, deflate' --cookie XSRF-TOKEN=ciao"
COMMON_CURL_URI="/status.cgi?_=${SEED}&sessionKey="
SESSION_KEY="NULL"

warn() {
  echo "Warning: $@" >&2
}


# Esce dallo script con un messaggio di errore opzionale
die() {
  test $# -gt 0 && echo "Error: $@" >&2
  exit 1
}

test_prog_check() {
  test -z "$1" && return 1
  local _prog="$(which $1 2>&1)"
  test -z "$_prog" && return 1
  test -x "$_prog" || return 1
  return 0
}


rawurlencode() {
  local string="${1}"
  local strlen=${#string}
  local encoded=""
  local pos c o

  for (( pos=0 ; pos<strlen ; pos++ )); do
     c=${string:$pos:1}
     case "$c" in
        [-_.~a-zA-Z0-9=] ) o="${c}" ;;
        * )               printf -v o '%%%02x' "'$c"
     esac
     encoded+="${o}"
  done
  echo "${encoded}"    # You can either set a return variable (FASTER) 
}


send_cmd() {
  local parms
  while [ x"$1" != x ]; do
    local string=$(rawurlencode "$1")
    parms="${parms}&${string}"
    shift
  done
  eval curl $COMMON_CURL_PARMS "\"http://${SERVER}:${PORT}${COMMON_CURL_URI}${SESSION_KEY}$parms\""
}


sanity() {
  test_prog_check curl || die "Please install curl"
  test_prog_check jq   || die "Please install jq"

  SESSION_KEY="$(send_cmd "cmd=3" "nvget=login_confirm" "username=$USERNAME" "password=$PASSWORD" | jq -r '.login_confirm.check_session')"

  local areweconnected=$(send_cmd "cmd=4" "nvget=login_confirm" | jq -r .login_confirm.login_status)
  [ "$areweconnected" != "1" ] && die "Login failed"

  echo "Logged in, session key: $SESSION_KEY"

}

sanity

if [ -n "$1" -a "$1" = "getroot" ]; then
  echo "Sto attivando Telnetd e SSHD sulla rete interna"
  send_cmd nvget=login_confirm cmd=3 username=pippo password="'; /usr/sbin/stnvram set CWMPX_FASTWEB_AppCfgSshdAllowIF LAN ; /usr/sbin/stnvram commit ; #" >/dev/null 
  sleep 1

  echo "Sto modificando il firewall per consentire l'accesso via Telnet e SSH da 192.168.0.0"
  send_cmd nvget=login_confirm cmd=3 username=pippo password="'; /usr/sbin/stnvram set CWMPX_FASTWEB_AppCfgTelnet_SSH_ACL 192.168.1.0/16  ;/usr/sbin/stnvram commit;  #" >/dev/null
  sleep 1

  echo "Sto riavviando il demone SSHD"
  send_cmd nvget=login_confirm cmd=3 username=pippo password="'; PATH='/home/bin:/home/scripts:/opt/bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/jamvm/bin:/opt/scripts' /usr/sbin/rc_task sshd restart ; #" >/dev/null
  sleep 2

  echo "Sto riavviando il demone Telnet"
  send_cmd nvget=login_confirm cmd=3 username=pippo \
    password="'; PATH='/home/bin:/home/scripts:/opt/bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/jamvm/bin:/opt/scripts' /usr/sbin/rc_task telnet restart ; #" >/dev/null
  sleep 2

  echo "Sto riavviando il firewall"
  send_cmd nvget=login_confirm cmd=3 username=pippo password="'; PATH='/home/bin:/home/scripts:/opt/bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/jamvm/bin:/opt/scripts' /usr/sbin/rc_task firewall restart ; #" >/dev/null
  sleep 2


  echo "Se tutto è andato bene, ora puoi connetterti a ${SERVER} via ssh usando come credenziali \"lanadmin\" e \"lanpasswd\""
  echo "Una volta effettuato il login, puoi richiamare una shell di root digitando \"sh -l\" e, al prompt, inserire:"
  echo "Username: \"lanadmin\""
  echo "Password: \"lanpasswd\""
  echo "oppure"
  echo "Username: \"FASTGate\""
  echo "Password: \"Testplant123\""
  echo "Attento a non rompere nulla!"
  

fi




send_cmd "$@" | jq "."
