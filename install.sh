#!/usr/bin/env bash
# Install Cursor engineering governance rules.
#
# Usage:
#   ./install.sh                 # user-global (~/.cursor/rules) + prompt for accounts
#   ./install.sh --project       # current project (.cursor/rules) + prompt
#   ./install.sh /path/to/dir    # custom destination rules dir + prompt
#   ./install.sh --skip-accounts # install rules only (no account-map prompt)
#
# Non-interactive (CI / scripted):
#   GITHUB_ACCOUNT=you@example.com \
#   SUPABASE_ACCOUNT=you@example.com \
#   VERCEL_ACCOUNT=you@example.com \
#   ./install.sh --yes
#
# Env overrides (optional): GITHUB_ACCOUNT, SUPABASE_ACCOUNT, VERCEL_ACCOUNT

set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
SRC_RULE="$ROOT/.cursor/rules/engineering-governance.mdc"
SRC_MAP="$ROOT/templates/account-map.example.mdc"

SKIP_ACCOUNTS=0
ASSUME_YES=0
DEST=""
MODE="global"

usage() {
  sed -n '2,18p' "$0"
}

prompt_value() {
  # $1 label  $2 default
  local label="$1"
  local default="${2:-}"
  local input=""
  if [[ -n "$default" ]]; then
    printf "%s [%s]: " "$label" "$default" >&2
  else
    printf "%s: " "$label" >&2
  fi
  if [[ ! -t 0 ]]; then
    echo "$default"
    return
  fi
  IFS= read -r input || true
  if [[ -z "$input" ]]; then
    echo "$default"
  else
    echo "$input"
  fi
}

write_account_map() {
  local dest_file="$1"
  local github="$2"
  local supabase="$3"
  local vercel="$4"
  local scope_line="$5"

  cat >"$dest_file" <<EOF
---
description: Service account map (identity only — no passwords or API keys)
alwaysApply: true
---

# Account map

${scope_line}

Do not put passwords or API keys here — account identity only.

\`\`\`text
GitHub:    ${github}
Supabase:  ${supabase}
Vercel:    ${vercel}
\`\`\`

Before creating or changing external resources, verify the logged-in CLI/console account matches this map.

Never hard-code these values into application source code.
EOF
}

collect_accounts() {
  local github supabase vercel

  echo "" >&2
  echo "Account map (email or account id only — never passwords/API keys)" >&2
  echo "Leave blank to keep placeholder; you can edit account-map.mdc later." >&2
  echo "" >&2

  github="${GITHUB_ACCOUNT:-}"
  supabase="${SUPABASE_ACCOUNT:-}"
  vercel="${VERCEL_ACCOUNT:-}"

  if [[ "$ASSUME_YES" -eq 1 ]]; then
    github="${github:-YOUR_GITHUB_ACCOUNT_OR_EMAIL}"
    supabase="${supabase:-YOUR_SUPABASE_ACCOUNT_OR_EMAIL}"
    vercel="${vercel:-YOUR_VERCEL_ACCOUNT_OR_EMAIL}"
  else
    github="$(prompt_value "GitHub account/email" "${github}")"
    supabase="$(prompt_value "Supabase account/email" "${supabase}")"
    vercel="$(prompt_value "Vercel account/email" "${vercel}")"
    [[ -z "$github" ]] && github="YOUR_GITHUB_ACCOUNT_OR_EMAIL"
    [[ -z "$supabase" ]] && supabase="YOUR_SUPABASE_ACCOUNT_OR_EMAIL"
    [[ -z "$vercel" ]] && vercel="YOUR_VERCEL_ACCOUNT_OR_EMAIL"
  fi

  GITHUB_VAL="$github"
  SUPABASE_VAL="$supabase"
  VERCEL_VAL="$vercel"
}

if [[ ! -f "$SRC_RULE" ]]; then
  echo "error: missing $SRC_RULE" >&2
  exit 1
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help|-h )
      usage
      exit 0
      ;;
    --skip-accounts )
      SKIP_ACCOUNTS=1
      shift
      ;;
    --yes|-y )
      ASSUME_YES=1
      shift
      ;;
    --project )
      MODE="project"
      DEST="$(pwd)/.cursor/rules"
      shift
      ;;
    --global )
      MODE="global"
      DEST="${HOME}/.cursor/rules"
      shift
      ;;
    * )
      if [[ -z "$DEST" && "$1" != -* ]]; then
        MODE="custom"
        DEST="$1"
        shift
      else
        echo "error: unknown option: $1" >&2
        usage
        exit 1
      fi
      ;;
  esac
done

if [[ -z "$DEST" ]]; then
  DEST="${HOME}/.cursor/rules"
  MODE="global"
fi

mkdir -p "$DEST"
cp "$SRC_RULE" "$DEST/engineering-governance.mdc"
echo "installed: $DEST/engineering-governance.mdc"

MAP_FILE="$DEST/account-map.mdc"
GITHUB_VAL=""
SUPABASE_VAL=""
VERCEL_VAL=""

if [[ "$SKIP_ACCOUNTS" -eq 1 ]]; then
  if [[ ! -f "$MAP_FILE" ]]; then
    cp "$SRC_MAP" "$MAP_FILE"
    echo "installed: $MAP_FILE  (placeholders — edit later or re-run without --skip-accounts)"
  else
    echo "skip: $MAP_FILE already exists (--skip-accounts)"
  fi
else
  if [[ -f "$MAP_FILE" && "$ASSUME_YES" -ne 1 ]]; then
    echo ""
    echo "Found existing: $MAP_FILE"
    if [[ -t 0 ]]; then
      printf "Overwrite account map? [y/N]: "
      IFS= read -r ans || true
      case "${ans:-}" in
        y|Y|yes|YES ) ;;
        * )
          echo "kept existing account-map.mdc"
          echo "done. Restart Cursor or start a new Agent chat so rules reload."
          exit 0
          ;;
      esac
    else
      echo "skip: non-interactive and account-map exists (use --yes to overwrite)"
      echo "done. Restart Cursor or start a new Agent chat so rules reload."
      exit 0
    fi
  fi

  collect_accounts

  case "$MODE" in
    project )
      SCOPE="Filled for **this project**. Project map overrides a user-global map when both exist."
      ;;
    global )
      SCOPE="Filled for **this Cursor user (all projects)**. Prefer a project-level map when accounts differ per repo."
      ;;
    * )
      SCOPE="Filled for this install destination."
      ;;
  esac

  write_account_map "$MAP_FILE" "$GITHUB_VAL" "$SUPABASE_VAL" "$VERCEL_VAL" "$SCOPE"
  echo "installed: $MAP_FILE"
  echo "  GitHub:   $GITHUB_VAL"
  echo "  Supabase: $SUPABASE_VAL"
  echo "  Vercel:   $VERCEL_VAL"
fi

echo "done. Restart Cursor or start a new Agent chat so rules reload."
