# ==============================================================================
# docker - scripts - apt install.local
# ==============================================================================
apt-get update -qq && \
  apt-get install -y \
    build-essential \
    libpq-dev \
    postgresql-client \
    tzdata \
    less \
    libsodium-dev \
    git \
    curl \

# Node.js と Yarn のインストール
curl -sL https://deb.nodesource.com/setup_$NODE_MAJOR.x | bash -
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo 'deb http://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list

apt-get update -qq && \
  apt-get install -y \
    nodejs \
    yarn \
