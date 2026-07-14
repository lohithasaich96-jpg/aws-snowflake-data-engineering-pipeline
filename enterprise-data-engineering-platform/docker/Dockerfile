# Runtime image for the src/ jobs (ingestion, validation, snowflake loader).
FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONPATH=/app

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential procps \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY src/ ./src/
COPY config/ ./config/

RUN useradd --create-home appuser
USER appuser

ENTRYPOINT ["python", "-m"]
CMD ["src.ingestion.s3_ingest"]
