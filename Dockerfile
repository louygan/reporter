# build
FROM golang:1.14.7-alpine3.12 AS build
WORKDIR /go/src/${owner:-github.com/IzakMarais}/reporter
RUN apk update && apk add make git
ADD . .
RUN make build

# create image
FROM alpine:3.12
COPY util/texlive.profile /

RUN PACKAGES="wget freeswitch-perl" \
        && apk update \
        && apk add $PACKAGES \
        && apk add ca-certificates texlive \
        # Cleanup
        && apk del --purge -qq $PACKAGES \
        && apk del --purge -qq \
        && rm -rf /var/lib/apt/lists/*


COPY --from=build /go/bin/grafana-reporter /usr/local/bin
ENTRYPOINT [ "/usr/local/bin/grafana-reporter" ]
