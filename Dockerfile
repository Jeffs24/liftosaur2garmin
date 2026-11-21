FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    HOME=/data

WORKDIR /app

COPY pyproject.toml README.md ./
COPY src/ src/

RUN pip install . \
    && useradd --uid 1000 --home-dir /data --no-create-home l2g \
    && mkdir -p /data \
    && chown l2g:l2g /data

USER l2g

# Config (~/.liftosaur2garmin), SQLite DB and Garmin tokens (~/.garminconnect) live here.
VOLUME ["/data"]

EXPOSE 8123

HEALTHCHECK --interval=60s --timeout=5s --start-period=20s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8123/login', timeout=4)" || exit 1

ENTRYPOINT ["liftosaur2garmin"]
CMD ["serve", "--host", "0.0.0.0", "--port", "8123"]
