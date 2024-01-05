#!/bin/sh

# This is a script to enable graceful shutdown for sidekiq
# https://aws.amazon.com/jp/blogs/news/graceful-shutdowns-with-ecs/
# https://github.com/sidekiq/sidekiq/wiki/Deployment

## Sigterm Handler
sigterm_handler() {
  if [ $pid -ne 0 ]; then
    # the above if statement is important because it ensures
    # that the application has already started. without it you
    # could attempt cleanup steps if the application failed to
    # start, causing errors.

    echo "Got TERM. Sending TSTP to pid $pid"
    # send TSTP signal for graceful shutdown
    kill -TSTP "$pid"

    echo "Waiting for 80 seconds."
    # this should be lower than [ECS container definition stopTimeout]-([sidekiq's timeout option]+5)
    # like 120-(25+5)=90; 80 is safe enough
    sleep 80

    echo "Sending TERM"
    kill -TERM "$pid"

    echo "Waiting for the process to exit."

    wait "$pid"
  fi
  exit 143; # 128 + 15 -- SIGTERM
}

## Setup signal trap
# on callback execute the specified handler
trap 'sigterm_handler' SIGTERM

## Start Process
# run process in background and record PID
echo "--- sidekiq-entrypoint ---"
echo "Starting: $@"
"$@" &
pid="$!"

## Wait forever until app dies
wait "$pid"
return_code="$?"

# echo the return code of the application
exit $return_code
