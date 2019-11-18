FROM alpine:edge

ENV RELAY_FROM_HOSTS=10.0.0.0/8:172.16.0.0/12:192.168.0.0/16 \
    DKIM_KEY_SIZE=1024 \
    DKIM_SELECTOR=mail \
    DKIM_SIGN_HEADERS=Date:From:To:Subject:Message-ID \
    EXIM_VERSION=4.92.3-r0

RUN apk --no-cache add exim=$EXIM_VERSION libcap openssl \
    && mkdir -pv /dkim /var/log/exim /usr/lib/exim /var/spool/exim \
    && ln -s /dev/stdout /var/log/exim/main \
    && ln -s /dev/stderr /var/log/exim/panic \
    && ln -s /dev/stderr /var/log/exim/reject \
    && chown -R 100: /dkim /var/log/exim /usr/lib/exim /var/spool/exim \
    && chmod 0755 /usr/sbin/exim \
    && setcap cap_net_bind_service=+ep /usr/sbin/exim \
	&& ln -svfT /etc/hostname /etc/mailname \
    && apk del libcap

COPY ./entrypoint.sh /
COPY ./exim.conf /etc/exim/exim.conf

RUN chmod +x /entrypoint.sh

USER exim
VOLUME /dkim
EXPOSE 25

ENTRYPOINT ["/entrypoint.sh"]

CMD ["-bdf", "-v"]
