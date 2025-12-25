---
name: figma
description: Fetch design information from Figma using the API. Use when applying designs from Figma, extracting styles, colors, fonts, or layout information. Requires FIGMA_TOKEN environment variable.
---

# Figma Design Fetcher

Figma APIを使用してデザイン情報を取得し、CSSやスタイル情報を抽出するSkillです。

## 環境変数

```bash
export FIGMA_TOKEN="your-figma-personal-access-token"
```

## 使い方

### 1. FigmaのURLからfile_keyとnode_idを抽出

FigmaのURL形式:
```
https://www.figma.com/design/{file_key}/{file_name}?node-id={node_id}
```

例:
- URL: `https://www.figma.com/design/dOd0KjODECcrKVCK8F8MkI/MyDesign?node-id=2-2`
- file_key: `dOd0KjODECcrKVCK8F8MkI`
- node_id: `2-2`

### 2. デザイン情報を取得

```bash
# ファイル全体の情報を取得
curl -s -H "X-Figma-Token: $FIGMA_TOKEN" \
  "https://api.figma.com/v1/files/{file_key}"

# 特定ノードの情報を取得
curl -s -H "X-Figma-Token: $FIGMA_TOKEN" \
  "https://api.figma.com/v1/files/{file_key}/nodes?ids={node_id}"

# 画像をエクスポート
curl -s -H "X-Figma-Token: $FIGMA_TOKEN" \
  "https://api.figma.com/v1/images/{file_key}?ids={node_id}&format=png&scale=2"
```

### 3. スタイル情報の抽出

Figma APIのレスポンスから以下を抽出:

- **色**: `fills[].color` (RGBA 0-1形式)
- **フォント**: `style.fontFamily`, `style.fontSize`, `style.fontWeight`
- **サイズ**: `absoluteBoundingBox.width`, `absoluteBoundingBox.height`
- **余白**: `paddingLeft`, `paddingRight`, `paddingTop`, `paddingBottom`
- **角丸**: `cornerRadius`
- **影**: `effects[].type === "DROP_SHADOW"`

### 4. 色の変換

Figma APIの色 (0-1) → CSS (0-255):
```
r: Math.round(color.r * 255)
g: Math.round(color.g * 255)
b: Math.round(color.b * 255)
a: color.a
```

## APIエンドポイント

| エンドポイント | 説明 |
|---------------|------|
| `GET /v1/files/:file_key` | ファイル全体のドキュメントツリー |
| `GET /v1/files/:file_key/nodes?ids=:ids` | 特定ノードの詳細情報 |
| `GET /v1/images/:file_key?ids=:ids&format=png` | ノードを画像としてエクスポート |
| `GET /v1/files/:file_key/styles` | ファイルのスタイル一覧 |

## スクリプト

デザイン情報取得:
```bash
.claude/skills/figma/scripts/fetch_design.sh {file_key} {node_id}
```

## 出力例

```json
{
  "colors": {
    "primary": "#3B82F6",
    "background": "#FFFFFF",
    "text": "#1F2937"
  },
  "typography": {
    "heading": { "fontFamily": "Inter", "fontSize": 24, "fontWeight": 700 },
    "body": { "fontFamily": "Inter", "fontSize": 16, "fontWeight": 400 }
  },
  "spacing": {
    "containerPadding": 24,
    "elementGap": 16
  },
  "borderRadius": 8
}
```
