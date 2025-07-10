#!/bin/bash

# --- Variáveis de Configuração SSH ---
# Porta SSH: Altere para uma porta diferente de 22 para segurança adicional (ex: 2222)
SSH_PORT="22" 
# Login de Root: 'no' para desativar (RECOMENDADO), 'yes' para permitir (NÃO RECOMENDADO)
PERMIT_ROOT_LOGIN="no"
# Autenticação por Senha: 'no' para desativar (RECOMENDADO com chave SSH), 'yes' para permitir
PASSWORD_AUTHENTICATION="no" 
# Autenticação por Chave SSH: 'yes' para ativar (RECOMENDADO)
PUBKEY_AUTHENTICATION="yes"
# Tempo limite de inatividade em segundos (ex: 300 = 5 minutos)
CLIENT_ALIVE_INTERVAL=300
CLIENT_ALIVE_COUNT_MAX=3

# --- Verificações Iniciais ---
if [ "$EUID" -ne 0 ]; then
    echo "❌ Este script deve ser executado como root (use sudo)."
    exit 1
fi

echo "=== [1/6] Instalando o OpenSSH Server ==="
apt update
apt install -y openssh-server

if [ $? -ne 0 ]; then
    echo "❌ Falha ao instalar o openssh-server. Verifique sua conexão e repositórios."
    exit 1
fi

echo "=== [2/6] Fazendo backup do arquivo de configuração original do SSH ==="
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak_$(date +%Y%m%d%H%M%S)

echo "=== [3/6] Configurando o SSH para maior segurança ==="

# Edita o arquivo sshd_config
# A forma mais segura é reescrever partes do arquivo ou usar sed para substituir linhas específicas.
# Aqui vamos usar sed para garantir que as linhas existam ou sejam atualizadas.

# Altera a porta SSH
sed -i "s/^#\?Port .*/Port ${SSH_PORT}/" /etc/ssh/sshd_config
# Desativa o login de root (se configurado)
sed -i "s/^#\?PermitRootLogin .*/PermitRootLogin ${PERMIT_ROOT_LOGIN}/" /etc/ssh/sshd_config
# Desativa a autenticação por senha (se configurado)
sed -i "s/^#\?PasswordAuthentication .*/PasswordAuthentication ${PASSWORD_AUTHENTICATION}/" /etc/ssh/sshd_config
# Ativa a autenticação por chave pública
sed -i "s/^#\?PubkeyAuthentication .*/PubkeyAuthentication ${PUBKEY_AUTHENTICATION}/" /etc/ssh/sshd_config
# Adiciona/Atualiza o tempo limite de inatividade
sed -i "/^#\?ClientAliveInterval .*/cClientAliveInterval ${CLIENT_ALIVE_INTERVAL}" /etc/ssh/sshd_config
if ! grep -q "^ClientAliveInterval" /etc/ssh/sshd_config; then
    echo "ClientAliveInterval ${CLIENT_ALIVE_INTERVAL}" >> /etc/ssh/sshd_config
fi
sed -i "/^#\?ClientAliveCountMax .*/cClientAliveCountMax ${CLIENT_ALIVE_COUNT_MAX}" /etc/ssh/sshd_config
if ! grep -q "^ClientAliveCountMax" /etc/ssh/sshd_config; then
    echo "ClientAliveCountMax ${CLIENT_ALIVE_COUNT_MAX}" >> /etc/ssh/sshd_config
fi

# Garante que 'UsePAM yes' está presente (geralmente é o padrão, mas bom verificar)
if ! grep -q "^UsePAM yes" /etc/ssh/sshd_config; then
    echo "UsePAM yes" >> /etc/ssh/sshd_config
fi

# Remove a opção 'PermitEmptyPasswords' caso exista (não deve haver, mas para garantir)
sed -i '/^#\?PermitEmptyPasswords/d' /etc/ssh/sshd_config

echo "Configurações aplicadas:"
grep -E "Port|PermitRootLogin|PasswordAuthentication|PubkeyAuthentication|ClientAlive" /etc/ssh/sshd_config | grep -v '^#'

echo "=== [4/6] Reiniciando o serviço SSH ==="
# CORREÇÃO AQUI: Mudando 'sshd' para 'ssh'
systemctl restart ssh

if [ $? -ne 0 ]; then
    echo "❌ Falha ao reiniciar o serviço SSH. Verifique o arquivo /etc/ssh/sshd_config em busca de erros."
    exit 1
fi

echo "=== [5/6] Verificando o status do serviço SSH ==="
# CORREÇÃO AQUI: Mudando 'sshd' para 'ssh'
systemctl status ssh --no-pager

echo "=== [6/6] Configurando o firewall UFW (se ativo) ==="
if systemctl is-active --quiet ufw; then
    echo "UFW está ativo. Abrindo porta ${SSH_PORT}..."
    ufw allow ${SSH_PORT}/tcp
    ufw reload
    echo "Regras do UFW atualizadas:"
    ufw status numbered
else
    echo "UFW não está ativo. Pule a configuração do firewall."
    echo "Considere ativar um firewall para proteger seu servidor."
fi

echo -e "\n✅ Configuração do SSH concluída com sucesso!"
echo -e "⚙️ Porta SSH configurada para: ${SSH_PORT}"
if [ "${PASSWORD_AUTHENTICATION}" == "no" ]; then
    echo -e "⚠️ Autenticação por senha DESABILITADA. Certifique-se de ter uma chave SSH configurada para o usuário que você vai usar."
    echo -e "   Para gerar uma chave SSH (na sua máquina local): ssh-keygen"
    echo -e "   Para copiar a chave pública para o servidor: ssh-copy-id USUARIO@IP_DO_SERVIDOR -p ${SSH_PORT}"
else
    echo -e "🔑 Autenticação por senha HABILITADA. Recomenda-se usar chaves SSH para maior segurança."
fi
echo -e "🚫 Login de root: ${PERMIT_ROOT_LOGIN}"
echo -e "\nVocê pode tentar se conectar via SSH agora: ssh -p ${SSH_PORT} USUARIO@IP_DO_SERVIDOR"