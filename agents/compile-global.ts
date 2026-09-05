import { readdir, mkdir, rm } from "fs/promises";
import { join, dirname } from "path";

const ANNOTATION_RE = /^<!-- @> (.+?) -->$/;
const FRONTMATTER_CLOSE = "---";
const BEGIN_MARKER = "<!-- BEGIN COMPILED -->";
const END_MARKER = "<!-- END COMPILED -->";
const PERSONAL_SKILLS_DIR = "agents/skills";
const SKILL_SOURCE_DIRS = [PERSONAL_SKILLS_DIR, ".agents/skills"];

interface Summary {
  text: string;
  line: number;
  file: string;
}

interface ProcessedFile {
  relPath: string;
  summaries: Summary[];
  cleanedContent: string;
}

interface ProcessedSkill {
  category?: string;
  skillPath: string;
  files: ProcessedFile[];
}

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

function buildFeedbackPreamble(skillName: string): string[] {
  return [
    "",
    `> **Feedback loop** — On this skill's first use in a session, read \`~/Code/dotfiles/agents/skills/${skillName}/skill.feedback.md\` if it exists, and re-read it after a correction. When the user corrects your output or states a preference that would apply to future sessions, append a dated line to that file. Skip task-specific details.`,
    "",
  ];
}

function processFile(
  content: string,
  fileRelPath: string,
  preamble: string[] = [],
): ProcessedFile {
  const inputLines = content.split("\n");
  const cleanedLines: string[] = [];
  const summaries: Summary[] = [];
  const pendingSummaries: string[] = [];
  let pendingPreamble = preamble;
  let insideFrontmatter = inputLines[0] === FRONTMATTER_CLOSE;

  for (const [index, line] of inputLines.entries()) {
    const m = line.match(ANNOTATION_RE);
    if (m) {
      pendingSummaries.push(m[1]);
      continue;
    }

    cleanedLines.push(line);

    if (insideFrontmatter && index > 0 && line === FRONTMATTER_CLOSE) {
      insideFrontmatter = false;
      cleanedLines.push(...pendingPreamble);
      pendingPreamble = [];
    }

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

  if (pendingPreamble.length > 0) {
    cleanedLines.unshift(...pendingPreamble);
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

async function findAndProcessSkills(
  repoDir: string,
): Promise<ProcessedSkill[]> {
  const results: ProcessedSkill[] = [];

  for (const skillsDir of SKILL_SOURCE_DIRS) {
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

      const frontmatter = parseFrontmatter(await skillMdFile.text());
      const receivesPreamble =
        skillsDir === PERSONAL_SKILLS_DIR && frontmatter.feedback !== "false";
      const preamble = receivesPreamble
        ? buildFeedbackPreamble(entry.name)
        : [];

      const glob = new Bun.Glob("**/*.md");
      const processedFiles: ProcessedFile[] = [];
      for (const mdRelPath of Array.from(glob.scanSync(skillDir))) {
        const content = await Bun.file(join(skillDir, mdRelPath)).text();
        const isSkillMd = mdRelPath === "SKILL.md";
        const processed = processFile(
          content,
          mdRelPath,
          isSkillMd ? preamble : [],
        );
        const indexed = frontmatter.global_category
          ? processed.summaries.length > 0
          : false;
        if (indexed || (isSkillMd && receivesPreamble)) {
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

function buildCompiledBlock(skills: ProcessedSkill[]): string {
  const indexed = skills.filter(
    (skill) =>
      skill.category && skill.files.some((file) => file.summaries.length > 0),
  );
  const sorted = [...indexed].sort((a, b) =>
    (a.category ?? "").localeCompare(b.category ?? ""),
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

async function main() {
  const checkMode = process.argv.includes("--check");

  const scriptDir = dirname(Bun.main);
  const repoDir = join(scriptDir, "..");
  const globalMdPath = join(scriptDir, "GLOBAL.md");
  const buildDir = join(scriptDir, ".build", "skills");

  const processed = await findAndProcessSkills(repoDir);
  const compiledBlock = buildCompiledBlock(processed);
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

  if (changed) {
    await Bun.write(globalMdPath, updated);
    console.log("Updated GLOBAL.md");
  } else {
    console.log("GLOBAL.md up to date");
  }

  await rm(buildDir, { recursive: true, force: true });
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
    `Wrote ${fileCount} file(s) across ${processed.length} skill(s) → agents/.build/skills/`,
  );
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
