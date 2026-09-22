import json
import re
import shlex
import sys

SEPARATORS = {"&&", "||", ";", ";;", "|", "|&", "&", "(", ")"}
GIT_GLOBAL_FLAGS_WITH_VALUE = {
    "-C",
    "-c",
    "--git-dir",
    "--work-tree",
    "--namespace",
    "--exec-path",
    "--config-env",
}
GH_PR_FLAGS_WITH_VALUE = {"-R", "--repo"}
MUTATIVE_GH_PR_SUBCOMMANDS = {
    "close",
    "comment",
    "create",
    "edit",
    "lock",
    "merge",
    "ready",
    "reopen",
    "review",
    "unlock",
    "update-branch",
}
HEREDOC_START = re.compile(r"<<-?\s*(['\"]?)(\w+)\1")


def strip_heredocs(command):
    kept = []
    lines = command.split("\n")
    index = 0
    while index < len(lines):
        match = HEREDOC_START.search(lines[index])
        if not match:
            kept.append(lines[index])
            index += 1
            continue
        terminator = match.group(2)
        kept.append(lines[index][: match.start()] + lines[index][match.end() :])
        index += 1
        while index < len(lines) and lines[index].strip() != terminator:
            index += 1
        index += 1
    return "\n".join(kept)


def simple_commands(command):
    flattened = strip_heredocs(command).replace("\\\n", " ").replace("\n", " ; ")
    lexer = shlex.shlex(flattened, posix=True, punctuation_chars=True)
    lexer.whitespace_split = True
    try:
        tokens = list(lexer)
    except ValueError:
        tokens = flattened.split()
    current = []
    for token in tokens:
        if token in SEPARATORS:
            if current:
                yield current
            current = []
        else:
            current.append(token)
    if current:
        yield current


def gh_pr_subcommands(tokens):
    for index, token in enumerate(tokens):
        if token != "gh" and not token.endswith("/gh"):
            continue
        cursor = index + 1
        if cursor >= len(tokens) or tokens[cursor] != "pr":
            continue
        cursor += 1
        while cursor < len(tokens) and tokens[cursor].startswith("-"):
            cursor += 2 if tokens[cursor] in GH_PR_FLAGS_WITH_VALUE else 1
        if cursor < len(tokens):
            yield tokens[cursor]


def contains_mutative_gh_pr(command):
    return any(
        subcommand in MUTATIVE_GH_PR_SUBCOMMANDS
        for tokens in simple_commands(command)
        for subcommand in gh_pr_subcommands(tokens)
    )


def hook_output(mode, command):
    if mode == "gh-pr" and contains_mutative_gh_pr(command):
        return {
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "additionalContext": "REMINDER: Read the pr-guidelines skill before running gh pr commands, if you have not already this session.",
            }
        }
    return None


if __name__ == "__main__":
    payload = json.load(sys.stdin)
    output = hook_output(sys.argv[1], payload.get("tool_input", {}).get("command", ""))
    if output:
        print(json.dumps(output))
