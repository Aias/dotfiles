# Skills Manager Workflow

Step-by-step guide for managing external skills.

## Setup

1. Ensure `.agents/` is NOT in `.gitignore` (we want to version control external skills)
2. Modify `install.sh` to copy from both `agents/skills/` and `.agents/skills/`

## Install a New Skill

```bash
cd ~/Code/dotfiles

# 1. Install using npx skills (downloads to .agents/skills/)
npx skills add vercel-labs/agent-skills \
  --skill vercel-react-best-practices

# 2. Get the commit hash from the cloned repo (optional but recommended)
COMMIT_HASH=$(git -C .agents/skills/vercel-react-best-practices rev-parse HEAD 2>/dev/null || echo "unknown")

# 3. Record metadata
agents/skills/skills-manager/manage-skills.sh add \
  vercel-react-best-practices \
  vercel-labs/agent-skills \
  "$COMMIT_HASH"

# 4. Deploy to all agents via rsync
make link

# 5. Commit to dotfiles (optional)
git add .agents/skills/vercel-react-best-practices
git add .agents/skills.json
git commit -m "Add vercel-react-best-practices skill from skills.sh"
```

Without `--agent`, npx skills only downloads to `.agents/skills/` without creating symlinks. `make link` handles deployment via rsync.

## Check for Updates

```bash
cd ~/Code/dotfiles
npx skills check
```

## Update a Skill

```bash
cd ~/Code/dotfiles

# 1. Update using npx skills
npx skills update

# 2. Get new commit hash
COMMIT_HASH=$(git -C .agents/skills/skill-name rev-parse HEAD 2>/dev/null || echo "unknown")

# 3. Update metadata
agents/skills/skills-manager/manage-skills.sh add \
  skill-name \
  source-repo \
  "$COMMIT_HASH"

# 4. Deploy
make link

# 5. Commit changes
git add .agents/skills/skill-name
git add .agents/skills.json
git commit -m "Update skill-name to $COMMIT_HASH"
```

## List Tracked Skills

```bash
cd ~/Code/dotfiles
agents/skills/skills-manager/manage-skills.sh list
```

## Directory Structure

```
dotfiles/
├── agents/
│   └── skills/          # Personal skills (hand-written)
│       ├── council/
│       ├── skills-manager/
│       └── ...
├── .agents/
│   ├── skills/          # External skills (from skills.sh)
│   │   ├── vercel-react-best-practices/
│   │   └── ...
│   └── skills.json      # Metadata tracking
└── install.sh           # Copies from both directories
```
