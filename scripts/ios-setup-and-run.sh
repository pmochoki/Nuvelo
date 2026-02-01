#!/usr/bin/env bash
# InterHungary iOS setup: Homebrew → Flutter → Xcode path → run app
# Run this in Terminal (you may be asked for your Mac password once).

set -e
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MOBILE_DIR="$PROJECT_ROOT/mobile"

echo "=== InterHungary iOS setup ==="
echo "Project: $PROJECT_ROOT"
echo ""

# 1. Homebrew
if ! command -v brew &>/dev/null; then
  echo ">>> Installing Homebrew (you will be asked for your Mac password and to press RETURN)..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add Homebrew to PATH for this script (Apple Silicon or Intel)
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  echo "Homebrew installed."
else
  echo ">>> Homebrew already installed."
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

# 2. Flutter
if ! command -v flutter &>/dev/null; then
  echo ">>> Installing Flutter (this may take a few minutes)..."
  brew install --cask flutter
  echo "Flutter installed."
else
  echo ">>> Flutter already installed."
fi

# 3. Xcode command-line path (so Flutter can use iOS simulators)
if [[ -d /Applications/Xcode.app ]]; then
  echo ">>> Pointing command-line tools to Xcode (password may be required)..."
  sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
  echo "Xcode path set."
else
  echo ">>> Xcode.app not found in /Applications. Install Xcode from the App Store, open it once, then run this script again."
fi

# 4. Flutter doctor
echo ""
echo ">>> Flutter doctor:"
flutter doctor -v

# 5. Run the app
echo ""
echo ">>> Getting dependencies and running InterHungary app..."
cd "$MOBILE_DIR"
flutter pub get
flutter run
