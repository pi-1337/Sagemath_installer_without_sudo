#!/bin/bash

# All-in-one SageMath installer without sudo
# Save this as install_sage.sh and run: bash install_sage.sh

set -e  # Exit on any error

echo "=== SageMath Installer ==="
echo "Installing to: /goinfre/$(whoami)/"

# Set installation directory
INSTALL_DIR="/goinfre/$(whoami)/sage_install"
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

echo "Installation directory: $INSTALL_DIR"

# Step 1: Install Miniconda
echo "Step 1: Installing Miniconda..."
if [ ! -d "miniconda" ]; then
    if command -v wget >/dev/null 2>&1; then
        wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
    elif command -v curl >/dev/null 2>&1; then
        curl -s https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o miniconda.sh
    else
        echo "Error: Neither wget nor curl available. Please install one of them."
        exit 1
    fi
    
    bash miniconda.sh -b -p "$INSTALL_DIR/miniconda"
    rm miniconda.sh
fi

# Add conda to PATH
export PATH="$INSTALL_DIR/miniconda/bin:$PATH"

# Initialize conda
source "$INSTALL_DIR/miniconda/bin/activate"

# Step 2: Accept Terms of Service
echo "Step 2: Accepting Terms of Service..."
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

# Step 3: Create Sage environment
echo "Step 3: Creating Sage environment..."
conda create -n sage python=3.11 -y

# Step 4: Install Sage
echo "Step 4: Installing SageMath (this may take a while)..."
conda activate sage
conda install -c conda-forge sage -y

# Step 5: Create startup script
echo "Step 5: Creating startup script..."
cat > "$INSTALL_DIR/start_sage.sh" << 'EOF'
#!/bin/bash
export PATH="$(dirname "$0")/miniconda/bin:$PATH"
source "$(dirname "$0")/miniconda/bin/activate"
conda activate sage
sage "$@"
EOF

chmod +x "$INSTALL_DIR/start_sage.sh"

# Step 6: Create desktop shortcut
cat > "$INSTALL_DIR/sage_desktop.sh" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
export PATH="./miniconda/bin:$PATH"
source ./miniconda/bin/activate
conda activate sage
echo "Starting SageMath..."
echo "To use Sage in the future, run: $PWD/start_sage.sh"
sage
EOF

chmod +x "$INSTALL_DIR/sage_desktop.sh"

# Step 7: Test installation
echo "Step 7: Testing installation..."
"$INSTALL_DIR/start_sage.sh" --version

echo ""
echo "=== Installation Complete! ==="
echo "SageMath has been installed to: $INSTALL_DIR"
echo ""
echo "To start SageMath, run:"
echo "  $INSTALL_DIR/start_sage.sh"
echo ""
echo "Or run the desktop version:"
echo "  $INSTALL_DIR/sage_desktop.sh"
echo ""
echo "Add this to your ~/.bashrc or ~/.zshrc to make sage available everywhere:"
echo "export PATH=\"$INSTALL_DIR/miniconda/bin:\$PATH\""
echo "source $INSTALL_DIR/miniconda/bin/activate"
echo "conda activate sage"
