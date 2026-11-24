#!/bin/bash
# =============================================================================
# user_data.sh — Inicializacao automatica da EC2 com Docker + Moodle
# Executado uma unica vez no primeiro boot da instancia EC2.
# Variaveis injetadas pelo Terraform templatefile():
#   rds_endpoint, rds_port, db_name, db_username, db_password,
#   moodle_admin_user, moodle_admin_password, moodle_site_name
# Ref: Requisitos 3.7, 3.8, 3.9, 3.10
# =============================================================================

# TODO: Monitore o progresso via SSH apos o terraform apply:
#   ssh ec2-user@<EC2_DNS> -i ~/.ssh/<sua_chave>
#   sudo tail -f /var/log/user-data-moodle.log

set -euo pipefail
exec >> /var/log/user-data-moodle.log 2>&1

echo "=== user_data iniciado em $(date) ==="

# --- 1. Atualizar pacotes ---
dnf update -y

# --- 2. Instalar Docker e Git ---
dnf install -y docker git

# --- 3. Habilitar e iniciar o servico Docker ---
systemctl enable --now docker

# --- 4. Instalar Docker Compose v2 plugin ---
mkdir -p /usr/local/lib/docker/cli-plugins
curl -fsSL \
  "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64" \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# --- 5. Criar diretorio da aplicacao ---
mkdir -p /opt/moodle

# --- 6. Copiar Dockerfile do repositorio ---
# Clona apenas o diretorio docker/ do repositorio para obter o Dockerfile do professor
# Ajuste a URL do repositorio se necessario
REPO_URL="https://github.com/diazrenan/implement_Moodle.git"
git clone --depth=1 "$REPO_URL" /tmp/moodle-repo
cp /tmp/moodle-repo/docker/Dockerfile /opt/moodle/Dockerfile
cp /tmp/moodle-repo/docker/docker-entrypoint.sh /opt/moodle/docker-entrypoint.sh
chmod +x /opt/moodle/docker-entrypoint.sh
rm -rf /tmp/moodle-repo

# --- 7. Criar .env com variaveis injetadas pelo Terraform templatefile() ---
cat > /opt/moodle/.env <<'ENVEOF'
MOODLE_DATABASE_TYPE=pgsql
MOODLE_DATABASE_HOST=${rds_endpoint}
MOODLE_DATABASE_PORT_NUMBER=${rds_port}
MOODLE_DATABASE_NAME=${db_name}
MOODLE_DATABASE_USER=${db_username}
MOODLE_DATABASE_PASSWORD=${db_password}
MOODLE_USERNAME=${moodle_admin_user}
MOODLE_PASSWORD=${moodle_admin_password}
MOODLE_SITE_NAME=${moodle_site_name}
ENVEOF

# --- 8. Criar docker-compose.yml para EC2 (sem servico db — usa RDS externo) ---
cat > /opt/moodle/docker-compose.yml <<'COMPOSEEOF'
services:
  moodle:
    build:
      context: .
      dockerfile: Dockerfile
    restart: unless-stopped
    ports:
      - "80:80"
    env_file:
      - .env
    environment:
      - MOODLE_DATABASE_TYPE=pgsql
    volumes:
      - moodle_data:/var/www/html
      - moodle_www:/var/moodledata

volumes:
  moodle_data:
  moodle_www:
COMPOSEEOF

# --- 9. Build da imagem Moodle (pode levar 10-20 minutos) ---
echo "=== Iniciando docker build em $(date) ==="
cd /opt/moodle
docker compose build moodle

# --- 10. Subir o contêiner ---
docker compose up -d
echo "=== Conteiner iniciado em $(date) ==="

# --- 11. Aguardar Apache iniciar ---
sleep 60

# --- 12. Obter DNS publico da EC2 via IMDSv2 ---
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
EC2_PUBLIC_DNS=$(curl -s \
  -H "X-aws-ec2-metadata-token: $TOKEN" \
  "http://169.254.169.254/latest/meta-data/public-hostname")

echo "=== EC2 DNS: $EC2_PUBLIC_DNS ==="

# --- 13. Instalar Moodle via CLI (nao-interativo) ---
echo "=== Iniciando instalacao Moodle CLI em $(date) ==="
docker exec moodle php /var/www/html/admin/cli/install.php \
  --non-interactive \
  --agree-license \
  --wwwroot="http://$EC2_PUBLIC_DNS" \
  --dataroot=/var/moodledata \
  --dbtype=pgsql \
  --dbhost="${rds_endpoint}" \
  --dbport="${rds_port}" \
  --dbname="${db_name}" \
  --dbuser="${db_username}" \
  --dbpass="${db_password}" \
  --fullname="${moodle_site_name}" \
  --shortname="moodle" \
  --adminuser="${moodle_admin_user}" \
  --adminpass="${moodle_admin_password}" \
  --adminemail="admin@example.com"

# --- 14. Finalizar ---
echo "=== user_data concluido em $(date) ==="
