#!/bin/bash
# check_status.sh - Check all services

echo "========================================="
echo "MLNode Status Check"
echo "========================================="

echo ""
echo "1. GPU Status:"
nvidia-smi --query-gpu=index,name,memory.used,memory.total,utilization.gpu --format=csv,noheader

echo ""
echo "2. Nginx Proxy Status:"
if ps aux | grep -v grep | grep nginx > /dev/null; then
    echo "✅ Nginx is running"
    if netstat -tln 2>/dev/null | grep :8080 > /dev/null || ss -tln 2>/dev/null | grep :8080 > /dev/null; then
        echo "✅ Port 8080 is listening"
    else
        echo "❌ Port 8080 is NOT listening"
    fi
else
    echo "❌ Nginx is NOT running"
fi

echo ""
echo "3. Gonka API Status:"
if curl -s http://localhost:8081/api/v1/state > /dev/null 2>&1; then
    STATE=$(curl -s http://localhost:8081/api/v1/state)
    echo "✅ Gonka API is running on port 8081"
    echo "   State: $STATE"
else
    echo "❌ Gonka API is NOT running on port 8081"
fi

echo ""
echo "4. Nginx Proxy Test:"
if curl -s http://localhost:8080/v3.0.8/api/v1/state > /dev/null 2>&1; then
    echo "✅ Nginx proxy working (version prefix stripped)"
else
    echo "❌ Nginx proxy NOT working"
fi

echo ""
echo "5. vLLM Status (via Gonka):"
GONKA_STATE=$(curl -s http://localhost:8080/api/v1/state | grep -o '"state":"[^"]*"' | cut -d'"' -f4)
if [ "$GONKA_STATE" = "INFERENCE" ]; then
    echo "✅ vLLM is running (state: INFERENCE)"
    if curl -s http://localhost:5000/v1/models > /dev/null 2>&1; then
        echo "✅ vLLM API responding on port 5000"
    else
        echo "⏳ vLLM still loading (port 5000 not ready yet)"
    fi
else
    echo "⏸️  vLLM not running (state: $GONKA_STATE)"
fi

echo ""
echo "6. Network Node Registration:"
if command -v jq > /dev/null; then
    curl -s http://104.238.135.166:9200/admin/v1/nodes | jq '.[] | select(.node.id=="a40-cluster-tp4") | {id: .node.id, intended: .state.intended_status, current: .state.current_status, host: .node.host, inference_port: .node.inference_port, poc_port: .node.poc_port}'
else
    curl -s http://104.238.135.166:9200/admin/v1/nodes | grep -A 20 '"id":"a40-cluster-tp4"'
fi

echo ""
echo "7. Screen Sessions:"
screen -ls

echo ""
echo "========================================="
