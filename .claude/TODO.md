# TODO

## S3/minio 対応の改善

### 現状の問題

`S3::Uploader` で、ローカル開発環境（minio）と本番環境（AWS S3）の認証情報の切り替えに問題がある。

- `config/settings/development.secrets.yml` に AWS 認証情報がハードコードされている
- `Settings.aws.access_key_id` が ENV 変数より優先されてしまう
- 現状は `AWS_S3_ENDPOINT` の有無で分岐して、ローカル環境では ENV 変数を直接参照するワークアラウンドを実装

### 修正箇所

`app/lib/s3/uploader.rb`:
```ruby
# ローカル開発環境（minio）の場合はENV変数を直接使用
if ENV['AWS_S3_ENDPOINT'].present?
  # ENV変数から直接取得
else
  # Settings.aws から取得
end
```

### 検討事項

1. `development.secrets.yml` から AWS 認証情報を削除し、ENV 変数に統一する
2. または Settings gem の設定ファイル読み込み順序を見直す
3. S3::Uploader の認証情報取得ロジックをより明確にする

### 関連ファイル

- `app/lib/s3/uploader.rb`
- `config/settings.yml`
- `config/settings/development.secrets.yml`
- `docker-compose.yml` (minio 設定)
