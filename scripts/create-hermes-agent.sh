#!/usr/bin/env sh
set -euo pipefail
mkdir -p ~/hermes
cd ~/hermes
if [ -f "$COMPOSE_FILE" ]; then
    echo "Existing docker-compose.yml found"
    BACKUP="${COMPOSE_FILE}.bak.$(date +%Y%m%d_%H%M%S)"
    cp "$COMPOSE_FILE" "$BACKUP"
    echo "Backup created: $BACKUP"
    read -p "Replace existing docker-compose.yml? [y/N] " REPLY
    case "$REPLY" in
        y|Y|yes|YES)
            echo "Replacing compose file..."
            ;;
        *)
            echo "Keeping existing compose file"
            exit 0
            ;;
    esac
fi
#cat > .env <<EOF
#MODEL_NAME=${MODEL_NAME}
#EOF

cat > docker-compose.yml <<'EOF'
services:
  ollama:
    image: ollama/ollama:latest
    container_name: ollama
    ports:
      - "11434:11434"
    #environment:
       #HTTP_PROXY: http://proxyip:port
       #HTTPS_PROXY: http://proxyip:port
       #NO_PROXY: localhost,127.0.0.1,ollama,hermes
    volumes:
      - ollama_data:/root/.ollama
    restart: unless-stopped

  hermes:
    image: nousresearch/hermes-agent:latest
    container_name: hermes
    command: ["sleep","infinity"]
    ports:
      - "9119:9119"
    environment:
      OPENAI_BASE_URL: http://ollama:11434/v1
      OPENAI_API_KEY: local
      DEFAULT_MODEL: ${MODEL_NAME}
      HERMES_DASHBOARD: "true"
      HERMES_DASHBOARD_INSECURE: "true"
      HERMES_DASHBOARD_HOST: "0.0.0.0"
      HERMES_DASHBOARD_PORT: "9119"
      GATEWAY_ALLOW_ALL_USERS: "true"
      #HTTP_PROXY: http://proxyip:port
      #HTTPS_PROXY: http://proxyip:port
      #NO_PROXY: localhost,127.0.0.1,ollama,hermes
    volumes:
      - hermes_data:/opt/data
    depends_on:
      - ollama
    restart: unless-stopped

  open-webui:
    image: ghcr.io/open-webui/open-webui:main
    container_name: open-webui
    ports:
      - "3000:8080"
    environment:
      OLLAMA_BASE_URL: http://ollama:11434
    volumes:
      - openwebui_data:/app/backend/data
    depends_on:
      - ollama
    restart: unless-stopped

volumes:
  ollama_data:
  hermes_data:
  openwebui_data:
EOF

docker-compose up -d

sleep 5s

echo "Waiting for Ollama API..."

until docker exec hermes python3 -c "
import requests,sys
try:
 r=requests.Session()
 r.trust_env=False
 x=r.get('http://ollama:11434/api/tags',timeout=5)
 sys.exit(0 if x.status_code==200 else 1)
except Exception:
 sys.exit(1)
"
do
  sleep 5
done

echo "Pulling model $MODEL_NAME"

docker exec -e OLLAMA_HOST=http://127.0.0.1:11434 ollama \
  ollama pull "$MODEL_NAME" || true

echo "Installed models:"

docker exec -e OLLAMA_HOST=http://127.0.0.1:11434 ollama \
  ollama list

sleep 5s

docker exec hermes mkdir -p /opt/data

docker exec hermes sh -c 'cat >/opt/data/config.yaml <<EOF
model: ${MODEL_NAME}
     default: llama3.1:8b
     provider: custom
     base_url: http://ollama:11434/v1
     api_key: local
tools:
  disabled_toolsets:
    - smart-home
    - social-media
    - mlops
    - email
    - github
memory:
  provider: local
EOF
'
echo
echo "Deployment complete"
echo
echo "Open WebUI : http://localhost:3000"
echo "Hermes UI  : http://localhost:9119"
echo "Model      : ${MODEL_NAME}"
