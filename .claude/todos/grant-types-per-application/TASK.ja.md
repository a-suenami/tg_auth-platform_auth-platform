# タスク: アプリケーションごとの Grant Types 制御

## 概要

`oauth_applications` の `enable_client_credential_flow` ブール型カラムではなく、別テーブルを使用してアプリケーションごとの grant type 制御を実装する。

## 背景

現在、grant types は2つのレベルで制御されている：
1. **サーバーレベル**: `config/initializers/doorkeeper.rb` の `grant_flows`（静的）
2. **アプリケーションレベル**: `enable_client_credential_flow` フラグのみ（部分的な制御）

つまり、`authorization_code` と `implicit_oidc` は全アプリケーションで常に許可されており、アプリケーションごとに無効化する手段がない。

## 設計案

### 新規テーブル: `oauth_application_grant_types`

```ruby
create_table :oauth_application_grant_types do |t|
  t.citext :tenant_id, null: false
  t.uuid   :oauth_application_id, null: false
  t.string :grant_type, null: false  # 'authorization_code', 'client_credentials', 'implicit', 'refresh_token'
  t.timestamps
end

add_index :oauth_application_grant_types,
          [:tenant_id, :oauth_application_id, :grant_type],
          unique: true,
          name: 'idx_oauth_app_grant_types_unique'

add_foreign_key :oauth_application_grant_types, :oauth_applications
add_foreign_key :oauth_application_grant_types, :tenants
```

### モデル

```ruby
# app/models/oauth_application_grant_type.rb
class OauthApplicationGrantType < ApplicationRecord
  include Multitenancy

  belongs_to :oauth_application

  VALID_GRANT_TYPES = %w[
    authorization_code
    client_credentials
    implicit
    refresh_token
  ].freeze

  validates :grant_type, presence: true, inclusion: { in: VALID_GRANT_TYPES }
  validates :grant_type, uniqueness: { scope: [:tenant_id, :oauth_application_id] }
end
```

```ruby
# app/models/oauth_application.rb
class OauthApplication < ApplicationRecord
  has_many :oauth_application_grant_types, dependent: :destroy

  def grant_types
    oauth_application_grant_types.pluck(:grant_type)
  end

  def supports_grant_type?(grant_type)
    oauth_application_grant_types.exists?(grant_type: grant_type)
  end
end
```

### Doorkeeper 設定の更新

```ruby
# config/initializers/doorkeeper.rb
allow_grant_flow_for_client do |grant_flow, client|
  client.supports_grant_type?(grant_flow)
end
```

### バリデーションルール

```ruby
class OauthApplicationGrantType < ApplicationRecord
  validate :client_credentials_requires_confidential

  private

  def client_credentials_requires_confidential
    if grant_type == 'client_credentials' && !oauth_application.confidential?
      errors.add(:grant_type, "client_credentials は confidential クライアントでのみ使用可能です")
    end
  end
end
```

## マイグレーション戦略

### フェーズ1: 新規テーブル追加（破壊的変更なし）

1. `oauth_application_grant_types` テーブルを作成
2. モデルとアソシエーションを追加
3. `enable_client_credential_flow` カラムは維持（後方互換性）

### フェーズ2: データマイグレーション

```ruby
# 既存データのマイグレーション
OauthApplication.find_each do |app|
  # 全アプリが現在 authorization_code をサポート（現設計では暗黙的）
  app.oauth_application_grant_types.find_or_create_by!(
    tenant_id: app.tenant_id,
    grant_type: 'authorization_code'
  )

  # client_credentials フラグをマイグレーション
  if app.enable_client_credential_flow
    app.oauth_application_grant_types.find_or_create_by!(
      tenant_id: app.tenant_id,
      grant_type: 'client_credentials'
    )
  end
end
```

### フェーズ3: Doorkeeper 設定の切り替え

`allow_grant_flow_for_client` を新テーブルを使用するよう更新。

### フェーズ4: 古いカラムの削除

動作確認後、`enable_client_credential_flow` カラムを削除。

## メリット

1. **明示的な制御**: 各 grant type が明示的に有効化され、暗黙のデフォルトがない
2. **拡張性**: スキーマ変更なしで新しい grant type を追加可能
3. **クエリ可能**: SQL で grant type によるアプリケーション検索が可能
4. **一貫したパターン**: 提案済みの `oauth_application_field_rules` テーブル設計と一致

## 関連タスク

- [ ] `oauth_application_grant_types` テーブルのマイグレーション作成
- [ ] バリデーション付きモデルの作成
- [ ] `OauthApplication` モデルの更新
- [ ] Doorkeeper 設定の更新
- [ ] データマイグレーションの作成
- [ ] 管理画面 UI の更新
- [ ] `enable_client_credential_flow` カラムの削除

## 関連ドキュメント

- `docs/spec/oauth_application_types.md` - OAuth アプリケーションタイプの仕様
- `docs/spec/oauth_application_types.ja.md` - OAuth アプリケーションタイプの仕様（日本語）
