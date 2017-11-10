FROM ubuntu:trusty

RUN echo "deb http://repo.yandex.ru/clickhouse/trusty/ dists/stable/main/binary-amd64/" \
    > /etc/apt/sources.list.d/clickhouse.list

RUN apt-get update

RUN apt-get install -y --allow-unauthenticated \
    clickhouse-server-common \
    clickhouse-client

COPY ["./ch1_config.xml", "/etc/clickhouse-server/config.xml"]
COPY ["./include_from.xml", "/etc/clickhouse-server/include_from.xml"]
VOLUME /var/lib/clickhouse

CMD ["clickhouse-server", "--config-file=/etc/clickhouse-server/config.xml"]
