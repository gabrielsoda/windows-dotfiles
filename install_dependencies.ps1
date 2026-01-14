# install_dependencies.ps1

# Verificar si se está ejecutando como administrador (opcional pero recomendado)
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "⚠️  Advertencia: No se está ejecutando como administrador. Algunas instalaciones podrían fallar." -ForegroundColor Yellow
    Write-Host "   Presiona Enter para continuar de todas formas, o Ctrl+C para cancelar..."
    Read-Host
}

Write-Host "Verificando módulos de PowerShell..." -ForegroundColor Cyan

# Asegurar que PSGallery está configurado como repositorio confiable
if ((Get-PSRepository -Name PSGallery).InstallationPolicy -ne 'Trusted') {
    Write-Host "Configurando PSGallery como repositorio confiable..." -ForegroundColor Yellow
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
}

# Función helper para instalar si falta
function Ensure-Module {
    param(
        [Parameter(Mandatory)]
        [string]$Name,
        
        [string]$MinimumVersion
    )
    
    try {
        $installed = Get-Module -ListAvailable -Name $Name | Select-Object -First 1
        
        if (-not $installed) {
            Write-Host " -> Instalando módulo: $Name" -ForegroundColor Yellow
            $installParams = @{
                Name = $Name
                Scope = 'CurrentUser'
                Force = $true
                AllowClobber = $true
                ErrorAction = 'Stop'
            }
            if ($MinimumVersion) {
                $installParams.MinimumVersion = $MinimumVersion
            }
            Install-Module @installParams
            Write-Host " -> ✓ $Name instalado correctamente." -ForegroundColor Green
        } else {
            Write-Host " -> ✓ $Name ya está instalado (versión $($installed.Version))." -ForegroundColor DarkGray
        }
        
        # Importar el módulo en la sesión actual si no está cargado
        if (-not (Get-Module -Name $Name)) {
            Import-Module $Name -ErrorAction SilentlyContinue
        }
        
    } catch {
        Write-Host " -> ✗ Error instalando $Name : $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
    
    return $true
}

# Instalación de módulos
$modules = @(
    @{Name = "Terminal-Icons"}
    @{Name = "PSReadLine"; MinimumVersion = "2.2.0"}  # Versión 2.2+ tiene mejoras importantes
    @{Name = "z"}
)

$failedModules = @()

foreach ($module in $modules) {
    $success = Ensure-Module @module
    if (-not $success) {
        $failedModules += $module.Name
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan

if ($failedModules.Count -eq 0) {
    Write-Host "✓ Todas las dependencias instaladas correctamente." -ForegroundColor Green
    Write-Host "`nNota: Para que los cambios surtan efecto, reinicia tu terminal o ejecuta:" -ForegroundColor Yellow
    Write-Host "      . `$PROFILE" -ForegroundColor White
} else {
    Write-Host "⚠️  Algunos módulos fallaron:" -ForegroundColor Red
    $failedModules | ForEach-Object { Write-Host "   - $_" -ForegroundColor Red }
    Write-Host "`nIntenta ejecutar el script como administrador o revisa tu conexión a internet." -ForegroundColor Yellow
}

Write-Host "========================================`n" -ForegroundColor Cyan