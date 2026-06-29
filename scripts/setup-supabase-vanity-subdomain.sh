#!/usr/bin/env bash
# Vanity subdomain on supabase.co (e.g. nuvelo.supabase.co) — included on Pro, no custom-domain add-on.
# Run ON YOUR MACHINE after: npm i -g supabase && supabase login
#
# Requires: Supabase Pro (or Team/Enterprise). Not available on the Free plan.
# Docs: https://supabase.com/docs/guides/platform/custom-domains#vanity-subdomains

set -euo pipefail

export PROJECT_REF="${PROJECT_REF:-ahiujuljjbozmfwoqtli}"
export DESIRED_SUBDOMAIN="${DESIRED_SUBDOMAIN:-nuvelo}"
export VANITY_URL="https://${DESIRED_SUBDOMAIN}.supabase.co"

if ! command -v supabase >/dev/null 2>&1; then
  echo "Install the CLI first: npm i -g supabase"
  exit 1
fi

echo "Project: $PROJECT_REF"
echo "Vanity subdomain: ${DESIRED_SUBDOMAIN}.supabase.co"
echo ""

case "${1:-check}" in
  check)
    echo "=== Check availability (needs Pro plan + Owner/Admin) ==="
    supabase vanity-subdomains --project-ref "$PROJECT_REF" check-availability \
      --desired-subdomain "$DESIRED_SUBDOMAIN" --experimental
    echo ""
    echo "If available, add OAuth redirect in each provider BEFORE activate:"
    echo "  ${VANITY_URL}/auth/v1/callback"
    echo "Keep the existing https://${PROJECT_REF}.supabase.co/auth/v1/callback during migration."
    echo ""
    echo "Then run: PROJECT_REF=$PROJECT_REF DESIRED_SUBDOMAIN=$DESIRED_SUBDOMAIN $0 activate"
    ;;
  activate)
    echo "=== Activate vanity subdomain ==="
    supabase vanity-subdomains --project-ref "$PROJECT_REF" activate \
      --desired-subdomain "$DESIRED_SUBDOMAIN" --experimental
    echo ""
    echo "After activation:"
    echo "  1. Vercel → VITE_SUPABASE_URL=$VANITY_URL (same anon key) → Redeploy"
    echo "  2. Vercel → SUPABASE_URL=$VANITY_URL (server routes, if set) → Redeploy"
    echo "  3. Google Cloud OAuth → Authorized redirect URI:"
    echo "       ${VANITY_URL}/auth/v1/callback"
    echo "  4. Meta / Apple developer consoles → same callback URL"
    echo "  5. Mobile assets/env → SUPABASE_URL=$VANITY_URL"
  ;;
  delete)
    echo "=== Remove vanity subdomain ==="
    supabase vanity-subdomains --project-ref "$PROJECT_REF" delete \
      --experimental
    ;;
  *)
    echo "Usage: $0 [check|activate|delete]"
    exit 1
    ;;
esac
