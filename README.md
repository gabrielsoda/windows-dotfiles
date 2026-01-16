# PowerShell + Scoop + Windows Terminal Backup

> Backup de configuración personal de PowerShell, aplicaciones de Scoop y Windows Terminal para facilitar la reinstalación después de formatear Windows.

## Componentes

| Archivo | Descripción |
|---------|-------------|
| `Microsoft.PowerShell_profile.ps1` | Perfil de PowerShell con funciones de automatización y configuración del entorno |
| `scoop_apps.json` | Lista de aplicaciones y buckets de Scoop (auto-actualizable) |
| `setup_scoop.ps1` | Script de restauración de Scoop con GUI de selección |
| `settings.json` | Configuración de Windows Terminal (temas, fuentes, perfiles) |
| `setup_terminal.ps1` | Script que restaura la configuración de Windows Terminal |
| `open_dev_layout.bat` | Abre Windows Terminal con layout de 3 paneles (hotkey rápido) |
| `install_dependencies.ps1` | Instala módulos de PowerShell requeridos |
| `powershell.config.json` | Política de ejecución |

> **Nota:** La actualización automática de la lista de aplicaciones en scoop está comentada por defecto: **descomentar si se está en la máquina principal**.

## Restauración rápida

```powershell
# 1. Clonar en la carpeta de PowerShell
$TargetDir = "$HOME\Documents\PowerShell"
New-Item -ItemType Directory -Path $TargetDir -Force
Set-Location $TargetDir
git clone https://github.com/gabrielsoda/windows-dotfiles.git .

# 2. Scoop + Apps
.\setup_scoop.ps1

# 3. Módulos PowerShell
.\install_dependencies.ps1

# 4. Perfil de PowerShell
Copy-Item .\Microsoft.PowerShell_profile.ps1 $PROFILE -Force

# 5. Windows Terminal
.\setup_terminal.ps1

# 6. Reiniciar terminal
```

## Windows Terminal

### Perfiles incluidos

El `settings.json` incluye estos perfiles:

| Perfil | Descripción |
|--------|-------------|
| PowerShell | PowerShell 7+ (default) |
| Windows PowerShell | PowerShell 5.1 legacy |
| Ubuntu | WSL Ubuntu |
| SSH Server | Conexión a `gsoda@192.168.1.38` |
| WSL Home | WSL Ubuntu iniciando en `~` |

### Layout de 3 paneles

Para abrir una ventana con los 3 entornos (host + servidor + WSL):

```powershell
.\open_dev_layout.ps1
```

Layout resultante:
```
┌─────────────────┬─────────────────┐
│   PowerShell    │                 │
│    (host)       │                 │
├─────────────────┤    SSH Server   │
│   WSL Home      │                 │
│    (Ubuntu)     │                 │
└─────────────────┴─────────────────┘
```

### Configurar atajo de teclado (Ctrl+Alt+T)

El archivo `.bat` es más rápido y estable para hotkeys que ps1. Para configurar:

```powershell
# Configurar política de ejecución (solo necesario una vez)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Crear atajo con hotkey
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Dev Layout.lnk")
$Shortcut.TargetPath = "$HOME\Documents\PowerShell\open_dev_layout.bat"
$Shortcut.WindowStyle = 7  # Minimized
$Shortcut.Hotkey = "Ctrl+Alt+T"  # Modificar a gusto
$Shortcut.Save()
```

Abrirá el layout de 3 paneles desde cualquier lugar.


## Funciones del perfil

### Transcripción (WhisperX)

| Comando | Descripción |
|---------|-------------|
| `wtxt <archivos>` | Transcribe audio a `.txt` (modelo large-v3, español) |
Comando real ejecutado:
> `whisperx $AudioFiles --model large-v3 --language es --output_format txt`

### YouTube

| Comando | Descripción |
|---------|-------------|
| `wyt <urls>` | Descarga audio, transcribe, elimina audio |
| `wyt2 <urls>` | Igual que `wyt` pero usa nombres temporales |
| `ytd <urls>` | Descarga video en mejor calidad (MP4) |
| `yt <urls>` | Alternativa al anterior |

### Video (FFmpeg)

| Comando | Descripción |
|---------|-------------|
| `subs <video> <srt> [output] [lang] [title]` | Muxea subtítulos en video sin recodificar |

## Auto-actualización de Scoop

El perfil tiene un bloque (comentado por defecto) que verifica semanalmente si `scoop_apps.json` necesita actualizarse.

**Para activar en la PC principal:** Descomentar el bloque "AUTO-UPDATE SCOOP CONFIG" al final del `$PROFILE`.

## Dependencias

- PowerShell 7+
- Módulos: `oh-my-posh`, `Terminal-Icons`, `PSReadLine`
- CLI: `ffmpeg`, `yt-dlp`, `uv` (en PATH, instalables via Scoop)
- Entorno virtual con `whisperx` en `C:\Users\Gabi\whisperx-env` (ajustar ruta si es necesario) para funciones `wtxt`/`wyt`.