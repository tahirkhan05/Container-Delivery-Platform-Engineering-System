# Production Multi-Stage Dockerfile with non-root security
FROM python:3.12-slim

WORKDIR /app

# Install curl for healthchecks
RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Security: Non-root user
RUN useradd -m -u 1001 appuser
USER appuser

COPY --chown=appuser:appuser . .

# Pass build-time Git commit SHA as environment variable
ARG GIT_COMMIT_SHA=dev-build
ENV GIT_COMMIT_SHA=${GIT_COMMIT_SHA}
ENV PYTHONUNBUFFERED=1

EXPOSE 8000

HEALTHCHECK --interval=15s --timeout=5s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
