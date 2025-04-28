#!/bin/bash
# test_ingress.sh - Test ingress-nginx deployment on EKS

set -e

echo "=== Beginning Ingress Testing ==="

# Ensure we're connected to the cluster
echo "Verifying connection to the EKS cluster..."
kubectl cluster-info

# Create test deployment
echo "Creating a test deployment and service..."
kubectl create deployment nginx-test --image=nginx --port=80

# Create test service
kubectl expose deployment nginx-test --port=80

# Wait for deployment to be ready
echo "Waiting for test deployment to be ready..."
kubectl wait --for=condition=available deployment/nginx-test --timeout=60s

# Create test ingress
echo "Creating test ingress resource..."
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-test-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  rules:
  - host: nginx-test.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx-test
            port:
              number: 80
EOF

# Wait for ingress to be ready
echo "Waiting for ingress resource to be processed..."
sleep 10

# Get ingress IP/hostname
echo "Getting ingress controller external IP/hostname..."
EXTERNAL_IP=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# If IP is empty, try hostname (AWS ELB typically provides hostname, not IP)
if [ -z "$EXTERNAL_IP" ]; then
  EXTERNAL_IP=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
  echo "External hostname: $EXTERNAL_IP"
else
  echo "External IP: $EXTERNAL_IP"
fi

# Test connectivity to the ingress controller
echo "Testing connectivity to ingress controller..."
if [ -n "$EXTERNAL_IP" ]; then
  # Test with curl and Host header
  echo "Running: curl -s -o /dev/null -w '%{http_code}' -H 'Host: nginx-test.example.com' http://$EXTERNAL_IP"
  HTTP_CODE=$(curl -s -o /dev/null -w '%{http_code}' -H "Host: nginx-test.example.com" http://$EXTERNAL_IP --connect-timeout 10 || echo "Failed")
 
  if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Successfully connected to test application through ingress (HTTP 200)"
    RESULT=0
  else
    echo "⚠️ Connection test returned HTTP code: $HTTP_CODE (expected 200)"
    echo "This might be normal if the load balancer is still provisioning. Try again in a few minutes."
    RESULT=1
  fi
else
  echo "⚠️ External IP/hostname not available yet. This is normal if the load balancer is still provisioning."
  echo "Run the following command later to check the status:"
  echo "kubectl get svc -n ingress-nginx ingress-nginx-controller"
  RESULT=1
fi

# Optional: Clean up test resources
if [ "${CLEANUP:-true}" = "true" ]; then
  echo "Cleaning up test resources..."
  kubectl delete ingress nginx-test-ingress
  kubectl delete service nginx-test
  kubectl delete deployment nginx-test
fi

echo "Testing completed with result: $RESULT (0=success, 1=failure)"
exit $RESULT