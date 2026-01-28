# Setup
# Best practice on Ubuntu/WSL: use a virtual environment
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Run with default prompt
python3 client.py

# Run with custom prompt (Quote your strings in Zsh!)
python3 client.py "Write a haiku about Kubernetes"
