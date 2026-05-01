#!/bin/bash

# Script to verify 16 KB page size compatibility
# Usage: ./verify_16kb.sh path/to/your/app.apk

if [ -z "$1" ]; then
    echo "Usage: $0 <path-to-apk-or-aab>"
    exit 1
fi

APP_FILE="$1"
TEMP_DIR="/tmp/apk_check_$$"

echo "Checking 16 KB compatibility for: $APP_FILE"
echo "================================================"

# Check if file exists
if [ ! -f "$APP_FILE" ]; then
    echo "Error: File not found: $APP_FILE"
    exit 1
fi

# Extract APK/AAB
mkdir -p "$TEMP_DIR"
unzip -q "$APP_FILE" -d "$TEMP_DIR"

# Find NDK path
if [ -z "$ANDROID_NDK_HOME" ]; then
    if [ -d "$HOME/Library/Android/sdk/ndk" ]; then
        NDK_VERSION=$(ls "$HOME/Library/Android/sdk/ndk" | sort -V | tail -n 1)
        ANDROID_NDK_HOME="$HOME/Library/Android/sdk/ndk/$NDK_VERSION"
    elif [ -d "$ANDROID_HOME/ndk" ]; then
        NDK_VERSION=$(ls "$ANDROID_HOME/ndk" | sort -V | tail -n 1)
        ANDROID_NDK_HOME="$ANDROID_HOME/ndk/$NDK_VERSION"
    else
        echo "Error: Cannot find Android NDK. Please set ANDROID_NDK_HOME"
        rm -rf "$TEMP_DIR"
        exit 1
    fi
fi

LLVM_OBJDUMP="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/darwin-x86_64/bin/llvm-objdump"

if [ ! -f "$LLVM_OBJDUMP" ]; then
    # Try Linux path
    LLVM_OBJDUMP="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-objdump"
fi

if [ ! -f "$LLVM_OBJDUMP" ]; then
    echo "Error: Cannot find llvm-objdump in NDK"
    rm -rf "$TEMP_DIR"
    exit 1
fi

echo "Using NDK: $ANDROID_NDK_HOME"
echo ""

# Check all .so files
SO_FILES=$(find "$TEMP_DIR" -name "*.so" -path "*/lib/arm64-v8a/*" -o -name "*.so" -path "*/lib/x86_64/*")

if [ -z "$SO_FILES" ]; then
    echo "No native libraries found. Your app is already 16 KB compatible!"
    rm -rf "$TEMP_DIR"
    exit 0
fi

FAILED=0
PASSED=0

echo "Checking ELF alignment for native libraries:"
echo "--------------------------------------------"

for SO_FILE in $SO_FILES; do
    RELATIVE_PATH=$(echo "$SO_FILE" | sed "s|$TEMP_DIR/||")
    echo "Checking: $RELATIVE_PATH"
    
    ALIGNMENT=$("$LLVM_OBJDUMP" -p "$SO_FILE" | grep "LOAD" | awk '{print $NF}' | sort -u)
    
    HAS_SMALL_ALIGNMENT=0
    for ALIGN in $ALIGNMENT; do
        if [[ "$ALIGN" =~ 2\*\*([0-9]+) ]]; then
            POWER="${BASH_REMATCH[1]}"
            if [ "$POWER" -lt 14 ]; then
                echo "  ❌ UNALIGNED: Found alignment $ALIGN (need 2**14 or higher)"
                HAS_SMALL_ALIGNMENT=1
            fi
        fi
    done
    
    if [ $HAS_SMALL_ALIGNMENT -eq 0 ]; then
        echo "  ✅ ALIGNED: All segments properly aligned"
        PASSED=$((PASSED + 1))
    else
        FAILED=$((FAILED + 1))
    fi
    echo ""
done

# Cleanup
rm -rf "$TEMP_DIR"

echo "================================================"
echo "Summary:"
echo "  Passed: $PASSED"
echo "  Failed: $FAILED"
echo ""

if [ $FAILED -gt 0 ]; then
    echo "❌ Your app is NOT 16 KB compatible!"
    echo "Please rebuild with the updated configuration."
    exit 1
else
    echo "✅ Your app is 16 KB compatible!"
    exit 0
fi
