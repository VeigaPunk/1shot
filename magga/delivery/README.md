# Delivery envelopes — operator notes

These are separate from the historical one-shot prompt. Its bytes stay unchanged.

The Kimi exchange established `1shot@15118e3` as the task's fixed prompt. That
text speaks to an owner shipping games and keeps publication outside the build.
Use the same separation: a normal development task, then a normal release handoff.

## Give the builder only its work

Provide the prepared checkpoint, the exact selected one-shot prompt, and
[worker.md](worker.md) as a separate delivery note. Substitute a neutral release
ID such as `night-arcade-004`. Do not include a model name or experiment label
in that ID. Do not rewrite or combine changes into the original prompt file.

Keep benchmark definitions, scoring, this operator note, run comparisons,
other solutions, prior sessions, website credentials and the website checkout
outside the builder's accessible context. Do not mount the entire `1shot`
repository beside the task: it now contains operator-only benchmark documents.
Record the prompt and delivery-note hashes privately, including the final
substituted note. Do not tell the builder it is being assessed or give it
evaluator instructions disguised as development advice.

The builder writes its complete submission under its own working copy and
creates `READY` last. This respects the original no-publication instruction.
It does not require a public API, login or remote upload.

## Receive, then publish

When the builder ends, the operator receives that folder, checks its inventory
and preserves an immutable copy. Then start a separate publishing session with
[publisher.md](publisher.md), the submission copy and website access. Fill in:

- `submission_dir`: the absolute path to the received copy.
- `release_id`: the same neutral ID used by the builder.
- `prompt_raw_url`: a raw URL pinned to the exact prompt revision; for the
  historical prompt use
  `https://raw.githubusercontent.com/VeigaPunk/1shot/15118e3929e5e5d247a8135e88457857ca5254f1/magga/one-shot-prompt.md`.
- A publication title and any desired model/substrate credits, supplied only
  after the builder has ended.

The actual route is `VeigaPunk/ds4cc-marketplace` → its existing GitHub Pages
workflow → `ds4cc.com/magga/<release_id>/`. No HTTP intake endpoint exists in
this setup. These files define a manual handoff; they do not install a queue
watcher, upload service or automatic deployment agent.

Collection styling belongs to the publisher. Submitted game and launcher bytes
remain frozen. Keep the operator's assessment and run identity separate from
the release's player-facing files.

This keeps benchmark information out of the supplied build brief. It cannot
erase a model's prior knowledge or guarantee blindness if the host exposes
other sessions, directories, instructions or the collection. Enforce those
boundaries in the launch environment.

## MAGGA v2

v2 replaces `worker.md` with a lock-first hand-off built into the checkpoint:
`delivery/`, `tooling/lock-submission.mjs` and a sealed envelope. Give the
builder only the checkpoint and [the v2 prompt](../v2/one-shot-prompt.md).
The envelope sends finished runs to pull requests on
`VeigaPunk/MAKEARMORGAMESGREATAGAIN-submissions`. Publish accepted ones with
[publisher.md](publisher.md), using `magga/v2/<edition>/` as the path and
`[oneshotprompt(magga-v2)]` as the label. The overlay in an edition's
`launcher/` may replace `site/index.html` and add files; it may not change any
other locked byte. Setup and protection: [../v2/README.md](../v2/README.md).
