---
name: pangram
description: Run requested Pangram text, document, or image checks with the user's web-plan allowance through the local pangram CLI. Retrieve saved results and resume pending checks.
---

# Pangram

Use the `pangram` CLI in `~/Code/pangram-cli` when the user asks to check content with Pangram. Read `pangram --help` for command syntax. If the shell command is unavailable, run `bun ~/Code/pangram-cli/src/cli.ts` with the same arguments.

## Submit and retrieve

- Text: `pangram scan draft.txt`, or pipe text into `pangram scan`.
- Documents: `pangram estimate document.pdf` returns extracted text and estimated credits. `pangram upload document.pdf` estimates, submits, and waits for its text result.
- Images: `pangram image photo.jpg` submits an image check and waits for its result.
- Allowances: `pangram account` returns current text credits and image scans.
- Saved results: `pangram result HISTORY_UUID` or `pangram image-result IMAGE_RESULT_UUID`.

A request to check specified content authorizes that submission against the user's plan. Each submission consumes its corresponding allowance. Use `--no-wait` to return a job receipt and preserve its ID. After a timeout, resume with `pangram status TASK_ID --wait`, `pangram image-status TASK_ID --wait`, or `pangram batch BATCH_ID --wait`. Retrying the original submission creates another check.

Commands emit JSON on stdout and progress on stderr. Redirect full results to a local file when they are large. Text results include complete segment data under `response_payload.windows`; `response.in_page` is one display page. Image results include `model.ai_likelihood`, `model.confidence`, and `model.heatmap`. Report Pangram's classification as its estimate. Text fractions describe portions of the text and are distinct from likelihood scores.

## Session

The CLI uses Pangram's web session and plan allowances. Text submission mirrors the website's defaults: plagiarism detection off, repository insertion on, and the account's logging preference honored. File uploads and image checks use server defaults.

Run `pangram account` to check authentication. Import an authenticated capture with `pangram auth import-har /path/to/capture.har` when needed. The CLI stores its session credential with owner-only permissions outside the repository and fetches a CSRF token for requests. An expired session requires a fresh capture. Keep credentials and HAR contents out of chat and tracked files.

The implementation and usage documentation live in `~/Code/pangram-cli`. Diagnose endpoint failures there before attempting another paid submission.
