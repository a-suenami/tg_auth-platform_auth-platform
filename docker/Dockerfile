# ==============================================================================
# docker - Dockerfile
# ==============================================================================
# ruby:3.2.2-slim
FROM ruby@sha256:f96c440a4790350fd0b516d153d22e7492d1dea1c3469a4ccb08ac245ee40c91
ENV LANG C.UTF-8

ARG BUNDLE_GIT__L__TWOGATE__NET
ENV RAILS_ENV production

ENV APP_HOME /rails_app
WORKDIR $APP_HOME

# Install gems
ENV DEBCONF_NOWARNINGS yes
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE DontWarn
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
COPY docker/scripts/bundle_install.sh scripts/bundle_install.sh
COPY docker/scripts/apt_install.sh scripts/apt_install.sh
#COPY vendor/bundle vendor/bundle
RUN /bin/sh scripts/apt_install.sh && \
  /bin/sh scripts/bundle_install.sh && \
  rm -rf /usr/local/bundle/cache && \
  bundle clean && \
  rm -rf ./vendor/bundle/ruby/3.0.0/cache && \
  apt-get purge -y build-essential libpq-dev git curl && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
  truncate -s 0 /var/log/*log

# Prepare App
COPY . $APP_HOME

## Expose assets for web container
VOLUME $APP_HOME/public/packs

EXPOSE 3000
CMD bundle exec rails server -b 0.0.0.0
