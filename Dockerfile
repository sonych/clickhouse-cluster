FROM ubuntu:trusty

RUN apt-get update && apt-get install -y dirmngr

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E0C56BD4
RUN echo "deb http://repo.yandex.ru/clickhouse/deb/stable/ main/" | tee /etc/apt/sources.list.d/clickhouse.list
RUN apt-get update

RUN apt-get install -y \
    clickhouse-server \
    clickhouse-client

COPY ["./ch*_config.xml", "/etc/clickhouse-server/"]
COPY ["./include_from.xml", "/etc/clickhouse-server/include_from.xml"]
RUN chown root /etc/clickhouse-server/ch*_config.xml
RUN chown root /etc/clickhouse-server/include_from.xml

CMD ["clickhouse-server", "--config-file=/etc/clickhouse-server/config.xml"]
