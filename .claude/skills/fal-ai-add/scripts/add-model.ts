#!/usr/bin/env tsx
/**
 * add-model.ts
 *
 * 新しいfal.aiモデルをプロジェクトに追加するためのスクリプト
 *
 * 使用方法:
 *   node add-model.ts --interactive
 *   node add-model.ts --model-id "fal-ai/new-model" --type t2i --name "New Model"
 *
 * オプション:
 *   --interactive       対話モードで情報を入力
 *   --model-id <id>     モデルID
 *   --type <type>       モデルタイプ (t2i, i2i, i2v)
 *   --name <name>       モデル名
 *   --description <d>   機能説明
 *   --dry-run           実行せずに確認のみ
 */

import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import readline from "readline";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const projectRoot = path.resolve(__dirname, "../../../../");
const skillsDir = path.join(projectRoot, ".claude/skills");

// 型定義
type ModelType = "t2i" | "i2i" | "i2v" | "other";

interface ModelInfo {
  modelId: string;
  type: ModelType;
  name: string;
  description: string;
}

interface ScriptTemplate {
  prefix: string;
  templatePath: string;
}

// モデルタイプに対応するスクリプトテンプレート
const TEMPLATES: Record<ModelType, ScriptTemplate> = {
  t2i: {
    prefix: "t2i",
    templatePath: path.join(skillsDir, "fal-ai/scripts/t2i-qwen-image-2512.ts")
  },
  i2i: {
    prefix: "i2i",
    templatePath: path.join(skillsDir, "fal-ai/scripts/i2i-qwen-image-edit-2511.ts")
  },
  i2v: {
    prefix: "i2v",
    templatePath: path.join(skillsDir, "fal-ai/scripts/i2v-ltx-2.ts")
  },
  other: {
    prefix: "misc",
    templatePath: path.join(skillsDir, "fal-ai/scripts/t2i-qwen-image-2512.ts")
  }
};

// コマンドライン引数の解析
function parseArgs(): { modelInfo?: Partial<ModelInfo>; interactive: boolean; dryRun: boolean } {
  const args = process.argv.slice(2);
  const result: { modelInfo?: Partial<ModelInfo>; interactive: boolean; dryRun: boolean } = {
    interactive: false,
    dryRun: false
  };

  for (let i = 0; i < args.length; i++) {
    switch (args[i]) {
      case "--interactive":
        result.interactive = true;
        break;
      case "--model-id":
        result.modelInfo = result.modelInfo || {};
        result.modelInfo.modelId = args[++i];
        break;
      case "--type":
        result.modelInfo = result.modelInfo || {};
        result.modelInfo.type = args[++i] as ModelType;
        break;
      case "--name":
        result.modelInfo = result.modelInfo || {};
        result.modelInfo.name = args[++i];
        break;
      case "--description":
        result.modelInfo = result.modelInfo || {};
        result.modelInfo.description = args[++i];
        break;
      case "--dry-run":
        result.dryRun = true;
        break;
      case "--help":
        console.log(`
使用方法: node add-model.ts [options]

オプション:
  --interactive           対話モードで情報を入力
  --model-id <id>         モデルID（例: fal-ai/new-model）
  --type <type>           モデルタイプ (t2i, i2i, i2v, other)
  --name <name>           モデル名（例: New Model 2024）
  --description <d>       機能説明
  --dry-run               実行せずに確認のみ

例:
  node add-model.ts --interactive
  node add-model.ts --model-id "fal-ai/new-model" --type t2i --name "New Model"
        `);
        process.exit(0);
    }
  }

  return result;
}

// 対話的な情報収集
async function collectInfoInteractive(initialInfo: Partial<ModelInfo> = {}): Promise<ModelInfo> {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
  });

  const question = (prompt: string): Promise<string> => {
    return new Promise((resolve) => {
      rl.question(prompt, (answer) => resolve(answer));
    });
  };

  console.log("\n=== fal.aiモデル追加ウィザード ===\n");

  const modelId = initialInfo.modelId || await question("1. モデルID（例: fal-ai/new-model）: ");
  const typeInput = initialInfo.type || await question("2. モデルタイプ (t2i/i2i/i2v/other): ");
  const name = initialInfo.name || await question("3. モデル名（例: New Model 2024）: ");
  const description = initialInfo.description || await question("4. 機能説明: ");

  rl.close();

  return {
    modelId,
    type: typeInput as ModelType,
    name,
    description
  };
}

