# ==============================================================================
# DOCKERFILE - Recipe to Build Your Flask App Container
# ==============================================================================
FROM python:3.11-slim

LABEL maintainer="Perth Team"
LABEL description="Flask Task Manager API"
LABEL version="1.0"

# 1. IMPORTANT: Set working directory to root.
# This ensures that 'python -m app' can see the 'app' folder as a package.
WORKDIR /

# 2. Install system dependencies (required for some Python packages)
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc && \
    rm -rf /var/lib/apt/lists/*

# 3. Copy and install Python dependencies
# We copy to /app/requirements.txt to keep things organized
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# 4. Copy application source code
# We copy all files into the /app package directory
COPY __init__.py /app/__init__.py
COPY __main__.py /app/__main__.py
COPY common.py /app/common.py
COPY models.py /app/models.py
COPY health_routes.py /app/health_routes.py
COPY tasks_routes.py /app/tasks_routes.py
COPY status_codes.py /app/status_codes.py

# 5. Create a non-root user for security
RUN useradd -m -u 1000 appuser && \
    chown -R appuser:appuser /app

# Switch to the non-root user
USER appuser

# 6. Expose the port the app runs on
EXPOSE 8080

# Prevent Python from buffering stdout/stderr (helps with logging)
ENV PYTHONUNBUFFERED=1

# 7. Health Check
# We use the JSON array format ["CMD", ...] to avoid shell issues in slim images.
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD ["python", "-c", "import urllib.request; urllib.request.urlopen('http://localhost:8080/health').read()"]

# 8. Start the application
# Since WORKDIR is /, this command looks for the 'app' folder and runs it as a module.
CMD ["python", "-m", "app"]
