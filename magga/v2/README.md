# ds4cc-MAGGA v2

**MAKE ARMORGAMES GREAT AGAIN** · *EVERYTHING IS PC x Make Love Not Warcraft* ·
benchmark definition **0.2.0**

> Take the checkpoint for legendary Flash-era games, with all the back
> infrastructure built, the full commit audit and traces. Take the checkpoint
> status and ship the final deliverable for each. In a one-shot prompt, with
> native substrate capabilities.

A quality, creative, multimodal benchmark that you can actually play. The
public deliverable is the arcade at **ds4cc.com/magga**: play the games, hear
them, find where they break, and inspect how they were made.

## The three inputs

Every run gets the same three things. Nothing else is held fixed.

1. **The references.** Seven games that shipped long ago on infrastructure
   nobody can build on anymore: Flash, dead portals, old desktop builds.
   Everyone can remember them, and nobody can ship them as they were.
2. **The checkpoint package.** `VeigaPunk/MAKEARMORGAMESGREATAGAIN-v2` is a
   proprietary, half-done deliverable: design dossiers, specs, a monorepo,
   prototypes, a near-complete level game, verification rounds, and the full
   git trail of a day of live multi-model work, dead ends included. It runs,
   and it is not finished.
3. **The one-shot prompt.** [one-shot-prompt.md](one-shot-prompt.md), the same
   bytes for every model and substrate.

Nothing tells the model how to get from 2 to 1. It has to read the checkpoint,
check it against the references, decide which parts of the path to keep, and
ship.

## What v2 changes

The roster, the mission and the half-done-package format are unchanged from
v1. Three things change.

**The framing.** v1 told runs that architecture was decided once and bound
later runs. Most of them stayed on the checkpoint's stack without asking
whether it was the right one. v2 replaces that rule with a production story.
In *Make Love, Not Warcraft*, South Park, a 2D cutout show, got into a 3D
game. The show was already animated in Maya, so it could take in real 3D
material. Blizzard opened a test server and supplied character models, and
Trey Parker directed players inside the game while the team reworked the
footage in Maya. The episode won the first Emmy for machinima. Blizzard's own
history supplies more bridges: WoW Classic moved from reviving the old client
to running the preserved data on the modern engine; StarCraft: Remastered kept
the rules and rebuilt the presentation; Hearthstone went to Unity instead of
WoW's engine. The prompt asks, per game, what must be preserved exactly and
what should be rebuilt on something better. The checkpoint is the set and
the cast, not the engine. Keeping the stack, porting its data to a new engine,
going 3D, or anything else is allowed. Losing what works is not allowed.

The title's *EVERYTHING IS PC* half is deliberately not explained to the
builder. It names the pack, not a style. It does not prescribe a plot,
position or stack. Runs interpret it through what they ship, or they ignore it.

**The roster is explicit at seven.** Chicken Invaders and Cluck Horizon are
two games on one shooter engine. Boxhead now includes LAN play between
separate devices. Clashbound, an off-roster card game that the previous
attempt added, was removed from the package.

