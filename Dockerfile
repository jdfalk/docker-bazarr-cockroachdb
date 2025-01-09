# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/unrar:latest AS unrar

FROM ghcr.io/linuxserver/baseimage-alpine:3.21

# set version label
ARG BUILD_DATE
ARG VERSION
ARG BAZARR_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="chbmb"
# hard set UTC in case the user does not define it
ENV TZ="Etc/UTC"

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    build-base \
    cargo \
    libffi-dev \
    libpq-dev \
    libxml2-dev \
    libxslt-dev \
    python3-dev && \
  echo "**** install packages ****" && \
  apk add --no-cache \
    ffmpeg \
    libxml2 \
    libxslt \
    mediainfo \
    python3 && \
  echo "**** install bazarr ****" && \
  mkdir -p \
    /app/bazarr/bin && \
  if [ -z ${BAZARR_VERSION+x} ]; then \
    BAZARR_VERSION=$(curl -sX GET "https://api.github.com/repos/jdfalk/bazarr-cockroachdb/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  curl -o \
    /tmp/bazarr.zip -L \
    "https://github.com/jdfalk/bazarr-cockroachdb/releases/download/${BAZARR_VERSION}/bazarr.zip" && \
  unzip \
    /tmp/bazarr.zip -d \
    /app/bazarr/bin && \
  rm -Rf /app/bazarr/bin/bin && \
  echo "UpdateMethod=docker\nBranch=master\nPackageVersion=${VERSION}\nPackageAuthor=linuxserver.io" > /app/bazarr/package_info && \
  curl -o \
    /app/bazarr/bin/pyproject.toml -L \
    "https://github.com/jdfalk/bazarr-cockroachdb/releases/download/${BAZARR_VERSION}/pyproject.toml" && \
  uv build && \
  # curl -o \
  #   /app/bazarr/bin/postgres-requirements.txt -L \
  #   "https://raw.githubusercontent.com/morpheus65535/bazarr/${BAZARR_VERSION}/postgres-requirements.txt" && \
  # echo "**** Install requirements ****" && \
  # python3 -m venv /lsiopy && \
  # pip install -U --no-cache-dir \
  #   pip \
  #   wheel && \
  # pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/alpine-3.21/ \
  #   -r /app/bazarr/bin/requirements.txt \
  #   -r /app/bazarr/bin/postgres-requirements.txt && \
  # echo "sqlalchemy-cockroachdb" >> /app/bazarr/bin/requirements.txt && \
  # pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/alpine-3.21/ \
  #   -r /app/bazarr/bin/requirements.txt && \
  printf "Linuxserver.io version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
  echo "**** clean up ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    $HOME/.cache \
    $HOME/.cargo \
    /tmp/*

# add local files
COPY root/ /

# add unrar
COPY --from=unrar /usr/bin/unrar-alpine /usr/bin/unrar

# ports and volumes
EXPOSE 6767

VOLUME /config


# RUN sed -i.bak 's/drivername="postgresql"/drivername="cockroachdb"/' /app/bazarr/bin/bazarr/app/database.py && \
#   sed -i.bak "s/elif bind\.engine\.name == \'postgresql\':/# PostgreSQL detected/g" /app/bazarr/bin/migrations/env.py && \
#   sed -i.bak 's/bind\.execute(text\(\"SET CONSTRAINTS ALL DEFERRED;\"\))/# Constraints deferred/' /app/bazarr/bin/migrations/env.py && \
#   sed -i.bak 's/bind\.execute(text\(\"SET CONSTRAINTS ALL IMMEDIATE;\"\))/# Constraints immediate/' /app/bazarr/bin/migrations/env.py

