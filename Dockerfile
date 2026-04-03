FROM debian:13.4

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential nodejs npm python3 python3-pip ripgrep ffmpeg gcc python3-dev libffi-dev curl && \
    rm -rf /var/lib/apt/lists/*

COPY . /opt/hermes
WORKDIR /opt/hermes

# ДОДАНО: "python-telegram-bot[webhooks]" — це виправить твою помилку
RUN pip install --no-cache-dir -e ".[all]" "python-telegram-bot[webhooks]" --break-system-packages && \
    npm install --prefer-offline --no-audit && \
    npx playwright install --with-deps chromium --only-shell && \
    cd /opt/hermes/scripts/whatsapp-bridge && \
    npm install --prefer-offline --no-audit && \
    npm cache clean --force

WORKDIR /opt/hermes

RUN mkdir -p /opt/data && chmod 777 /opt/data
ENV HERMES_HOME=/opt/data
VOLUME [ "/opt/data" ]

# Запуск шлюзу
CMD ["hermes", "gateway"]
