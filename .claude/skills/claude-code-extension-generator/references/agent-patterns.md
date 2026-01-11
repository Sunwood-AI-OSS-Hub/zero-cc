# エージェント設定パターン

## エージェント設定とは

プロジェクト全体でClaudeの振る舞いを定義する設定ファイル群。

## 設定ファイル一覧

| ファイル | 用途 | スコープ |
|----------|------|----------|
| `CLAUDE.md` | プロジェクト固有の指示・コンテキスト | プロジェクト |
| `~/.claude/CLAUDE.md` | ユーザー全体の設定 | グローバル |
| `.mcp.json` | MCP サーバー統合 | プロジェクト |
| `.claude/settings.json` | 権限・動作設定 | プロジェクト |

## CLAUDE.md 構成

### 基本テンプレート

```markdown
# プロジェクト概要

[1-2文でプロジェクトを説明]

## 技術スタック

- 言語: 
- フレームワーク: 
- データベース: 
- インフラ: 

## ディレクトリ構造

```
src/
├── components/   # UIコンポーネント
├── services/     # ビジネスロジック
└── utils/        # ユーティリティ
```

## コーディング規約

- [規約1]
- [規約2]
- [規約3]

## 重要なコマンド

- ビルド: `npm run build`
- テスト: `npm test`
- リント: `npm run lint`

## 注意事項

- [プロジェクト固有の注意点]
```

### 高度なテンプレート

```markdown
# [プロジェクト名]

## 概要
[プロジェクトの目的と背景]

## アーキテクチャ

### システム構成
[図またはテキストで説明]

### 主要コンポーネント
| コンポーネント | 責務 | 場所 |
|----------------|------|------|
| API Gateway | リクエストルーティング | `src/gateway/` |
| Auth Service | 認証・認可 | `src/auth/` |

## 開発ワークフロー

### ブランチ戦略
- main: 本番
- develop: 開発統合
- feature/*: 機能開発

### コミット規約
Conventional Commits形式:
- feat: 新機能
- fix: バグ修正
- docs: ドキュメント

### レビュー基準
1. テストカバレッジ80%以上
2. 型エラーなし
3. Lintエラーなし

## API仕様

### 認証
Bearer tokenを Authorization ヘッダーに設定

### エンドポイント規約
- RESTful設計
- バージョニング: /api/v1/*
- エラー形式: {error: {code, message}}

## デプロイメント

### 環境
| 環境 | URL | 用途 |
|------|-----|------|
| dev | dev.example.com | 開発 |
| stg | stg.example.com | 検証 |
| prod | example.com | 本番 |

### 手順
1. PRマージでdev自動デプロイ
2. リリースタグでprodデプロイ

## トラブルシューティング

### よくある問題
- **ビルドエラー**: `npm clean-install` を試す
- **テスト失敗**: 環境変数 `.env.test` を確認
```

## MCP統合設定 (.mcp.json)

### 基本構造

```json
{
  "mcpServers": {
    "server-name": {
      "command": "実行コマンド",
      "args": ["引数"],
      "env": {
        "ENV_VAR": "値"
      }
    }
  }
}
```

### 実践例

**PostgreSQL接続:**
```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "DATABASE_URL": "postgresql://user:pass@localhost/db"
      }
    }
  }
}
```

**ファイルシステムアクセス:**
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/path/to/allowed/directory"
      ]
    }
  }
}
```

**GitHub連携:**
```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

## 権限設定 (.claude/settings.json)

```json
{
  "permissions": {
    "allow": [
      "Bash(npm run *)",
      "Bash(git *)",
      "Read(src/**)",
      "Write(src/**)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Write(.env*)"
    ]
  }
}
```

## 生成ワークフロー

### 1. 要件ヒアリング

- プロジェクトの種類（Web/CLI/ライブラリ）
- 使用技術
- チームの規約
- 外部連携

### 2. CLAUDE.md生成

```bash
touch CLAUDE.md
# テンプレートをベースに記述
```

### 3. MCP設定（必要時）

```bash
touch .mcp.json
# 必要なサーバーを設定
```

### 4. コマンド追加（必要時）

```bash
mkdir -p .claude/commands
# プロジェクト固有コマンドを作成
```

## ベストプラクティス

✅ 必要最小限の情報
✅ 実行可能なコマンド例
✅ プロジェクト構造の明示
✅ 規約の具体例

❌ 過剰な説明
❌ 変更頻度の高い情報（バージョン等）
❌ 機密情報（.envに移動）
