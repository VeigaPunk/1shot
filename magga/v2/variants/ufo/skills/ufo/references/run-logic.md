# UFO-FSD — Run Logic

> Provenance: tracked local UFO-FSD contract, revised 2026-09-15.
> The original ignored `.ufo/local-dispatch/l1-speedrun-24h-three-prompts.md`
> is unavailable and has no Git history. The three guidance themes below are
> an evidence-backed semantic reconstruction from tracked launch and handoff
> material; they are not quoted or claimed byte-identical to the missing file.

Language-neutral contract for the one canonical runtime. Framework: UFO-FSD.
Posture: godspeed. Planner stance: wwkd.

Dispatch doctrine: OMP-only.
`automaticSubstrate` stays `omp`; the other six installed adapters remain
compatibility surfaces, never automatic fallback transports. Native `kimi`
and Sekhmet/L3 are not selected. The frozen per-seat route table is stated
once, in `config/ufo.json` `nativeProfiles.omp-native-v1` (`seatTiers` →
`routeTiers` over the consumed `modelRoutes`/`modelFallbacks` pins; planner
deviation pinned there, recorded as history in CHANGELOG.md). §6 states the
routing invariants; this header restates no pins.
Assignments use English natural-language output and unchanged JSON contract
keys; no model-specific reasoning-language instruction is injected.
Exactly one terminal `| godspeed` per assignment; fail-closed on drift.
One authored Godspeed source: `ssot/godspeed-core/directive.md`. Host and
packaged copies (e.g. `references/godspeed-core/directive.md`, repo-root
`godspeed-core/directive.md`, the bundled crate copy, and every packaged
skill target) are checked generated mirrors, not a second authority.

Load authored guidance once per unchanged session. A digest-bound assignment's
canonical directive prefix is already loaded posture; do not expand it from a
second skill or mirror. On fleet dispatch one leading `/ufo` invocation
precedes overlays and the one directive prefix; omp-native assignments carry
no `/ufo` and must begin with the directive bytes themselves. Mirror parity
is a sync check, not repeated reading.

## Operator guidance themes (reconstructed)

These identifiers are exact and durable:

1. **`phase0_lkg_gate`** — compare the local tree with its last-known-good
   base, retain only non-regressing moves, then pass contract, compile, boot,
   and probe checks before round 1.
2. **`same_essence_substrate_shape`** — keep runtime, judge, Pareto, telemetry,
   reroute, and stop semantics identical. Only command and packaging shape may
   differ across `omp`, `kimi`, `codex`, `cursor`, `opencode`, `grok`, and `devin`.
3. **`reroute_not_respawn`** — a local route failure keeps the same logical
   lane identity, prompt, and cache. It never mints a replacement logical
   agent or switches runtime, judge, or substrate.

The runtime exposes and tests exactly these identifiers.

---

## 0. Invariants

- **I1 — One judge.** One local L1 owns the run; only the canonical Rust
  runtime emits judgment. Adapter guards reject a second L1 or judge.
- **I2 — The L1 works.** L1 plans, executes, integrates, and submits evidence
  to Rust. It never waits for a specialist to become the orchestrator.
- **I3 — Degrade honestly.** One unavailable lane cannot kill a sound wave.
  Other lanes continue, and the failed lane continues on another implemented
  local route when one exists. If every lane is unavailable, halt with
  evidence; never manufacture convergence or a proposal.
- **I4 — Failure is data.** Route failures and unavailable lanes are typed
  telemetry with identity, cause, source route, destination route, and round.
- **I5 — Cache on dispatch.** Every logical lane receives the current cache.
  A child process is transport, not a new lane identity.
- **I6 — Reroute, do not respawn.** Recovery keeps lane identity and cache.
  A replacement logical agent is never created for the same work.
- **I7 — Runtime identity is immutable.** The run stays in
  `crates/ufo-core-runtime`, with one judge and one selected substrate.
- **I8 — Honesty outranks progress.** Zero accepted proposals is convergence
  only after a complete, sound round. No progress theater.
- **I9 — Tracked authority wins.** Canonical guidance and runtime source beat
  generated artifacts and mirrors. Drift halts and names both paths.
- **I10 — Local-first ship.** A target is verified only when its local command
  surface is invoked. Publishing and deployment remain operator-owned.

---

## 1. State

```
RunState {
  token:         RunToken
  task:          String
  runtime:       "crates/ufo-core-runtime"
  judge:         "single-local-l1"
  substrate:     omp | kimi | codex | cursor | opencode | grok | devin
  axes:          FrozenAxisSet
  baseline:      ScoreVector
  round:         Int
  lanes:         Map<LaneIdentity, Lane>
  cache:         RoundCache
  telemetry:     Vec<Event>
  reroutes:      Vec<RerouteRecord>
  contract_sync: ContractSyncReport
  stop:          RUNNING | SATURATED | BUDGET_HALT | BLOCKED
}

Lane {
  identity: LaneIdentity       // durable tuple, spec 11 §4:
                               //   logical_lane_id = <run_id>/<role>/<instance>
                               //   frozen_scope_hash    — distinguishes repeated roles
                               //   native_agent_id      — per actual spawn (OMP)
                               //   attempt_id           — per try on any route
                               //   wave_token           — per dispatch (spec 02)
  role:     SpecialistRole
  route:    LocalRoute
  allowed_routes: Vec<LocalRoute>
  state:    READY | UNAVAILABLE
  cache:    CacheRef
}
```

