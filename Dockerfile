ARG BIND_VERSION=9.18
FROM internetsystemsconsortium/bind9:${BIND_VERSION}

# install webmin as webui
RUN apt-get update \
    && apt-get install -y curl wget rsync \
    && curl -o /tmp/setup-repos.sh https://raw.githubusercontent.com/webmin/webmin/master/setup-repos.sh \
    && chmod 0755 /tmp/setup-repos.sh \
    && echo 'y' | bash /tmp/setup-repos.sh \
    && apt-get update \
    && apt-get install -y webmin \
    && rm -f /tmp/setup-repos.sh \
    && apt-get clean

RUN mkdir -p /initdata/webmin /initdata/bind && rsync -a /etc/webmin/ /initdata/webmin && rsync -a /etc/bind/ /initdata/bind

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENV ROOT_PASSWORD=bind

VOLUME [ "/etc/webmin" ]

EXPOSE 53/udp 53/tcp 953/tcp 10000/tcp

ENTRYPOINT [ "/docker-entrypoint.sh" ]

CMD ["/usr/sbin/named", "-g", "-c", "/etc/bind/named.conf", "-u", "bind"]
