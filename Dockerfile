FROM ubuntu:22.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
    fortune-mod \
    cowsay \
    python3 \
    python3-pip \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Set PATH for cowsay and games
ENV PATH="/usr/games:${PATH}"

# Create app directory and user
RUN groupadd -r wisecow && useradd -r -g wisecow wisecow
WORKDIR /app
RUN chown wisecow:wisecow /app

# Copy application files
COPY --chown=wisecow:wisecow wisecow.sh .
RUN chmod +x wisecow.sh

# Switch to non-root user
USER wisecow

# Set default port
ENV SRVPORT=4499

# Expose port
EXPOSE 4499

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:4499/health || exit 1

# Run the application
CMD ["./wisecow.sh"]
