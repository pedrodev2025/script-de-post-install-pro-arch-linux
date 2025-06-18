#!/bin/bash
set -x

# Variável para o arquivo de log
LOG_FILE="/var/log/post-install-arch-logs.log"

# Função para exibir mensagens e registrar no log
log_message() {
    echo "$1" | tee -a "$LOG_FILE"
}

# Função para verificar o status do comando e sair em caso de erro
check_status() {
    local cmd_name="$1"
    if [ "$?" -ne 0 ]; then
        log_message "ERROR: O comando '$cmd_name' falhou com código de saída $?. Saindo do script."
        exit 1
    fi
}

# Verifica se o script está sendo executado com sudo
if [[ $EUID -ne 0 ]]; then
    log_message "ERROR: Este script precisa ser executado com privilégios de root (sudo)."
    exit 1
fi

# Tenta fazer ping em um servidor confiável (Google DNS)
log_message "Verificando conexão com a internet..."
ping -c 1 8.8.8.8 > /dev/null 2>&1
check_status "ping -c 1 8.8.8.8"

# Se chegamos aqui, a conexão está ok
USER=$SUDO_USER
log_message "Conectado à internet. Continuando o script..."
log_message "A Instalação Está Começando. Por favor, espere..."

# Configurando repositorio chaotic-aur
log_message "Configurando Chaotic-AUR..."
pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
check_status "pacman-key --recv-key"
pacman-key --lsign-key 3056513887B78AEB
check_status "pacman-key --lsign-key"
pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' --noconfirm
check_status "pacman -U chaotic-keyring"
pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' --noconfirm
check_status "pacman -U chaotic-mirrorlist"

# Verifica se o Chaotic-AUR já está no pacman.conf antes de adicionar
if ! grep -q "[chaotic-aur]" /etc/pacman.conf; then
    echo "[chaotic-aur]" >> /etc/pacman.conf
    echo "Include = /etc/pacman.d/chaotic-mirrorlist" >> /etc/pacman.conf
    log_message "Chaotic-AUR adicionado ao pacman.conf."
else
    log_message "Chaotic-AUR já está configurado no pacman.conf. Ignorando."
fi
log_message "Chaotic-AUR configurado."

# Criando Pastas De Produtividade
log_message "Criando Pastas De Produtividade..."
mkdir -p "/home/$USER/TEMP"
check_status "mkdir -p /home/$USER/TEMP"
chmod 700 "/home/$USER/TEMP"
check_status "chmod 700 /home/$USER/TEMP"
# chown "$USER":"$USER" "/home/$USER/TEMP" # Mantido como estava, pois é a sintaxe correta
chown "$USER":"$USER" "/home/$USER/TEMP"
check_status "chown /home/$USER/TEMP"

mkdir -p "/home/$USER/Documentos/Planilhas"
check_status "mkdir -p /home/$USER/Documentos/Planilhas"
chmod 700 "/home/$USER/Documentos/Planilhas"
check_status "chmod 700 /home/$USER/Documentos/Planilhas"
# chown "$USER":"$USER" "/home/$USER/Documentos/Planilhas" # Mantido como estava
chown "$USER":"$USER" "/home/$USER/Documentos/Planilhas"
check_status "chown /home/$USER/Documentos/Planilhas"

mkdir -p "/home/$USER/AppImages/"
check_status "mkdir -p /home/$USER/AppImages/"
chmod 700 "/home/$USER/AppImages/"
check_status "chmod 700 /home/$USER/AppImages/"
# chown "$USER":"$USER" "/home/$USER/AppImages/" # Mantido como estava
chown "$USER":"$USER" "/home/$USER/AppImages/"
check_status "chown /home/$USER/AppImages/"
log_message "Pastas de produtividade criadas e dono definido."

# Atualiza o sistema
log_message "Atualizando o sistema..."
pacman -Syu --noconfirm
check_status "pacman -Syu --noconfirm"

# Instala utilitários básicos
log_message "Instalando utilitários básicos (curl wget unzip)..."
pacman -S --needed --noconfirm curl wget unzip
check_status "pacman -S --needed --noconfirm curl wget unzip"

# Instala VLC
log_message "Instalando VLC..."
pacman -S --noconfirm vlc
check_status "pacman -S vlc"

# Instala yay (necessário para pacotes do AUR como Chrome e alpaca-ai)
log_message "Instalando yay (AUR helper)..."
pacman -S --noconfirm yay
check_status "pacman -S yay"

# Instala Chrome (via yay)
log_message "Instalando Google Chrome (via yay)..."
sudo -u "$USER" yay -S --noconfirm google-chrome
check_status "yay -S google-chrome"

# Instalando python-cobble (via yay)
log_message "Instalando python-cobble (via yay)..."
sudo -u "$USER" yay -S --noconfirm python-cobble
check_status "yay -S python-cobble"

# Instalando python-mammoth (com desabilitação de verificação de assinatura - CUIDADO!)
log_message "Instalando python-mammoth (com verificação de assinatura desabilitada - CUIDADO!)..."
pacman -U --noconfirm --config <(echo -e "[options]\nSigLevel = Never") 'https://github.com/pedrodev2025/script-de-post-install-pro-arch-linux/raw/refs/heads/main/cdn-alpaca/python-mammoth-1.9.1-4-any.pkg.tar.zst'
check_status "pacman -U python-mammoth.pkg.tar.zst (SigLevel=Never)"

# Instalando alpaca-ai (via yay)
log_message "Instalando alpaca-ai (via yay)..."
sudo -u "$USER" yay -S --noconfirm alpaca-ai
check_status "yay -S alpaca-ai"

# Instala Gnome Software e Flatpak (plugin já é integrado com o pacote flatpak)
log_message "Instalando Gnome Software e Flatpak..."
pacman -S --needed --noconfirm gnome-software flatpak
check_status "pacman -S --needed --noconfirm gnome-software flatpak"

log_message "Script de pós-instalação concluído com sucesso!"
exit 0
