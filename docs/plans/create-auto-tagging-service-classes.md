# Auto Taggingサービスクラス作成計画

## 概要

現在、Auto Tagging関連のDB操作はコントローラ内で直接ActiveRecordを呼び出している。これをサービスクラスに抽出することで、ビジネスロジックの分離、テスタビリティの向上、トランザクション管理の一元化を実現する。

## 現状の問題点

### 1. コントローラの責務過多

```ruby
# UserAutoTaggingsController#create
@user_auto_tagging = UserAutoTagging.new(user_auto_tagging_params)
@user_auto_tagging.created_by = current_admin
@user_auto_tagging.save
```

- ビジネスロジックがコントローラに埋め込まれている
- 再利用が困難
- テストが複雑になりやすい

### 2. トランザクション管理の欠如

- UserAutoTagging の create/update/delete にトランザクションがない
- UserTag の CRUD にトランザクションがない
- nested attributes による複数レコード操作が非原子的

### 3. イベント記録の不統一

- `UserTagAssignmentsController#update` ではイベント記録あり
- その他の操作ではイベント記録なし
- 監査証跡が不完全

### 4. エラーハンドリングの分散

- 各コントローラで個別にエラーハンドリング
- 一貫性のないエラーレスポンス

## 目標

1. ビジネスロジックをサービスクラスに分離
2. 全ての書き込み操作をトランザクションで保護
3. 必要な操作にイベント記録を追加
4. 一貫したResult/Responseパターンの導入
5. テスタビリティの向上

## 設計方針

### サービスクラスの基本パターン

```ruby
module UserAutoTagging
  class CreateService
    include Callable

    def initialize(params:, admin:)
      @params = params
      @admin = admin
    end

    def call
      ActiveRecord::Base.transaction do
        # ビジネスロジック
      end

      Success(user_auto_tagging)
    rescue ActiveRecord::RecordInvalid => e
      Failure(e.record.errors)
    end
  end
end
```

### Resultパターン

既存のプロジェクトパターンに従う、または以下のシンプルなパターンを採用：

```ruby
# 成功
{ success: true, data: user_auto_tagging }

# 失敗
{ success: false, errors: errors }
```

## 実装計画

### Phase 1: UserAutoTagging CRUD サービス

#### 1.1 CreateService

**ファイル**: `app/services/user_auto_tagging/create_service.rb`

**責務**:
- UserAutoTagging の作成
- 関連する RuleBlock, Rule, AutoTaggingSchedule, UserAutoTaggingTag の作成
- created_by の設定
- トランザクション管理

**入力**:
```ruby
{
  name: String,
  description: String (optional),
  enabled: Boolean,
  shareable: Boolean,
  schedule_attributes: { start_at:, end_at: },
  rule_blocks_attributes: [
    { position:, rules_attributes: [...] }
  ],
  user_tag_ids: [UUID]
}
```

**出力**:
- 成功: `{ success: true, user_auto_tagging: UserAutoTagging }`
- 失敗: `{ success: false, errors: ActiveModel::Errors }`

#### 1.2 UpdateService

**ファイル**: `app/services/user_auto_tagging/update_service.rb`

**責務**:
- UserAutoTagging の更新
- nested attributes による関連レコードの更新/削除
- updated_by の設定
- トランザクション管理

#### 1.3 DestroyService

**ファイル**: `app/services/user_auto_tagging/destroy_service.rb`

**責務**:
- UserAutoTagging の削除
- 関連レコードのカスケード削除確認
- トランザクション管理

### Phase 2: UserTag CRUD サービス

#### 2.1 CreateService

**ファイル**: `app/services/user_tag/create_service.rb`

**責務**:
- UserTag の作成
- created_by の設定
- 名前の重複チェック（case-insensitive）

#### 2.2 UpdateService

**ファイル**: `app/services/user_tag/update_service.rb`

**責務**:
- UserTag の更新
- updated_by の設定

#### 2.3 DestroyService

**ファイル**: `app/services/user_tag/destroy_service.rb`

**責務**:
- UserTag の削除
- 関連する UserTagAssignment, UserAutoTaggingTag の確認
- 使用中のタグ削除防止（オプション）

### Phase 3: UserTagAssignment サービス（リファクタリング）

#### 3.1 BulkUpdateService

**ファイル**: `app/services/user_tag_assignment/bulk_update_service.rb`

**責務**:
- 既存の `UserTagAssignmentsController#update` ロジックを移行
- 手動タグの一括追加/削除
- UserEvent 記録
- トランザクション管理

### Phase 4: コントローラの更新

各コントローラをサービスクラスを使用するように更新：

```ruby
class AdminArea::UserAutoTaggingsController < AdminController
  def create
    result = UserAutoTagging::CreateService.call(
      params: user_auto_tagging_params,
      admin: current_admin
    )

    if result[:success]
      redirect_to admin_user_auto_taggings_path, notice: '作成しました'
    else
      @user_auto_tagging = result[:user_auto_tagging]
      render :new, status: :unprocessable_entity
    end
  end
end
```

## ディレクトリ構造

```
app/services/
├── user_auto_tagging/
│   ├── create_service.rb
│   ├── update_service.rb
│   └── destroy_service.rb
├── user_tag/
│   ├── create_service.rb
│   ├── update_service.rb
│   └── destroy_service.rb
└── user_tag_assignment/
    └── bulk_update_service.rb
```

