# ==============================================================================
# docker - local.Dockerfile
# ==============================================================================
# ruby:3.3.0-slim
FROM ruby@sha256:bbfce7fbb794e43b183411301b0c9386c1ba9640acead631651789572a5d3820

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
