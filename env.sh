# ==============================================================================
# env
# ==============================================================================
# Usage: `source env.sh`
project_name='auth-platform'

if [ -n "$ZSH_VERSION" ]; then
  autoload -Uz colors
  colors
  RPROMPT="[%{${fg_bold[magenta]}%}$project_name%{${reset_color}%}]"
elif [ -n "$BASH_VERSION" ]; then
  prefix="(\[\e[35m\]$project_name\[\e[0m\])"
  PS1="$prefix $PS1"
fi

if command -v docker &> /dev/null; then
  # aliases for host machine, not in docker container
  alias docker-compose="docker compose -p $project_name"
  alias build="docker-compose build"
  alias up="docker-compose up"
  alias stop="docker-compose stop"
  alias spring="rm -f tmp/pids/spring.pid tmp/pids/spring.sock && up spring"
  alias app="rm -f tmp/pids/server.pid && up app"
  alias rails="bundle exec rails"
  alias rake="bundle exec rake"
  alias seed_fu="rake db:seed_fu FIXTURE_PATH=db/seeds/development/"
  alias rspec="docker-compose run -e RAILS_ENV=test --rm app rspec"
  alias rubocop="bundle exec rubocop -DESP"
  alias lint="bundle exec rubocop -a"
  alias rubocop_show_class="bundle exec rubocop -D"
  alias guard="docker-compose run -e RAILS_ENV=test --rm app bundle exec guard"
  alias rswag="docker-compose run -e RAILS_ENV=test --rm app bundle exec rails rswag:specs:swaggerize"
  alias bun="docker-compose run --rm app bun"
  alias bunx="docker-compose run --rm app bunx"
  alias yarn="docker-compose run --rm app yarn"
  alias zekk="bundle exec zekk"
  alias tapioca="docker-compose run -e FORCE_TEST_DATABASE=true --rm app bin/tapioca"

  bundle() {
    docker compose -p $project_name run -e RAILS_ENV=${RAILS_ENV:=development} --rm app bundle $*
  }
fi

# json formatting and copy
function jpy {
  echo $1 | jq | pbcopy
}

npm() {
  echo "Don't use npm for this project. Use yarn instead."
}

export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
