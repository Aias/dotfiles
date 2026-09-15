import { afterEach, describe, expect, test } from "bun:test";
import { chmod, mkdtemp, mkdir, readFile, rm, writeFile } from "fs/promises";
import { tmpdir } from "os";
import { join } from "path";

const compiler = join(import.meta.dir, "compile-global.ts");
const fixtures: string[] = [];

async function write(path: string, content: string | Uint8Array): Promise<void> {
  await mkdir(join(path, ".."), { recursive: true });
  await writeFile(path, content);
}

async function createFixture(): Promise<string> {
  const root = await mkdtemp(join(tmpdir(), "compile-global-test-"));
  fixtures.push(root);
  await write(
    join(root, "agents/GLOBAL.md"),
    [
      "# Global",
      "",
      "Shared global",
      "  <!-- harness: codex -->",
      "Codex global",
      "  <!-- /harness -->",
      "<!-- harness: claude,cursor -->",
      "Claude Cursor global",
      "<!-- /harness -->",
      "",
      "<!-- BEGIN COMPILED -->",
      "stale",
      "<!-- END COMPILED -->",
      "",
    ].join("\n"),
  );
  await write(
    join(root, "agents/skills/shared/SKILL.md"),
    [
      "---",
      "name: shared",
      "global_category: Test",
      "---",
      "# Shared",
      "<!-- @> common summary -->",
      "## Common",
      "<!-- harness: codex -->",
      "<!-- @> codex summary -->",
      "## Codex",
      "<!-- /harness -->",
      "<!-- harness: claude,cursor -->",
      "<!-- @> desktop summary -->",
      "## Desktop",
      "<!-- /harness -->",
      "",
    ].join("\n"),
  );
  await write(
    join(root, "agents/skills/shared/references/detail.md"),
    [
      "# Detail",
      "<!-- harness: cursor -->",
      "Cursor detail",
      "<!-- /harness -->",
      "Common detail",
      "",
    ].join("\n"),
  );
  await write(
    join(root, "agents/skills/shared/assets/data.bin"),
    new Uint8Array([0, 1, 2, 255]),
  );
  await write(
    join(root, "agents/skills/shared/skill.feedback.md"),
    "<!-- harness: codex -->\nprivate feedback\n",
  );
  const executable = join(root, "agents/skills/shared/scripts/run.sh");
  await write(executable, "#!/bin/sh\nexit 0\n");
  await chmod(executable, 0o755);
  await write(
    join(root, ".agents/skills/targeted/SKILL.md"),
    [
      "---",
      "name: targeted",
      "global_category: Test",
      "metadata:",
      "  targets: claude,cursor",
      "---",
      "<!-- @> targeted summary -->",
      "# Targeted",
      "",
    ].join("\n"),
  );
  await write(
    join(root, "agents/skills.local/private/SKILL.md"),
    [
      "---",
      "name: private",
      "global_category: Private",
      "---",
      "<!-- @> private summary -->",
      "# Private",
      "",
    ].join("\n"),
  );
  return root;
}

async function runCompiler(
  root: string,
  ...args: string[]
): Promise<{ exitCode: number; stdout: string; stderr: string }> {
  const child = Bun.spawn(["bun", compiler, "--repo", root, ...args], {
    stdout: "pipe",
    stderr: "pipe",
  });
  const [exitCode, stdout, stderr] = await Promise.all([
    child.exited,
    new Response(child.stdout).text(),
    new Response(child.stderr).text(),
  ]);
  return { exitCode, stdout, stderr };
}

afterEach(async () => {
  await Promise.all(
    fixtures.splice(0).map((fixture) =>
      rm(fixture, { recursive: true, force: true }),
    ),
  );
});

