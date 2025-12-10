#!/bin/bash
# setup_mlnode.sh - Complete 4×A40 MLNode Setup with Nginx Proxy

set -e

echo "========================================="
echo "Gonka MLNode Complete Setup - 4×A40"
echo "========================================="

# Update system and install dependencies
echo "Installing system dependencies..."
apt-get update
apt-get install -y git screen sqlite3 jq curl pkg-config libsecp256k1-dev nginx

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
    rm -f gonka-mlnode-app.tar.gz*
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

# Configure Nginx proxy (strips /v3.0.8 version prefix)
echo "Configuring Nginx reverse proxy..."
cat > /etc/nginx/sites-available/gonka-proxy <<'EOF'
server {
    listen 8080;
    server_name _;

    # Strip /vX.X.X prefix and proxy to Gonka API
    location ~ ^/v[0-9]+\.[0-9]+\.[0-9]+/(.*)$ {
        proxy_pass http://127.0.0.1:8081/$1$is_args$args;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    # Direct access without version
    location / {
        proxy_pass http://127.0.0.1:8081;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF

ln -sf /etc/nginx/sites-available/gonka-proxy /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t

# Start nginx
echo "Starting Nginx..."
pkill nginx || true
nginx

echo "========================================="
echo "Setup complete! Ready to start services"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Start Gonka API: bash /data/gonka-scripts/start_gonka_api.sh"
echo "2. Start vLLM via Gonka: bash /data/gonka-scripts/start_vllm_via_gonka.sh"
echo "3. Register node: bash /data/gonka-scripts/register_node.sh"
echo "4. Check status: bash /data/gonka-scripts/check_status.sh"
