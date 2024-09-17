# Use NVIDIA CUDA base image
FROM nvidia/cuda:12.2.0-runtime-ubuntu22.04

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3.10 \
    python3.10-dev \
    python3-pip \
    libexpat1 \
    git \
    && rm -rf /var/lib/apt/lists/*

# Clone the repository
RUN git clone https://github.com/Heurist-Network/miner-release.git .

# Install Python dependencies
RUN pip3 install --no-cache-dir -r requirements.txt

# Install PyTorch with CUDA support
RUN pip3 install torch==2.4.0 torchvision==0.19.0+cu121 torchaudio==2.4.0+cu121 --extra-index-url https://download.pytorch.org/whl/cu121

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV NVIDIA_VISIBLE_DEVICES=all

# Create a script to handle environment variables and start the miner
COPY sd-miner-starter.sh /app/sd-miner-starter.sh
RUN chmod +x /app/sd-miner-starter.sh

# Create a non-root user and set up volumes
RUN useradd -m appuser && \
    mkdir -p /home/appuser/.heurist-keys /home/appuser/.cache && \
    chown -R appuser:appuser /home/appuser/.heurist-keys /home/appuser/.cache /app

# Switch to non-root user
USER appuser

# Set up volumes
VOLUME ["/home/appuser/.heurist-keys", "/home/appuser/.cache"]

# Set the entrypoint
ENTRYPOINT ["/app/sd-miner-starter.sh"]