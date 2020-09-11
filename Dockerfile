FROM alpine:3

ARG VERSION
ARG BUILD_DATE
ARG VCS_REF
LABEL maintainer="Stark & Wayne <beahero@starkandwayne.com>" \
      summary="Concourse Slack Notifications Resource" \
      version=$VERSION \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://github.com/cloudfoundry-community/slack-notification-resource.git" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.schema-version="1.0.0"

RUN apk add --no-cache curl bash jq gettext-dev

COPY check /opt/resource/check
COPY in    /opt/resource/in
COPY out   /opt/resource/out

RUN chmod +x /opt/resource/out /opt/resource/in /opt/resource/check

ADD test/ /opt/resource-tests/
RUN /opt/resource-tests/all.sh \
 && rm -rf /tmp/*