Field names are contractual, not literal struct members: `runtime`/`judge`
are pinned constants, `cache`/`telemetry`/`contract_sync` are digest fields
and `.ufo` artifacts rather than stored loop state, and lane availability is
computed per dispatch — a failed lane either
recovers on its typed chain or reports `UNAVAILABLE`. `cache` is physically
a chain of bounded round digests (`ufo-round-digest-v1`,
`.ufo/rounds/<runId>/r<NN>-digest.json`, bound `rounds.digest_max_bytes`,
default 32768, single-sourced in the runtime) plus hash references; raw
artifacts are re-fetched by hash on demand. Digests are the only
guaranteed carry-forward — every lane still receives prior-round context
(I5), as bounded digests and pointers, not raw accumulation.
`stop_reason` uses `running | round_cap | saturated | blocked` plus
`interrupted` (SIGINT/operator halt checkpointing a live round, spec 03),
`honesty_brake` (actual or projected budget exhaustion, spec 03 §4), and
`authority_boundary` (membrane-touching accepts awaiting operator sign-off,
spec 06) — all three emitted; `budget_halt` is the `LoopOutcome` name for
`round_cap`. Mapping: `stop` is the loop-state field; `loop_stop` (§8) drops `running`.
`stop_reason` is the checkpoint vocabulary, not a telemetry event.
The selected substrate is state, not a dispatch hint. It cannot change during
resume or reroute.
Within the loop this holds: resume restores the checkpointed substrate and
rejects route-provenance changes, and reroute stays on the same-substrate
chain. The Sighting mission-manifest `substrate` field is operator-
overridable at `resume` and is display/dispatch metadata, not loop state.

---

## 2. Boot and identity pin

```
fn boot(goal, substrate) -> RunState:
    assert substrate in [omp, kimi, codex, cursor, opencode, grok, devin]
    authorities = read([
        canonical_ufo_skill,
        canonical_run_logic,
        canonical_agent_cards,
        core_runtime_source,
        local_lkg_reference,
    ])
    assert authorities.operator_guidance == [
        phase0_lkg_gate,
        same_essence_substrate_shape,
        reroute_not_respawn,
    ]
    assert exactly_one_runtime("crates/ufo-core-runtime")
    assert exactly_one_judge("single-local-l1")
    state.substrate = substrate
    freeze(state.runtime, state.judge, state.substrate)
    return state
```

The `authorities` read and the `exactly_one_*` asserts are doctrine-shaped:
the concrete mechanism is the contract-sync mirror check plus the provenance
assert; uniqueness holds by construction (pinned constants), and the
guidance triple is emitted as `operatorGuidanceThemes` and asserted by the
gates battery.

### 2.1 `resume_continuity_v1`

Before any run-state, pane, or child mutation on resume, the exact native
session MUST be selected explicitly by its stable native identifier; recency,
ordinal selection, and `--continue` MUST NOT select it. Observe the selected
session's agent identity and canonical cwd/project, and require both to match
the frozen L1 mission. Missing evidence or any mismatch fails closed with zero
mutation. A resumed session retains its existing role and MUST NOT promote a
planner or any other subordinate to L1.
Enforcement is verified at dispatch preflight for `omp` (exact `--resume`
session UUID plus session-record attestation; `--continue` is rejected) and
`opencode` (`--session` plus export attestation). The other five substrates
carry no verified native resume; the machine map records them as
policy-assumption-only.

---

## 3. Phase 0 last-known-good gate

Phase 0 runs once before round 1.

```
fn phase0(state):
    diff = compare(local_tree, local_lkg_reference)
    review_each(diff, rule = improves_one_axis_and_regresses_none)
    reject_ambiguous_or_regressing_changes()

    contract_sync = verify_exact_guidance_and_agent_mirrors()
    require(contract_sync.ok)

    require(local_compile())
    require(local_boot())
    probe = require(local_probe(state.substrate))
    record(state.telemetry, Phase0Passed{contract_sync, probe})
```
The `local_lkg_reference` diff steps are L1 doctrine — no scripted baseline
ships in the repo. The mechanical gate is the contract-sync check plus the
mutation smoke battery; compile, boot, and probe are discharged by the
gates battery (`contracts:check` → `cargo build` → `ufo status` → per-seat
`self-iter` fixtures). Emitted telemetry is the `phase0` block
`{contracts, gates, provenance}` of `.ufo/rs-self-iter-report.json` plus the
`.ufo/contract-sync/r00.json` record — there is no `Phase0Passed` event.

No round starts from a broken or ambiguous base. Fix forward, rerun Phase 0,
then enter the loop.

---

## 4. Round loop

Axes freeze before the first plan. Every round then has the same order.

```
fn run(state):
    phase0(state)
    loop:
        state.round += 1
        plan      = wwkd_plan(state)
        outputs   = parallel_dispatch(state.lanes, plan, state.cache)
        distilled = distill(outputs)
        verdict   = canonical_rust_pareto_judge(state.baseline, distilled)

        advance_frontier_only(verdict.accepted)
        persist(state, outputs, verdict)

        match stop_condition(state, verdict):
            SATURATED   -> return SATURATED
            BUDGET_HALT -> return BUDGET_HALT; HONESTY_BRAKE -> return HONESTY_BRAKE
            BLOCKED     -> return BLOCKED
            CONTINUE    -> append_round_digest_and_continue()
```

Rejects, route failures, and no-proposal results remain in the cache. The next
round consumes them; the current round never changes its frozen contract.

### 4.1 Lane execution

```
fn lane_execute(state, lane, task):
    result = lane.run_current_route(task, lane.cache)
    match result:                        // RouteAttemptOutcome (state.rs)
        Proposal(output) -> return output
        NoProposal(note) -> return NoProposal(note)
        CapacityFailure(cause) -> {
            record(state.telemetry, cause)
            // only capacity classes advance: usage_limit | rate_limit |
            // model_unavailable; other typed failures never probe a route
            next = cause.is_capacity_class()
                ? next_implemented_local_route(lane)
                : none
            if next is none:
                lane.state = UNAVAILABLE
                return LaneUnavailable(cause)
            return reroute_same_identity(state, lane, task, next, cause)
        }
        Unavailable(cause) -> {
            lane.state = UNAVAILABLE
            record(state.telemetry, cause)
            return LaneUnavailable(cause)
        }
        ProcessExit(cause) -> {
            record(state.telemetry, cause)
            if lane.is_critical && retry_remaining(lane):
                return retry_same_identity_same_route(state, lane, task)
            lane.state = UNAVAILABLE
            return LaneUnavailable(cause)
        }
        LaneTimeout(deadline) -> {
            // terminal cause = time; elapsed = ended_ms - started_ms
            record(state.telemetry, lane_timeout{...})
            // never a capacity event: the route chain does not advance (I6)
            if lane.is_critical && retry_remaining(lane):
                return retry_same_identity_same_route(state, lane, task)
            lane.state = UNAVAILABLE
            return LaneUnavailable(lane_timeout)
        }
```

