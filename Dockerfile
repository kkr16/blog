FROM alpine:3.15.0 as build
ARG HUGO_VERSION=0.92.2
ENV HUGO_BINARY hugo_extended_${HUGO_VERSION}_Linux-64bit.tar.gz
RUN apk add --no-cache git
RUN apk add --update wget ca-certificates && \
    cd /tmp/ && \
    wget https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${HUGO_BINARY} && \
    tar xzf ${HUGO_BINARY} && \
    rm -r ${HUGO_BINARY} && \
    mv hugo /usr/bin/hugo && \
    apk del wget ca-certificates && \
    rm /var/cache/apk/*
WORKDIR /site
COPY . .
RUN git submodule update --init --recursive
RUN HUGO_ENV=production hugo -v -s /site -d /site/public

FROM nginx:alpine
COPY config/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /site/public /usr/share/nginx/html