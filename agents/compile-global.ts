import {
  chmod,
  mkdir,
  mkdtemp,
  readFile,
  readdir,
  rename,
  rm,
  stat,
} from "fs/promises";
import { basename, dirname, join } from "path";

type Target = "claude" | "codex" | "cursor";
type Filter = Target | "shared" | "union";

const ANNOTATION_RE = /^<!-- @> (.+?) -->$/;
const HARNESS_OPEN_RE = /^<!-- harness:\s*(.*?)\s*-->$/;
const HARNESS_CLOSE_RE = /^<!-- \/harness -->$/;
const BEGIN_MARKER = "<!-- BEGIN COMPILED -->";
const END_MARKER = "<!-- END COMPILED -->";
const PERSONAL_SKILLS_DIR = "agents/skills";
const LOCAL_SKILLS_DIR = "agents/skills.local";
const SKILL_SOURCE_DIRS = [
  PERSONAL_SKILLS_DIR,
  ".agents/skills",
  LOCAL_SKILLS_DIR,
];
const TARGETS: Target[] = ["claude", "codex", "cursor"];

interface Summary {
  text: string;
  line: number;
  file: string;
}

interface ProcessedFile {
  summaries: Summary[];
  content: string;
}

interface SkillSource {
  name: string;
  sourceDir: string;
  skillDir: string;
  category?: string;
  targets?: Target[];
  files: string[];
}

interface ProcessedSkill {
  category?: string;
  skillPath: string;
  files: Array<{ relPath: string; summaries: Summary[] }>;
}

interface Artifact {
  content: string | Uint8Array;
  mode: number;
}

interface Options {
  check: boolean;
  repoDir: string;
}

function targetFromString(value: string, context: string): Target {
  if (value === "claude" || value === "codex" || value === "cursor") {
    return value;
  }
  throw new Error(`Unknown harness target "${value}" in ${context}`);
}

