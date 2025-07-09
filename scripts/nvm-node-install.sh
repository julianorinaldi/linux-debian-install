#!/bin/bash

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

# Define o diretório do NVM
NVM_DIR="$HOME/.nvm"

# Define os trechos a serem adicionados
NVM_INIT_SCRIPT=$(cat <<EOF

export NVM_DIR="\$HOME/.nvm"
[ -s "\$NVM_DIR/nvm.sh" ] && \. "\$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "\$NVM_DIR/bash_completion" ] && \. "\$NVM_DIR/bash_completion"  # This loads nvm bash_completion
EOF
)

# Verifica se já está no .bashrc
if ! grep -q 'nvm.sh' "$HOME/.bashrc"; then
    echo "Adicionando configuração do NVM ao .bashrc..."
    echo "$NVM_INIT_SCRIPT" >> "$HOME/.bashrc"
else
    echo "A configuração do NVM já existe no .bashrc."
fi

# Aplica as alterações no terminal atual (opcional)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

source $HOME/.bashrc

echo "Configuração do NVM finalizada."



