# Publish the arcade release

Publish the completed local submission at `{{submission_dir}}` as
`https://ds4cc.com/magga/{{release_id}}/`.

You are authorized to publish this release to the website repository
`VeigaPunk/ds4cc-marketplace`. Never push or modify the checkpoint repository
`VeigaPunk/MAKEARMORGAMESGREATAGAIN`.

1. Confirm the builder has ended and the submission has a `READY` marker.
   Validate `submission.json`: safe relative paths, no symlinks or paths escaping
   the submission, an existing `site/index.html`, all declared game links and
   previews, and exact file sizes and SHA-256 hashes. Check that the inventory
   lists every site and preview file exactly once. If incomplete or inconsistent,
   return the specific issue without publishing it as a finished release.
2. Work from the current website branch in an isolated clean checkout. Preserve
   other people's uncommitted work and concurrent commits. Reserve a new path
   `magga/{{release_id}}/`; do not overwrite an existing release. If the exact
   same submission was already published, verify it and report that result.
3. Copy `site/` into that path without changing its bytes. Place the supplied
   previews under `magga/assets/{{release_id}}/`. Keep game records and private
   evidence with the operator, outside the public website payload. Retain the
   release's file inventory in its own `release.json`; require that filename to
   be unused by the submitted site before adding it.
4. Add one collection card in `magga/index.html`, using the provided release
   title and real-game previews. Match the existing collection styling and
   update its edition count. Give the `[oneshotprompt(magga)]` label its own
   hyperlink to `{{prompt_raw_url}}`; do not nest links. Any model/substrate
   credit comes from the operator's supplied publication metadata. Do not
   rewrite the submitted games, launcher, art or styling.
5. Verify the integrated site locally: collection link, every submitted game, relative
   assets, desktop/mobile layout, browser errors and the frozen file hashes.
   If hosting requires changes inside the release, return the issue for a new
   submission instead of silently modifying it during publication.
6. Commit only this release and its catalog integration. Fetch and reconcile
   concurrent website changes, then push normally to `ds4cc-marketplace` main;
   never force-push. Wait for the existing Pages workflow to succeed for a
   commit containing the release.
7. Check the public collection and release URL, follow each game link, check
   the prompt hyperlink, and compare the served files with the submission
   hashes. Save the website commit, workflow URL, verification results and live
   address in an operator-side deployment receipt.

Report the actual state: received, pushed, or deployed and verified. A local
folder, Git commit, or successful push alone is not a verified deployment.
If publication credentials or deployment are unavailable, preserve the package
and report the exact blocker; do not create accounts or claim success.
