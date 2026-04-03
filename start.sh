#!/bin/bash

# 1. Створюємо папку для конфігу
mkdir -p /root/.hermes

# Визначаємо модель: беремо з Render або дефолтну, і додаємо :free
# Якщо в Render вже написано з :free, воно просто додасть ще раз (OpenRouter зазвичай це розуміє),
# але краще, щоб у Render була просто чиста назва моделі.
BASE_MODEL="${MODEL_NAME:-openai/gpt-oss-120b}"
FINAL_MODEL="${BASE_MODEL}:free"

# 2. Генеруємо config.yaml
cat <<EOF > /root/.hermes/config.yaml
model:
  default: "$FINAL_MODEL"
  provider: "openrouter"
  base_url: "https://openrouter.ai/api/v1"

gateway:
  model: "$FINAL_MODEL"

mcp_servers:
  # MCP GitHub для роботи з кодом
  github:
    command: "npx"
    args: ["-y", "@modelcontextprotocol/server-github"]
    env:
      GITHUB_PERSONAL_ACCESS_TOKEN: "${GITHUB_TOKEN}"

  # MCP Filesystem для створення презентацій та файлів
  filesystem:
    command: "npx"
    args: ["-y", "@modelcontextprotocol/server-filesystem", "/opt/data"]
EOF

# Авторизація GitHub CLI через токен
if [ -n "$GITHUB_TOKEN" ]; then
    echo "$GITHUB_TOKEN" | gh auth login --with-token 2>/dev/null || true
    echo "✅ GitHub CLI authorized"
fi

# Вивід конфігу для логів (без токена)
echo "--- Generated Config (FREE MODEL VERSION) ---"
echo "Model ID: $FINAL_MODEL"
grep -v "TOKEN" /root/.hermes/config.yaml
echo "---------------------------------------------"

# 3. Запускаємо шлюз
exec hermes gateway run
