# GitHub Project Manager - コマンドリファレンス

このドキュメントでは、GitHub プロジェクト管理で使用するコマンドの詳細を説明します。

## 目次

1. [Issue 関連](#issue-関連)
2. [ラベル関連](#ラベル関連)
3. [プロジェクト関連](#プロジェクト関連)
4. [マイルストーン関連](#マイルストーン関連)
5. [日付設定](#日付設定)
6. [ステータス変更](#ステータス変更)

---

## Issue 関連

### Issue 作成

```bash
gh issue create --title "タイトル" --body "本文" --label "label1,label2"
```

**オプション:**
- `--title`: Issue のタイトル
- `--body`: Issue の本文（Markdown 可）
- `--label`: カンマ区切りでラベルを指定

**例:**
```bash
gh issue create \
  --title "テスト Issue 1: スキル機能の改善" \
  --body "## 概要\n\nAgent ZERO のスキル機能を改善する。" \
  --label "enhancement,good first issue"
```

### Issue 編集

```bash
gh issue edit ISSUE番号 --add-label "label1,label2"
```

**例:**
```bash
# ラベル追加
gh issue edit 7 --add-label "test"

# マイルストーン設定（API 使用）
gh api --method PATCH /repos/OWNER/REPO/issues/7 -f milestone=1
```

---

## ラベル関連

### ラベル作成

```bash
gh label create ラベル名 --color "#カラー" --description "説明"
```

**オプション:**
- `--color`: カラーコード（16進数、先頭の `#` 必須）
- `--description`: ラベルの説明

**例:**
```bash
gh label create test --color "#bfd4f2" --description "Test issue or pull request"
gh label create automation --color "#0052cc" --description "Automation related issues"
```

### ラベル一覧

```bash
gh label list
```

---

## プロジェクト関連

### プロジェクト一覧

```bash
gh project list --owner OWNER
```

**例:**
```bash
gh project list --owner Sunwood-ai-labs
# 出力: 11    Agent-ZERO    open    PVT_kwHOBnsxLs4BMiC9
```

### プロジェクト詳細

```bash
gh project view PROJECT番号 --owner OWNER --format json
```

**重要:** グローバルID（`PVT_...`）を取得するために `--format json` を使用します。

**例:**
```bash
gh project view 11 --owner Sunwood-ai-labs --format json
# 出力: {"id":"PVT_kwHOBnsxLs4BMiC9","number":11,"title":"Agent-ZERO",...}
```

### プロジェクトに Item 追加

```bash
gh project item-add PROJECT番号 --url "IssueのURL" --owner OWNER
```

**例:**
```bash
gh project item-add 11 \
  --url "https://github.com/Sunwood-ai-labs/zero-cc/issues/7" \
  --owner Sunwood-ai-labs
```

### プロジェクト Item 一覧

```bash
gh project item-list PROJECT番号 --owner OWNER --format json
```

---

## マイルストーン関連

### マイルストーン作成

**注意:** `gh` に `milestone` サブコマンドがないため、API を使用します。

```bash
gh api --method POST /repos/OWNER/REPO/milestones \
  -f title="バージョン" \
  -f description="説明" \
  -f state="open"
```

**例:**
```bash
gh api --method POST /repos/Sunwood-ai-labs/zero-cc/milestones \
  -f title="v0.1.0" \
  -f description="MVP リリース" \
  -f state="open"
```

### マイルストーン一覧

```bash
gh api /repos/OWNER/REPO/milestones
```

### Issue にマイルストーン紐付け

```bash
gh api --method PATCH /repos/OWNER/REPO/issues/ISSUE番号 -f milestone=MILESTONE_ID
```

**例:**
```bash
gh api --method PATCH /repos/Sunwood-ai-labs/zero-cc/issues/7 -f milestone=1
```

---

## 日付設定

### 日付フィールド作成

```bash
gh project field-create PROJECT番号 --owner OWNER --name "フィールド名" --data-type DATE
```

**例:**
```bash
# 開始日フィールド
gh project field-create 11 --owner Sunwood-ai-labs --name "開始日" --data-type DATE

# 終了日フィールド
gh project field-create 11 --owner Sunwood-ai-labs --name "終了日" --data-type DATE
```

### フィールド一覧

```bash
gh project field-list PROJECT番号 --owner OWNER
```

**出力例:**
```
Title    ProjectV2Field    PVTF_lAHOBnsxLs4BMiC9zg7yZ1M
...
開始日    ProjectV2Field    PVTF_lAHOBnsxLs4BMiC9zg71LEA
終了日    ProjectV2Field    PVTF_lAHOBnsxLs4BMiC9zg71LFU
```

### 日付設定

```bash
gh project item-edit \
  --project-id PROJECT_GLOBAL_ID \
  --id ITEM_ID \
  --field-id FIELD_ID \
  --date "YYYY-MM-DD"
```

**重要:**
- `--project-id`: グローバルID（`PVT_...`）
- `--id`: アイテムID（`PVTI_...`）
- `--field-id`: フィールドID（`PVTF_...`）

**例:**
```bash
# Issue #7 に開始日を設定
gh project item-edit \
  --project-id PVT_kwHOBnsxLs4BMiC9 \
  --id PVTI_lAHOBnsxLs4BMiC9zgjpfng \
  --field-id PVTF_lAHOBnsxLs4BMiC9zg71LEA \
  --date "2026-01-15"
```

---

## ステータス変更

### ステータスフィールド情報取得（GraphQL）

```bash
gh api graphql -f query='
query {
  node(id: "PROJECT_GLOBAL_ID") {
    ... on ProjectV2 {
      fields(first: 20) {
        nodes {
          ... on ProjectV2SingleSelectField {
            id
            name
            options {
              id
              name
            }
          }
        }
      }
    }
  }
}'
```

**出力例:**
```json
{
  "data": {
    "node": {
      "fields": {
        "nodes": [
          {
            "id": "PVTSSF_lAHOBnsxLs4BMiC9zg7yZ1U",
            "name": "Status",
            "options": [
              {"id": "f75ad846", "name": "Todo"},
              {"id": "47fc9ee4", "name": "In Progress"},
              {"id": "98236657", "name": "Done"}
            ]
          }
        ]
      }
    }
  }
}
```

### ステータス変更

```bash
gh project item-edit \
  --project-id PROJECT_GLOBAL_ID \
  --id ITEM_ID \
  --field-id STATUS_FIELD_ID \
  --single-select-option-id OPTION_ID
```

**例:**
```bash
# In Progress に変更
gh project item-edit \
  --project-id PVT_kwHOBnsxLs4BMiC9 \
  --id PVTI_lAHOBnsxLs4BMiC9zgjpfng \
  --field-id PVTSSF_lAHOBnsxLs4BMiC9zg7yZ1U \
  --single-select-option-id 47fc9ee4
```

---

## ID の種類と取得方法

| ID 種類 | 形式 | 取得コマンド |
|---------|------|-------------|
| プロジェクト ローカルID | 数字（例: `11`） | `gh project list --owner OWNER` |
| プロジェクト グローバルID | `PVT_...` | `gh project view 番号 --format json` |
| アイテムID | `PVTI_...` | `gh project item-list 番号 --format json` |
| フィールドID | `PVTF_...` | `gh project field-list 番号 --owner OWNER` |
| ステータスフィールドID | `PVTSSF_...` | GraphQL クエリ |
| ステータスオプションID | 16進数（例: `47fc9ee4`） | GraphQL クエリ |
