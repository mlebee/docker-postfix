FROM ubuntu:bionic

RUN apt-get -y update && apt-get -y install \
  postfix \
  libsasl2-modules \
  && apt clean \
  && rm -rf /var/cache/apt/*

COPY run.sh /
RUN chmod +x /run.sh
RUN newaliases

EXPOSE 25
CMD ["/run.sh"]
