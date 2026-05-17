#!/usr/bin/env bash
# infra/bootstrap.sh
# Crea (si no existen) los recursos previos a Terraform:
#  - Bucket S3 para el state remoto, con versioning + encryption + public-access-block.
# Idempotente: corres este script tantas veces como quieras, no rompe nada.
#
# Uso:
#   chmod +x infra/bootstrap.sh
#   ./infra/bootstrap.sh

set -euo pipefail

# ─── Variables (edítalas) ─────────────────────────────────────────────────────
PROJECT="dkron"
OWNER="tunombre"                          # ← cámbialo, debe ser único globalmente
SUFFIX="2026"                             # ← entropía adicional
REGION="us-east-1"
BUCKET="tfstate-${PROJECT}-${OWNER}-${SUFFIX}"

echo "🪣 Asegurando bucket de state: ${BUCKET} en ${REGION}"

# 1) Crear bucket si no existe (us-east-1 no acepta LocationConstraint)
if aws s3api head-bucket --bucket "${BUCKET}" 2>/dev/null; then
  echo "   ↳ ya existe, salto creación"
else
  aws s3api create-bucket \
    --bucket "${BUCKET}" \
    --region "${REGION}"
  echo "   ↳ creado"
fi

# 2) Versioning (obliga a tener historial del state para recovery)
aws s3api put-bucket-versioning \
  --bucket "${BUCKET}" \
  --versioning-configuration Status=Enabled

# 3) Encryption en reposo (AES256 nativo de S3 — sin coste, sin KMS extra)
aws s3api put-bucket-encryption \
  --bucket "${BUCKET}" \
  --server-side-encryption-configuration '{
    "Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]
  }'

# 4) Bloquear todo acceso público (es state secreto, nunca debe filtrarse)
aws s3api put-public-access-block \
  --bucket "${BUCKET}" \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# 5) Tags consistentes (para FinOps y para el requisito PDF 5.1)
aws s3api put-bucket-tagging \
  --bucket "${BUCKET}" \
  --tagging "TagSet=[
    {Key=Project,Value=${PROJECT}},
    {Key=Environment,Value=prod},
    {Key=Owner,Value=${OWNER}},
    {Key=ManagedBy,Value=bootstrap.sh}
  ]"

echo "✅ Bucket listo: ${BUCKET}"
echo ""
echo "📝 Anota este valor para usarlo en infra/envs/prod/backend.tf:"
echo "   bucket = \"${BUCKET}\""