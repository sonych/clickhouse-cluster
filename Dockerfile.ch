ARG BASE_IMAGE=ubuntu:18.04
FROM $BASE_IMAGE

ARG repository="deb http://repo.yandex.ru/clickhouse/deb/lts/ main/"
ARG version=19.14.10.16
ARG gosu_ver=1.10

RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
        apt-transport-https \
        dirmngr \
        gnupg \
        python3 \
        python3-pip \
        python3-setuptools \
    && gpg --version \
    && mkdir -p /etc/apt/sources.list.d \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv E0C56BD4 \
    && echo $repository > /etc/apt/sources.list.d/clickhouse.list \
    && apt-get update \
    && env DEBIAN_FRONTEND=noninteractive \
        apt-get install --allow-unauthenticated --yes --no-install-recommends \
            clickhouse-common-static=$version \
            clickhouse-client=$version \
            clickhouse-server=$version \
            libgcc-7-dev \
            locales \
            tzdata \
            wget \
    && rm -rf \
        /var/lib/apt/lists/* \
        /var/cache/debconf \
        /tmp/* \
    && apt-get clean \
    && pip3 install kazoo

ADD https://github.com/tianon/gosu/releases/download/1.10/gosu-amd64 /bin/gosu

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN mkdir /docker-entrypoint-initdb.d

# Copy the correct cluster config file across.
# this method handles a non-existing config file, as the base repo
# didn't use one in shard one, however it seems to be necessary!
ARG SHARD=1
RUN echo "./ch${SHARD}_config.xml*"
COPY ["./nill", "./ch${SHARD}_config.xml*", "/etc/clickhouse-server/tmp/"]
RUN if [ -f "/etc/clickhouse-server/tmp/ch${SHARD}_config.xml" ]; then mv "etc/clickhouse-server/tmp/ch${SHARD}_config.xml" /etc/clickhouse-server/config.xml; fi

COPY ["./include_from.xml", "/etc/clickhouse-server/include_from.xml"]
COPY ["./users.xml", "/etc/clickhouse-server/users.xml"]
COPY ["./dictionary.xml", "/etc/clickhouse-server/dictionary.xml"]

RUN chmod +x /bin/gosu

VOLUME /var/lib/clickhouse
CMD ["clickhouse-server", "--config-file=/etc/clickhouse-server/config.xml"]