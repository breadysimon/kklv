# Build Stage
FROM lacion/alpine-golang-buildimage:1.12.4 AS build-stage

LABEL app="build-kklv"
LABEL REPO="https://github.com/breadysimon/kklv"

ENV PROJPATH=/go/src/github.com/breadysimon/kklv

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:$GOROOT/bin:$GOPATH/bin

ADD . /go/src/github.com/breadysimon/kklv
WORKDIR /go/src/github.com/breadysimon/kklv

RUN make build-alpine

# Final Stage
FROM chjmailbox/kklv:latest

ARG GIT_COMMIT
ARG VERSION
LABEL REPO="https://github.com/breadysimon/kklv"
LABEL GIT_COMMIT=$GIT_COMMIT
LABEL VERSION=$VERSION

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:/opt/kklv/bin

WORKDIR /opt/kklv/bin

COPY --from=build-stage /go/src/github.com/breadysimon/kklv/bin/kklv /opt/kklv/bin/
RUN chmod +x /opt/kklv/bin/kklv

# Create appuser
RUN adduser -D -g '' kklv
USER kklv

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["/opt/kklv/bin/kklv"]
