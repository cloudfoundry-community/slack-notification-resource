ARG alpine

FROM ${alpine} AS resource

ARG VERSION
ARG BUILD_DATE
ARG VCS_REF
LABEL maintainer="Gstack <https://github.com/gstackio>" \
      summary="Concourse Slack Notifications Resource" \
      version=$VERSION \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://github.com/cloudfoundry-community/slack-notification-resource.git" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.schema-version="1.0.0"

# Notice: the 'gettext-dev' package provides the required 'envsubst' binary
RUN apk add --no-cache curl bash jq gettext-dev

COPY check /opt/resource/check
COPY in    /opt/resource/in
COPY out   /opt/resource/out

RUN chmod +x /opt/resource/out /opt/resource/in /opt/resource/check



FROM resource AS tests

ADD test/ /opt/resource-tests/
RUN /opt/resource-tests/all.sh \
    && rm -rf /tmp/*



FROM resource
