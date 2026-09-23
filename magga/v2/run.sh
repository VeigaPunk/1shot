#!/usr/bin/env bash
# MAGGA v2 — one command per benchmark run.
#
#   run.sh <cli> [vanilla|godspeed|ufo] [options]      start a run
#       vanilla: the prompt alone. godspeed / ufo: that skill package (a pinned tarball) installed
#       in every native skill location, and `/godspeed` or `/ufo` appended to the prompt.
#   run.sh creds [cli ...]                              export your logins once (writes magga-creds.b64)
#   run.sh setup [vanilla|godspeed|ufo]                 prepare an app's cloud environment in place;
#                                                       prints the message to send its agent
#
# From anywhere (local or a cloud shell):
#   curl -fsSL https://raw.githubusercontent.com/VeigaPunk/1shot/main/magga/v2/run.sh | bash -s -- codex ufo
#
# <cli>: codex | claude | gemini | opencode | qwen | kimi | omp | cursor | grok | devin | shell
#
# The script works out its own environment:
#   Docker reachable → a fresh --privileged container per run (passwordless sudo, empty /work)
#   no Docker        → a fresh directory with an isolated $HOME (cloud shells, CI, VMs)
# Every run gets: an empty work dir; Node 24 via fnm; uv, IPython and Harbor; agent-browser with its
# browser; the latest CLI; only that CLI's login; the pinned prompt checked by SHA-256; every
# permission prompt bypassed. Afterwards it checks the lock and the envelope, and writes a run record.
#
# Logins, in priority order:
#   --creds FILE or $MAGGA_CREDS (the base64 bundle from `run.sh creds`)
#   this machine's own logins (read from $HOME when you run locally)
#   the CLI's sign-in flow inside the run (or --login to force it)
#
# Options: --docker | --bare   --login   --dry (set up, check the bypass flag, don't start)
#          --rebuild (rebuild the image)   MAGGA_RUNS=<dir> (default ./magga-v2-runs)
set -euo pipefail

PROMPT_URL=https://raw.githubusercontent.com/VeigaPunk/1shot/2309d8dfb6be965579beb34232095ffe4af6a695/magga/v2/one-shot-prompt.md
PROMPT_SHA=dbd8523fa3f3f453f779e1bc87952492691555b219e1b413bb4252c3ff1839c7
VARIANTS_BASE=https://raw.githubusercontent.com/VeigaPunk/1shot/6011cd7918d4d0f937c0011791b67120a04581ef/magga/v2/variants
VARIANT_SHA_godspeed=b9e89b9f8f0cb8bc9f89ecd5918e450839c891970a28ad88adfcac660613ec76
VARIANT_SHA_ufo=a4e1513c64715d46d61a8e4b8a3ffff827814f187d86aa587f6ab6e7eb8687a7
IMAGE=magga-v2-env:3
CLIS="codex claude gemini opencode qwen kimi omp cursor grok devin"
PASS_ENV=(OPENAI_API_KEY ANTHROPIC_API_KEY CLAUDE_CODE_OAUTH_TOKEN GEMINI_API_KEY GOOGLE_API_KEY
  XAI_API_KEY GROK_DEPLOYMENT_KEY CURSOR_API_KEY MOONSHOT_API_KEY KIMI_API_KEY DASHSCOPE_API_KEY
  OPENROUTER_API_KEY DEEPSEEK_API_KEY ZAI_API_KEY DEVIN_API_KEY GH_TOKEN GITHUB_TOKEN MAGGA_MODEL
  GEMINI_CLI_TRUST_WORKSPACE)

# ------------------------------------------------------------------ per-CLI tables
cli_install() { case $1 in
  setup)    : ;;
  codex)    npm i -g @openai/codex ;;
  claude)   curl -fsSL https://claude.ai/install.sh | bash ;;
  gemini)   npm i -g @google/gemini-cli ;;
  opencode) npm i -g opencode-ai ;;
  qwen)     npm i -g @qwen-code/qwen-code ;;
  kimi)     curl -fsSL https://code.kimi.com/install.sh | bash ;;
  omp)      curl -fsSL https://omp.sh/install | sh ;;
  cursor)   curl -fsSL https://cursor.com/install | bash ;;
  grok)     curl -fsSL https://x.ai/cli/install.sh | bash ;;
  devin)    curl -fsSL https://cli.devin.ai/install.sh | bash ;;
  shell)    : ;;
