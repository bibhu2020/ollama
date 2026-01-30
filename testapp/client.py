#!/usr/bin/env python3
import requests
import json
import sys
import time

# Configuration
# If running outside k8s (e.g. from your WSL terminal), use localhost and the NodePort
# If running inside k8s, you would use http://ollama-service:7860
# OLLAMA_URL = "http://localhost:30786/api/generate"
OLLAMA_URL = "https://mishrabp-ollama.hf.space/api/generate"
MODEL = "llama3.2:3b"

def query_ollama(prompt):
    print(f"🔵 Querying {MODEL} at {OLLAMA_URL}...")
    print(f"📝 Prompt: {prompt}")
    print("-" * 50)

    payload = {
        "model": MODEL,
        "prompt": prompt,
        "stream": True  # Enable streaming for real-time output
    }

    try:
        response = requests.post(OLLAMA_URL, json=payload, stream=True)
        response.raise_for_status()

        full_response = ""
        start_time = time.time()

        for line in response.iter_lines():
            if line:
                decoded_line = line.decode('utf-8')
                data = json.loads(decoded_line)
                
                if "response" in data:
                    chunk = data["response"]
                    print(chunk, end='', flush=True)
                    full_response += chunk
                
                if data.get("done", False):
                    print() # Newline at end
                    total_duration = data.get("total_duration", 0) / 1e9 # Convert ns to s
                    print("-" * 50)
                    print(f"✅ Done in {total_duration:.2f}s")
                    
    except requests.exceptions.ConnectionError:
        print(f"\n❌ Could not connect to Ollama at {OLLAMA_URL}")
        print("   Ensure the Kubernetes service is running and port 30786 is accessible.")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) > 1:
        prompt = " ".join(sys.argv[1:])
    else:
        prompt = "Why is the sky blue? Keep it brief."
    
    query_ollama(prompt)