// スクリプトファイル名を生成
function generateScriptFilename(modelInfo: ModelInfo): string {
  const template = TEMPLATES[modelInfo.type];
  const slug = modelInfo.modelId.split("/").pop() || "new-model";
  return `${template.prefix}-${slug}.ts`;
}

// スクリプトをコピーして作成
function createScript(modelInfo: ModelInfo, dryRun: boolean): string {
  const template = TEMPLATES[modelInfo.type];
  const scriptName = generateScriptFilename(modelInfo);
  const destPath = path.join(skillsDir, "fal-ai/scripts", scriptName);

  if (!fs.existsSync(template.templatePath)) {
    throw new Error(`テンプレートが見つかりません: ${template.templatePath}`);
  }

  if (dryRun) {
    console.log(`[DRY-RUN] ${template.templatePath} -> ${destPath}`);
    return destPath;
  }

  const content = fs.readFileSync(template.templatePath, "utf-8");
  fs.writeFileSync(destPath, content);

  return destPath;
}

// モデル情報を表示
function displaySummary(modelInfo: ModelInfo): void {
  console.log("\n=== 追加するモデル情報 ===");
  console.log(`モデルID:     ${modelInfo.modelId}`);
  console.log(`タイプ:       ${modelInfo.type}`);
  console.log(`名前:         ${modelInfo.name}`);
  console.log(`説明:         ${modelInfo.description}`);
  console.log(`スクリプト名:  ${generateScriptFilename(modelInfo)}`);
  console.log("========================\n");
}

// MODELS.mdを更新するためのテキストを生成
function generateModelsMarkdown(modelInfo: ModelInfo): string {
  const number = getNextModelNumber();
  const scriptName = generateScriptFilename(modelInfo);

  return `

## ${number}. ${modelInfo.name}

**モデルID**: \`${modelInfo.modelId}\`

**機能**: ${modelInfo.description}

### 入力パラメータ

| パラメータ | 型 | デフォルト | 説明 |
|-----------|------|-----------|------|
| \`prompt\` | string | 必須 | プロンプト |
| \`input\` | InputType | - | 入力 |

### プロンプトの例

\`\`\`
"Example prompt for ${modelInfo.name}"
\`\`\`

### 使用方法

\`\`\`bash
node .claude/skills/fal-ai/scripts/${scriptName} --input "example"
\`\`\`

---
`;
}

// 次のモデル番号を取得
function getNextModelNumber(): number {
  const modelsPath = path.join(skillsDir, "fal-ai/references/MODELS.md");
  if (!fs.existsSync(modelsPath)) {
    return 1;
  }
  const content = fs.readFileSync(modelsPath, "utf-8");
  const matches = content.matchAll(/^## \d+\. /gm);
  return Array.from(matches).length + 1;
}

// メイン処理
async function main() {
  const args = parseArgs();

  // 情報収集
  let modelInfo: ModelInfo;
  if (args.interactive || !args.modelInfo?.modelId) {
    modelInfo = await collectInfoInteractive(args.modelInfo);
  } else {
    modelInfo = {
      modelId: args.modelInfo.modelId!,
      type: args.modelInfo.type || "other",
      name: args.modelInfo.name || "Unknown Model",
      description: args.modelInfo.description || ""
    };
  }

  // 確認
  displaySummary(modelInfo);

  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
  });

  const confirm = await new Promise<string>((resolve) => {
    rl.question("この内容で追加しますか？ (y/n): ", (answer) => resolve(answer));
  });

  rl.close();

  if (confirm.toLowerCase() !== "y") {
    console.log("キャンセルしました。");
    process.exit(0);
  }

  // スクリプト作成
  try {
    const scriptPath = createScript(modelInfo, args.dryRun);
    console.log(`✓ スクリプトを作成: ${scriptPath}`);
  } catch (error) {
    console.error(`✗ スクリプト作成エラー: ${error}`);
    process.exit(1);
  }

  // MODELS.md更新テキストを表示
  const modelsMarkdown = generateModelsMarkdown(modelInfo);
  console.log("\n=== MODELS.mdに追加する内容 ===");
  console.log(modelsMarkdown);
  console.log("=============================\n");

  const modelsPath = path.join(skillsDir, "fal-ai/references/MODELS.md");
  console.log(`以下のファイルを手動で更新してください:`);
  console.log(`  - ${modelsPath}`);
  console.log(`  - ${path.join(skillsDir, "fal-ai/SKILL.md")}`);

  if (args.dryRun) {
    console.log("\n[DRY-RUN] 実行はスキップされました。");
  } else {
    console.log("\n✓ 準備完了！");
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
