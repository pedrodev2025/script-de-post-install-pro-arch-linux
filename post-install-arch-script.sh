#!/bin/bash

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

log_message "Conectado à internet. Continuando o script..."
log_message "A Instalação Está Começando. Por favor, espere..."

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

# Instala Flatpak
log_message "Instalando Flatpak..."
pacman -S --needed --noconfirm flatpak # Removido sudo
check_status "pacman -S --needed --noconfirm flatpak"

# Adiciona o repositório Flathub
log_message "Adicionando o repositório Flathub..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
check_status "flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo"

# Atualiza o banco de dados do Flatpak
log_message "Atualizando o banco de dados do Flatpak..."
flatpak update --noninteractive
check_status "flatpak update --noninteractive"

# Instala aplicativos Flatpak
log_message "Instalando Chrome (via Flatpak)..."
flatpak install --noninteractive flathub com.google.Chrome
check_status "flatpak install --noninteractive flathub com.google.Chrome"

log_message "Instalando VLC (via Flatpak)..."
flatpak install --noninteractive flathub org.videolan.VLC # Removido -y
check_status "flatpak install --noninteractive flathub org.videolan.VLC"

log_message "Instalando GIMP (via Flatpak)..."
flatpak install --noninteractive flathub org.gimp.GIMP # Removido -y
check_status "flatpak install --noninteractive flathub org.gimp.GIMP"

log_message "Instalando Onlyoffice (via Flatpak)..."
flatpak install --noninteractive flathub org.onlyoffice.desktopeditors
check_status "flatpak install --noninteractive flathub org.onlyoffice.desktopeditors"

# Instala LM Studio
log_message "Instalando LM Studio..."
# Verifica se wget está instalado
if command -v wget &> /dev/null; then
  LM_STUDIO_URL="https://installers.lmstudio.ai/linux/x64/0.3.14-5/LM-Studio-0.3.14-5-x64.AppImage"
  OUTPUT_PATH="/home/$USER/AppImages/lmstudio.AppImage"
  log_message "Baixando LM Studio de: $LM_STUDIO_URL para $OUTPUT_PATH"
  wget -O "$OUTPUT_PATH" "$LM_STUDIO_URL"
  check_status "wget -O \"$OUTPUT_PATH\" \"$LM_STUDIO_URL\""
  chmod +x "$OUTPUT_PATH"
  check_status "chmod +x \"$OUTPUT_PATH\""
else
  log_message "AVISO: wget não está instalado. Pulando a instalação do LM Studio."
fi

# Instala Gnome Software
log_message "Instalando Gnome Software e plugin Flatpak..."
pacman -S --needed --noconfirm gnome-software gnome-software-plugin-flatpak # Removido sudo
check_status "pacman -S --needed --noconfirm gnome-software gnome-software-plugin-flatpak"

log_message "Script de pós-instalação concluído com sucesso!"
exit 0
