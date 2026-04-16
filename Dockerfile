# Custom GitHub Actions Runner Image
FROM ghcr.io/actions/actions-runner:latest

# Install additional tools
USER root

# Install common CI/CD tools
# Added dumb-init here (CRITICAL for container survival)
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    jq \
    unzip \
    apt-transport-https \
    ca-certificates \
    software-properties-common \
    dumb-init \
    && rm -rf /var/lib/apt/lists/*

# Install Docker CLI (for Docker-in-Docker workflows)
RUN curl -fsSL https://get.docker.com -o get-docker.sh && \
    sh get-docker.sh && \
    rm get-docker.sh

# Install gcloud CLI (for GCP interactions)
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | \
    tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
    apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && \
    apt-get update && apt-get install -y google-cloud-cli && \
    rm -rf /var/lib/apt/lists/*

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl

# Install Terraform
RUN wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    tee /etc/apt/sources.list.d/hashicorp.list && \
    apt-get update && apt-get install -y terraform && \
    rm -rf /var/lib/apt/lists/*

# Install Node.js and npm (useful for many workflows)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install Python and pip
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# --- FIX START ---

# Ensure the runner user owns their home directory again
# (Running as root often changes ownership of config files, causing permission denied crashes)
RUN chown -R runner:runner /home/runner

# Switch back to runner user for security
USER runner

# Set working directory
WORKDIR /home/runner

# OVERRIDE ENTRYPOINT
# This prevents the container from printing "Usage:..." and exiting immediately.
# It allows the Scale Set Controller to inject the startup command correctly.
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/home/runner/run.sh"]

# --- FIX END ---