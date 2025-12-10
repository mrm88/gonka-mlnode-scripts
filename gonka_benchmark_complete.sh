#!/bin/bash
set -e

# CRITICAL: Set environment
export VLLM_USE_V1=0
export NCCL_P2P_DISABLE=1
export NCCL_IB_DISABLE=1
export NCCL_SOCKET_IFNAME=eth0

source ./setup_env.sh

echo "========================================="
echo "Complete Gonka Benchmark - 8xA40"
echo "Official Gonka methodology"
echo "========================================="

# Test configs
declare -a TPS=("2" "4" "8")

for tp in "${TPS[@]}"; do
  echo ""
  echo "========================================"
  echo "Testing TP=$tp"
  echo "========================================"
  
  # Kill existing
  pkill -9 vllm python3 || true
  sleep 10
  
  # Start vLLM
  echo "Starting vLLM with TP=$tp..."
  vllm serve $MODEL \
    --host 0.0.0.0 \
    --port $INFERENCE_PORT \
    --tensor-parallel-size $tp \
    --gpu-memory-utilization 0.90 \
    --max-model-len 16384 \
    --max-num-batched-tokens 32768 \
    --max-num-seqs 256 \
    --trust-remote-code \
    > /data/logs/vllm_tp${tp}.log 2>&1 &
  
  # Wait for startup (longer for more GPUs)
  WAIT_TIME=$((60 + tp * 30))
  echo "Waiting ${WAIT_TIME}s for startup..."
  sleep $WAIT_TIME
  
  # Verify
  if ! curl -s http://localhost:$INFERENCE_PORT/v1/models > /dev/null 2>&1; then
    echo "❌ Failed to start TP=$tp"
    tail -50 /data/logs/vllm_tp${tp}.log
    continue
  fi
  echo "✓ TP=$tp ready"
  
  # Benchmark with official Gonka config
  echo "Running Gonka benchmark..."
  compressa-perf measure-from-yaml \
    --no-sign \
    config_gonka_official.yml
  
  echo "✓ TP=$tp complete"
done

echo ""
echo "========================================"
echo "BENCHMARK COMPLETE!"
echo "========================================"
echo ""
echo "Compare results:"
echo ""
sqlite3 compressa-perf-db.sqlite "
  SELECT 
    'TP=' || CASE 
      WHEN experiment_name LIKE '%tp2%' THEN '2'
      WHEN experiment_name LIKE '%tp4%' THEN '4'  
      WHEN experiment_name LIKE '%tp8%' THEN '8'
      ELSE '?'
    END as 'Config',
    ROUND(CAST(json_extract(metrics, '$.THROUGHPUT_OUTPUT_TOKENS') AS REAL), 2) as 'Throughput (tok/s)',
    ROUND(CAST(json_extract(metrics, '$.TTFT') AS REAL), 2) as 'TTFT (s)',
    ROUND(CAST(json_extract(metrics, '$.TPOT') AS REAL), 4) as 'TPOT (s)'
  FROM experiments 
  WHERE experiment_name LIKE 'gonka_%'
  ORDER BY CAST(json_extract(metrics, '$.THROUGHPUT_OUTPUT_TOKENS') AS REAL) DESC;
"
