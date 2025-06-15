#!/bin/bash
set -x
# Variável para o arquivo de log
LOG_FILE="/var/logs/post-install-arch-logs.log"
# Função para exibir mensagens e registrar no log
log_message() {
  echo "$1" | tee -a "$LOG_FILE"
}

# Função para verificar o status do comando e sair em caso de erro
check_status() {
  local cmd_name="$1" # Captura o nome do comando para a mensagem de erro
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
check_status "ping -c 1 8.8.8.8" # Se o ping falhar, o script sairá aqui

# Se chegamos aqui, a conexão está ok
USER=$SUDO_USER # Obtém o nome do usuário original que invocou o sudo
ln -s /var/log /var/logs
log_message "Conectado à internet. Continuando o script..."
log_message "A Instalação Está Começando. Por favor, espere..."
# Configurando repositorio chaotic-aur
 pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
 pacman-key --lsign-key 3056513887B78AEB
 pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' --noconfirm
pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' --noconfirm
echo "[chaotic-aur]" >> /etc/pacman.conf
echo "Include = /etc/pacman.d/chaotic-mirrorlist" >> /etc/pacman.conf 
# Criando Pastas De Produtividade
log_message "Criando Pastas De Produtividade"
mkdir -p /home/$USER/TEMP
check_status "mkdir -p /home/$USER/TEMP"
chmod 700 /home/$USER/TEMP
check_status "chmod 700 /home/$USER/TEMP"

mkdir -p /home/$USER/Documentos/Planilhas
check_status "mkdir -p /home/$USER/Documentos/Planilhas"
chmod 700 /home/$USER/Documentos/Planilhas
check_status "chmod 700 /home/$USER/Documentos/Planilhas"

mkdir -p /home/$USER/AppImages/
check_status "mkdir -p /home/$USER/AppImages/"
chmod 700 /home/$USER/AppImages/
check_status "chmod 700 /home/$USER/AppImages/"

# Atualiza o sistema
log_message "Atualizando o sistema..."
pacman -Syu --noconfirm # Removido sudo
check_status "pacman -Syu --noconfirm"

# Instala utilitários básicos
log_message "Instalando utilitários básicos (curl wget unzip)..."
pacman -S --needed --noconfirm curl wget unzip # Removido sudo
check_status "pacman -S --needed --noconfirm curl wget unzip"
# Instala VLC
log_message "Instalando VLC"
pacman -S vlc 
check_status "pacman -S vlc"
# Instala Chrome
pacman -S google-chrome
check_status "pacman -S google-chrome"
# Instala alpaca
# Instala Gnome Software
log_message "Instalando Gnome Software e plugin Flatpak..."
pacman -S --needed --noconfirm gnome-software # Removido sudo
check_status "pacman -S --needed --noconfirm gnome-software gnome-software-plugin-flatpak"

log_message "Script de pós-instalação concluído com sucesso!"
exit 0
