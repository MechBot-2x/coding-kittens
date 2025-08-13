#!/bin/bash
# Verifica dependencias
for cmd in python npm git curl jq; do
    if ! command -v $cmd >/dev/null 2>&1; then
        echo "❌ Error: $cmd no está instalado" >&2
        exit 1
    fi
done

# Configura Python
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# Configura Node.js
cd frontend
npm install
cd ..

echo -e "\n✅ \e[32mConfiguración completada\e[0m"
echo "Para activar el entorno: source .venv/bin/activate"
echo "Para iniciar frontend: cd frontend && npm run dev"
