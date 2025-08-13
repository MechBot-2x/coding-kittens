#!/bin/bash
# Versión mejorada con manejo de errores

TOKEN_FILE=~/.secrets/github_token
API_BASE="https://api.github.com"

# Verifica token
[ ! -f "$TOKEN_FILE" ] && { echo "❌ Token no encontrado"; exit 1; }
GITHUB_TOKEN=$(cat "$TOKEN_FILE")

# Manejo de parámetros
[ -z "$1" ] && { echo "Uso: $0 <endpoint> [json_data]"; exit 1; }

# Ejecuta la petición
curl -sS -w "\nHTTP: %{http_code}" \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Content-Type: application/json" \
  ${2:+-d "$2"} \
  "$API_BASE/$1"
