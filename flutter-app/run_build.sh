#!/bin/bash

echo "=== Cleaning generated files ==="
find . -name "*.freezed.dart" -type f -delete
find . -name "*.g.dart" -type f -delete

echo "=== Cleaning Flutter cache ==="
flutter clean

echo "=== Getting dependencies ==="
flutter pub get

echo "=== Running code generation ==="
dart run build_runner build --delete-conflicting-outputs

echo "=== Running analysis ==="
flutter analyze

echo "=== Build process completed! ==="
