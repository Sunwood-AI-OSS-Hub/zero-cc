<div align="center">

<img src="assets/header.svg" alt="ZERO CC Header" width="1200"/>

</div>

<div align="center">

### Claude Code 用カスタムスキル集

[![Claude Code](https://img.shields.io/badge/Claude-Code-purple?style=flat-square&logo=anthropic)](https://claude.ai/code)
[![GLM-4.7](https://img.shields.io/badge/Powered%20by-GLM--4.7-blue?style=flat-square)](https://open.bigmodel.cn/)
[![License](https://img.shields.io/badge/License-MIT-blue?style=flat-square)](LICENSE)

**日本語** | [English](README_EN.md)

Claude Code を強化する、実用的なカスタムスキルコレクション。

</div>

---

## ✨ 概要

`zero-cc` は Claude Code の生産性を向上させるために作られたカスタムスキル集です。GitHub リポジトリの作成からメンテナンス、さらには新しいスキルの自動生成まで、開発ワークフローを自動化します。

## 📦 含まれるスキル

<div align="center">

| スキル | 説明 |
|:------:|------|
| **extension-generator** | 自然言語から Claude Code 拡張機能（スキル/エージェント）を自動生成 |
| **fal-ai** | fal.ai APIで画像生成・画像編集・動画生成（プロンプト自動保存機能付き） |
| **repo-create** | GitHub リポジトリを新規作成・初期化（AI生成ヘッダー画像対応） |
| **repo-flow** | Git Flow ワークフロー（ブランチ/PR/マージ） |
| **repo-maintain** | 既存リポジトリのメンテナンス（リリース/変更履歴/状態確認） |
| **remotion** | Remotion 動画制作ベストプラクティス（React ベースの動画生成） |
| **voicevox** | VOICEVOX Engine を使った日本語音声合成 |

</div>

---

### 🔧 extension-generator

ユーザーの自然言語指示から Claude Code の拡張機能を自動生成するメタスキル。

**対応する拡張機能:**
- **スキル** - プロンプト再利用・専門知識・ワークフロー
- **サブエージェント** - 独立コンテキストの特化型AI
- **プロジェクト設定** - CLAUDE.md / .mcp.json

```bash
# スキルを作成
/extension-generator コードレビューするスキルを作って

# サブエージェントを作成
/extension-generator フロントエンドコードを最適化するエージェントを作って
```

---

### 📁 repo-create

GitHub リポジトリを新規作成・初期化します。

**機能:**
- `gh repo create` でリポジトリ作成
- README.md / .gitignore / LICENSE を自動生成
- AI生成ヘッダー画像（fal.ai Nano Banana Pro）
- initial commit を自動実行

```bash
/repo-create my-awesome-project
/repo-create my-app --private --description "My awesome app"
```

---

### 🎨 fal-ai

fal.ai API を使って画像生成・画像編集・動画生成を行います。

**機能:**
- **画像生成** - テキストから高品質な画像を生成（Nano Banana Pro、Qwen Image 2512）
- **画像編集** - 既存の画像をプロンプトで編集
- **動画生成** - 画像から動画を生成（LTX-2）
- **音声付き動画生成** - 画像から音声付き動画を生成（LTX-2 19B Distilled）
- **プロンプト自動保存** - 生成物と一緒にプロンプト情報を `.md` ファイルで自動保存

```bash
# 画像生成
「マーケティングバナーを作って、テキスト『SUMMER SALE』入りで」
「夕日の山脈の画像を作って」
「猫のイラストを生成して」

# 画像編集
「この写真の空を青くして」

# 動画生成
「この写真から動画を作って」
「この写真から音声付き動画を作って」
```

---

### 🌊 repo-flow

Git Flow ワークフローで開発からマージまでを実行します。

**機能:**
- **フィーチャーブランチ作成** - `develop` からブランチ作成
- **PR 作成** - 変更内容から PR を自動生成
- **コードレビュー** - PR のレビュー支援
- **マージ** - レビュー完了後にマージ実行

```bash
/repo-flow feature add-user-auth
/repo-flow pr
/repo-flow review
/repo-flow merge
```

---

### 🚀 repo-maintain

既存 GitHub リポジトリのメンテナンス作業を支援します。

**機能:**
- **リリース作成** - Gitタグ + GitHubリリース + リリースノート生成
- **変更履歴** - コミットログから自動分類
- **イシュー作成** - テンプレートベースのIssue作成
- **状態確認** - リポジトリのサマリー表示

```bash
/repo-maintain release 1.0.0
/repo-maintain changelog
/repo-maintain issue "Bug: Login fails"
/repo-maintain status
```

---

### 🎬 remotion

Remotion（React ベースの動画制作フレームワーク）のベストプラクティス集。

**機能:**
- 36のルールファイルで網羅的なドキュメント
- アニメーション・トランジション・キャプション等の実装パターン
- 3D コンテンツ（Three.js）対応
- チャート・データ可視化パターン

```bash
/remotion 動画を作って
/remotion キャプションを追加して
```

---

### 🎙️ voicevox

VOICEVOX Engine を使って日本語音声を合成します。

**機能:**
- テキストから自然な日本語音声（WAV形式）を生成
- 複数のキャラクター（四国めたん、ずんだもん等）から選択可能
- 速度・ピッチ・音量・イントネーションを調整可能

```bash
「この文章を読み上げて」
「音声を生成して」
「『こんにちは、世界』という音声を作って」
```

---

## 🚀 セットアップ

### 要件

- [GitHub CLI](https://cli.github.com/) (`gh`) がインストール済み
- `gh auth login` で認証済み

### インストール

#### 方法1: インストーラー使用（推奨）

Claude Code も一緒に自動インストールされます。

```bash
curl -fsSL https://raw.githubusercontent.com/Sunwood-ai-labs/zero-cc/main/script/install.sh | bash
```

インストール後、以下のコマンドが利用可能になります：
- `cc-st` - Claude Code（標準モード）
- `cc-glm` - Claude Code（GLM/Z.AI モード）
- `ccd-st` - Claude Code Dangerous（標準モード）
- `ccd-glm` - Claude Code Dangerous（GLM/Z.AI モード）

#### 方法2: 手動インストール

1. このリポジトリをクローン
2. Claude Code でプロジェクトを開く
3. スキルが自動的に読み込まれます

```bash
git clone https://github.com/Sunwood-ai-labs/zero-cc.git
cd zero-cc
```

---

## 📁 構造

```
zero-cc/
├── .claude/
│   └── skills/
│       ├── extension-generator/
│       │   ├── SKILL.md
│       │   └── references/
│       ├── repo-create/
│       │   ├── SKILL.md
│       │   └── references/
│       ├── repo-flow/
│       │   ├── SKILL.md
│       │   └── references/
│       ├── repo-maintain/
│       │   ├── SKILL.md
│       │   └── references/
│       ├── remotion/
│       │   ├── SKILL.md
│       │   └── rules/
│       ├── fal-ai/
│       │   ├── SKILL.md
│       │   ├── scripts/
│       │   │   ├── t2i-nano-banana-pro.ts
│       │   │   ├── t2i-qwen-image-2512.ts
│       │   │   ├── i2i-qwen-image-edit-2511.ts
│       │   │   ├── i2v-ltx-2.ts
│       │   │   ├── i2v-ltx-2-audio.ts
│       │   │   └── utils/
│       │   │       └── prompt-saver.ts
│       │   └── package.json
│       └── voicevox/
│           ├── SKILL.md
│           └── scripts/
├── assets/
│   ├── header.svg
│   └── release-header-v0.2.0.svg
├── script/
│   └── install.sh
├── README.md
├── RELEASE_NOTES.md
└── LICENSE
```

---

## 🎮 事例 / Examples

ZERO CC を活用して作成されたプロジェクト例:

### [claude-glm-actions-lab](https://github.com/Sunwood-ai-labs/claude-glm-actions-lab)

GitHub Actions で Claude Code と GLM API を統合する実験的リポジトリ。

**使用した ZERO CC スキル:**
- `/repo-create` - リポジトリの初期化
- `/repo-maintain` - リリース管理
- `/extension-generator` - カスタムスキルの生成

**機能:**
- GitHub Actions で Claude Code を実行
- GLM API (Z.AI) との統合
- Issue コメント & PR レビュー対応
- Bot 自己トリガー防止機能

---

## 🤖 使用モデル

本プロジェクトの開発には **GLM-4.7** (Zhipu AI) が使用されています。

### GLM-4.7 について

- **開発者**: [Zhipu AI (智谱AI)](https://open.bigmodel.cn/)
- **リリース**: 2025年12月22日
- **特徴**: コーディングシーンに特化した最適化、マルチファイル処理、深い数学的推論
- **ツール互換性**: Claude Code を含む20以上のAIコーディングツールと互換性
- **ライセンス**: オープンウェイトモデル

---

## 📄 ライセンス

[MIT License](LICENSE)

---

<div align="center">

Made with ❤️ for [Claude Code](https://claude.ai/code)

</div>
