#!/usr/bin/env bash
set -euxo pipefail

FLUTTER_VERSION="3.29.3"
FLUTTER_ARCHIVE="flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"

# Download flutter SDK if not cached by Vercel
if [ ! -d "flutter" ]; then
  curl -L "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/${FLUTTER_ARCHIVE}" -o flutter_sdk.tar.xz
  tar xf flutter_sdk.tar.xz
  git config --global --add safe.directory "${PWD}/flutter"
fi

export PATH="${PWD}/flutter/bin:${PATH}"
flutter config --no-analytics
flutter precache --web
flutter pub get
flutter build web --release
