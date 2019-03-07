# docker-postfix
[![Docker Stars](https://img.shields.io/docker/stars/mlebee/postfix-relay.svg?style=flat-square)](https://hub.docker.com/r/mlebee/postfix-relay)
[![Docker Pulls](https://img.shields.io/docker/pulls/mlebee/postfix-relay.svg?style=flat-square)](https://hub.docker.com/r/mlebee/postfix-relay)

Simple Postfix SMTP relay [docker](http://www.docker.com) image with no local authentication enabled (to be run in a secure LAN).

**postfix** is started with `start-fg` command to keep the master daemon running in the foreground.

### Build instructions

Clone this repo and then:

    cd docker-postfix
    sudo docker build -t postfix-relay .

### How to run it

The following env variables need to be passed to the container:

* `DOMAIN` The internet domain name of this mail system, aka `mydomain`
* `SMTP_SERVER` Server address of the SMTP server to use, aka `relayhost`

The following env variables are optional:
* `SERVER_HOSTNAME` (default: noname) Server hostname for the Postfix container. Emails will appear to come from the hostname's domain.
* `SMTP_SASL_AUTH_ENABLE` Enable SASL authentication in the Postfix SMTP client. The 2 env variables below are required:
  * `SMTP_USERNAME` Username to authenticate with.
  * `SMTP_PASSWORD` Password of the SMTP user.
* `SMTP_HEADER_TAG` This will add a header for tracking messages upstream. Helpful for spam filters. Will appear as "RelayTag: ${SMTP_HEADER_TAG}" in the email headers.


    docker run -d --name postfix-relay \
           -e DOMAIN=bar.com \
           -e SMTP_SERVER=relay.foo.com \
           mlebee/postfix-relay
