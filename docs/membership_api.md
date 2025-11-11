# メンバーシップAPI ドキュメント(仮置き)

ex: baseurl

- [https://account.stg.haguruma.io](https://account.stg.haguruma.io/api/v1/public/memberships)

# メンバーシップAPI仕様書

## 目次

1. [概要](https://www.notion.so/API-29aa41a3cf9b80a4ae00e11dcc387669?pvs=21)
2. [認証](https://www.notion.so/API-29aa41a3cf9b80a4ae00e11dcc387669?pvs=21)
3. [エンドポイント一覧](https://www.notion.so/API-29aa41a3cf9b80a4ae00e11dcc387669?pvs=21)
4. [詳細仕様](https://www.notion.so/API-29aa41a3cf9b80a4ae00e11dcc387669?pvs=21)

---

## 概要

本APIは、メンバーシッププランの表示、契約、管理を行うためのエンドポイントを提供します。

**公開APIベースURL**: `/api/v1/public`**認証必須APIベースURL**: `/api/v1/internal`

**認証**: `/api/v1/internal`以下のエンドポイントは認証が必要です。AuthorizationヘッダーにJWTトークンを設定してください。

---

## 認証

認証が必要なすべてのリクエストには以下のヘッダーが必要です：

```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

```

---

## エンドポイント一覧

### 公開API（認証不要）

| メソッド | エンドポイント | 説明 |
| --- | --- | --- |
| GET | `/public/memberships` | メンバーシップ一覧取得 |
| GET | `/public/memberships/:id` | メンバーシップ詳細取得 |
| GET | `/public/membership_plans` | メンバーシッププラン一覧取得 |
| GET | `/public/membership_plans/:id` | メンバーシッププラン詳細取得 |
| GET | `/public/membership_groups` | メンバーシップグループ一覧取得 |
| GET | `/public/membership_groups/:id` | メンバーシップグループ詳細取得 |
| GET | `/public/tenant_stripe_account` | Stripe公開鍵取得 |

### 認証必須API（内部）

| メソッド | エンドポイント | 説明 |
| --- | --- | --- |
| GET | `/internal/me/card` | 登録済みカード取得 |
| POST | `/internal/me/card/setup_intent` | カード登録用のSetupIntent作成 |
| POST | `/internal/me/card/off_session_setup_intent` | オフセッションカード認証用のSetupIntent作成 |
| POST | `/internal/me/card` | カード情報の更新 |
| POST | `/internal/me/card/complete_off_session_card` | オフセッションカード認証完了 |
| DELETE | `/internal/me/card` | カード削除 |
| GET | `/internal/membership/contracts` | 契約一覧取得 |
| GET | `/internal/membership/contracts/:id` | 契約詳細取得 |
| POST | `/internal/membership/contracts/credit_card_payments` | クレジットカード決済での契約作成 |
| POST | `/internal/membership/contracts/credit_card_payments/bulk` | 複数プランの一括契約 |
| POST | `/internal/membership/contracts/credit_card_payments/:contract_id/complete` | 決済完了処理 |
| POST | `/internal/membership/contracts/:id/plan_change` | プラン変更 |
| POST | `/internal/membership/contracts/:id/cancel` | 契約キャンセル |

---

## 詳細仕様

### 公開API（認証不要）

### 1. メンバーシップ一覧取得

**エンドポイント**: `GET /api/v1/public/memberships`

**説明**: 利用可能なメンバーシップ一覧を取得します。

**クエリパラメータ**:

- `membership_id` (optional): メンバーシップIDで絞り込み
- `payment_type` (optional): 支払い方法で絞り込み（`credit_card`, `convenience`, etc.）

**リクエスト例**:

```
GET /api/v1/public/memberships?payment_type=credit_card

```

**レスポンス例** (200 OK):

```json
[
  {
    "id": "542c871e-b0f3-43ae-a2f3-022158fa54e5",
    "name": "Basic",
    "display_name": "段階的メンバーシップ ベーシック",
    "position": 1,
    "tier": 3,
    "membership_group": {
      "id": "fcf46391-fa56-4117-9786-010308f3153e",
      "name": "leveled_membership",
      "display_name": "段階的プラングループ",
      "position": 0
    },
    "membership_plans": [
      {
        "id": "3eb43056-cf30-43cd-82e7-00a754c68799",
        "name": "段階的プラン ベーシック 月額",
        "amount": 500,
        "recurrence": true,
        "recurring_interval_unit": "month",
        "recurring_interval_count": 1
      }
    ]
  }
]

```

---

### 2. メンバーシップ詳細取得

**エンドポイント**: `GET /api/v1/public/memberships/:id`

**説明**: 指定されたメンバーシップの詳細情報を取得します。

**パスパラメータ**:

- `id`: メンバーシップID（UUID）

**リクエスト例**:

```
GET /api/v1/public/memberships/542c871e-b0f3-43ae-a2f3-022158fa54e5

```

**レスポンス例** (200 OK):

```json
{
  "id": "542c871e-b0f3-43ae-a2f3-022158fa54e5",
  "name": "Basic",
  "display_name": "段階的メンバーシップ ベーシック",
  "position": 1,
  "tier": 3,
  "membership_group": {
    "id": "fcf46391-fa56-4117-9786-010308f3153e",
    "name": "leveled_membership",
    "display_name": "段階的プラングループ",
    "position": 0
  },
  "membership_plans": [
    {
      "id": "3eb43056-cf30-43cd-82e7-00a754c68799",
      "name": "段階的プラン ベーシック 月額",
      "amount": 500,
      "recurrence": true,
      "recurring_interval_unit": "month",
      "recurring_interval_count": 1,
      "plan_payment_methods": [
        {
          "payment_type": "credit_card"
        }
      ]
    }
  ]
}

```

---

### 3. メンバーシッププラン一覧取得

**エンドポイント**: `GET /api/v1/public/membership_plans`

**説明**: 利用可能なメンバーシッププラン一覧を取得します。

**クエリパラメータ**:

- `membership_id` (optional): メンバーシップIDで絞り込み
- `payment_type` (optional): 支払い方法で絞り込み

**リクエスト例**:

```
GET /api/v1/public/membership_plans?membership_id=542c871e-b0f3-43ae-a2f3-022158fa54e5

```

**レスポンス例** (200 OK):

```json
[
  {
    "id": "3eb43056-cf30-43cd-82e7-00a754c68799",
    "name": "段階的プラン ベーシック 月額",
    "amount": 500,
    "recurrence": true,
    "recurring_interval_unit": "month",
    "recurring_interval_count": 1,
    "billing_anchor": "by_start_day",
    "anchor_day_of_month": null,
    "is_active": true,
    "enabled_at": null,
    "disabled_at": null,
    "trial_period_days": 0,
    "position": 0,
    "created_at": "2025-10-24T08:19:00.000Z",
    "updated_at": "2025-10-24T08:19:00.000Z",
    "plan_payment_methods": [
      {
        "payment_type": "credit_card"
      }
    ],
    "memberships": [
      {
        "id": "542c871e-b0f3-43ae-a2f3-022158fa54e5",
        "name": "Basic",
        "display_name": "段階的メンバーシップ ベーシック",
        "position": 1,
        "tier": 3
      }
    ]
  }
]

```

---

### 4. メンバーシッププラン詳細取得

**エンドポイント**: `GET /api/v1/public/membership_plans/:id`

**説明**: 指定されたメンバーシッププランの詳細情報を取得します。

**パスパラメータ**:

- `id`: メンバーシッププランID（UUID）

**リクエスト例**:

```
GET /api/v1/public/membership_plans/3eb43056-cf30-43cd-82e7-00a754c68799

```

**レスポンス例** (200 OK):

```json
{
  "id": "3eb43056-cf30-43cd-82e7-00a754c68799",
  "name": "段階的プラン ベーシック 月額",
  "amount": 500,
  "recurrence": true,
  "recurring_interval_unit": "month",
  "recurring_interval_count": 1,
  "billing_anchor": "by_start_day",
  "anchor_day_of_month": null,
  "is_active": true,
  "enabled_at": null,
  "disabled_at": null,
  "trial_period_days": 0,
  "position": 0,
  "created_at": "2025-10-24T08:19:00.000Z",
  "updated_at": "2025-10-24T08:19:00.000Z",
  "plan_payment_methods": [
    {
      "payment_type": "credit_card"
    }
  ],
  "memberships": [
    {
      "id": "542c871e-b0f3-43ae-a2f3-022158fa54e5",
      "name": "Basic",
      "display_name": "段階的メンバーシップ ベーシック",
      "position": 1,
      "tier": 3
    }
  ]
}

```

---

### 5. メンバーシップグループ一覧取得

**エンドポイント**: `GET /api/v1/public/membership_groups`

**説明**: 利用可能なメンバーシップグループ一覧を取得します。

**リクエスト例**:

```
GET /api/v1/public/membership_groups

```

**レスポンス例** (200 OK):

```json
[
  {
    "id": "fcf46391-fa56-4117-9786-010308f3153e",
    "name": "leveled_membership",
    "display_name": "段階的プラングループ",
    "position": 0,
    "memberships": [
      {
        "id": "542c871e-b0f3-43ae-a2f3-022158fa54e5",
        "name": "Basic",
        "display_name": "段階的メンバーシップ ベーシック",
        "position": 1,
        "tier": 3
      }
    ]
  }
]

```

---

### 6. メンバーシップグループ詳細取得

**エンドポイント**: `GET /api/v1/public/membership_groups/:id`

**説明**: 指定されたメンバーシップグループの詳細情報を取得します。

**パスパラメータ**:

- `id`: メンバーシップグループID（UUID）

**リクエスト例**:

```
GET /api/v1/public/membership_groups/fcf46391-fa56-4117-9786-010308f3153e

```

**レスポンス例** (200 OK):

```json
{
  "id": "fcf46391-fa56-4117-9786-010308f3153e",
  "name": "leveled_membership",
  "display_name": "段階的プラングループ",
  "position": 0,
  "memberships": [
    {
      "id": "542c871e-b0f3-43ae-a2f3-022158fa54e5",
      "name": "Basic",
      "display_name": "段階的メンバーシップ ベーシック",
      "position": 1,
      "tier": 3
    }
  ]
}

```

---

### 6. Stripe公開鍵取得

**エンドポイント**: `GET /api/v1/public/tenant_stripe_account`

**説明**: テナントのStripe公開鍵（Publishable Key）を取得します。フロントエンドでStripeの決済フォームを初期化する際に使用します。

**リクエスト例**:

```
GET /api/v1/public/tenant_stripe_account

```

**レスポンス例** (200 OK):

```json
{
  "id": "02ff0a8c-9e4d-49f5-b52b-cc7d5a82e904",
  "tenant_id": "sample",
  "type": "Tenant::StripeAccount",
  "publishable_key": "pk_test_1234567890"
}
```

**エラーレスポンス例** (404 Not Found):

```json
{
  "error": {
    "code": "not_found",
    "message": "Not found"
  }
}
```

**注意**: `tenant_stripe_account` が存在しない場合、404エラーが返されます。

---

### 認証必須API（内部）

### 7. 登録済みカード取得

**エンドポイント**: `GET /api/v1/internal/me/card`

**説明**: 現在のユーザーに登録されているクレジットカード情報を取得します。

**リクエスト例**:

```
GET /api/v1/internal/me/card
Authorization: Bearer <TOKEN>

```

**レスポンス例** (200 OK):

```json
{
  "id": "243e92e6-a089-4836-95c9-a1da1190aec9",
  "remote_id": "pm_1SLha9LtOmpZVCAzUfcJbtMD",
  "type": "StripeRecord::PaymentMethod",
  "card": {
    "brand": "visa",
    "last4": "4242",
    "exp_month": 4,
    "exp_year": 2026,
    "funding": "credit",
    "country": "US"
  },
  "billing_details": {
    "name": null,
    "email": null,
    "phone": null,
    "address": {
      "city": null,
      "line1": null,
      "line2": null,
      "state": null,
      "country": null,
      "postal_code": "15556"
    }
  },
  "detached_at": null
}

```

---

### 8. カード登録用のSetupIntent作成

**エンドポイント**: `POST /api/v1/internal/me/card/setup_intent`

**説明**: カード登録に必要なSetupIntentを作成します。Stripe.jsを使用してカード情報を入力する際に使用します。

**リクエスト例**:

```
POST /api/v1/internal/me/card/setup_intent
Authorization: Bearer <TOKEN>

```

**レスポンス例** (201 Created):

```json
{
  "id": "setup-intent-uuid",
  "remote_id": "seti_xxx",
  "status": "requires_payment_method",
  "usage": "off_session",
  "client_secret": "seti_xxx_secret_xxx",
  "payment_method_id": null,
  "type": "StripeRecord::SetupIntent"
}

```

---

### 9. オフセッションカード認証用のSetupIntent作成

**エンドポイント**: `POST /api/v1/internal/me/card/off_session_setup_intent`

**説明**: 既に登録されているカードをオフセッションで再認証するためのSetupIntentを作成します。カードが登録されていない場合はエラーになります。

**リクエスト例**:

```
POST /api/v1/internal/me/card/off_session_setup_intent
Authorization: Bearer <TOKEN>

```

**レスポンス例** (201 Created):

```json
{
  "id": "setup-intent-uuid",
  "remote_id": "seti_xxx",
  "status": "requires_action",
  "usage": "off_session",
  "client_secret": "seti_xxx_secret_xxx",
  "payment_method_id": "pm_xxx",
  "type": "StripeRecord::SetupIntent"
}

```

**エラー例** (400 Bad Request):

```json
{
  "error": {
    "code": "card_missing",
    "message": "登録されているカードがありません"
  }
}

```

---

### 10. カード情報の更新

**エンドポイント**: `POST /api/v1/internal/me/card`

**説明**: SetupIntentで認証されたカードを登録します。

**リクエストボディ**:

```json
{
  "setup_intent_id": "seti_xxx"
}

```

**リクエスト例**:

```
POST /api/v1/internal/me/card
Authorization: Bearer <TOKEN>
Content-Type: application/json

{
  "setup_intent_id": "seti_xxx"
}

```

**レスポンス例** (200 OK):

```json
{
  "id": "243e92e6-a089-4836-95c9-a1da1190aec9",
  "remote_id": "pm_1SLha9LtOmpZVCAzUfcJbtMD",
  "type": "StripeRecord::PaymentMethod",
  "card": {
    "brand": "visa",
    "last4": "4242",
    "exp_month": 4,
    "exp_year": 2026
  },
  "billing_details": {...},
  "detached_at": null
}

```

---

### 11. オフセッションカード認証完了

**エンドポイント**: `POST /api/v1/internal/me/card/complete_off_session_card`

**説明**: オフセッションカード認証を完了します。

**リクエストボディ**:

```json
{
  "setup_intent_id": "seti_xxx"
}

```

**リクエスト例**:

```
POST /api/v1/internal/me/card/complete_off_session_card
Authorization: Bearer <TOKEN>
Content-Type: application/json

{
  "setup_intent_id": "seti_xxx"
}

```

**レスポンス例** (200 OK):

```json
{
  "id": "setup-intent-uuid",
  "remote_id": "seti_xxx",
  "status": "succeeded",
  "usage": "off_session",
  "client_secret": "seti_xxx_secret_xxx",
  "payment_method_id": "pm_xxx",
  "type": "StripeRecord::SetupIntent"
}

```

---

### 12. カード削除

**エンドポイント**: `DELETE /api/v1/internal/me/card`

**説明**: 登録されているクレジットカードを削除します。

**リクエスト例**:

```
DELETE /api/v1/internal/me/card
Authorization: Bearer <TOKEN>

```

**レスポンス例** (204 No Content):

```
HTTP/1.1 204 No Content

```

---

### 13. 契約一覧取得

**エンドポイント**: `GET /api/v1/internal/membership/contracts`

**説明**: 現在のユーザーの契約一覧を取得します。

**リクエスト例**:

```
GET /api/v1/internal/membership/contracts
Authorization: Bearer <TOKEN>

```

**レスポンス例** (200 OK):

```json
[
  {
    "id": "contract-uuid",
    "status": "active",
    "cancel_at_period_end": false,
    "expires_at": "2025-11-24T00:00:00.000Z",
    "created_at": "2025-10-24T00:00:00.000Z",
    "updated_at": "2025-10-24T00:00:00.000Z",
    "contract_terms": [
      {
        "id": "term-uuid",
        "membership_plan_id": "3eb43056-cf30-43cd-82e7-00a754c68799",
        "start_at": "2025-10-24T00:00:00.000Z",
        "end_at": null
      }
    ],
    "payment_transactions": [
      {
        "id": "transaction-uuid",
        "status": "succeeded",
        "chargeable_type": "StripeRecord::PaymentIntent",
        "chargeable_id": "payment-intent-uuid"
      }
    ],
    "payment_subscription": {
      "id": "subscription-uuid",
      "remote_id": "sub_xxx",
      "status": "active"
    }
  }
]

```

---

### 14. 契約詳細取得

**エンドポイント**: `GET /api/v1/internal/membership/contracts/:id`

**説明**: 指定された契約の詳細情報を取得します。

**パスパラメータ**:

- `id`: 契約ID（UUID）

**リクエスト例**:

```
GET /api/v1/internal/membership/contracts/contract-uuid
Authorization: Bearer <TOKEN>

```

**レスポンス例** (200 OK):

```json
{
  "id": "contract-uuid",
  "status": "active",
  "cancel_at_period_end": false,
  "expires_at": "2025-11-24T00:00:00.000Z",
  "created_at": "2025-10-24T00:00:00.000Z",
  "updated_at": "2025-10-24T00:00:00.000Z",
  "contract_terms": [
    {
      "id": "term-uuid",
      "membership_plan_id": "3eb43056-cf30-43cd-82e7-00a754c68799",
      "start_at": "2025-10-24T00:00:00.000Z",
      "end_at": null
    }
  ],
  "payment_transactions": [
    {
      "id": "transaction-uuid",
      "status": "succeeded",
      "chargeable_type": "StripeRecord::PaymentIntent",
      "chargeable_id": "payment-intent-uuid"
    }
  ],
  "payment_subscription": {
    "id": "subscription-uuid",
    "remote_id": "sub_xxx",
    "status": "active"
  }
}

```

---

### 15. クレジットカード決済での契約作成

**エンドポイント**: `POST /api/v1/internal/membership/contracts/credit_card_payments`

**説明**: 指定されたメンバーシッププランにクレジットカード決済で契約します。3Dセキュアが必要な場合があります。

**リクエストボディ**:

```json
{
  "memberships_contracts": {
    "membership_plan_id": "3eb43056-cf30-43cd-82e7-00a754c68799"
  }
}

```

**リクエスト例**:

```
POST /api/v1/internal/membership/contracts/credit_card_payments
Authorization: Bearer <TOKEN>
Content-Type: application/json

{
  "memberships_contracts": {
    "membership_plan_id": "3eb43056-cf30-43cd-82e7-00a754c68799"
  }
}

```

**レスポンス例** (201 Created):

```json
{
  "id": "contract-uuid",
  "status": "pending",
  "cancel_at_period_end": false,
  "expires_at": "2025-11-24T00:00:00.000Z",
  "created_at": "2025-10-24T00:00:00.000Z",
  "updated_at": "2025-10-24T00:00:00.000Z",
  "contract_terms": [
    {
      "id": "term-uuid",
      "membership_plan_id": "3eb43056-cf30-43cd-82e7-00a754c68799",
      "start_at": "2025-10-24T00:00:00.000Z",
      "end_at": null
    }
  ],
  "payment_transactions": [
    {
      "id": "transaction-uuid",
      "status": "requires_action",
      "chargeable_type": "StripeRecord::PaymentIntent",
      "chargeable_id": "payment-intent-uuid",
      "chargeable": {
        "id": "payment-intent-uuid",
        "client_secret": "pi_xxx_secret_xxx",
        "status": "requires_action"
      }
    }
  ],
  "payment_subscription": {
    "id": "subscription-uuid",
    "remote_id": "sub_xxx",
    "status": "incomplete"
  }
}

```

**ステータスコード**:

- `201 Created`: 契約が正常に作成されました（3Dセキュア不要）
- `402 Payment Required`: 3Dセキュアが必要です

**3Dセキュアが必要な場合**:
`payment_transactions[0].chargeable.client_secret`を使用して、3Dセキュア認証画面を表示する必要があります。

---

### 16. 複数プランの一括契約

**エンドポイント**: `POST /api/v1/internal/membership/contracts/credit_card_payments/bulk`

**説明**: 複数のメンバーシッププランを同時に契約します。すべてオフセッション前提です。

**リクエストボディ**:

```json
{
  "memberships_contracts": {
    "membership_plan_ids": [
      "3eb43056-cf30-43cd-82e7-00a754c68799",
      "0f29cb57-43f1-45f2-a68f-87b51ea6d60f"
    ]
  }
}

```

**リクエスト例**:

```
POST /api/v1/internal/membership/contracts/credit_card_payments/bulk
Authorization: Bearer <TOKEN>
Content-Type: application/json

{
  "memberships_contracts": {
    "membership_plan_ids": [
      "3eb43056-cf30-43cd-82e7-00a754c68799",
      "0f29cb57-43f1-45f2-a68f-87b51ea6d60f"
    ]
  }
}

```

**レスポンス例** (201 Created):

```json
[
  {
    "id": "contract-uuid-1",
    "status": "active",
    "cancel_at_period_end": false,
    "expires_at": "2025-11-24T00:00:00.000Z",
    "created_at": "2025-10-24T00:00:00.000Z",
    "updated_at": "2025-10-24T00:00:00.000Z",
    "contract_terms": [...]
  },
  {
    "id": "contract-uuid-2",
    "status": "active",
    "cancel_at_period_end": false,
    "expires_at": "2025-11-24T00:00:00.000Z",
    "created_at": "2025-10-24T00:00:00.000Z",
    "updated_at": "2025-10-24T00:00:00.000Z",
    "contract_terms": [...]
  }
]

```

---

### 17. 決済完了処理

**エンドポイント**: `POST /api/v1/internal/membership/contracts/credit_card_payments/:contract_id/complete`

**説明**: 決済が完了した後に契約を確定します（3Dセキュア完了後のコールバック想定）。

**パスパラメータ**:

- `contract_id`: 契約ID（UUID）

**リクエスト例**:

```
POST /api/v1/internal/membership/contracts/credit_card_payments/contract-uuid/complete
Authorization: Bearer <TOKEN>

```

**レスポンス例** (200 OK):

```json
{
  "id": "contract-uuid",
  "status": "active",
  "cancel_at_period_end": false,
  "expires_at": "2025-11-24T00:00:00.000Z",
  "created_at": "2025-10-24T00:00:00.000Z",
  "updated_at": "2025-10-24T00:00:00.000Z",
  "contract_terms": [...],
  "payment_transactions": [
    {
      "id": "transaction-uuid",
      "status": "succeeded",
      "chargeable_type": "StripeRecord::PaymentIntent",
      "chargeable_id": "payment-intent-uuid"
    }
  ],
  "payment_subscription": {
    "id": "subscription-uuid",
    "remote_id": "sub_xxx",
    "status": "active"
  }
}

```

**エラー例** (400 Bad Request):

```json
{
  "error": {
    "code": "payment_not_succeeded",
    "message": "決済が完了していません"
  }
}

```

---

### 18. プラン変更

**エンドポイント**: `POST /api/v1/internal/membership/contracts/:id/plan_change`

**説明**: 既存の契約を新しいプランに変更します。

**パスパラメータ**:

- `id`: 契約ID（UUID）

**リクエストボディ**:

```json
{
  "plan_change": {
    "membership_plan_id": "0f29cb57-43f1-45f2-a68f-87b51ea6d60f"
  }
}

```

**リクエスト例**:

```
POST /api/v1/internal/membership/contracts/contract-uuid/plan_change
Authorization: Bearer <TOKEN>
Content-Type: application/json

{
  "plan_change": {
    "membership_plan_id": "0f29cb57-43f1-45f2-a68f-87b51ea6d60f"
  }
}

```

**レスポンス例** (200 OK):

```json
{
  "id": "contract-uuid",
  "status": "active",
  "cancel_at_period_end": false,
  "expires_at": "2025-11-24T00:00:00.000Z",
  "created_at": "2025-10-24T00:00:00.000Z",
  "updated_at": "2025-10-24T00:00:00.000Z",
  "contract_terms": [...]
}

```

---

### 19. 契約キャンセル

**エンドポイント**: `POST /api/v1/internal/membership/contracts/:id/cancel`

**説明**: 既存の契約をキャンセルします（期間終了時に終了）。

**パスパラメータ**:

- `id`: 契約ID（UUID）

**リクエスト例**:

```
POST /api/v1/internal/membership/contracts/contract-uuid/cancel
Authorization: Bearer <TOKEN>

```

**レスポンス例** (200 OK):

```json
{
  "id": "contract-uuid",
  "status": "active",
  "cancel_at_period_end": true,
  "expires_at": "2025-11-24T00:00:00.000Z",
  "created_at": "2025-10-24T00:00:00.000Z",
  "updated_at": "2025-10-24T00:00:00.000Z",
  "contract_terms": [...]
}

```

---

## 共通エラー

### 400 Bad Request

```json
{
  "error": {
    "code": "stripe_error",
    "message": "Stripeエラーメッセージ"
  }
}

```

### 401 Unauthorized

認証が必要ですが、トークンが無効または期限切れです。

### 404 Not Found

指定されたリソースが見つかりませんでした。

### 422 Unprocessable Entity

```json
{
  "errors": {
    "field": ["エラーメッセージ"]
  }
}

```

---

## 契約のステータス

- `pending`: 契約作成中（決済待ち）
- `active`: 有効な契約
- `canceled`: キャンセル済み
- `expired`: 期限切れ

---

## 3Dセキュア対応

3Dセキュアが必要な場合、以下のフローで処理してください：

1. 契約作成APIを呼び出す
2. `payment_transactions[0].chargeable.client_secret`を取得
3. Stripe.jsを使用して3Dセキュア認証画面を表示
4. 認証完了後、決済完了APIを呼び出す

---

## 注意事項

- すべての日時はISO 8601形式（UTC）で返されます
- UUIDはすべてハイフン付きの形式です
- 金額は最小単位（例: 1円 = 1）で返されます
- すべてのリクエストにはContent-Type: application/jsonが必要です