esac; }
cli_bin() { case $1 in cursor) echo cursor-agent ;; *) echo "$1" ;; esac; }
# Launch argv; the message is the last argument. Every permission prompt is bypassed.
cli_launch() { local p=$2; case $1 in
  codex)    LAUNCH=(codex --dangerously-bypass-approvals-and-sandbox "$p") ;;
  claude)   LAUNCH=(claude --dangerously-skip-permissions "$p") ;;
  gemini)   LAUNCH=(gemini --yolo --prompt-interactive "$p") ;;
  opencode) LAUNCH=(opencode --auto --prompt "$p") ;;
  qwen)     LAUNCH=(qwen --yolo --prompt-interactive "$p") ;;
  kimi)     LAUNCH=(kimi --prompt "$p") ;;      # no interactive prefill; Never Ask comes from config
  omp)      LAUNCH=(omp --auto-approve "$p") ;;
  cursor)   LAUNCH=(cursor-agent --yolo --trust --approve-mcps --sandbox disabled "$p") ;;
  grok)     LAUNCH=(grok --always-approve "$p") ;;
  devin)    LAUNCH=(devin --permission-mode dangerous --respect-workspace-trust false -- "$p") ;;
  shell)    LAUNCH=(bash -l) ;;
esac; }
cli_bypass_flag() { case $1 in
  codex) echo dangerously-bypass-approvals-and-sandbox ;; claude) echo dangerously-skip-permissions ;;
  gemini|qwen) echo yolo ;; opencode) echo auto ;; omp) echo auto-approve ;; cursor) echo yolo ;;
  grok) echo always-approve ;; devin) echo permission-mode ;; *) echo "" ;;
esac; }
# Login files, relative to $HOME. Configs, memories and sessions are never exported.
cli_auth() { case $1 in
  codex) echo .codex/auth.json ;; claude) echo .claude/.credentials.json ;;
  gemini) echo .gemini/oauth_creds.json .gemini/google_accounts.json .gemini/settings.json ;;
  opencode) echo .local/share/opencode/auth.json ;; qwen) echo .qwen/oauth_creds.json ;;
  kimi) echo .kimi-code/credentials ;; cursor) echo .config/cursor/auth.json ;;
  grok) echo .grok/auth.json ;; devin) echo .local/share/devin/credentials.toml .config/devin/config.json ;;
  *) echo "" ;;
esac; }
cli_login() { case $1 in
  codex)    if [ -n "${OPENAI_API_KEY:-}" ]; then printenv OPENAI_API_KEY | codex login --with-api-key; else codex login --device-auth; fi ;;
  kimi)     kimi login ;;
  cursor)   [ -n "${CURSOR_API_KEY:-}" ] || NO_OPEN_BROWSER=1 cursor-agent login ;;
  grok)     [ -n "${GROK_DEPLOYMENT_KEY:-}${XAI_API_KEY:-}" ] || grok login --device-auth ;;
  devin)    devin auth login ;;
  opencode) opencode auth login ;;
  *)        : ;;   # claude, gemini, qwen and omp sign in on their own first screen
esac; }
# Native skill locations, so each CLI discovers the variant's skills on its own.
SKILL_DIRS=".agents/skills .claude/skills .omp/agent/skills .grok/skills .kimi-code/skills .config/opencode/skill .config/opencode/skills .cursor/skills .gemini/skills .qwen/skills .config/devin/skills"

