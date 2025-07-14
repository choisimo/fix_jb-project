#!/bin/bash

echo "=== Cleaning old generated files ==="
find . -name "*.freezed.dart" -type f -delete
find . -name "*.g.dart" -type f -delete

echo "=== Cleaning build cache ==="
rm -rf .dart_tool/build

echo "=== Cleaning Flutter ==="
flutter clean

echo "=== Getting dependencies ==="
flutter pub get

echo "=== Testing with simple model first ==="
dart run build_runner build --build-filter="lib/test/simple_model.dart" --delete-conflicting-outputs

if [ $? -eq 0 ]; then
    echo "=== Simple model succeeded, running full build ==="
    dart run build_runner build --delete-conflicting-outputs
else
    echo "=== Build failed, checking verbose output ==="
    dart run build_runner build --delete-conflicting-outputs --verbose
fi
