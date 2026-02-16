---
name: repo-create
description: |
  GitHubリポジトリを新規作成・初期化。ghコマンド使用。
  トリガー例: 「リポジトリを作成」「GitHubリポジトリ」「repo-create」「gh repo create」
allowed-tools: Bash, Write, Glob, Grep, Task
arguments: auto-detect
user-invocable: true
---

# GitHub Repository Creator

GitHubリポジトリを新規作成・初期化します。

## 前提条件

- GitHub CLI (`gh`) がインストール済み
- `gh auth login` で認証済み
- fal.ai APIキー (`FAL_KEY`) が `.env` に設定済み（ヘッダー画像生成用）

## ワークフロー

### 1. 引数解析
`$ARGUMENTS` からリポジトリ名とオプションを特定:

- `repo-create [name]` → リポジトリ名
- `--public` / `--private` → 可視性（デフォルト: public）
- `--description` / `-d` → 説明
- `--clone` → カレントディレクトリにclone

### 2. 作成手順

1. **リポジトリ名の決定**
   - 引数指定 → 使用
   - 未指定 → カレントディレクトリ名を使用

2. **GitHubリポジトリ作成**
   ```bash
   gh repo create [name] --[public|private] --description "[description]"
   ```

3. **初期ファイル生成**（--clone 指定時）

   詳細は [references/](references/) を参照:
   - `README-template.md` - README.md テンプレート
   - `LICENSE-options.md` - ライセンス選択ガイド
   - `badges.md` - バッジ一覧
   - `EXAMPLES.md` - 使用例

   **生成するファイル:**
   - `README.md` - テンプレートをベースに作成
   - `.gitignore` - 言語自動検出（`gh repo create` のデフォルト）
   - `LICENSE` - 選択プロンプト（MIT/Apache-2.0/GPL-3.0等）→ See [LICENSE-options.md](references/LICENSE-options.md)
   - `assets/` - 画像用ディレクトリ作成

4. **ヘッダー画像生成**（fal.ai Nano Banana Pro）

   詳細は [references/header-image-generation.md](references/header-image-generation.md) を参照。

   **手順:**
   1. リポジトリの内容を分析して適切なスタイルとカラーマップを選択
   2. エレガントなフォントを使用したヘッダー画像のプロンプトを構築
   3. Nano Banana Pro で画像生成
   4. 生成された画像を `assets/header.png` にリネームして保存

   **実行コマンド:**
   ```bash
   npx tsx .claude/skills/fal-ai/scripts/t2i-nano-banana-pro.ts "<prompt>" --size 16:9 --resolution 2k --format png --output ./assets
   ```

5. **Initial Commit**
   ```bash
   git init
   git branch -M main
   git add .
   git commit -m "Initial commit"
   git push -u origin main
   ```

6. **完了メッセージ**
   - リポジトリURL
   - 次のステップ

## 使用例

詳細な使用例は [references/EXAMPLES.md](references/EXAMPLES.md) を参照。

```bash
/repo-create my-awesome-project
/repo-create my-app --private --description "My awesome app"
/repo-create my-lib --clone
```
