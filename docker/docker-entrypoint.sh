#!/bin/bash
set -euo pipefail

# TODO: Este script verifica se o Moodle ja esta instalado antes de rodar.
# Ajuste as variaveis de ambiente conforme necessario no docker/.env

CONFIG_FILE="/var/www/html/config.php"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "[entrypoint] Iniciando instalacao nao-interativa do Moodle..."

    # Aguardar o PostgreSQL aceitar conexoes (ate 150s = 30 tentativas x 5s)
    echo "[entrypoint] Aguardando PostgreSQL em ${MOODLE_DATABASE_HOST}:${MOODLE_DATABASE_PORT_NUMBER:-5432}..."
    for i in $(seq 1 30); do
    if pg_isready -h "${MOODLE_DATABASE_HOST}" -p "${MOODLE_DATABASE_PORT_NUMBER:-5432}" -U "${MOODLE_DATABASE_USER}" -d "${MOODLE_DATABASE_NAME}" -q; then

            echo "[entrypoint] PostgreSQL disponivel."
            break
        fi
        if [ "$i" -eq 30 ]; then
            echo "[entrypoint] ERRO: PostgreSQL nao respondeu apos 30 tentativas."
            exit 1
        fi
        echo "[entrypoint] Tentativa $i/30 - aguardando 5s..."
        sleep 5
    done

    php /var/www/html/admin/cli/install.php \
        --non-interactive \
        --agree-license \
        --wwwroot="${MOODLE_WWWROOT:-http://localhost:8080}" \
        --dataroot=/var/moodledata \
        --dbtype=pgsql \
        --dbhost="${MOODLE_DATABASE_HOST}" \
        --dbport="${MOODLE_DATABASE_PORT_NUMBER:-5432}" \
        --dbname="${MOODLE_DATABASE_NAME}" \
        --dbuser="${MOODLE_DATABASE_USER}" \
        --dbpass="${MOODLE_DATABASE_PASSWORD}" \
        --fullname="${MOODLE_SITE_NAME:-Moodle Challenge}" \
        --shortname="moodle" \
        --adminuser="${MOODLE_USERNAME:-admin}" \
        --adminpass="${MOODLE_PASSWORD}" \
        --adminemail="admin@example.com"

    echo "[entrypoint] Instalacao concluida."
else
    echo "[entrypoint] Moodle ja instalado - pulando instalacao."
fi

echo "[entrypoint] Iniciando Apache..."
exec apache2-foreground