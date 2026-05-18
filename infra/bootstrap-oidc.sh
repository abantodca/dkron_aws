#!/usr/bin/env bash
# infra/bootstrap-oidc.sh
# Crea (si no existen) el OIDC provider de GitHub Actions y un rol IAM
# que el pipeline pueda asumir vía AssumeRoleWithWebIdentity.
# Idempotente: corres este script varias veces sin romper nada.
#
# Uso:
#   chmod +x infra/bootstrap-oidc.sh
#   ./infra/bootstrap-oidc.sh tunombre/dkron-aws

set -euo pipefail

GITHUB_REPO="${1:-}"                      # ej: tunombre/dkron-aws
if [[ -z "${GITHUB_REPO}" ]]; then
  echo "Uso: ./infra/bootstrap-oidc.sh <owner>/<repo>"
  echo "Ej:   ./infra/bootstrap-oidc.sh juanperez/dkron-aws"
  exit 1
fi

PROJECT="dkron"
REGION="us-east-1"
ROLE_NAME="github-actions-${PROJECT}"
ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
OIDC_URL="token.actions.githubusercontent.com"
OIDC_ARN="arn:aws:iam::${ACCOUNT_ID}:oidc-provider/${OIDC_URL}"

# ─── 1) OIDC provider ────────────────────────────────────────────────────────
if aws iam get-open-id-connect-provider --open-id-connect-provider-arn "${OIDC_ARN}" >/dev/null 2>&1; then
  echo "✅ OIDC provider ya existe: ${OIDC_ARN}"
else
  echo "🔧 Creando OIDC provider..."
  aws iam create-open-id-connect-provider \
    --url "https://${OIDC_URL}" \
    --client-id-list "sts.amazonaws.com" \
    --thumbprint-list "6938fd4d98bab03faadb97b34396831e3780aea1"
  echo "   ↳ creado"
fi

# ─── 2) Trust policy del rol GHA (solo del repo declarado) ───────────────────
TRUST_POLICY=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": { "Federated": "${OIDC_ARN}" },
    "Action": "sts:AssumeRoleWithWebIdentity",
    "Condition": {
      "StringEquals": {
        "${OIDC_URL}:aud": "sts.amazonaws.com"
      },
      "StringLike": {
        "${OIDC_URL}:sub": "repo:${GITHUB_REPO}:*"
      }
    }
  }]
}
EOF
)

# ─── 3) Crear o actualizar el rol GHA ────────────────────────────────────────
if aws iam get-role --role-name "${ROLE_NAME}" >/dev/null 2>&1; then
  echo "✅ Rol ya existe: ${ROLE_NAME} — actualizando trust policy"
  aws iam update-assume-role-policy \
    --role-name "${ROLE_NAME}" \
    --policy-document "${TRUST_POLICY}"
else
  echo "🔧 Creando rol ${ROLE_NAME}..."
  aws iam create-role \
    --role-name "${ROLE_NAME}" \
    --assume-role-policy-document "${TRUST_POLICY}" \
    --description "Rol asumible por GitHub Actions vía OIDC para CI/CD"
  echo "   ↳ creado"
fi

# ─── 4) PowerUserAccess (suficiente para el alcance del proyecto) ────────────
aws iam attach-role-policy \
  --role-name "${ROLE_NAME}" \
  --policy-arn "arn:aws:iam::aws:policy/PowerUserAccess"

# ─── 5) Permisos IAM:* — necesarios para crear los roles del módulo compute ──
# Justificación reporte B.5: PowerUser excluye iam:*, pero Terraform crea roles
# (instance profile EC2, SGs). Acotamos a iam:* sobre la cuenta propia.
aws iam put-role-policy \
  --role-name "${ROLE_NAME}" \
  --policy-name "TerraformIAMManage" \
  --policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Action": "iam:*",
      "Resource": "*"
    }]
  }'

# ─── 6) Tags ─────────────────────────────────────────────────────────────────
aws iam tag-role \
  --role-name "${ROLE_NAME}" \
  --tags "Key=Project,Value=${PROJECT}" \
         "Key=Environment,Value=prod" \
         "Key=ManagedBy,Value=bootstrap-oidc.sh"

ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/${ROLE_NAME}"
echo ""
echo "✅ Setup completo."
echo ""
echo "📋 Configura este secret en GitHub:"
echo "   Settings → Secrets and variables → Actions → New repository secret"
echo ""
echo "   Name:  AWS_ROLE_ARN"
echo "   Value: ${ROLE_ARN}"
echo ""
echo "📋 Y este environment para aprobación manual:"
echo "   Settings → Environments → New environment → 'production'"
echo "   Marca: Required reviewers → agrégate"