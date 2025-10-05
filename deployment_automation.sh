#!/bin/bash
export HF_TOKEN=$1

INSTALL_DIR="$HOME/miniconda3"

echo "Downloading Miniconda installer..."
curl -fsSL -o Miniconda3-latest-Linux-x86_64.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh

echo "Installing Miniconda to $INSTALL_DIR..."
rm -rf "$INSTALL_DIR"
bash Miniconda3-latest-Linux-x86_64.sh -b -p "$INSTALL_DIR"

echo "=== Checking Miniconda installation ==="
if [ ! -d "$INSTALL_DIR" ]; then
    echo "Re-downloading Miniconda installer..."
    curl -fsSL -o miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    bash miniconda.sh -b -p "$INSTALL_DIR"
    rm miniconda.sh
fi

echo "Verifying conda installation..."
"$INSTALL_DIR/bin/conda" --version



# Add conda init + base activation to ~/.bashrc (without duplication)
if ! grep -q 'conda activate base' ~/.bashrc; then
    echo "Configuring ~/.bashrc for automatic base activation..."
    {
        echo ""
        echo "# >>> conda initialize >>>"
        echo "eval \"\$($INSTALL_DIR/bin/conda shell.bash hook)\""
        echo "conda activate base"
        echo "# <<< conda initialize <<<"
    } >> ~/.bashrc
fi
# Reload bashrc so the rest of the script runs in base
echo "Reloading ~/.bashrc to enter base..."
source ~/.bashrc

echo "Now inside base environment. Continuing with script..."


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
