# ==============================================================================
# docker - local.Dockerfile
# ==============================================================================
# ruby:3.2.2-slim
FROM ruby@sha256:f96c440a4790350fd0b516d153d22e7492d1dea1c3469a4ccb08ac245ee40c91
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

# Expose assets for web container
VOLUME $APP_HOME/public/assets

# Run and own only the runtime files as a non-root user for security
RUN useradd rails --create-home --shell /bin/bash && \
    mkdir -p log tmp && chown -R rails:rails log tmp
USER rails:rails

EXPOSE 3000
CMD bundle exec rails server -b 0.0.0.0
