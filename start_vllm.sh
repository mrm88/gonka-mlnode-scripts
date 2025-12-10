
#!/bin/bash
# start_vllm.sh - Start vLLM on port 5000

echo "Starting vLLM on port 5000..."

# Set environment variables
export VLLM_USE_V1=0
export NCCL_P2P_DISABLE=1
export NCCL_IB_DISABLE=1
export NCCL_SOCKET_IFNAME=eth0
export HF_HOME=/data/.cache/huggingface
export CUDA_VISIBLE_DEVICES=0,1,2,3

# Start in screen
screen -dmS vllm bash -c "
vllm serve Qwen/Qwen3-32B-FP8 \
  --host 0.0.0.0 \
  --port 5000 \
  --trust-remote-code \
  --gpu-memory-utilization 0.90 \
  --max-model-len 16384 \
  --tensor-parallel-size 4 \
  --max-num-batched-tokens 32768 \
  --max-num-seqs 256 \
  2>&1 | tee /data/logs/vllm.log
"

echo "vLLM started in screen session 'vllm'"
echo "View logs: screen -r vllm"
echo "Or: tail -f /data/logs/vllm.log"
echo "Wait 3-5 minutes for model loading..."
