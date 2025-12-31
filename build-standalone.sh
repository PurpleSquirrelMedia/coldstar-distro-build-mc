#!/bin/bash
# ColdStar Standalone Build Script
# Creates a fully self-contained executable with ALL dependencies bundled
# Output: dist/coldstar (single executable, ~50-100MB)

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║           COLDSTAR STANDALONE BUILD                          ║"
echo "║     Building self-contained executable with all deps         ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check requirements
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}Error: $1 is required but not installed.${NC}"
        exit 1
    fi
}

echo -e "${YELLOW}Checking build requirements...${NC}"
check_command python3
check_command cargo
check_command pip3

# Create virtual environment for build
echo -e "${YELLOW}Setting up build environment...${NC}"
if [ ! -d "build_venv" ]; then
    python3 -m venv build_venv
fi
source build_venv/bin/activate

# Upgrade pip
pip install --upgrade pip wheel setuptools

# Install dependencies
echo -e "${YELLOW}Installing Python dependencies...${NC}"
pip install -r local_requirements.txt
pip install solana solders
pip install pyinstaller

# Build Rust library
echo -e "${YELLOW}Building Rust secure signer...${NC}"
if [ -d "secure_signer" ]; then
    cd secure_signer
    cargo build --release
    cd ..

    # Copy library to accessible location
    if [ -f "secure_signer/target/release/libsolana_secure_signer.dylib" ]; then
        cp secure_signer/target/release/libsolana_secure_signer.dylib .
    elif [ -f "secure_signer/target/release/libsolana_secure_signer.so" ]; then
        cp secure_signer/target/release/libsolana_secure_signer.so .
    fi
fi

# Build with PyInstaller
echo -e "${YELLOW}Building standalone executable with PyInstaller...${NC}"
pyinstaller --clean coldstar.spec

# Verify build
if [ -f "dist/coldstar" ]; then
    echo -e "${GREEN}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                    BUILD SUCCESSFUL!                          ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"

    # Get file size
    SIZE=$(du -h dist/coldstar | cut -f1)
    echo -e "Executable: ${GREEN}dist/coldstar${NC} ($SIZE)"
    echo ""
    echo "To run:"
    echo "  ./dist/coldstar"
    echo ""
    echo "To distribute:"
    echo "  1. Copy dist/coldstar to target machine"
    echo "  2. chmod +x coldstar"
    echo "  3. ./coldstar"
    echo ""
    echo -e "${YELLOW}No Python, Rust, or packages needed on target machine!${NC}"
else
    echo -e "${RED}Build failed! Check errors above.${NC}"
    exit 1
fi

# Create distributable archive
echo -e "${YELLOW}Creating distribution archive...${NC}"
PLATFORM=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
VERSION="1.1.0"
ARCHIVE_NAME="coldstar-${VERSION}-${PLATFORM}-${ARCH}"

mkdir -p "release/${ARCHIVE_NAME}"
cp dist/coldstar "release/${ARCHIVE_NAME}/"
cp README.md "release/${ARCHIVE_NAME}/" 2>/dev/null || true

cd release
if [ "$PLATFORM" = "darwin" ]; then
    zip -r "${ARCHIVE_NAME}.zip" "${ARCHIVE_NAME}"
else
    tar -czvf "${ARCHIVE_NAME}.tar.gz" "${ARCHIVE_NAME}"
fi
cd ..

echo -e "${GREEN}Distribution archive created: release/${ARCHIVE_NAME}.*${NC}"

# Cleanup
deactivate
echo -e "${GREEN}Done!${NC}"
