FROM debian:stable-slim

ENV PROJECT_DIR=""
ENV COURSE_SHORTNAME="course"
ENV AUTHOR_SHORTNAME="togiolda"

ARG PROJECT_DIR=PROJECT_DIR
ARG PANDOC_VERSION=3.4
ARG CROSSREF_VERSION=0.3.18.0
ARG LUA_VERSION=5.4.6
ARG PANDOC_TYPES_VERSION=1.23.1

# system + full TeX stack
# Added 'lmodern' explicitly below
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    curl wget ca-certificates build-essential git \
    xz-utils tar gnupg \
    texlive-latex-base \
    texlive-latex-recommended \
    texlive-fonts-recommended \
    texlive-latex-extra \
    lmodern \
 && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Lua
RUN curl -fsSL https://www.lua.org/ftp/lua-${LUA_VERSION}.tar.gz -o /tmp/lua.tgz \
 && cd /tmp \
 && tar xzf lua.tgz \
 && cd lua-${LUA_VERSION} \
 && make linux install \
 && cd / \
 && rm -rf /tmp/lua*

# Pandoc
RUN curl -fsSL \
    https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-linux-amd64.tar.gz \
    -o /tmp/pandoc.tgz \
 && cd /tmp \
 && tar xzf pandoc.tgz \
 && mv pandoc-${PANDOC_VERSION}/bin/pandoc /usr/local/bin/ \
 && rm -rf pandoc* \
 && pandoc --version

# Pandoc-crossref
RUN curl -fsSL \
    https://github.com/lierdakil/pandoc-crossref/releases/download/v${CROSSREF_VERSION}/pandoc-crossref-Linux.tar.xz \
    -o /tmp/crossref.tar.xz \
 && cd /tmp \
 && tar -xf crossref.tar.xz \
 && mv pandoc-crossref /usr/local/bin/ \
 && rm -rf /tmp/* \
 && pandoc-crossref --version

# just
RUN curl -fsSL https://just.systems/install.sh | bash -s -- --to /usr/local/bin

WORKDIR /app

COPY ./report-theme report-theme
COPY ./justfile justfile
COPY ./meta.md meta.md
COPY ./filters filters

RUN mkdir /out

ENTRYPOINT ["sh", "-c", "just pdf $PROJECT_DIR"]