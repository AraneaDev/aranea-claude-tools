#!/usr/bin/env bash
#
# A marketplace is a promise about repositories it does not contain. Nothing
# here fails at build time, it fails when somebody tries to install. These are
# the checks that turn a silent broken install into a red build.
#
# Run from the repository root. Set GH_TOKEN for the remote checks, or pass
# --offline to skip them.

set -uo pipefail

MANIFEST=.claude-plugin/marketplace.json
OFFLINE=0
[ "${1:-}" = "--offline" ] && OFFLINE=1

status=0
ok()  { printf '  \033[32mok\033[0m    %s\n' "$1"; }
bad() { printf '  \033[31mFAIL\033[0m  %s\n' "$1"; status=1; }
skip(){ printf '  \033[33mskip\033[0m  %s\n' "$1"; }

echo "Validating $MANIFEST"

jq -e . "$MANIFEST" >/dev/null 2>&1 || { bad "manifest is not valid JSON"; exit 1; }
ok "manifest is valid JSON"

# --- marketplace-level fields -------------------------------------------------
for field in name owner description plugins; do
  if [ "$(jq -r "has(\"$field\")" "$MANIFEST")" = "true" ]; then
    ok "marketplace has '$field'"
  else
    bad "marketplace is missing '$field'"
  fi
done

count=$(jq '.plugins | length' "$MANIFEST")
if [ "$count" -gt 0 ]; then ok "$count plugin(s) listed"; else bad "no plugins listed"; fi

# --- per-plugin ---------------------------------------------------------------
echo
echo "Checking each plugin entry"
for i in $(seq 0 $((count - 1))); do
  name=$(jq -r ".plugins[$i].name" "$MANIFEST")
  desc=$(jq -r ".plugins[$i].description // empty" "$MANIFEST")
  repo=$(jq -r ".plugins[$i].source.repo // empty" "$MANIFEST")
  kind=$(jq -r ".plugins[$i].source.source // \"path\"" "$MANIFEST")

  echo "  [$name]"
  if [ -z "$name" ] || [ "$name" = "null" ]; then bad "entry $i has no name"; fi
  if [ -n "$desc" ]; then ok "has a description"; else bad "$name has no description"; fi

  # A duplicate name makes `/plugin install <name>@<market>` ambiguous.
  dupes=$(jq -r "[.plugins[].name] | map(select(. == \"$name\")) | length" "$MANIFEST")
  if [ "$dupes" -eq 1 ]; then ok "name is unique"; else bad "$name is listed $dupes times"; fi

  if [ "$kind" != "github" ]; then
    skip "$name uses source type '$kind', remote checks are github-only"
    continue
  fi
  [ -n "$repo" ] || { bad "$name has a github source with no repo"; continue; }

  if [ "$OFFLINE" -eq 1 ]; then
    skip "$name -> $repo (offline)"
    continue
  fi

  # The install-breaking failures: the repo is gone, private, or renamed.
  if gh api "repos/$repo" --jq .full_name >/dev/null 2>&1; then
    ok "$repo exists and is reachable"
  else
    bad "$repo is unreachable: a user installing $name would get nothing"
    continue
  fi

  # A repo with no plugin manifest installs as an empty plugin.
  if gh api "repos/$repo/contents/.claude-plugin/plugin.json" --jq .name >/dev/null 2>&1; then
    ok "$repo has .claude-plugin/plugin.json"
    declared=$(gh api "repos/$repo/contents/.claude-plugin/plugin.json" --jq .content \
      | base64 -d | jq -r .name)
    if [ "$declared" = "$name" ]; then
      ok "plugin.json name '$declared' matches the marketplace entry"
    else
      bad "$repo declares itself '$declared' but this marketplace advertises '$name'"
    fi
  else
    bad "$repo has no .claude-plugin/plugin.json"
  fi
done

# --- the README must not advertise what the manifest does not list ------------
echo
echo "Checking README.md against the manifest"
market=$(jq -r .name "$MANIFEST")
while read -r advertised; do
  if jq -e --arg n "$advertised" '.plugins[] | select(.name == $n)' "$MANIFEST" >/dev/null; then
    ok "README installs '$advertised', which the manifest lists"
  else
    bad "README installs '$advertised', which the manifest does not list"
  fi
done < <(grep -oE "plugin install [a-z0-9-]+@${market}" README.md | awk '{print $3}' | cut -d@ -f1 | sort -u)

for listed in $(jq -r '.plugins[].name' "$MANIFEST"); do
  if grep -q "plugin install ${listed}@${market}" README.md; then
    ok "README documents how to install '$listed'"
  else
    bad "'$listed' is listed but the README never shows how to install it"
  fi
done

echo
if [ "$status" -eq 0 ]; then
  printf '\033[32mmarketplace is consistent\033[0m\n'
else
  printf '\033[31mmarketplace has problems\033[0m\n'
fi
exit "$status"
