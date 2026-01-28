#!/bin/bash
set -e

# Define image name
IMG_NAME="docker.io/library/ollama-local:latest"

echo "1. Building image: $IMG_NAME ..."
docker build --network=host -t $IMG_NAME .

echo "2. Saving image to ollama-local.tar ..."
docker save $IMG_NAME > ollama-local.tar

echo "3. Importing into Microk8s (k8s.io namespace)..."
# Using 'images import' explicitly
microk8s ctr --namespace k8s.io images import ollama-local.tar

echo "---------------------------------------------------"
echo "VERIFICATION: Checking if image exists in Microk8s:"
microk8s ctr --namespace k8s.io images list | grep "ollama-local" || echo "❌ Image NOT found in Microk8s registry!"
echo "---------------------------------------------------"

echo "4. Redeploying..."
kubectl apply -f deploy.yml
# Retrieve the pod name to delete it
POD_NAME=$(kubectl get pod -l app=ollama -o jsonpath="{.items[0].metadata.name}")
if [ -n "$POD_NAME" ]; then
    echo "Deleting old pod: $POD_NAME"
    kubectl delete pod $POD_NAME
fi

echo "Done! Watch the pods with: kubectl get pods -w"
