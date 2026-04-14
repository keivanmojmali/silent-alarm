#!/bin/bash

# Silent Alarm Build Script
# Run this to build the app without opening Xcode

echo "Building Silent Alarm..."

# Check if we have Xcode command line tools
if ! command -v swift &> /dev/null; then
    echo "Error: Swift not found. Install Xcode Command Line Tools:"
    echo "xcode-select --install"
    exit 1
fi

# Create build directory
mkdir -p build

# Compile the Swift files directly
echo "Compiling Swift files..."
swiftc -target x86_64-apple-macosx13.0 \
       -import-objc-header /System/Library/Frameworks/Cocoa.framework/Headers/Cocoa.h \
       -framework Cocoa \
       -framework SwiftUI \
       -o build/SilentAlarm \
       SilentAlarm/*.swift

if [ $? -eq 0 ]; then
    echo "✅ Build successful! Run with: ./build/SilentAlarm"
else
    echo "❌ Build failed. You'll need to use Xcode for full macOS app building."
    echo "The Swift files are ready - just open SilentAlarm.xcodeproj in Xcode"
fi