An unexpected process exit is not disguised as a reroute. The remaining wave
continues; an all-lane failure aborts the run with a hard error (exit 1),
not the `BLOCKED` stop value.

Deadlines are per seat class, declared in
`nativeProfiles.omp-native-v1.deadlines`: main to `orchestratorMs`, planner to
`plannerMs`, distiller to `distillerMs`, labrat to `labratMs`, the thinking
proposal roles to `thinkingMs`, the mechanical proposal roles to
`mechanicalMs`. `elapsed = ended_ms - started_ms` is compared against the
class bound; an exceed is a terminal cause of time (`LaneTimeout`), recorded
as `lane_timeout` telemetry and never as a capacity event — the route chain
does not advance (I6). A critical seat (Main, planner, probeParent, labrat,
distiller) takes exactly ONE same-identity same-route retry (D1a) on
`LaneTimeout` or `ProcessExit`; a second terminal failure makes the round
invalid for judgment while collection and provenance continue, and never
suppresses later reachable dispatch or its evidence. A non-critical seat
reports `UNAVAILABLE`, the wave continues, and its late output is
inadmissible.

Recovery actions beyond capacity advance are typed by the failure-action
matrix (`nativeProfiles.*.recovery`, spec 11): temporary classes
(`timeout`, `tool_failure`, `unknown`) take a bounded same-route retry
(`temporaryRetry.maxAttempts` total attempts, then `UNAVAILABLE`);
`authentication`/`permission_denied` report `authorization_unavailable`
with no retry and no hop (auth is not capacity); `invalid_request` is
`UNAVAILABLE` with no retry; capacity classes hop or retry per the chain;
`ProcessExit`/`LaneTimeout` keep the D1a rule above. Account-level
backpressure (`recovery.backpressure`): `herdThreshold` capacity failures
in one route-provider domain inside `herdWindowMs` cool the domain for
`domainCooldownMs` — lanes into a cooled domain record typed
`domain-cooldown` unavailability (waiting is an authorized action, never
a hop-storm); `maxConcurrentPerDomain` 0 is unlimited. Every action is
telemetry. No row authorizes a substrate, runtime, or judge change (I7),
a replacement identity (I6), or a weakened checker (I9).

### 4.2 OMP native evidence membrane

OMP owns native agent transport; Rust remains the only judge. The OMP host
builds a typed handoff — `omp-native-v2` by default, on the admission-profile
split below — after its task wave:

```
NativeRoundHandoff {
  profile, run_id, round, substrate, concurrency,
  concurrency_semantics, axes, axes_hash, contract_hash,
  contract_root, config_digest,
  proposal_seats: [NativeProposalSeat], probe_parent,
  agents: [NativeAgentProvenance],
  proposals: [NativeProposal],
  integrated_candidate, candidate_digest, candidate_receipt,
  baseline, provenance, telemetry,
  // additive OPTIONAL fields by profile (v1 carries none):
  plan_digest, acceptance_criteria,        // v2+ (A-07)
  effective_launch: [EffectiveLaunch],     // v2+ (spec 12)
  attempt_ledger, dispatch_attempts,       // resilient only (specs 10/11)
}
```

