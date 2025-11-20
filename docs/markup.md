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
12. [モーダルの実装方法](#モーダルの実装方法)
13. [モーダルのタイトルセクション](#モーダルのタイトルセクション)
14. [Enumerizeの表示方法](#enumerizeの表示方法)
15. [空状態の表示](#空状態の表示)
16. [フォームの構造](#フォームの構造)
17. [ナビゲーションのアイコン](#ナビゲーションのアイコン)
18. [国際化対応](#国際化対応)
19. [未実装機能の非表示](#未実装機能の非表示)

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
- [ ] 関連する2つのフィールドを横並びに配置する場合は`label-group`と`input-group`を使用しているか
- [ ] enumerizeの値を表示する場合は`.text`メソッドを使用しているか
- [ ] Turbo Frame内の動的に追加された要素にも対応するため、イベント委譲を使用しているか
- [ ] キャンセルボタンには`--color-text-inactive`を使用しているか
- [ ] データが存在しない場合は`c-empty`コンポーネントを使用して空状態を表示しているか
- [ ] データの有無に応じてボタンのラベルを適切に変更しているか
- [ ] フォームパーシャル内で`.c-form`を定義しているか
- [ ] ナビゲーションのアイコンの向きを状態に応じて変更しているか
- [ ] 国際化が必要な場合は適切な翻訳を使用しているか
- [ ] アイコンの配置は`display: grid; place-items: center;`を使用しているか
- [ ] ネイティブUI要素（datetime-local等）のカスタマイズが必要な場合は適切に対応しているか
- [ ] `readonly`属性と`disabled`属性の使い分けが適切か
- [ ] モーダルを使用する場合はTurbo Frameと連携しているか
- [ ] モーダルの開閉は`data-modal-open`属性で制御しているか
- [ ] モーダルを閉じる際にTurbo Frameの内容をクリアしているか
- [ ] 導線が機能しているが本番非表示の場合は`unless Rails.env.production?`で非表示にしているか（導線が塞がれている場合は非表示不要）

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

## 参考

- [BEM記法](http://getbem.com/)
- [CSS変数の使用](app/frontend/stylesheets/admin_area/foundation/_variables.scss)
- [既存のコンポーネント例](app/frontend/stylesheets/admin_area/object/component/)

