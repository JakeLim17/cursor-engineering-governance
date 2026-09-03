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
#   SOURCE_CONTROL_ACCOUNT=you@example.com \
#   HOSTING_ACCOUNT=you@example.com \
#   DATABASE_ACCOUNT=you@example.com \
#   CLOUD_ACCOUNT= \
#   CDN_ACCOUNT= \
#   ./install.sh --yes
#
# Env overrides (v1.1+): SOURCE_CONTROL_ACCOUNT, HOSTING_ACCOUNT, DATABASE_ACCOUNT,
#   CLOUD_ACCOUNT, CDN_ACCOUNT
# Backward compat (v1.0): GITHUB_ACCOUNT → SOURCE_CONTROL_ACCOUNT,
#   VERCEL_ACCOUNT → HOSTING_ACCOUNT, SUPABASE_ACCOUNT → DATABASE_ACCOUNT

set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
SRC_RULE="$ROOT/.cursor/rules/engineering-governance.mdc"
SRC_MAP="$ROOT/templates/account-map.example.mdc"

SKIP_ACCOUNTS=0
ASSUME_YES=0
DEST=""
MODE="global"

usage() {
  sed -n '2,22p' "$0"
}

prompt_value() {
  # $1 label  $2 default  $3 optional hint (e.g. "Enter to skip")
  local label="$1"
  local default="${2:-}"
  local hint="${3:-}"
  local input=""
  if [[ -n "$hint" ]]; then
    if [[ -n "$default" ]]; then
      printf "%s [%s] (%s): " "$label" "$default" "$hint" >&2
    else
      printf "%s (%s): " "$label" "$hint" >&2
    fi
  elif [[ -n "$default" ]]; then
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

resolve_account_env() {
  # $1 new env name  $2 legacy env name
  local new_val="${!1:-}"
  local legacy_val="${!2:-}"
  if [[ -n "$new_val" ]]; then
    echo "$new_val"
  else
    echo "$legacy_val"
  fi
}

write_account_map() {
  local dest_file="$1"
  local source_control="$2"
  local hosting="$3"
  local database="$4"
  local cloud="$5"
  local cdn="$6"
  local scope_line="$7"

  cat >"$dest_file" <<EOF
---
description: Service account map (identity only — no passwords or API keys)
alwaysApply: true
---

# Account map

${scope_line}

Do not put passwords or API keys here — account identity only.
Leave a row blank if this install does not use that provider.

\`\`\`text
Source control:   GitHub / GitLab / Bitbucket           → ${source_control}
Hosting/Deploy:   Vercel / Netlify / Railway / Render    → ${hosting}
Database/BaaS:    Supabase / Firebase / PlanetScale / Neon → ${database}
Cloud:            AWS / GCP / Azure                      → ${cloud}
CDN/Edge:         Cloudflare                              → ${cdn}
\`\`\`

Before creating or changing external resources, verify the logged-in CLI/console account matches this map.
If a category is blank, treat it as **unverified** — confirm the correct account with the user before modifying that provider.

Never hard-code these values into application source code.
EOF
}

collect_accounts() {
  local source_control hosting database cloud cdn

  echo "" >&2
  echo "Account map (email or account id only — never passwords/API keys)" >&2
  echo "Leave blank to leave that category unverified; edit account-map.mdc later." >&2
  echo "" >&2

  source_control="$(resolve_account_env SOURCE_CONTROL_ACCOUNT GITHUB_ACCOUNT)"
  hosting="$(resolve_account_env HOSTING_ACCOUNT VERCEL_ACCOUNT)"
  database="$(resolve_account_env DATABASE_ACCOUNT SUPABASE_ACCOUNT)"
  cloud="${CLOUD_ACCOUNT:-}"
  cdn="${CDN_ACCOUNT:-}"

  if [[ "$ASSUME_YES" -eq 1 ]]; then
    : # use env values as-is (empty allowed)
  else
    source_control="$(prompt_value "Source control (GitHub/GitLab/Bitbucket)" "${source_control}")"
    hosting="$(prompt_value "Hosting/Deploy (Vercel/Netlify/Railway/Render)" "${hosting}")"
    database="$(prompt_value "Database/BaaS (Supabase/Firebase/PlanetScale/Neon)" "${database}")"
    cloud="$(prompt_value "Cloud (AWS/GCP/Azure)" "${cloud}" "Enter to skip")"
    cdn="$(prompt_value "CDN/Edge (Cloudflare)" "${cdn}" "Enter to skip")"
  fi

  SOURCE_CONTROL_VAL="$source_control"
  HOSTING_VAL="$hosting"
  DATABASE_VAL="$database"
  CLOUD_VAL="$cloud"
  CDN_VAL="$cdn"
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
SOURCE_CONTROL_VAL=""
HOSTING_VAL=""
DATABASE_VAL=""
CLOUD_VAL=""
CDN_VAL=""

if [[ "$SKIP_ACCOUNTS" -eq 1 ]]; then
  if [[ ! -f "$MAP_FILE" ]]; then
    cp "$SRC_MAP" "$MAP_FILE"
    echo "installed: $MAP_FILE  (blank rows — edit later or re-run without --skip-accounts)"
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

  write_account_map "$MAP_FILE" "$SOURCE_CONTROL_VAL" "$HOSTING_VAL" "$DATABASE_VAL" "$CLOUD_VAL" "$CDN_VAL" "$SCOPE"
  echo "installed: $MAP_FILE"
  echo "  Source control: $SOURCE_CONTROL_VAL"
  echo "  Hosting/Deploy: $HOSTING_VAL"
  echo "  Database/BaaS:  $DATABASE_VAL"
  echo "  Cloud:          $CLOUD_VAL"
  echo "  CDN/Edge:       $CDN_VAL"
fi

echo "done. Restart Cursor or start a new Agent chat so rules reload."
