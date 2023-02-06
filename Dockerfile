ARG BIND_VERSION=9.18
FROM internetsystemsconsortium/bind9:${BIND_VERSION}

# install webmin as webui
RUN apt-get update \
    && apt-get install -y curl wget \
    && curl -o /tmp/webmin-current.deb https://www.webmin.com/download/deb/webmin-current.deb \
    && apt-get install -y /tmp/webmin-current.deb \
    && rm -f /tmp/webmin-current.deb \
    && apt-get clean

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENV ROOT_PASSWORD=bind

VOLUME [ "/data", "/var/log/bind" ]

EXPOSE 53/udp 53/tcp 953/tcp 10000/tcp

ENTRYPOINT [ "/docker-entrypoint.sh" ]

CMD ["/usr/sbin/named", "-g", "-c", "/etc/bind/named.conf", "-u", "bind"]
