ARG BIND_VERSION=9.18
FROM internetsystemsconsortium/bind9:${BIND_VERSION}

# install webmin as webui
RUN apt-get update \
    && apt-get install -y curl wget \
    && curl -o /tmp/setup-repos.sh https://raw.githubusercontent.com/webmin/webmin/master/setup-repos.sh \
    && chmod 0755 /tmp/setup-repos.sh \
    && echo 'y' | bash /tmp/setup-repos.sh \
    && apt-get update \
    && apt-get install -y webmin \
    && rm -f /tmp/setup-repos.sh \
    && apt-get clean

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENV ROOT_PASSWORD=bind

VOLUME [ "/data", "/var/log/bind" ]

EXPOSE 53/udp 53/tcp 953/tcp 10000/tcp

ENTRYPOINT [ "/docker-entrypoint.sh" ]

CMD ["/usr/sbin/named", "-g", "-c", "/etc/bind/named.conf", "-u", "bind"]
