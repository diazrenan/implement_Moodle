#!/bin/bash
# =============================================================================
# user_data.sh — Inicializacao automatica da EC2 com Docker + Moodle
# Executado uma unica vez no primeiro boot da instancia EC2.
#
# Variaveis substituidas pelo Terraform templatefile() — sem escape:
#   ${rds_endpoint}, ${rds_port}, ${db_name}, ${db_username},
#   ${db_password}, ${moodle_admin_user}, ${moodle_admin_password},
#   ${moodle_site_name}
#
# Variaveis bash de runtime — com escape $${} para nao serem interpretadas
# pelo templatefile():
#   $${TOKEN}, $${EC2_PUBLIC_DNS}, $${i}, $$(date), $$(seq ...), etc.
#
# Ref: Requisitos 3.7, 3.8, 3.9, 3.10
# =============================================================================

# TODO: Monitore o progresso apos o terraform apply via SSH:
#   ssh ec2-user@<EC2_DNS> -i ~/.ssh/<sua_chave>
#   sudo tail -f /var/log/user-data-moodle.log

set -euo pipefail
exec >> /var/log/user-data-moodle.log 2>&1

echo "=== user_data iniciado em $$(date) ==="

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

echo "=== Docker Compose instalado: $$(docker compose version) ==="

# --- 5. Criar diretorio da aplicacao ---
mkdir -p /opt/moodle

# --- 6. Obter DNS publico da EC2 via IMDSv2 ---
# Deve ocorrer antes da criacao do .env para incluir MOODLE_WWWROOT.
# IMDSv2 e obrigatorio no Amazon Linux 2023 — requer token de sessao.
TOKEN=$$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
EC2_PUBLIC_DNS=$$(curl -s \
  -H "X-aws-ec2-metadata-token: $${TOKEN}" \
  "http://169.254.169.254/latest/meta-data/public-hostname")

echo "=== EC2 DNS: $${EC2_PUBLIC_DNS} ==="

# --- 7. Clonar repositorio para obter o Dockerfile do professor ---
# TODO: Substitua pela URL do seu fork antes do terraform apply
REPO_URL="https://github.com/diazrenan/implement_Moodle.git"
git clone --depth=1 "$${REPO_URL}" /tmp/moodle-repo
cp /tmp/moodle-repo/docker/Dockerfile           /opt/moodle/Dockerfile
cp /tmp/moodle-repo/docker/docker-entrypoint.sh /opt/moodle/docker-entrypoint.sh
chmod +x /opt/moodle/docker-entrypoint.sh
rm -rf /tmp/moodle-repo

# --- 8. Criar .env com variaveis injetadas pelo Terraform templatefile() ---
# As variaveis $${...} abaixo sao substituidas pelo Terraform antes do deploy.
# MOODLE_WWWROOT usa $${EC2_PUBLIC_DNS}, que e uma variavel bash de runtime.
cat > /opt/moodle/.env <<ENVEOF
MOODLE_DATABASE_TYPE=pgsql
MOODLE_DATABASE_HOST=${rds_endpoint}
MOODLE_DATABASE_PORT_NUMBER=${rds_port}
MOODLE_DATABASE_NAME=${db_name}
MOODLE_DATABASE_USER=${db_username}
MOODLE_DATABASE_PASSWORD=${db_password}
MOODLE_USERNAME=${moodle_admin_user}
MOODLE_PASSWORD=${moodle_admin_password}
MOODLE_SITE_NAME=${moodle_site_name}
MOODLE_WWWROOT=http://$${EC2_PUBLIC_DNS}
ENVEOF

echo "=== .env criado com MOODLE_WWWROOT=http://$${EC2_PUBLIC_DNS} ==="

# --- 9. Criar docker-compose.yml para EC2 ---
# Sem servico db: o banco e o RDS externo.
# Porta 80:80 — SG_EC2 libera HTTP na porta 80.
cat > /opt/moodle/docker-compose.yml <<'COMPOSEEOF'
services:
  moodle:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: moodle
    restart: unless-stopped
    ports:
      - "80:80"
    env_file:
      - .env
    volumes:
      - moodle_data:/var/www/html
      - moodle_www:/var/moodledata

volumes:
  moodle_data:
  moodle_www:
COMPOSEEOF

# --- 10. Build da imagem Moodle (pode levar 10-20 minutos) ---
echo "=== Iniciando docker build em $$(date) ==="
cd /opt/moodle
docker compose build moodle
echo "=== Build concluido em $$(date) ==="

# --- 11. Subir o conteiner ---
# O docker-entrypoint.sh detecta ausencia de config.php e executa
# o install.php automaticamente no primeiro boot — nao e necessario
# chamar o instalador novamente aqui.
docker compose up -d
echo "=== Conteiner iniciado em $$(date) ==="


# --- 12. Aguardar conclusao da instalacao do Moodle ---
# O entrypoint instala o Moodle e cria o config.php.
echo "=== Aguardando instalacao do Moodle pelo entrypoint... ==="
INSTALL_OK=0

for i in $$(seq 1 30); do
  if docker compose exec -T moodle test -f /var/www/html/config.php 2>/dev/null; then
    echo "=== Moodle instalado com sucesso na tentativa $${i} ==="
    INSTALL_OK=1
    break
  fi

  echo "=== Aguardando config.php... tentativa $${i}/30 ==="
  sleep 30
done

if [ "$${INSTALL_OK}" -eq 0 ]; then
  echo "=== ERRO: config.php nao encontrado apos 15 minutos. Verifique os logs. ==="
  docker compose logs moodle >> /var/log/user-data-moodle.log 2>&1
  exit 1
fi


# --- 13. Finalizar ---
echo "=== user_data concluido com sucesso em $$(date) ==="