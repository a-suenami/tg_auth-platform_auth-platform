# ==============================================================================
# docker - Dockerfile
# ==============================================================================
# ruby:3.3.0-slim
FROM ruby@sha256:bbfce7fbb794e43b183411301b0c9386c1ba9640acead631651789572a5d3820
ENV LANG C.UTF-8

ARG BUNDLE_GIT__L__TWOGATE__NET
ARG BUNDLE_GEMS__CONTRIBSYS__COM

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

# アーキテクチャに応じた jemalloc の LD_PRELOAD
ARG TARGETARCH
RUN if [ "$TARGETARCH" = "amd64" ]; then \
        echo "using jemalloc for amd64 arch"; \
        export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2; \
    else \
        echo "using jemalloc for arm64 arch"; \
        export LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libjemalloc.so.2; \
    fi

# Prepare App
COPY . $APP_HOME

RUN bundle exec bootsnap precompile --gemfile app/ lib/

# Run and own only the runtime files as a non-root user for security
RUN useradd rails --create-home --shell /bin/bash && \
    mkdir -p log tmp && chown -R rails:rails log tmp
USER rails:rails

## Expose assets for web container
VOLUME $APP_HOME/public/packs

EXPOSE 3000
CMD bundle exec rails server -b 0.0.0.0
