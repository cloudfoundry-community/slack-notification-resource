FROM alpine

RUN apk add --update \
    bash \
    curl \
    jq \
 && rm -rf /var/cache/apk/*

COPY check /opt/resource/check
COPY in    /opt/resource/in
COPY out   /opt/resource/out

RUN chmod +x /opt/resource/*
