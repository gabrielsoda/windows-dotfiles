oh-my-posh init pwsh | Invoke-Expression

(& uv generate-shell-completion powershell) | Out-String | Invoke-Expression
(& uvx --generate-shell-completion powershell) | Out-String | Invoke-Expression
Invoke-Expression (& { (zoxide init powershell | Out-String) })

#Terminal Icons
Import-Module Terminal-Icons

#PSReadLine
Import-Module PSReadLine
Set-PSReadLineKeyHandler -Key Tab -Function TabCompleteNext
Set-PSReadLineOption -PredictionViewStyle ListView

# OPCIONAL: Historial mejorado de PSReadLine
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# Buscar archivos y abrirlos con VSCode
function fzf-code {
    $file = fzf
    if ($file) { code $file }
}
Set-Alias fzc fzf-code

# Buscar en historial de comandos con Ctrl+R
Set-PSReadLineKeyHandler -Key Ctrl+r -ScriptBlock {
    $command = Get-Content (Get-PSReadLineOption).HistorySavePath | fzf
    if ($command) {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($command)
    }
}

# Navegar a carpetas rápidamente
function fzf-cd {
    $dir = Get-ChildItem -Directory -Recurse -Depth 3 | Select-Object -ExpandProperty FullName | fzf
    if ($dir) { Set-Location $dir }
}
Set-Alias fzcd fzf-cd

# Función para descargar videos de YouTube usando yt_dlp
function yt {
    param($url)
    python -c @"
import yt_dlp
import sys

url = sys.argv[1]
ydl_opts = {
    'format': 'bestvideo+bestaudio/best',
    'outtmpl': '%(title)s-%(id)s.%(ext)s',
}

try:
    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        ydl.download([url])
    print('¡Descarga completa!')
except Exception as e:
    print(f'Ocurrió un error: {e}')
"@ $url
}

Set-Alias -Name yt -Value yt



# Función para WhisperX con alias wtxt (corregida para venv en whisperx-env)
function WhisperTxt {
    param (
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$AudioFiles
    )
    
    # Activa el venv específico
    $envPath = "C:\Users\Gabi\whisperx-env"
    if (Test-Path "$envPath\Scripts\Activate.ps1") {
        . "$envPath\Scripts\Activate.ps1"
        Write-Host "Venv de WhisperX activado" -ForegroundColor Green
    } else {
        Write-Host "Error: No se encontró el venv en $envPath" -ForegroundColor Red
        return
    }
    
    # Ejecuta WhisperX con params fijos y audios variables
    if ($AudioFiles.Count -eq 0) {
        Write-Host "Error: Debes proporcionar al menos un archivo de audio." -ForegroundColor Red
        return
    }
    whisperx $AudioFiles --model large-v3 --output_format txt --language es
    
    # Desactiva el venv después
    deactivate
    Write-Host "Transcripción completada. Venv desactivado." -ForegroundColor Green
}

Set-Alias -Name wtxt -Value WhisperTxt

