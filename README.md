# Objetivo
Este repositório tem por objetivo definir os programas usados no Linux distribuição Debian (Ubuntu)

# Pré-requisitos

- Iniciar com atualização da lista de pacotes
  - ```sudo apt update```
- Instalar software-properties-common
  - ```sudo apt install software-properties-common -y```
- Instalar o Curl
  - ```sudo apt install curl -y```
- Instalar NetTools
  - ```sudo apt install net-tools -y```
- Instalar Git
  - ```sudo apt install git -y```
- Instalar Flatpak
  - ```sudo apt install flatpak -y```
  - ```sudo apt install gnome-software-plugin-flatpak -y```
- Instalar Snapcraft
  - ```sudo snap install snapcraft --classic```
- Instalar Flameshoot (printscreen)
  - ```sudo apt install flameshot -y```
- Instalar Python 3.10
  - ```sudo add-apt-repository ppa:deadsnakes/ppa -y && sudo apt update```
  - ```sudo apt install python3.10 -y```
  - ```sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 && sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1```
- Instalar Pip do Python
  - ```sudo apt install python3.10-distutils -y && sudo apt-get install python3-pip -y```
  - ```pip3 install --upgrade pip```
- Instalar Docker
  - ```sudo apt install docker.io -y && sudo usermod -aG docker ${USER} && newgrp docker```
- Instalar Docker Compose
  - ```sudo apt install docker-compose -y```
- Instalar Vitals (Sensores)
  - ```sudo apt install gnome-shell-extension-manager gir1.2-gtop-2.0 lm-sensors -y```
- Instalar Peek (Screen to Gif)
  - ```sudo apt install peek -y```
- Instalar Htop
  - ```sudo apt install htop -y```
- Instalar NVM (Node)
  - ```sudo bash scripts/nvm-node-install.sh```
  - ```nvm install --lts```
- Instalar 7Zip
  - ```sudo apt install p7zip-full p7zip-rar -y```
- Instalar o Terminal Tilix
  - ```sudo apt install tilix -y```
  - Configurar o tilix como terminal default ```sudo update-alternatives --config x-terminal-emulator```
- Instalar o Auxiliador de Terminal oh-my-zsh
  - ```sudo apt install zsh -y```
  - Configurar: ```chsh -s $(which zsh)```
  - Instalar Plugins: ```sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"```
- Instalar o Árvore de Arquivos fzf
  - ```sudo apt install fzf -y```






# Software para Download
- Visual Code
  - Site: https://code.visualstudio.com/download
  - Download em: https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64
  - Instalação com .deb: ```sudo dpkg -i code_..._amd64.deb```
- Chrome
  - Site: https://www.google.com/intl/pt-BR/chrome/
  - Download em: https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  - Instalação com .deb: ```sudo dpkg -i google-chrome-stable_current_amd64.deb```
- Impressora e Scanner L3150
  - Site Impressora: https://support.epson.net/linux/Printer/LSB_distribution_pages/en/escpr.php
    - https://download3.ebz.epson.net/dsc/f/03/00/16/21/77/211c32cd14db04ed7838001a6ec0276e5ffd7190/epson-inkjet-printer-escpr_1.8.6-1_amd64.deb
    - Instalação com .deb: ```sudo dpkg -i epson-inkjet-printer-escpr_1.8.6-1_amd64.deb```
  - Site Scanner: https://support.epson.net/linux/en/epsonscan2.php
    - https://download3.ebz.epson.net/dsc/f/03/00/17/08/12/9f3fec0ae80aa5c36f5170377ebcc38c93251e23/epsonscan2-bundle-6.7.80.0.x86_64.deb.tar.gz
    - Instalação: Extrair para uma pasta, e adiante executar ```sudo ./install.sh```


- Slack
- Dbeaver
- PhpStorm
- PyCharm
- Discord
- Filezila
- Cheasse
- VNC
- SSH
- Vivaldi
- Sublime Text
- JetBrains Toolbox
- Insomnia
- Php
- miniconda
- jupyter
- ObsStudio
- ctop: monitor interativo de containers Docker
- VLC
- OpenShot
- GIMP
- Stacer - https://oguzhaninan.github.io/Stacer-Web/
- Bitwarden
- Pdfarranger
- https://obsidian.md/download
- Etcher