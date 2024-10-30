# PowerShell Script for setting up a WSL2 development environment with VSCode, Go, Docker, VueJS with TypeScript, and Spell Checker

# Enable WSL and Virtual Machine Platform
Write-Host "Enabling WSL and Virtual Machine Platform..."
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# Update WSL2 kernel
Write-Host "Checking WSL2 kernel update..."
$kernelUpdateURL = "https://aka.ms/wsl2kernel"
Invoke-WebRequest -Uri $kernelUpdateURL -OutFile "$env:TEMP\wsl_update.msi"
Start-Process -FilePath "$env:TEMP\wsl_update.msi" -Wait

# Set WSL2 as default version
Write-Host "Setting WSL2 as the default version..."
wsl --set-default-version 2

# Install Ubuntu if not already installed via Microsoft Store
Write-Host "Please install Ubuntu (or preferred distro) from Microsoft Store if not already installed."

# Function to check if a program is installed
function Test-ProgramInstalled {
    param ([string]$programName)

    # Returns true if the program is found, otherwise false
    return $null -ne (Get-Command $programName -ErrorAction SilentlyContinue)
}

# Check if Visual Studio Code is installed
if (!(Test-ProgramInstalled "code")) {
    Write-Host "Installing Visual Studio Code..."
    $vscodeInstallerUrl = "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user"
    Invoke-WebRequest -Uri $vscodeInstallerUrl -OutFile "$env:TEMP\vscode_installer.exe"
    Start-Process -FilePath "$env:TEMP\vscode_installer.exe" -Wait
} else {
    Write-Host "Visual Studio Code is already installed."
}

# Install required VSCode extensions
Write-Host "Installing VSCode extensions for Golang, Docker, VueJS with TypeScript, Spell Checker, and more..."
code --install-extension golang.go                  # Go Extension
code --install-extension ms-azuretools.vscode-docker # Docker Extension
code --install-extension octref.vetur                # Vue.js Extension
code --install-extension Vue.vscode-typescript-vue-plugin # TypeScript support for Vue
code --install-extension streetsidesoftware.code-spell-checker # English Spell Checker

# Additional useful extensions for code formatting and error visibility
code --install-extension usernamehw.errorlens        # Error Lens
code --install-extension esbenp.prettier-vscode      # Prettier - Code formatter
code --install-extension alefragnani.bookmarks       # Bookmarks
code --install-extension formulahendry.code-runner   # Code Runner
code --install-extension zxh404.vscode-proto3        # Protocol Buffers (proto3) syntax highlighting
code --install-extension aaron-bond.better-comments  # Better Comments

# Install developer tools in WSL2 environment
Write-Host "Updating WSL and installing Go, Docker, Node.js, and Vue CLI..."
wsl sudo apt update ; sudo apt upgrade -y
wsl sudo apt install -y build-essential git curl

# Install Go in WSL2
$goVersion = "1.23.2"
$goUrl = "https://golang.org/dl/go$goVersion.linux-amd64.tar.gz"
wsl curl -OL $goUrl
wsl sudo tar -C /usr/local -xzf "go$goVersion.linux-amd64.tar.gz"
wsl echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc

# Install Docker (without Docker Desktop)
Write-Host "Installing Docker in WSL2..."
wsl sudo apt-get install -y docker.io
wsl sudo usermod -aG docker $USER
wsl newgrp docker

# Install Node.js and npm (required for VueJS and TypeScript)
wsl curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
wsl sudo apt-get install -y nodejs

# Install Vue CLI
wsl npm install -g @vue/cli

# Configure Git (optional)
Write-Host "Configuring Git in WSL..."
$gitUserName = Read-Host "Enter your Git user name"
$gitUserEmail = Read-Host "Enter your Git email"
wsl git config --global user.name "$gitUserName"
wsl git config --global user.email "$gitUserEmail"

Write-Host "Opening Visual Studio Code in WSL environment..."
code .
Write-Host "Setup complete! Your environment is ready for Go, Docker, VueJS with TypeScript, and additional development tools."
