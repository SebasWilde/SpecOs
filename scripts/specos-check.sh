#!/usr/bin/env bash
# SpecOS — deterministic check for a specs repo
#
# Usage: specos-check.sh [root] [--strict] [--session <file>] [--impacts <feature>]
#
# Reads specs/*/spec.md and specs/*/*/spec.md (groups with `type: group` are
# skipped) and reports warnings. Warnings never fail the run unless --strict is
# given, which exits 1 when any warning was printed. Bash + grep/awk/sed only.
#
# Formats it understands:
#   AC definitions   - AC1: text   |   - **AC1** — text   |   - AC1 — text   (AC21b ids)
#                    an annotation may sit between id and separator: - AC8 *(example)*: text
#   AC references    AC1, AC1–AC11 (en dash or hyphen), AC1-3
#   task lines       - [FK-927] Title (AC1–AC3) v1.0   |   - [new] ...   |   - [SP-01] ...
#   testcases        ## TC-01 — title, then covers: / steps: / expected:, and a `spec: v1.1` stamp
#   status           draft needs ## Assumptions or ## Open questions with content; approved must have no ## Assumptions
#   session.md       task: is a ticket key, [new] or null
set -uo pipefail

ROOT="."
STRICT=0
SESSION=""
IMPACTS=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --strict)  STRICT=1 ;;
    --session) shift; SESSION="${1:-}" ;;
    --impacts) shift; IMPACTS="${1:-}" ;;
    -h|--help) sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*) echo "specos-check: unknown option $1" >&2; exit 2 ;;
    *)  ROOT="$1" ;;
  esac
  shift
done

if [[ ! -d "$ROOT/specs" ]]; then
  echo "specos-check: no specs/ directory in $ROOT" >&2
  exit 2
fi
ROOT="$(cd "$ROOT" && pwd)"
[[ -z "$SESSION" ]] && SESSION="$ROOT/session.md"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

EM=$'\xe2\x80\x94'   # em dash
EN=$'\xe2\x80\x93'   # en dash
# Dashes become ASCII so every later pattern is plain ASCII.
norm() { LC_ALL=C sed -e "s/$EM/ - /g" -e "s/$EN/-/g" -e 's/\r$//' "$1"; }

