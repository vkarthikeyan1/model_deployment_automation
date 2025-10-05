#!/bin/bash
export HF_TOKEN=$1

INSTALL_DIR="$HOME/venv"

echo "==== Installing Python & venv environment ===="

# Ensure Python is installed
if ! command -v python3 &> /dev/null; then
    echo "Python3 not found. Installing..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update -y
        sudo apt-get install -y python3 python3-venv python3-pip
    else
        echo "Error: Could not find a supported package manager (apt, dnf, yum)." >&2
        exit 1
    fi
fi

# Create a clean virtual environment
echo "Creating virtual environment in $INSTALL_DIR ..."
rm -rf "$INSTALL_DIR"
python3 -m venv "$INSTALL_DIR"

# Activate venv
echo "Activating virtual environment..."
source "$INSTALL_DIR/bin/activate"

echo "Python version:"
python --version
echo "Pip version:"
pip --version

echo "==== Installing Git ===="

if command -v apt-get &> /dev/null; then
    echo "Detected apt package manager. Updating package list..."
    sudo apt-get update -y
    echo "Installing Git..."
    sudo apt-get install git -y
else
    echo "Error: Could not find a supported package manager (apt, dnf, yum)." >&2
    deactivate
    exit 1
fi

if command -v git &> /dev/null; then
    echo "Git has been successfully installed."
    git --version
else
    echo "Git installation failed." >&2
    deactivate
    exit 1
fi

# Run App
echo "==== Cloning and running the app ===="

git clone https://github.com/Thameem022/mlops-cs-1.git
cd ./mlops-cs-1 || exit 1

pip install --upgrade pip
pip install -r requirements.txt

nohup python app.py > my.log 2>&1 < /dev/null &

echo "------ App Running in background ------"
echo "Log file: $(pwd)/my.log"
