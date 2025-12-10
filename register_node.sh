#!/bin/bash
# register_node.sh - Register MLNode with Network Node (auto-detects RunPod ports)

cd /data/gonka-scripts
source setup_env.sh

echo "Registering MLNode with Network Node..."
echo "MLNode IP: $MLNODE_PUBLIC_IP"

# Auto-detect RunPod external ports or use environment variables
if [ -z "$EXTERNAL_INFERENCE_PORT" ] || [ -z "$EXTERNAL_MANAGEMENT_PORT" ]; then
    echo ""
    echo "⚠️  External ports not set!"
    echo ""
    echo "Please check your RunPod 'Direct TCP ports' section and set:"
    echo ""
    echo "  export EXTERNAL_INFERENCE_PORT=XXXXX  # Your vLLM port"
    echo "  export EXTERNAL_MANAGEMENT_PORT=YYYYY # Your Gonka API port"
    echo ""
    echo "Then run this script again."
    echo ""
    echo "Example (if your SSH port is 22107):"
    echo "  export EXTERNAL_INFERENCE_PORT=22108"
    echo "  export EXTERNAL_MANAGEMENT_PORT=22109"
    echo "  bash register_node.sh"
    exit 1
fi

INFERENCE_PORT=$EXTERNAL_INFERENCE_PORT
MANAGEMENT_PORT=$EXTERNAL_MANAGEMENT_PORT

echo "Using external ports:"
echo "  Inference (vLLM): $INFERENCE_PORT"
echo "  Management (Gonka): $MANAGEMENT_PORT"

# Create JSON payload
JSON_PAYLOAD=$(cat <<EOF
{
  "host": "$MLNODE_PUBLIC_IP",
  "inference_segment": "",
  "inference_port": $INFERENCE_PORT,
  "poc_segment": "",
  "poc_port": $MANAGEMENT_PORT,
  "models": {
    "Qwen/Qwen3-32B-FP8": {
      "args": ["--tensor-parallel-size", "4", "--pipeline-parallel-size", "1"]
    }
  },
  "id": "a40-cluster-tp4",
  "max_concurrent": 1000,
  "hardware": null
}
EOF
)

# Send registration request
curl --max-time 10 -X POST http://104.238.135.166:9200/admin/v1/nodes \
  -H "Content-Type: application/json" \
  -d "$JSON_PAYLOAD"

echo ""
echo "Checking registration status..."
curl -s http://104.238.135.166:9200/admin/v1/nodes | jq '.[] | select(.node.id=="a40-cluster-tp4") | {id: .node.id, status: .state.current_status, intended: .state.intended_status}'
