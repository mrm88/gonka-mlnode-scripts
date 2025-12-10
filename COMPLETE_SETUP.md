# Complete Gonka MLNode Setup for Runpod 8xA40

## What Works
✅ V0 engine with NCCL workarounds
✅ TP=2, TP=4, TP=8 (tensor parallelism)
✅ Official Gonka compressa-perf benchmarks
✅ Long context testing (10k char prompts)

## What Doesn't Work
❌ PP>1 (pipeline parallelism) - V1 engine bug
❌ TP=4,PP=2 - Would need vLLM downgrade or update

## Critical Environment Variables
```bash
export VLLM_USE_V1=0                    # Force V0 engine
export NCCL_P2P_DISABLE=1               # NCCL workaround
export NCCL_IB_DISABLE=1                # NCCL workaround
export NCCL_SOCKET_IFNAME=eth0          # NCCL workaround
export HF_HOME=/data/.cache/huggingface
export CUDA_VISIBLE_DEVICES=0,1,2,3,4,5,6,7
```

## Quick Start

### 1. First Time Setup
```bash
cd /data
git clone https://github.com/mrm88/gonka-mlnode-scripts.git gonka-scripts
cd gonka-scripts

# Install dependencies
apt-get update && apt-get install -y pkg-config libsecp256k1-dev
pip install git+https://github.com/product-science/compressa-perf.git --break-system-packages

# Set environment
source setup_env.sh
```

### 2. Run Benchmark (Find Optimal TP)
```bash
bash gonka_benchmark_complete.sh
# Takes 1-2 hours, tests TP=2, TP=4, TP=8
```

### 3. Deploy Production
```bash
# Update TP in script based on benchmark winner
nano start_production_working.sh

# Start production
screen -S mlnode
bash start_production_working.sh
# Ctrl+A, D to detach
```

### 4. Register with Network Node
```bash
bash register_with_network.sh
```

## Expected Performance (8xA40, Official Gonka Benchmark)
- TP=2: ~40-50 tok/s (2 GPUs)
- TP=4: ~61 tok/s (4 GPUs) ✓ Confirmed
- TP=8: ~80-100 tok/s? (8 GPUs) - Need to test

## Troubleshooting
- **NCCL errors**: Already fixed with environment variables
- **V1 engine crash**: Already fixed with VLLM_USE_V1=0
- **OOM errors**: Lower --gpu-memory-utilization to 0.85
