# PowerShell + Scoop Backup

> El objetivo principal de este repositorio es Backup de la configuración personal de PowerShell y las aplicaciones de Scoop que utilizo, para facilitar la reinstalación después de formatear la PC en windows.

## Componentes

- `Microsoft.PowerShell_profile.ps1`  
  El perfil de PowerShell con funciones de automatización (whisperx, yt-dlp, ffmpeg) y configuración del entorno (oh-my-posh, terminal-icons, psreadline, autocompletado).

- `scoop_apps.json`  
  Lista de aplicaciones y buckets de Scoop exportada, que se actualiza automáticamente cada semana.
  > ESTO ESTÁ COMENTADO POR DEFECTO: DESCOMENTAR SI SE ESTÁ EN LA PC PRINCIPAL.

- `setup_scoop.ps1`  
  Script de restauración que instala Scoop, añade los buckets y permite con interfaz seleccionar qué aplicaciones reinstalar de la lista.

- `powershell.config.json`  
  Configuración de la política de ejecución.

## Flujos

### Flujo de auto-actualización

El perfil tiene un bloque al final que verifica si `scoop_apps.json` tiene más de 7 días y, si es así, ejecuta `scoop export` y hace auto-commit.
Por defecto está comentado. Descomentar si estás en la pc principal.

### Flujo de restauración

En una PC nueva, se clona el repositorio, se ejecuta `setup_scoop.ps1` para restaurar las apps de Scoop, se instalan los módulos de PowerShell ejecutando `install_dependencies.ps1` y se copia el perfil a `$PROFILE`.  
Reiniciar terminal.


## Restauración

### 1. Clonar repositorio 
**Opcional: clonar en carpeta de configuración por defecto:**
Idealmente el repositorio debe clonarse **directamente** en la carpeta estándar de perfiles de PowerShell. Esto permite que el sistema cargue el perfil automáticamente sin pasos extra.

```powershell
# Asegura que el directorio existe (o se crea)
$TargetDir = "$HOME\Documents\PowerShell"
New-Item -ItemType Directory -Path $TargetDir -Force

# Ubica en el directorio y clona ('.' es para no crear una subcarpeta)
Set-Location $TargetDir
git clone https://github.com/gabrielsoda/windows-dotfiles.git .
```

### 2. Scoop + Apps

```powershell
.\setup_scoop.ps1
```

Instala Scoop (si no existe), añade buckets y reinstala las apps listadas.

### 3. Módulos PowerShell

```powershell
.\install_dependencies.ps1
```

### 4. Perfil de PowerShell

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
> **Nota:** La ruta del entorno virtual está hardcodeada en `C:\Users\Gabi\whisperx-env`. Modificar la variable `$envPath` en la función `WhisperTxt` según corresponda.
## Funciones disponibles integradas en el perfil de PowerShell

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
| `yt <urls>` | Alternativa al anterior |

### Video (FFmpeg)

| Comando | Descripción |
|---------|-------------|
| `subs <video> <srt> [output] [lang] [title]` | Muxea subtítulos en video sin recodificar |

## Notas de configuración del script de actualización automática de las aplicaciones en scoop:

* **PC Principal (Master):** Para activar el backup semanal automático de aplicaciones, abrir `$PROFILE` y **descomentar** el bloque final ("AUTO-UPDATE SCOOP CONFIG").
* **Ruta dinámica:** El perfil detecta automáticamente su ubicación (`$PSScriptRoot`), por lo que la auto-actualización funciona sin ajustar rutas manuales.