`scripts/run-omp-native-trial.mjs` requires canonical mirrors to match before
creating trial state, snapshots the Rust-computed contract hash, creates full
prompt artifacts, and invokes one interactive OMP Main by default. Explicit
headless and preparation-only paths never silently replace a failed visible
launch. The interactive Main shuts down after its final artifact and settled
tasks; the host then collects, judges, persists the outcome and retires the
pane. A stopped process or retired pane alone is not an admitted result.
`scripts/ufo-sighting` and its hash-bound `.mjs` helper own the attached
UFO Sighting terminal, pane registry, exact layout, and independent twin launch
membrane. They add no judgment, orchestration, provider, or credential layer.
`scripts/collect-omp-native-handoff.mjs` accepts only current-user,
non-symlink files bounded by declared run and session roots; rejects
launch/current contract drift — the launch contract hash and, when
`config/ufo.json` is present under the contract root, a re-hash against the
launch config digest plus a re-pin of every role route and fallback chain.
It snapshots OMP JSONL transcripts into a normalized evidence copy (reused
task call ids are uniquified and oversized uninspected fields are truncated
to the judge's 128 KiB line bound before hashing); extracts observed route,
failure, successful task-yield, actual spawn identity, and timing evidence;
pairs each successful task call with the spawn records in its task result;
screens failure details for credential-shaped data; screens proposal and
report artifacts for override-shaped patterns
(`membrane.screening.classes`: canonical directive bytes inside an
artifact, terminal markers, judge-addressed imperatives, assignment-shaped
headers, and directive-looking task data) and attaches typed
`screening_flags` — flags are evidence surfaced in the verdict, never
auto-rejection, and artifact content never modifies contract, axes,
routes, or judgment; and emits the typed
handoff. The collector synthesizes `lane_failure` and
`correlated_unavailability` telemetry itself; the manifest telemetry field
stays empty. Rejected calls that spawned no agent are not topology edges.
None of these scripts judges.

The collector asks the existing Rust runtime's `receipt-digests` command for
typed baseline, axes, and survivor-set hashes through bounded JSON stdin.
Rust owns structural serialization; JavaScript hashes only exact artifact
bytes. Digest generation is not admission: `judge-handoff` independently
recomputes and validates the receipt before judgment.

`skills/ufo/SKILL.md` owns the level vocabulary: Main is L1; every OMP
task/Agent Hub specialist descendant, including the depth-2 labrat, is L2;
only Sekhmet sparks are L3. Native parentage below therefore uses explicit
depths 0, 1, and 2 rather than treating depth as a level number.

The Rust `judge-handoff --input <path>` gate fails closed unless all of these
hold:

- one Main L1 orchestrator at depth 0; one depth-1 planner that completes
  before the proposal wave starts; Rust remains the judge;
- one frozen batched proposal wave of 6–16 depth-1 seats drawn from the
  ten-role proposal taxonomy; the launcher default is all 16 seats;
- `scout`, `reviewer`, `critic`, `connector`, `sentinel`, and `executor` each
  hold at least one mandatory seat; the default also includes
  `mutation-tester`, `revenger`, `simplifier`, and `scribe`; repeated roles use
  contiguous instances with distinct frozen assignment scopes and hashes;
- exactly one depth-2 `labrat`, parented by the frozen executor
  `probe_parent` — the handoff field for the dispatch seat `probeParent`,
  which the launcher designates as the first executor seat in blueprint
  order — and contained within that executor's interval; no other
  descendant;
- Main successfully spawns the planner, every frozen proposal seat in one
  batched call, and distiller; `probe_parent` successfully spawns exactly
  labrat; every other seat spawns zero tasks; non-spawning rejected tool calls
  do not create agents;
- one depth-1 distiller starts after the proposal wave settles and
  completes;
- the complete topology contains `proposal_wave_size + 4` seats and never
  exceeds 20;
- concurrency is in `1..=32`, counts live children including waiting parents
  and descendants, and reserves one descendant slot:
  `concurrency >= proposal_wave_size + 1`;
- observed proposal overlap is positive; the
  `min(proposal_wave_size, concurrency - 1)` upper bound is implied by the
  concurrency precondition above and needs no separate check;
- every actual agent id, job id, dispatch name, parent, depth, assignment,
  transcript, artifact, hash, status, interval, requested model, resolved
  model, fallback flag, and evidence kind is present and internally
  consistent; the labrat id is executor-qualified;
- every completed non-Main transcript binds exactly one OMP task `yield`
  call, which must succeed; its result timestamp is the seat's settlement
  endpoint even when a later process-disposal `session_exit` exists; the
  collector also requires the adjacent nonempty completion artifact before
  producing the handoff;
- every effective spawned assignment byte-matches the launcher-written
  canonical assignment and its SHA-256; only one task-call terminal newline
  may be normalized by OMP before the successful spawn result;
- every assignment begins with the canonical directive bytes, appears in its
  hashed OMP transcript, and contains exactly one terminal `| godspeed`;
- the project OMP skill and used agent cards are byte-identical mirrors, while
  `contract_hash` binds canonical guidance, routing, collector/launcher,
  attached entry point, Rust execution profile and judge source, and CLI
  source;
- the handoff freezes each requested model to the compiled canonical route
  (the collector binds the hash-bound launch manifest to the same routes);
  every transcript
  contains exactly one session envelope, one primary `model_change` (any
  further `model_change` must be a capacity-failure-justified fallback
  switch), the effort event matching that hop's declared effort suffix
  (never a clamped or assumed setting — the §6 effort rule types a clamped
  or unobservable setting as `effort_unsupported` /
  `effort_unverifiable`), and at least one served assistant
  provider/model observation; every non-Main transcript additionally
  contains exactly one `session_init` whose `resolvedModel` exactly echoes
  the full requested route including effort;
- Main requests `devin/swe-2:max`, resolves to `devin/swe-2` at max effort,
  and uses `extendedContext=true` with the doc-attested 262K context; the
  1,000,000-token `l1Context` floor is a catalog invariant, not a gate on
  the configured Main. Its empty fallback does not silently change models;
- every L2 role requests its pinned route from its declared seat tier in
  `config/ufo.json` `nativeProfiles.omp-native-v1` (§6 routing invariants;
  `seatTiers` → `routeTiers` over `modelRoutes`/`modelFallbacks`; planner
  deviation recorded in CHANGELOG.md) — resolving to the base model id
  at the declared effort with the typed fallback chain. Repeated roles use
  the same pinned route. Each
  `model_change` has a false fallback flag; no native seat uses
  `opencode-go`. Explicit fleet L1 studies are labeled separately and do
  not masquerade as this canonical native handoff;
- a failed proposal seat is bound to an OMP error transcript and one typed
  `lane_failure` event, while completed proposal seats retain canonical
  proposal artifacts; critical Main, planner, the frozen `probe_parent`
  executor, labrat, and distiller seats must complete for admission, and at
  least one proposal must survive;
- critical failure does not suppress a later reachable topology dispatch;
  collection preserves the failed transcript before Rust rejects admission;
- each surviving proposal equals its hashed native artifact and its provenance
  fields bind the OMP task id; no producer supplies a candidate — the
  distiller seat composes it, and Rust alone re-validates admission,
  composition, and digests before emitting the candidate in its
  digest-bound verdict;
- the handoff declares exactly one admission profile on substrate `omp` —
  `omp-native-v1` (frozen conformance) or `omp-native-v2` (the strict default,
  plan_digest + acceptance_criteria), and `omp-native-resilient-v1` only on an
  operator re-charter (the "Admission profiles" split below); axes are
  nonempty with unique ids and recomputed hashes; `contract_root`
  canonicalizes to the trusted project root, `config_digest` recomputes
  over `config/ufo.json`, and provenance must equal the active honest
  provenance; `.omp/config.yml` must byte-equal the regenerated projection —
  projection parity binds the project file, while the `effective_launch`
  record (v2+, spec 12) binds what each seat actually inherited; both are
  required and neither substitutes for the other;
  telemetry is restricted to `lane_failure`, `correlated_unavailability`, and
  `lane_timeout` events under `omp-native-v1`, plus `domain_cooldown`
  (observed herd record, spec 11 §5) under v2 and resilient;
  `lane_timeout` carries the identical field set to
  `lane_failure` (the deadline and elapsed times ride inside its bounded
  `detail` string — the v1 handoff schema gains no field); every handoff
  struct denies unknown fields under the declared byte ceilings.

Admission profiles (spec 10): a handoff declares exactly ONE admission
profile, and the two strict profiles — `omp-native-v1` (frozen conformance)
and `omp-native-v2` (the default) — admit one shape of route evidence: a
completed seat carries no route continuity. The strict rejection of a fallback
completion on a completed seat is the collector's die
`role <role> completed with route continuity; exact-primary evidence cannot
include continuity`, which fires before the handoff reaches the judge; that
rejection is the DOCUMENTED behavior (T03), not a surprise, and the judge's
twin rule stays unreachable on the native path.

`omp-native-resilient-v1` is a THIRD admitted profile, never a relaxation of
the other two: it validates authorized transitions instead of pretending no
transition happened. It admits a fallback completion only through a complete
`attempt_ledger` entry for that seat — an additive OPTIONAL field under this
profile, REQUIRED for any seat whose completion involved a route hop, and a
typed rejection naming the freeze under `omp-native-v1` and `omp-native-v2`.
Each entry carries `logical_lane_id` (`<run_id>/<role>/<instance>`), `role`,
`instance`, the ordered `attempts` (each with `attempt_id`,
`requested_route` as provider/model:effort, `observed_model`,
`observed_effort`, `native_agent_id`, `typed_failure`, and
`authorized_next_hop` as route + reason), `final_attempt_id`, and
`output_digest`; the ledger keeps no `input_snapshot_hash` or
`evidence_digests` of its own (the spec's two extra digest fields were
dropped when the entry landed): the v2 handoff's existing digests are reused,
so the ledger adds hops, never a parallel evidence channel. Resilient
admission requires: every attempt's `requested_route` is declared in the
seat's typed chain and hops strictly forward — the chain_index/next_route
machinery reused, no wrap and no skip backward; every hop's `typed_failure`
is a capacity class that permits advance, since a non-capacity transition is
inadmissible; `frozen_scope_hash` and `assignment_hash` are identical across
the lane's attempts and equal the seat's frozen assignment hash (I5/I6) — the
two renderings are deliberate, `frozen_scope_hash` being `sha256:`-prefixed
while `assignment_hash` stays the bare-hex handoff digest; the final
attempt binds the seat's completing agent and its output passes the SAME
evidence gates as a strict completion; and `observed_effort` equals the
requested route's declared effort suffix, a mismatch being the typed
`effort_unverifiable` rejection of the §6 effort rule (T07) — never silent
clamping credited as exact effort. An empty chain stays a hard pin, an
undeclared model stays inadmissible, and a completed seat carrying hop
evidence WITHOUT a ledger entry is rejected under this profile too.

Under BOTH strict and resilient, undeclared routes, non-capacity transitions,
and relabeled evidence are inadmissible: setting fallback flags false,
relabeling a fallback as the primary, and normalizing an observed route to
the requested route are never "fixes" (T05). The strict profile stays the
default; resilient activation for any mission class is an operator
re-charter, like any route-table change, and selects the profile with the
launcher's `--profile omp-native-v2|omp-native-resilient-v1` (default
`omp-native-v2`), whose choice is pinned into the launch manifest and flows
to the collector's emission. The profile choice never changes exit codes.

