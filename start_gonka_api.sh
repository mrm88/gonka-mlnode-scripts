#!/bin/bash
# start_gonka_api.sh - Start Gonka Management API on port 8081 (behind nginx on 8080)

echo "Starting Gonka API on port 8081 (proxied through nginx on 8080)..."

# Set all required environment variables for vLLM management
export VLLM_USE_V1=0
export NCCL_P2P_DISABLE=1
export NCCL_IB_DISABLE=1
export NCCL_SOCKET_IFNAME=eth0
export HF_HOME=/data/.cache/huggingface
export CUDA_VISIBLE_DEVICES=0,1,2,3

# Set PYTHONPATH
export PYTHONPATH=/data/app/packages/api/src:/data/app/packages/pow/src:/data/app/packages/train/src:/data/app/packages/common/src:$PYTHONPATH

# Create logs directory
mkdir -p /data/logs

# Start in screen
screen -dmS gonka-api bash -c "
cd /data/app/packages/api/src
uvicorn api.app:app \
  --host=0.0.0.0 \
  --port=8081 \
  2>&1 | tee /data/logs/gonka-api.log
"

echo "Gonka API started in screen session 'gonka-api'"
echo "Nginx proxy listening on port 8080 (external)"
echo "Gonka API listening on port 8081 (internal)"
echo ""
echo "View logs: screen -r gonka-api"
echo "Or: tail -f /data/logs/gonka-api.log"
echo ""
echo "Test endpoints:"
echo "  curl http://localhost:8080/api/v1/state"
echo "  curl http://localhost:8080/v3.0.8/api/v1/state"
