# This should be removed in favor of the base-ruby:3.14. Will have a follow up story for getting that pipeline working
ARG BASE_RUBY_IMAGE_TAG="3.0.4-alpine3.16"
ARG NODE_VERSION="16.20.0-r0"
ARG FFMPEG_LIBS_VERSION="5.0.3-r0"
ARG IMAGE_ENV="production"
ARG UID="502"
ARG USER="app"
ARG USERHOME="/home/app"

FROM ruby:${BASE_RUBY_IMAGE_TAG} as base
ARG NODE_VERSION
ARG FFMPEG_LIBS_VERSION
ARG USER
ARG UID
ARG USERHOME
ENV USERHOME=$USERHOME

RUN apk add --no-cache \
    # Required for container healthcheck
    curl \
    # nokogiri on M1
    gcompat \
    # Required for typhoeus gem
    libcurl \
    # Required for connecting to postgres
    postgresql-dev \
    # Required for pg_dump when using rails migrations locally
    postgresql-client \
    # Required for redis-cli
    redis \
    # Node
    nodejs=${NODE_VERSION} \
    libxml2 \
    && adduser \
    --disabled-password \
    --gecos "" \
    --home ${USERHOME} \
    --uid "${UID}" \
    "${USER}"

FROM base as build_tools
ARG FFMPEG_LIBS_VERSION
RUN apk add --no-cache \
    build-base \
    tzdata \
    yarn \
    chromium \
    chromium-chromedriver \
    ffmpeg-libs=${FFMPEG_LIBS_VERSION} \
    # For pry to page long results
    less \
    && gem install bundler