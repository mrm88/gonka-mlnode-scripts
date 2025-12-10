#!/bin/bash
# setup_env.sh - Environment configuration for Gonka MLNode

# ===== MLNODE CONFIGURATION =====
export HF_HOME=/data/.cache/huggingface
export CUDA_VISIBLE_DEVICES=0,1,2,3,4,5,6,7
export MODEL=Qwen/Qwen3-32B-FP8

# MLNode ports (local)
export INFERENCE_PORT=5000
export MANAGEMENT_PORT=8080

# Get MLNode public IP
export MLNODE_PUBLIC_IP=$(curl -s ifconfig.me)

# ===== NETWORK NODE CONFIGURATION (Your remote server) =====
export NETWORK_NODE_IP=104.238.135.166
export NETWORK_NODE_API_PORT=8000
export NETWORK_NODE_ADMIN_PORT=9200
export NETWORK_NODE_POC_CALLBACK=http://${NETWORK_NODE_IP}:9100

# ===== GONKA NETWORK =====
export SEED_API_URL=http://node2.gonka.ai:8000
export SEED_NODE_RPC_URL=http://node2.gonka.ai:26657

echo "========================================="
echo "MLNode Configuration"
echo "========================================="
echo "MLNode Public IP: $MLNODE_PUBLIC_IP"
echo "Inference Port: $INFERENCE_PORT"
echo "Management Port: $MANAGEMENT_PORT"
echo ""
echo "Network Node: $NETWORK_NODE_IP"
echo "Network Node Admin API: http://$NETWORK_NODE_IP:$NETWORK_NODE_ADMIN_PORT"
echo "PoC Callback URL: $NETWORK_NODE_POC_CALLBACK"
echo "========================================="

# Aliases for register_with_network.sh compatibility
export MLNODE_IP="$MLNODE_PUBLIC_IP"
export MLNODE_INFERENCE_PORT="$INFERENCE_PORT"
export MLNODE_MANAGEMENT_PORT="$MANAGEMENT_PORT"
export MODEL_NAME="$MODEL"
export NETWORK_NODE_ADMIN_API="http://$NETWORK_NODE_IP:$NETWORK_NODE_ADMIN_PORT"
export MLNODE_ID="a40-cluster-tp4"
export POC_CALLBACK_URL="$NETWORK_NODE_POC_CALLBACK"
