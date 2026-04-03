FROM debian:13.4

# 1. Встановлення системних залежностей
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential nodejs npm python3 python3-pip ripgrep ffmpeg gcc python3-dev libffi-dev curl && \
    rm -rf /var/lib/apt/lists/*

COPY . /opt/hermes
WORKDIR /opt/hermes

# 2. Встановлення Python та Node залежностей
RUN pip install --no-cache-dir -e ".[all]" "python-telegram-bot[webhooks]" --break-system-packages && \
    npm install --prefer-offline --no-audit && \
    npx playwright install --with-deps chromium --only-shell && \
    cd /opt/hermes/scripts/whatsapp-bridge && \
    npm install --prefer-offline --no-audit && \
    npm cache clean --force

WORKDIR /opt/hermes

# 3. Створення структури папок для конфігурації
RUN mkdir -p /opt/data/.hermes && chmod -R 777 /opt/data

# 4. СТВОРЕННЯ CONFIG.YAML (вирішуємо проблему No models provided)
# Ми записуємо налаштування моделі та провайдера безпосередньо у файл
RUN echo 'model:' > /opt/data/.hermes/config.yaml && \
    echo '  default: "qwen/qwen-2.5-72b-instruct"' >> /opt/data/.hermes/config.yaml && \
    echo '  provider: "openrouter"' >> /opt/data/.hermes/config.yaml && \
    echo 'gateway:' >> /opt/data/.hermes/config.yaml && \
    echo '  model: "qwen/qwen-2.5-72b-instruct"' >> /opt/data/.hermes/config.yaml

# 5. Налаштування оточення
ENV HERMES_HOME=/opt/data
ENV MODEL_NAME=qwen/qwen-2.5-72b-instruct
ENV HERMES_MODEL=qwen/qwen-2.5-72b-instruct

VOLUME [ "/opt/data" ]

# 6. Запуск шлюзу
CMD ["hermes", "gateway", "run"]
