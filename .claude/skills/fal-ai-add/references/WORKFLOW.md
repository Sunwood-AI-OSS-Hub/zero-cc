# fal-ai-add Workflow Guide

このガイドは、新しいfal.aiモデルを追加する際のワークフローを説明します。

## ワークフロー概要

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Step 1:        │───▶│  Step 2:        │───▶│  Step 3:        │
│  情報収集         │    │  スクリプト生成     │    │  ドキュメント更新  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                      │
                                                      ▼
                                            ┌─────────────────┐
                                            │  Step 4:        │
                                            │  動作確認        │
                                            └─────────────────┘
```

---

## Step 1: 情報収集

ユーザーから新しいモデルの情報を収集します。

### 必須情報

| 項目 | 説明 | 例 |
|:-----|------|:---|
| **モデルID** | fal.aiのモデル識別子 | `fal-ai/qwen-image-2512/lora` |
| **モデルタイプ** | モデルの種類 | T2I, I2I, I2V |
| **モデル名** | 表示用の名前 | Qwen Image 2512 |
| **機能説明** | 何ができるか | テキストから画像を生成 |

### オプション情報

| 項目 | 説明 |
|:-----|------|
| **入力パラメータ** | モデルが受け取るパラメータ一覧 |
| **出力形式** | 生成されるファイル形式 |
| **特殊機能** | LoRA対応、カメラ制御など |

### 質問テンプレート

```
1. モデルIDは何ですか？（例: fal-ai/new-model）
2. どんなタイプのモデルですか？
   - T2I: テキストから画像
   - I2I: 画像から画像（編集）
   - I2V: 画像から動画
   - Other: その他
3. モデルの名前は何と呼びますか？
4. このモデルは何ができますか？簡潔に説明してください
5. 特別なパラメータはありますか？
```

---

## Step 2: スクリプト生成

モデルタイプに応じたスクリプトを生成します。

### スクリプト命名規則

| モデルタイプ | ファイル名プレフィックス | 例 |
|:------------|:----------------------|:---|
| T2I | `t2i-{model-name}.ts` | `t2i-qwen-image-2512.ts` |
| I2I | `i2i-{model-name}.ts` | `i2i-qwen-image-edit-2511.ts` |
| I2V | `i2v-{model-name}.ts` | `i2v-ltx-2.ts` |

### スクリプト構成要素

生成されるスクリプトは以下の要素を含みます：

```typescript
#!/usr/bin/env tsx
/**
 * {filename}
 *
 * MODEL: {model-id}
 * TYPE: {model-type}
 *
 * 説明文
 *
 * 使用方法:
 *   node {filename} --input xxx --param yyy
 */

import { fal } from "@fal-ai/client";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import dotenv from "dotenv";

// 環境設定
// 型定義
// コマンドライン引数解析
// メイン処理
```

### 既存スクリプトからのコピー

既存のスクリプトをテンプレートとして使用：

```bash
# T2Iモデルの場合
cp .claude/skills/fal-ai/scripts/t2i-qwen-image-2512.ts \
   .claude/skills/fal-ai/scripts/t2i-{new-model}.ts

# I2Iモデルの場合
cp .claude/skills/fal-ai/scripts/i2i-qwen-image-edit-2511.ts \
   .claude/skills/fal-ai/scripts/i2i-{new-model}.ts

# I2Vモデルの場合
cp .claude/skills/fal-ai/scripts/i2v-ltx-2.ts \
   .claude/skills/fal-ai/scripts/i2v-{new-model}.ts
```

---

## Step 3: ドキュメント更新

関連ドキュメントを更新します。

### 3.1 MODELS.md の更新

新しいモデルセクションを追加：

```markdown
## {N}. {Model Name} ({機能})

**モデルID**: `{model-id}`

**機能**: {機能説明}

### 入力パラメータ

| パラメータ | 型 | デフォルト | 説明 |
|-----------|------|-----------|------|
| `param1` | string | 必須 | 説明 |
| `param2` | number | 10 | 説明 |

### プロンプトの例

```
"Example prompt 1"
"Example prompt 2"
```
```

### 3.2 SKILL.md の更新（必要な場合）

新しい機能をSKILL.mdの機能セクションに追加：

```markdown
## 機能

- **{新機能}**: 説明
- **既存機能**: 説明
```

### 3.3 更新対象ファイルのパス

```
.claude/skills/fal-ai/
├── SKILL.md
└── references/
    └── MODELS.md
```

---

## Step 4: 動作確認

追加したモデルが正常に動作するか確認します。

### 確認項目

| 項目 | 確認内容 |
|:-----|----------|
| **スクリプト実行** | ヘルプメッセージが表示されるか |
| **型チェック** | TypeScriptコンパイルエラーがないか |
| **ドキュメント** | 追加内容が正しく記載されているか |
| **スキル認識** | Claude Codeが新しいスクリプトを認識するか |

### テストコマンド

```bash
# ヘルプメッセージ確認
node .claude/skills/fal-ai/scripts/{new-script}.ts

# 型チェック
cd .claude/skills/fal-ai/scripts
npx tsc --noEmit

# スキル再読み込み（Claude Code再起動）
```

---

## 完了チェックリスト

すべて完了したら、以下を確認：

- [ ] スクリプトが正しい位置に作成されている
- [ ] スクリプトのヘッダーコメントが正しい
- [ ] MODELS.mdにモデル情報が追加されている
- [ ] SKILL.mdが更新されている（必要な場合）
- [ ] スクリプトがエラーなく実行できる
- [ ] モデルIDが正しい

---

## トラブルシューティング

### 問題: スクリプトが実行できない

**解決策**:
1. TypeScriptコンパイルエラーを確認
2. 環境変数FAL_KEYが設定されているか確認
3. 依存関係がインストールされているか確認

### 問題: モデルが見つからない

**解決策**:
1. モデルIDが正しいか確認
2. fal.aiのドキュメントを確認
3. APIキーに必要な権限があるか確認

### 問題: ドキュメントのフォーマットが崩れている

**解決策**:
1. Markdownの構文を確認
2. テーブルのフォーマットを確認
3. 既存のセクションと同じフォーマットに統一
