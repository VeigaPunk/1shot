# ds4cc-MAGGA

**MAKE ARMORGAMES GREAT AGAIN** · Benchmark definition **0.1.0**

A quality, creative, multimodal benchmark that you can actually interact with.
The public deliverable is the arcade at **ds4cc.com/magga**: play the games,
hear them, feel the difference, find where they break, and inspect how they
were made. The finished work is the receipt of what these systems can do.

Give an agent a real game-development checkpoint and have it turn the whole
fleet into complete, faithful, refined browser games—the versions you would
actually ship. Recover what made the originals great, then improve them with
modern craft. All six matter. One gem beside five prototypes is unfinished.

## V1 essence

Given a shared checkpoint, references for six classic games, and a shared
prompt: **how good can you make them?** Quality, taste, creativity and the
ability to finish several games belong at the center of the challenge.
"Good enough" is not the target. Leave room for resourcefulness and exploration,
with no prescribed ceiling on the ambition or craft of the result.

Compare models **in their native substrates**. Their ability to understand the
checkpoint, obtain tools, create visuals and audio, make design decisions,
integrate the work and verify the result is part of what people are seeing.
The rendition is evidence about that model working through that setup.
Record actual resources and assistance; open ambition is not a claim that
every run had unlimited or identical time, budget or access.

Make the evidence available beyond the model providers' own reports. Anyone
should be able to try the deliverables and judge the strengths and failures
for themselves. Alongside each playable rendition, make its source, exact
prompt, setup, verification and known gaps inspectable. Scores can summarize
findings; they cannot substitute for the work people can play and examine.

Expand the collection across providers and iterate the benchmark itself while
preserving each run's conditions and artifact. The early Codex rendition used
a different prompt; keep that visible when showing it beside the one-shot
renditions. Historical examples do not become matched comparisons retroactively.

The intention checkpoint is **`1shot@15118e3`**, from the Kimi session that
confirmed the original one-shot was pushed. [That prompt](one-shot-prompt.md)
is preserved byte-for-byte. This benchmark definition does not rewrite it.
Exact source and prompt identities are in [benchmark.json](benchmark.json).

The separately versioned [v2 DLC](v2/README.md), **EVERYTHING IS PC x Make Love
Not Warcraft**, carries this essence into animated comedy, fantasy adventure
and a collectible-card game. It has its own [one-shot prompt](v2/one-shot-prompt.md).

## The challenge

| Original | What the game tests |
|---|---|
| Boxhead: 2Play Rooms | Real-time combat, arena design, solo survival, local co-op and deathmatch |
| The Impossible Game | Timing, collision precision, rhythm, instant retry and a complete campaign |
| Burger Tycoon / McDonald's Videogame | Four connected departments, economic balance, dirty actions and consequences |
| Chicken Invaders 2 | Wave design, weapons, missiles, bosses and campaign progression; Cluck Horizon stays a second pack in the same engine |
| Swords & Sandals 2 | Character creation, tactical combat, shops, progression and persistence |
| The World's Hardest Game | Precision movement, authored puzzles, deterministic simulation and validation |

The deliverable includes the games themselves: complete content, coherent
original art, music and SFX, fair tuning, menus, pause, settings, restart,
keyboard/mouse and touch controls, saves where appropriate, and usable
performance. One entry point; playable locally without a player build step,
CDN or external service. Player-facing brands and assets must be original.

This tests code comprehension, planning, design judgment, tool use, asset and
audio creation, implementation, debugging, integration, verification and
honest delivery. The agent owns its approach. No mandated framework, renderer,
visual style, delegation strategy or test harness.

## Benchmark × one-shot prompt

The benchmark defines **what is being attempted and evaluated**. A separately
versioned one-shot prompt supplies **the wording used to set the agent to work**.
We can provision different operator-authored, stylized prompts against the same
benchmark. Store their exact bytes; do not silently rewrite or append to them.
Keep this benchmark definition and evaluation metadata operator-side. The
builder receives the task prompt and a normal [release-delivery note](delivery/worker.md).
Record every supplied input privately. The [delivery envelopes](delivery/README.md)
separate the finished local handoff from publication at `ds4cc.com/magga/`.

Each run identifies its benchmark version, prompt revision/hash, source snapshot,
model and CLI versions, configuration, actual helper models, resource allowance
and usage, and final artifact hashes. A continued session records its parent
and cumulative work. It is not another fresh attempt.

Change the prompt to study prompting. Change the benchmark to study a different
challenge. Version them independently and hold the other conditions fixed when
comparing. Keep original runs and results attached to their original versions.

## Keep the comparison clean

- Start from the pinned checkpoint's game files, without its Git history or
  operator configuration. Keep other renditions and previous session memory out
  of reach. A reverted solution in history is still a solution.
- Disclose the effective setup and model routing. A native CLI setup, operator
  customization, and mixed-model assistance must be distinguishable in results.
- Let agents obtain development tools within the declared run conditions.
  Reference the checkpoint and original games; exclude other remakes and
  benchmark solutions.
- Old prototype scope, stack instructions and “shipped” labels cannot lower the
  task. Before comparative runs, fix the expected full-content checklist for
  each selected original release. Mark historical uncertainties explicitly.
- Preserve working behavior when iterating a rendition, but allow justified
  improvements and architectural changes. Existing tests do not define quality.

## Judge the actual games

Evaluate every title for fidelity and feel, completeness, visual craft, audio,
controls and usability, stability and performance. Review the frozen build
independently of the agent's own completion claim, including actual play and
listening where claimed. Tests provide evidence; they do not award polish.

Require real input on the real build for playthrough claims. Record full
campaign coverage, or sustained-loop coverage for endless and management games.
Keep partial, failed and unverified requirements visible. A missing game or
campaign prevents a fleet-complete result; other strengths still deserve to
be recorded. Publish the per-game assessment, not just an average.

Freeze the evaluated artifact. Publishing it later must preserve its bytes;
restyles belong outside the edition or become a new evaluated revision. Keep
resource costs and assistance visible. Compare repeated matched runs before
making broad claims about a model.

This is the initial benchmark definition, not a claim that new runs or rankings
have already been validated. Iterate the benchmark from observed results while
preserving the original mission and the untouched historical prompt.