# ------------------------------------------------------------------ credential bundle (host side)
# bundle_add <dir> <cli>: copy one CLI's login into <dir>/<cli>/, deriving trimmed files where needed.
bundle_add() {
  local out=$1 cli=$2 f n=0
  mkdir -p "$out/$cli"
  for f in $(cli_auth "$cli"); do
    [ -e "$HOME/$f" ] || continue
    mkdir -p "$out/$cli/$(dirname "$f")"; cp -a "$HOME/$f" "$out/$cli/$f"; n=$((n+1))
  done
  if [ "$cli" = omp ] && [ -f "$HOME/.omp/agent/agent.db" ] && command -v sqlite3 >/dev/null; then
    # Credential tables only: no history, cache, routing config or memory.
    mkdir -p "$out/omp/.omp/agent"; local db="$out/omp/.omp/agent/agent.db"
    sqlite3 "$HOME/.omp/agent/agent.db" .schema | grep -v sqlite_sequence | sqlite3 "$db"
    sqlite3 "$db" "ATTACH '$HOME/.omp/agent/agent.db' AS s;
      INSERT INTO auth_credentials SELECT * FROM s.auth_credentials;
      INSERT INTO auth_credential_blocks SELECT * FROM s.auth_credential_blocks;
      INSERT INTO auth_schema_version SELECT * FROM s.auth_schema_version;
      INSERT INTO schema_version SELECT * FROM s.schema_version;
      INSERT INTO meta SELECT * FROM s.meta;
      INSERT OR REPLACE INTO auth_change_revision SELECT * FROM s.auth_change_revision;
      DETACH s; VACUUM;" && n=$((n+1))
  fi
  if [ "$cli" = kimi ] && [ -f "$HOME/.kimi-code/config.toml" ] && command -v python3 >/dev/null; then
    # Managed-login provider and its models only; permission mode set to Never Ask.
    python3 - "$HOME/.kimi-code/config.toml" "$out/kimi/.kimi-code/config.toml" <<'PY' && n=$((n+1))
import sys, tomllib
c = tomllib.load(open(sys.argv[1], 'rb'))
def v(x):
    if isinstance(x, bool): return 'true' if x else 'false'
    if isinstance(x, (int, float)): return str(x)
    if isinstance(x, list): return '[' + ', '.join(v(i) for i in x) + ']'
    return '"' + str(x).replace('\\', '\\\\').replace('"', '\\"') + '"'
out = []
if c.get('default_model'): out.append(f"default_model = {v(c['default_model'])}")
out.append('default_permission_mode = "auto"')
def table(name, d):
    out.append(f'\n[{name}]'); out.extend(f'{k} = {v(x)}' for k, x in d.items() if not isinstance(x, dict))
    for k, x in d.items():
        if isinstance(x, dict): table(f'{name}.{k}', x)
for k, x in c.get('providers', {}).items():
    if k.startswith('managed:'): table(f'providers."{k}"', x)
for k, x in c.get('models', {}).items():
    if str(x.get('provider', '')).startswith('managed:'): table(f'models."{k}"', x)
open(sys.argv[2], 'w').write('\n'.join(out) + '\n')
PY
  fi
  [ $n -gt 0 ] || rmdir "$out/$cli" 2>/dev/null || true
}
bundle_env() {
  local k; : >"$1/env"
  for k in "${PASS_ENV[@]}"; do [ -n "${!k:-}" ] && printf '%s=%s\n' "$k" "${!k}" >>"$1/env"; done
  return 0
}

