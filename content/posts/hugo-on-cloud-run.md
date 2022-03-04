---
title: "How I built this blog using Hugo on Cloud Run"
date: 2022-03-01T03:20:02Z
draft: false
taxonomies:
  tags: "#meta"
---
# Hugo on Cloud Run

I'm a master procrastinator. This meant that when I decided to start writing, I had to find new ways to delay it, and what better way of procrastinating on writing, than to build your own blog.

I wanted a blog that:
- is lightweight
- is static
- portable
- runs on Google Cloud
- requires zero infrastructure management
- uses Markdown
- is source controlled
- can be deployed via GitOps

Once everything was deployed, I ended up with a super simple setup, with only one service serving traffic. 

![](/img/hugo-on-run.png)

## Building the blog
I decided on using Hugo for my blog because it can be used to generate static html content. This meant the blog didn't need a database, or a specific tech stack other than a webserver to be served. This help keeps my blog's Cloud costs low, and it also helps reduce vulnerabilities given the smaller attack surface.

When I'm editing, I just start a Hugo server on localhost, and start writting, and my page gets refreshed every time I save the markdown file.

To start the server locally, I just execute the below command, and navigate to [http://localhost:1313](http://localhost:1313)

`$ hugo server`

## Generating the static content
Once the content is to my liking, I can push it to my [Github repo](https://github.com/kkr16/blog). I can also generate the static html from my markdown content, and my selected theme and templates

```
$ hugo -v -s . -d ./public
       |   |        |_ destination directory
       |   |_ source directory
       |_ verbose
```
The static content can now be served using [nginx](https://nginx.com) or any other web server.

## Serving the blog
To serve the blog, I opted for [Google Cloud Run](https://cloud.google.com/run), a fully managed serverless container platform.

I then used Cloud Run's [Custom Domain](https://cloud.google.com/run/docs/mapping-custom-domains#run) feature to map my domain to the Cloud Run service, which meant I didn't need to deploy my own Load Balancer upstream.

## Deploying the blog
I want to ensure that my blog is always up to date, and tracks my Github repo, so I configured [Continuous Deployment from Git using Cloud Build](https://cloud.google.com/run/docs/continuous-deployment-with-cloud-build). Cloud Build can get build instructions directly from a `Dockerfile`. For more complex builds, you would probably want to use `cloudbuild.yml` defitions, but this job is simple that it could be defined in a simple `Dockerfile`.

In order to keep my end image as light as possible, I'm doing a two stage build:
1. Build a `build` container image that will use `hugo` to generate static html content
2. Build a second container image based on `nginx:alpine` that contains nginx and your static html

Cloud Build will then take this resulting image, store it in Google Container Registry. Cloud Build will then automatically deploy it to my Cloud Run service, and send 100% of the traffic to the new image. 

This is the Dockerfile used by Google Cloud Build to build the image:
```
FROM alpine as build
ARG HUGO_VERSION=0.92.0
ENV HUGO_BINARY hugo_extended_${HUGO_VERSION}_Linux-64bit.tar.gz
ENV HUGO_ENV production

ENV GLIBC_VERSION 2.27-r0

RUN set -x && \
  apk add --update wget ca-certificates libstdc++

# Install glibc: This is required for HUGO-extended (including SASS) to work.

RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
&&  wget "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_VERSION/glibc-$GLIBC_VERSION.apk" \
&&  apk --no-cache add "glibc-$GLIBC_VERSION.apk" \
&&  rm "glibc-$GLIBC_VERSION.apk" \
&&  wget "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_VERSION/glibc-bin-$GLIBC_VERSION.apk" \
&&  apk --no-cache add "glibc-bin-$GLIBC_VERSION.apk" \
&&  rm "glibc-bin-$GLIBC_VERSION.apk" \
&&  wget "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_VERSION/glibc-i18n-$GLIBC_VERSION.apk" \
&&  apk --no-cache add "glibc-i18n-$GLIBC_VERSION.apk" \
&&  rm "glibc-i18n-$GLIBC_VERSION.apk"


RUN apk add --update git wget ca-certificates && \
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
RUN hugo -v -s /site -d /site/public

FROM nginx:alpine
COPY config/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /site/public /usr/share/nginx/html
```

## End result
It's a bit meta that the inaugural post of my blog is about my blog itself. If you're intersted in building something similar, you'll find my blog source, including all configurations on [Github](https://github.com/kkr16/blog).

/kr
