#!/bin/bash
# Executado no pipeline (GitHub Actions) ou na máquina do desenvolvedor.
# Envia o scripts/deploy.sh para a EC2 via AWS Systems Manager (sem abrir SSH).
# Requer: IMAGE, INSTANCE_ID e credenciais AWS no ambiente
# (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN).
set -euo pipefail

: "${IMAGE:?Variável IMAGE não definida}"
: "${INSTANCE_ID:?Variável INSTANCE_ID não definida}"
REGION="${AWS_DEFAULT_REGION:-us-east-1}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PARAMS="$(mktemp)"

# Monta o parâmetro do SSM: define IMAGE e anexa o conteúdo do deploy.sh
{
  echo "export IMAGE='${IMAGE}'"
  cat "${SCRIPT_DIR}/deploy.sh"
} | jq -Rs '{commands: split("\n")}' > "${PARAMS}"

echo "==> Enviando comando de deploy para ${INSTANCE_ID}"
CMD_ID="$(aws ssm send-command \
  --region "${REGION}" \
  --instance-ids "${INSTANCE_ID}" \
  --document-name "AWS-RunShellScript" \
  --comment "StockFlow deploy" \
  --parameters "file://${PARAMS}" \
  --query "Command.CommandId" \
  --output text)"
echo "Comando SSM: ${CMD_ID}"

aws ssm wait command-executed \
  --region "${REGION}" \
  --command-id "${CMD_ID}" \
  --instance-id "${INSTANCE_ID}" || true

RESULT="$(aws ssm get-command-invocation \
  --region "${REGION}" \
  --command-id "${CMD_ID}" \
  --instance-id "${INSTANCE_ID}" \
  --output json)"

echo "----- Saída do deploy -----"
echo "${RESULT}" | jq -r '.StandardOutputContent'
echo "----- Erros -----"
echo "${RESULT}" | jq -r '.StandardErrorContent'

STATUS="$(echo "${RESULT}" | jq -r '.Status')"
echo "Status final: ${STATUS}"
[ "${STATUS}" = "Success" ]
