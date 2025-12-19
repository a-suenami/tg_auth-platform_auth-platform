# ADR: EventBridge イベント発行の再設計

- **日付**: 2025-12-18
- **ステータス**: 承認済み
- **決定者**: Akira Suenami, Daichi Miyazaki

## コンテキスト

現在、EventBridge へのイベント発行は `PublishEvents::PublishService` で実装されている。このサービスは以下の箇所から呼び出されている：

- `Users::UpdateService`（現在未使用）
- `Users::DestroyService`
- `Users::EmailChangeService`
- `DeliveryAddresses::CreateService`
- `DeliveryAddresses::UpdateService`

しかし、以下の問題がある：

1. `Users::UpdateService` が `UserForm` に置き換えられたことで、プロフィール更新時にイベントが発行されなくなっている
2. イベント形式が CloudEvents などの標準仕様に沿っていない
3. バージョニングの仕組みがない

## 決定

### 1. 既存の PublishService に手を加えず、別の実装で新たにイベントを送る

既存の `PublishEvents::PublishService` は変更せず、新しい `PublishEvents::PublishWorker` を作成し、`UserEvent` モデルの `after_commit` コールバックからエンキューする。

### 2. イベントのバージョニングを detail-type に含める

`detail-type` にバージョンを含める（例: `profile.changed.v1`）。これにより、破壊的変更時に新旧バージョンを並行運用できる。

## 理由

### 既存実装を変更しない理由

- 現在のコンシューマは Triple と Caravan のみで、社内プロダクトに閉じている
- 社内で閉じているため、影響範囲を把握でき、移行作業も社内で完結できる
- 今後の拡張を考えると、このタイミングで再設計しておくことで保守性と拡張性を確保できる
- 既存のコンシューマは既存の形式のままで動作を継続でき、移行準備ができ次第切り替えられる

### バージョニングを detail-type に含める理由

- EventBridge ルールでバージョンによるフィルタリングが可能になる
- CloudEvents の type 属性でバージョンを含める方式（例: `com.example.object.deleted.v2`）に倣った
- `detail` 内に `schema_version` を持つ方式も検討したが、ルーティング時に `detail` をパースする必要があり不便

## 影響

- 新しいイベント形式でのコンシューマ開発が可能になる
- 既存のコンシューマは影響を受けない
- 将来的に既存の `PublishService` は廃止予定

## 関連

- [docs/eventbridge-publishing.md](../eventbridge-publishing.md)
- [docs/eventbridge-publishing.ja.md](../eventbridge-publishing.ja.md)