function wyt {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$youtube_links
    )

    $env:PYTHONIOENCODING = "utf8"

    if (-not $youtube_links -or $youtube_links.Count -eq 0) {
        Write-Host "No has introducido ningun enlace."
        return
    }

    foreach ($link in $youtube_links) {
        Write-Host ""
        Write-Host "-----------------------------------------------------------------"
        Write-Host "--- 1. Obteniendo nombre..."
        Write-Host "-----------------------------------------------------------------"

        $temp_file = [System.IO.Path]::GetTempFileName()

        yt-dlp --get-filename --windows-filenames -o "%(title)s.m4a" "$link" > $temp_file

        if (-not (Test-Path $temp_file)) {
            Write-Host "ERROR: No se pudo obtener el nombre del archivo desde yt-dlp."
            Write-Host "Verifica el enlace o tu conexion a internet."
            continue
        }

        $audio_filename = (Get-Content $temp_file -Raw -Encoding UTF8).Trim()

        Remove-Item $temp_file

        if (-not $audio_filename) {
            Write-Host "ERROR: La variable del nombre de archivo esta vacia despues de la lectura."
            continue
        }

        Write-Host ""
        Write-Host "Titulo original obtenido: `"$audio_filename`""
        Write-Host ""
        Write-Host "-----------------------------------------------------------------"
        Write-Host "--- 2. Descargando..."
        Write-Host "-----------------------------------------------------------------"

        yt-dlp -f worstaudio -x --audio-format m4a -o "$audio_filename" "$link"

        if (-not (Test-Path $audio_filename)) {
            Write-Host "ERROR: El archivo `"$audio_filename`" no se encontro despues de la descarga."
            continue
        }

        Write-Host ""
        Write-Host "-----------------------------------------------------------------"
        Write-Host "--- 3. Transcribiendo con wtxt..."
        Write-Host "-----------------------------------------------------------------"
        wtxt "$audio_filename"

        Write-Host ""
        Write-Host "-----------------------------------------------------------------"
        Write-Host "--- 4. Limpiando archivo temporal..."
        Write-Host "-----------------------------------------------------------------"
        Remove-Item "$audio_filename"

        Write-Host ""
        Write-Host "-----------------------------------------------------------------"
        Write-Host "Proceso completado para: $link"
        Write-Host "-----------------------------------------------------------------"
        Write-Host ""
    }

    Write-Host ""
    Write-Host "-----------------------------------------------------------------"
    Write-Host "Todos los enlaces ingresados han sido procesados (o se intento)."
    Write-Host "-----------------------------------------------------------------"
}

function wyt2 {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$youtube_links
    )

    $env:PYTHONIOENCODING = "utf8"

    if (-not $youtube_links -or $youtube_links.Count -eq 0) {
        Write-Host "No has introducido ningun enlace."
        return
    }

    $counter = 1
    foreach ($link in $youtube_links) {
        Write-Host ""
        Write-Host "-----------------------------------------------------------------"
        Write-Host "--- Procesando enlace $counter..."
        Write-Host "-----------------------------------------------------------------"

        # Usar un nombre simple y fijo
        $audio_filename = "temp_audio_$counter.m4a"

        Write-Host "Descargando como: `"$audio_filename`""
        Write-Host ""

        # Descargar directamente con nombre fijo
        yt-dlp -f "ba[ext=m4a]/ba/worst" -o "$audio_filename" "$link"

        if (-not (Test-Path $audio_filename)) {
            Write-Host "ERROR: El archivo `"$audio_filename`" no se encontro despues de la descarga."
            Write-Host "Intenta actualizar yt-dlp: yt-dlp -U"
            $counter++
            continue
        }

        Write-Host ""
        Write-Host "-----------------------------------------------------------------"
        Write-Host "--- Transcribiendo con wtxt..."
        Write-Host "-----------------------------------------------------------------"
        wtxt "$audio_filename"

        Write-Host ""
        Write-Host "-----------------------------------------------------------------"
        Write-Host "--- Limpiando archivo temporal..."
        Write-Host "-----------------------------------------------------------------"
        Remove-Item "$audio_filename"

        Write-Host ""
        Write-Host "Completado: $link"
        Write-Host ""
        
        $counter++
    }

    Write-Host "Todos los enlaces procesados."
}