**The hand-off is sealed.** The builder never sees the catalog, the other
editions or how publication works until its own submission is locked. See
[Lock, then envelope](#lock-then-envelope).

## The roster

| # | Reference | What it tests |
|---|---|---|
| 1 | Swords & Sandals 2: Emperor's Reign | Character creation, tactical combat, shops, progression, persistence |
| 2 | Boxhead: 2Play Rooms, with LAN | Real-time combat, arenas, solo, local co-op, deathmatch, and play between devices on one network |
| 3 | Chicken Invaders 2: The Next Wave | Waves, weapons, missiles, bosses, campaign |
| 4 | Cluck Horizon (original IP, same engine as 3) | Content-pack architecture: a second campaign without a fork |
| 5 | The World's Hardest Game | Precision movement, authored corpus, deterministic validation |
| 6 | The Impossible Game | Timing, collision precision, rhythm, instant retry, full campaign |
| 7 | The McDonald's Videogame (shipped as Burger Tycoon) | Four connected departments, economic balance, dirty actions and consequences |

All seven count. A missing game or campaign prevents a fleet-complete result.

## Lock, then envelope

The v1 checkpoint was pushed to after it was handed out: a run shipped into
the shared origin, and a revert followed. v2 closes that at three levels.

- **Server.** The checkpoint repository is archived, and it carries branch
  and tag rulesets with no bypass actors. Pushes are rejected for everyone,
  including the owner. Both layers were probed against a throwaway repository
  on 2026-09-23 and rejected pushes from an admin token.
- **Clone.** Its origin push URL is `DISABLED`, and the prompt forbids pushing
  to it at all times.
- **Sequence.** Publishing is impossible before the lock, because the builder
  does not know where or how to publish until then.

The builder writes `delivery/` and runs `node tooling/lock-submission.mjs`.
That validates the folder, writes `LOCK.json` (a SHA-256 inventory and
digest), commits it, and decrypts `delivery/ENVELOPE.sealed` into
`ENVELOPE.md`. The envelope ([envelope.md](envelope.md)) sends the builder to
look at the catalog, fit its card and optional launcher restyle to the
catalog's style, record its run identity, and submit a pull request to
`VeigaPunk/MAKEARMORGAMESGREATAGAIN-submissions`, or leave a local bundle
when GitHub is unavailable. Game bytes stay frozen; the launcher overlay may
only replace `site/index.html` and add files.

The seal is a commitment device, not cryptographic access control: the key is
in the lock tool. Early opening is detectable. The envelope carries a receipt
code whose hash is recorded operator-side, and a pre-lock commit or file that
contains it is contamination. Record it as such.

## Launching runs

`magga/v2/run.sh` starts one clean run with one command, locally or in a cloud shell:

```bash
# once, on the machine that is signed in: export its logins (a secret file)
bash magga/v2/run.sh creds
# each run: <cli> [vanilla|godspeed|ufo]
curl -fsSL https://raw.githubusercontent.com/VeigaPunk/1shot/main/magga/v2/run.sh | bash -s -- codex ufo --creds magga-creds.b64
```

It gives each run a fresh privileged Docker container, or an isolated home directory when Docker is
missing. Inside it installs the toolchain (Node via fnm, uv, IPython, Harbor, agent-browser) and the
latest CLI, copies in only that CLI's login, checks the pinned prompt and the variant tarball against
their SHA-256, and bypasses every permission prompt. When the run ends it writes `run.json` plus the
lock and envelope-peek checks. The variant is recorded in each run's identity: `vanilla` is the prompt
alone; `godspeed` and `ufo` install that skill package (`variants/*.tar.gz`) and append `/godspeed`
or `/ufo` to the message.

## Running a matched run

1. Once per checkpoint revision, run `magga/v2/release-checkpoint.sh
   <checkpoint-dir>`. It pushes this prompt, seals the envelope with the
   prompt's pinned raw URL, publishes the checkpoint, applies the rulesets,
   archives the repo, creates the submissions repo if needed and probes that a
   push is rejected. Commit the resulting `envelope-record.json` and fill
   `benchmark.json` → `v2.checkpoint`.
2. Give the builder a clean environment containing either the cloned
   checkpoint or an empty directory, plus the prompt. Nothing else is given:
   no benchmark docs, other renditions, prior sessions or website checkout.
3. When the builder ends, run `node tooling/lock-submission.mjs --check` in its
   working copy, keep an immutable copy of that working copy, and review the
   pull request against `LOCK.json`.
4. Publish with [../delivery/publisher.md](../delivery/publisher.md) under
   `ds4cc.com/magga/v2/<edition>/`, with the `[oneshotprompt(magga-v2)]` label
   linked to the pinned prompt. Catalog tabs per benchmark version and final
   styling are operator work outside the benchmark.

Record per run: benchmark version, prompt commit and SHA-256, checkpoint
commit and tree, envelope `plaintext_sha256`, model and substrate versions,
effective configuration, actual helper models, human interventions, resource
allowance and usage, fresh or continuation, lock digest and lock commit, and
whether the receipt code appears anywhere before the lock commit.

## Judge the actual games

Unchanged from v1. Assess every title for fidelity and feel, completeness,
visual craft, audio, controls and usability, stability, performance, and now
portability: nested path, mobile, and LAN where claimed. Use actual play and
listening on the frozen build, independent of the agent's claims. Record the
architectural decision each run made per game and whether it paid off. That
decision is part of what v2 measures. Keep partial, failed and unverified
requirements visible. Publish per-game findings, not an average. v1 and v2 are
different prompt/package pairs; show them as versions, not one ranking.

## Sources for the framing

- [Make Love, Not Warcraft — production](https://en.wikipedia.org/wiki/Make_Love,_Not_Warcraft):
  Blizzard collaboration, alpha server, Maya re-creation, first machinima Emmy.
- [Restoring History: Creating WoW Classic](https://worldofwarcraft.blizzard.com/en-us/news/22646759)
  and [Dev Watercooler: WoW Classic](https://news.blizzard.com/en-us/article/21881587/dev-watercooler-world-of-warcraft-classic):
  1.12 data on the modern engine after the old-client build proved unworkable.
- [Remastering StarCraft's Art](https://news.blizzard.com/en-us/article/20695698/remastering-starcraft-s-art):
  same gameplay, rebuilt presentation, classic toggle.
- [Unity: Moving from internal engine technology](https://unity3d.com/files/solutions/unityformobile/A_Guide_To_Moving_From_Internal_Game_Engine_Technology.pdf):
  Hearthstone on Unity, WoW on a custom engine, Maya in the art workflow.
- South Park moved to Maya in season 5; the cutout look is rendered from 3D
  (South Park Studios FAQ, cited via [Wikipedia: South Park](https://en.wikipedia.org/wiki/South_Park);
  the southpark.cc.com FAQ URLs returned 404 when checked on 2026-09-23).

This is the v2 definition and launch kit. No v2 rendition exists yet.
