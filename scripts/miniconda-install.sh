#!/bin/bash

# --- Variáveis ---
MINICONDA_INSTALLER="Miniconda3-latest-Linux-x86_64.sh"
MINICONDA_DOWNLOAD_URL="https://repo.anaconda.com/miniconda/${MINICONDA_INSTALLER}"
INSTALL_DIR="${HOME}/miniconda3" # Diretório padrão de instalação para o usuário

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
# Este script NÃO precisa ser executado como root. Ele instala para o usuário atual.
if [ "$EUID" -eq 0 ]; then
    log_error "Este script NÃO deve ser executado como root. Execute-o como seu usuário normal (ex: bash ./install-miniconda.sh)."
fi

# Verificar se o curl está instalado
if ! command -v curl &> /dev/null; then
    log_info "Instalando curl, pois é necessário para o download..."
    sudo apt update
    sudo apt install -y curl || log_error "Falha ao instalar curl."
fi

# --- Processo de Instalação ---

log_info "Baixando o instalador do Miniconda..."
curl -o "/tmp/${MINICONDA_INSTALLER}" "$MINICONDA_DOWNLOAD_URL" || log_error "Falha ao baixar o instalador do Miniconda. Verifique a URL ou sua conexão."

log_info "Tornando o instalador executável..."
chmod +x "/tmp/${MINICONDA_INSTALLER}" || log_error "Falha ao dar permissões de execução ao instalador."

log_info "Executando o instalador do Miniconda (modo não interativo)..."
# -b: batch mode (não interativo)
# -p: prefixo de instalação
# -u: update mode (se já existir, atualiza)
"/tmp/${MINICONDA_INSTALLER}" -b -p "${INSTALL_DIR}" -u || log_error "Falha na execução do instalador do Miniconda."

log_info "Inicializando o Miniconda para o seu shell..."
# Adiciona a inicialização do conda ao .bashrc (ou .zshrc, dependendo do shell)
# Isso permite que o comando 'conda' seja reconhecido após reiniciar o terminal.
if [ -f "${HOME}/.bashrc" ]; then
    "${INSTALL_DIR}/bin/conda" init bash || log_error "Falha ao inicializar conda para bash."
    log_info "Adicionado inicialização do Miniconda ao ~/.bashrc."
elif [ -f "${HOME}/.zshrc" ]; then
    "${INSTALL_DIR}/bin/conda" init zsh || log_error "Falha ao inicializar conda para zsh."
    log_info "Adicionado inicialização do Miniconda ao ~/.zshrc."
else
    log_error "Não foi possível encontrar .bashrc ou .zshrc. Por favor, inicialize o conda manualmente:\nsource ${INSTALL_DIR}/bin/activate && conda init <seu_shell>"
fi

log_info "Limpando arquivo do instalador temporário..."
rm -f "/tmp/${MINICONDA_INSTALLER}"
log_success "Miniconda instalado e configurado com sucesso!"

echo -e "\nPara começar a usar o Miniconda, você precisará **reiniciar seu terminal** ou executar:"
echo -e "  source ~/.bashrc  (ou ~/.zshrc, dependendo do seu shell)"
echo -e "\nApós reiniciar, você pode testar a instalação com:"
echo -e "  conda --version"
echo -e "  conda env list"
echo -e "  conda install python=3.9 # Exemplo de instalação de Python 3.9"