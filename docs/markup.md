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

## 参考

- [BEM記法](http://getbem.com/)
- [CSS変数の使用](app/frontend/stylesheets/admin_area/foundation/_variables.scss)
- [既存のコンポーネント例](app/frontend/stylesheets/admin_area/object/component/)