describe("compile-global", () => {
  test("builds filtered globals and complete target skill trees", async () => {
    const root = await createFixture();
    const result = await runCompiler(root);
    expect(result.exitCode).toBe(0);

    const sourceGlobal = await readFile(join(root, "agents/GLOBAL.md"), "utf8");
    expect(sourceGlobal).toContain("targeted summary");
    expect(sourceGlobal).not.toContain("private summary");
    expect(sourceGlobal).toContain("<!-- harness: codex -->");

    const codexGlobal = await readFile(
      join(root, "agents/.build/codex/GLOBAL.md"),
      "utf8",
    );
    const claudeGlobal = await readFile(
      join(root, "agents/.build/claude/GLOBAL.md"),
      "utf8",
    );
    const sharedGlobal = await readFile(
      join(root, "agents/.build/shared/GLOBAL.md"),
      "utf8",
    );
    expect(codexGlobal).toContain("Codex global");
    expect(codexGlobal).not.toContain("Claude Cursor global");
    expect(codexGlobal).toContain("codex summary");
    expect(codexGlobal).toContain("private summary");
    expect(codexGlobal).not.toContain("targeted summary");
    expect(claudeGlobal).toContain("Claude Cursor global");
    expect(claudeGlobal).not.toContain("Codex global");
    expect(claudeGlobal).toContain("desktop summary");
    expect(claudeGlobal).toContain("targeted summary");
    expect(sharedGlobal).toContain("Shared global");
    expect(sharedGlobal).not.toContain("Codex global");
    expect(sharedGlobal).not.toContain("Claude Cursor global");
    expect(sharedGlobal).toContain("common summary");
    expect(sharedGlobal).not.toContain("common summary:L");
    expect(sharedGlobal).not.toContain("codex summary");
    expect(sharedGlobal).not.toContain("targeted summary");

    const codexSkill = await readFile(
      join(root, "agents/.build/codex/skills/shared/SKILL.md"),
      "utf8",
    );
    const codexLine = codexSkill.split("\n").indexOf("## Codex") + 1;
    expect(codexGlobal).toContain(`codex summary:L${codexLine}`);
    expect(codexSkill).not.toContain("desktop summary");
    expect(codexSkill).not.toContain("<!-- @>");
    expect(
      await Bun.file(
        join(root, "agents/.build/codex/skills/targeted/SKILL.md"),
      ).exists(),
    ).toBe(false);
    expect(
      await Bun.file(
        join(root, "agents/.build/claude/skills/targeted/SKILL.md"),
      ).exists(),
    ).toBe(true);
    expect(
      await Bun.file(
        join(root, "agents/.build/codex/skills/shared/skill.feedback.md"),
      ).exists(),
    ).toBe(false);
    expect(
      await readFile(
        join(root, "agents/.build/codex/skills/shared/assets/data.bin"),
      ),
    ).toEqual(new Uint8Array([0, 1, 2, 255]));
    expect(
      await readFile(
        join(root, "agents/.build/codex/excluded-skills.txt"),
        "utf8",
      ),
    ).toBe("targeted\n");
    expect(
      (await Bun.file(
        join(root, "agents/.build/codex/skills/shared/scripts/run.sh"),
      ).stat()).mode & 0o777,
    ).toBe(0o755);
  });

  test("compiles without the optional private submodule", async () => {
    const root = await createFixture();
    await rm(join(root, "agents/skills.local"), { recursive: true });
    expect((await runCompiler(root)).exitCode).toBe(0);
    expect((await runCompiler(root, "--check")).exitCode).toBe(0);
    for (const target of ["claude", "codex", "cursor"]) {
      const built = join(root, "agents/.build", target);
      expect(await Bun.file(join(built, "skills/shared/SKILL.md")).exists()).toBe(true);
      expect(await Bun.file(join(built, "skills/private/SKILL.md")).exists()).toBe(false);
      expect(await readFile(join(built, "GLOBAL.md"), "utf8")).not.toContain("private summary");
    }
  });

  test("keeps private repository metadata outside deployment", async () => {
    const root = await createFixture();
    await write(join(root, "agents/skills.local/.git"), "gitdir: ../../.git/modules/agents/skills.local\n");
    await write(join(root, "agents/skills.local/README.md"), "Private repository notes\n");
    expect((await runCompiler(root)).exitCode).toBe(0);
    const built = join(root, "agents/.build/codex/skills");
    expect(await Bun.file(join(built, "private/SKILL.md")).exists()).toBe(true);
    expect(await Bun.file(join(built, ".git")).exists()).toBe(false);
    expect(await Bun.file(join(built, "README.md")).exists()).toBe(false);
  });

  test("check detects stale outputs without rewriting them", async () => {
    const root = await createFixture();
    expect((await runCompiler(root)).exitCode).toBe(0);
    expect((await runCompiler(root, "--check")).exitCode).toBe(0);
    const output = join(root, "agents/.build/codex/skills/shared/SKILL.md");
    const original = await readFile(output, "utf8");
    const stale = `${original}stale\n`;
    await writeFile(output, stale);
    const result = await runCompiler(root, "--check");
    expect(result.exitCode).toBe(1);
    expect(result.stderr).toContain(
      "agents/.build/codex/skills/shared/SKILL.md",
    );
    expect(await readFile(output, "utf8")).toBe(stale);
    await writeFile(output, original);

    const executable = join(
      root,
      "agents/.build/codex/skills/shared/scripts/run.sh",
    );
    await chmod(executable, 0o644);
    const modeResult = await runCompiler(root, "--check");
    expect(modeResult.exitCode).toBe(1);
    expect(modeResult.stderr).toContain(
      "agents/.build/codex/skills/shared/scripts/run.sh",
    );
  });

  test.each([
    ["unknown metadata target", "metadata:\n  targets: vscode", "Unknown harness target"],
    ["empty metadata target", "metadata:\n  targets: ''", "Empty harness target list"],
    ["non-mapping metadata", "metadata: invalid", "metadata must be a mapping"],
    ["non-string metadata target", "metadata:\n  targets: [codex]", "metadata.targets must be a string"],
    ["unknown section target", "<!-- harness: windsurf -->\nX\n<!-- /harness -->", "Unknown harness target"],
    ["empty section target", "<!-- harness: -->\nX\n<!-- /harness -->", "Empty harness target list"],
    ["unclosed section", "<!-- harness: codex -->\nX", "Unclosed harness block"],
    ["unmatched close", "<!-- /harness -->", "Unmatched harness close marker"],
    ["nested section", "<!-- harness: codex -->\n<!-- harness: claude -->\nX\n<!-- /harness -->\n<!-- /harness -->", "Nested harness block"],
    ["malformed section", "<!-- harness codex -->", "Malformed harness marker"],
  ])("rejects %s", async (_name, fragment, message) => {
    const root = await createFixture();
    await write(
      join(root, "agents/skills/invalid/SKILL.md"),
      `---\nname: invalid\n${fragment.startsWith("metadata:") ? `${fragment}\n` : ""}---\n${fragment.startsWith("metadata:") ? "# Invalid" : fragment}\n`,
    );
    const result = await runCompiler(root);
    expect(result.exitCode).toBe(1);
    expect(result.stderr).toContain(message);
  });
});
