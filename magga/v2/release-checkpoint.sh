#!/usr/bin/env bash
# Operator-side. Publish the MAGGA v2 checkpoint and make it impossible to push to.
#   magga/v2/release-checkpoint.sh <checkpoint-dir>
# Order matters: the prompt is pushed first so the envelope can pin its raw URL,
# then the envelope is sealed into the checkpoint, then the checkpoint is published
# and locked down (ruleset with no bypass + archive = read-only for everyone).
set -euo pipefail
owner=VeigaPunk
repo=MAKEARMORGAMESGREATAGAIN-v2
submissions=MAKEARMORGAMESGREATAGAIN-submissions
checkpoint=$(realpath "${1:?usage: release-checkpoint.sh <checkpoint-dir>}")
oneshot=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)

git -C "$oneshot" diff --quiet HEAD -- magga/v2/one-shot-prompt.md || { echo "commit magga/v2/one-shot-prompt.md first" >&2; exit 1; }
git -C "$oneshot" push origin HEAD:main
prompt_commit=$(git -C "$oneshot" log -1 --format=%H -- magga/v2/one-shot-prompt.md)
prompt_url="https://raw.githubusercontent.com/$owner/1shot/$prompt_commit/magga/v2/one-shot-prompt.md"

node "$oneshot/magga/v2/seal-envelope.mjs" "$checkpoint" "$prompt_url"
git -C "$checkpoint" add delivery/ENVELOPE.sealed
git -C "$checkpoint" diff --cached --quiet || git -C "$checkpoint" commit -qm "Seal publication envelope"

gh repo view "$owner/$repo" >/dev/null 2>&1 && { echo "$owner/$repo already exists; refusing to overwrite a handed-out checkpoint" >&2; exit 1; }
gh repo create "$owner/$repo" --public --description "MAGGA v2 checkpoint: seven Flash-era remakes, half done. Read-only." --disable-issues --disable-wiki
git -C "$checkpoint" push "https://github.com/$owner/$repo.git" HEAD:refs/heads/main
git -C "$checkpoint" tag -f checkpoint-v2 HEAD
git -C "$checkpoint" push "https://github.com/$owner/$repo.git" refs/tags/checkpoint-v2

gh api -X POST "repos/$owner/$repo/rulesets" --input - >/dev/null <<'JSON'
{"name":"checkpoint is immutable","target":"branch","enforcement":"active","bypass_actors":[],
 "conditions":{"ref_name":{"include":["~ALL"],"exclude":[]}},
 "rules":[{"type":"creation"},{"type":"update"},{"type":"deletion"},{"type":"non_fast_forward"}]}
JSON
gh api -X POST "repos/$owner/$repo/rulesets" --input - >/dev/null <<'JSON'
{"name":"tags are immutable","target":"tag","enforcement":"active","bypass_actors":[],
 "conditions":{"ref_name":{"include":["~ALL"],"exclude":[]}},
 "rules":[{"type":"creation"},{"type":"update"},{"type":"deletion"}]}
JSON
gh repo archive "$owner/$repo" --yes
git -C "$checkpoint" remote remove origin 2>/dev/null || true
git -C "$checkpoint" remote add origin "https://github.com/$owner/$repo.git"
git -C "$checkpoint" remote set-url --push origin DISABLED

if ! gh repo view "$owner/$submissions" >/dev/null 2>&1; then
  gh repo create "$owner/$submissions" --public --description "MAGGA edition submissions: pull requests from locked runs." --add-readme
fi

commit=$(git -C "$checkpoint" rev-parse HEAD)
tree=$(git -C "$checkpoint" rev-parse 'HEAD^{tree}')
echo
echo "checkpoint  https://github.com/$owner/$repo  commit $commit  tree $tree  (archived, rulesets active)"
echo "prompt      $prompt_url"
echo "record      $oneshot/magga/v2/envelope-record.json  -> fill benchmark.json v2.checkpoint and commit"
if git -C "$checkpoint" push "https://github.com/$owner/$repo.git" HEAD:refs/heads/push-probe-must-fail >/dev/null 2>&1; then
  echo "WARNING: push probe was accepted" >&2; exit 1
else
  echo "push probe  rejected, as intended"
fi
