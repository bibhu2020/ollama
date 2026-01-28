---
title: Ollama
emoji: ⚡
colorFrom: pink
colorTo: blue
sdk: docker
pinned: false
license: mit
short_description: Ollama (llama3.2:3b) on Hugging Face Spaces (Docker)
---


# 🦙 Ollama (llama3.2:3b) on Hugging Face Spaces (Docker)

This Space runs **[Ollama](https://ollama.com/)** with the **`llama3.2:3b`** model using a **Docker-based Hugging Face Space**.

The container starts Ollama, pulls the model at runtime, and exposes the Ollama HTTP API so you can interact with the model programmatically.

---

## 🚀 Hugging Face Space Configuration

When creating the Space:

- **SDK**: `Docker`
- **Template**: `Blank`
- **Hardware**: `Free CPU` (sufficient for 3B models)
- **Visibility**: Public or Private (your choice)

No additional configuration files are required beyond this repository.

---

## 🧱 How It Works

- Ollama runs inside a Docker container
- The model `llama3.2:3b` is pulled on startup
- Ollama listens on port **11434**
- Hugging Face automatically maps the port and exposes the Space URL

---

## 📡 API Usage

Once the Space is running, you can interact with Ollama via HTTP.

### Check version
```bash
curl https://<your-space>.hf.space/api/version
```

### Generate text
```bash
curl https://<your-space>.hf.space/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama3.2:3b",
    "prompt": "Explain Kubernetes like I am five"
  }'
```

---

## 🔄 Automatic Deployment (GitHub → Hugging Face)

You can deploy automatically using **GitHub Actions**.

### Required Secrets (GitHub Repository)

Go to **Settings → Secrets and variables → Actions**, then add:

| Secret Name | Description |
|------------|------------|
| `HF_USERNAME` | Your Hugging Face username |
| `HF_TOKEN` | Hugging Face **Write** access token |
| `SPACE_NAME` | Name of the Hugging Face Space |

The workflow logs in to:
```
registry.hf.space
```
and pushes the Docker image, triggering a redeploy of the Space.

---

## 🧪 Local Development (Optional)

You can run the same container locally for testing.

### Build the image
```bash
docker build -t ollama-local:latest .
```

If you hit DNS/network issues:
```bash
docker build --network=host -t ollama-local:latest .
```

### Run locally
```bash
docker run -p 11434:11434 ollama-local:latest
```

Test:
```bash
curl http://localhost:11434/api/version
```

---

## ☸️ Local Kubernetes Deployment (Optional)

This project can also be deployed to a local Kubernetes cluster (Docker Desktop, Minikube, MicroK8s).

### Build the image
```bash
docker build -t ollama-local:latest .
```

### Deploy
```bash
kubectl apply -f local.yml
```

### Access the service
- **Docker Desktop**:  
  `http://localhost:30786`
- **Minikube**:
  ```bash
  echo "http://$(minikube ip):30786"
  ```

Verify:
```bash
curl http://localhost:30786/api/version
```

---

## ⚠️ Notes & Limitations

- Free CPU Spaces are **slow** for inference (expected for LLMs)
- Model downloads happen at container startup
- Hugging Face Spaces may restart containers periodically

---

## 📚 References

- Ollama: https://ollama.com/
- Hugging Face Spaces (Docker): https://huggingface.co/docs/hub/spaces-sdks-docker
