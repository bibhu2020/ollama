# Ollama on Hugging Face Spaces & Local Kubernetes

This project provides a Docker setup to run [Ollama](https://ollama.com/) with the `llama3.2:3b` model. It is designed to be hosted on a Hugging Face Space or deployed to a local Kubernetes cluster.

## Prerequisites

1.  **Hugging Face Account** (for Spaces deployment): You need an account on [huggingface.co](https://huggingface.co/).
2.  **Kubernetes Cluster** (for local deployment): Docker Desktop (with Kubernetes enabled), Minikube, or similar.
3.  **Kubectl**: The Kubernetes command-line tool.

## Deployment Option 1: Hugging Face Spaces

1.  **Create a Space**:
    *   Go to "New Space".
    *   Enter a name (e.g., `ollama-llama3`).
    *   Select **Docker** as the SDK.
    *   Select **Blank** as the template.
    *   **Hardware**: "Free CPU" works fine for this 3B model.

2.  **Setup GitHub Actions** (Automatic Deployment):
    To enable automatic deployment from this repository:
    *   Go to your GitHub repository **Settings > Secrets and variables > Actions**.
    *   Add the following **Repository secrets**:
        *   `HF_USERNAME`: Your Hugging Face username.
        *   `HF_TOKEN`: A Write access token from your [Hugging Face Settings](https://huggingface.co/settings/tokens).
        *   `SPACE_NAME`: The name of the Space you created.

## Deployment Option 2: Local Kubernetes

You can also run this setup effectively on your local machine using Kubernetes.

### 1. Build the Docker Image
First, build the image locally. You must tag it as `ollama-local:latest` so the Kubernetes manifest finds it.

```bash
docker build -t ollama-local:latest .
```

**Troubleshooting Build Errors:**
If you encounter DNS errors like `dial tcp: lookup ... i/o timeout` during the build step, use the `--network=host` flag to allow the build process to use your host's network connection:
```bash
docker build --network=host -t ollama-local:latest .
```

**Note for Microk8s users:**
Microk8s uses its own containerd registry, so it cannot see images built by your local Docker daemon by default. You must export and import the image:

```bash
# 1. Save the image to a tar file
docker save ollama-local:latest > ollama-local.tar

# 2. Import it into Microk8s (namespace k8s.io is required!)
microk8s ctr image import ollama-local.tar
# If the above doesn't work or the pod assumes the image is missing, try explicitly specifying the namespace:
microk8s ctr --namespace k8s.io image import ollama-local.tar
```
*Tip: usage of `microk8s images import ollama-local.tar` (if available on your version) also handles this automatically.*

*Tip: If you update the image, you must repeat these steps and restart the pod.*

**Note for Minikube users:**
If you are using Minikube, you must build the image *inside* the Minikube environment so the cluster can see it:
```bash
eval $(minikube docker-env)
docker build -t ollama-local:latest .
```

### 2. Deploy to Kubernetes
Apply the `local.yml` manifest, which creates a Deployment and a NodePort Service.

```bash
kubectl apply -f local.yml
```

### 3. Access the Service
The service is exposed on **NodePort 30786**.

*   **Docker Desktop (Windows/Mac)**: Access via localhost.
    *   Endpoint: `http://localhost:30786`
*   **Minikube**: You need the Minikube IP.
    ```bash
    echo "http://$(minikube ip):30786"
    ```

### Verify it works
You can use `curl` or the `ollama` CLI to test the connection.

```bash
# Using curl
curl http://localhost:30786/api/version

# Using ollama CLI
export OLLAMA_HOST=http://localhost:30786
ollama list
```
