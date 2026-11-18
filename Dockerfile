FROM docker.io/library/busybox:1.36.1-musl AS shell

FROM docker.io/3proxy/3proxy:latest

# Офіційний образ 3proxy/3proxy:latest зібраний FROM scratch (містить лише /bin/3proxy).
# Додаємо мінімальний статичний POSIX shell (~1 МБ) для динамічної генерації конфігу з .env.
COPY --from=shell /bin/busybox /bin/busybox
COPY --from=shell /bin/sh /bin/sh
COPY --from=shell /bin/tr /bin/tr
COPY --from=shell /bin/cat /bin/cat
COPY --from=shell /bin/grep /bin/grep
COPY --from=shell /bin/netstat /bin/netstat
COPY --from=shell /tmp /tmp

ENV PROXY_PORT=8888 \
    PROXY_BIND_IP=0.0.0.0 \
    ALLOWED_IPS=185.112.41.130 \
    ANONYMOUS_MODE=false \
    BLOCK_LOCALHOST=true \
    MAX_CONN=2000 \
    DNS_SERVERS=1.1.1.1,8.8.8.8 \
    ENABLE_LOGS=true

COPY entrypoint.sh /entrypoint.sh

EXPOSE 8888

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD ["/bin/sh", "-c", "netstat -lnt | grep -q \":${PROXY_PORT:-8888} \""]

ENTRYPOINT ["/entrypoint.sh"]
