FROM debian:13.4

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential nodejs npm python3 python3-pip ripgrep ffmpeg gcc python3-dev libffi-dev curl && \
    rm -rf /var/lib/apt/lists/*

COPY . /opt/hermes
WORKDIR /opt/hermes

# Install Python and Node dependencies
RUN pip install --no-cache-dir -e ".[all]" "python-telegram-bot[webhooks]" --break-system-packages && \
    npm install --prefer-offline --no-audit && \
    npx playwright install --with-deps chromium --only-shell && \
    cd /opt/hermes/scripts/whatsapp-bridge && \
    npm install --prefer-offline --no-audit && \
    npm cache clean --force

WORKDIR /opt/hermes

RUN mkdir -p /opt/data && chmod 777 /opt/data

# Прописуємо модель прямо тут, щоб вона точно була доступна
ENV MODEL_NAME=qwen/qwen-2.5-72b-instruct
ENV HERMES_MODEL=qwen/qwen-2.5-72b-instruct
ENV HERMES_HOME=/opt/data

VOLUME [ "/opt/data" ]

# ВИПРАВЛЕНО: Додано "run" перед запуском
CMD ["hermes", "gateway", "run"]
