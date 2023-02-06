#!/bin/bash
set -e

# allow arguments to be passed to named
if [[ ${1:0:1} = '-' ]]; then
  EXTRA_ARGS="$*"
  set --
elif [[ ${1} == named || ${1} == "$(command -v named)" ]]; then
  EXTRA_ARGS="${*:2}"
  set --
fi

if [ ! -f /data/.initialized ]; then
    mv /etc/bind /data/bind/etc
    mv /var/cache/bind /data/bind/cache
    mv /var/lib/bind /data/bind/data
    mv /etc/webmin /data/webmin
    touch /data/.initialized
fi

if [ ! -L /etc/bind ]; then
    rm -rf /etc/bind
    ln -s /data/bind/etc /etc/bind
    chown root:bind /etc/bind/ && chmod 755 /etc/bind
fi
if [ ! -L /var/cache/bind ]; then
    rm -rf /var/cache/bind
    ln -s /data/bind/cache /var/cache/bind
    chown bind:bind /var/cache/bind && chmod 755 /var/cache/bind
fi
if [ ! -L /var/lib/bind ]; then
    rm -rf /var/lib/bind
    ln -s /data/bind/data /var/lib/bind
    chown bind:bind /var/lib/bind && chmod 755 /var/lib/bind
fi
if [ ! -L /etc/webmin ]; then
    rm -rf /etc/webmin
    ln -s /data/webmin /etc/webmin
fi

chown bind:bind /var/log/bind && chmod 755 /var/log/bind

if [[ -z ${1} ]]; then
    echo "root:$ROOT_PASSWORD" | chpasswd
    echo "Starting webmin..."
    /etc/init.d/webmin start
    /usr/sbin/named -g -c /etc/bind/named.conf -u bind
else
    exec "$@"
fi