# ------------------------------------------------------------------ inside the run
# Runs as the agent user with HOME = fresh home and WORK = empty work dir. Serialized into the container.
inner_stage() {
  set -euo pipefail
  local cli=$1 variant=$2 dry=$3 login=$4 meta="$HOME/.magga-run"
  mkdir -p "$meta" "$HOME/.local/bin" "$HOME/.npm-global"
  export PATH="$HOME/.local/share/fnm:$HOME/.local/bin:$HOME/.npm-global/bin:$HOME/.kimi-code/bin:$HOME/.grok/bin:$HOME/.opencode/bin:$PATH"
  export NPM_CONFIG_PREFIX="$HOME/.npm-global" IS_SANDBOX=1 DISABLE_AUTOUPDATER=1
  cd "$WORK"
  [ "$cli" = setup ] || [ -z "$(ls -A "$WORK")" ] || { echo "work dir is not empty: $WORK" >&2; return 1; }
  command -v git >/dev/null || { echo "git is required" >&2; return 1; }

  # Node via fnm; `fnm env` gives every shell its own multishell Node path.
  if ! command -v fnm >/dev/null; then
    echo "» installing fnm"
    curl -fsSL https://fnm.vercel.app/install | bash -s -- --install-dir "$HOME/.local/share/fnm" --skip-shell >"$meta/fnm.log" 2>&1 \
      || { tail -20 "$meta/fnm.log"; return 1; }
  fi
  eval "$(fnm env --use-on-cd --shell bash)"
  fnm install 24 >/dev/null 2>&1 && fnm default 24 && fnm use 24 >/dev/null
  cat >"$HOME/.magga-env.sh" <<'RC'
export PATH="$HOME/.local/share/fnm:$HOME/.local/bin:$HOME/.npm-global/bin:$HOME/.kimi-code/bin:$HOME/.grok/bin:$HOME/.opencode/bin:$PATH"
export NPM_CONFIG_PREFIX="$HOME/.npm-global"
command -v fnm >/dev/null && eval "$(fnm env --shell bash)"
export PATH="$HOME/.npm-global/bin:$HOME/.local/bin:$PATH"
RC
  local rc; for rc in .bashrc .profile; do
    touch "$HOME/$rc"
    grep -q magga-env "$HOME/$rc" || { printf '[ -f "$HOME/.magga-env.sh" ] && . "$HOME/.magga-env.sh"\n' | cat - "$HOME/$rc" >"$HOME/$rc.new"; mv "$HOME/$rc.new" "$HOME/$rc"; }
  done
  export BASH_ENV="$HOME/.magga-env.sh" ENV="$HOME/.magga-env.sh"

  echo "» installing uv, IPython, Harbor"
  { command -v uv >/dev/null || curl -LsSf https://astral.sh/uv/install.sh | env UV_NO_MODIFY_PATH=1 sh; } >"$meta/uv.log" 2>&1
  { uv tool install ipython && uv tool install harbor; } >>"$meta/uv.log" 2>&1 || echo "WARNING: uv tools incomplete (meta/uv.log)" >&2
  echo "» installing agent-browser"
  { npm i -g agent-browser && { agent-browser install --with-deps || agent-browser install; }; } >"$meta/agent-browser.log" 2>&1 \
    || echo "WARNING: agent-browser incomplete (meta/agent-browser.log)" >&2
  [ "$cli" = setup ] || echo "» installing $cli (latest)"
  cli_install "$cli" >"$meta/install.log" 2>&1 || { tail -20 "$meta/install.log"; return 1; }
  hash -r
  local bin; bin=$(cli_bin "$cli")
  case $cli in shell|setup) ;; *) false ;; esac || command -v "$bin" >/dev/null || { echo "$bin not on PATH after install" >&2; tail -20 "$meta/install.log"; return 1; }
  { case $cli in shell|setup) ;; *) "$bin" --version 2>&1 | head -1 ;; esac; } >"$meta/cli-version.txt" || true
  { node -v; uv --version; ipython --version; harbor --version; agent-browser --version; } >"$meta/tool-versions.txt" 2>&1 || true

  curl -fsSL "$PROMPT_URL" -o "$meta/prompt.md"
  echo "$PROMPT_SHA  $meta/prompt.md" | sha256sum -c --quiet - || { echo "prompt checksum mismatch" >&2; return 1; }
  local message; message=$(cat "$meta/prompt.md")

  # Variant: one pinned tarball of skill packages, installed in every native skill location.
  if [ "$variant" != vanilla ]; then
    local tgz="$meta/magga-v2-$variant.tar.gz" want d s
    want=$(eval echo "\$VARIANT_SHA_$variant")
    curl -fsSL "$VARIANTS_BASE/magga-v2-$variant.tar.gz" -o "$tgz"
    echo "$want  $tgz" | sha256sum -c --quiet - || { echo "variant tarball checksum mismatch" >&2; return 1; }
    mkdir -p "$meta/skills" && tar -xzf "$tgz" -C "$meta/skills"
    for d in $SKILL_DIRS; do mkdir -p "$HOME/$d"; for s in "$meta/skills"/*/; do cp -r "$s" "$HOME/$d/"; done; done
  fi
  [ "$variant" = vanilla ] || message="$message"$'\n\n'"/$variant"
  (cd "$meta" && { [ -d skills ] && find skills -type f -exec sha256sum {} + | sort -k2; true; }) >"$meta/skills.sha256"
  printf '%s' "$message" | sha256sum | cut -d' ' -f1 >"$meta/message.sha256"
  if [ "$cli" = setup ]; then
    printf '%s\n' "$message" >"$meta/MESSAGE.md"
    return 0
  fi

  # Bypass permissions in native settings too, not only flags.
  case $cli in
    codex)  mkdir -p "$HOME/.codex"; printf 'approval_policy = "never"\nsandbox_mode = "danger-full-access"\n' >>"$HOME/.codex/config.toml" ;;
    claude) mkdir -p "$HOME/.claude"; printf '{"permissions":{"defaultMode":"bypassPermissions"},"skipDangerousModePermissionPrompt":true}\n' >"$HOME/.claude/settings.json" ;;
    gemini|qwen) mkdir -p "$HOME/.$cli"
      if [ "$cli" = gemini ] && command -v node >/dev/null; then
        # Model + max thinking: MAGGA_MODEL overrides the default gemini-3.1-pro.
        node -e 'const fs=require("fs"),p=process.env.HOME+"/.gemini/settings.json";
          let s={}; try{s=JSON.parse(fs.readFileSync(p,"utf8"))}catch(e){}
          s.tools={...(s.tools||{})}; delete s.tools.approvalMode;
          const m=process.env.MAGGA_MODEL||"gemini-3.1-pro";
          s.model={...(s.model||{}),name:m};
          s.modelConfigs={...(s.modelConfigs||{}),customAliases:{...((s.modelConfigs||{}).customAliases||{}),
            [m]:{modelConfig:{model:m,generateContentConfig:{thinkingConfig:{thinkingLevel:"HIGH"}}}}}};
          if(!process.env.GEMINI_API_KEY&&!process.env.GOOGLE_API_KEY&&fs.existsSync(process.env.HOME+"/.gemini/oauth_creds.json"))
            s.security={...(s.security||{}),auth:{selectedType:"oauth-personal"}};
          fs.writeFileSync(p,JSON.stringify(s,null,2))'
      else
        [ -f "$HOME/.$cli/settings.json" ] || printf '{"tools":{"approvalMode":"yolo"}}\n' >"$HOME/.$cli/settings.json"
      fi ;;
  esac

  local have_auth=0 k f
  for f in $(cli_auth "$cli"); do [ -e "$HOME/$f" ] && have_auth=1; done
  [ "$cli" = omp ] && [ -f "$HOME/.omp/agent/agent.db" ] && have_auth=1
  for k in "${PASS_ENV[@]}"; do [ -n "${!k:-}" ] && have_auth=1; done
  if [ "$cli" != shell ] && { [ "$login" = 1 ] || [ $have_auth = 0 ]; }; then echo "» signing in to $cli"; cli_login "$cli"; fi
  if [ "$cli" = kimi ]; then
    touch "$HOME/.kimi-code/config.toml"
    grep -q '^default_permission_mode' "$HOME/.kimi-code/config.toml" \
      || { printf 'default_permission_mode = "auto"\n' | cat - "$HOME/.kimi-code/config.toml" >"$HOME/.kimi-code/c.new"; mv "$HOME/.kimi-code/c.new" "$HOME/.kimi-code/config.toml"; }
  fi

  cli_launch "$cli" "$message"
  local flag; flag=$(cli_bypass_flag "$cli")
  if [ -n "$flag" ] && ! "$bin" --help 2>&1 | grep -q -- "--$flag"; then
    echo "WARNING: $bin --help no longer lists --$flag; check the launch flags" >&2
  fi
  { printf '%q ' "${LAUNCH[@]:0:${#LAUNCH[@]}-1}"; echo '<message>'; } >"$meta/launch.txt"
  if [ "$dry" = 1 ]; then
    echo "» dry run [$variant]: $(cat "$meta/launch.txt")"; sed 's/^/  /' "$meta/cli-version.txt" "$meta/tool-versions.txt"
    [ -s "$meta/skills.sha256" ] && sed 's/^/  skill /' "$meta/skills.sha256"
    return 0
  fi

  date -u +%FT%TZ >"$meta/started_at"
  echo "» starting $cli [$variant] in $WORK. Every permission prompt is bypassed. Exit the CLI when the run ends."
  set +e; "${LAUNCH[@]}"; echo $? >"$meta/exit_code"; set -e
  date -u +%FT%TZ >"$meta/finished_at"

  {
    if [ -f "$WORK/delivery/LOCK.json" ]; then
      echo "lock: $(cd "$WORK" && node tooling/lock-submission.mjs --check 2>&1)"
      local r lc early
      r=$(grep -o 'MLNW-[0-9A-F]*' "$WORK/delivery/ENVELOPE.md" 2>/dev/null | head -1 || true)
      lc=$(git -C "$WORK" log -1 --format=%H -- delivery/LOCK.json 2>/dev/null || true)
      if [ -n "$r" ] && [ -n "$lc" ]; then
        early=$(git -C "$WORK" log -S"$r" --format='%h %s' "$lc^" 2>/dev/null || true)
        echo "receipt $r before lock: ${early:-none (clean)}"
      fi
    else
      echo "lock: none; the run did not lock a submission"
    fi
    ls "$WORK"/magga-v2-*.tar.gz 2>/dev/null | sed 's/^/bundle: /' || true
  } | tee "$meta/post-run.txt"
  local ex=(--exclude=.npm --exclude=.cache --exclude=.npm-global --exclude=.local/share/fnm --exclude=.local/share/uv
            --exclude=.agent-browser --exclude=.magga-run --exclude=./.omp/agent/agent.db --exclude=./.kimi-code/config.toml)
  for f in $(cli_auth "$cli"); do ex+=("--exclude=./$f"); done
  tar "${ex[@]}" -czf "$meta/home-transcripts.tar.gz" -C "$HOME" . 2>/dev/null || true
}

# ------------------------------------------------------------------ host side
die() { echo "magga-v2: $*" >&2; exit 1; }

if [ "${1:-}" = creds ]; then
  shift; want=${*:-$CLIS}
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
  for c in $want; do bundle_add "$tmp" "$c"; done
  bundle_env "$tmp"
  found=$(cd "$tmp" && ls -d */ 2>/dev/null | tr -d / | tr '\n' ' ')
  out="$PWD/magga-creds.b64"; umask 077
  tar -czf - -C "$tmp" . | base64 -w0 >"$out"
  echo "» wrote $out ($(wc -c <"$out") bytes, mode 600)"
  echo "  logins: ${found:-none}   env keys: $(cut -d= -f1 "$tmp/env" | tr '\n' ' ')"
  for c in $want; do case " $found " in *" $c "*) ;; *) echo "  no login found for $c (it signs in inside the run, or set its API key before exporting)";; esac; done
  echo "  This file is a secret. Use it as either:"
  echo "    run.sh <cli> --creds magga-creds.b64"
  echo "    MAGGA_CREDS=\"\$(cat magga-creds.b64)\"   (e.g. a cloud-environment secret)"
  exit 0
