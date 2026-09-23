# ds4cc-MAGGA v2

**EVERYTHING IS PC x Make Love Not Warcraft** · DLC brief, revision 1

A quality, creative, multimodal benchmark you can actually interact with.
The arcade is the deliverable. Play it, hear it, find its failures, inspect
how it was made, and feel the difference between renditions.

V1 asks how well a model can finish six classic games from a shared checkpoint.
This DLC asks how well it can create a connected original world across animated
comedy, fantasy adventure and a collectible-card game. V1's six-game challenge
and historical prompt remain intact. A v2 run ships these three new experiences;
it is not required to remake the six again. The DLC expands the MAGGA collection.

## The creative brief

An original cast has ordinary lives, oversized fantasy alter egos, and a card
game that turns their exploits into local mythology. The same character should
be recognizable as an animated townsperson, an adventurer and a card illustration.
Choices and events travel between those forms. Each experience also works when
someone launches it directly from the arcade.

South Park supplies the reference for expressive cutout staging, comic timing
and the collision of mundane life with absurd stakes. Vanilla World of Warcraft
supplies the sense of place, class identity, dangerous travel, equipment and
adventure. Hearthstone supplies the tactile card table, legible interactions,
deckbuilding and audiovisual pleasure of playing a card. These are references
for craft, not a request for their characters, assets or entire content catalogs.

Let the creator decide what “PC” means in its world, what it finds funny, and
how the story unfolds. The title does not prescribe a political position, plot,
renderer or house style. The original cast and the actual play must carry it.

## A complete release

These are authored-content floors for this revision, not measures of quality.
Duplicated encounters, renamed cards and repeated dialogue do not satisfy them.
The [builder prompt](one-shot-prompt.md) contains the same requirements.

| Experience | Required scope |
|---|---|
| Animated town comedy | One complete playable episode; at least 4 recurring characters, 3 locations and 6 staged scenes; at least 2 choices with later consequences; an ending. |
| Fantasy adventure | At least 3 distinct playable class builds, 3 explorable regions, 6 authored quests and a dungeon with 3 distinct boss encounters; character progression, equipment, defeat/recovery and a campaign ending. |
| Collectible-card game | At least 60 mechanically distinct cards, 3 leaders with different play styles, a collection and deck editor, 3 viable deck strategies and 6 distinct AI opponents culminating in a finale; tutorial, rematches and saved progression. |

One shared world, three substantial experiences. At least one persistent
consequence must travel from each experience to another. Direct entry provides
a coherent starting state without making people complete another game first.
All three need authored animation, music, sound, usable controls, persistence,
clear rules, fair difficulty and complete start-to-finish flows. The release
runs locally and under a nested website path without player installation,
external services or network access after obtaining its files.

## Production freedom

“Use the same engine” is a production reference, not a stack restriction.
Maya is an animation and asset-authoring toolset. South Park's official account
describes filming WoW gameplay with Blizzard and bringing material into Maya.
Unity's Hearthstone case study describes a Unity game, Maya in the art workflow,
and WoW as a custom-engine game. There is no shared engine to mandate.
[Autodesk](https://www.autodesk.com/products/maya/overview),
[South Park Studios](https://southpark.cc.com/news/y2dhvu/fan-question-is-it-true-blizzard-entertainment-helped-with-the-warcraft-episode),
[Unity, pages 12–13 and 26](https://unity3d.com/files/solutions/unityformobile/A_Guide_To_Moving_From_Internal_Game_Engine_Technology.pdf).

Let each model use its native substrate and obtain the tools, libraries,
renderers, art and audio workflows that serve the result. No ceiling on creative
ambition; record the time, cost, limits, assistance and tools actually used.
Different available resources remain visible in comparisons.

## Run it without exposing the comparison

Use the same pinned source as v1: checkpoint commit
`322a5e4e6f7ea39bfc6469e2c8cc4544e3926163`, tree
`5740c5f0f627436435a26dc989da115bac94a268`. Export only `prototypes/`,
`hardest/`, `MAGA-everything/` and `verification/`, without Git history or operator
files. Its existing game code is reusable foundation; it contains no promised
DLC implementation. Do not supply a previous model's finished rendition or the
operator-side `tcg/` work. Give every matched run the same exported bytes.

Supply only that workspace, the exact selected v2
[one-shot prompt](one-shot-prompt.md), and the normal
[release-delivery note](../delivery/worker.md) with a neutral release ID.
Keep this document, comparisons, other renditions and website access outside
the builder's environment. The [delivery procedure](../delivery/README.md)
still applies: local handoff first, separate publication after the builder ends.

Record the benchmark revision, exact prompt and delivery-note hashes, source
inventory, model/substrate versions, effective configuration, actual helper
models, human interventions, resource usage and final artifact hashes privately.
Pair future stylized prompts with this definition explicitly; do not rewrite
the v1 prompt. Change and version the brief when changing the required scope.

## Receipts people can use

Publish the playable artifacts with their exact prompts, source, production
notes, real-input verification and known limitations. Keep secrets and private
operator material out of those public receipts. Preserve the submitted bytes;
collection styling belongs outside a rendition.

Assess each experience and the connections between them through actual play
and listening: character and comic timing, world and combat feel, card clarity
and strategic variety, art direction, sound, completeness, usability and
stability. Tests support these judgments. A screenshot or passing test suite
cannot establish that the games are fun, balanced or finished.

Keep partial results visible. A strong card game beside two unfinished shells
is a partial release. V1 and v2 are different tasks; show their versions rather
than treating their results as a single controlled ranking. New renditions and
observed failures inform the next revision of the benchmark.

This is the v2 brief and its launch prompt, not a claim that a v2 rendition has
already been built, validated or published.
