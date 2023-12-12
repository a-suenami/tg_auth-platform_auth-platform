#!/bin/bash
source env.sh
if [ -f "dev.env" ]; then
    source dev.env
    # Check the value of USE_LOCAL_SORBET_LSP
    if [ "$USE_LOCAL_SORBET_LSP" = "1" ]; then
        use_local_sorbet='1'
    fi
fi

if [ "$use_local_sorbet" == "1" ]; then
    command bundle exec srb tc --lsp ${@:2}
else
    docker compose -p $project_name run --rm app bundle exec srb tc --lsp ${@:2}
fi
