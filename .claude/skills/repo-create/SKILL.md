---
name: repo-create
description: |
  GitHubリポジトリを新規作成・初期化。ghコマンド使用。
  トリガー例: 「リポジトリを作成」「GitHubリポジトリ」「repo-create」「gh repo create」
allowed-tools: Bash, Write, Glob, Grep
arguments: auto-detect
user-invocable: true
---

# GitHub Repository Creator

GitHubリポジトリを新規作成・初期化します。

## 前提条件

- GitHub CLI (`gh`) がインストール済み
- `gh auth login` で認証済み

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
   - README.md
   - .gitignore（言語自動検出）
   - LICENSE（選択プロンプト）

4. **initial commit**
   ```bash
   git add .
   git commit -m "Initial commit"
   git push -u origin main
   ```

5. **完了メッセージ**
   - リポジトリURL
   - 次のステップ

## 使用例

```bash
/repo-create my-awesome-project
/repo-create my-app --private --description "My awesome app"
/repo-create my-lib --clone
```
