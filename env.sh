# ==============================================================================
# env
# ==============================================================================
# Usage: `source env.sh`
project_name='triple'
alias docker-compose="docker compose -p $project_name"
alias build="docker-compose build"
alias up="docker-compose up"
alias stop="docker-compose stop"
alias spring="rm -f tmp/pids/spring.pid tmp/pids/spring.sock && up spring"
alias app="rm -f tmp/pids/server.pid && up app"
# alias bundle="docker-compose run -e RAILS_ENV=development --rm app bundle"
alias rails="docker-compose run -e RAILS_ENV=development --rm app bundle exec rails"
alias rake="docker-compose run -e RAILS_ENV=development --rm app bundle exec rake"
alias seed_fu="rake db:seed_fu FIXTURE_PATH=db/seeds/development/"
alias rspec="docker-compose run -e RAILS_ENV=test --rm spring spring rspec"
alias rubocop="docker-compose run -e RAILS_ENV=development --rm app bundle exec rubocop -DESP"
alias lint="docker-compose run -e RAILS_ENV=development --rm app bundle exec rubocop -a"
alias rubocop_show_class="docker-compose run -e RAILS_ENV=development --rm app bundle exec rubocop -D"
alias guard="docker-compose run -e RAILS_ENV=test --rm app bundle exec guard"
alias rswag="docker-compose run -e RAILS_ENV=test --rm app bundle exec rails rswag:specs:swaggerize"
alias yarn="docker-compose run -e RAILS_ENV=development --rm app yarn"
alias zekk="docker-compose run -e RAILS_ENV=development --rm app bundle exec zekk"

bundle() {
  docker-compose run -e RAILS_ENV=${RAILS_ENV:=development} --rm app bundle $*
}

# json formatting and copy
function jpy {
  echo $1 | jq | pbcopy
}

if [ -n "$ZSH_VERSION" ]; then
 autoload -Uz colors
 colors
 RPROMPT="[%{${fg_bold[magenta]}%}$project_name%{${reset_color}%}]"
elif [ -n "$BASH_VERSION" ]; then
 prefix="(\[\e[35m\]$project_name\[\e[0m\])"
 PS1="$prefix $PS1"
fi

export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# if executed directly, the command is executed according to its arguments.
# Usage: `bash env.sh bundle install`
case "$1" in
  "bundle" ) docker compose -p $project_name run -e RAILS_ENV=development --rm app bundle ${@:2} ;;
esac
