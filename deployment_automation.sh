#!/bin/bash
set -e

export HF_TOKEN=$(cat "$HOME/token.txt")

INSTALL_DIR="$HOME/miniconda3"
ENV_NAME="mlops_env_$(date +%s)"

echo "=== Checking Miniconda installation ==="
if [ ! -d "$INSTALL_DIR" ]; then
    echo "Re-downloading Miniconda installer..."
    curl -fsSL -o miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    yes | bash miniconda.sh -b -p "$INSTALL_DIR"
    rm miniconda.sh
    echo "Verifying conda installation..."
    "$INSTALL_DIR/bin/conda" --version
fi

# Initialize conda for the current shell session
echo "Initializing conda for current shell..."
source "$INSTALL_DIR/etc/profile.d/conda.sh"

# Initialize conda in ~/.bashrc for future sessions
echo "Initializing conda in ~/.bashrc..."
"$INSTALL_DIR/bin/conda" init bash

# Accept ToS if needed
echo "Accepting Anaconda Terms of Service..."
conda config --set channel_priority strict
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main 2>/dev/null || true
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r 2>/dev/null || true

echo "Creating a new environment: $ENV_NAME..."
conda create -y -n "$ENV_NAME" python=3.10

echo "Activating environment: $ENV_NAME..."
conda activate "$ENV_NAME"

echo "Environment created and activated successfully."
conda info --envs

echo "Starting Git installation..."

if command -v apt-get &> /dev/null; then
    echo "Detected apt package manager. Updating package list..."
    sudo apt-get update -y
    echo "Installing Git..."
    sudo apt-get install git -y
else
    echo "Error: Could not find a supported package manager (apt, dnf, yum)." >&2
    exit 1
fi

if command -v git &> /dev/null; then
    echo "Git has been successfully installed."
    git --version
else
    echo "Git installation failed." >&2
    exit 1
fi

# Run App
APP_DIR="$HOME/mlops-cs-1"
rm -rf "$APP_DIR"  # Clean clone
git clone https://github.com/Thameem022/mlops-cs-1.git "$APP_DIR"
cd "$APP_DIR"

pip install -r requirements.txt

echo "Starting Gradio app..."
nohup python app.py > my.log 2>&1 < /dev/null &

# Wait for app to initialize
echo "Waiting for app to start (max 20 seconds)..."
for i in {1..20}; do
    if curl -fs http://127.0.0.1:7860/ > /dev/null 2>&1; then
        echo "✅ App is running successfully on http://127.0.0.1:7860"
        exit 0
    fi
    sleep 1
done

echo "------- App failed to start on port 7860.-------"
echo "Check logs with: tail -n 20 $APP_DIR/my.log"
exit 1