function ytd {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$youtube_links
    )

    $env:PYTHONIOENCODING = "utf8"

    if (-not $youtube_links -or $youtube_links.Count -eq 0) {
        Write-Host "No has introducido ningun enlace."
        return
    }

    foreach ($link in $youtube_links) {
        Write-Host ""
        Write-Host "-----------------------------------------------------------------"
        Write-Host "--- 1. Obteniendo nombre..."
        Write-Host "-----------------------------------------------------------------"

        $temp_file = [System.IO.Path]::GetTempFileName()

        yt-dlp --get-filename --windows-filenames -o "%(title)s.%(ext)s" "$link" > $temp_file

        if (-not (Test-Path $temp_file)) {
            Write-Host "ERROR: No se pudo obtener el nombre del archivo desde yt-dlp."
            Write-Host "Verifica el enlace o tu conexion a internet."
            continue
        }

        $video_filename = (Get-Content $temp_file -Raw -Encoding UTF8).Trim()

        Remove-Item $temp_file

        if (-not $video_filename) {
            Write-Host "ERROR: La variable del nombre de archivo esta vacia despues de la lectura."
            continue
        }

        Write-Host ""
        Write-Host "Titulo original obtenido: `"$video_filename`""
        Write-Host ""
        Write-Host "-----------------------------------------------------------------"
        Write-Host "--- 2. Descargando en la mejor calidad..."
        Write-Host "-----------------------------------------------------------------"

        yt-dlp -f "bestvideo+bestaudio/best" --merge-output-format mp4 -o "$video_filename" "$link"

        if (-not (Test-Path $video_filename)) {
            Write-Host "ERROR: El archivo `"$video_filename`" no se encontro despues de la descarga."
            continue
        }

        Write-Host ""
        Write-Host "-----------------------------------------------------------------"
        Write-Host "--- Descarga completada. El archivo guardado como `"$video_filename`""
        Write-Host "-----------------------------------------------------------------"
        Write-Host ""
    }

    Write-Host ""
    Write-Host "-----------------------------------------------------------------"
    Write-Host "Todos los enlaces ingresados han sido procesados (o se intento)."
    Write-Host "-----------------------------------------------------------------"
}


# Función para integrar subtítulos en archivos de video
function MuxSubs {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$VideoFile,
        
        [Parameter(Mandatory = $true, Position = 1)]
        [string]$SubtitleFile,
        
        [Parameter(Position = 2)]
        [string]$OutputFile,
        
        [Parameter()]
        [string]$Language = "spa",

        [Parameter()]
        [string]$Title = "Custom Subs"
    )

    # --- HELPER: CLEAN PATHS ---
    function Get-CleanPath {
        param ($Path)
        $Sanitized = $Path.Replace('`', '') 
        if (Test-Path -LiteralPath $Sanitized) { return (Convert-Path -LiteralPath $Sanitized) }
        return $null
    }

    # 1. VALIDATE INPUTS
    $RealVideoPath = Get-CleanPath -Path $VideoFile
    $RealSubPath = Get-CleanPath -Path $SubtitleFile

    if (-not $RealVideoPath -or -not $RealSubPath) { 
        Write-Host "✗ Error: Archivos no encontrados." -ForegroundColor Red; return 
    }

    # 2. SMART OUTPUT NAMING
    if (-not $OutputFile) {
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($RealVideoPath)
        # Evitar recursividad en el nombre (ej: _subs_subs)
        if ($baseName.EndsWith("_subs")) {
            $baseName = $baseName.Substring(0, $baseName.Length - 5)
        }
        $ext = [System.IO.Path]::GetExtension($RealVideoPath)
        $OutputFile = "$baseName`_subs$ext"
    }
    $OutputFile = [System.IO.Path]::GetFullPath($OutputFile)

    # 3. FIX ENCODING (ROBUST NET FRAMEWORK METHOD) ---------------------
    Write-Host "⟳ Normalizando subtítulos a UTF-8 con BOM..." -ForegroundColor DarkGray
    $TempSub = [System.IO.Path]::GetTempFileName()
    
    try {
        # Leemos todo el texto. Si no se especifica encoding, .NET intenta detectar.
        # A veces los SRT vienen en ANSI (Windows-1252).
        $Content = [System.IO.File]::ReadAllText($RealSubPath)
        
        # Forzamos escritura en UTF-8 con BOM (Byte Order Mark), que es lo que aman las TVs.
        $Utf8WithBom = new-object System.Text.UTF8Encoding $true
        [System.IO.File]::WriteAllText($TempSub, $Content, $Utf8WithBom)
        
        # Renombramos a .srt para que ffmpeg no se queje
        $TempSubSrt = "$TempSub.srt"
        Move-Item -Path $TempSub -Destination $TempSubSrt -Force
        $TempSub = $TempSubSrt
        
    } catch {
        Write-Host "⚠ Error en conversión UTF-8: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host "  -> Usando subtítulo original (puede fallar en TV)." -ForegroundColor Yellow
        $TempSub = $RealSubPath
    }
    # -------------------------------------------------------------------

    # 4. STREAM COUNT
    $existingStreams = ffprobe -v error -select_streams s -show_entries stream=index -of csv=p=0 "$RealVideoPath" 2>$null
    $streamCount = if ($existingStreams) {
        @($existingStreams -split "`n" | Where-Object { $_.Trim() -ne "" }).Count
    } else { 0 }

    Write-Host "• Muxing: $(Split-Path $RealVideoPath -Leaf) + Subtítulos ($streamCount subs existentes)" -ForegroundColor Cyan

    # 5. EXECUTE FFMPEG
    $ffArgs = "-i `"$RealVideoPath`" -i `"$TempSub`" -map 0 -map 1 -c copy " +
              "-metadata:s:s:$streamCount language=$Language " +
              "-metadata:s:s:$streamCount title=`"$Title`" " +
              "-disposition:s:s:$streamCount default " +
              "`"$OutputFile`""

    $process = Start-Process -FilePath "ffmpeg" -ArgumentList $ffArgs `
        -Wait -NoNewWindow -PassThru

    # 6. CLEANUP
    if ($TempSub -ne $RealSubPath -and (Test-Path $TempSub)) { Remove-Item $TempSub }

    if ($process.ExitCode -eq 0) {
        Write-Host "✓ Listo: $(Split-Path $OutputFile -Leaf)" -ForegroundColor Green
    } else {
        Write-Host "✗ Error FFmpeg: $($process.ExitCode)" -ForegroundColor Red
    }
}
Set-Alias -Name subs -Value MuxSubs

# Procesar clases TUIA: transcribir videos y generar notas en Obsidian
function ProcesarClases {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Args
    )
    uv run "C:\Users\Gabi\Proyectos\tuia-procesar-clases\procesar_clases.py" @Args
}
Set-Alias -Name pc -Value ProcesarClases

# Subir clases TUIA: subir a YouTube
function SubirClases {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Args
    )
    uv run "C:\Users\Gabi\Proyectos\tuia-procesar-clases\subir_clases.py" @Args
}
Set-Alias -Name sc -Value SubirClases

# Quitar silencios de clases TUIA con auto-editor
function QuitarSilencios {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Args
    )
    uv run "C:\Users\Gabi\Proyectos\tuia-procesar-clases\quitar_silencios.py" @Args
}
Set-Alias -Name qs -Value QuitarSilencios

# Limpiar clases TUIA: eliminar videos ya subidos a YouTube
function LimpiarClases {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Args
    )
    uv run "C:\Users\Gabi\Proyectos\tuia-procesar-clases\limpiar_clases.py" @Args
}
Set-Alias -Name lc -Value LimpiarClases

# Pipeline completo de clases TUIA: transcribir, recortar silencios (y subir a YouTube a futuro)
function ProcesarClasesCompleto {
    param(
        [switch]$y
    )
    $flags = @()
    if ($y) { $flags += "-y" }
    
    uv run "C:\Users\Gabi\Proyectos\tuia-procesar-clases\procesar_clases.py" @flags
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error en procesar_clases.py (código $LASTEXITCODE). Abortando pipeline." -ForegroundColor Red
        return
    }
    uv run "C:\Users\Gabi\Proyectos\tuia-procesar-clases\quitar_silencios.py" @flags
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error en quitar_silencios.py (código $LASTEXITCODE)." -ForegroundColor Red
    }
}
Set-Alias -Name clases -Value ProcesarClasesCompleto

# --- AUTO-UPDATE SCOOP CONFIG ---
$RepoPath = $PSScriptRoot
$ScoopFile = Join-Path $RepoPath "scoop_apps.json"

if (Test-Path $RepoPath) {
    $LastUpdate = if (Test-Path $ScoopFile) { (Get-Item $ScoopFile).LastWriteTime } else { [DateTime]::MinValue }
    
    if ((Get-Date) -gt $LastUpdate.AddDays(7)) {
        Write-Host "Actualizando lista de apps de Scoop (Backup semanal)..." -ForegroundColor DarkGray
        try {
            scoop export | Out-File $ScoopFile -Encoding utf8 -Force
            # Opcional: Auto-commit 
            git -C $RepoPath commit -am "Auto-update: scoop apps list" | Out-Null
        } catch {
            Write-Host "Error actualizando backup de Scoop." -ForegroundColor Red
        }
    }
}