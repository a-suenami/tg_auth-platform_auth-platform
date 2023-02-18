# ==============================================================================
# docker - local.Dockerfile
# ==============================================================================
# ruby:3.2.1-slim
FROM ruby@sha256:2f8600dda5efef63d5f44e21f029b6694d536498eca30d9fe8c110f68b7d4adf
ENV LANG C.UTF-8

ENV APP_HOME /rails_app
WORKDIR $APP_HOME

ENV DEBCONF_NOWARNINGS yes
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE DontWarn
# 使用する Node.js のメジャーバージョンを指定
ENV NODE_MAJOR 18

# Install apk package
COPY docker/scripts/apt_install.local.sh scripts/apt_install.local.sh
RUN /bin/sh scripts/apt_install.local.sh

# Prepare App
COPY . $APP_HOME

# Expose assets for web container
VOLUME $APP_HOME/public/assets

EXPOSE 3000
CMD bundle exec rails server -b 0.0.0.0
