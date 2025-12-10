#!/bin/bash
# setup_mlnode.sh - Complete 4×A40 MLNode Setup
# Repository: https://github.com/mrm88/MLNODE

set -e

echo "========================================="
echo "Gonka MLNode Complete Setup - 4×A40"
echo "========================================="

# Update system and install dependencies
echo "Installing system dependencies..."
apt-get update
apt-get install -y git screen sqlite3 jq curl pkg-config libsecp256k1-dev

# Upgrade pip
python3.12 -m pip install --upgrade pip

# Install Python packages
echo "Installing Python packages..."
pip install git+https://github.com/product-science/compressa-perf.git --break-system-packages
pip install toml fire sentencepiece tiktoken fairscale h2 httpx[http2] --break-system-packages

# Clone/update scripts
echo "Setting up scripts repository..."
cd /data
if [ ! -d "/data/gonka-scripts" ]; then
    git clone https://github.com/mrm88/MLNODE.git gonka-scripts
else
    cd gonka-scripts
    git pull origin main
    cd /data
fi

# Download and extract Gonka MLNode app
if [ ! -d "/data/app" ]; then
    echo "Downloading Gonka MLNode application..."
    cd /data
    wget https://github.com/mrm88/MLNODE/releases/download/V1/gonka-mlnode-app.tar.gz
    
    echo "Extracting application..."
    tar -xzf gonka-mlnode-app.tar.gz
    rm gonka-mlnode-app.tar.gz
    
    echo "Verifying extraction..."
    ls -la app/
    ls -la app/packages/
fi

# Create logs directory
mkdir -p /data/logs

echo "========================================="
echo "Setup complete! Ready to start services"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Start vLLM: bash /data/gonka-scripts/start_vllm.sh"
echo "2. Start Gonka API: bash /data/gonka-scripts/start_gonka_api.sh"
echo "3. Register node: bash /data/gonka-scripts/register_node.sh"
