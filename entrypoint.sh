#!/bin/ash

EXIM=/usr/sbin/exim
OPENSSL=/usr/bin/openssl

DKIM=/dkim/$HOSTNAME

if [ ! -f $DKIM ]; then
  $OPENSSL genrsa $DKIM_KEY_SIZE > $DKIM
fi

if [ ! -f $DKIM.pub ]; then
  $OPENSSL rsa -in $DKIM -pubout > $DKIM.pub
fi

$EXIM $@
trap "kill $!" SIGINT SIGTERM
