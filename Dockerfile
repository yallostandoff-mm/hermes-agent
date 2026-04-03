FROM debian:13.4

# 1. Встановлення системних залежностей + GitHub CLI
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential nodejs npm python3 python3-pip ripgrep ffmpeg gcc python3-dev libffi-dev curl git ca-certificates gnupg && \
    # Додаємо репозиторій GitHub CLI (корисно для агента)
    mkdir -p -m 0755 /etc/apt/keyrings && \
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /etc/apt/keyrings/githubcli-archive-keyring.gpg && \
    chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && \
    apt-get install -y gh && \
    rm -rf /var/lib/apt/lists/*

COPY . /opt/hermes
WORKDIR /opt/hermes

# 2. Встановлення Python та Node залежностей
# Додано python-pptx для створення презентацій
RUN pip install --no-cache-dir -e ".[all]" "python-telegram-bot[webhooks]" python-pptx --break-system-packages && \
    npm install --prefer-offline --no-audit && \
    npx playwright install --with-deps chromium --only-shell && \
    cd /opt/hermes/scripts/whatsapp-bridge && \
    npm install --prefer-offline --no-audit && \
    npm cache clean --force

# Створюємо папку для збереження презентацій та даних
RUN mkdir -p /opt/data && chmod 777 /opt/data

# Робимо скрипт запуску виконуваним
RUN chmod +x /opt/hermes/start.sh

# Налаштування змінних
ENV HERMES_HOME=/opt/data
ENV PORT=10000

CMD ["/opt/hermes/start.sh"]
