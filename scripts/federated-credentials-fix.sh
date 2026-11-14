
#!/usr/bin/env bash
set -euo pipefail

RG="tfstate-rg"
IDENTITY="tfstate-github-uami"
ISSUER="https://token.actions.githubusercontent.com"

PREFIX="repo:AgbVal@52071388/devops-demo@1457591900"

for ENV in terraform-plan terraform-apply; do
  NAME="github-${ENV}-immutable"
  SUBJECT="${PREFIX}:environment:${ENV}"

  echo "Checking $NAME..."

  EXISTING=$(az identity federated-credential show \
    --resource-group "$RG" \
    --identity-name "$IDENTITY" \
    --name "$NAME" \
    --query subject \
    -o tsv 2>/dev/null || true)

  if [[ -n "$EXISTING" ]]; then
    if [[ "$EXISTING" != "$SUBJECT" ]]; then
      echo "ERROR: $NAME has a different subject."
      exit 1
    fi
    echo "Already configured: $NAME"
    continue
  fi

  az identity federated-credential create \
    --resource-group "$RG" \
    --identity-name "$IDENTITY" \
    --name "$NAME" \
    --issuer "$ISSUER" \
    --subject "$SUBJECT" \
    --audiences "api://AzureADTokenExchange" \
    --output none

  echo "Created $NAME"
done
