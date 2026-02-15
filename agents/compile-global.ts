#!/usr/bin/env bun

/**
 * Compiles @> annotations from SKILL.md files into a dense index in GLOBAL.md.
 *
 * Source syntax (in SKILL.md):
 *   - Frontmatter: `global_category: CategoryName`
 *   - Inline: `<!-- @> summary text -->` above the relevant section
 *
 * Output (in GLOBAL.md between BEGIN/END COMPILED markers):
 *   Category|skills/skill-name|summary:Lnn|summary:Lnn|...
 *
 * Cleaned SKILL.md files (annotations stripped) are written to agents/.build/skills/.
 *
 * Usage:
 *   bun agents/compile-global.ts          # compile
 *   bun agents/compile-global.ts --check  # check staleness (exit 1 if stale)
 */

import { readdir, readFile, writeFile, mkdir } from "fs/promises";
import { join, dirname } from "path";
import { existsSync } from "fs";

const ANNOTATION_RE = /^<!-- @> (.+?) -->$/;
const BEGIN_MARKER = "<!-- BEGIN COMPILED -->";
const END_MARKER = "<!-- END COMPILED -->";

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

interface Summary {
  text: string;
  line: number; // 1-indexed line in cleaned output
}

interface ProcessedSkill {
  category: string;
  skillPath: string; // e.g. "skills/typescript-guidelines"
  summaries: Summary[];
  cleanedContent: string;
}

// ---------------------------------------------------------------------------
// Frontmatter
// ---------------------------------------------------------------------------

function parseFrontmatter(raw: string): {
  data: Record<string, string>;
  body: string;
  fullContent: string;
} {
  const match = raw.match(/^---\n([\s\S]*?)\n---\n?([\s\S]*)$/);
  if (!match) return { data: {}, body: raw, fullContent: raw };

  const data: Record<string, string> = {};
  for (const line of match[1].split("\n")) {
    const colonIdx = line.indexOf(":");
    if (colonIdx === -1) continue;
    const key = line.slice(0, colonIdx).trim();
    const val = line.slice(colonIdx + 1).trim();
    if (key) data[key] = val;
  }
  return { data, body: match[2], fullContent: raw };
}

// ---------------------------------------------------------------------------
// Process a single skill
// ---------------------------------------------------------------------------

function processSkill(
  content: string,
  skillRelPath: string,
): ProcessedSkill | null {
  const { data } = parseFrontmatter(content);
  const category = data.global_category;
  if (!category) return null;

  const inputLines = content.split("\n");
  const cleanedLines: string[] = [];
  const summaries: Summary[] = [];
  const pendingSummaries: string[] = [];

  for (const line of inputLines) {
    const m = line.match(ANNOTATION_RE);
    if (m) {
      pendingSummaries.push(m[1]);
      continue; // strip from output
    }

    cleanedLines.push(line);

    // Pair pending summaries with first non-blank content line
    if (pendingSummaries.length > 0 && line.trim() !== "") {
      const lineNum = cleanedLines.length; // 1-indexed
      for (const text of pendingSummaries) {
        if (text.includes("|")) {
          console.error(
            `Error: annotation contains pipe character in ${skillRelPath}: "${text}"`,
          );
          process.exit(1);
        }
        summaries.push({ text, line: lineNum });
      }
      pendingSummaries.length = 0;
    }
  }

  // Flush any trailing annotations (no content after them)
  if (pendingSummaries.length > 0) {
    const lineNum = cleanedLines.length || 1;
    for (const text of pendingSummaries) {
      summaries.push({ text, line: lineNum });
    }
  }

  return {
    category,
    skillPath: skillRelPath,
    summaries,
    cleanedContent: cleanedLines.join("\n"),
  };
}

// ---------------------------------------------------------------------------
// Find skill files
// ---------------------------------------------------------------------------

async function findSkillFiles(
  repoDir: string,
): Promise<Array<{ path: string; relPath: string }>> {
  const results: Array<{ path: string; relPath: string }> = [];

  for (const skillsDir of ["agents/skills", ".agents/skills"]) {
    const fullDir = join(repoDir, skillsDir);
    if (!existsSync(fullDir)) continue;

    const entries = await readdir(fullDir, { withFileTypes: true });
    for (const entry of entries) {
      if (!entry.isDirectory()) continue;
      const skillMd = join(fullDir, entry.name, "SKILL.md");
      if (existsSync(skillMd)) {
        results.push({ path: skillMd, relPath: `skills/${entry.name}` });
      }
    }
  }

  return results;
}

// ---------------------------------------------------------------------------
// Build compiled block
// ---------------------------------------------------------------------------

function buildCompiledBlock(skills: ProcessedSkill[]): string {
  const sorted = [...skills].sort((a, b) =>
    a.category.localeCompare(b.category),
  );

  const lines: string[] = [];
  for (const skill of sorted) {
    const parts = skill.summaries.map((s) => `${s.text}:L${s.line}`);
    lines.push([skill.category, skill.skillPath, ...parts].join("|"));
  }
  return lines.join("\n") + "\n";
}

// ---------------------------------------------------------------------------
// Update GLOBAL.md
// ---------------------------------------------------------------------------

function updateGlobalMd(
  content: string,
  compiledBlock: string,
): { updated: string; changed: boolean } {
  const beginIdx = content.indexOf(BEGIN_MARKER);
  const endIdx = content.indexOf(END_MARKER);

  if (beginIdx === -1 || endIdx === -1) {
    throw new Error("Missing BEGIN/END COMPILED markers in GLOBAL.md");
  }

  const before = content.slice(0, beginIdx + BEGIN_MARKER.length);
  const after = content.slice(endIdx);
  const updated = before + "\n" + compiledBlock + after;
  return { updated, changed: updated !== content };
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

async function main() {
  const checkMode = process.argv.includes("--check");

  const scriptDir = dirname(Bun.main);
  const repoDir = join(scriptDir, "..");
  const globalMdPath = join(scriptDir, "GLOBAL.md");
  const buildDir = join(scriptDir, ".build", "skills");

  // Find and process skills
  const skillFiles = await findSkillFiles(repoDir);
  const processed: ProcessedSkill[] = [];

  for (const { path: skillPath, relPath } of skillFiles) {
    const content = await readFile(skillPath, "utf-8");
    const result = processSkill(content, relPath);
    if (result) processed.push(result);
  }

  // Build compiled block
  const compiledBlock = buildCompiledBlock(processed);

  // Update GLOBAL.md
  const globalContent = await readFile(globalMdPath, "utf-8");
  const { updated, changed } = updateGlobalMd(globalContent, compiledBlock);

  if (checkMode) {
    if (changed) {
      console.error("✗ GLOBAL.md is stale. Run: make compile");
      process.exit(1);
    }
    console.log("✓ GLOBAL.md is up to date");
    return;
  }

  // Write GLOBAL.md
  if (changed) {
    await writeFile(globalMdPath, updated);
    console.log("Updated GLOBAL.md");
  } else {
    console.log("GLOBAL.md up to date");
  }

  // Write cleaned skills to .build/
  await mkdir(buildDir, { recursive: true });
  for (const skill of processed) {
    const skillName = skill.skillPath.replace("skills/", "");
    const outDir = join(buildDir, skillName);
    await mkdir(outDir, { recursive: true });
    await writeFile(join(outDir, "SKILL.md"), skill.cleanedContent);
  }

  console.log(`Cleaned ${processed.length} skill(s) → agents/.build/skills/`);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
