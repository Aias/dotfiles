#!/usr/bin/env python3
"""
Initialize a new Agent Skill.

Usage:
    init-skill.py <skill-name> [--resources scripts,references,assets]

Examples:
    init-skill.py pdf-processing
    init-skill.py data-analysis --resources scripts,references
    init-skill.py brand-guidelines --resources assets
"""

import argparse
import re
import sys
from pathlib import Path

SKILLS_DIR = Path.home() / "Code" / "dotfiles" / "agents" / "skills"
MAX_NAME_LENGTH = 64
ALLOWED_RESOURCES = {"scripts", "references", "assets"}

SKILL_TEMPLATE = '''---
name: {name}
description: [TODO: What the skill does AND when to use it. Include trigger scenarios.]
---

# {title}

[TODO: 1-2 sentences explaining what this skill enables]

## Usage

[TODO: Add step-by-step instructions, examples, or guidance]

[TODO: If using scripts, inline simple commands directly for portability.
For complex scripts, use relative paths like `scripts/my-script.sh`.
Never hardcode agent-specific paths like ~/.claude/skills/ or ~/.cursor/skills/]

## Resources

[TODO: Delete this section if no resources, or document what each provides]

- `scripts/` — [what the scripts do]
- `references/` — [what documentation is included]
- `assets/` — [what files are bundled]
'''


def normalize_name(raw_name: str) -> str:
    """Normalize skill name to lowercase hyphen-case."""
    name = raw_name.strip().lower()
    name = re.sub(r"[^a-z0-9]+", "-", name)
    name = name.strip("-")
    name = re.sub(r"-{2,}", "-", name)
    return name


def to_title(name: str) -> str:
    """Convert hyphen-case to Title Case."""
    return " ".join(word.capitalize() for word in name.split("-"))


def parse_resources(raw: str) -> list[str]:
    """Parse comma-separated resources list."""
    if not raw:
        return []
    resources = [r.strip() for r in raw.split(",") if r.strip()]
    invalid = [r for r in resources if r not in ALLOWED_RESOURCES]
    if invalid:
        print(f"[ERROR] Unknown resources: {', '.join(invalid)}")
        print(f"        Allowed: {', '.join(sorted(ALLOWED_RESOURCES))}")
        sys.exit(1)
    return list(dict.fromkeys(resources))  # dedupe preserving order


def create_skill(name: str, resources: list[str]) -> Path | None:
    """Create the skill directory and files."""
    skill_dir = SKILLS_DIR / name

    if skill_dir.exists():
        print(f"[ERROR] Skill already exists: {skill_dir}")
        return None

    try:
        skill_dir.mkdir(parents=True)
        print(f"[OK] Created {skill_dir}")
    except Exception as e:
        print(f"[ERROR] Failed to create directory: {e}")
        return None

    # Create SKILL.md
    content = SKILL_TEMPLATE.format(name=name, title=to_title(name))
    (skill_dir / "SKILL.md").write_text(content)
    print("[OK] Created SKILL.md")

    # Create resource directories
    for resource in resources:
        (skill_dir / resource).mkdir()
        print(f"[OK] Created {resource}/")

    return skill_dir


def main():
    parser = argparse.ArgumentParser(
        description="Initialize a new Agent Skill in the dotfiles skills directory."
    )
    parser.add_argument("name", help="Skill name (normalized to hyphen-case)")
    parser.add_argument(
        "--resources",
        default="",
        help="Comma-separated: scripts,references,assets",
    )
    args = parser.parse_args()

    name = normalize_name(args.name)
    if not name:
        print("[ERROR] Skill name must contain at least one letter or digit.")
        sys.exit(1)

    if len(name) > MAX_NAME_LENGTH:
        print(f"[ERROR] Name too long ({len(name)} chars, max {MAX_NAME_LENGTH}).")
        sys.exit(1)

    if name != args.name:
        print(f"Note: Normalized '{args.name}' to '{name}'")

    resources = parse_resources(args.resources)

    print(f"\nInitializing skill: {name}")
    print(f"Location: {SKILLS_DIR / name}")
    if resources:
        print(f"Resources: {', '.join(resources)}")
    print()

    result = create_skill(name, resources)
    if not result:
        sys.exit(1)

    print(f"\n[OK] Skill '{name}' initialized")
    print("\nNext steps:")
    print("1. Edit SKILL.md — complete TODOs, write description and instructions")
    if resources:
        print("2. Add content to resource directories")
    print(f"3. Run ~/Code/dotfiles/install.sh to deploy")
    print("4. Restart the agent to pick up the new skill")


if __name__ == "__main__":
    main()
