# EventBridge イベント発行仕様

このドキュメントは AWS EventBridge へのイベント発行仕様を記述します。

## 概要

IDP システムで変更が発生した際、ユーザー関連のイベントが AWS EventBridge に発行されます。下流のコンシューマーはこれらのイベントを購読し、データ同期、通知、分析などの目的に利用できます。

## イベント構造

### EventBridge エンベロープ

| フィールド | 説明 | 例 |
|-----------|------|-----|
| `source` | イベント発生源の識別子 | `com.twogate.idp/{tenant_id}/users` |
| `detail-type` | バージョン付きイベントタイプ | `profile.changed.v1` |
| `detail` | イベントペイロード（JSON） | 下記参照 |
| `event-bus-name` | 送信先イベントバス | `Settings.aws.event_bus_name` で設定 |

### Source フォーマット

```
com.twogate.idp/{tenant_id}/users
```

- `com.twogate.idp` - 逆ドメイン記法（コーポレートドメイン + サービス名）
- `{tenant_id}` - テナント識別子
- `users` - リソースコレクション（全ユーザー関連イベントで共通）

### Detail Type フォーマット

```
{resource}.{action}.{version}
```

例：
- `user.signed_up.v1`
- `profile.changed.v1`
- `delivery_address.added.v1`

## イベント一覧

### User イベント

| detail-type | トリガー |
|-------------|---------|
| `user.signed_up.v1` | ユーザーがサインアップ完了 |
| `user.deleted.v1` | ユーザーアカウント削除 |

### Profile イベント

| detail-type | トリガー |
|-------------|---------|
| `profile.registered.v1` | 初回プロフィール登録 |
| `profile.changed.v1` | プロフィール情報変更 |

### Email イベント

| detail-type | トリガー |
|-------------|---------|
| `email.changed.v1` | メールアドレス変更 |

### ContactAddress イベント

| detail-type | トリガー |
|-------------|---------|
| `contact_address.registered.v1` | 初回連絡先住所登録 |
| `contact_address.changed.v1` | 連絡先住所変更 |

### DeliveryAddress イベント

| detail-type | トリガー |
|-------------|---------|
| `delivery_address.added.v1` | 配送先住所追加 |
| `delivery_address.changed.v1` | 配送先住所変更 |
| `delivery_address.removed.v1` | 配送先住所削除 |

## Detail ペイロード構造

すべてのペイロードで JSON キーは **snake_case** を使用します。

```json
{
  "event_data": {
    "id": "evt_xxxxxxxxxxxx",
    "occurred_at": "2025-12-19T10:30:00+09:00",
    "params": {
      // イベントのトリガーとなったパラメータ
    }
  },
  "resource": {
    // 変更後のリソース全体のスナップショット
  }
}
```

### フィールド説明

| フィールド | 説明 |
|-----------|------|
| `event_data.id` | イベントの一意識別子（冪等性担保用） |
| `event_data.occurred_at` | イベント発生時刻（ISO 8601、タイムゾーン付き） |
| `event_data.params` | イベントのトリガーとなったパラメータ |
| `resource` | 変更後のリソース全体のスナップショット |

## ペイロード例

### profile.changed.v1

```json
{
  "event_data": {
    "id": "evt_abc123def456",
    "occurred_at": "2025-12-19T10:30:00+09:00",
    "params": {
      "last_name": "鈴木",
      "last_name_kana": "スズキ"
    }
  },
  "resource": {
    "user_id": "usr_123456",
    "first_name": "太郎",
    "last_name": "鈴木",
    "first_name_kana": "タロウ",
    "last_name_kana": "スズキ",
    "birth_date": "1990-01-15",
    "gender": "male"
  }
}
```

### delivery_address.added.v1

```json
{
  "event_data": {
    "id": "evt_xyz789",
    "occurred_at": "2025-12-19T10:30:00+09:00",
    "params": {
      "zip_code": "100-0001",
      "prefecture_code": "13",
      "city": "千代田区",
      "street": "丸の内1-1-1",
      "building": "東京ビル 5F",
      "phone_number": "+819012345678",
      "country_code": "JP",
      "is_default": true
    }
  },
  "resource": {
    "id": "da_789",
    "user_id": "usr_123456",
    "zip_code": "100-0001",
    "prefecture_code": "13",
    "city": "千代田区",
    "street": "丸の内1-1-1",
    "building": "東京ビル 5F",
    "phone_number": "+819012345678",
    "country_code": "JP",
    "is_default": true
  }
}
```

## EventBridge ルール例

### 特定テナントの全イベントを購読

```json
{
  "source": ["com.twogate.idp/tenant_abc/users"]
}
```

### 全テナントのプロフィールイベントを購読

```json
{
  "source": [{ "wildcard": "com.twogate.idp/*/users" }],
  "detail-type": [{ "prefix": "profile." }]
}
```

### 特定のイベントタイプを購読

```json
{
  "detail-type": [
    "user.signed_up.v1",
    "user.deleted.v1"
  ]
}
```

## 設計方針

### 命名規則

| 項目 | 規則 |
|------|------|
| `source` | 逆ドメイン記法（`com.twogate.idp`） |
| `detail-type` | `{resource}.{action}.{version}`（snake_case） |
| `detail` 内の JSON キー | snake_case |
| `detail-type` のリソース名 | 単数形（例: `profile`、`profiles` ではない） |
| `source` のリソース名 | 複数形（例: `users`） |

### バージョニング

バージョンは `detail-type` に含まれます（例: `.v1`）。ペイロード構造に破壊的変更を加える場合は、バージョンをインクリメントします。

### 参考資料

- [CloudEvents Specification](https://github.com/cloudevents/spec)
- [AWS EventBridge Event Patterns](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-event-patterns.html)
