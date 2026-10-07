#!/usr/bin/env bash
# Build the Flutter web app and deploy it to Firebase Hosting.
# Usage: ./deploy.sh [firebase-account-email]
set -euo pipefail
cd "$(dirname "$0")"

PROJECT="home-guard-app-51db9"
ACCOUNT_ARGS=()
if [ -n "${1:-}" ]; then ACCOUNT_ARGS=(--account "$1"); fi

flutter pub get
flutter build web --release
firebase deploy --only hosting --project "$PROJECT" "${ACCOUNT_ARGS[@]+"${ACCOUNT_ARGS[@]}"}"

echo "Live at https://$PROJECT.web.app"
