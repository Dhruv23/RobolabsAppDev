#!/bin/bash

set -e

REPO_URL="https://github.com/dhruv23/RobolabsAppDev.git"
DEPLOY_PARENT="../html_inventory"
DEPLOY_DIR="$DEPLOY_PARENT/RobolabsAppDev"
BUILD_DIR="build/web"

echo "🚿 Cleaning build..."
flutter clean

echo "📦 Getting packages..."
flutter pub get

echo "🌐 Building web app with correct base href..."
flutter build web --base-href /RobolabsAppDev/

echo "🧼 Removing old deploy folder..."
rm -rf "$DEPLOY_DIR"

echo "🌀 Cloning fresh gh-pages branch..."
git clone --branch gh-pages "$REPO_URL" "$DEPLOY_DIR"

echo "📁 Copying new web build to deployment directory..."
cp -r "$BUILD_DIR"/* "$DEPLOY_DIR"

cd "$DEPLOY_DIR"

echo "➕ Staging changes..."
git add .

echo "✅ Committing..."
git commit -m "🚀 Deploy updated build to GitHub Pages" || echo "No changes to commit."

echo "⬆️ Force pushing to gh-pages..."
git push origin gh-pages --force

echo "✅ Deployment complete!"
echo "🌐 Visit: https://dhruv23.github.io/RobolabsAppDev/"
