#!/bin/bash
set -e

# Load environment
source ./setup_env.sh

# TP=4 (winner!)
TP=4
PP=1

echo "========================================="
echo "Registering MLNode with Network Node"
echo "========================================="
echo "MLNode IP: $MLNODE_PUBLIC_IP"
echo "Network Node: $NETWORK_NODE_IP"
echo "Config: TP=$TP, PP=$PP"
echo ""

# Check MLNode is running
if ! curl -s -m 5 http://localhost:$INFERENCE_PORT/v1/models > /dev/null 2>&1; then
  echo "❌ ERROR: MLNode not running on port $INFERENCE_PORT"
  echo "Start it first: bash start_production_working.sh"
  exit 1
fi

echo "✓ MLNode is running"

# Register with Network Node Admin API
echo ""
echo "Registering via Network Node Admin API..."

RESPONSE=$(curl -s -m 10 -X POST http://$NETWORK_NODE_IP:$NETWORK_NODE_ADMIN_PORT/admin/v1/nodes \
  -H "Content-Type: application/json" \
  -d "{
    \"id\": \"a40-cluster-tp4\",
    \"host\": \"http://${MLNODE_PUBLIC_IP}\",
    \"inference_port\": ${INFERENCE_PORT},
    \"poc_port\": ${MANAGEMENT_PORT},
    \"max_concurrent\": 1000,
    \"models\": {
      \"Qwen/Qwen3-32B-FP8\": {
        \"args\": [
          \"--tensor-parallel-size\", \"${TP}\",
          \"--pipeline-parallel-size\", \"${PP}\"
        ]
      }
    }
  }")

echo "Response: $RESPONSE"

# Verify registration
echo ""
echo "Verifying registration..."
sleep 2

ALL_NODES=$(curl -s -m 10 http://$NETWORK_NODE_IP:$NETWORK_NODE_ADMIN_PORT/admin/v1/nodes)
echo "All registered nodes:"
echo "$ALL_NODES" | jq '.' || echo "$ALL_NODES"

echo ""
echo "========================================="
echo "Registration complete!"
echo "========================================="
echo "MLNode ID: a40-cluster-tp4"
echo "MLNode URL: http://${MLNODE_PUBLIC_IP}:${INFERENCE_PORT}"
echo ""
echo "Next: Check participants list after next PoC cycle:"
echo "  curl http://$NETWORK_NODE_IP:8000/v1/epochs/current/participants | jq"
