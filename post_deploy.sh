#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "Starting kubectl, Helm, and ingress-nginx installation..."

# Detect OS
OS=$(uname | tr '[:upper:]' '[:lower:]')
echo "Detected OS: $OS"

# Create temporary directory for downloads
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

# Install kubectl
echo "Installing kubectl..."

# Get latest stable kubectl version
KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
echo "Installing kubectl version: $KUBECTL_VERSION"

if [[ "$OS" == "darwin" ]]; then
    # macOS
    curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/darwin/amd64/kubectl"
elif [[ "$OS" == "linux" ]]; then
    # Linux
    curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
else
    echo "Unsupported OS: $OS"
    exit 1
fi

# Make kubectl executable and move to /usr/local/bin
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Verify kubectl installation
echo "Verifying kubectl installation..."
kubectl version --client

# Install Helm
echo "Installing Helm..."

# Get latest Helm version
HELM_VERSION=$(curl -s https://api.github.com/repos/helm/helm/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
echo "Installing Helm version: $HELM_VERSION"

# Download and install Helm based on OS
if [[ "$OS" == "darwin" ]]; then
    # macOS
    curl -L "https://get.helm.sh/helm-${HELM_VERSION}-darwin-amd64.tar.gz" -o helm.tar.gz
elif [[ "$OS" == "linux" ]]; then
    # Linux
    curl -L "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz" -o helm.tar.gz
fi

# Extract archive
tar -zxvf helm.tar.gz

# Move helm binary to /usr/local/bin
sudo mv "${OS}-amd64/helm" /usr/local/bin/helm
chmod +x /usr/local/bin/helm

# Clean up
cd -
rm -rf "$TMP_DIR"

# Verify Helm installation
echo "Verifying Helm installation..."
helm version

# Add required Helm repositories
echo "Adding Helm repositories..."
helm repo add stable https://charts.helm.sh/stable
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

# Update repositories
helm repo update

# Configure kubectl to connect to the EKS cluster
echo "Configuring kubectl to connect to EKS cluster..."

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "AWS CLI not found. Installing AWS CLI..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
fi

# Get EKS cluster name from Terraform output or environment variable
EKS_CLUSTER_NAME=${EKS_CLUSTER_NAME:-"k8s-eks-cluster"}
REGION=${AWS_REGION:-"us-east-1"}  # Default to us-east-1 if not set

echo "Updating kubeconfig for EKS cluster: $EKS_CLUSTER_NAME in region: $REGION"
aws eks update-kubeconfig --name "$EKS_CLUSTER_NAME" --region "$REGION"

# Verify connection to the cluster
echo "Verifying connection to the EKS cluster..."
kubectl cluster-info

# Check if the Kubernetes cluster is accessible before installing ingress-nginx
echo "Checking Kubernetes cluster connectivity..."
if ! kubectl cluster-info &> /dev/null; then
    echo "Warning: Cannot connect to Kubernetes cluster. Please check your kubeconfig before installing ingress-nginx."
    exit 1
fi

# Install ingress-nginx using Helm
echo "Installing ingress-nginx using Helm..."
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --create-namespace \
  --namespace ingress-nginx \
  --set controller.service.type=LoadBalancer

# Wait for ingress-nginx to be ready
echo "Waiting for ingress-nginx to be ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

# Check installation status
echo ""
echo "=== Installation Complete ==="
echo ""
echo "Checking kubectl installation:"
kubectl version --client

echo ""
echo "Checking Helm installation:"
helm version

echo ""
echo "Checking ingress-nginx installation:"
echo "- Pods:"
kubectl get pods -n ingress-nginx
echo ""
echo "- Services:"
kubectl get svc -n ingress-nginx
echo ""
echo "- Deployments:"
kubectl get deployments -n ingress-nginx

echo ""
echo "To verify ingress-nginx is working properly, you can run:"
echo "kubectl get all -n ingress-nginx"
echo ""
echo "To get the external IP of your ingress controller:"
echo "kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}'"
echo ""
echo "To test with a sample application, create a test deployment and ingress resource:"
echo "kubectl create deployment demo --image=httpd --port=80"
echo "kubectl expose deployment demo"
echo "kubectl create ingress demo --class=nginx --rule=\"demo.localdev.me/*=demo:80\""
echo ""
echo "Then add the ingress IP to your /etc/hosts file and access demo.localdev.me in your browser"

echo ""
echo "Installation completed successfully!"



# echo ""
# echo "To verify ingress-nginx is working properly, you can run:"
# echo "kubectl get all -n ingress-nginx"
# echo ""
# echo "To get the external IP of your ingress controller:"
# echo "kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}'"
# echo ""
# echo "To test with a sample application, create a test deployment and ingress resource:"
# echo "kubectl create deployment demo --image=httpd --port=80"
# echo "kubectl expose deployment demo"
# echo "kubectl create ingress demo --class=nginx --rule=\"demo.localdev.me/*=demo:80\""
# echo ""
# echo "Then add the ingress IP to your /etc/hosts file and access demo.localdev.me in your browser"

# echo ""
# echo "Installation completed successfully!"




































# #!/bin/bash

# # Exit immediately if a command exits with a non-zero status
# set -e

# echo "Starting Helm installation..."

# # Detect OS
# OS=$(uname | tr '[:upper:]' '[:lower:]')
# echo "Detected OS: $OS"

# # Check if kubectl is installed
# if ! command -v kubectl &> /dev/null; then
#     echo "kubectl not found. Please install kubectl first."
#     exit 1
# fi

# # Check if Kubernetes cluster is accessible
# if ! kubectl cluster-info &> /dev/null; then
#     echo "Cannot connect to Kubernetes cluster. Please check your kubeconfig."
#     exit 1
# fi

# # Create temporary directory for downloads
# TMP_DIR=$(mktemp -d)
# cd "$TMP_DIR"

# # Get latest Helm version
# HELM_VERSION=$(curl -s https://api.github.com/repos/helm/helm/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
# echo "Installing Helm version: $HELM_VERSION"

# # Download and install Helm based on OS
# if [[ "$OS" == "darwin" ]]; then
#     # macOS
#     curl -L "https://get.helm.sh/helm-${HELM_VERSION}-darwin-amd64.tar.gz" -o helm.tar.gz
# elif [[ "$OS" == "linux" ]]; then
#     # Linux
#     curl -L "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz" -o helm.tar.gz
# else
#     echo "Unsupported OS: $OS"
#     exit 1
# fi

# # Extract archive
# tar -zxvf helm.tar.gz

# # Move helm binary to /usr/local/bin
# sudo mv "${OS}-amd64/helm" /usr/local/bin/helm
# chmod +x /usr/local/bin/helm

# # Clean up
# cd -
# rm -rf "$TMP_DIR"

# # Verify installation
# helm version

# # Add stable repository
# helm repo add stable https://charts.helm.sh/stable

# # Update repositories
# helm repo update

# echo "Helm installation completed successfully!"