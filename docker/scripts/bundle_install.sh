# ==============================================================================
# docker - scripts - bundle install
# ==============================================================================
nproc=$(which nproc > /dev/null && nproc || 1)

case "$RAILS_ENV" in
  "development" )
    bundle config set without 'production'
    bundle install --jobs="$nproc";;
  "test" )
    bundle config set clean 'true'
    bundle config set deployment 'true'
    bundle config set without 'development'
    bundle install --jobs="$nproc";;
  "production" )
    bundle config set clean 'true'
    bundle config set deployment 'true'
    bundle config set without 'development test'
    bundle install --jobs="$nproc";;
esac
