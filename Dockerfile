# syntax=docker/dockerfile:1

FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    clustalw \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /data
ENTRYPOINT ["clustalw2"]
