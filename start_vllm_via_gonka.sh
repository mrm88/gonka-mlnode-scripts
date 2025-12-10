#!/bin/bash
# start_vllm_via_gonka.sh - Start vLLM through Gonka's management API

echo "Starting vLLM through Gonka management API..."
echo ""

# Check if Gonka API is running
if ! curl -s http://localhost:8080/api/v1/state > /dev/null 2>&1; then
    echo "ERROR: Gonka API is not running on port 8080"
    echo "Please run: bash start_gonka_api.sh"
    exit 1
fi

# Check current state
CURRENT_STATE=$(curl -s http://localhost:8080/api/v1/state | grep -o '"state":"[^"]*"' | cut -d'"' -f4)
echo "Current state: $CURRENT_STATE"

if [ "$CURRENT_STATE" = "INFERENCE" ]; then
    echo "vLLM is already running!"
    exit 0
fi

# Kill any manual vLLM processes
echo "Stopping any manual vLLM processes..."
pkill -9 vllm || true
sleep 2

# Tell Gonka to start vLLM
echo "Requesting Gonka to start vLLM..."
RESPONSE=$(curl -s -X POST http://localhost:8080/api/v1/inference/up \
  -H "Content-Type: application/json" \
  -d '{
    "model": "Qwen/Qwen3-32B-FP8",
    "dtype": "auto",
    "additional_args": [
      "--tensor-parallel-size", "4",
      "--max-model-len", "16384",
      "--gpu-memory-utilization", "0.90",
      "--max-num-batched-tokens", "32768",
      "--max-num-seqs", "256"
    ]
  }')

echo "Response: $RESPONSE"
echo ""
echo "vLLM is starting... This takes 3-5 minutes."
echo "Monitor progress:"
echo "  watch -n 3 'curl -s http://localhost:8080/api/v1/state'"
echo ""
echo "Or check GPU usage:"
echo "  watch -n 3 nvidia-smi"
echo ""
echo "When state shows 'INFERENCE', vLLM is ready!"
