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
8. [ラジオボタングループ](#ラジオボタングループ)
9. [フォームフィールドの入力グループパターン](#フォームフィールドの入力グループパターン)
10. [アイコンの配置とスタイリング](#アイコンの配置とスタイリング)
11. [ネイティブUI要素のカスタマイズ](#ネイティブui要素のカスタマイズ)
12. [readonly属性の使用](#readonly属性の使用)
13. [モーダルの実装方法](#モーダルの実装方法)
14. [モーダルのタイトルセクション](#モーダルのタイトルセクション)
15. [Enumerizeの表示方法](#enumerizeの表示方法)
16. [空状態の表示](#空状態の表示)
17. [フォームの構造](#フォームの構造)
18. [ナビゲーションのアイコン](#ナビゲーションのアイコン)
19. [国際化対応](#国際化対応)
20. [未実装機能の非表示](#未実装機能の非表示)
21. [リンクのhover時の色指定](#リンクのhover時の色指定)
22. [ドロップダウンの実装](#ドロップダウンの実装)
23. [フォームバリデーション](#フォームバリデーション)
24. [テーブルフィルター](#テーブルフィルター)
25. [空状態のモディファイア](#空状態のモディファイア)
26. [ボタン内のドロップダウン](#ボタン内のドロップダウン)
27. [セクション分割パターン](#セクション分割パターン)

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

> 補足: `c-`で始まるコンポーネントクラスは必ず `app/frontend/stylesheets/admin_area/object/component/` 配下に専用ファイルを用意して定義してください（コンポーネント用SCSSとプロジェクト用SCSSを混在させない）。
> 例外: 特定プロジェクト配下でのみコンポーネントにスタイルを当てたい場合は、そのプロジェクト用SCSS内でコンポーネントをネストして記述しても構いません（グローバルなcomponent配下には置かない）。

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
- [ ] 関連する2つのフィールドを横並びに配置する場合は`label-group`と`input-group`を使用しているか
- [ ] enumerizeの値を表示する場合は`.text`メソッドを使用しているか
- [ ] Turbo Frame内の動的に追加された要素にも対応するため、イベント委譲を使用しているか
- [ ] キャンセルボタンには`--color-text-inactive`を使用しているか
- [ ] データが存在しない場合は`c-empty`コンポーネントを使用して空状態を表示しているか
- [ ] データの有無に応じてボタンのラベルを適切に変更しているか
- [ ] フォームパーシャル内で`.c-form`を定義しているか
- [ ] ナビゲーションのアイコンの向きを状態に応じて変更しているか
- [ ] 国際化が必要な場合は適切な翻訳を使用しているか
- [ ] ラジオボタンはカスタムUIを実装し、ネイティブのラジオボタンは非表示にしているか
- [ ] ラジオボタングループは独立したコンポーネントファイルに分離しているか
- [ ] アイコンの配置は`display: grid; place-items: center;`を使用しているか
- [ ] ネイティブUI要素（datetime-local等）のカスタマイズが必要な場合は適切に対応しているか
- [ ] `readonly`属性と`disabled`属性の使い分けが適切か
- [ ] モーダルを使用する場合はTurbo Frameと連携しているか
- [ ] モーダルの開閉は`data-modal-open`属性で制御しているか
- [ ] モーダルを閉じる際にTurbo Frameの内容をクリアしているか
- [ ] 導線が機能しているが本番非表示の場合は`unless Rails.env.production?`で非表示にしているか（導線が塞がれている場合は非表示不要）
- [ ] リンク要素を使用するコンポーネントでは、hover時に明示的に色を指定してUIKitとの競合を回避しているか
- [ ] ドロップダウンはデータ属性（`data-dropdown-toggle`、`data-dropdown-open`）を使用して開閉を制御しているか
- [ ] ドロップダウンの開閉はイベント委譲を使用して実装しているか
- [ ] カード全体をリンクにする場合、アクションボタンは絶対配置で配置しているか
- [ ] ナビゲーションの表示方法を現在のページに応じて切り替えているか
- [ ] チェックボックスの初期状態を現在のページに応じて設定しているか
- [ ] 親と子のアクティブ状態を適切に管理しているか
- [ ] プレースホルダーの色は`--color-text-placeholder`を使用しているか
- [ ] ボタンの無効化スタイル（`:disabled`）を適切に定義しているか
- [ ] `display: contents`を使用してグリッドレイアウトに統合しているか
- [ ] フォームバリデーションはStimulusコントローラーを使用して実装しているか
- [ ] 送信ボタンは初期状態で`disabled`にしておくか
- [ ] 複数の送信ボタンがある場合は`submitTargets`（複数形）を使用しているか
- [ ] `type="button"`の場合は`disabled`属性を設定し、`pointer-events`で制御しているか
- [ ] テーブルフィルターはデータ属性（`data-filter-toggle`、`data-filter-open`）で開閉を制御しているか
- [ ] フィルター条件が存在する場合は、初期状態で`data-filter-open="true"`に設定しているか
- [ ] 空状態にマージンが必要な場合は`c-empty--has-margin`モディファイアを使用しているか
- [ ] テーブル内の空状態は`c-table__empty`を使用しているか
- [ ] ボタン内のドロップダウンはチェブロンアイコンと組み合わせて実装しているか
- [ ] 送信ボタンが無効化されている場合、チェブロンアイコンも視覚的に無効化しているか
- [ ] サイドバーのセクション分割は`__section`を使用しているか
- [ ] セクション間は`border-bottom`で区切っているか

## ラジオボタングループ

### カスタムラジオボタンの実装

ラジオボタンは、ネイティブのラジオボタンを非表示にして、カスタムのラジオボタンUIを実装します。

**マークアップ:**
```slim
.c-form-field
  label.c-form-field__label 配送先住所と請求先住所
  .c-form-field__radio-group
    label.c-form-field__radio-group__item
      = f.radio_button :billing_address_type, "same", checked: false, class: 'c-form-field__radio-group__input'
      span.c-form-field__radio-group__radio
      span.c-form-field__radio-group__label 配送先住所と同じ
    label.c-form-field__radio-group__item
      = f.radio_button :billing_address_type, "different", checked: true, class: 'c-form-field__radio-group__input'
      span.c-form-field__radio-group__radio
      span.c-form-field__radio-group__label 配送先住所と異なる
```

**スタイル:**
```scss
.c-form-field__radio-group {
  display: flex;
  gap: 0;
  border: 1px solid var(--color-border);
  border-radius: 8px;
  background-color: var(--color-background);
  overflow: hidden;
  box-shadow: var(--box-shadow);

  &__item {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: flex-start;
    gap: 8px;
    padding: 12px 16px;
    cursor: pointer;
    position: relative;

    &:not(:first-child) {
      border-left: 1px solid var(--color-border);
    }
  }

  &__input {
    position: absolute;
    opacity: 0;
    pointer-events: none;

    &:checked + .c-form-field__radio-group__radio {
      &::before {
        opacity: 1;
      }
    }

    &:checked ~ .c-form-field__radio-group__label {
      color: var(--color-text-heading);
      font-weight: 500;
    }
  }

  &__radio {
    width: 16px;
    height: 16px;
    border: 1px solid #99A1AF;
    border-radius: 50%;
    background-color: var(--color-background);
    display: inline-grid;
    place-items: center;
    flex-shrink: 0;
    position: relative;

    &::before {
      content: '';
      width: 8px;
      height: 8px;
      opacity: 0;
      border: 1px solid rgba(black, 0.8);
      background-color: var(--color-text-heading);
      border-radius: 50%;
      transition: opacity 0.1s ease-in-out;
    }
  }

  &__label {
    font-size: 14px;
    color: var(--color-text-body);
    cursor: pointer;
    user-select: none;
  }
}
```

**ポイント:**
- ネイティブのラジオボタンは`opacity: 0`と`pointer-events: none`で非表示にするが、DOMには残してフォーム送信に使用する
- カスタムのラジオボタンUIは`span.c-form-field__radio-group__radio`で実装する
- `:checked`状態では、`::before`疑似要素の`opacity`を`1`にして内側の円を表示する
- 選択されたラジオボタンのラベルは`color: var(--color-text-heading)`と`font-weight: 500`で強調する
- `label`要素でラップすることで、ラジオボタン全体がクリック可能になる
- コンポーネントとして独立したファイル（`_radio-group.scss`）に分離する

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

### 関連フィールドの横並び配置

姓と名、セイとメイのように、関連する2つのフィールドを横並びに配置する場合、`c-form-field__label-group`と`c-form-field__input-group`を使用します。

**マークアップ:**
```slim
.c-form-field
  .c-form-field__label-group
    label.c-form-field__label = UserProfile.human_attribute_name(:last_name)
    label.c-form-field__label = UserProfile.human_attribute_name(:first_name)
  .c-form-field__input-group
    .c-form-field__input-group__input
      = f.text_field :last_name, class: 'c-form-field__input'
    .c-form-field__input-group__input
      = f.text_field :first_name, class: 'c-form-field__input'
```

**スタイル:**
```scss
.c-form-field {
  &__label-group {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 0;
  }

  &__input-group {
    &__input {
      &:not(:first-child) {
        border-left: 1px solid var(--color-border);
      }
    }
  }
}
```

**ポイント:**
- `label-group`でラベルを2列のグリッドで横並びに配置
- `input-group`で入力フィールドを横並びに配置
- 2つ目以降の入力フィールドに`border-left`で分割線を追加
- 各入力フィールドは`flex: 1`で均等に配置される

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

### プレースホルダーの色

プレースホルダーの色は、専用のCSS変数（`--color-text-placeholder`）を使用します。

**スタイル:**
```scss
&::placeholder {
  color: var(--color-text-placeholder);
}
```

**ポイント:**
- プレースホルダーの色は`--color-text-placeholder`を使用する
- 入力フィールドのテキスト色（`--color-text-body`）や非アクティブなテキスト色（`--color-text-inactive`）とは区別する
- これにより、プレースホルダーと入力済みテキストを視覚的に区別できる

### ボタンの無効化スタイル

送信ボタンが無効化された場合のスタイルを適切に定義します。

**スタイル:**
```scss
&--submit {
  background-color: var(--color-primary);
  color: var(--color-primary-contrast);
  border-color: var(--color-primary);

  &:hover:not(:disabled) {
    background-color: var(--color-text-heading);
    border-color: var(--color-text-heading);
  }

  &:disabled {
    background-color: var(--color-border);
    color: var(--color-text-inactive);
    border-color: transparent;
    cursor: not-allowed;
  }
}
```

**ポイント:**
- `:disabled`状態のスタイルを明示的に定義する
- 無効化時は`cursor: not-allowed`でカーソルを変更する
- `:hover:not(:disabled)`で、無効化時はホバー効果を適用しない
- 無効化時は控えめな色（`--color-border`、`--color-text-inactive`）を使用する

## モーダルの実装方法

### モーダルの基本構造

モーダルは`c-modal`コンポーネントを使用し、Turbo Frameと連携して動作します。

**共通モーダルパーシャル（`app/views/admin_area/shared/_modal.html.slim`）:**
```slim
.c-modal data-modal-id="#{modal_id}"
  .c-modal__overlay
  .c-modal__dialog
    = turbo_frame_tag "modal-frame", class: "c-modal__dialog__frame" do
      .c-modal__dialog__body
        | 読み込み中...
```

**レイアウトへの組み込み:**
```slim
/ 共通モーダル
= render 'admin_area/shared/modal', modal_id: 'common-modal'
```

**ポイント:**
- `data-modal-id`でモーダルを識別
- `data-modal-open`属性で開閉状態を管理（JavaScriptで制御）
- Turbo Frameを使用してコンテンツを動的に読み込む

### モーダルを開く方法

リンクに`data: { turbo_frame: 'modal-frame' }`を指定することで、Turbo Frame経由でモーダルを開きます。

**マークアップ:**
```slim
= link_to edit_admin_area_user_path(@user), class: "p-user-detail__content__section__label__edit", data: { turbo_frame: 'modal-frame' } do
  = render 'shared/icons/icon-edit'
  | 編集する
```

**モーダルコンテンツ（`edit.html.slim`）:**
```slim
= turbo_frame_tag "modal-frame" do
  .c-modal__dialog__header
    .c-modal__dialog__header__subtitle = @user.user_profile&.name
    .c-modal__dialog__header__title アカウントの編集
    = link_to "#", class: "c-modal__dialog__header__close", data: { action: "close-modal" } do
      = render 'shared/icons/icon-close'
  .c-modal__dialog__body
    = form_with model: [:admin_area, @user], url: admin_area_user_path(@user), method: :patch, local: true, data: { turbo_frame: '_top' }, html: { id: "edit_user_#{@user.id}" } do |f|
      / フォーム内容
  .c-modal__dialog__footer
    button.c-modal__dialog__footer__button.c-modal__dialog__footer__button--cancel type="button" data-action="close-modal" キャンセル
    button.c-modal__dialog__footer__button.c-modal__dialog__footer__button--save type="submit" form="edit_user_#{@user.id}" data-shortcut="⌘+S" 保存
```

**ポイント:**
- Turbo FrameのIDは`modal-frame`で統一
- フォーム送信時は`data: { turbo_frame: '_top' }`でページ全体を更新
- 閉じるボタンには`data-action="close-modal"`を指定

### モーダルのスタイル

**基本構造:**
```scss
.c-modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 1000;
  display: none;

  &[data-modal-open="true"] {
    display: grid;
  }
}
```

**オーバーレイ:**
```scss
&__overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(2px);
}
```

**ダイアログ:**
```scss
&__dialog {
  position: relative;
  z-index: 1;
  margin: auto;
  background-color: var(--color-background);
  border-radius: 12px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
  max-width: 600px;
  width: 90%;
  max-height: 90vh;
  display: grid;
  grid-template-rows: auto 1fr auto;
  overflow: hidden;
}
```

**ポイント:**
- `display: none`と`display: grid`で開閉を制御
- オーバーレイは`backdrop-filter`でぼかし効果を追加
- ダイアログは`grid-template-rows: auto 1fr auto`でヘッダー、ボディ、フッターを配置
- レスポンシブ対応（`width: 90%`、`max-width: 600px`）

### JavaScriptの実装

モーダルの開閉はJavaScriptで制御します。

**開く処理:**
```typescript
function openModal(modalId: string) {
  const modal = document.querySelector(`[data-modal-id="${modalId}"]`) as HTMLElement;
  if (modal) {
    modal.setAttribute("data-modal-open", "true");
    document.body.style.overflow = "hidden";
  }
}
```

**閉じる処理:**
```typescript
function closeModal(modalId: string) {
  const modal = document.querySelector(`[data-modal-id="${modalId}"]`) as HTMLElement;
  if (modal) {
    modal.setAttribute("data-modal-open", "false");
    document.body.style.overflow = "";
    // Turbo Frameをクリア
    const frame = modal.querySelector("turbo-frame#modal-frame") as HTMLElement;
    if (frame) {
      frame.innerHTML = "";
    }
  }
}
```

**イベントハンドラー:**
- 閉じるボタン: `[data-action='close-modal']`
- オーバーレイクリック: `.c-modal__overlay`
- キーボードショートカット（⌘+S）: `button[data-shortcut="⌘+S"]`
- Turbo Frameロード時: `turbo:frame-load`イベントで自動的に開く

**イベント委譲の使用:**
Turbo Frame内で動的に追加された要素にも対応するため、イベント委譲を使用します。

```typescript
// 閉じるボタン（イベント委譲を使用してTurbo Frame内のボタンにも対応）
document.addEventListener("click", (e) => {
  const target = e.target as HTMLElement;
  const button = target.closest("[data-action='close-modal']") as HTMLElement;
  if (button) {
    e.preventDefault();
    const modal = button.closest(".c-modal") as HTMLElement;
    if (modal) {
      const modalId = modal.getAttribute("data-modal-id");
      if (modalId) {
        closeModal(modalId);
      }
    }
  }
});
```

**ポイント:**
- モーダル開閉時に`body`の`overflow`を制御してスクロールを無効化
- 閉じる際にTurbo Frameの内容をクリア
- Turbo Frameがロードされたときに自動的にモーダルを開く
- Turbo Frame内の動的に追加された要素にも対応するため、イベント委譲を使用する

### モーダルのタイトルセクション

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

### モーダルのフッターボタン

モーダルのフッターには、キャンセルボタンと保存ボタンが配置されます。

**スタイル:**
```scss
&__footer {
  &__button {
    &--cancel {
      background-color: var(--color-background);
      color: var(--color-text-inactive);
      border-color: var(--color-border);

      &:hover {
        background-color: var(--color-background-gray);
      }
    }

    &--save {
      background-color: var(--color-primary);
      color: var(--color-primary-contrast);
      border-color: var(--color-primary);
    }
  }
}
```

**ポイント:**
- キャンセルボタンには`--color-text-inactive`を使用して視覚的に控えめにする
- 保存ボタンは`--color-primary`を使用して主要なアクションであることを示す
- 両方のボタンに適切なホバー効果を追加

## Enumerizeの表示方法

### 翻訳された値の表示

enumerizeを使用している場合、`.text`メソッドを使用して翻訳された値を表示します。

**マークアップ:**
```slim
.c-info__item__value = @user&.user_profile&.gender&.text
```

**ロケールファイルの設定:**
```yaml
ja:
  enumerize:
    user_profile:
      gender:
        male: 男性
        female: 女性
        other: その他
```

**ポイント:**
- enumerizeの値は`.text`メソッドで翻訳された値を取得できる
- ロケールファイルで`enumerize.[model_name].[attribute].[value]`の形式で翻訳を定義する
- 属性名の翻訳は`activerecord.attributes.[model_name].[attribute]`で定義する

## 空状態の表示

### データが存在しない場合の表示

データが存在しない場合、`c-empty`コンポーネントを使用して空状態を表示します。

**マークアップ:**
```slim
- if @user.contact_address.present?
  .c-info
    / データ表示
- else
  .c-empty
    .c-empty__text 配送先住所が設定されていません
```

**スタイル:**
```scss
.c-empty {
  background-color: var(--color-background-gray);
  border-radius: 8px;
  border: 1px solid var(--color-border);
  padding: 24px 12px;
  display: flex;
  align-items: center;
  justify-content: center;

  &__text {
    font-size: 14px;
    color: var(--color-text-inactive);
    text-align: center;
  }
}
```

**ポイント:**
- データが存在しない場合にユーザーに分かりやすいメッセージを表示する
- `c-info`コンポーネントと同じスタイル（背景色、ボーダー、角丸）を使用して統一感を保つ
- テキストは`--color-text-inactive`を使用して控えめに表示する

### 条件分岐によるボタンラベルの変更

データの有無に応じて、ボタンのラベルを「編集する」/「作成する」と切り替えます。

**マークアップ:**
```slim
.p-user-detail__content__section__label
  | 配送先住所
  - if @user.contact_address.present?
    = link_to edit_admin_area_user_contact_address_path(@user), class: "p-user-detail__content__section__label__edit", data: { turbo_frame: 'modal-frame' } do
      = render 'shared/icons/icon-edit'
      | 編集する
  - else
    = link_to new_admin_area_user_contact_address_path(@user), class: "p-user-detail__content__section__label__edit", data: { turbo_frame: 'modal-frame' } do
      = render 'shared/icons/icon-edit'
      | 作成する
```

**ポイント:**
- データの有無に応じて適切なアクションを提供する
- 同じクラス名を使用してスタイルを統一する
- Turbo Frameを使用してモーダルを開く

## フォームの構造

### フォームパーシャル内での`.c-form`の配置

フォームパーシャル内で`.c-form`を定義することで、モーダル内でもフォームのスタイルが適用されます。

**マークアップ（フォームパーシャル）:**
```slim
.c-form
  .c-form-field
    label.c-form-field__label ラベル
    = f.text_field :field, class: 'c-form-field__input'
```

**マークアップ（モーダル内）:**
```slim
.c-modal__dialog__body
  = form_with model: @model, url: path, method: :put, local: true, data: { turbo_frame: '_top' }, html: { id: "form_id" } do |f|
    = render 'admin_area/shared/form_error', target: f.object
    = render 'form', f: f
```

**ポイント:**
- フォームパーシャル内で`.c-form`を定義することで、モーダル内でもフォームのスタイルが適用される
- モーダル内では`.c-form`を重複して定義しない（パーシャル内で定義済み）

### display: contentsの使用

グリッドレイアウトに統合するために、`display: contents`を使用します。

**マークアップ:**
```slim
.p-user-tag-form data-controller="form-validation"
  .p-user-tag-form__breadcrumb
    = render 'admin_area/shared/breadcrumb', items: [...]
  .l-page-content__content__main.p-user-tag-form__content__main
    / フォーム内容
  .l-page-content__content__sub.p-user-tag-form__content__sub
    / サイドバー内容
```

**スタイル:**
```scss
.p-user-tag-form {
  display: contents;

  &__breadcrumb {
    grid-column: 1 / -1;
  }
}
```

**ポイント:**
- `display: contents`を使用することで、要素自体はレンダリングされず、子要素が親のグリッドレイアウトに直接参加する
- これにより、既存のレイアウト（`.l-page-content__content`）に統合できる
- `grid-column: 1 / -1`で、パンくずリストなどの要素を全列にまたがらせることができる

## フォームバリデーション

### Stimulusコントローラーによるバリデーション

フォームのバリデーションは、Stimulusコントローラーを使用して実装します。

**マークアップ:**
```slim
.p-user-tag-form data-controller="form-validation"
  = form_with model: @user_tag, url: admin_area_user_tags_path, method: :post, local: true, data: { turbo_frame: '_top', form_validation_target: 'form' }, html: { id: 'new_user_tag_form' } do |f|
    .c-form
      .c-form-field
        label.c-form-field__label タグ名
        = f.text_field :name, placeholder: 'タグ名を入力', class: 'c-form-field__input', required: true
  button.p-user-tag-form__content__sub__button type="submit" form="new_user_tag_form" data-form-validation-target="submit" disabled="disabled" 新規作成
```

**JavaScript（Stimulusコントローラー）:**
```typescript
import { Controller } from '@hotwired/stimulus';

export default class extends Controller<HTMLElement> {
  static targets = ['form', 'submit'];

  declare readonly formTarget: HTMLFormElement;
  declare readonly submitTarget: HTMLButtonElement;

  connect() {
    this.validate();
    this.formTarget.addEventListener('input', this.validate.bind(this));
    this.formTarget.addEventListener('change', this.validate.bind(this));
  }

  disconnect() {
    this.formTarget.removeEventListener('input', this.validate.bind(this));
    this.formTarget.removeEventListener('change', this.validate.bind(this));
  }

  validate() {
    const form = this.formTarget;
    if (!form) return;

    const isValid = form.checkValidity();
    if (this.submitTarget) {
      this.submitTarget.disabled = !isValid;
    }
  }
}
```

**ポイント:**
- `data-controller="form-validation"`でStimulusコントローラーを有効化する
- `data-form-validation-target="form"`でフォーム要素を指定する
- `data-form-validation-target="submit"`で送信ボタンを指定する
- `connect()`で初期バリデーションとイベントリスナーの登録を行う
- `disconnect()`でイベントリスナーを削除する
- `form.checkValidity()`でネイティブのバリデーションAPIを使用する
- 送信ボタンは初期状態で`disabled="disabled"`にしておく
- 入力フィールドに`required`属性を指定して必須項目を定義する

### 複数の送信ボタンへの対応

フォームに複数の送信ボタンがある場合、`submitTarget`を`submitTargets`（複数形）に変更します。

**JavaScript（Stimulusコントローラー）:**
```typescript
export default class extends Controller<HTMLElement> {
  static targets = ['form', 'submit'];

  declare readonly formTarget: HTMLFormElement;
  declare readonly submitTargets: HTMLButtonElement[]; // 複数形

  validate() {
    const form = this.formTarget;
    if (!form) return;

    const isValid = form.checkValidity();
    this.submitTargets.forEach((target) => {
      if (target.type === 'submit') {
        target.disabled = !isValid;
      } else {
        // type="button"の場合は、disabled属性を設定し、pointer-eventsで制御
        if (!isValid) {
          target.setAttribute('disabled', 'disabled');
        } else {
          target.removeAttribute('disabled');
        }
      }
    });
  }
}
```

**ポイント:**
- `submitTarget`を`submitTargets`（複数形）に変更することで、複数の送信ボタンに対応できる
- `type="submit"`の場合は`disabled`プロパティを使用する
- `type="button"`の場合は`disabled`属性を設定し、CSSの`pointer-events`で制御する
- ドロップダウンメニュー内の送信ボタンなど、複数の送信ボタンがある場合に有効

## テーブルフィルター

### データ属性による開閉制御

テーブルの絞り込みセクションは、データ属性（`data-filter-toggle`、`data-filter-open`）を使用して開閉を制御します。

**マークアップ:**
```slim
.c-table-header
  .c-table-header__content
    a.c-table-header__content__filter href='#' data-filter-toggle="user-filter-section"
      = render 'shared/icons/icon-filter'
      span.c-table-header__content__filter__text 絞り込み
- filter_active = params[:id].present? || params[:email].present? || params[:phone_number].present?
.c-table-filter id="user-filter-section" data-filter-open="#{filter_active}"
  = form_with url: admin_area_users_path, method: :get, local: true, class: 'c-table-filter__form' do |f|
    .c-table-filter__fields
      .c-form-field
        = f.label :id, "ID", class: 'c-form-field__label'
        = f.text_field :id, placeholder: "539dde46-68a2-4619-9866-63b7478ae36e", value: params[:id], class: 'c-form-field__input'
    .c-table-filter__actions
      = f.submit "検索", class: 'c-table-filter__actions__button c-table-filter__actions__button--submit'
      = link_to "検索初期化", admin_area_users_path, class: 'c-table-filter__actions__button c-table-filter__actions__button--reset'
```

**スタイル:**
```scss
.c-table-filter {
  display: none;
  padding: 24px;
  background-color: var(--color-background-gray);
  border-bottom: 1px solid var(--color-border);

  &[data-filter-open="true"] {
    display: block;
  }

  &__form {
    display: grid;
    gap: 24px;
    max-width: 320px;
  }

  &__fields {
    display: grid;
    grid-template-columns: 1fr;
    gap: 16px;
  }

  &__actions {
    display: flex;
    gap: 8px;
    align-items: center;
  }
}
```

**JavaScript:**
```typescript
function initFilterHandlers() {
  document.addEventListener("click", (e) => {
    const target = e.target as HTMLElement;
    const toggle = target.closest("[data-filter-toggle]") as HTMLElement;
    const filterSection = target.closest(".c-table-filter") as HTMLElement;

    if (toggle) {
      e.preventDefault();
      e.stopPropagation();

      const filterId = toggle.getAttribute("data-filter-toggle");
      if (!filterId) return;

      const targetFilter = document.getElementById(filterId) as HTMLElement;
      if (!targetFilter) return;

      const isOpen = targetFilter.getAttribute("data-filter-open") === "true";

      // クリックされた絞り込みセクションを開閉
      targetFilter.setAttribute("data-filter-open", isOpen ? "false" : "true");
    } else if (filterSection) {
      // 絞り込みセクション内のクリック時は閉じない（フォームの処理を優先）
      e.stopPropagation();
    }
  });
}
```

**ポイント:**
- `data-filter-toggle`でトグルボタンを指定し、対象のフィルターセクションのIDを指定する
- `data-filter-open`でフィルターセクションの開閉状態を管理する
- サーバーサイドでフィルター条件が存在する場合は、初期状態で`data-filter-open="true"`に設定する
- フィルターセクション内のクリック時は`stopPropagation()`で閉じないようにする
- `display: none`と`display: block`で開閉を制御する

## 空状態のモディファイア

### マージン付き空状態

空状態コンポーネントにマージンを追加する場合は、`c-empty--has-margin`モディファイアを使用します。

**マークアップ:**
```slim
- if @users.empty?
  .c-empty.c-empty--has-margin
    .c-empty__text ユーザーが見つかりません
```

**スタイル:**
```scss
.c-empty {
  // ... 既存のスタイル ...

  &--has-margin {
    margin: 24px;
  }
}
```

**ポイント:**
- テーブルやリストの空状態など、周囲にマージンが必要な場合に使用する
- モディファイアを使用することで、デフォルトのスタイルを変更せずに済む

### テーブルの空状態

テーブル内で空状態を表示する場合は、`c-table__empty`を使用します。

**マークアップ:**
```slim
.c-table.has-checkbox.has-action
  - if @users.empty?
    .c-table__empty ユーザーが見つかりません
  - else
    table
      / ... テーブル内容 ...
```

**スタイル:**
```scss
.c-table {
  &__empty {
    padding: 48px 24px;
    text-align: center;
    font-size: 14px;
    color: var(--color-text-inactive);
    background-color: var(--color-background-gray);
    border-radius: 8px;
    border: 1px solid var(--color-border);
  }
}
```

**ポイント:**
- テーブル内で空状態を表示する場合は、`c-table__empty`を使用する
- テーブルのスタイル（背景色、ボーダー、角丸）に合わせてデザインする
- 条件分岐でテーブルと空状態を切り替える

## ボタン内のドロップダウン

### チェブロンアイコンとドロップダウンメニューの組み合わせ

送信ボタンにチェブロンアイコンを追加し、クリックでドロップダウンメニューを表示します。

**マークアップ:**
```slim
.p-user-tag-form__content__sub__button-wrapper
  button.p-user-tag-form__content__sub__button.p-user-tag-form__content__sub__button--submit type="submit" form="edit_user_tag_form" data-form-validation-target="submit" 変更を保存
  button.p-user-tag-form__content__sub__button__chevron type="button" data-dropdown-toggle="dropdown-save-actions"
    = render 'shared/icons/icon-chevron-down'
  .p-user-tag-form__content__sub__button__dropdown id="dropdown-save-actions"
    button.p-user-tag-form__content__sub__button__dropdown__item type="submit" form="edit_user_tag_form" data-form-validation-target="submit" 変更を保存
    = link_to admin_area_user_tag_path(@user_tag), data: { turbo_method: :delete, turbo_confirm: '本当に削除しますか？', turbo_frame: '_top' }, class: 'p-user-tag-form__content__sub__button__dropdown__item' do
      | タグを削除
```

**スタイル:**
```scss
&__button-wrapper {
  position: relative;

  // submitボタンが無効化されている場合、矢印部分も視覚的に無効化
  .p-user-tag-form__content__sub__button--submit[disabled] ~ .p-user-tag-form__content__sub__button__chevron {
    opacity: 0.5;
    cursor: not-allowed;

    &:hover::before {
      background-color: transparent;
    }
  }
}

&__button {
  &--submit {
    padding-right: 40px; // 矢印部分のスペースを確保
  }

  &__chevron {
    position: absolute;
    right: 4px;
    top: 50%;
    transform: translateY(-50%);
    display: flex;
    align-items: center;
    justify-content: center;
    width: 24px;
    height: 24px;
    cursor: pointer;
    border: none;
    background: none;
    padding: 0;
    border-radius: 50%;
    transition: background-color 0.2s;
    z-index: 1;

    &::before {
      content: '';
      position: absolute;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
      width: 24px;
      height: 24px;
      border-radius: 50%;
      background-color: transparent;
      transition: background-color 0.2s;
    }

    &:hover::before {
      background-color: rgba(255, 255, 255, 0.1);
    }

    svg {
      display: block;
      aspect-ratio: 1;
      width: 8px;
      height: auto;
      color: var(--color-primary-contrast);
      position: relative;
      z-index: 1;
    }
  }

  &__dropdown {
    position: absolute;
    top: calc(100% + 4px);
    left: 0;
    right: 0;
    background-color: var(--color-background);
    border: 1px solid var(--color-border);
    border-radius: 8px;
    box-shadow: 0 4px 12px 0 rgba(0, 0, 0, 0.12);
    display: none;
    overflow: hidden;
    z-index: 1000;

    &[data-dropdown-open="true"] {
      display: block;
    }

    &__item {
      display: block;
      padding: 12px 16px;
      font-size: 14px;
      color: var(--color-text-body);
      text-decoration: none;
      transition: background-color 0.2s;
      border: none;
      background: none;
      width: 100%;
      text-align: left;
      cursor: pointer;
      font-family: var(--font-family);

      &:hover {
        background-color: var(--color-background-gray);
        color: var(--color-text-body);
      }

      &:not(:first-child) {
        border-top: 1px solid var(--color-border);
      }
    }
  }
}
```

**ポイント:**
- ボタンとチェブロンアイコンを`position: relative`のラッパーで囲む
- チェブロンアイコンは`position: absolute`でボタン内の右側に配置する
- ボタンに`padding-right`を追加して、チェブロンアイコンのスペースを確保する
- チェブロンアイコンは`type="button"`で、ドロップダウンの開閉のみを担当する
- ドロップダウンメニューは`position: absolute`でボタンの下に配置する
- 送信ボタンが無効化されている場合、チェブロンアイコンも視覚的に無効化する（`opacity: 0.5`、`cursor: not-allowed`）
- チェブロンアイコンのホバー時は、`::before`疑似要素で背景色を変更する

## セクション分割パターン

### サイドバーのセクション分割

サイドバーのコンテンツを複数のセクションに分割する場合は、`__section`を使用します。

**マークアップ:**
```slim
.l-page-content__content__sub.p-user-tag-form__content__sub
  .p-user-tag-form__content__sub__section
    .p-user-tag-form__content__sub__button-wrapper
      button.p-user-tag-form__content__sub__button.p-user-tag-form__content__sub__button--submit type="submit" form="edit_user_tag_form" 変更を保存
    = link_to admin_area_user_tags_path, class: 'p-user-tag-form__content__sub__button p-user-tag-form__content__sub__button--cancel', data: { turbo_frame: '_top' } do
      | キャンセル
  .p-user-tag-form__content__sub__section
    = link_to admin_area_users_path, class: 'p-user-tag-form__content__sub__button p-user-tag-form__content__sub__button--cancel', data: { turbo_frame: '_top' } do
      | ユーザー一覧
  .p-user-tag-form__content__sub__section.p-user-tag-form__content__sub__metadata
    .c-info
      / ... メタデータ ...
```

**スタイル:**
```scss
&__sub {
  display: flex;
  flex-direction: column;
  gap: 0;
  align-content: start;

  &__section {
    padding: 24px;
    display: flex;
    flex-direction: column;
    gap: 16px;
    border-bottom: 1px solid var(--color-border);

    &:last-child {
      border-bottom: none;
      padding-bottom: 0;
    }
  }
}
```

**ポイント:**
- セクション間は`border-bottom`で区切る
- 最後のセクションは`border-bottom: none`で区切り線を削除する
- 各セクションに`padding: 24px`を設定して、適切な余白を確保する
- 親要素の`gap`は`0`に設定し、セクション間の余白は`border-bottom`で視覚的に区切る
- セクション内の要素間の余白は、セクション内の`gap`で制御する

## ナビゲーションのアイコン

### チェブロンアイコンの向きの制御

ナビゲーションのチェブロンアイコンは、開閉状態に応じて向きを変更します。

**スタイル:**
```scss
.l-page-content__navigation__item {
  &__chevron {
    transform: rotate(180deg); // デフォルトで下向き

    &:checked + .l-page-content__navigation__item {
      .l-page-content__navigation__item__chevron {
        transform: none; // 開いたときに上向き
      }
    }
  }
}
```

**ポイント:**
- デフォルトでチェブロンアイコンを下向き（`rotate(180deg)`）に設定
- 開いた状態では`transform: none`で上向きに戻す
- CSSの`:checked`セレクタを使用して状態を制御する

### ナビゲーションの条件分岐による表示切り替え

現在のページに応じて、ナビゲーション項目をリンクとして表示するか、開閉可能なチェックボックス付きの項目として表示するかを切り替えます。

**マークアップ:**
```slim
- if controller_name == 'user_tags'
  input#tags-is-open.l-page-content__navigation__checkbox type="checkbox" checked="checked"
  label.l-page-content__navigation__item for="tags-is-open" class="#{'is-active' if controller_name == 'user_tags' && !params[:id]}"
    span.l-page-content__navigation__item__text タグ
    span.l-page-content__navigation__item__chevron
      = render 'shared/icons/icon-chevron-down'
  .l-page-content__navigation__children
    - UserTag.ordered.limit(20).each do |tag|
      = link_to edit_admin_area_user_tag_path(tag), class: "l-page-content__navigation__children__item #{'is-active' if params[:id].to_s == tag.id.to_s}", data: { turbo_frame: '_top' } do
        = tag.name
- else
  = link_to admin_area_user_tags_path, class: "l-page-content__navigation__item #{'is-active' if controller_name == 'user_tags'}" do
    span.l-page-content__navigation__item__text タグ
```

**ポイント:**
- 現在のコントローラーに応じて、ナビゲーション項目の表示方法を切り替える
- 該当するコントローラーの場合は、チェックボックス付きの開閉可能な項目として表示する
- それ以外の場合は、通常のリンクとして表示する
- チェックボックスの`checked="checked"`属性で、現在のページに応じて初期状態を開いた状態にする
- 親項目のアクティブ状態は、子項目がアクティブでない場合のみ適用する（`controller_name == 'user_tags' && !params[:id]`）
- 子項目のアクティブ状態は、パラメータ（`params[:id]`）で判定する

## 国際化対応

### ISO3166::Countryの翻訳

国名を表示する際は、ISO3166::Countryの翻訳を使用して日本語で表示します。

**マークアップ:**
```slim
.c-info__item
  .c-info__item__label 国
  .c-info__item__value
    - if @user&.contact_address&.country_code.present?
      - country = ISO3166::Country[@user.contact_address.country_code]
      = country&.translations&.dig('ja') || country&.name || @user.contact_address.country_code
    - else
      | -
```

**セレクトボックスでの使用:**
```slim
= f.select :country_code, ISO3166::Country.all.map { |c| [c.translations['ja'] || c.name, c.alpha2] }, { selected: f.object.country_code || 'JP' }, { class: 'c-form-field__input c-form-field__input--select' }
```

**ポイント:**
- `ISO3166::Country`の`translations['ja']`で日本語の国名を取得する
- 翻訳が存在しない場合は`name`をフォールバックとして使用する
- それも存在しない場合は国コードを表示する

## 未実装機能の非表示

### 実装済みでないセクションおよび導線の非表示

実装済みでないセクションや導線（リンク、ボタンなど）は、`unless Rails.env.production?`という条件分岐を使用して本番環境では非表示にします。これにより、開発環境やステージング環境では表示されるが、本番環境では非表示になります。

**重要な原則:**
- **導線が塞がれている場合**（`href='#'`などで機能しない）: 未実装であっても非表示にする必要はない。そのまま表示してよい。
- **導線が機能している場合**（実際にページ遷移やアクションが動作する）: まだ本番環境に出すべきでない場合は、`unless Rails.env.production?`で非表示にする。

**マークアップ例（導線が機能しているが本番非表示）:**
```slim
- unless Rails.env.production?
  = link_to admin_area_dashboard_path, class: 'l-header__container__link' do
    = render 'shared/icons/icon-dashboard'
    span.l-header__container__link__text ダッシュボード
```

**マークアップ例（導線が塞がれている場合）:**
```slim
/ 導線が塞がれている場合は条件分岐不要
= link_to '#', class: 'l-header__container__link' do
  = render 'shared/icons/icon-dashboard'
  span.l-header__container__link__text ダッシュボード
```

**ポイント:**
- 導線が塞がれている（`href='#'`など）場合は、未実装でも表示してよい
- 導線が機能しているが、まだ本番環境に出すべきでない場合は`- unless Rails.env.production?`で囲む
- 本番環境では非表示になり、開発環境やステージング環境では表示される
- 実装が完了したら条件分岐を削除する

**使用例（ナビゲーション）:**
```slim
.l-header__container
  / 導線が機能しているが本番非表示
  - unless Rails.env.production?
    = link_to admin_area_dashboard_path, class: 'l-header__container__link' do
      = render 'shared/icons/icon-dashboard'
      span.l-header__container__link__text ダッシュボード
  / 実装済みの機能（常に表示）
  = link_to admin_area_users_path, class: "l-header__container__link #{'is-active' if controller_name == 'users'}" do
    = render 'shared/icons/icon-user'
    span.l-header__container__link__text ユーザー
  / 導線が塞がれている場合は条件分岐不要（未実装でも表示）
  = link_to '#', class: 'l-header__container__link' do
    = render 'shared/icons/icon-transaction'
    span.l-header__container__link__text 取引
```

## リンクのhover時の色指定

### UIKitとの競合回避

リンク要素（`a`タグ）を使用するコンポーネントでは、UIKitによるデフォルトのhover時の文字色変更と競合する可能性があります。これを回避するため、色変更がない場合でも、hover時に明示的に同じ色を指定して上書きしてください。

**スタイル例:**
```scss
.c-tag-card {
  color: var(--color-text-inactive);
  text-decoration: none;

  &:hover {
    color: var(--color-text-inactive); // 明示的に同じ色を指定
  }
}
```

**ポイント:**
- リンク要素を使用するコンポーネントでは、必ず`:hover`時に色を明示的に指定する
- 色変更がない場合でも、デフォルトの色を`:hover`で再指定することでUIKitのスタイルを上書きする
- これにより、意図しない色変更を防ぐことができる

### マークアップ作業時のチェック項目

リンク要素（`a`タグ、`link_to`ヘルパー）を使用するコンポーネントのスタイルを実装する際は、以下の点を必ず確認してください：

1. **マークアップ作業前の確認**
   - スタイルを実装する前に、このガイドライン（#21）を確認する
   - リンク要素を使用する予定のコンポーネントを特定する

2. **実装時の必須チェック**
   - `link_to`ヘルパーを使用している場合、生成される`a`タグにスタイルを適用する
   - `:hover`疑似クラスを定義する際は、必ず`color`プロパティを明示的に指定する
   - 色を変更しない場合でも、デフォルトの色と同じ値を`:hover`で再指定する

3. **実装例の確認**
   - ボタン風のリンク（キャンセルボタンなど）でも、`link_to`で実装されている場合は同様に`:hover`時の色を指定する
   - `button`要素と`a`要素では扱いが異なるため、要素の種類を意識する

**チェックリスト:**
- [ ] リンク要素（`link_to`）を使用しているか確認した
- [ ] `:hover`疑似クラスを定義した
- [ ] `:hover`内で`color`プロパティを明示的に指定した
- [ ] 色を変更しない場合でも、デフォルトの色と同じ値を指定した

## ドロップダウンの実装

### データ属性による開閉制御

ドロップダウンは、データ属性（`data-dropdown-toggle`、`data-dropdown-open`）を使用して開閉を制御します。

**マークアップ:**
```slim
.c-tag-card-wrapper
  = link_to edit_admin_area_user_tag_path(tag), class: 'c-tag-card', data: { turbo_frame: '_top' } do
    / カードの内容
  .c-tag-card__action-wrapper
    .c-tag-card__action data-dropdown-toggle="dropdown-#{tag.id}"
      = render 'shared/icons/icon-more-vertical'
    .c-tag-card__dropdown id="dropdown-#{tag.id}"
      = link_to admin_area_user_tag_path(tag), data: { turbo_method: :delete, turbo_confirm: '本当に削除しますか？' }, class: 'c-tag-card__dropdown__item'
        | 削除
```

**スタイル:**
```scss
.c-tag-card {
  &__action-wrapper {
    position: absolute;
    top: 24px;
    right: 24px;
    z-index: 10;
  }

  &__dropdown {
    position: absolute;
    top: calc(100% + 4px);
    right: 0;
    background-color: var(--color-background);
    border: 1px solid var(--color-border);
    border-radius: 8px;
    box-shadow: 0 4px 12px 0 rgba(0, 0, 0, 0.12);
    min-width: 120px;
    display: none;
    overflow: hidden;
    z-index: 1000;

    &[data-dropdown-open="true"] {
      display: block;
    }

    &__item {
      display: block;
      padding: 12px 16px;
      font-size: 14px;
      color: var(--color-text-body);
      text-decoration: none;
      transition: background-color 0.2s;

      &:hover {
        background-color: var(--color-background-gray);
        color: var(--color-text-body);
      }
    }
  }
}
```

**JavaScript:**
```typescript
function initDropdownHandlers() {
  document.addEventListener("click", (e) => {
    const target = e.target as HTMLElement;
    const toggle = target.closest("[data-dropdown-toggle]") as HTMLElement;
    const dropdown = target.closest(".c-tag-card__dropdown") as HTMLElement;

    if (toggle) {
      e.preventDefault();
      e.stopPropagation();

      const dropdownId = toggle.getAttribute("data-dropdown-toggle");
      if (!dropdownId) return;

      const targetDropdown = document.getElementById(dropdownId) as HTMLElement;
      if (!targetDropdown) return;

      const isOpen = targetDropdown.getAttribute("data-dropdown-open") === "true";

      // すべてのドロップダウンを閉じる
      document.querySelectorAll("[data-dropdown-open='true']").forEach((d) => {
        d.setAttribute("data-dropdown-open", "false");
      });

      // クリックされたドロップダウンを開閉
      if (!isOpen) {
        targetDropdown.setAttribute("data-dropdown-open", "true");
      }
    } else if (dropdown) {
      // ドロップダウン内のリンククリック時は閉じない（リンクの処理を優先）
      e.stopPropagation();
    } else {
      // ドロップダウン外をクリックした場合は閉じる
      document.querySelectorAll("[data-dropdown-open='true']").forEach((d) => {
        d.setAttribute("data-dropdown-open", "false");
      });
    }
  });
}
```

**ポイント:**
- `data-dropdown-toggle`でドロップダウンのIDを指定し、トグルボタンを識別する
- `data-dropdown-open`で開閉状態を管理する（`"true"`で開く、`"false"`で閉じる）
- イベント委譲を使用して、動的に追加された要素にも対応する
- トグルボタンクリック時は`preventDefault()`と`stopPropagation()`でイベントを制御する
- ドロップダウン内のリンククリック時は`stopPropagation()`で閉じる処理を防ぐ
- ドロップダウン外をクリックした場合はすべてのドロップダウンを閉じる
- アクションボタンは絶対配置でカードの右上に配置する
- ドロップダウンは`z-index: 1000`で他の要素の上に表示する

### カード全体をリンクにする

カード全体をリンクにする場合、アクションボタンは絶対配置で配置し、リンクのクリックと区別します。

**マークアップ:**
```slim
.c-tag-card-wrapper
  = link_to edit_admin_area_user_tag_path(tag), class: 'c-tag-card', data: { turbo_frame: '_top' } do
    .c-tag-card__header
      .c-tag-card__header__title = tag.name
  .c-tag-card__action-wrapper
    .c-tag-card__action data-dropdown-toggle="dropdown-#{tag.id}"
      = render 'shared/icons/icon-more-vertical'
```

**スタイル:**
```scss
.c-tag-card-wrapper {
  position: relative;
}

.c-tag-card {
  // カード全体のスタイル
}

.c-tag-card__action-wrapper {
  position: absolute;
  top: 24px;
  right: 24px;
  z-index: 10;
}
```

**ポイント:**
- カード全体をリンクにする場合、`wrapper`要素を`position: relative`にする
- アクションボタンは`position: absolute`で右上に配置する
- `z-index`でアクションボタンをカードのリンクより上に配置する
- アクションボタンクリック時は`stopPropagation()`でカードのリンク処理を防ぐ

## Stimulusコントローラーの実装パターン

### 動的なDOM要素の生成とStimulusの連携

Stimulusコントローラーで動的にDOM要素を生成する場合、Stimulusの自動スキャン機能を活用します。

**ポイント:**
- 動的に追加された要素に`data-controller`属性を設定すると、Stimulusが自動的にコントローラーを接続する
- `requestAnimationFrame`を使用してDOMの更新を待つ必要はない（Stimulusが自動的に検出する）
- 明示的な`application.load()`呼び出しは不要

**実装例:**
```typescript
// 動的に要素を生成
const block = document.createElement('div');
block.className = 'c-condition-block';
block.setAttribute('data-controller', 'condition-block');

// DOMに追加すると、Stimulusが自動的にコントローラーを接続する
container.appendChild(block);
```

### ユーティリティ関数の活用

複数のコントローラーで共通する処理は、ユーティリティ関数として分離します。

**実装例:**
- `app/frontend/utils/dropdown.ts`: ドロップダウンの開閉制御
- `app/frontend/utils/icons.ts`: SVGアイコンの生成
- `app/frontend/utils/empty-state.ts`: 空状態の表示制御
- `app/frontend/utils/condition-factory.ts`: 条件要素の生成（ファクトリーパターン）
- `app/frontend/utils/condition-block-builder.ts`: 条件ブロックの生成（Builderパターン）

**ポイント:**
- 共通処理をユーティリティ関数に抽出することで、コードの重複を削減
- テストしやすく、保守性が向上
- 型安全性を保ちながら実装

### ファクトリーパターンの使用

条件タイプごとに異なるDOM構造を生成する場合、ファクトリーパターンを使用します。

**実装例:**
```typescript
// app/frontend/utils/condition-factory.ts
export function createCurrentMembershipCondition(
  initializeSelectClass: (select: HTMLSelectElement) => void
): DocumentFragment {
  const fragment = document.createDocumentFragment();
  // 条件タイプに応じたDOM要素を生成
  return fragment;
}

// コントローラーでの使用
const factory = conditionFactories[type];
if (factory) {
  const contentFragment = factory((select) => this.initializeSelectClass(select));
  content.appendChild(contentFragment);
}
```

**ポイント:**
- 条件タイプごとの生成ロジックを分離
- 新しい条件タイプの追加が容易
- コードの可読性と保守性が向上

### Builderパターンの使用

複雑なDOM構造を生成する場合、Builderパターンを使用します。

**実装例:**
```typescript
// app/frontend/utils/condition-block-builder.ts
export class ConditionBlockBuilder {
  static build(blockNumber: number): HTMLElement {
    const block = document.createElement('div');
    // ヘッダー、リスト、追加ボタンなどを構築
    return block;
  }
}

// コントローラーでの使用
const block = ConditionBlockBuilder.build(blockNumber);
container.appendChild(block);
```

**ポイント:**
- 複雑なDOM構造の生成ロジックをカプセル化
- 生成ロジックの変更が容易
- コードの可読性が向上

### ミックスインの活用

複数のコントローラーで共通する機能は、ミックスインとして実装します。

**実装例:**
```typescript
// app/frontend/controllers/admin_area/dropdown_mixin.ts
export const DropdownMixin = {
  handleOutsideClick(event: Event, dropdownSelectors: string[] = []): void {
    // 外部クリック処理
  },
};

// コントローラーでの使用
private handleOutsideClick(event: Event) {
  DropdownMixin.handleOutsideClick(event, ['.c-condition-block__dropdown']);
}
```

**ポイント:**
- 共通機能をミックスインとして分離
- 複数のコントローラーで再利用可能
- コードの重複を削減

### SCSSのmixin化

ドロップダウンなどの共通スタイルは、SCSSのmixinとして定義します。

**実装例:**
```scss
// app/frontend/stylesheets/admin_area/object/component/_dropdown.scss
@mixin dropdown-base {
  position: absolute;
  background-color: var(--color-background);
  border: 1px solid var(--color-border);
  // ... 共通スタイル
}

@mixin dropdown-item {
  display: block;
  padding: 12px 16px;
  // ... 共通スタイル
}

// 使用例
.c-condition-block {
  &__header__dropdown {
    @include dropdown-base;
    top: calc(100% + 4px);
    right: 0;

    &__item {
      @include dropdown-item;
    }
  }
}
```

**ポイント:**
- 共通スタイルをmixinとして定義することで、コードの重複を削減
- スタイルの変更が容易
- 一貫性のあるデザインを維持

### 期間設定コンポーネントの実装

期間設定のような複雑なフォーム要素は、Stimulusコントローラーで制御します。

**マークアップ:**
```slim
.c-period-settings data-controller="period-settings"
  .c-period-settings__select
    select data-period-settings-target="select" data-action="change->period-settings#handleChange"
      option value="none" 期間設定なし
      option value="relative" 相対的に期間を指定する
      option value="fixed" 固定の期間を指定する
  .c-period-settings__content data-period-settings-target="content"
    .c-period-settings__relative data-period-settings-target="relative" style="display: none;"
      / 相対期間のフィールド
    .c-period-settings__fixed data-period-settings-target="fixed"
      / 固定期間のフィールド
```

**ポイント:**
- 選択値に応じて表示するセクションを切り替える
- `data-period-settings-target`でStimulusのターゲットを指定
- `data-action`でイベントハンドラーを指定

### 日付ピッカーの実装

日付選択には、モーダル内に年月日のselectタグを配置したdatepickerを実装します。

**マークアップ:**
```slim
/ 日付表示部分（クリック可能）
.c-period-settings__fixed__argument data-action="click->period-settings#openDatepicker" data-date-type="start"
  span.c-period-settings__fixed__argument__text 2025/01/01

/ モーダル内のdatepicker
.c-datepicker data-controller="datepicker"
  .c-datepicker__fields
    select.c-datepicker__field data-datepicker-target="year"
      option value="2025" 2025
    .c-datepicker__unit 年
    select.c-datepicker__field data-datepicker-target="month"
      option value="1" 1
    .c-datepicker__unit 月
    select.c-datepicker__field data-datepicker-target="day"
      option value="1" 1
    .c-datepicker__unit 日
  button type="button" data-action="select-date" 選択
```

**ポイント:**
- 日付表示部分をクリックするとモーダルが開く
- モーダル内で年月日を選択
- 選択した日付を表示部分に反映
- Turbo Frameを使用してモーダルコンテンツを動的に読み込む

### 条件ブロックの動的生成

条件ブロックは、Stimulusコントローラーで動的に生成・管理します。

**マークアップ:**
```slim
.c-form-section__content data-controller="condition-blocks"
  .c-form-section__content__blocks data-condition-blocks-target="blocks"
  .c-form-section__content__empty data-condition-blocks-target="empty"
    .c-form-section__content__empty__text 条件ブロックがありません
  button.c-form-section__add-block type="button" data-action="click->condition-blocks#addBlock"
    = render 'shared/icons/icon-plus'
    span.c-form-section__add-block__text 条件ブロックを追加
```

**ポイント:**
- 条件ブロックは動的に追加・削除可能
- 空状態の表示/非表示を自動制御
- Builderパターンを使用してブロックを生成
- 各ブロック内で条件を追加・削除可能

### 空状態の動的管理

空状態の表示/非表示は、ユーティリティ関数で統一管理します。

**実装例:**
```typescript
// app/frontend/utils/empty-state.ts
export function updateEmptyState(
  container: HTMLElement,
  emptyElement: HTMLElement,
  itemSelector: string
): void {
  const items = container.querySelectorAll(itemSelector);
  const hasItems = items.length > 0;
  emptyElement.style.display = hasItems ? 'none' : 'flex';
}

// コントローラーでの使用
private updateEmptyState() {
  updateEmptyStateUtil(
    this.listTarget,
    this.emptyTarget,
    '.c-condition-block__item'
  );
}
```

**ポイント:**
- 空状態の表示/非表示ロジックを統一
- 複数のコントローラーで再利用可能
- コードの重複を削減

### モーダルのパディング制御

モーダルのボディにパディングを持たせない場合は、`--no-padding`モディファイアを使用します。

**マークアップ:**
```slim
.c-modal__dialog__body.c-modal__dialog__body--no-padding
  / パディングなしのコンテンツ
```

**スタイル:**
```scss
.c-modal__dialog__body {
  &--no-padding {
    padding: 0;
  }
}
```

**ポイント:**
- タグピッカーのような表形式のコンテンツでは、パディングなしのモーダルを使用
- モディファイアで柔軟に制御

## 参考

- [BEM記法](http://getbem.com/)
- [CSS変数の使用](app/frontend/stylesheets/admin_area/foundation/_variables.scss)
- [既存のコンポーネント例](app/frontend/stylesheets/admin_area/object/component/)

