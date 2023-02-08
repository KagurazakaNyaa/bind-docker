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

if [ ! -f /etc/webmin/miniserv.conf ]; then
    echo "Initiating webmin data..."
    rsync -a /initdata/webmin/ /etc/webmin
    echo "done."
fi
if [ ! -f /etc/bind/named.conf ]; then
    echo "Initiating bind data..."
    rsync -a /initdata/bind/ /etc/bind
    echo "done."
fi

chown root:bind /etc/bind/ && chmod 755 /etc/bind
chown bind:bind /var/cache/bind && chmod 755 /var/cache/bind
chown bind:bind /var/lib/bind && chmod 755 /var/lib/bind
chown bind:bind /var/log/bind && chmod 755 /var/log/bind

if [[ -z ${1} ]]; then
    echo "root:$ROOT_PASSWORD" | chpasswd
    echo "Starting webmin..."
    /etc/init.d/webmin start
    echo "done."
    echo "Starting bind..."
    /usr/sbin/named -g -c /etc/bind/named.conf -u bind
else
    exec "$@"
fi
