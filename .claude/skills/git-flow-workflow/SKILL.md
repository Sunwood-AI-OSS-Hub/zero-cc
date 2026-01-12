---
name: git-flow-workflow
description: |
  Git Flow ワークフローで開発からマージまでを実行。
  「フィーチャーブランチ作って」「PR出して」「コードレビューして」「マージして」などのリクエスト時に使用。
  develop → main のリリースフローもサポート。
allowed-tools: Bash, Glob, Grep, Read, Write
user-invocable: true
---

# Git Flow Workflow

Git Flow ワークフローでフィーチャーブランチの作成からマージ・クリーンアップまでを支援します。

## ワークフロー

### Step 1: 現状確認

```bash
git status
git branch -vv
git log --oneline -5
```

- カレントブランチの確認
- 未コミット変更の有無
- リモートとの同期状態

### Step 2: フィーチャーブランチ作成

**ブランチ名の決定:**
```
feature/<description>

例:
feature/repo-create-refs
feature/add-auth-system
feature/fix-login-bug
```

```bash
# develop から作成（なければ main から）
git checkout develop 2>/dev/null || git checkout main
git pull

# ブランチ作成
git checkout -b feature/<name>
```

### Step 3: 開発・コミット

**コミットメッセージ形式:**
```
<type>: <subject>

[optional body]

Co-Authored-By: Claude <noreply@anthropic.com>
```

**タイプ:**
- `feat` - 新機能
- `fix` - バグ修正
- `docs` - ドキュメント
- `style` - フォーマット
- `refactor` - リファクタリング
- `test` - テスト
- `chore` - その他

**コミット例:**
```bash
git add <files>
git commit -m "feat: add user authentication

- Implement JWT-based authentication
- Add login/logout endpoints
- Include password hashing

Co-Authored-By: Claude <noreply@anthropic.com>"
```

### Step 4: プッシュ

```bash
git push -u origin feature/<name>
```

### Step 5: プルリクエスト作成

**タイトル形式:**
```
<type>: <subject>

例:
feat(repo-create): add comprehensive reference templates
fix(auth): resolve JWT token expiration issue
```

**PR 作成:**
```bash
gh pr create \
  --title "feat(scope): description" \
  --body "PR body here"
```

**PR ボディンテンプレート:**
```markdown
## Summary

[1-2行で変更内容を説明]

## Changes

- 変更点1
- 変更点2

## Test plan

- [x] テスト項目1
- [x] テスト項目2

---

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Step 6: コードレビュー対応

**gemini-code-assist などのレビュー確認:**
```bash
gh pr view <number> --json comments
```

**修正コミット:**
```bash
# 修正をコミット（同じブランチにプッシュ）
git add <files>
git commit -m "fix: resolve review feedback"
git push
```

### Step 7: develop へのマージ

**Git Flow の正しい順序:**
```
feature → develop → main
```

```bash
# develop に切り替え
git checkout develop
git pull

# feature ブランチをマージ
git merge feature/<name> --no-ff
git push origin develop
```

### Step 8: main へのリリースマージ

**リリース時のみ実行:**

```bash
# main に切り替え
git checkout main
git pull

# develop をマージ（--no-ff または --squash）
git merge develop --no-ff
git push origin main

# タグ付け（任意）
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

### Step 9: クリーンアップ

```bash
# ローカルブランチ削除
git branch -d feature/<name>

# リモートブランチ削除
git push origin --delete feature/<name>

# リモートの追跡ブランチをクリーンアップ
git fetch --prune
```

## ブランチ構造

```
main           ← 本番環境（リリース時のみ更新）
  ↑
develop        ← 開発統合ブランチ
  ↑
feature/*      ← フィーチャーブランチ（各機能開発）
```

## クイックリファレンス

### コマンド一覧

| 操作 | コマンド |
|:--|:--|
| ブランチ作成 | `git checkout -b feature/<name>` |
| プッシュ | `git push -u origin feature/<name>` |
| PR 作成 | `gh pr create --title "..." --body "..."` |
| develop へマージ | `git merge feature/<name> --no-ff` |
| ブランチ削除 | `git branch -d feature/<name>` |
| リモート削除 | `git push origin --delete feature/<name>` |

### develop が存在しない場合

```bash
# main から develop を作成
git checkout main
git pull
git checkout -b develop
git push -u origin develop
```

## ベストプラクティス

✅ **やるべきこと:**
- develop から feature ブランチを作成
- Conventional Commits 形式でコミット
- PR ボディに詳細な説明を記載
- コードレビューを受けてからマージ
- マージ済みブランチは削除

❌ **やるべきでないこと:**
- feature ブランチを直接 main にマージ
- リモートの main に直接プッシュ
- マージせずにブランチを放置
- `git push --force` を使用

## 使用例

```bash
# フィーチャーブランチ作成からマージまで
/git-flow-workflow フィーチャーブランチ作って
# → develop から feature/xxx を作成

# PR 作成
/git-flow-workflow PR出して
# → gh pr create を実行

# マージ
/git-flow-workflow マージして
# → feature → develop にマージ

# クリーンアップ
/git-flow-workflow ブランチ削除して
# → マージ済みブランチを削除
```
