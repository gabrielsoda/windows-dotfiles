# setup_scoop.ps1
$ErrorActionPreference = "Stop"
$ScriptDir = $PSScriptRoot

Write-Host "Iniciando configuración de entorno Scoop..." -ForegroundColor Cyan

# 1. Instalar Scoop
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "Instalando Scoop..."
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    irm get.scoop.sh | iex
}

# 2. Cargar configuración externa
$JsonPath = Join-Path $ScriptDir "scoop_apps.json"
if (-not (Test-Path $JsonPath)) {
    Write-Error "No se encontró scoop_apps.json en $ScriptDir"
}
$Config = Get-Content $JsonPath -Raw | ConvertFrom-Json

# 3. Restaurar Buckets
$CurrentBuckets = scoop bucket list
foreach ($bucket in $Config.buckets) {
    if ($CurrentBuckets -notmatch $bucket.Name) {
        Write-Host "Añadiendo bucket: $($bucket.Name)"
        scoop bucket add $bucket.Name $bucket.Source
    }
}
scoop update

# 4. Restaurar Apps
Write-Host "Verificando aplicaciones..." -ForegroundColor Cyan
foreach ($app in $Config.apps) {
    # Instalamos usando el nombre, ignorando la versión para obtener la 'latest'
    # Usamos -u para omitir si ya existe
    scoop install $app.Name -u
}

Write-Host "Entorno restaurado según scoop_apps.json" -ForegroundColor Green