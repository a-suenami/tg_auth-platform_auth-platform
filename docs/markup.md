# マークアップガイドライン

このドキュメントは、プロジェクトにおけるマークアップのベストプラクティスとガイドラインをまとめたものです。
今後のマークアップを生成する際は、このドキュメントを参照してください。

## 目次

1. [命名規則](#命名規則)
2. [コンポーネント設計](#コンポーネント設計)
3. [スタイルの構造](#スタイルの構造)
4. [レイアウトとコンポーネントの使い分け](#レイアウトとコンポーネントの使い分け)
5. [データ属性の活用](#データ属性の活用)
6. [パーシャルの活用](#パーシャルの活用)
7. [実装例](#実装例)
8. [フォームフィールドの入力グループパターン](#フォームフィールドの入力グループパターン)
9. [アイコンの配置とスタイリング](#アイコンの配置とスタイリング)
10. [ネイティブUI要素のカスタマイズ](#ネイティブui要素のカスタマイズ)
11. [readonly属性の使用](#readonly属性の使用)
12. [モーダルのタイトルセクション](#モーダルのタイトルセクション)

## 命名規則

### BEM記法の使用

プロジェクトではBEM（Block Element Modifier）記法を使用します。

### プレフィックスの使い分け

- **`c-`**: コンポーネント（再利用可能なUI部品）
  - 例: `.c-info`, `.c-user-detail-memo`, `.c-user-detail-tag`
- **`p-`**: プロジェクト（特定のページや機能固有のスタイル）
  - 例: `.p-user-show`, `.p-user-detail`
- **`l-`**: レイアウト（ページ構造を定義するスタイル）
  - 例: `.l-page-content`, `.l-page-content__content__main`

### 命名の原則

1. **コンポーネントは再利用可能な単位で命名**
   - ❌ `.p-user-show__content__section__account`
   - ✅ `.c-info`

2. **クラス名は簡潔に、意味が明確に**
   - 長すぎるクラス名は避け、コンポーネント化を検討

3. **モディファイアは状態やバリエーションを表す**
   - 例: `.c-info__item--row`, `.c-tag.is-auto-tag`

## コンポーネント設計

### コンポーネント化の判断基準

以下の条件を満たす場合は、コンポーネントとして分離することを検討してください：

1. **複数の場所で使用される**
2. **独立した機能を持つ**
3. **再利用可能な見た目や動作**

### コンポーネントの配置

- **コンポーネント**: `app/frontend/stylesheets/admin_area/object/component/`
- **プロジェクト固有**: `app/frontend/stylesheets/admin_area/object/project/`

### コンポーネント化の例

**Before（プロジェクト固有）:**
```slim
.p-user-show__content__section__account
  .p-user-show__content__section__account__item
    .p-user-show__content__section__account__item__label ID
    .p-user-show__content__section__account__item__value = @user.id
```

**After（コンポーネント化）:**
```slim
.c-info
  .c-info__item
    .c-info__item__label ID
    .c-info__item__value = @user.id
```

## スタイルの構造

### 共通スタイルのmixin化

複数のコンポーネントで共通するスタイルは、mixinとして定義します。

**例: `_user-detail-common.scss`**
```scss
@mixin c-user-detail-common {
  display: grid;
  gap: 8px;

  &__label {
    font-size: 14px;
    font-weight: 500;
    color: var(--color-text-heading);
  }
}
```

**使用例:**
```scss
.c-user-detail-memo {
  @include common.c-user-detail-common;
  // メモ固有のスタイル
}
```

### セクションスタイルのmixin化

セクションの共通スタイルもmixinとして定義します。

**例: `_detail-section.scss`**
```scss
@mixin c-detail-section {
  display: grid;
  gap: 16px;

  &__label {
    display: flex;
    align-items: center;
    justify-content: space-between;
    font-size: 16px;
    color: var(--color-text-heading);

    &__edit {
      // 編集ボタンのスタイル
    }
  }
}
```

**使用例:**
```scss
.p-user-show {
  &__content {
    &__section {
      @include detail-section.c-detail-section;
    }
  }
}
```

## レイアウトとコンポーネントの使い分け

### レイアウト（`l-`）

ページの構造を定義するスタイル。グリッドレイアウトやコンテナの配置など。

**例:**
```slim
.l-page-content__content__main
  .p-user-show__content__section
    // コンテンツ
```

### コンポーネント（`c-`）

再利用可能なUI部品。ボタン、フォーム、カードなど。

**例:**
```slim
.c-info
  .c-info__item
    .c-info__item__label ラベル
    .c-info__item__value 値
```

## データ属性の活用

### 状態管理にデータ属性を使用

JavaScriptでの状態管理や、CSSでの条件付きスタイリングにデータ属性を活用します。

**例: アクティビティの種類による色分け**
```slim
.c-user-detail-activity__item__icon data-kind="#{activity[:kind]}"
  = render "shared/icons/#{activity[:icon]}"
```

```scss
.c-user-detail-activity__item__icon {
  &[data-kind='success'] {
    background-color: var(--color-success-background);
  }

  &[data-kind='notice'] {
    background-color: var(--color-notice-background);
  }
}
```

### データ属性の命名

- `data-kind`: 種類やタイプを表す
- `data-state`: 状態を表す
- `data-id`: 識別子を表す

## パーシャルの活用

### 共通部分のパーシャル化

複数のビューで使用される共通部分はパーシャルとして分離します。

**例: パンくずリスト**
```slim
= render 'admin_area/shared/breadcrumb', items: [{ text: 'すべてのユーザー', link: admin_area_users_path }]
```

### パーシャルの配置

- **共有パーシャル**: `app/views/admin_area/shared/`
- **機能固有パーシャル**: `app/views/admin_area/[機能名]/`

## 実装例

### 情報表示コンポーネント（`c-info`）

**マークアップ:**
```slim
.c-info
  .c-info__item
    .c-info__item__label ID
    .c-info__item__value = @user.id
  .c-info__item
    .c-info__item__label 名前
    .c-info__item__value = @user.user_profile&.name
```

**スタイル:**
```scss
.c-info {
  background-color: var(--color-background-gray);
  border-radius: 8px;
  border: 1px solid var(--color-border);

  &__item {
    display: grid;
    gap: 8px;
    padding: 8px 12px;

    &:not(:first-child) {
      border-top: 1px solid var(--color-border);
    }

    &__label {
      font-size: 12px;
      color: var(--color-text-inactive);
    }

    &__value {
      font-size: 14px;
      color: var(--color-text-active);
    }
  }
}
```

### 行レイアウトの実装

複数の項目を横並びに表示する場合：

```slim
.c-info
  .c-info__item.c-info__item--row
    .c-info__item
      .c-info__item__label 姓
      .c-info__item__value = @user.user_profile&.last_name
    .c-info__item
      .c-info__item__label 名
      .c-info__item__value = @user.user_profile&.first_name
```

```scss
.c-info__item {
  &--row {
    display: flex;
    padding: 0;

    .c-info__item {
      flex: 1;
      display: grid;
      gap: 8px;
      padding: 8px 12px;

      &:not(:first-child) {
        border-top: none;
        border-left: 1px solid var(--color-border);
      }
    }
  }
}
```

### グリッドレイアウトの使用

**例: タグリスト（2列表示）**
```scss
.c-user-detail-tag {
  &__list {
    display: grid;
    grid-template-columns: repeat(2, minmax(97px, 1fr));
    gap: 8px;
  }
}
```

### グラデーションの使用

**例: 縦向きの点線**
```scss
&::before {
  background: repeating-linear-gradient(
    to bottom,
    transparent 0,
    transparent 4px,
    var(--color-background-gray-dark) 4px,
    var(--color-background-gray-dark) 8px
  );
}
```

## チェックリスト

新しいマークアップを実装する際は、以下を確認してください：

- [ ] 命名規則に従っているか（`c-`, `p-`, `l-`の使い分け）
- [ ] 再利用可能な部分はコンポーネント化されているか
- [ ] 共通スタイルはmixinとして定義されているか
- [ ] 長すぎるクラス名になっていないか
- [ ] データ属性を適切に使用しているか
- [ ] パーシャル化できる部分は分離されているか
- [ ] レイアウトとコンポーネントが適切に分離されているか
- [ ] 複数の入力フィールドを統合する場合は`input-group`パターンを使用しているか
- [ ] アイコンの配置は`display: grid; place-items: center;`を使用しているか
- [ ] ネイティブUI要素（datetime-local等）のカスタマイズが必要な場合は適切に対応しているか
- [ ] `readonly`属性と`disabled`属性の使い分けが適切か

## フォームフィールドの入力グループパターン

### 複数入力の統合デザイン

メイン入力とステータス選択など、複数の入力フィールドを1つのグループとして統合する場合、`c-form-field__input-group`を使用します。

**マークアップ:**
```slim
.c-form-field
  label.c-form-field__label メールアドレス
  .c-form-field__input-group
    .c-form-field__input-group__input
      = f.email_field :email, class: 'c-form-field__input'
    .c-form-field__input-group__status
      = f.select 'email_verified_status', [['確認済み', 'confirmed'], ['未確認', 'unconfirmed']], {}, { class: 'c-form-field__input c-form-field__input--select' }
      .c-form-field__input-group__status__dropdown
        = render 'shared/icons/icon-chevron-down'
```

**スタイルのポイント:**
- 外側のコンテナでボーダーとボックスシャドウを設定し、視覚的に統合
- 内部の各入力フィールドは`border: none`でボーダーを削除
- `overflow: hidden`で角丸を維持
- 区切り線は`border-left`で表現

## アイコンの配置とスタイリング

### 中央配置の方法

アイコンを要素の中央に配置する場合、`display: grid`と`place-items: center`を使用します。

**例: カレンダーアイコンの配置**
```scss
&__calendar {
  position: absolute;
  right: 0;
  top: 0;
  bottom: 0;
  display: grid;
  place-items: center;
  pointer-events: none;
  border-left: 1px solid var(--color-border);
  min-width: 48px;
  aspect-ratio: 1;
}
```

**ポイント:**
- `display: grid; place-items: center;`で完全な中央配置を実現
- `aspect-ratio: 1`で正方形を確保
- `pointer-events: none`でクリックイベントを無効化
- ボーダーで区切りを表現

### ドロップダウンアイコンの配置

セレクトボックスなどのドロップダウンアイコンは、絶対配置で右側に配置します。

```scss
&__dropdown {
  position: absolute;
  right: 12px;
  top: 50%;
  transform: translateY(-50%);
  display: flex;
  align-items: center;
  pointer-events: none;
}
```

## ネイティブUI要素のカスタマイズ

### datetime-localのカスタマイズ

`datetime-local`入力フィールドのデフォルトカレンダーアイコンを非表示にし、カスタムアイコンで置き換えます。

**スタイル:**
```scss
&[type="datetime-local"] {
  padding-right: 60px;

  &::-webkit-calendar-picker-indicator {
    display: none;
  }
}
```

**マークアップ:**
```slim
.c-form-field__input-wrapper
  = f.datetime_local_field :deleted_at, class: 'c-form-field__input'
  .c-form-field__input-wrapper__calendar
    = render 'shared/icons/icon-calendar'
```

**ポイント:**
- `::-webkit-calendar-picker-indicator`でデフォルトアイコンを非表示
- カスタムアイコンを`input-wrapper`内に配置
- 適切な`padding-right`でアイコン分のスペースを確保

## readonly属性の使用

フォームヘルパーではなく、直接HTMLで`readonly`属性を指定する場合があります。

**例:**
```slim
input.c-form-field__input type="text" value="1234-5678-9000" readonly="readonly"
```

**スタイル:**
```scss
&[readonly] {
  background-color: var(--color-background-gray);
  color: var(--color-text-inactive);
  cursor: not-allowed;
}
```

**ポイント:**
- `readonly`属性は値の編集を防ぐが、フォーム送信には含まれる
- `disabled`とは異なり、フォーム送信時に値が送信される
- 視覚的には`disabled`と同様のスタイルを適用

## モーダルのタイトルセクション

### タイトルとサブタイトルの配置

モーダルのヘッダー部分では、タイトルとサブタイトルの間隔とスタイリングに注意します。

**スタイル:**
```scss
&__header {
  gap: 12px; // 8pxから12pxに調整

  &__subtitle {
    font-size: 14px;
    color: var(--color-text-heading); // var(--color-text-body)から変更
    font-weight: 500;
  }

  &__title {
    font-size: 20px;
    font-weight: 600;
    // color指定を削除（デフォルトの色を使用）
  }
}
```

**ポイント:**
- `gap`を適切に調整して視覚的な階層を明確化
- サブタイトルも`color-text-heading`を使用して重要性を表現
- タイトルはデフォルトの色を使用し、過度な色指定を避ける

## 参考

- [BEM記法](http://getbem.com/)
- [CSS変数の使用](app/frontend/stylesheets/admin_area/foundation/_variables.scss)
- [既存のコンポーネント例](app/frontend/stylesheets/admin_area/object/component/)

