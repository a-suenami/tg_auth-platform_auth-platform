# ==============================================================================
# docker - scripts - apt install.local
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
    gnupg2 \
    lsb-release \
    unzip \

# pg_dump for pg15 のインストール
curl -sS https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

apt-get update -qq && \
  apt-get install -y \
    postgresql-client-15 \

# Node.js と Yarn のインストール
curl -sL https://deb.nodesource.com/setup_$NODE_MAJOR.x | bash -
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo 'deb http://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list

apt-get update -qq && \
  apt-get install -y \
    nodejs \
    yarn \

cd $(mktemp -d) && \
curl -sSL -o dl-watchman.zip https://github.com/facebook/watchman/releases/download/v2023.02.27.00/watchman-v2023.02.27.00-linux.zip && \
unzip dl-watchman.zip && \
cd watchman* && \
mkdir -p /usr/local/{bin,lib} /usr/local/var/run/watchman && \
cp bin/* /usr/local/bin && \
cp lib/* /usr/local/lib && \
chmod 755 /usr/local/bin/watchman && \
chmod 2777 /usr/local/var/run/watchman