## 各サービスクラスの実装詳細

### UserAutoTagging::CreateService

```ruby
# typed: strict
# frozen_string_literal: true

module UserAutoTagging
  class CreateService
    extend T::Sig

    sig { params(params: T::Hash[Symbol, T.untyped], admin: Admin).void }
    def initialize(params:, admin:)
      @params = params
      @admin = admin
    end

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def call
      user_auto_tagging = nil

      ActiveRecord::Base.transaction do
        user_auto_tagging = ::UserAutoTagging.new(@params)
        user_auto_tagging.created_by = @admin
        user_auto_tagging.save!
      end

      { success: true, user_auto_tagging: user_auto_tagging }
    rescue ActiveRecord::RecordInvalid => e
      { success: false, user_auto_tagging: e.record, errors: e.record.errors }
    end

    sig { params(params: T::Hash[Symbol, T.untyped], admin: Admin).returns(T::Hash[Symbol, T.untyped]) }
    def self.call(params:, admin:)
      new(params: params, admin: admin).call
    end
  end
end
```

### UserAutoTagging::UpdateService

```ruby
# typed: strict
# frozen_string_literal: true

module UserAutoTagging
  class UpdateService
    extend T::Sig

    sig { params(user_auto_tagging: ::UserAutoTagging, params: T::Hash[Symbol, T.untyped], admin: Admin).void }
    def initialize(user_auto_tagging:, params:, admin:)
      @user_auto_tagging = user_auto_tagging
      @params = params
      @admin = admin
    end

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def call
      ActiveRecord::Base.transaction do
        @user_auto_tagging.updated_by = @admin
        @user_auto_tagging.update!(@params)
      end

      { success: true, user_auto_tagging: @user_auto_tagging }
    rescue ActiveRecord::RecordInvalid => e
      { success: false, user_auto_tagging: e.record, errors: e.record.errors }
    end

    sig do
      params(
        user_auto_tagging: ::UserAutoTagging,
        params: T::Hash[Symbol, T.untyped],
        admin: Admin
      ).returns(T::Hash[Symbol, T.untyped])
    end
    def self.call(user_auto_tagging:, params:, admin:)
      new(user_auto_tagging: user_auto_tagging, params: params, admin: admin).call
    end
  end
end
```

### UserAutoTagging::DestroyService

```ruby
# typed: strict
# frozen_string_literal: true

module UserAutoTagging
  class DestroyService
    extend T::Sig

    sig { params(user_auto_tagging: ::UserAutoTagging).void }
    def initialize(user_auto_tagging:)
      @user_auto_tagging = user_auto_tagging
    end

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def call
      ActiveRecord::Base.transaction do
        @user_auto_tagging.destroy!
      end

      { success: true }
    rescue ActiveRecord::RecordNotDestroyed => e
      { success: false, errors: e.record.errors }
    end

    sig { params(user_auto_tagging: ::UserAutoTagging).returns(T::Hash[Symbol, T.untyped]) }
    def self.call(user_auto_tagging:)
      new(user_auto_tagging: user_auto_tagging).call
    end
  end
end
```

## テスト計画

各サービスクラスに対してRSpecテストを作成：

```
spec/services/
├── user_auto_tagging/
│   ├── create_service_spec.rb
│   ├── update_service_spec.rb
│   └── destroy_service_spec.rb
├── user_tag/
│   ├── create_service_spec.rb
│   ├── update_service_spec.rb
│   └── destroy_service_spec.rb
└── user_tag_assignment/
    └── bulk_update_service_spec.rb
```

### テストケース例

```ruby
RSpec.describe UserAutoTagging::CreateService do
  describe '.call' do
    context '有効なパラメータの場合' do
      it 'UserAutoTaggingを作成する'
      it 'created_byを設定する'
      it '関連するRuleBlockを作成する'
      it '関連するRuleを作成する'
      it 'success: trueを返す'
    end

    context '無効なパラメータの場合' do
      it 'success: falseを返す'
      it 'errorsを含む'
      it 'レコードが作成されない'
    end

    context 'nested attributesでエラーが発生した場合' do
      it 'トランザクションがロールバックされる'
    end
  end
end
```

## 移行手順

1. **Phase 1**: サービスクラスの実装（テスト含む）
2. **Phase 2**: コントローラの更新（1つずつ）
3. **Phase 3**: 動作確認・リグレッションテスト
4. **Phase 4**: 不要なコードの削除

## 注意点

- 既存のAPIインターフェースは変更しない
- nested attributes の動作は維持する
- エラーメッセージの形式を変更しない
- Sorbet の型定義を追加する

## 将来の拡張

- イベント記録の追加（UserAutoTagging作成/更新/削除時）
- 非同期処理への対応（Auto tagging実行など）
- バッチ処理用サービスの追加
- API用サービスの追加（内部管理画面とAPI用で分離が必要な場合）

## 参考

- 既存の良い実装例: `UserTagAssignmentsController#update`（トランザクション + イベント記録）
- Rails Service Object パターン
- ActiveModel::Model を使ったForm Object パターン（将来の検討）