The resilient profile also admits a pre-spawn failure as typed unavailable
evidence (spec 11 §3): a frozen proposal seat whose batched task call was
rejected before spawn carries a `dispatch_attempts` entry — resilient-only,
a typed rejection under both strict profiles — recording
`logical_lane_id`, `attempt_id`, `requested_route`, `typed_failure`,
bounded sanitized `detail`, and the attempt interval, with NO native agent
id (T12). A frozen proposal seat is covered by an agent XOR a dispatch
attempt; its `lane_failure` telemetry binds `agent_id` null, the attempt's
requested route and interval, and the same correlation group the seat's
agent would carry. Under the strict profiles a pre-spawn failure keeps its
existing failed-seat admission semantics; critical seats never appear in
`dispatch_attempts` — a critical pre-spawn failure keeps its invalidation.

`effective_launch` (spec 12) is the per-seat launch attestation bound into
the handoff under v2 and resilient — an additive OPTIONAL field, a typed
rejection under v1. Each `effective-launch-v1` record carries the seat's
ids (`logical_lane_id`, `attempt_id`, `wave_token`), host attestation
(OMP path/version/sha256, launcher rev, tmux), the resolved role card
(source, path, sha256 recomputed over `contract_root/agents/<role>.md`),
requested route + resolved model + fallback chain + retry policy, tool/
spawn/behavior policy (advisor absent), overlay digests, cwd, and
credential-screened argv. The launcher captures records at dispatch and
re-resolves the policy immediately before the batched call — drift
between plan time and dispatch time halts pre-mutation naming the layer
(T14). The collector's behavior census (T15) requires every transcript
model/session event to be accounted for by the seat's declared attempts;
an unaccounted switch or extra session envelope is unauthorized evidence
and dies.

Native deadline admission is post-hoc. Any seat whose interval exceeds its
seat-class bound is `failed` + `lane_timeout` evidence — the deadline breach
is the terminal cause it names, regardless of whether the seat had completed
or already failed (`lane_failure` is for failures inside the bound), and the
seat's provider-failure detail remains in its transcript. The Rust judge
independently recomputes `elapsed` against the same config deadlines,
rejecting a mismatch in either direction — an over-deadline seat without
`lane_timeout`, or a `lane_timeout` without an over-deadline interval.
Dispatch is idempotent per
wave: the launcher writes `.ufo/dispatch/<runId>/pre-dispatch-r<NN>.json`
(O_EXCL, 0600, no-follow) holding the intended topology, per-seat assignment
hashes, and `wave_token` before the batched task call, whose `context` carries
a literal `wave_token: <token>` line. Two successful batched proposal-wave
calls for one wave, or a context token that disagrees with the snapshot, is a
typed `double_dispatch` rejection naming both transcripts; a token absent from
the evidence is the pre-P2 legacy path and draws no new rejection. A resumed
Main that finds a snapshot with no settled collection never re-fires the wave —
it pairs live Hub agents against the snapshot and continues to collection, and a
frozen seat with no live agent is a typed `missing_seats` rejection, never a
respawn (I6). The token never enters `NativeRoundHandoff` as a field of its
own; the profiles that carry it do so only inside the per-seat
`effective_launch.ids` record above. Re-running a
crashed run under the same `--run-id` always resumes the anchored wave and
never re-fires it; a fresh wave requires a fresh `--run-id`.

