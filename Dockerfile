# syntax=docker/dockerfile:1

FROM ubuntu:22.04 AS builder

ARG DEBIAN_FRONTEND=noninteractive
ARG CLUSTALW_VERSION=2.1
ARG CLUSTALW_SHA256=e052059b87abfd8c9e695c280bfba86a65899138c82abccd5b00478a80f49486

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    wget \
    build-essential \
    autoconf \
    automake \
    libtool \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp
RUN wget --no-check-certificate -O clustalw.tar.gz "https://www.clustal.org/download/current/clustalw-${CLUSTALW_VERSION}.tar.gz" \
    && echo "${CLUSTALW_SHA256}  clustalw.tar.gz" | sha256sum -c - \
    && tar -xzf clustalw.tar.gz \
    && cd "clustalw-${CLUSTALW_VERSION}" \
    && ./configure --prefix=/usr/local \
    && make -j"$(nproc)" \
    && make install-strip \
    && if [ -x /usr/local/bin/clustalw2 ] && [ ! -x /usr/local/bin/clustalw ]; then ln -s /usr/local/bin/clustalw2 /usr/local/bin/clustalw; fi

FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/bin/clustalw /usr/local/bin/clustalw
COPY --from=builder /usr/local/bin/clustalw2 /usr/local/bin/clustalw2

WORKDIR /data
ENTRYPOINT ["clustalw"]
