#!/bin/bash

# --- Variáveis ---
INSTALL_DIR="/tmp" # Usaremos /tmp para o download temporário do .deb
APP_NAME="balena-etcher" # Nome do pacote/aplicativo

# --- Funções ---
log_info() {
    echo -e "\n=== [INFO] $1 ==="
}

log_success() {
    echo -e "✅ $1"
}

log_error() {
    echo -e "❌ $1"
    exit 1
}

# --- Verificações Iniciais ---
if [ "$EUID" -ne 0 ]; then
    log_error "Este script deve ser executado como root (use sudo)."
fi

# --- Processo de Instalação ---

log_info "Instalando dependências (curl, wget) se necessário..."
apt update > /dev/null 2>&1
apt install -y curl wget || log_error "Falha ao instalar curl/wget."

log_info "Buscando a última versão estável do balenaEtcher (pacote .deb)..."

# Busca a última tag de release (ex: v2.1.2)
LATEST_TAG=$(curl -s "https://api.github.com/repos/balena-io/etcher/releases/latest" | grep "tag_name" | cut -d : -f 2,3 | tr -d \" | tr -d , | xargs)

if [ -z "$LATEST_TAG" ]; then
    log_error "Não foi possível obter a última tag de release do GitHub. Verifique a conexão ou a API."
fi

# Extrai o número da versão (ex: 2.1.2 de v2.1.2)
ETCHER_VERSION=$(echo "$LATEST_TAG" | sed 's/^v//')

if [ -z "$ETCHER_VERSION" ]; then
    log_error "Não foi possível extrair o número da versão da tag de release: $LATEST_TAG"
fi

# Constrói a URL de download do pacote .deb para amd64
DEB_DOWNLOAD_URL="https://github.com/balena-io/etcher/releases/download/${LATEST_TAG}/balena-etcher_${ETCHER_VERSION}_amd64.deb"

log_info "Última versão encontrada: ${ETCHER_VERSION}"
log_info "URL de download: ${DEB_DOWNLOAD_URL}"

log_info "Baixando o pacote .deb do balenaEtcher para ${INSTALL_DIR}..."
wget -O "${INSTALL_DIR}/${APP_NAME}_${ETCHER_VERSION}_amd64.deb" -L "$DEB_DOWNLOAD_URL" || log_error "Falha ao baixar o pacote .deb. Verifique a URL ou sua conexão."

log_info "Instalando o pacote .deb..."
# dpkg -i instala o pacote, e apt --fix-broken install resolve dependências que possam faltar
dpkg -i "${INSTALL_DIR}/${APP_NAME}_${ETCHER_VERSION}_amd64.deb" || apt --fix-broken install -y

if [ $? -eq 0 ]; then
    log_success "balenaEtcher instalado com sucesso via pacote .deb!"
    echo "Você pode iniciá-lo pesquisando por 'balenaEtcher' no seu menu de aplicativos."
else
    log_error "Falha ao instalar o balenaEtcher. Verifique os logs acima."
fi

log_info "Limpando arquivos temporários..."
rm -f "${INSTALL_DIR}/${APP_NAME}_${ETCHER_VERSION}_amd64.deb"
log_success "Instalação concluída e arquivos temporários removidos."

# ---

## **Método Alternativo: Instalação via Repositório APT (Comentado)**

# Se você preferir instalar via Repositório APT para atualizações automáticas via 'apt upgrade',
# descomente e use o bloco abaixo.
# Este método é o mais recomendado para manutenção a longo prazo, mas o pacote .deb é mais imediato.

: '
log_info "Adicionando repositório balenaEtcher e chave GPG..."

sudo apt update
sudo apt install -y curl apt-transport-https

# Este comando adiciona o repositório oficial da Balena para Etcher de forma segura
curl -1sLf 'https://dl.cloudsmith.io/public/balena/etcher/setup.deb.sh' | sudo -E bash

log_info "Atualizando lista de pacotes e instalando balena-etcher-electron..."
apt update
apt install -y balena-etcher-electron

if [ $? -eq 0 ]; then
    log_success "balenaEtcher instalado com sucesso via Repositório APT!"
    echo "Você pode iniciá-lo pesquisando por 'balenaEtcher' no seu menu de aplicativos."
else
    log_error "Falha ao instalar o balenaEtcher via Repositório APT."
fi
'