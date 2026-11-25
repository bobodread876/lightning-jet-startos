FROM node:22-alpine

# arm64 or amd64
ARG PLATFORM
# aarch64 or x86_64
ARG ARCH

RUN apk update && apk add --no-cache --virtual build-dependencies \
  procps make gcc g++ python3 py3-setuptools curl wget bash sudo

RUN wget https://github.com/mikefarah/yq/releases/download/v4.6.3/yq_linux_${PLATFORM}.tar.gz -O - |\
  tar xz && mv yq_linux_${PLATFORM} /usr/bin/yq

WORKDIR /app/
COPY lightning-jet/ /app/

RUN npm_config_build_from_source=true npm_config_python=/usr/bin/python3 npm ci --omit=dev

# Jet opens these paths directly. Resolve them into the StartOS main volume.
RUN mv /app/api/config.json /app/api/config.default.json \
    && ln -s /root/jet/config.json /app/api/config.json \
    && ln -s /root/jet/jet.db /app/db/jet.db
COPY jet-config.cjs /usr/local/lib/jet-config.js

ENV PATH="/app:${PATH}"

ADD ./docker_entrypoint.sh /usr/local/bin/docker_entrypoint.sh
RUN chmod a+x /usr/local/bin/docker_entrypoint.sh

# StartOS 0.3 removes the old image ID after an upgrade, even if its tag changed.
ARG PKG_VERSION
LABEL org.opencontainers.image.version=$PKG_VERSION
