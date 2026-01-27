FROM ollama/ollama:latest

# Set environment variables for Hugging Face Spaces
# Spaces expect the service to listen on port 7860
ENV OLLAMA_HOST=0.0.0.0:7860
ENV OLLAMA_ORIGINS="*"

# Hugging Face Spaces typically run as user 1000.
# We create a user and set up the home directory and model path.
ENV HOME=/home/user
ENV OLLAMA_MODELS=$HOME/.ollama/models

# The base image may already have a user with UID 1000 (often named 'ollama').
# We setup the home directory expected by HF Spaces and ensure permissions.
RUN mkdir -p $HOME/.ollama/models && \
    chown -R 1000:1000 $HOME

# Switch to UID 1000 (whether it's 'user' or 'ollama')
USER 1000

# Pre-pull the model during the build process
# Llama 3.2 3B is small enough to fit in the image layer for deployment stability
RUN /bin/ollama serve & \
    pid=$! && \
    sleep 5 && \
    echo "Pulling llama3.2:3b model..." && \
    /bin/ollama pull llama3.2:3b && \
    kill $pid

# Expose the port expected by HF Spaces
EXPOSE 7860

# Start Ollama
ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]


