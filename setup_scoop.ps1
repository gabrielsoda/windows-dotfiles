# setup_scoop.ps1
Write-Host "Iniciando configuración de entorno Scoop..." -ForegroundColor Cyan

# 1. Instalar Scoop (si no existe)
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "Instalando Scoop..."
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    irm get.scoop.sh | iex
} else {
    Write-Host "Scoop ya está instalado." -ForegroundColor Green
}

# 2. Instalar dependencias críticas primero (Git y 7zip)
scoop install git 7zip

# 3. Añadir Buckets
$buckets = @("extras", "versions", "nerd-fonts", "nonportable", "games")
$currentBuckets = scoop bucket list
foreach ($bucket in $buckets) {
    if ($currentBuckets -notmatch $bucket) {
        Write-Host "Añadiendo bucket: $bucket"
        scoop bucket add $bucket
    }
}

scoop update

# 4. Lista de Aplicaciones (Extraída de tu configuración)
$apps = @(
    "2ship2harkinian",
    "bitwarden",
    "calibre",
    "camo-studio",
    "dark",
    "discord",
    "ditto",
    "epic-games-launcher",
    "everything",
    "fancontrol",
    "ffmpeg",
    "FiraCode",
    "firefox",
    "googlechrome",
    "graphviz",
    "handbrake",
    "innounp",
    "lightshot",
    "obs-studio",
    "obsidian",
    "oh-my-posh",
    "pandoc",
    "powertoys",
    "qbittorrent-enhanced",
    "quarto",
    "shipwright",
    "spotify",
    "steam",
    "syncthing",
    "telegram",
    "ubisoftconnect",
    "uv",
    "ventoy",
    "vlc",
    "vscode",
    "yt-dlp",
    "zelda64recomp"
)

# 5. Instalación masiva
Write-Host "Instalando aplicaciones..." -ForegroundColor Cyan
foreach ($app in $apps) {
    # -u evita errores si la app ya está instalada
    scoop install $app -u
}

Write-Host "Configuración de Scoop finalizada." -ForegroundColor Green