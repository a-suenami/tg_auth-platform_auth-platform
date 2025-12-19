# ADR: EventBridge イベント形式の設計

- **日付**: 2025-12-19
- **ステータス**: 承認済み
- **決定者**: Akira Suenami

## コンテキスト

EventBridge に発行するイベントの形式を設計する必要がある。EventBridge のイベントは以下のフィールドを持つ：

- `source`: イベント発生源の識別子
- `detail-type`: イベントの種類
- `detail`: イベントペイロード（JSON）

これらのフィールドの命名規則や構造を決定する必要がある。

## 決定

### 1. source 形式

```
com.twogate.idp/{tenant_id}/users
```

- 逆ドメイン記法でコーポレートドメイン `com.twogate` を使用
- サービス名 `idp` を付加
- テナント ID とリソース名をパスとして含める

### 2. detail-type 形式

```
{resource}.{action}.{version}
```

例: `profile.changed.v1`, `delivery_address.added.v1`

- リソース名は単数形（`profile`, `contact_address`, `delivery_address`）
- アクションは過去形（`signed_up`, `changed`, `added`, `removed` など）
- バージョンはサフィックスとして付加（`.v1`）

※ 具体的なイベント名は別途決定する。

### 3. detail ペイロード構造

```json
{
  "event_data": {
    "id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "occurred_at": "2025-12-19T10:30:00+09:00",
    "params": { ... }
  },
  "resource": { ... }
}
```

- `event_data`: イベントメタデータとトリガーパラメータ
- `resource`: 変更後のリソース全体のスナップショット

### 4. JSON キー命名規則

すべて snake_case を使用する。

## 理由

### source にテナント ID を含める理由

- `source` と `detail-type` のどちらに含めるか検討した
- EventBridge はワイルドカードによるフィルタリングをサポートしている
- 全テナントのイベントを受け取る場合は `com.twogate.idp/*/users` でフィルタ可能
- 特定テナントのイベントのみ受け取る場合は source で直接指定できる
- コンシューマの多くは社内プロダクトであり、この方式が都合がよい

### コーポレートドメイン com.twogate を使用する理由

- 当初は `net.id-platform` を検討した
- しかし、サービス名（idp）は将来変更される可能性がある
- コーポレートドメイン `com.twogate` は安定しており、変更の可能性が低い
- サービス名が変更されても、コンシューマ側で `com.twogate.*` のワイルドカードで対応可能

### snake_case を使用する理由

- AWS のイベント形式には統一された命名規則がない（EventBridge 標準フィールドは kebab-case、各サービスはバラバラ）
- 実装言語が Ruby であり、snake_case が自然
- `detail` 内のカスタムフィールドは自由に決められるため、プロジェクトの慣習に合わせる

### event_data / resource という属性名の理由

- 検討した候補：
  - `payload` / `snapshot`
  - `input` / `state`
  - `changes` / `current`
  - `trigger` / `resource`
  - `event_data` / `resource`
- `event_data` はイベントに関するデータであることが明確
- `resource` は REST の概念と一致し、馴染みがある
- この組み合わせが最もわかりやすいと判断

### リソース名の単数形・複数形の理由

- `detail-type` のリソース名は単数形: イベントは「1つのエンティティに起きたこと」を表すため
- `source` のリソース名は複数形: リソースの「コレクション」を示すため
- これは REST API の慣習（`GET /users/{id}` で個別リソースを取得）と整合する

## 参考

- [CloudEvents Specification](https://github.com/cloudevents/spec)
  - `source`: URI-reference（MUST）、絶対 URI（RECOMMENDED）
  - `type`: 逆ドメイン記法（SHOULD）
- [AWS EventBridge Event Patterns](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-event-patterns.html)

## 関連

- [ADR: EventBridge イベント発行の再設計](../20251218-eventbridge-redesign/ADR.ja.md)
- [docs/eventbridge-publishing.md](../eventbridge-publishing.md)
- [docs/eventbridge-publishing.ja.md](../eventbridge-publishing.ja.md)
