# back/Dockerfile
# syntax = docker/dockerfile:1

ARG RUBY_VERSION=3.2.2
FROM ruby:$RUBY_VERSION-slim as base

ARG RAILS_ENV=production
ARG BUNDLE_WITHOUT=development

WORKDIR /rails

ENV RAILS_ENV=$RAILS_ENV \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT=$BUNDLE_WITHOUT

FROM base as build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libvips pkg-config

# Gemfile をコピー
COPY Gemfile Gemfile.lock ./
RUN gem install bundler -v 2.6.3

# BUNDLE_WITHOUT に従い gem インストール
RUN bundle _2.6.3_ install
RUN bundle exec bootsnap precompile --gemfile

# アプリケーションコードをコピー
COPY . .

RUN bundle exec bootsnap precompile app/ lib/

FROM base
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libvips postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER rails:rails

ENTRYPOINT ["/rails/bin/docker-entrypoint"]
EXPOSE 3000
CMD ["./bin/rails", "server"]
