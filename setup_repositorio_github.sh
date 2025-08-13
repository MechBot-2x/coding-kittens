#!/bin/bash
# setup_repositorio_github.sh - Script seguro para crear repositorios

# Configuración
ORGANIZACION="MechBot-2x"
NOMBRE_REPO="coding-kittens"
RAMA_PRINCIPAL="main"
DESCRIPCION="Programación cuántica con gatos 🐱💻"
VISIBILIDAD="false"  # false = público, true = privado

# Función para obtener token de forma segura
obtener_token() {
  if [ -z "$GITHUB_TOKEN" ]; then
    if [ -f ".env" ]; then
      source .env
    else
      echo -n "Ingrese su Token de Acceso Personal de GitHub: "
      read -s GITHUB_TOKEN
      echo
    fi
  fi
}

# Función para verificar el token
verificar_token() {
  echo "Verificando token de GitHub..."
  respuesta=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/user)

  [ "$respuesta" -eq 200 ] && echo "✅ Token válido" || { echo "❌ Token inválido (HTTP $respuesta)"; return 1; }
}

# Función para crear el repositorio
crear_repositorio() {
  echo "Creando repositorio $NOMBRE_REPO en $ORGANIZACION..."
  
  respuesta=$(curl -s -o respuesta.json -w "%{http_code}" \
    -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/orgs/$ORGANIZACION/repos \
    -d '{
      "name": "'$NOMBRE_REPO'",
      "description": "'"$DESCRIPCION"'",
      "private": '$VISIBILIDAD',
      "auto_init": true,
      "default_branch": "'$RAMA_PRINCIPAL'"
    }')

  if [ "$respuesta" -eq 201 ]; then
    echo "✅ Repositorio creado exitosamente"
    URL_REPO=$(jq -r '.html_url' respuesta.json)
    echo "🔗 $URL_REPO"
    rm respuesta.json
  else
    echo "❌ Error al crear repositorio (HTTP $respuesta)"
    [ -f "respuesta.json" ] && jq . respuesta.json
    rm -f respuesta.json
    return 1
  fi
}

# Función para configurar Git
configurar_git() {
  if [ -d .git ]; then
    echo "Configurando repositorio local..."
    git remote add origin https://$GITHUB_TOKEN@github.com/$ORGANIZACION/$NOMBRE_REPO.git
    git branch -M $RAMA_PRINCIPAL
    git push -u origin $RAMA_PRINCIPAL
    echo "✅ Configuración Git completada"
  else
    echo "⚠️ No es un repositorio Git. Ejecuta 'git init' primero."
  fi
}

# Ejecución principal
obtener_token
if verificar_token; then
  if crear_repositorio; then
    configurar_git
  fi
fi

# Limpieza de seguridad
unset GITHUB_TOKEN
echo "🚀 Configuración completada!"
