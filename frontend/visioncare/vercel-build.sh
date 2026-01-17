#!/bin/bash
set -e

# Install Flutter
curl -fsSL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.22.3-stable.tar.xz | tar xJ

# Mark Flutter as safe for git
git config --global --add safe.directory "$PWD/flutter"

# Add Flutter to PATH
export PATH="$PATH:$PWD/flutter/bin"

# Disable analytics (CI-safe)
flutter config --no-analytics

# Build Flutter web
flutter build web --release
