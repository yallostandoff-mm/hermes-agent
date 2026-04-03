#!/bin/bash

# 1. Створюємо папку для конфігу
mkdir -p /root/.hermes

# 2. Генеруємо config.yaml з підтримкою MCP GitHub
# Змінна ${GITHUB_TOKEN} автоматично візьметься з налаштувань Render
cat <<EOF > /root/.hermes/config.yaml
model:
  default: "${MODEL_NAME:-openai/gpt-oss-120b}"
  provider: "openrouter"
  base_url: "https://openrouter.ai/api/v1"

gateway:
  model: "${MODEL_NAME:-openai/gpt-oss-120b}"

mcp_servers:
  github:
    command: "npx"
    args: ["-y", "@modelcontextprotocol/server-github"]
    env:
      GITHUB_PERSONAL_ACCESS_TOKEN: "${GITHUB_TOKEN}"
EOF

# Виводимо частину конфігу в лог для перевірки (без токена для безпеки)
echo "--- Generated Config with MCP ---"
grep -v "TOKEN" /root/.hermes/config.yaml
echo "---------------------------------"

# 3. Запускаємо шлюз
exec hermes gateway run
