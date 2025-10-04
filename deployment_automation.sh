#!/bin/bash

INSTALL_DIR="$HOME/miniconda3"

echo "Downloading Miniconda installer"
curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh


echo "Installing Miniconda to $INSTALL_DIR..."
bash miniconda.sh -b -p "$INSTALL_DIR"


export PATH="$INSTALL_DIR/bin:$PATH"

echo "Initializing Conda..."
conda init bash



echo "Applying changes to current shell..."
source ~/.bashrc

echo "----Miniconda is installed and ready to use in this terminal."

echo "Verifying installation..."
conda --version


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
    echo " Git has been successfully installed."
    git --version
else
    echo " Git installation failed." >&2
    exit 1
fi


# Run App

git clone https://github.com/Thameem022/mlops-cs-1.git

cd ./mlops-cs-1

pip install -r requirements.txt

nohup python app.py > my.log 2>&1 < /dev/null &

echo "------App Running------"
