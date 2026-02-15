#!/usr/bin/env bun

/**
 * Compiles @> annotations from skill .md files into a dense index in GLOBAL.md.
 *
 * Source syntax:
 *   - SKILL.md frontmatter: `global_category: CategoryName`
 *   - Any .md file in the skill dir: `<!-- @> summary text -->` above relevant section
 *
 * Output (in GLOBAL.md between BEGIN/END COMPILED markers):
 *   Category|skills/skill-name|summary:Lnn|summary:subpath:Lnn|...
 *   (subpath omitted for SKILL.md — it's the default)
 *
 * Cleaned .md files (annotations stripped) written to agents/.build/skills/.
 *
 * Usage:
 *   bun agents/compile-global.ts          # compile
 *   bun agents/compile-global.ts --check  # check staleness (exit 1 if stale)
 */

import { readdir, mkdir } from "fs/promises";
import { join, dirname } from "path";

const ANNOTATION_RE = /^<!-- @> (.+?) -->$/;
const BEGIN_MARKER = "<!-- BEGIN COMPILED -->";
const END_MARKER = "<!-- END COMPILED -->";

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

interface Summary {
  text: string;
  line: number;
  file: string; // relative to skill dir, e.g. "SKILL.md" or "workflows/pr-guidelines.md"
}

interface ProcessedFile {
  relPath: string; // relative to skill dir
  summaries: Summary[];
  cleanedContent: string;
}

interface ProcessedSkill {
  category: string;
  skillPath: string; // e.g. "skills/git-workflows"
  files: ProcessedFile[];
}

// ---------------------------------------------------------------------------
// Frontmatter
// ---------------------------------------------------------------------------

function parseFrontmatter(raw: string): Record<string, string> {
  const match = raw.match(/^---\n([\s\S]*?)\n---\n/);
  if (!match) return {};

  const data: Record<string, string> = {};
  for (const line of match[1].split("\n")) {
    const colonIdx = line.indexOf(":");
    if (colonIdx === -1) continue;
    const key = line.slice(0, colonIdx).trim();
    const val = line.slice(colonIdx + 1).trim();
    if (key) data[key] = val;
  }
  return data;
}

// ---------------------------------------------------------------------------
// Process a single .md file for annotations
// ---------------------------------------------------------------------------

function processFile(content: string, fileRelPath: string): ProcessedFile {
  const inputLines = content.split("\n");
  const cleanedLines: string[] = [];
  const summaries: Summary[] = [];
  const pendingSummaries: string[] = [];

  for (const line of inputLines) {
    const m = line.match(ANNOTATION_RE);
    if (m) {
      pendingSummaries.push(m[1]);
      continue;
    }

    cleanedLines.push(line);

    if (pendingSummaries.length > 0 && line.trim() !== "") {
      const lineNum = cleanedLines.length;
      for (const text of pendingSummaries) {
        if (text.includes("|")) {
          console.error(
            `Error: annotation contains pipe character in ${fileRelPath}: "${text}"`,
          );
          process.exit(1);
        }
        summaries.push({ text, line: lineNum, file: fileRelPath });
      }
      pendingSummaries.length = 0;
    }
  }

  if (pendingSummaries.length > 0) {
    const lineNum = cleanedLines.length || 1;
    for (const text of pendingSummaries) {
      summaries.push({ text, line: lineNum, file: fileRelPath });
    }
  }

  return {
    relPath: fileRelPath,
    summaries,
    cleanedContent: cleanedLines.join("\n"),
  };
}

// ---------------------------------------------------------------------------
// Find and process skills
// ---------------------------------------------------------------------------

async function findAndProcessSkills(
  repoDir: string,
): Promise<ProcessedSkill[]> {
  const results: ProcessedSkill[] = [];

  for (const skillsDir of ["agents/skills", ".agents/skills"]) {
    const fullDir = join(repoDir, skillsDir);
    let entries;
    try {
      entries = await readdir(fullDir, { withFileTypes: true });
    } catch {
      continue;
    }
    for (const entry of entries) {
      if (!entry.isDirectory()) continue;

      const skillDir = join(fullDir, entry.name);
      const skillMdFile = Bun.file(join(skillDir, "SKILL.md"));
      if (!(await skillMdFile.exists())) continue;

      // Check for global_category in SKILL.md frontmatter
      const skillMdContent = await skillMdFile.text();
      const frontmatter = parseFrontmatter(skillMdContent);
      if (!frontmatter.global_category) continue;

      // Scan all .md files in this skill directory
      const glob = new Bun.Glob("**/*.md");
      const mdFiles = Array.from(glob.scanSync(skillDir));
      const processedFiles: ProcessedFile[] = [];

      for (const mdRelPath of mdFiles) {
        const mdFullPath = join(skillDir, mdRelPath);
        const content = await Bun.file(mdFullPath).text();
        const processed = processFile(content, mdRelPath);
        if (processed.summaries.length > 0) {
          processedFiles.push(processed);
        }
      }

      if (processedFiles.length > 0) {
        results.push({
          category: frontmatter.global_category,
          skillPath: `skills/${entry.name}`,
          files: processedFiles,
        });
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
    const parts: string[] = [];
    for (const file of skill.files) {
      for (const s of file.summaries) {
        if (s.file === "SKILL.md") {
          parts.push(`${s.text}:L${s.line}`);
        } else {
          parts.push(`${s.text}:${s.file}:L${s.line}`);
        }
      }
    }
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
  const processed = await findAndProcessSkills(repoDir);

  // Build compiled block
  const compiledBlock = buildCompiledBlock(processed);

  // Update GLOBAL.md
  const globalContent = await Bun.file(globalMdPath).text();
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
    await Bun.write(globalMdPath, updated);
    console.log("Updated GLOBAL.md");
  } else {
    console.log("GLOBAL.md up to date");
  }

  // Write cleaned files to .build/
  await mkdir(buildDir, { recursive: true });
  let fileCount = 0;
  for (const skill of processed) {
    const skillName = skill.skillPath.replace("skills/", "");
    for (const file of skill.files) {
      const outPath = join(buildDir, skillName, file.relPath);
      await mkdir(dirname(outPath), { recursive: true });
      await Bun.write(outPath, file.cleanedContent);
      fileCount++;
    }
  }

  console.log(
    `Cleaned ${fileCount} file(s) across ${processed.length} skill(s) → agents/.build/skills/`,
  );
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
