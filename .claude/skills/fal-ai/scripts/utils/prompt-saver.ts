#!/usr/bin/env tsx
/**
 * prompt-saver.ts
 *
 * 生成した画像/動画と一緒にプロンプト情報をマークダウンファイルで保存するユーティリティ
 */

import fs from "fs";
import path from "path";

export interface PromptMetadata {
  // 共通フィールド
  model: string;
  modelType: "T2I" | "I2I" | "I2V" | "T2V";
  prompt: string;
  negativePrompt?: string;
  seed?: number;

  // 画像生成用
  imageSize?: string;
  aspectRatio?: string;
  resolution?: string;
  numInferenceSteps?: number;
  guidanceScale?: number;
  outputFormat?: string;
  numImages?: number;
  enableSafetyChecker?: boolean;

  // 画像編集用
  inputImageUrl?: string;
  strength?: number;

  // 動画生成用
  duration?: number;
  fps?: number;
  motionScale?: number;

  // 出力情報
  outputFiles: Array<{
    filename: string;
    url: string;
    width?: number;
    height?: number;
    contentType?: string;
  }>;

  // リクエスト情報
  requestId?: string;

  // その他のパラメータ
  extraParams?: Record<string, any>;
}

/**
 * プロンプト情報をマークダウンファイルとして保存
 *
 * @param outputPath - 画像/動画ファイルのパス（同じ場所に.mdファイルが作成される）
 * @param metadata - 保存するメタデータ
 */
export function savePromptMarkdown(
  outputPath: string,
  metadata: PromptMetadata
): string {
  const mdPath = outputPath.replace(/\.[^.]+$/, ".md");

  const lines: string[] = [];

  // タイトル
  lines.push(`# ${metadata.modelType} Generation Log`);
  lines.push("");

  // 基本情報
  lines.push("## Model Info");
  lines.push("");
  lines.push(`- **Model**: \`${metadata.model}\``);
  lines.push(`- **Type**: ${metadata.modelType}`);
  lines.push(`- **Generated**: ${new Date().toISOString()}`);
  if (metadata.requestId) {
    lines.push(`- **Request ID**: \`${metadata.requestId}\``);
  }
  lines.push("");

  // プロンプト
  lines.push("## Prompt");
  lines.push("");
  lines.push("```");
  lines.push(metadata.prompt);
  lines.push("```");
  lines.push("");

  // ネガティブプロンプト
  if (metadata.negativePrompt) {
    lines.push("### Negative Prompt");
    lines.push("");
    lines.push("```");
    lines.push(metadata.negativePrompt);
    lines.push("```");
    lines.push("");
  }

  // パラメータ
  lines.push("## Parameters");
  lines.push("");
  lines.push("| Parameter | Value |");
  lines.push("|-----------|-------|");

  if (metadata.seed !== undefined) {
    lines.push(`| Seed | \`${metadata.seed}\` |`);
  }
  if (metadata.imageSize) {
    lines.push(`| Image Size | \`${metadata.imageSize}\` |`);
  }
  if (metadata.aspectRatio) {
    lines.push(`| Aspect Ratio | \`${metadata.aspectRatio}\` |`);
  }
  if (metadata.resolution) {
    lines.push(`| Resolution | \`${metadata.resolution}\` |`);
  }
  if (metadata.numInferenceSteps) {
    lines.push(`| Inference Steps | \`${metadata.numInferenceSteps}\` |`);
  }
  if (metadata.guidanceScale) {
    lines.push(`| Guidance Scale | \`${metadata.guidanceScale}\` |`);
  }
  if (metadata.outputFormat) {
    lines.push(`| Output Format | \`${metadata.outputFormat}\` |`);
  }
  if (metadata.numImages) {
    lines.push(`| Num Images | \`${metadata.numImages}\` |`);
  }
  if (metadata.enableSafetyChecker !== undefined) {
    lines.push(`| Safety Checker | \`${metadata.enableSafetyChecker}\` |`);
  }
  if (metadata.strength !== undefined) {
    lines.push(`| Strength | \`${metadata.strength}\` |`);
  }
  if (metadata.duration !== undefined) {
    lines.push(`| Duration | \`${metadata.duration}s\` |`);
  }
  if (metadata.fps !== undefined) {
    lines.push(`| FPS | \`${metadata.fps}\` |`);
  }
  if (metadata.motionScale !== undefined) {
    lines.push(`| Motion Scale | \`${metadata.motionScale}\` |`);
  }

  // その他のパラメータ
  if (metadata.extraParams) {
    for (const [key, value] of Object.entries(metadata.extraParams)) {
      const displayValue = typeof value === "object" ? JSON.stringify(value) : String(value);
      lines.push(`| ${key} | \`${displayValue}\` |`);
    }
  }

  lines.push("");

  // 入力画像（I2I, I2Vの場合）
  if (metadata.inputImageUrl) {
    lines.push("## Input");
    lines.push("");
    lines.push(`- **Source**: ${metadata.inputImageUrl}`);
    lines.push("");
  }

  // 出力ファイル
  lines.push("## Output Files");
  lines.push("");

  for (let i = 0; i < metadata.outputFiles.length; i++) {
    const file = metadata.outputFiles[i];
    lines.push(`### File ${i + 1}: \`${file.filename}\``);
    lines.push("");

    if (file.width && file.height) {
      lines.push(`- **Dimensions**: ${file.width}x${file.height}`);
    }
    if (file.contentType) {
      lines.push(`- **Content Type**: \`${file.contentType}\``);
    }
    lines.push(`- **URL**: ${file.url}`);
    lines.push("");
  }

  // ファイルに書き込み
  const content = lines.join("\n");
  fs.writeFileSync(mdPath, content, "utf-8");

  return mdPath;
}

/**
 * 画像/動画の保存と同時にプロンプト情報も保存するヘルパー関数
 *
 * @param outputDir - 出力ディレクトリ
 * @param filename - ファイル名
 * @param metadata - メタデータ
 * @param downloadFn - 画像/動画をダウンロードする関数
 */
export async function saveWithPrompt(
  outputDir: string,
  filename: string,
  metadata: PromptMetadata,
  downloadFn: (outputPath: string) => Promise<void>
): Promise<{ outputPath: string; mdPath: string }> {
  const outputPath = path.join(outputDir, filename);

  // 画像/動画をダウンロード
  await downloadFn(outputPath);

  // プロンプト情報を保存
  const mdPath = savePromptMarkdown(outputPath, metadata);

  return { outputPath, mdPath };
}