fi

if [ "${1:-}" = setup ]; then
  # Prepare an app's own cloud environment in place: its agent runs the benchmark, not this script.
  shift; VARIANT=vanilla
  for a in "$@"; do case $a in vanilla|godspeed|ufo) VARIANT=$a ;; *) die "setup takes: vanilla | godspeed | ufo" ;; esac; done
  SUDO=""; [ "$(id -u)" = 0 ] || { command -v sudo >/dev/null && sudo -n true 2>/dev/null && SUDO=sudo; }
  if command -v apt-get >/dev/null && { [ "$(id -u)" = 0 ] || [ -n "$SUDO" ]; }; then
    echo "» installing base packages"
    { $SUDO apt-get update -qq && DEBIAN_FRONTEND=noninteractive $SUDO apt-get install -y -qq git curl ca-certificates xz-utils unzip sqlite3 python3 >/dev/null; } 2>&1 | tail -3 || true
  fi
  for t in git curl unzip; do command -v "$t" >/dev/null || die "$t is required and could not be installed"; done
  export WORK="$PWD"
  inner_stage setup "$VARIANT" 0 0
  # Make the toolchain visible to every shell the app's agent opens, not only interactive ones.
  line="[ -f \"$HOME/.magga-env.sh\" ] && { . \"$HOME/.magga-env.sh\"; export BASH_ENV=\"$HOME/.magga-env.sh\"; }"
  for f in /etc/profile.d/magga-env.sh /etc/bash.bashrc /etc/environment.d/magga.conf; do
    case $f in
      */environment.d/*) $SUDO mkdir -p /etc/environment.d 2>/dev/null && printf 'BASH_ENV=%s\n' "$HOME/.magga-env.sh" | $SUDO tee "$f" >/dev/null 2>&1 || true ;;
      *) grep -qs magga-env "$f" || printf '%s\n' "$line" | $SUDO tee -a "$f" >/dev/null 2>&1 || true ;;
    esac
  done
  M="$HOME/.magga-run/MESSAGE.md"
  echo
  echo "» environment ready (variant: $VARIANT). Tools: $(tr '\n' ' ' <"$HOME/.magga-run/tool-versions.txt")"
  echo "» send this as the task's first and only message (saved at $M):"
  echo "------------------------------------------------------------------------"
  cat "$M"
  echo "------------------------------------------------------------------------"
  exit 0
fi

CLI="" VARIANT=vanilla MODE="" DRY=0 LOGIN=0 REBUILD=0 CREDS=""
while [ $# -gt 0 ]; do case $1 in
  --docker) MODE=docker ;; --bare) MODE=bare ;; --dry) DRY=1 ;; --login) LOGIN=1 ;; --rebuild) REBUILD=1 ;;
  --creds) CREDS=${2:?--creds needs a file}; shift ;;
  vanilla|godspeed|ufo) VARIANT=$1 ;;
  -h|--help) sed -n '2,27p' "${BASH_SOURCE[0]}" 2>/dev/null || echo "usage: run.sh <cli> [vanilla|godspeed|ufo] | run.sh creds"; exit 0 ;;
  -*) die "unknown option $1" ;; *) CLI=$1 ;;
esac; shift; done
case " $CLIS shell " in *" $CLI "*) [ -n "$CLI" ] || die "pick a CLI: $CLIS shell" ;; *) die "pick a CLI: $CLIS shell" ;; esac

if [ -z "$MODE" ]; then
  if command -v docker >/dev/null && docker info >/dev/null 2>&1; then MODE=docker
  elif command -v docker >/dev/null && command -v systemctl >/dev/null && sudo -n true 2>/dev/null \
       && sudo systemctl start docker 2>/dev/null && docker info >/dev/null 2>&1; then MODE=docker
  else MODE=bare; fi
fi
TTY=/dev/stdin; [ -t 0 ] || TTY=/dev/tty
ID="$CLI-$VARIANT-$(date -u +%Y%m%dT%H%M%SZ)"
RUNS=$(mkdir -p "${MAGGA_RUNS:-$PWD/magga-v2-runs}" && cd "${MAGGA_RUNS:-$PWD/magga-v2-runs}" && pwd)
RUN="$RUNS/$ID"; mkdir -p "$RUN/work"
echo "» MAGGA v2 run $ID ($MODE) → $RUN"

# Credentials for this CLI only: bundle, else this machine's logins, else sign-in inside the run.
AUTH=$(mktemp -d); trap 'rm -rf "$AUTH"' EXIT
if [ $LOGIN = 0 ] && [ "$CLI" != shell ]; then
  if [ -n "$CREDS" ] || [ -n "${MAGGA_CREDS:-}" ]; then
    { if [ -n "$CREDS" ]; then cat "$CREDS"; else printf '%s' "$MAGGA_CREDS"; fi; } | base64 -d | tar -xzf - -C "$AUTH" \
      || die "could not read the credential bundle"
    echo "» logins from bundle: $(cd "$AUTH" && ls -d */ 2>/dev/null | tr -d / | tr '\n' ' ')"
  else
    bundle_add "$AUTH" "$CLI"; bundle_env "$AUTH"
  fi
  [ -d "$AUTH/$CLI" ] && echo "» $CLI login: $(cd "$AUTH/$CLI" && find . -type f | sed 's|^\./|~/|' | tr '\n' ' ')"
