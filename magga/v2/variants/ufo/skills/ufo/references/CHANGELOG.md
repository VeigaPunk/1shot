# UFO-FSD CHANGELOG

Dated re-charter history, extracted from normative prose per improvement-pack
spec 08 §1. Normative text in SKILL.md and run-logic.md stays timeless; every
dated decision lives here. Entry format: date / decision / supersedes /
rationale / evidence. This file is a tracked canonical doc: it rides the
contract-sync mirror set and the native contract hash.

## 2026-09-11 — dispatch-time output policy
- decision: English natural-language output with unchanged English JSON
  contract keys; `--print-thoughts` controls output visibility ONLY (not
  reasoning effort, verbosity, tool access, or auto-approval); no
  model-specific reasoning-language instruction
- supersedes: none (initial statement)
- rationale: admission relies on observable actions and artifacts; hidden
  reasoning is never required evidence
- evidence: SKILL.md OMP native profile; corrected wording 2026-09-17

## 2026-09-11 — Sekhmet/L3 shelved
- decision: Sekhmet/L3 is shelved — no sparks as routes, fallback
  transports, proposal seats, or prerequisites; the retained
  evidence-only implementation and its 64-worker ceiling are
  compatibility data, and no spark output enters a NativeRoundHandoff
- supersedes: L3 as an active dispatch tier
- rationale: operator doctrine; the OMP native profile carries dispatch
- evidence: SKILL.md role section; run-logic §4.2; `l3Evidence` config

## 2026-09-12 — SWE-2-everywhere route contract
- decision: all seats on `devin/swe-2`, including a same-day flash-main
  interlude
- supersedes: initial mixed routing
- rationale: uniform seat routing under Devin OAuth
- evidence: superseded 2026-09-15; git history

## 2026-09-15 — OMP-only re-charter; route table frozen
- decision: OMP is the only automatic substrate (`automaticSubstrate` stays
  `omp`; the other six adapters are compatibility surfaces); per-seat route
  table frozen — Main, fleet L1s, and thinking seats on `devin/swe-2:max`
  with empty fallbacks; distiller and the six mechanical seats on pinned
  flash chains; advisor disabled (absent from `omp-native-v1`);
  `xai/grok-4-fast` removed from all chains; Kimi Code OAuth de-chained
  (installed, no active chain)
- supersedes: 2026-09-12 SWE-2-everywhere
- rationale (token-poor, operator): the Token Plan carries ~15 USD of
  credits, so paid flash capacity fronts the high-throughput mechanical
  seats while unmetered SWE-2 covers Main and the thinking seats
- evidence: config/ufo.json pins; git history

## 2026-09-16 — planner-seat override
- decision: planner seat primary `alibaba-token-plan/qwen3.8-max:xhigh`,
  empty fallback — the only deviation from the frozen 2026-09-15 table
- supersedes: planner on `devin/swe-2:max` (2026-09-15)
- rationale: operator directive; planner quality on the xhigh effort tier
- evidence: config/ufo.json `modelRoutes.planner`

## 2026-09-17 — improvement pack re-charter (PC + P3 + P4)
- decision: admission profiles split (strict v1/v2 + resilient attempt
  ledger); failure-action matrix + backpressure under
  `nativeProfiles.*.recovery`; effective-launch attestation; token budgets
  (`budgets.*`, `honesty_brake`/`interrupted` emitted); route table gains
  tier indirection (`routeTiers`/`seatTiers`) + `failureDomains` +
  `routes:equivalence` gate + per-domain Phase 0 probes + lane-health
  ledger; prose route table deleted from run-logic §6/SKILL.md (config is
  the sole statement); drill matrix harness + dependency closure
- supersedes: prose-restated route table (config was already authoritative)
- rationale: three re-charters in five days proved the table is the
  most-volatile artifact in the most expensive format; correctness core
  before efficiency per the pack's merged phase order
- evidence: docs/advisory/2026-09-17-ufo-improvement-pack/; commits
  4043a7e7 (PC-A), 1bddc7b3 (PC-B), c166c8cd (PC-C), 2c087de6 (P3),
  285fc692 (P8-structural)

## 2026-09-18 — improvement pack judgment/enforcement/hygiene (P5–P7)
- decision: membrane sign-off (`authority_boundary` + TTY-gated
  `ufo charter sign` + Phase 0 re-pass) with artifact-trust screening;
  executable/evidence/subjective axis measurements with computed deltas
  outranking advisory scores; writer lease with fencing epochs,
  journaled transactional apply, and raw+derived evidence digests;
  bounded round digests (`ufo-round-digest-v1`) with the clean-round
  saturation rule and plan-digest binding with wave-drift provenance
- supersedes: prompt-text-only enforcement boundaries; advisory-only
  axis scoring; unbounded cache carry; saturates-on-any-zero-accept
- rationale: judgment integrity requires mechanism below the prompt
  (F09–F12, F18); computed measurement beats narrated improvement
- evidence: docs/advisory/2026-09-17-ufo-improvement-pack/; commits
  52898c0b + 5bd0584d (P5), 1d1f95d4 (P6), 241ec3a2 (P7)
