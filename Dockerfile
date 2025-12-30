# ColdStar - Self-contained Docker Image
# No dependencies required on host - just Docker

FROM rust:1.75-slim-bookworm AS rust-builder

WORKDIR /build
COPY secure_signer/ ./secure_signer/

RUN cd secure_signer && cargo build --release

# Python stage
FROM python:3.12-slim-bookworm

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libsodium23 \
    usbutils \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy Rust binary from builder
COPY --from=rust-builder /build/secure_signer/target/release/solana-signer /usr/local/bin/

# Install Python dependencies
COPY local_requirements.txt .
RUN pip install --no-cache-dir -r local_requirements.txt solana solders

# Copy application code
COPY main.py config.py flash_usb.py upgrade_wallet.py python_signer_example.py ./
COPY src/ ./src/

# Set environment
ENV COLDSTAR_HOME=/app
ENV PYTHONUNBUFFERED=1

# Default command
ENTRYPOINT ["python", "main.py"]