fi
touch "$AUTH/env"
FUNCS="$(declare -p PROMPT_URL PROMPT_SHA VARIANTS_BASE VARIANT_SHA_godspeed VARIANT_SHA_ufo PASS_ENV SKILL_DIRS); $(declare -f cli_install cli_bin cli_launch cli_bypass_flag cli_auth cli_login inner_stage)"

record() {
  local meta=$1
  j() { [ -s "$meta/$1" ] && printf '"%s"' "$(tr -d '\n' <"$meta/$1" | sed 's/\\/\\\\/g; s/"/\\"/g')" || printf 'null'; }
  { printf '{\n  "run_id": "%s",\n  "cli": "%s",\n  "variant": "%s",\n  "environment": "%s",\n' "$ID" "$CLI" "$VARIANT" "$MODE"
    printf '  "privileged": %s,\n  "cli_version": %s,\n' "$([ "$MODE" = docker ] && echo true || echo false)" "$(j cli-version.txt)"
    printf '  "prompt_url": "%s",\n  "prompt_sha256": "%s",\n  "message_sha256": %s,\n' "$PROMPT_URL" "$PROMPT_SHA" "$(j message.sha256)"
    printf '  "started_at": %s,\n  "finished_at": %s,\n  "exit_code": %s,\n' "$(j started_at)" "$(j finished_at)" "$(j exit_code)"
    printf '  "image": "%s",\n  "work": "work/",\n  "meta": "meta/"\n}\n' "${IMAGE_ID:-}"; } >"$RUN/run.json"
}