Task and Agent Hub records are transport evidence only. They cannot accept a
move. The Rust verdict includes the handoff digest so later edits invalidate
the decision. Fixture reports and native handoffs are different evidence kinds
and never impersonate one another.

Role assignments require the behavior in `agents/*.md`, not prefilled
improvement vectors. Mutation evidence includes a local defect, detector
output and exact restoration; executor evidence exercises a bounded real
change. Concurrent writes stay in separately owned scratch paths. Scores are
advisory and cite actual observations; unknown axes stay at baseline.
Transport conformance and repository improvement are separate claims.

OMP's native credential manager owns actual credential use. The hash-bound
launch manifest is the requested-route evidence. The hashed task transcript's
`model_change`, `session_init`, effort event, and served assistant messages are
the resolved-route evidence. No external credential or slot selector is part
of the native profile.

Sekhmet/L3 is shelved by operator doctrine. Its retained implementation and
stored capacity/chain are compatibility data, not active dispatch authority.
Do not launch sparks, replace missing OMP seats with L3 evidence, or make L3 a
prerequisite. Spark output never enters `NativeRoundHandoff` agents,
proposals, or telemetry.

### 4.3 Swarm wave dispatch

Fleet self-improvement missions dispatch L2 workers swarm-style under one
L1-owned scope. The shape is substrate-neutral semantics; the command
mapping is per-substrate plumbing (OMP batched `task` call, kimi
`AgentSwarm`, devin `run_subagent` batch). This section is L1 orchestration
doctrine. The swarm-wave planner `scripts/ufo-swarm-wave.mjs` validates a
wave spec and emits the single batched dispatch payload (OMP is the first
plumbing target); the `ufo-mission-result-v1` evidence envelope records
swarm-shaped results. The spec itself is declared by whichever source the
operator or L1 has in hand — a saved file (`--spec <wave.json>`), stdin
(`--spec -`), or an inline literal (`--spec-json <json>`); `plan` emits the
validated `ufo-swarm-wave-v1` plan, and `run` renders
`ufo-swarm-wave-dispatch-v1`, the dispatch-ready payload: one `task` call
(`taskCall`, `null` when the wave resumes only) plus one `hub send` per
`resumeSends` entry.

1. Explore the owned scope and partition it into concrete items before
   dispatch; workers never edit outside the L1 scope.
2. Emit one batched task call per wave, up to 128 lanes when warranted —
   the kimi `MAX_AGENT_SWARM_SUBAGENTS` parity cap on spawn items plus
   resumes, declared as `sighting.dispatch.swarm.maxLanes` and independent
   of the native profile `concurrencyCeiling` and the 1024 global
   runner ceiling. Expanded item prompts must be pairwise distinct — a
   duplicated expansion fails the wave before any lane spawns; never dedupe
   silently. A wave carries at least two lanes unless every lane in it is a
   resume.
3. Waves run sequentially within a round: wave N+1 launches only as wave N
   settles. A wave settles when every dispatched lane has reached a terminal
   typed state — `completed`, `failed`, `lane_timeout`, or `unavailable`; a
   lane with no terminal state blocks the next wave, and the per-seat-class
   deadline table guarantees every lane reaches one. A swarm wave may
   accompany an unjudged fleet mission as reconnaissance; on the judged OMP
   native path the collector admits
   exactly three Main task calls (planner, proposal wave, distiller), so no
   swarm wave may appear in a `NativeRoundHandoff` session. It never
   substitutes for a typed proposal seat.
4. Resume a failed lane on the same identity (I6); never mint a
   replacement. Per-item failure is typed lane telemetry.
5. Aggregate lane findings without flattening; each lane emits a scoped
   report artifact, and cross-scope findings hand to the L1 integrator (no
   dedicated wrap-up seat exists in `agents/` or the configured lanes).
6. Swarm output is advisory evidence, never a `Proposal`: it enters no
   judge admission path and manufactures no frontier movement. A swarm
   wave's exhaustion is lane telemetry, never `SATURATED` or
   `BUDGET_HALT` on its own — I8 applies to rounds, not lanes.
7. Never spawn another L1 (I1), change substrate, add L3, or touch
   credentials.

---

## 5. WWKD plan

```
fn wwkd_plan(state) -> Plan:
    1. data walk         — inspect cache, telemetry, and local diff first
    2. skeleton first    — establish one end-to-end shape before capacity
    3. overfit one case  — prove one concrete path, then generalize one axis
    4. cheapest local check — use pattern checks before expensive local work
    5. verification gate — every milestone names its observable check
    6. least disruption  — order moves so each remains runnable in isolation
```

The plan is written by the one L1. A planner card may provide advice on hosts
that support it, but it never becomes a second judge or runtime.

