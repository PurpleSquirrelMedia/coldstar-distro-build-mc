#!/bin/bash
# ColdStar One-Line Installer (Docker version)
# curl -fsSL https://raw.githubusercontent.com/PurpleSquirrelMedia/coldstar-distro-build-mc/main/scripts/install-docker.sh | bash

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║              COLDSTAR INSTALLER (Docker Edition)              ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check for Docker
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}Docker not found. Installing...${NC}"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "Please install Docker Desktop from: https://docs.docker.com/desktop/mac/install/"
        exit 1
    else
        curl -fsSL https://get.docker.com | sh
        sudo usermod -aG docker $USER
        echo "Please log out and back in for Docker permissions to take effect."
    fi
fi

# Pull the image
echo "Pulling ColdStar Docker image..."
docker pull ghcr.io/purplesquirrelmedia/coldstar:latest 2>/dev/null || {
    echo "Pre-built image not available. Building locally..."
    git clone https://github.com/PurpleSquirrelMedia/coldstar-distro-build-mc.git /tmp/coldstar
    cd /tmp/coldstar
    docker build -t coldstar:local .
}

# Install wrapper script
INSTALL_DIR="/usr/local/bin"
if [ ! -w "$INSTALL_DIR" ]; then
    INSTALL_DIR="$HOME/.local/bin"
    mkdir -p "$INSTALL_DIR"
fi

cat > "$INSTALL_DIR/coldstar" << 'WRAPPER'
#!/bin/bash
docker run -it --rm --privileged -v /dev:/dev -e TERM=xterm-256color \
    ghcr.io/purplesquirrelmedia/coldstar:latest 2>/dev/null || \
    docker run -it --rm --privileged -v /dev:/dev -e TERM=xterm-256color coldstar:local "$@"
WRAPPER
chmod +x "$INSTALL_DIR/coldstar"

echo -e "${GREEN}"
echo "✓ ColdStar installed successfully!"
echo ""
echo "Run with: coldstar"
echo -e "${NC}"

# Add to PATH if needed
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo "Add this to your shell profile:"
    echo "  export PATH=\"\$PATH:$INSTALL_DIR\""
fi