function parseTargets(value: string, context: string): Target[] {
  let unquoted = value.trim();
  if (
    unquoted.length >= 2 &&
    ((unquoted.startsWith("\"") && unquoted.endsWith("\"")) ||
      (unquoted.startsWith("'") && unquoted.endsWith("'")))
  ) {
    unquoted = unquoted.slice(1, -1).trim();
  }
  if (unquoted === "") {
    throw new Error(`Empty harness target list in ${context}`);
  }
  const targets: Target[] = [];
  for (const rawTarget of unquoted.split(",")) {
    const target = targetFromString(rawTarget.trim(), context);
    if (!targets.includes(target)) targets.push(target);
  }
  return targets;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function parseFrontmatter(
  raw: string,
  context: string,
): { category?: string; targets?: Target[] } {
  const match = raw.match(/^---\n([\s\S]*?)\n---(?:\n|$)/);
  if (!match) return {};
  const parsed: unknown = Bun.YAML.parse(match[1]);
  if (!isRecord(parsed)) throw new Error(`Invalid frontmatter in ${context}`);
  const categoryValue = parsed.global_category;
  if (categoryValue !== undefined && typeof categoryValue !== "string") {
    throw new Error(`global_category must be a string in ${context}`);
  }
  const metadata = parsed.metadata;
  if (metadata === undefined) return { category: categoryValue };
  if (!isRecord(metadata)) {
    throw new Error(`metadata must be a mapping in ${context}`);
  }
  const targetsValue = metadata.targets;
  if (targetsValue === undefined) return { category: categoryValue };
  if (typeof targetsValue !== "string") {
    throw new Error(`metadata.targets must be a string in ${context}`);
  }
  return {
    category: categoryValue,
    targets: parseTargets(targetsValue, `${context} metadata.targets`),
  };
}

function includesEveryTarget(targets: Target[]): boolean {
  return TARGETS.every((target) => targets.includes(target));
}

function included(targets: Target[] | undefined, filter: Filter): boolean {
  if (!targets || filter === "union") return true;
  if (filter === "shared") return includesEveryTarget(targets);
  return targets.includes(filter);
}

function filterHarnessSections(
  content: string,
  filePath: string,
  filter: Filter,
): string {
  const output: string[] = [];
  let blockTargets: Target[] | undefined;
  let blockLine = 0;
  for (const [index, line] of content.split("\n").entries()) {
    const marker = line.trim();
    const open = marker.match(HARNESS_OPEN_RE);
    if (open) {
      if (blockTargets) {
        throw new Error(`Nested harness block in ${filePath}:${index + 1}`);
      }
      blockTargets = parseTargets(open[1], `${filePath}:${index + 1}`);
      blockLine = index + 1;
      continue;
    }
    if (HARNESS_CLOSE_RE.test(marker)) {
      if (!blockTargets) {
        throw new Error(`Unmatched harness close marker in ${filePath}:${index + 1}`);
      }
      blockTargets = undefined;
      blockLine = 0;
      continue;
    }
    if (
      marker.startsWith("<!-- harness") ||
      marker.startsWith("<!-- /harness")
    ) {
      throw new Error(`Malformed harness marker in ${filePath}:${index + 1}`);
    }
    if (!blockTargets || included(blockTargets, filter)) output.push(line);
  }
  if (blockTargets) {
    throw new Error(`Unclosed harness block in ${filePath}:${blockLine}`);
  }
  return output.join("\n");
}

function processMarkdown(
  content: string,
  filePath: string,
  filter: Filter,
): ProcessedFile {
  const inputLines = filterHarnessSections(content, filePath, filter).split("\n");
  const cleanedLines: string[] = [];
  const summaries: Summary[] = [];
  const pendingSummaries: string[] = [];

  for (const line of inputLines) {
    const annotation = line.match(ANNOTATION_RE);
    if (annotation) {
      pendingSummaries.push(annotation[1]);
      continue;
    }
    cleanedLines.push(line);
    if (pendingSummaries.length > 0 && line.trim() !== "") {
      const lineNumber = cleanedLines.length;
      for (const text of pendingSummaries) {
        if (text.includes("|")) {
          throw new Error(
            `Annotation contains pipe character in ${filePath}: "${text}"`,
          );
        }
        summaries.push({ text, line: lineNumber, file: filePath });
      }
      pendingSummaries.length = 0;
    }
  }
  if (pendingSummaries.length > 0) {
    const lineNumber = cleanedLines.length || 1;
    for (const text of pendingSummaries) {
      summaries.push({ text, line: lineNumber, file: filePath });
    }
  }
  return { summaries, content: cleanedLines.join("\n") };
}

async function listFiles(root: string): Promise<string[]> {
  const files: string[] = [];
  let entries;
  try {
    entries = await readdir(root, { withFileTypes: true });
  } catch {
    return files;
  }
  for (const entry of entries) {
    const entryPath = join(root, entry.name);
    if (entry.isDirectory()) {
      for (const child of await listFiles(entryPath)) {
        files.push(join(entry.name, child));
      }
    } else if (entry.isFile()) {
      files.push(entry.name);
    }
  }
  return files.sort();
}

async function loadSkills(repoDir: string): Promise<SkillSource[]> {
  const skills: SkillSource[] = [];
  for (const sourceDir of SKILL_SOURCE_DIRS) {
    const fullSourceDir = join(repoDir, sourceDir);
    let entries;
    try {
      entries = await readdir(fullSourceDir, { withFileTypes: true });
    } catch {
      continue;
    }
    for (const entry of entries) {
      if (!entry.isDirectory()) continue;
      const skillDir = join(fullSourceDir, entry.name);
      const skillMdPath = join(skillDir, "SKILL.md");
      let skillMd;
      try {
        skillMd = await readFile(skillMdPath, "utf8");
      } catch {
        continue;
      }
      const frontmatter = parseFrontmatter(
        skillMd,
        `${sourceDir}/${entry.name}/SKILL.md`,
      );
      const files = await listFiles(skillDir);
      for (const relPath of files) {
        if (basename(relPath) === "skill.feedback.md") continue;
        if (!relPath.endsWith(".md")) continue;
        const content = await readFile(join(skillDir, relPath), "utf8");
        filterHarnessSections(
          content,
          `${sourceDir}/${entry.name}/${relPath}`,
          "union",
        );
      }
      skills.push({
        name: entry.name,
        sourceDir,
        skillDir,
        category: frontmatter.category,
        targets: frontmatter.targets,
        files,
      });
    }
  }
  return skills;
}

function buildCompiledBlock(
  skills: ProcessedSkill[],
  includeLocations: boolean,
): string {
  const indexed = skills.filter(
    (skill) =>
      skill.category && skill.files.some((file) => file.summaries.length > 0),
  );
  indexed.sort((a, b) => {
    const categoryOrder = (a.category ?? "").localeCompare(b.category ?? "");
    return categoryOrder || a.skillPath.localeCompare(b.skillPath);
  });
  const lines: string[] = [];
  for (const skill of indexed) {
    const parts: string[] = [];
    for (const file of skill.files) {
      for (const summary of file.summaries) {
        if (!includeLocations) {
          parts.push(summary.text);
          continue;
        }
        const location =
          summary.file === "SKILL.md"
            ? `L${summary.line}`
            : `${summary.file}:L${summary.line}`;
        parts.push(`${summary.text}:${location}`);
      }
    }
    lines.push([skill.category, skill.skillPath, ...parts].join("|"));
  }
  return lines.length > 0 ? `${lines.join("\n")}\n` : "";
}

function updateGlobalMd(content: string, compiledBlock: string): string {
  const beginIndex = content.indexOf(BEGIN_MARKER);
  const endIndex = content.indexOf(END_MARKER);
  if (beginIndex === -1 || endIndex === -1 || endIndex < beginIndex) {
    throw new Error("Missing or malformed BEGIN/END COMPILED markers in GLOBAL.md");
  }
  const before = content.slice(0, beginIndex + BEGIN_MARKER.length);
  const after = content.slice(endIndex);
  return `${before}\n${compiledBlock}${after}`;
}

async function processSkill(
  skill: SkillSource,
  filter: Filter,
  artifacts?: Map<string, Artifact>,
): Promise<ProcessedSkill | undefined> {
  if (!included(skill.targets, filter)) return undefined;
  const processedFiles: Array<{ relPath: string; summaries: Summary[] }> = [];
  for (const relPath of skill.files) {
    if (basename(relPath) === "skill.feedback.md") continue;
    const sourcePath = join(skill.skillDir, relPath);
    const sourceStat = await stat(sourcePath);
    if (relPath.endsWith(".md")) {
      const content = await readFile(sourcePath, "utf8");
      const processed = processMarkdown(
        content,
        relPath,
        filter,
      );
      processedFiles.push({ relPath, summaries: processed.summaries });
      artifacts?.set(`skills/${skill.name}/${relPath}`, {
        content: processed.content,
        mode: sourceStat.mode,
      });
    } else {
      artifacts?.set(`skills/${skill.name}/${relPath}`, {
        content: await readFile(sourcePath),
        mode: sourceStat.mode,
      });
    }
  }
  return {
    category: skill.category,
    skillPath: `skills/${skill.name}`,
    files: processedFiles,
  };
}

async function buildIndex(
  skills: SkillSource[],
  filter: Filter,
  includeLocal: boolean,
  includeLocations: boolean,
  artifacts?: Map<string, Artifact>,
): Promise<string> {
  const processed: ProcessedSkill[] = [];
  for (const skill of skills) {
    const result = await processSkill(skill, filter, artifacts);
    if (result && (includeLocal || skill.sourceDir !== LOCAL_SKILLS_DIR)) {
      processed.push(result);
    }
  }
  return buildCompiledBlock(processed, includeLocations);
}

async function createArtifacts(
  skills: SkillSource[],
  sourceGlobal: string,
): Promise<Map<string, Artifact>> {
  const artifacts = new Map<string, Artifact>();
  for (const target of TARGETS) {
    const targetArtifacts = new Map<string, Artifact>();
    const compiled = await buildIndex(
      skills,
      target,
      true,
      true,
      targetArtifacts,
    );
    const filteredGlobal = filterHarnessSections(
      sourceGlobal,
      "agents/GLOBAL.md",
      target,
    );
    artifacts.set(`${target}/GLOBAL.md`, {
      content: updateGlobalMd(filteredGlobal, compiled),
      mode: 0o644,
    });
    const excluded = skills
      .filter((skill) => skill.targets && !skill.targets.includes(target))
      .map((skill) => skill.name)
      .sort();
    artifacts.set(`${target}/excluded-skills.txt`, {
      content: excluded.length > 0 ? `${excluded.join("\n")}\n` : "",
      mode: 0o644,
    });
    for (const [path, artifact] of targetArtifacts) {
      artifacts.set(`${target}/${path}`, artifact);
    }
  }
  const sharedCompiled = await buildIndex(skills, "shared", true, false);
  const sharedGlobal = filterHarnessSections(
    sourceGlobal,
    "agents/GLOBAL.md",
    "shared",
  );
  artifacts.set("shared/GLOBAL.md", {
    content: updateGlobalMd(sharedGlobal, sharedCompiled),
    mode: 0o644,
  });
  return artifacts;
}

async function artifactMatches(path: string, artifact: Artifact): Promise<boolean> {
  try {
    const actual = await readFile(path);
    const actualStat = await stat(path);
    const expected =
      typeof artifact.content === "string"
        ? new TextEncoder().encode(artifact.content)
        : artifact.content;
    return (
      actual.equals(expected) &&
      (actualStat.mode & 0o777) === (artifact.mode & 0o777)
    );
  } catch {
    return false;
  }
}

async function checkArtifacts(
  buildDir: string,
  artifacts: Map<string, Artifact>,
): Promise<string[]> {
  const stale: string[] = [];
  for (const [relPath, artifact] of artifacts) {
    if (!(await artifactMatches(join(buildDir, relPath), artifact))) {
      stale.push(relPath);
    }
  }
  const actualFiles = await listFiles(buildDir);
  for (const relPath of actualFiles) {
    const root = relPath.split("/")[0];
    if (
      (root === "claude" ||
        root === "codex" ||
        root === "cursor" ||
        root === "shared") &&
      !artifacts.has(relPath)
    ) {
      stale.push(relPath);
    }
  }
  return stale.sort();
}

async function writeArtifacts(
  buildDir: string,
  artifacts: Map<string, Artifact>,
): Promise<void> {
  await mkdir(dirname(buildDir), { recursive: true });
  await mkdir(buildDir, { recursive: true });
  const stagingDir = await mkdtemp(join(dirname(buildDir), ".build-"));
  try {
    for (const [relPath, artifact] of artifacts) {
      const outputPath = join(stagingDir, relPath);
      await mkdir(dirname(outputPath), { recursive: true });
      await Bun.write(outputPath, artifact.content);
      await chmod(outputPath, artifact.mode & 0o777);
    }
    for (const target of [...TARGETS, "shared"]) {
      await rm(join(buildDir, target), { recursive: true, force: true });
      await rename(join(stagingDir, target), join(buildDir, target));
    }
    await rm(join(buildDir, "skills"), { recursive: true, force: true });
  } finally {
    await rm(stagingDir, { recursive: true, force: true });
  }
}

function parseOptions(args: string[]): Options {
  let check = false;
  let repoDir = join(dirname(Bun.main), "..");
  for (let index = 0; index < args.length; index++) {
    const arg = args[index];
    if (arg === "--check") {
      check = true;
    } else if (arg === "--repo") {
      const value = args[index + 1];
      if (!value) throw new Error("--repo requires a path");
      repoDir = value;
      index++;
    } else {
      throw new Error(`Unknown argument: ${arg}`);
    }
  }
  return { check, repoDir };
}

async function main(): Promise<void> {
  const options = parseOptions(process.argv.slice(2));
  const globalPath = join(options.repoDir, "agents/GLOBAL.md");
  const buildDir = join(options.repoDir, "agents/.build");
  const originalGlobal = await readFile(globalPath, "utf8");
  filterHarnessSections(originalGlobal, "agents/GLOBAL.md", "union");
  const skills = await loadSkills(options.repoDir);
  const sourceCompiled = await buildIndex(skills, "union", false, true);
  const canonicalGlobal = updateGlobalMd(originalGlobal, sourceCompiled);
  const artifacts = await createArtifacts(skills, canonicalGlobal);

  if (options.check) {
    const stale: string[] = [];
    if (canonicalGlobal !== originalGlobal) stale.push("agents/GLOBAL.md");
    for (const path of await checkArtifacts(buildDir, artifacts)) {
      stale.push(`agents/.build/${path}`);
    }
    if (stale.length > 0) {
      console.error(
        `✗ Compiled output is stale:\n${stale.map((path) => `  ${path}`).join("\n")}`,
      );
      process.exit(1);
    }
    console.log("✓ Compiled globals and skills are up to date");
    return;
  }

  if (canonicalGlobal !== originalGlobal) {
    await Bun.write(globalPath, canonicalGlobal);
    console.log("Updated agents/GLOBAL.md");
  } else {
    console.log("agents/GLOBAL.md up to date");
  }
  await writeArtifacts(buildDir, artifacts);
  console.log(`Wrote ${artifacts.size} files across ${TARGETS.length} harness builds`);
}

if (import.meta.main) {
  main().catch((error) => {
    console.error(error instanceof Error ? error.message : error);
    process.exit(1);
  });
}
