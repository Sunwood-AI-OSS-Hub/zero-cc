---
name: claude-code-extension-generator
description: Claude Codeの拡張機能（スキル、サブエージェント、プロジェクト設定）をユーザーの自然言語指示から自動生成するスキル。「○○を作るスキルを作って」「○○エージェントを作って」「CLAUDE.mdを設定して」などのリクエスト時に使用。v2.1.1以降、スラッシュコマンドとスキルは統合されたため、すべてスキルとして作成。
---

# Claude Code Extension Generator

ユーザーの自然言語指示からClaude Codeの拡張機能を生成。

## v2.1.1+ 統合について

**スラッシュコマンドとスキルは統合されました。**

- `.claude/commands/` → `.claude/skills/` に一本化推奨
- スキルは `/skill-name` でも呼び出し可能
- スキルの方が高機能（複数ファイル、スクリプト、hooks等）

## 対応する拡張機能タイプ

| タイプ | 用途 | 出力先 |
|--------|------|--------|
| **スキル** | プロンプト再利用・専門知識・ワークフロー | `.claude/skills/` |
| **サブエージェント** | 独立コンテキストの特化型AI | `.claude/agents/` |
| **プロジェクト設定** | プロジェクト固有の振る舞い | `CLAUDE.md`/`.mcp.json` |

## 生成ワークフロー

### Step 1: 要件の明確化

ユーザーの指示から以下を特定:

1. **目的**: 何を解決したいか
2. **トリガー**: どんな状況で使用するか
3. **複雑さ**: 単純なプロンプトか、複雑なワークフローか
4. **独立性**: メイン会話で実行か、独立コンテキストが必要か

### Step 2: タイプ選択

```
プロンプト再利用・知識・ワークフロー → スキル (.claude/skills/)
独立コンテキストで動作する特化型AI → サブエージェント (.claude/agents/)
プロジェクト全体の設定 → CLAUDE.md / .mcp.json
```

### Step 3: 生成実行

- **スキル**: See [references/skill-patterns.md](references/skill-patterns.md)
- **サブエージェント**: See [references/subagent-patterns.md](references/subagent-patterns.md)
- **プロジェクト設定**: See [references/project-config-patterns.md](references/project-config-patterns.md)

## クイックリファレンス

### スキル構造 (.claude/skills/)

```
skill-name/
├── SKILL.md          # 必須: メタデータ + 手順
├── scripts/          # 自動化スクリプト（任意）
├── references/       # 参照ドキュメント（任意）
└── assets/           # テンプレート等（任意）
```

### サブエージェント構造 (.claude/agents/)

```
agent-name.md         # YAMLフロントマター + システムプロンプト
```

### プロジェクト設定

```
project-root/
├── CLAUDE.md         # プロジェクト固有指示
└── .mcp.json         # MCP統合設定
```

## スキル vs サブエージェント

| 項目 | スキル | サブエージェント |
|------|--------|------------------|
| コンテキスト | メイン会話に追加 | **独立** |
| 呼び出し | 自動検出 + `/skill` | 自動 or 明示的 |
| 構造 | ディレクトリ | 単一ファイル |
| 複数ファイル | ✅ | ❌ |
| ツール制限 | `allowed-tools` | `tools` |
| hooks | ✅ | ✅ |
| モデル指定 | ❌ | `model` |

### 選択基準

- **スキル**: 知識を追加したい、ワークフローを標準化したい
- **サブエージェント**: 独立して動作させたい、異なるツール/モデルを使いたい
