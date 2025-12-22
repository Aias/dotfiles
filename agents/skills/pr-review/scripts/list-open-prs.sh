#!/usr/bin/env bash
set -euo pipefail

# Check for PR on current branch first
current_branch=$(git branch --show-current 2>/dev/null || echo "")
current_pr=""
if [[ -n "$current_branch" ]]; then
  current_pr=$(gh pr view --json number -q '.number' 2>/dev/null || echo "")
fi

# Find PRs where user is reviewer/assignee
reviewer_prs=$(gh pr list \
  --search "is:open (review-requested:@me OR reviewed-by:@me OR assignee:@me)" \
  --limit 10 \
  --json number,title,author,headRefName \
  --jq '.[].number' 2>/dev/null || echo "")

# Combine: current branch PR + reviewer PRs (deduplicated)
all_prs=""
if [[ -n "$current_pr" ]]; then
  all_prs="$current_pr"
fi
for pr in $reviewer_prs; do
  if [[ "$pr" != "$current_pr" ]]; then
    all_prs="${all_prs:+$all_prs }$pr"
  fi
done

if [[ -z "$all_prs" ]]; then
  exit 0
fi

# Output details for all found PRs
for pr in $all_prs; do
  gh pr view "$pr" --json number,title,author,headRefName,reviewRequests,assignees,createdAt \
    --jq '{
      number,
      title,
      author: .author.login,
      branch: .headRefName,
      reviewers: [.reviewRequests[]?.login],
      assignees: [.assignees[]?.login],
      created: .createdAt
    }'
done
