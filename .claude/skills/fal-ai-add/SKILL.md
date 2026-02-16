---
name: fal-ai-add
description: fal.aiスキルに新しいモデルを追加するためのスキル
allowed-tools:
  - Bash(node .claude/skills/fal-ai-add/scripts/*)
  - Read
  - Write
  - Edit
  - Glob
triggers:
  - "fal.*追加"
  - "追加.*モデル"
  - "add.*model"
  - "新しい.*fal"
  - "モデルを追加"
---

# fal-ai-add Skill

fal.aiスキルに新しいモデルを追加するためのスキル。

## 機能

- **モデル情報収集**: ユーザーから新しいfal.aiモデルの情報を収集
- **スクリプト生成**: モデル用のTypeScriptスクリプトを自動生成
- **ドキュメント更新**: MODELS.mdとSKILL.mdを自動更新
- **設定ファイル更新**: package.json等の依存関係を管理

## 使用方法

```
「fal-aiに新しいモデルを追加して」
「fal-ai-addで新しい動画生成モデルを追加」
「Falの新しいモデルをスキルに追加して」
```

## ワークフロー

### Step 1: モデル情報収集

ユーザーから以下の情報を収集：

1. **モデルID**: fal.aiのモデルID（例: `fal-ai/new-model`）
2. **モデルタイプ**: T2I / I2I / I2V / Other
3. **モデル名**: 分かりやすい名前（例: New Model 2024）
4. **機能説明**: モデルの機能を簡潔に説明
5. **入力パラメータ**: 必須・オプションのパラメータ一覧

### Step 2: スクリプト生成

モデルタイプに応じてテンプレートからスクリプトを生成：

| タイプ | スクリプト命名規則 |
|:------|:------------------|
| T2I | `t2i-{model-name}.ts` |
| I2I | `i2i-{model-name}.ts` |
| I2V | `i2v-{model-name}.ts` |

### Step 3: ドキュメント更新

- `fal-ai/references/MODELS.md` にモデル仕様を追加
- `fal-ai/SKILL.md` に新しい機能を追加（必要な場合）

### Step 4: 依存関係更新

必要に応じて`package.json`を更新

## スクリプト実行例

```bash
# スクリプトテンプレート生成
node .claude/skills/fal-ai-add/scripts/add-model.ts --type t2i --model-id "fal-ai/new-model"

# ドキュメント更新
node .claude/skills/fal-ai-add/scripts/add-model.ts --update-docs --model-id "fal-ai/new-model"
```

## 詳細ドキュメント

- [ワークフローガイド](references/WORKFLOW.md)
- [チェックリスト](references/CHECKLIST.md)

## 更新対象ファイル

このスキルは以下のファイルを更新します：

```
.claude/skills/fal-ai/
├── SKILL.md                    ← 新機能の追加
├── references/
│   └── MODELS.md               ← 新モデルの仕様追加
└── scripts/
    ├── t2i-*.ts                ← 新規生成
    ├── i2i-*.ts                ← 新規生成
    ├── i2v-*.ts                ← 新規生成
    └── package.json            ← 依存関係更新（必要な場合）
```

## 注意事項

- 既存のスクリプトを上書きすることはありません
- 更新前には必ずユーザーに確認します
- スクリプトは既存のパターンに従って生成されます
