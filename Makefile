IMAGE   ?= cfcommunity/slack-notification-resource
VERSION ?= dev

install:
	mkdir -vp ~/.docker/cli-plugins/
	curl --silent -L "https://github.com/docker/buildx/releases/download/v0.4.2/buildx-v0.4.2.linux-amd64" > ~/.docker/cli-plugins/docker-buildx
	chmod a+x ~/.docker/cli-plugins/docker-buildx
	docker run --rm --privileged docker/binfmt:66f9012c56a8316f9244ffd7622d7c21c1f6f28d
	docker buildx create --use --name mybuilder

build: install
	docker buildx build --platform linux/amd64,linux/arm64 \
	  --build-arg BUILD_DATE="$(shell date -u --iso-8601)" \
	  --build-arg VCS_REF="$(shell git rev-parse --short HEAD)" \
	  --build-arg VERSION="$(VERSION)" \
	  -t $(IMAGE):$(VERSION) -t $(IMAGE):latest --push .

release: build
