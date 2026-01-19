#!/bin/bash
# Hetzner Server Setup for Ralph Wiggum Loop
# Usage: curl -fsSL <raw-url> | bash
#    or: chmod +x hetzner-setup.sh && ./hetzner-setup.sh

set -e

echo "=== Hetzner Build Server Setup ==="
echo ""

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "Cannot detect OS"
    exit 1
fi

echo "Detected OS: $OS"
echo ""

# --- 1. System packages ---
echo "=== Installing system packages ==="
if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
    sudo apt update
    sudo apt install -y \
        curl \
        wget \
        unzip \
        git \
        openjdk-17-jdk \
        build-essential
elif [ "$OS" = "fedora" ] || [ "$OS" = "centos" ] || [ "$OS" = "rhel" ]; then
    sudo dnf install -y \
        curl \
        wget \
        unzip \
        git \
        java-17-openjdk-devel \
        gcc \
        make
else
    echo "Unsupported OS: $OS"
    echo "Please install manually: curl, wget, unzip, git, JDK 17"
fi

echo ""
echo "Java version:"
java -version
echo ""

# --- 2. Android SDK ---
echo "=== Setting up Android SDK ==="

ANDROID_HOME="$HOME/android-sdk"
CMDLINE_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"

if [ ! -d "$ANDROID_HOME" ]; then
    echo "Downloading Android command-line tools..."
    mkdir -p "$ANDROID_HOME"
    cd /tmp
    wget -q "$CMDLINE_TOOLS_URL" -O cmdline-tools.zip
    unzip -q cmdline-tools.zip
    mkdir -p "$ANDROID_HOME/cmdline-tools"
    mv cmdline-tools "$ANDROID_HOME/cmdline-tools/latest"
    rm cmdline-tools.zip
    cd -
    echo "Android SDK installed to $ANDROID_HOME"
else
    echo "Android SDK already exists at $ANDROID_HOME"
fi

# --- 3. Environment variables ---
echo "=== Setting up environment variables ==="

SHELL_RC="$HOME/.bashrc"
if [ -n "$ZSH_VERSION" ] || [ -f "$HOME/.zshrc" ]; then
    SHELL_RC="$HOME/.zshrc"
fi

# Add to shell config if not already present
if ! grep -q "ANDROID_HOME" "$SHELL_RC" 2>/dev/null; then
    cat >> "$SHELL_RC" << 'EOF'

# Android SDK
export ANDROID_HOME="$HOME/android-sdk"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
export PATH="$PATH:$ANDROID_HOME/emulator"
EOF
    echo "Added Android environment variables to $SHELL_RC"
else
    echo "Android environment variables already in $SHELL_RC"
fi

# Source for current session
export ANDROID_HOME="$HOME/android-sdk"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
export PATH="$PATH:$ANDROID_HOME/platform-tools"

# --- 4. Android SDK packages ---
echo "=== Installing Android SDK packages ==="
echo "Accepting licenses..."
yes | sdkmanager --licenses > /dev/null 2>&1 || true

echo "Installing platform tools and SDK..."
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"

echo ""
echo "Android SDK setup complete!"
echo ""

# --- 5. Claude CLI ---
echo "=== Claude CLI ==="
if command -v claude &> /dev/null; then
    echo "Claude CLI already installed:"
    claude --version
else
    echo "Installing Claude CLI..."
    curl -fsSL https://claude.ai/install.sh | sh

    # Add to PATH if needed
    if [ -d "$HOME/.claude/bin" ]; then
        export PATH="$PATH:$HOME/.claude/bin"
        if ! grep -q ".claude/bin" "$SHELL_RC" 2>/dev/null; then
            echo 'export PATH="$PATH:$HOME/.claude/bin"' >> "$SHELL_RC"
        fi
    fi
fi

echo ""

# --- 6. SSH key for GitHub ---
echo "=== SSH Key Setup ==="
SSH_KEY="$HOME/.ssh/id_ed25519"
if [ ! -f "$SSH_KEY" ]; then
    echo "Generating new SSH key..."
    ssh-keygen -t ed25519 -C "hetzner-build-server" -f "$SSH_KEY" -N ""
    echo ""
    echo "Add this public key to GitHub (Settings → SSH Keys):"
    echo "---"
    cat "${SSH_KEY}.pub"
    echo "---"
else
    echo "SSH key already exists."
    echo "Public key:"
    echo "---"
    cat "${SSH_KEY}.pub"
    echo "---"
fi

echo ""
echo "=== Setup Summary ==="
echo ""
echo "Installed:"
echo "  - JDK $(java -version 2>&1 | head -1)"
echo "  - Android SDK at $ANDROID_HOME"
echo "  - Claude CLI: $(command -v claude || echo 'needs authentication')"
echo ""
echo "=== Next Steps ==="
echo ""
echo "1. Source your shell config:"
echo "   source $SHELL_RC"
echo ""
echo "2. Add SSH key to GitHub (printed above)"
echo ""
echo "3. Authenticate Claude CLI:"
echo "   claude login"
echo ""
echo "4. Clone your repo:"
echo "   git clone git@github.com:YOUR_USER/YOUR_REPO.git"
echo "   cd YOUR_REPO"
echo ""
echo "5. Test the build:"
echo "   ./gradlew build -x iosTest -x linkDebugTestIosX64"
echo ""
echo "6. Run the loop:"
echo "   ./loop.sh plan 1"
echo "   ./loop.sh build"
echo ""
echo "=== Done ==="
