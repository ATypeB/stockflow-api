#!/bin/bash
# Executado NA instância EC2 (enviado pelo AWS Systems Manager).
# Baixa a imagem do container e substitui a versão em execução.
# Requer a variável IMAGE, ex.: ghcr.io/atypeb/stockflow-api:<sha>
set -euo pipefail

export HOME="${HOME:-/root}"
: "${IMAGE:?Variável IMAGE não definida}"
NAME="stockflow-api"

echo "==> Baixando imagem ${IMAGE}"
docker pull "${IMAGE}"

echo "==> Removendo container anterior (se existir)"
docker rm -f "${NAME}" 2>/dev/null || true

echo "==> Iniciando novo container"
docker run -d \
  --name "${NAME}" \
  --restart unless-stopped \
  -p 3000:3000 \
  "${IMAGE}"

echo "==> Aguardando a API responder"
for i in $(seq 1 15); do
  if curl -fsS http://localhost:3000/ > /dev/null; then
    echo "API saudável (tentativa ${i})"
    docker ps --filter "name=${NAME}"
    docker image prune -f > /dev/null
    exit 0
  fi
  sleep 2
done

echo "ERRO: a API não respondeu a tempo. Últimos logs do container:"
docker logs "${NAME}" --tail 50
exit 1
