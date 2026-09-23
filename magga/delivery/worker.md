# Release delivery

Release ID: `{{release_id}}`
Publication address: `https://ds4cc.com/magga/{{release_id}}/`

When the games are finished, submit the release to the local publishing queue
at `delivery/{{release_id}}/` inside this working copy. The publishing team
handles the website account and deployment. Do not push the checkpoint repository.

Prepare this folder:

```text
delivery/{{release_id}}/
  site/              # Complete playable release; index.html is its entry point
  previews/          # Three screenshots captured from your actual games
  records/           # Game records and reproducible verification evidence
  submission.json
  READY
```

Copy only the files needed to play into `site/`. Keep development dependencies,
credentials, operator tooling and superseded renditions out of it. Everything
must work from local files or a trivial static server, including when served
under `/magga/{{release_id}}/`. Check that path locally. The publishing team
will integrate the collection listing; you do not need to open the hosting
site or inspect other releases.

In `submission.json`, record the release ID, publication address, entry path,
game names and their relative links, preview paths, and a SHA-256 inventory
of every file in `site/` and `previews/` with its relative path and byte count.
Include the exact verification commands, their observed results, and any
remaining limitations. Use your existing game records rather than inventing
a second account of what was tested.

Check the copied release itself. Write `READY` last, only when all files and
records are complete, then leave this submission unchanged. Finish by reporting
the absolute submission-folder path and any unresolved issues. That completes
the local handoff; the publishing team will report the live URL after deployment.

If the work is unfinished, report what exists and what is missing. Do not mark
it ready or claim it is live.
