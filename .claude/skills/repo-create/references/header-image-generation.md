# Header Image Generation with fal.ai Nano Banana Pro

リポジトリ用ヘッダー画像を fal.ai Nano Banana Pro (Google Gemini 3 Pro Image) で生成するガイド。

## 概要

Nano Banana Pro は高度なテキスト描画とキャラクターの一貫性に対応した画像生成モデル。
エレガントなフォントとスタイリッシュなデザインで、リポジトリのブランドイメージを強化できる。

## 実行コマンド

```bash
npx tsx .claude/skills/fal-ai/scripts/t2i-nano-banana-pro.ts "<prompt>" \
  --size 16:9 \
  --resolution 2k \
  --format png \
  --output ./assets
```

### パラメータ

| パラメータ | 値 | 説明 |
|:--|:--|:--|
| `--size` | `16:9` (推奨) | ヘッダー画像に最適なアスペクト比 |
| `--resolution` | `2k` (推奨) | 高品質な画像品質 |
| `--format` | `png` | 透明度対応・高品質 |

## プロンプト構築テンプレート

### 基本構造

```
A beautiful GitHub repository header banner for "{PROJECT_NAME}",
{STYLE_DESCRIPTION},
{COLOR_SCHEME},
elegant typography with serif and sans-serif fonts,
professional modern design,
high quality, 4K, cinematic lighting
```

### スタイル別プロンプト

#### AI/ML プロジェクト

```
A futuristic GitHub repository header banner for "{PROJECT_NAME}",
neural network patterns and glowing data streams,
deep blue and purple gradient background with cyan accents,
elegant modern typography with clean sans-serif fonts,
artificial intelligence theme,
professional tech design,
cinematic lighting, high quality, 4K
```

#### Web フロントエンド

```
A vibrant GitHub repository header banner for "{PROJECT_NAME}",
abstract geometric shapes and flowing gradients,
modern gradient from teal to purple with pink accents,
elegant typography with contemporary fonts,
web development theme,
sleek modern design,
cinematic lighting, high quality, 4K
```

#### バックエンド/API

```
A professional GitHub repository header banner for "{PROJECT_NAME}",
abstract server architecture and network connections,
dark blue and cyan color scheme with white accents,
clean elegant typography with professional fonts,
backend infrastructure theme,
minimalist modern design,
cinematic lighting, high quality, 4K
```

#### モバイルアプリ

```
A creative GitHub repository header banner for "{PROJECT_NAME}",
abstract mobile device shapes and flowing UI elements,
warm orange and red gradient with golden accents,
elegant bold typography with modern fonts,
mobile app development theme,
vibrant modern design,
cinematic lighting, high quality, 4K
```

#### データ/インフラ

```
A clean GitHub repository header banner for "{PROJECT_NAME}",
abstract data visualization and cloud infrastructure,
cyan and blue gradient with teal accents,
elegant typography with technical fonts,
data engineering theme,
professional modern design,
cinematic lighting, high quality, 4K
```

#### セキュリティ/ハッキング

```
A mysterious GitHub repository header banner for "{PROJECT_NAME}",
matrix-style code rain and cyber security elements,
dark background with neon green accents,
elegant typography with monospace-inspired fonts,
cybersecurity theme,
dark modern design,
cinematic lighting, high quality, 4K
```

#### ゲーム開発

```
An exciting GitHub repository header banner for "{PROJECT_NAME}",
abstract game elements and dynamic particles,
purple and magenta gradient with pink accents,
bold elegant typography with playful fonts,
game development theme,
energetic modern design,
cinematic lighting, high quality, 4K
```

#### 緑/環境系

```
A fresh GitHub repository header banner for "{PROJECT_NAME}",
organic shapes and leaf-inspired patterns,
green gradient with lime and teal accents,
elegant typography with nature-inspired fonts,
sustainability theme,
clean modern design,
cinematic lighting, high quality, 4K
```

## エレガントなフォント指定

プロンプトに含めるフォント関連のキーワード:

### フォントスタイル
- `elegant serif typography` - 上品なセリフ体
- `clean sans-serif fonts` - すっきりしたサンセリフ体
- `modern contemporary typography` - モダンなタイポグラフィ
- `professional corporate fonts` - プロフェッショナルなフォント
- `minimalist typography` - ミニマルな書体

### 文字装飾
- `subtle text shadow` - 繊細なテキストシャドウ
- `elegant text glow effect` - エレガントなグロー効果
- `gradient text fill` - グラデーションテキスト
- `refined letter spacing` - 上品な文字間隔

## カラースキーム

| カテゴリ | 背景色 | アクセント色 |
|:--|:--|:--|
| AI/ML | 深紫、紺 | シアン、マゼンダ |
| Web | ティール、紫 | ピンク、イエロー |
| Backend | 濃紺、シアン | ホワイト、ライトブルー |
| Mobile | オレンジ、赤 | ゴールド、ピンク |
| Data | シアン、青 | ティール、グリーン |
| Security | 黒、ダークグレー | ネオングリーン |
| Game | 紫、マゼンダ | ピンク、イエロー |
| Green | グリーン、ライム | ティール、イエロー |

## 生成フロー

1. **リポジトリタイプの特定**
   - README.md や package.json から技術スタックを推測
   - 適切なスタイルテンプレートを選択

2. **プロンプトの構築**
   - プロジェクト名を `{PROJECT_NAME}` に置換
   - 必要に応じてサブタイトルを追加
   - スタイルとカラースキームを適用

3. **画像生成の実行**
   ```bash
   npx tsx .claude/skills/fal-ai/scripts/t2i-nano-banana-pro.ts "<constructed-prompt>" \
     --size 16:9 \
     --resolution 2k \
     --format png \
     --output ./assets
   ```

4. **ファイル名の変更**
   - 生成されたファイルを `header.png` にリネーム
   - README.md の画像パスを更新

## README.md への埋め込み

```markdown
<img src="assets/header.png" alt="{PROJECT_NAME} Header" width="100%">

# {PROJECT_NAME}

{DESCRIPTION}
```

## 注意事項

- Nano Banana Pro はテキスト描画に優れるが、複雑なテキストは調整が必要
- 日本語テキストは英訳してプロンプトに含めることを推奨
- 複数枚生成して最適なものを選択してもよい
- シード値を固定すると再現性が確保できる（`--seed <number>`）
