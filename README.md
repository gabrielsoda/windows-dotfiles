# PowerShell + Scoop Backup

> El objetivo principal de este repositorio es Backup de la configuración personal de PowerShell y las aplicaciones de Scoop que utilizo, para facilitar la reinstalación después de formatear la PC en windows.

## Componentes

- `Microsoft.PowerShell_profile.ps1`  
  El perfil de PowerShell con funciones de automatización (whisperx, yt-dlp, ffmpeg) y configuración del entorno (oh-my-posh, terminal-icons, psreadline, autocompletado).

- `scoop_apps.json`  
  Lista de aplicaciones y buckets de Scoop exportada, que se actualiza automáticamente cada semana.

- `setup_scoop.ps1`  
  Script de restauración que instala Scoop, añade los buckets y reinstala las apps.

- `powershell.config.json`  
  Configuración de la política de ejecución.

## Flujos

### Flujo de auto-actualización

El perfil tiene un bloque al final que verifica si `scoop_apps.json` tiene más de 7 días y, si es así, ejecuta `scoop export` y hace auto-commit.

### Flujo de restauración

En una PC nueva, se clona el repositorio, se ejecuta `setup_scoop.ps1` para restaurar las apps de Scoop, y se copia el perfil a `$PROFILE`.  
Backup de configuración de PowerShell y aplicaciones de Scoop para restaurar en formateos.


## Estructura

| Archivo | Descripción |
|---------|-------------|
| `Microsoft.PowerShell_profile.ps1` | Perfil de PowerShell (copiar a `$PROFILE`) |
| `scoop_apps.json` | Lista de apps y buckets de Scoop (auto-actualiza semanalmente) |
| `setup_scoop.ps1` | Script de restauración de Scoop |
| `powershell.config.json` | Política de ejecución |

## Restauración

### 1. Scoop + Apps

```powershell
.\setup_scoop.ps1
```

Instala Scoop (si no existe), añade buckets y reinstala las apps listadas.

### 2. Perfil de PowerShell

```powershell
Copy-Item .\Microsoft.PowerShell_profile.ps1 $PROFILE -Force
```

Reiniciar terminal.

## Dependencias

El perfil requiere:

- PowerShell 7+
- `oh-my-posh`, `Terminal-Icons`, `PSReadLine` (módulos)
- `ffmpeg`, `ffprobe`, `yt-dlp`, `uv` (en PATH, instalables via Scoop)
- Entorno virtual con `whisperx` en `C:\Users\Gabi\whisperx-env` (para funciones `wtxt`/`wyt`)

## Funciones del Perfil

### Transcripción (WhisperX)

| Comando | Descripción |
|---------|-------------|
| `wtxt <archivos>` | Transcribe audio a `.txt` (modelo large-v3, español) |

### YouTube

| Comando | Descripción |
|---------|-------------|
| `wyt <urls>` | Descarga audio, transcribe, elimina audio |
| `wyt2 <urls>` | Igual que `wyt` pero usa nombres temporales (evita errores con títulos raros) |
| `ytd <urls>` | Descarga video en mejor calidad (MP4) |

### Video (FFmpeg)

| Comando | Descripción |
|---------|-------------|
| `subs <video> <srt> [output] [lang] [title]` | Muxea subtítulos en video sin recodificar |

## Auto-actualización

El perfil exporta `scoop_apps.json` automáticamente si tiene más de 7 días. Hace commit si el repo está en `$HOME\Documents\PowerShell\`. Ajustar `$RepoPath` en el perfil si es otra ubicación.