# Frontmatter value: fm <file> <key>
fm() {
  awk -v k="$2" '
    NR == 1 && $0 !~ /^---/ { exit }
    NR > 1 && /^---/ { exit }
    NR > 1 && $0 ~ ("^" k ":") { sub("^" k ":[ \t]*", ""); gsub(/["'"'"']/, ""); sub(/[ \t]+#.*$/, ""); sub(/[ \t]+$/, ""); print; exit }
  ' < <(tr -d '\r' < "$1")
}

# Frontmatter list items under `linked:`
fm_linked() {
  awk '
    NR == 1 && $0 !~ /^---/ { exit }
    NR > 1 && /^---/ { exit }
    /^linked:/ { on = 1; next }
    on && /^[ \t]*-[ \t]+/ { sub(/^[ \t]*-[ \t]+/, ""); gsub(/["'"'"']/, ""); sub(/[ \t]+#.*$/, ""); sub(/[ \t]+$/, ""); print; next }
    on && /^[^ \t-]/ { on = 0 }
  ' < <(tr -d '\r' < "$1")
}

# Number of content lines under a `## <heading>` section (none / n/a / - count as empty).
sec_content() {
  norm "$1" | awk -v h="$2" '
    /^[ \t]*```/ { fence = !fence; next }
    fence { next }
    /^##[ \t]+/ { t = $0; sub(/^##[ \t]+/, "", t); sub(/[ \t]+$/, "", t); on = (tolower(t) == tolower(h)); next }
    on {
      l = $0; gsub(/^[ \t]+|[ \t]+$/, "", l)
      if (l == "") next
      lt = tolower(l); gsub(/[.*_]/, "", lt)
      if (lt ~ /^(none|n\/a|-)$/) next
      n++
    }
    END { print n + 0 }'
}

list_specs() {
  find "$ROOT/specs" -mindepth 2 -maxdepth 3 -name spec.md 2>/dev/null | LC_ALL=C sort
}

feature_of() { local d; d="$(dirname "$1")"; echo "${d#$ROOT/specs/}"; }

# --- --impacts <feature> ----------------------------------------------------

if [[ -n "$IMPACTS" ]]; then
  IMPACTS="${IMPACTS#specs/}"; IMPACTS="${IMPACTS%/spec.md}"; IMPACTS="${IMPACTS%/}"
  echo "Specs that link to $IMPACTS:"
  found=0
  while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    feat="$(feature_of "$f")"
    [[ "$feat" == "$IMPACTS" ]] && continue
    if fm_linked "$f" | sed -e 's|^\./||' -e 's|^specs/||' -e 's|/spec\.md$||' -e 's|/$||' | grep -qx "$IMPACTS"; then
      echo "  specs/$feat/spec.md"
      found=$((found+1))
    fi
  done < <(list_specs)
  [[ $found -eq 0 ]] && echo "  none"
  exit 0
fi

# --- per-spec awk -----------------------------------------------------------
# Input files, in order: spec.md, tasks.md, testcases.md (each normalized).
# Missing files are passed as empty files; hastasks / hastests tell them apart.

IFS= read -r -d '' AWK_CHECK <<'AWK'
function warn(m) { print "  warn  " m; nwarn++ }
function info(m) { print "  info  " m }

function numof(id,   t) { t = id; sub(/^AC/, "", t); sub(/[a-z]$/, "", t); return t + 0 }

function vcmp(a, b,   x, y, i, n) {
  n = split(a, x, "."); split(b, y, ".")
  for (i = 1; i <= 3; i++) {
    if ((x[i] + 0) < (y[i] + 0)) return -1
    if ((x[i] + 0) > (y[i] + 0)) return 1
  }
  return 0
}

# Fills RLO[1..n] / RHI[1..n] with the AC references found in a line.
function parse_refs(line,   rest, tok, a, hi, prev) {
  nref = 0
  rest = line
  while (match(rest, /AC[0-9]+[a-z]?(-(AC)?[0-9]+[a-z]?)?/)) {
    tok = substr(rest, RSTART, RLENGTH)
    prev = (RSTART > 1) ? substr(rest, RSTART - 1, 1) : ""
    rest = substr(rest, RSTART + RLENGTH)
    if (prev ~ /[A-Za-z0-9]/) continue
    nref++
    if (index(tok, "-") > 0) {
      split(tok, a, "-")
      hi = a[2]; if (hi !~ /^AC/) hi = "AC" hi
      RLO[nref] = a[1]; RHI[nref] = hi
    } else { RLO[nref] = tok; RHI[nref] = "" }
  }
  return nref
}

# Returns the AC id when the line defines one, "" otherwise. Sets DEF_RETIRED / DEF_PENDING.
function acdef(line,   t, bold, id, rest) {
  DEF_RETIRED = 0; DEF_PENDING = 0
  t = line
  if (!match(t, /^[ \t]*[-*][ \t]+/)) return ""
  t = substr(t, RLENGTH + 1)
  if (match(t, /^\[[ xX]\][ \t]+/)) t = substr(t, RLENGTH + 1)
  bold = 0
  if (substr(t, 1, 2) == "**") { bold = 1; t = substr(t, 3) }
  if (!match(t, /^AC[0-9]+[a-z]?/)) return ""
  id = substr(t, 1, RLENGTH); rest = substr(t, RLENGTH + 1)
  if (substr(rest, 1, 1) ~ /[A-Za-z0-9]/) return ""
  if (bold) sub(/^\*\*/, "", rest)
  if (match(rest, /^[ \t]*\*?\([^)]*\)\*?/)) rest = substr(rest, RLENGTH + 1)   # *(example)*
  if (!bold && rest !~ /^[ \t]*(:|-[ \t])/) return ""
  t = tolower(rest); sub(/^\**[ \t]*(:|-)?[ \t]*\**[ \t]*/, "", t)
  if (t ~ /^retired/) DEF_RETIRED = 1
  if (tolower(line) ~ /\[pending\]/) DEF_PENDING = 1
  return id
}

function list_some(arr, n,   i, s, shown) {
  s = ""; shown = 0
  for (i = 1; i <= n; i++) { if (shown < 8) { s = s (shown ? ", " : "") arr[i]; shown++ } }
  if (n > 8) s = s " (+" (n - 8) " more)"
  return s
}

function close_case() {
  if (curtc == "") return
  ncase++
  if (!tc_steps) nsketch++
  if (!tc_covers) nnocov++
  curtc = ""
}

FNR == 1 { fileno++; fence = 0; fmstate = 0 }

# ---- file 1: spec.md --------------------------------------------------------
fileno == 1 {
  if (FNR == 2 && $0 ~ /^---/) { fmstate = 1; next }
  if (fmstate == 1) { if ($0 ~ /^---/) fmstate = 2; next }
  if ($0 ~ /^[ \t]*```/) { fence = !fence; next }
  if (fence) next
  id = acdef($0)
  if (id != "") {
    if (id in ACDEF) {
      if (DUPN[id] == 0) { ndup++; DUPORD[ndup] = id; DUPN[id] = 1 }
      DUPN[id]++; next
    }
    nac++; ACORD[nac] = id; ACDEF[id] = 1
    if (DEF_RETIRED) RET[id] = 1
    if (DEF_PENDING) PEND[id] = 1
  }
  next
}

# ---- file 2: tasks.md -------------------------------------------------------
fileno == 2 {
  if ($0 ~ /^[ \t]*```/) { fence = !fence; next }
  if (fence) next
  if (!match($0, /^[ \t]*-[ \t]+\[[^]]+\]/)) next
  keytxt = substr($0, 1, RLENGTH); rest = substr($0, RLENGTH + 1)
  sub(/^[ \t]*-[ \t]+\[/, "", keytxt); sub(/\]$/, "", keytxt)
  if (keytxt ~ /^[ xX]$/) next          # an old checkbox line, not a task key
  ntask++
  if (keytxt == "new") nnew++
  else if (keytxt ~ /^SP-[0-9]+$/) nsp++
  if (nac == 0) next
  n = parse_refs(rest)
  if (n == 0) notaskref++
  for (i = 1; i <= n; i++) {
    lo = RLO[i]; hi = RHI[i]
    if (hi == "") {
      if (!(lo in ACDEF)) warn("task [" keytxt "] references " lo ", which does not exist")
      else if (lo in RET) warn("task [" keytxt "] references " lo ", which is retired")
      else if (lo in PEND) warn("task [" keytxt "] references " lo ", which is [pending]")
    } else {
      if (!(lo in ACDEF)) warn("task [" keytxt "] references " lo ", which does not exist")
      if (!(hi in ACDEF)) warn("task [" keytxt "] references " hi ", which does not exist")
      for (j = 1; j <= nac; j++) {
        a = ACORD[j]
        if (numof(a) >= numof(lo) && numof(a) <= numof(hi)) {
          if (a in RET) warn("task [" keytxt "] range " lo "-" hi " includes " a ", which is retired")
          else if (a in PEND) warn("task [" keytxt "] range " lo "-" hi " includes " a ", which is [pending]")
        }
      }
    }
  }
  next
}

# ---- file 3: testcases.md ---------------------------------------------------
fileno == 3 {
  if ($0 ~ /^[ \t]*```/) { fence = !fence; next }
  if (fence) next
  if ($0 ~ /^##[ \t]+TC-[0-9]+/) {
    close_case()
    curtc = $0; sub(/^##[ \t]+/, "", curtc); sub(/[ \t].*$/, "", curtc)
    tc_steps = 0; tc_covers = 0; seen_tc = 1
    next
  }
  if (!seen_tc && $0 ~ /^spec:[ \t]*v?[0-9]+\.[0-9]+/) {
    stamp = $0; sub(/^spec:[ \t]*v?/, "", stamp); sub(/[^0-9.].*$/, "", stamp)
    next
  }
  if (curtc == "") next
  if ($0 ~ /^[ \t]*steps:/) tc_steps = 1
  if ($0 ~ /^[ \t]*covers:/) {
    tc_covers = 1; anycov = 1
    if (nac == 0) next
    line = $0; sub(/^[ \t]*covers:/, "", line)
    n = parse_refs(line)
    for (i = 1; i <= n; i++) {
      lo = RLO[i]; hi = RHI[i]
      if (hi == "") {
        if (!(lo in ACDEF)) warn(curtc " covers " lo ", which does not exist")
        else { COV[lo] = 1; if (lo in RET) warn(curtc " covers " lo ", which is retired") }
      } else {
        if (!(lo in ACDEF)) warn(curtc " covers " lo ", which does not exist")
        if (!(hi in ACDEF)) warn(curtc " covers " hi ", which does not exist")
        for (j = 1; j <= nac; j++) {
          a = ACORD[j]
          if (numof(a) >= numof(lo) && numof(a) <= numof(hi)) COV[a] = 1
        }
      }
    }
  }
  next
}

END {
  close_case()
  if (ndup > 0) {
    s = ""; shown = 0
    for (i = 1; i <= ndup; i++) { if (shown < 8) { s = s (shown ? ", " : "") DUPORD[i] "×" DUPN[DUPORD[i]]; shown++ } }
    if (ndup > 8) s = s " (+" (ndup - 8) " more)"
    warn(s " — ids repeated, legacy per-journey numbering?")
  }
  if (nac == 0) {
    info("no AC ids found (legacy spec) — AC checks skipped")
  } else {
    nun = 0
    for (j = 1; j <= nac; j++) { a = ACORD[j]; if (!(a in RET) && !(a in COV)) UNC[++nun] = a }
    if (hastests && ncase > 0 && !anycov) {
      info("testcases.md has no covers: lines (old format) — coverage not checked")
    } else {
      if (nun > 0) {
        if (!hastests) warn("no testcases.md — " nun " AC(s) have no test case: " list_some(UNC, nun))
        else warn(nun " AC(s) have no test case covering them: " list_some(UNC, nun))
      }
      if (hastests && ncase > 0 && nnocov > 0) warn(nnocov " of " ncase " test case(s) have no covers:")
    }
    if (hastasks && notaskref > 0) info(notaskref " task(s) reference no AC")
  }
  if (hastests && ncase > 0) {
    if (nsketch > 0) warn(nsketch " of " ncase " test case(s) are sketches (no steps:)")
    if (stamp == "" && nsketch < ncase && anycov) info("testcases.md has expanded cases but no spec: stamp")
    else if (stamp != "" && specver != "" && vcmp(stamp, specver) < 0) warn("testcases.md is stamped spec: v" stamp ", behind the spec at v" specver)
  }
  if (nnew > 0) warn(nnew " [new] task(s) still waiting for a ticket key")
  if (nsp > 0) info(nsp " legacy SP- placeholder(s) — distribute asks before treating them as new")
}
AWK

# --- main loop --------------------------------------------------------------

NSPECS=0; NGROUPS=0; NWARN=0; NWARNSPECS=0
OUT="$TMP/out.txt"; : > "$OUT"

while IFS= read -r spec; do
  [[ -z "$spec" ]] && continue
  dir="$(dirname "$spec")"
  feat="$(feature_of "$spec")"

  if [[ "$(fm "$spec" type)" == "group" ]]; then
    NGROUPS=$((NGROUPS+1)); continue
  fi
  NSPECS=$((NSPECS+1))

  ver="$(fm "$spec" version)"
  res="$TMP/res.txt"; : > "$res"

  norm "$spec" > "$TMP/spec.md"
  hastasks=0; hastests=0
  if [[ -f "$dir/tasks.md" ]];     then norm "$dir/tasks.md" > "$TMP/tasks.md"; hastasks=1; else : > "$TMP/tasks.md"; fi
  if [[ -f "$dir/testcases.md" ]]; then norm "$dir/testcases.md" > "$TMP/testcases.md"; hastests=1; else : > "$TMP/testcases.md"; fi

  # awk skips empty files, so fileno must not be inferred from position when one is empty:
  # prepend a marker line to every file.
  for n in spec tasks testcases; do
    { echo "#specos-file"; cat "$TMP/$n.md"; } > "$TMP/$n.in"
  done

  awk -v specver="$ver" -v hastasks="$hastasks" -v hastests="$hastests" \
      "$AWK_CHECK" "$TMP/spec.in" "$TMP/tasks.in" "$TMP/testcases.in" >> "$res" 2>/dev/null || \
    echo "  warn  check crashed on this spec (awk error)" >> "$res"

  # draft / approved against the Assumptions and Open questions sections
  status="$(fm "$spec" status)"
  if [[ "$status" == "draft" || "$status" == "approved" ]]; then
    n_as=$(sec_content "$spec" "Assumptions"); n_oq=$(sec_content "$spec" "Open questions")
    if [[ "$status" == "draft" && "$n_as" -eq 0 && "$n_oq" -eq 0 ]]; then
      echo "  warn  status is draft but there is no ## Assumptions or ## Open questions with content — approve it, or list what is open" >> "$res"
    elif [[ "$status" == "approved" && "$n_as" -gt 0 ]]; then
      echo "  warn  status is approved but ## Assumptions still has $n_as item(s) — unconfirmed assumptions" >> "$res"
    fi
  fi

  # linked: paths
  while IFS= read -r l; do
    [[ -z "$l" || "$l" == *"["* ]] && continue
    if [[ ! -e "$ROOT/$l" && ! -e "$dir/$l" ]]; then
      echo "  warn  linked path does not exist: $l" >> "$res"
    fi
  done < <(fm_linked "$spec")

  # CHANGELOG entry for the current version
  if [[ -n "$ver" ]]; then
    if [[ ! -f "$dir/CHANGELOG.md" ]]; then
      echo "  warn  no CHANGELOG.md (spec is v$ver)" >> "$res"
    else
      vre="${ver//./\\.}"
      if ! grep -Eq "^##.*(^|[^0-9.])v?${vre}([^0-9]|$)|(^|[^0-9.A-Za-z])v${vre}([^0-9]|$)" "$dir/CHANGELOG.md"; then
        echo "  warn  spec is v$ver but CHANGELOG.md has no entry for it" >> "$res"
      fi
    fi
  else
    echo "  warn  spec.md has no version in its frontmatter" >> "$res"
  fi

  if [[ -s "$res" ]]; then
    {
      echo ""
      echo "specs/$feat${ver:+ (v$ver)}"
      cat "$res"
    } >> "$OUT"
    w=$(grep -c '^  warn' "$res" || true)
    if [[ "$w" -gt 0 ]]; then
      NWARN=$((NWARN + w)); NWARNSPECS=$((NWARNSPECS+1))
    fi
  fi
done < <(list_specs)

# --- session.md -------------------------------------------------------------

SESS_OUT=""
if [[ -f "$SESSION" ]]; then
  lines=$(wc -l < "$SESSION" | tr -d ' ')
  bytes=$(wc -c < "$SESSION" | tr -d ' ')
  if [[ "$lines" -gt 30 || "$bytes" -gt 2048 ]]; then
    SESS_OUT="  warn  session.md is $lines lines / $bytes bytes (limit 30 lines / 2 KB) — rewrite it"
    NWARN=$((NWARN+1))
  fi
  # `task:` is a ticket key, [new] or null — never prose.
  if grep -q '^task:' "$SESSION"; then
    tval=$(tr -d '\r' < "$SESSION" | awk '/^task:/ { sub(/^task:[ \t]*/, ""); sub(/[ \t]+#.*$/, ""); gsub(/["'"'"']/, ""); sub(/[ \t]+$/, ""); print; exit }')
    if [[ ! "$tval" =~ ^(null|\[new\]|[A-Za-z][A-Za-z0-9]*-[0-9]+)$ ]]; then
      SESS_OUT="${SESS_OUT:+$SESS_OUT
}  warn  session.md task is '$tval' — use a ticket key (PROJ-123), [new] or null"
      NWARN=$((NWARN+1))
    fi
  fi
  # `open` is for questions about the active task: at most 3 entries.
  nopen=$(tr -d '\r' < "$SESSION" | awk '
    /^open:/ { on = 1; next }
    on && /^[A-Za-z_]+:/ { on = 0 }
    on && /^[ \t]+-[ \t]/ { n++ }
    END { print n + 0 }')
  if [[ "$nopen" -gt 3 ]]; then
    SESS_OUT="${SESS_OUT:+$SESS_OUT
}  warn  session.md open has $nopen entries (max 3, active task only) — move the rest to parked"
    NWARN=$((NWARN+1))
  fi
fi

# --- report -----------------------------------------------------------------

echo "SpecOS check — $ROOT"
echo "  specs checked: $NSPECS (groups skipped: $NGROUPS)"
cat "$OUT"
if [[ -n "$SESS_OUT" ]]; then
  echo ""
  echo "session.md"
  echo "$SESS_OUT"
fi
echo ""
if [[ $NWARN -eq 0 ]]; then
  echo "No warnings."
else
  echo "$NWARN warning(s) in $NWARNSPECS spec(s)${SESS_OUT:+ (plus session.md)}."
fi

if [[ $STRICT -eq 1 && $NWARN -gt 0 ]]; then exit 1; fi
exit 0
