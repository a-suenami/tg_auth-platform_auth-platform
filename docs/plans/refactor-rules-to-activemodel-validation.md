# ルールバリデーションをActiveModelに移行する計画

## 概要

現在、`UserAutoTagging::Rules` の各ルールクラスでは `self.validate_config(config)` というクラスメソッドで自前のバリデーションを実装している。これを `ActiveModel::Validations` を使った標準的なRailsのバリデーションパターンに移行する。

## 現状

### 現在の実装パターン

```ruby
class UserAutoTagging::Rules::MembershipRule < UserAutoTagging::Rules::AbstractRule
  sig { params(config: T::Hash[String, T.untyped]).returns(T::Array[String]) }
  def self.validate_config(config)
    errors = []
    values = config['values']
    unless values.is_a?(Array) && values.any?
      errors << I18n.t('auto_tagging.rules.errors.values_empty')
    end
    # ...
    errors
  end
end
```

### 問題点

- Railsの標準パターンから外れている
- `errors` 配列を手動で管理している
- バリデーションロジックが手続き的で再利用しにくい
- テストが複雑になりやすい

## 目標

### 移行後の実装パターン

```ruby
class UserAutoTagging::Rules::MembershipRule < UserAutoTagging::Rules::AbstractRule
  include ActiveModel::Validations

  attr_accessor :values

  validates :values, presence: true
  validate :values_must_be_valid_uuids

  def initialize(config)
    @values = config['values']
  end

  private

  def values_must_be_valid_uuids
    return unless values.is_a?(Array)

    unless values.all? { |v| v.is_a?(String) && v.present? }
      errors.add(:values, I18n.t('auto_tagging.rules.errors.membership_ids_invalid'))
    end
  end
end
```

## 実装計画

### Phase 1: AbstractRule の更新

1. `AbstractRule` に `ActiveModel::Validations` を include
2. `ActiveModel::Model` も include してコンストラクタのパターンを統一
3. 基底クラスにインターフェース用のメソッドを定義

```ruby
class UserAutoTagging::Rules::AbstractRule
  include ActiveModel::Model
  include ActiveModel::Validations

  # configからインスタンスを生成するファクトリメソッド
  def self.from_config(config)
    new(config)
  end

  # 互換性のため validate_config を維持（非推奨）
  def self.validate_config(config)
    instance = from_config(config)
    instance.valid?
    instance.errors.full_messages
  end
end
```

### Phase 2: 各ルールクラスの移行

対象ファイル（10ファイル）:
- [ ] `abstract_rule.rb`
- [ ] `membership_rule.rb`
- [ ] `membership_duration_rule.rb`
- [ ] `plan_rule.rb`
- [ ] `plan_duration_rule.rb`
- [ ] `age_rule.rb`
- [ ] `gender_rule.rb`
- [ ] `prefecture_rule.rb`
- [ ] `account_link_rule.rb`
- [ ] `rule_factory.rb`

#### 各ルールの移行内容

| ルール | attr_accessor | validates | カスタムバリデーション |
|--------|---------------|-----------|------------------------|
| MembershipRule | values | presence | UUIDs形式チェック |
| MembershipDurationRule | values, duration_value, duration_unit | presence | UUIDs形式、duration_unit inclusion |
| PlanRule | values | presence | UUIDs形式チェック |
| PlanDurationRule | values, duration_value, duration_unit | presence | UUIDs形式、duration_unit inclusion |
| AgeRule | min, max | - | min/max整数チェック、範囲チェック、少なくとも1つ必須 |
| GenderRule | values | presence | male/female のみ許可 |
| PrefectureRule | values | presence | 都道府県コード形式チェック |
| AccountLinkRule | value | presence | LINE のみ許可 |

### Phase 3: RuleFactory の更新

```ruby
class UserAutoTagging::Rules::RuleFactory
  def self.validate(condition_type, config)
    rule = build(condition_type, config)
    return ["Unknown condition_type: #{condition_type}"] if rule.nil?

    rule.valid?
    rule.errors.full_messages
  end

  def self.build(condition_type, config)
    klass = rule_class_for(condition_type, config)
    klass&.from_config(config)
  end

  private

  def self.rule_class_for(condition_type, config)
    case condition_type
    when 'membership'
      config['subscription_type'] == 'duration' ? MembershipDurationRule : MembershipRule
    when 'plan'
      config['subscription_type'] == 'duration' ? PlanDurationRule : PlanRule
    when 'age' then AgeRule
    when 'prefecture' then PrefectureRule
    when 'gender' then GenderRule
    when 'account_link' then AccountLinkRule
    end
  end
end
```

### Phase 4: カスタムバリデータの抽出（オプション）

共通のバリデーションロジックをカスタムバリデータとして抽出:

```ruby
# app/validators/uuid_array_validator.rb
class UuidArrayValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value.is_a?(Array)

    unless value.all? { |v| v.is_a?(String) && v.present? }
      record.errors.add(attribute, options[:message] || :invalid)
    end
  end
end
```

### Phase 5: i18n キーの整理

ActiveModel の errors に合わせて i18n キーを整理:

```yaml
ja:
  activemodel:
    errors:
      models:
        user_auto_tagging/rules/membership_rule:
          attributes:
            values:
              blank: 値を選択してください
              invalid_uuids: 有効なメンバーシップIDを選択してください
```

## テスト計画

各ルールクラスに対して:

1. `valid?` が正しく動作すること
2. `errors.full_messages` が期待通りのエラーメッセージを返すこと
3. `from_config` が正しくインスタンスを生成すること
4. 既存の `validate_config` との互換性（移行期間中）

## 移行戦略

1. **段階的移行**: 1ファイルずつ移行し、各段階でテストを実行
2. **互換性維持**: `validate_config` クラスメソッドを deprecated として維持
3. **Feature flag**: 必要に応じてフラグで切り替え可能にする

## 注意点

- Sorbet の型定義との整合性を確認
- `ActiveModel::Model` を include すると `initialize` の挙動が変わる
- `subscription_type` による条件分岐（membership/plan）の扱い

## 参考リンク

- [Active Model Basics - Rails Guides](https://guides.rubyonrails.org/active_model_basics.html)
- [Active Model Validations](https://api.rubyonrails.org/classes/ActiveModel/Validations.html)
