#!/bin/bash
# start_gonka_api.sh - Start Gonka Management API on port 8080

echo "Starting Gonka API on port 8080..."

# Set PYTHONPATH
export PYTHONPATH=/data/app/packages/api/src:/data/app/packages/pow/src:/data/app/packages/train/src:/data/app/packages/common/src:$PYTHONPATH

# Start in screen
screen -dmS gonka-api bash -c "
cd /data/app/packages/api/src
uvicorn api.app:app \
  --host=0.0.0.0 \
  --port=8080 \
  2>&1 | tee /data/logs/gonka-api.log
"

echo "Gonka API started in screen session 'gonka-api'"
echo "View logs: screen -r gonka-api"
echo "Or: tail -f /data/logs/gonka-api.log"
