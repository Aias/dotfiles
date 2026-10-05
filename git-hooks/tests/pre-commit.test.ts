import { afterEach, describe, expect, test } from "bun:test";
import { mkdtemp, mkdir, readFile, rm, writeFile } from "fs/promises";
import { tmpdir } from "os";
import { join } from "path";

const hook = join(import.meta.dir, "../pre-commit");
const fixtures: string[] = [];
const localGitVariables = Bun.spawnSync(["git", "rev-parse", "--local-env-vars"]);
if (localGitVariables.exitCode !== 0) {
  throw new Error("Could not determine repository-local Git variables");
}
const localGitNames = localGitVariables.stdout.toString().trim().split("\n");
const fixtureEnvironment = Object.fromEntries(
  Object.entries(process.env).filter(([name]) => !localGitNames.includes(name)),
);

async function run(root: string, command: string[]) {
  const child = Bun.spawn(command, {
    cwd: root,
    env: fixtureEnvironment,
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

async function createRepository() {
  const root = await mkdtemp(join(tmpdir(), "pre-commit-test-"));
  fixtures.push(root);
  await mkdir(join(root, "agents"));
  await writeFile(join(root, "agents/GLOBAL.md"), "original\n");
  expect((await run(root, ["git", "init", "--quiet"])).exitCode).toBe(0);
  expect((await run(root, ["git", "add", "agents/GLOBAL.md"])).exitCode).toBe(0);
  return root;
}

afterEach(async () => {
  await Promise.all(
    fixtures.splice(0).map((fixture) =>
      rm(fixture, { recursive: true, force: true }),
    ),
  );
});

describe("pre-commit", () => {
  test.each([
    { name: "compilation fails", compileExit: 7, checkExit: 0 },
    { name: "source checks fail", compileExit: 0, checkExit: 9 },
    { name: "all checks pass", compileExit: 0, checkExit: 0 },
  ])("$name", async ({ compileExit, checkExit }) => {
    const root = await createRepository();
    await writeFile(
      join(root, "Makefile"),
      [
        "compile:",
        "\t@echo compile >> calls",
        "\t@echo compiled > agents/GLOBAL.md",
        `\t@exit ${compileExit}`,
        "check-source:",
        "\t@echo check-source >> calls",
        `\t@exit ${checkExit}`,
        "",
      ].join("\n"),
    );

    const result = await run(root, ["bash", hook]);
    const passed = compileExit === 0 && checkExit === 0;
    expect(result.exitCode === 0).toBe(passed);
    expect(await readFile(join(root, "calls"), "utf8")).toBe(
      compileExit === 0 ? "compile\ncheck-source\n" : "compile\n",
    );
    const staged = await run(root, ["git", "show", ":agents/GLOBAL.md"]);
    expect(staged.exitCode).toBe(0);
    expect(staged.stdout).toBe(passed ? "compiled\n" : "original\n");
  });

  test("preserves the calling worktree's index", async () => {
    const root = await createRepository();
    const child = Bun.spawn(
      ["bun", "test", import.meta.path, "--test-name-pattern", "all checks pass"],
      {
        cwd: root,
        env: {
          ...process.env,
          GIT_DIR: join(root, ".git"),
          GIT_INDEX_FILE: join(root, ".git/index"),
        },
        stdout: "pipe",
        stderr: "pipe",
      },
    );
    const [exitCode] = await Promise.all([
      child.exited,
      new Response(child.stdout).text(),
      new Response(child.stderr).text(),
    ]);
    expect(exitCode).toBe(0);
    const staged = await run(root, ["git", "show", ":agents/GLOBAL.md"]);
    expect(staged.exitCode).toBe(0);
    expect(staged.stdout).toBe("original\n");
  });
});
