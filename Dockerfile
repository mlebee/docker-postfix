FROM ubuntu:bionic

RUN apt-get -y update && apt-get -y install \
  postfix \
  libsasl2-modules \
  && apt-get clean \
  && rm -rf /var/cache/apt/* /var/lib/apt/lists/*

COPY run.sh /
RUN chmod +x /run.sh
RUN newaliases

EXPOSE 25
CMD ["/run.sh"]
