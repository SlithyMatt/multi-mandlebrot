#!/bin/bash
# Builds Mandelbrot.app for Apple Silicon. Requires only the Xcode Command Line Tools.
set -e
cd "$(dirname "$0")"

APP=Mandelbrot.app
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
swiftc -O -target arm64-apple-macos14.0 -o "$APP/Contents/MacOS/Mandelbrot" main.swift
cp Info.plist "$APP/Contents/"
codesign --force --sign - "$APP"
echo "Built $APP - run with: open $APP"
