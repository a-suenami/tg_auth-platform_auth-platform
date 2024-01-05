# ==============================================================================
# docker - scripts - apt install
# ==============================================================================
apt-get update -qq && \
  apt-get install -y \
    build-essential \
    libpq-dev \
    tzdata \
    less \
    libsodium-dev \
    git \
    curl \
    libjemalloc2
