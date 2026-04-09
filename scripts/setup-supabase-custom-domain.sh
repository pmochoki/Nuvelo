#!/usr/bin/env bash
# Run ON YOUR MACHINE after: npm i -g supabase && supabase login
# We cannot run this for you — it needs your Supabase org + DNS access.
#
# Docs: https://supabase.com/docs/guides/platform/custom-domains
#
# Requires: paid Supabase plan + Custom Domain add-on enabled for the project.

set -euo pipefail

# Nuvelo — override if needed
export PROJECT_REF="${PROJECT_REF:-ahiujuljjbozmfwoqtli}"
export CUSTOM_HOST="${CUSTOM_HOST:-api.nuvelo.one}"

if ! command -v supabase >/dev/null 2>&1; then
  echo "Install the CLI first: npm i -g supabase"
  exit 1
fi

echo "Project: $PROJECT_REF"
echo "Custom hostname: $CUSTOM_HOST"
echo ""

case "${1:-create}" in
  create)
    echo "=== Step 1: Register domain with Supabase (prints DNS records) ==="
    supabase domains create --project-ref "$PROJECT_REF" --custom-hostname "$CUSTOM_HOST"
    echo ""
    echo "Next: add the CNAME and TXT records at your DNS provider for nuvelo.one"
    echo "Then run:  PROJECT_REF=$PROJECT_REF CUSTOM_HOST=$CUSTOM_HOST $0 reverify"
    ;;
  reverify)
    echo "=== Step 2: Verify DNS + SSL (run until successful) ==="
    supabase domains reverify --project-ref "$PROJECT_REF"
    ;;
  activate)
    echo "=== Step 3: Activate custom domain ==="
    supabase domains activate --project-ref "$PROJECT_REF"
    echo ""
    echo "Then:"
    echo "  1. Vercel → set VITE_SUPABASE_URL=https://$CUSTOM_HOST (same anon key) → Redeploy"
    echo "  2. Google Cloud OAuth → add https://$CUSTOM_HOST/auth/v1/callback"
    ;;
  *)
    echo "Usage: $0 [create|reverify|activate]"
    exit 1
    ;;
esac
