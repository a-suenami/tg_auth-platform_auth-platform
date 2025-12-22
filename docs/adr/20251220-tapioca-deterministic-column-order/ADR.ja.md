# ADR: Tapioca DSL 生成におけるカラム順序の決定論的ソート

- **日付**: 2025-12-20
- **ステータス**: 承認済み
- **決定者**: Akira Suenami

## コンテキスト

twogate/tapioca フォークでは、ActiveRecord モデルの `where` メソッドに対する RBI ファイルを生成する際に `constant.column_names` を使用してキーワード引数を生成している。

しかし、`column_names` はデータベースの物理的なカラム順序に依存する。

### PostgreSQL のカラム順序の制約

PostgreSQL は追記的（append-only）アーキテクチャを採用しており、`ALTER TABLE ADD COLUMN` で新しいカラムを追加する際、テーブルの末尾にしか追加できない。カラムの物理的な順序を変更するには、テーブルを再作成してデータを移行する必要がある。

### Ridgepole と Schemafile

本プロジェクトでは Ridgepole を使用してスキーマを管理している。Schemafile には人間が読んで自然な順番（例: id、主要なカラム、タイムスタンプの順）でカラムを列挙したい。しかし、Ridgepole は Schemafile の記述順序に関わらず、既存のカラムは維持し、新しいカラムのみを追加する。

### 問題の本質

結果として、以下の環境間でカラムの物理順序が異なる：

- **追記的なマイグレーションを繰り返した DB**（多くのエンジニアのローカル環境）: マイグレーションが実行された順序でカラムが追加されている
- **`db:reset` で作り直した DB**（CI 環境や新規セットアップ）: `structure.sql` から一括で作成され、Schemafile の定義順序に近い形になる

これにより、同じスキーマでもカラムの物理順序が異なり、Tapioca が生成する RBI ファイルが環境間で一致せず、CI で差分チェックが失敗する。

## 決定

`ActiveRecord::ModelSchema::ClassMethods#column_names` をモンキーパッチし、返却値をアルファベット順にソートする。

```ruby
module TapiocaColumnOrderPatch
  def column_names
    super.sort
  end
end

ActiveRecord::ModelSchema::ClassMethods.prepend(TapiocaColumnOrderPatch)
```

このパッチは `sorbet/tapioca/compilers/deterministic_column_order.rb` に配置し、Tapioca の DSL コンパイラとして読み込まれるようにする。

## 理由

### モンキーパッチを採用した理由

1. **上流への修正の判断が困難**: twogate/tapioca は他のプロジェクトでも広く使われており、この変更を入れていいか判断しかねた。カラム順序のソートは一部のユースケースには適さない可能性がある
2. **影響範囲の限定**: このパッチは Tapioca の DSL 生成時のみに影響し、アプリケーション実行時には影響しない（`sorbet/tapioca/compilers/` 以下は Tapioca 実行時のみ読み込まれる）
3. **シンプルな解決策**: 3行のコードで問題を解決できる

### アルファベット順を採用した理由

1. **決定論的**: 同じカラム集合に対して常に同じ順序を保証する
2. **可読性**: RBI ファイルのレビュー時にカラムを見つけやすい
3. **実績**: EF Core など他のフレームワークでも同様の問題に対してアルファベット順ソートが採用されている（参考: https://github.com/dotnet/efcore/issues/2272）

## 代替案

### 1. structure.sql のカラム順序を固定する

PostgreSQL の追記的アーキテクチャにより、既存テーブルのカラム順序を変更するにはテーブルの再作成とデータ移行が必要。全テーブルに対してこれを行うのは非現実的。

### 2. 全エンジニアに db:reset を強制する

ローカル環境でも常に `db:reset` を使用する方法。しかし：
- 開発データが失われる
- 大量のテストデータを持つ環境では時間がかかる
- 運用上の負担が大きい

### 3. CI で追記的なマイグレーションを再現する

CI 環境でも `db:migrate` を使用する方法。しかし：
- CI の実行時間が大幅に増加する
- マイグレーション履歴の完全な再現は困難

## 影響

- Tapioca による RBI 生成が環境に依存しなくなる
- CI での RBI ファイル差分チェックが安定する
- 生成される RBI ファイル内のカラム順序がアルファベット順に変更される（一度だけ全ファイルの再生成が必要）

## 関連

- [sorbet/tapioca/compilers/deterministic_column_order.rb](../../../sorbet/tapioca/compilers/deterministic_column_order.rb)
- https://github.com/dotnet/efcore/issues/2272 (EF Core での類似問題)
