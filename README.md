# 開発環境動かすまで

Docker および Docker Compose V2 が必要

- https://docs.docker.com/engine/
- https://docs.docker.com/compose/install/

```sh
source env.sh
build
bundle install
yarn install
bundle exec thor credentials:decrypt # パスワードを聞かれるので入力する。パスワードについては PM に確認
rake db:create ridgepole:apply db:seed db:seed_fu
```


# 起動
以下はシェルを起動したら初めに

```sh
source env.sh
```

をしてから行うこと。


## Spring server

シェルを1つ用意して

```sh
spring
```

と打ち込んで放置する。これで spring server が立ち上がり続ける。
基本的に spring server は常に起動しておく。
そうでないと rails console などが使えなくなる。


## Rails

別のシェルを用意して

```sh
app
```

とする。再起動する場合は `ctrl+c` で停止できる。うまく停止できなかったときは

```sh
stop app
app
```

で再起動する。


## Webpacker

以下のコマンドで webpack の dev server が立ち上がり、Hot Module Replacement が利用できる。

```sh
up webpack-dev-server
```


## Rails console

こちらも別のシェルを用意して

```sh
rails c
```

でOK。


## Worker (Sidekiq)

こちらも別のシェルを用意して

```sh
up worker
```

でOK。


# Seed

```sh
# 基本
rake db:seed_fu
```


# テスト / Rubocop

```sh
# テスト環境の DB 更新（初回とその後必要に応じて）
rake db:create db:structure:load RAILS_ENV=test
# DBを再更新する場合、その前にテスト環境DBをdropする必要がある（structure.sqlにはforce optionがないため）
rake db:drop RAILS_ENV=test
# テスト実行
rspec
# 特定のテストだけを実行する場合
rspec spec/path/to/sepc.rb
# 行を指定することもできる
rspec spec/path/to/sepc.rb:33

# Rubocop
rubocop
```
