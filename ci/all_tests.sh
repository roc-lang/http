#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root_dir"

if [ -n "${ROC_HTTP_TMPDIR:-}" ]; then
    tmp_base="$ROC_HTTP_TMPDIR"
elif [ -d /private/tmp ]; then
    tmp_base=/private/tmp
else
    tmp_base="${TMPDIR:-/tmp}"
fi

tmp_dir="$tmp_base/roc-http-ci"
docs_dir="$tmp_dir/docs"
bundle_dir="$tmp_dir/bundle"

rm -rf "$tmp_dir"
mkdir -p "$docs_dir" "$bundle_dir"

echo "roc $(roc version)"

echo ""
echo "Checking format..."
roc fmt --check package examples

echo ""
echo "Checking package..."
roc check package/main.roc

echo ""
echo "Running package tests..."
roc test package/main.roc

echo ""
echo "Generating package docs..."
roc docs package/main.roc --output="$docs_dir"

echo ""
echo "Bundling package..."
scripts/bundle.sh --output-dir "$bundle_dir"

echo ""
echo "Testing examples against localhost bundle..."
python3 ci/test_bundle_examples.py
