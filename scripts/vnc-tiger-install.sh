#!/bin/bash

DISPLAY_NUM=1
RESOLUCAO="1990x1080" # Pequena alteração na resolução para testar se influencia
DEPTH=24

# Confirma execução como root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Este script deve ser executado como root (use sudo)."
    exit 1
fi

# Obtém o usuário real
USUARIO=${SUDO_USER}
if [ -z "$USUARIO" ] || [ "$USUARIO" == "root" ]; then
    echo "❌ Não é possível identificar o usuário. Use: sudo ./script.sh"
    exit 1
fi

HOME_DIR="/home/$USUARIO"
SERVICE_FILE="/etc/systemd/system/vncserver@${USUARIO}.service"

# Confirma se diretório do usuário existe
if [ ! -d "$HOME_DIR" ]; then
    echo "❌ Diretório home $HOME_DIR não encontrado."
    exit 1
fi

echo "=== [1/7] Instalando pacotes necessários ==="
# Adicionado xterm para testes e lightdm para garantir um ambiente de display manager (pode ser útil)
apt update
apt install -y tigervnc-standalone-server tigervnc-common tigervnc-xorg-extension dbus-x11 xfce4-goodies xfce4 xterm lightdm

echo "=== [2/7] Criando diretório ~/.vnc e definindo senha ==="
runuser -l "$USUARIO" -c "mkdir -p ~/.vnc && vncpasswd"

echo "=== [3/7] Criando script ~/.vnc/xstartup ==="
# Conteúdo do xstartup modificado para uma inicialização mais robusta e padrão para XFCE
runuser -l "$USUARIO" -c "cat > ~/.vnc/xstartup << 'EOF'
#!/bin/sh
# Gerado por VNC Server - Adaptações para Xubuntu/XFCE

# Carrega recursos X (cores, fontes, etc.)
[ -r \$HOME/.Xresources ] && xrdb \$HOME/.Xresources

# Configurações do VNC
vncconfig -iconic &

# Limpa variáveis de ambiente que podem causar problemas
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

# Define um PATH adequado para encontrar os executáveis do XFCE
export PATH=/usr/bin:/bin:/usr/sbin:/sbin

# Tenta iniciar a sessão XFCE
# O comando 'exec' substitui o shell atual, garantindo que a sessão XFCE seja o processo principal
exec startxfce4
EOF"
chmod +x "$HOME_DIR/.vnc/xstartup"
chown "$USUARIO:$USUARIO" "$HOME_DIR/.vnc/xstartup"

echo "=== [4/7] Criando serviço systemd personalizado para o usuário ==="
cat > "$SERVICE_FILE" << EOF
[Unit]
Description=Start TigerVNC server at startup for user $USUARIO
After=network.target

[Service]
Type=forking
User=$USUARIO
WorkingDirectory=$HOME_DIR
PIDFile=$HOME_DIR/.vnc/%H:$DISPLAY_NUM.pid
ExecStartPre=-/usr/bin/vncserver -kill :$DISPLAY_NUM > /dev/null 2>&1
ExecStart=/usr/bin/vncserver :$DISPLAY_NUM -geometry $RESOLUCAO -depth $DEPTH
ExecStop=/usr/bin/vncserver -kill :$DISPLAY_NUM

[Install]
WantedBy=multi-user.target
EOF

echo "=== [5/7] Recarregando systemd ==="
systemctl daemon-reexec
systemctl daemon-reload

echo "=== [6/7] Habilitando e iniciando o serviço VNC ==="
systemctl enable vncserver@${USUARIO}.service
systemctl start vncserver@${USUARIO}.service

echo "=== [7/7] Verificando status ==="
systemctl status vncserver@${USUARIO}.service --no-pager

sudo ufw allow 5901/tcp
sudo ufw enable # Se o firewall não estiver ativo

echo -e "\n✅ VNC configurado com sucesso para o usuário '$USUARIO'"
echo -e "🔗 Acesse via VNC em: IP_DO_SERVIDOR:$((5900 + DISPLAY_NUM))"