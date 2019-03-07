#!/bin/bash

[ "${DEBUG}" == "yes" ] && set -x

function add_config_value() {
  local key=${1}
  local value=${2}
  local config_file=${3:-/etc/postfix/main.cf}
  [ "${key}" == "" ] && echo "ERROR: No key set !!" && exit 1
  [ "${value}" == "" ] && echo "ERROR: No value set !!" && exit 1

  echo "Setting configuration option ${key} with value: ${value}"
 postconf -e "${key} = ${value}"
}

[ -z "${DOMAIN}" ] && echo "DOMAIN is not set" && exit 1
[ -z "${SMTP_SERVER}" ] && echo "SMTP_SERVER is not set" && exit 1
if [[ "${SMTP_SASL_AUTH_ENABLE}" == "yes" ]]
then
  SMTP_PORT="587"
  [ -z "${SMTP_USERNAME}" ] && echo "SMTP_USERNAME is not set" && exit 1
  [ -z "${SMTP_PASSWORD}" ] && echo "SMTP_PASSWORD is not set" && exit 1
else
  SMTP_PORT="25"
fi

# Set needed config options
add_config_value "myhostname" ${SERVER_HOSTNAME-noname}
add_config_value "mydomain" ${DOMAIN}
add_config_value "mydestination" '$myhostname localhost.$mydomain localhost'
add_config_value "myorigin" '$mydomain'
add_config_value "relayhost" "[${SMTP_SERVER}]:${SMTP_PORT}"
# and specify the trusted networks
add_config_value "mynetworks" "127.0.0.0/8, 10.0.0.0/8"
add_config_value "inet_interfaces" "all"
add_config_value "inet_protocols" "ipv4"

# Set sasl config options
if [[ "${SMTP_SASL_AUTH_ENABLE}" == "yes" ]]; then
add_config_value "smtp_sasl_auth_enable" "yes"
add_config_value "smtp_use_tls" "yes"
add_config_value "smtp_sasl_password_maps" "hash:\/etc\/postfix\/sasl_passwd"
add_config_value "smtp_sasl_security_options" "noanonymous"
fi

# Create sasl_passwd file with auth credentials
echo "Adding SASL authentication configuration"
echo "[${SMTP_SERVER}]:${SMTP_PORT} ${SMTP_USERNAME}:${SMTP_PASSWORD}" > /etc/postfix/sasl_passwd
postmap /etc/postfix/sasl_passwd


#Set header tag
if [ ! -z "${SMTP_HEADER_TAG}" ]; then
  postconf -e "header_checks = regexp:/etc/postfix/header_tag"
  echo -e "/^MIME-Version:/i PREPEND RelayTag: $SMTP_HEADER_TAG\n/^Content-Transfer-Encoding:/i PREPEND RelayTag: $SMTP_HEADER_TAG" > /etc/postfix/header_tag
  echo "Setting configuration option SMTP_HEADER_TAG with value: ${SMTP_HEADER_TAG}"
fi

#Start services
supervisord