Every frozen axis names its measurement (`Axis.measurement`, frozen at
Phase 0 with the axis set): `executable` axes are measured by the runtime
— the check runs in a bounded scratch copy of the baseline tree and of
the candidate tree (the proposal's declared `candidate_writes`), never
the live tree, and the judge consumes the computed direction-aware delta;
seat scores on an executable axis are advisory context and never override
a computed regression. `subjective` axes admit a claimed improvement only
through the recorded symmetric argument (for and against sides citing
role-appropriate evidence); one-sided claims are clamped to baseline and
flagged. `evidence` axes are computed by the judge from typed handoff
evidence and exist only on the native path — the fixture loop cannot
produce them and the native path cannot execute subprocess checks, so
each side rejects the other's kind at admission. A check that fails to
run measures UNKNOWN: never regression cover, never a phantom gain, and
UNKNOWN on a material axis blocks admission as `INSUFFICIENT_EVIDENCE`.
An axis with no measurement declaration fails Phase 0: unmeasurable axes
are not axes (verification-gate stance applied to the axis set itself).
The verdict and round report carry the computed measurements and flags
as provenance.

---

## 6. Same-identity local reroute

Reroute is a runtime capability, not an operator paste and not a replacement
process presented as the original lane.

```
fn reroute_same_identity(state, lane, task, next, cause):
    // concrete gates: require_local_route admits only implemented local
    // routes; next must sit in the role's typed chain; per-record pins keep
    // runtime "crates/ufo-core-runtime" and the selected substrate
    assert next in lane.allowed_routes
    assert next.is_local && next.is_implemented
    assert state.runtime == "crates/ufo-core-runtime"
    assert state.substrate == selected_substrate

    before = {
        identity: lane.identity,
        cache: lane.cache,
        prompt: task,
    }
    output = lane.resume_same_lane(route = next)  // new attempt, same identity
    assert lane.identity == before.identity
    assert lane.cache == before.cache
    assert task == before.prompt

    from = lane.route
    lane.route = next
    lane.state = READY
    record(state.reroutes, RerouteRecord{
        round: state.round,
        reason: cause,   // lane identity is asserted at intake, not stored
        from,
        to: next,
    })
    return output
```

Current canonical routes are explicit local implementations:
`local/fixture-primary`, its in-invocation recovery route
`local/fixture-recovery`, optional local distillation `hvm/qwen-hvm`, and the
OMP-native evidence transport `omp/task`. The latter is admitted
only through `ufo judge-handoff`; Rust does not pretend it spawned OMP agents.
Any undeclared route fails closed.

Autonomous model routing (OMP native lanes): the operator never pinpoints a
model per dispatch. Each seat resolves its route through its declared tier
(`seatTiers` → `routeTiers` in `config/ufo.json`
`nativeProfiles.omp-native-v1`); the config is the sole statement of the
table — `modelRoutes`/`modelFallbacks` remain the consumed pins, projected
to OMP YAML and generated Rust role chains, and the sync gate's
`routes:equivalence` step halts on any divergence between the tier
resolution and the pins (I9). Chains advance only on typed capacity
failures (I6), honor the exact effort declared for each hop (the effort
rule below), and halt honestly on exhaustion without wrapping. Empty
fallback arrays are explicit. Repeated roles in one seat class resolve
identically. `retry.usageAwareFallback=false`; `fallbackRevertPolicy=never`.
Unknown provider usage is not healthy capacity. Proactive pinned fallback
would not satisfy exact-primary native handoff evidence. Re-chartering a
route = a tier-map edit + `routes:equivalence` + domain drills + operator
sign-off; it is never a live edit. The advisor stays DISABLED — absent
from `omp-native-v1`, not `enabled: false`; an advisor is never a seat or
judge. `kimi-code` routes are gated on `kimiOAuth.routedLanes`; the
moonshot API-key path stays disabled. The `devin-native-v1` profile uses
`devin/subagent` transport and is never admitted by `judge-handoff`. The
dormant L1 catalog and override live in `l1Context` as capability, never
available capacity; `deepseek-v4-pro` is a dormant catalog entry and is
never dispatched. L0 selection is independent of this table.

Failure domains (`failureDomains`, generated from the resolved chains as
`<tier>[<chainIndex>]`): `devin_oauth` down kills the orchestrator and
thinking seats outright and strands the mechanical and distiller chains at
their devin hops — judgment impossible. `alibaba_token_plan` down kills the
planner critical seat and every mechanical and distiller primary — the
round is invalid. Both are single-domain mission kills under the frozen
contract; naming them in the contract turns a surprise into a typed
outcome. `xai_oauth` and `openai_codex` are single-hop covers. Phase 0
probes fire per domain serving at least one critical seat
(`devin_oauth`, `alibaba_token_plan`): one bounded minimal completion whose
failure halts dispatch pre-spend, naming the domain and the killed seats;
a Devin OAuth probe proves reachability at probe time only and stays
operator-attested, never a quota guarantee. Seat attempts append to the
append-only `.ufo/routing-health.jsonl` lane-health ledger (read by
`ufo routing-health`, display-only) so re-charters move on ledger data,
not on vibes.

The effort rule: each hop honors the exact effort declared for that hop in
the typed chain. Role-level reasoning intent, requested effort, resolved
effort, and provider-observable execution settings are recorded separately.
An unsupported or unobservable setting is an explicit typed outcome
(`effort_unsupported` / `effort_unverifiable`), never assumed compliance and
never silent clamping credited as exact effort (T07).

---

## 7. Priority ramp

Priority changes ordering, never Pareto admission:

1. restore and prove the core runtime;
2. prove observable behavior and failure paths;
3. prove self-iteration and reroute;
4. prove exact contract portability;
5. exercise all seven local command surfaces.

A later concern may veto an earlier move. No weighted sum, confidence score,
or target metric may admit a regression.

---

## 8. Stop conditions

```
fn stop_condition(state, verdict):
    // an all-lane failure never reaches here: dispatch aborts the run
    // with a hard error (exit 1) before judgment
    if !sound_round:                    // unsound distill or bind failure
        return BLOCKED
    // cost brakes (spec 03): actual or projected budget exhaustion stops
    // the loop — recorded, never convergence, never completion (exit 2)
    if cost_ledger.mission_cumulative >= budgets.tokensPerMission
       || projected_wave_cost > remaining_mission_budget
       || mission_wall_clock >= budgets.wallClockMsPerMission:
        record(telemetry, budget_projection{...})
        return HONESTY_BRAKE
    if verdict.accepted.is_empty() && no pending_refinement:
        if round_is_clean:      // the round digest's lane_health block:
                                // zero capacity, zero lane_timeout, zero
                                // quality_degraded, zero unavailable
            return SATURATED
        record(telemetry, saturation_inconclusive{lane_health})
        return CONTINUE         // a degraded zero-accept round is not a
                                // plateau (spec 07 §5)
    if configured_round_budget_exhausted:
        return BUDGET_HALT
    return CONTINUE
```

`SATURATED` describes the search, not the task. Terminal outcomes carry
`round_validity` (sound | unsound), `loop_stop` (`saturated` | `budget_halt`
| `blocked` | `interrupted` | `honesty_brake` | `authority_boundary`), and
`mission_goal` (`satisfied` | `incomplete` | `unverified`) independently. A
sound, saturated mission with unmet acceptance criteria reports
`saturated + incomplete` and is not task completion; unmeasurable criteria
report `unverified`. Neither field ever upgrades the other, and only
`loop_stop` drives the exit code — the triple is reported in the verdict
output and the mission envelope, never folded into exit status.

`mission_goal` derives ONLY from the round plan's `acceptance_criteria`
(`ufo-round-plan-v1`, spec 07 A-07). Empty or absent criteria, or any
non-empty string criterion (unmeasurable by construction), report
`unverified`. Mechanical criteria of the form
`{kind: "axis_threshold", axis, op: ">=" | "<=" | ">" | "<" | "==", value}`
are evaluated against the final round scores: every such criterion met →
`satisfied`; any measured unmet → `incomplete`. Full measurement states
(OBSERVED / UNKNOWN / CONTRADICTED / NOT_APPLICABLE) and their axis contracts
are landed (spec 05, P5); a criterion is either mechanical or unverifiable,
and no placeholder ever counts as met.

`BUDGET_HALT` and `BLOCKED` are not convergence.
`CONTINUE` is loop control; it persists only as the non-terminal `running`
checkpoint marker and is never a terminal stop value (§1).


If any accepted proposal touches `membrane.paths` (config-declared senses:
runtime, CLI, collector, sync gate, launcher, sighting, routing/budget
config, contract docs, authored directive), the verdict emits
`authority_boundary` and the loop seals until the operator signs
(`ufo charter sign <runId>`, operator-interactive only) and a full Phase 0
re-passes. The accepted work still lands locally; the next round never
dispatches under a seal. The system may edit its own body under judgment;
edits to its own senses are operator-owned, like publishing (I10).

Fleet `iterate` chains are scheduling continuity, not additional judges.
Only validated result receipts may release successors, which retain the
frozen prompt, routes, scope, axes and prior-round evidence. A bound converged
outcome stops the chain. Reaching the declared round count is a budget halt,
not convergence; never automatically re-arm a genuinely converged charter.
Missing receipts, drift or rejected evidence remain recorded blockers.

---

## 9. Cross-substrate contract sync

There is one implementation, not seven adapted loops.

```
fn sync_contracts(canonical):
    parallel_for mirror in declared_skill_mirrors:
        require(mirror.skill_tree == canonical.skill_tree)
    parallel_for mirror in declared_agent_mirrors:
        require(mirror.agent_cards == canonical.agent_cards)
    parallel_for target in [omp, kimi, codex, cursor, opencode, grok, devin]:
        require(target.wrapper.delegates_to == "ufo-cli")
        require(target.wrapper.passes_substrate == target.name)
    require(no_missing_drifted_or_extra_mirror_files)
    return ContractSyncReport
```

`scripts/sync-ufo-contracts.mjs` is the mechanical authority for the declared
skill and agent mirror targets; `--check` rejects missing, drifted, or extra
files under every declared target.
`--check` also gates the `.omp/config.yml` projection, charterlist scope
tags, the bundled runtime config, and the godspeed directive mirrors — its
authority exceeds skill and agent mirrors alone.

Contract sync proves shape parity. It does not prove an authenticated host CLI
ran. Behavioral evidence comes from invoking each target's local `self-iter`
command separately.

---

## 10. Local ship

```
fn ship_local():   // the aggregate gates flow, not `ufo local-ship`
    require(sync_contracts().ok)
    require(build_canonical_runtime())
    parallel_for target in supported_substrates:
        report = invoke_local_self_iter_surface(target)
        require(report.runtime == "crates/ufo-core-runtime")
        require(report.substrate == target)
        require(report.operatorGuidanceThemes == exact_three_themes)
    emit_local_artifacts()
```

No runtime path commits, pushes, publishes, deploys, or infers credentials.

Local ship is transactional: the admitted candidate applies against its
pinned baseline snapshot (the hash the judge admitted — an admitted
candidate applied to a different tree is a mismatch, not a ship) under a
mission-scoped writer lease with fencing epochs (`.ufo/writer-lease.json`;
a stale-epoch write is rejected, and of two supervisors advancing one
mission exactly one lease wins), through a crash-recoverable ownership
journal (`.ufo/apply-journal/`): per-operation records with before/
candidate digests and the preimage bytes; recovery rolls back ONLY owned
pending operations, and a file whose bytes match neither digest is a
pre-existing user edit — it is never a rollback casualty. Raw transcripts
are preserved beside normalized evidence with a canonicalizer version and
raw/derived digests plus a redaction map (`evidence_originals`); no hash
of a derived copy stands in for its original, and tampering with either
layer is independently detectable. Self-modification is promotion: the
running contract validates a candidate contract for a successor boundary
(the §8 membrane sign-off is the promotion permission); the candidate
never edits the live gates and never approves itself.

---

## 11. Definition of done

The map holds when a local command reaches a verified result through one
runtime and one judge; Phase 0 rejects drift; a route failure reroutes the same
logical lane and cache without a replacement identity; every substrate surface
preserves the three themes; budget and blocked outcomes remain non-success;
and the loop can stop itself at honest saturation.

For OMP native execution, done additionally requires the exact native
depth-0/1/2 topology (Main, depth-1 planner/proposal/distiller seats, and the
executor-owned depth-2 labrat), full-prompt integrity, concurrent-wave timing,
per-tier artifact and model provenance, and a digest-bound Rust
`judge-handoff` verdict. A fixture run is never substituted for that proof.

Self-driving is demonstrated by two contiguous native rounds on one bounded
task. Round 1: WWKD plan → native dispatch → evidence → an accepted change.
Round 2: a NEW WWKD plan that reads the changed baseline, prior rejects, and
prior failures → new native dispatch → a verdict linked to round 1's. Both
rounds carry genuine native traces with distinct real transcript ids; the
successor is bound to its predecessor's contract, accepted artifacts, axes,
unfinished work, and relevant lane history. A fixture, a merely scheduled
fleet successor, or a re-run of round 1's plan is never a substitute (T02).

The receipt is `.ufo/receipts/<runId>/round-chain.json` — per round an entry
`{round, plan_digest, handoff_digest, verdict_digest, baseline_before,
baseline_after, predecessor}` where `predecessor` is the prior round's entry.
The scaffolding and its digest fields land with PC-A; the two-round proof
itself is the pack's capstone gate (P9).

Runtime identity is fixed. Host command shape is adaptable.