if [ "$MODE" = docker ]; then
  if [ $REBUILD = 1 ] || ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
    echo "» building $IMAGE (once)"
    docker build -q -t "$IMAGE" - <<'DOCKERFILE' >/dev/null
FROM node:24-bookworm
RUN apt-get update && apt-get install -y --no-install-recommends sudo ripgrep jq unzip xz-utils less sqlite3 \
    python3 python3-venv python3-pip build-essential ca-certificates iproute2 procps \
 && rm -rf /var/lib/apt/lists/* && echo 'node ALL=(ALL) NOPASSWD:ALL' >/etc/sudoers.d/node && chmod 0440 /etc/sudoers.d/node \
 && mkdir /work && chown node:node /work
USER node
ENV BASH_ENV=/home/node/.magga-env.sh \
    PATH=/home/node/.local/share/fnm:/home/node/.local/bin:/home/node/.npm-global/bin:/home/node/.kimi-code/bin:/home/node/.grok/bin:/home/node/.opencode/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
WORKDIR /work
DOCKERFILE
  fi
  IMAGE_ID=$(docker image inspect -f '{{.Id}}' "$IMAGE")
  NAME="magga-$ID"
  docker create -it --privileged --name "$NAME" --hostname magga --shm-size=2g \
    -v "$RUN/work:/work" -e WORK=/work -e HOME=/home/node --env-file "$AUTH/env" \
    "$IMAGE" bash -c "$FUNCS; inner_stage $CLI $VARIANT $DRY $LOGIN" >/dev/null
  [ -d "$AUTH/$CLI" ] && docker cp "$AUTH/$CLI/." "$NAME:/home/node/" >/dev/null
  set +e; docker start -ai "$NAME" <"$TTY"; set -e
  docker cp "$NAME:/home/node/.magga-run" "$RUN/meta" >/dev/null 2>&1 || true
  record "$RUN/meta"
  echo "» container kept as $NAME (docker rm $NAME when done)"
else
  echo "» bare mode: the run has your user's rights on this machine; prefer Docker locally"
  RHOME="$RUN/home"; mkdir -p "$RHOME"
  [ -d "$AUTH/$CLI" ] && cp -a "$AUTH/$CLI/." "$RHOME/"
  KEYS=(); while IFS= read -r line; do [ -n "$line" ] && KEYS+=("$line"); done <"$AUTH/env"
  set +e; env -i PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin" TERM="${TERM:-xterm-256color}" LANG="${LANG:-C.UTF-8}" \
    HOME="$RHOME" USER="${USER:-agent}" WORK="$RUN/work" "${KEYS[@]}" \
    bash -c "$FUNCS; inner_stage $CLI $VARIANT $DRY $LOGIN" <"$TTY"; set -e
  mkdir -p "$RUN/meta"; cp -a "$RHOME/.magga-run/." "$RUN/meta/" 2>/dev/null || true
  record "$RUN/meta"
fi
echo "» run folder: $RUN"
[ -f "$RUN/meta/post-run.txt" ] && cat "$RUN/meta/post-run.txt"
exit 0
