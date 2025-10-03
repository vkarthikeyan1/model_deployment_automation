#!/bin/bash
set -euo pipefail

INSTALL_DIR="$HOME/miniconda3"

echo "=== Checking Miniconda installation ==="
if [ ! -d "$INSTALL_DIR" ]; then
    echo "Downloading Miniconda installer..."
    curl -fsSL -o miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    bash miniconda.sh -b -p "$INSTALL_DIR"
    rm miniconda.sh
fi

export PATH="$INSTALL_DIR/bin:$PATH"

echo "Verifying conda installation..."
conda --version

echo "=== Checking Git installation ==="
if ! command -v git &> /dev/null; then
    if command -v apt-get &> /dev/null; then
        sudo apt-get update -y && sudo apt-get install git -y
    else
        echo "No supported package manager found." >&2
        exit 1
    fi
fi
echo "Git installed: $(git --version)"

# Activate conda base
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate base

echo "=== Setting up API project ==="
if [ ! -d "mlops-cs-1" ]; then
    git clone https://github.com/Thameem022/mlops-cs-1.git
fi
cd mlops-cs-1
pip install -r requirements.txt
nohup uvicorn main:app --host 0.0.0.0 --port 8000 > api.log 2>&1 < /dev/null &
cd ..

echo "=== Setting up Local project ==="
if [ ! -d "case-study-1-local" ]; then
    git clone https://github.com/Thameem022/case-study-1-local.git
fi
cd case-study-1-local
pip install -r requirements.txt
nohup python app.py > local.log 2>&1 < /dev/null &
cd ..

echo "=== API and Local are running in background"