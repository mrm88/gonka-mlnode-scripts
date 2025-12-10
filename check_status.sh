#!/bin/bash
# check_status.sh - Check all services

echo "========================================="
echo "MLNode Status Check"
echo "========================================="

echo ""
echo "1. GPU Status:"
nvidia-smi --query-gpu=index,name,memory.used,memory.total,utilization.gpu --format=csv,noheader

echo ""
echo "2. vLLM Status:"
if curl -s http://localhost:5000/v1/models > /dev/null 2>&1; then
    echo "✅ vLLM is running on port 5000"
    curl -s http://localhost:5000/v1/models | jq -r '.data[0].id'
else
    echo "❌ vLLM is NOT running"
fi

echo ""
echo "3. Gonka API Status:"
if curl -s http://localhost:8080/api/v1/state > /dev/null 2>&1; then
    echo "✅ Gonka API is running on port 8080"
    curl -s http://localhost:8080/api/v1/state
else
    echo "❌ Gonka API is NOT running"
fi

echo ""
echo "4. Network Node Registration:"
curl -s http://104.238.135.166:9200/admin/v1/nodes | jq '.[] | select(.node.id=="a40-cluster-tp4") | {id: .node.id, status: .state.current_status, host: .node.host}'

echo ""
echo "5. Screen Sessions:"
screen -ls

echo ""
echo "========================================="
