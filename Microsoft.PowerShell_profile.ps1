oh-my-posh init pwsh | Invoke-Expression

(& uv generate-shell-completion powershell) | Out-String | Invoke-Expression
(& uvx --generate-shell-completion powershell) | Out-String | Invoke-Expression


#Terminal Icons
Import-Module Terminal-Icons

#PSReadLine
Import-Module PSReadLine
Set-PSReadLineKeyHandler -Key Tab -Function TabCompleteNext
Set-PSReadLineOption -PredictionViewStyle ListView

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
    whisperx $AudioFiles --model large-v3 --language es --output_format txt
    
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

    # --- HELPER FUNCTION TO SANITIZE PATHS ---
    function Get-CleanPath {
        param ($Path)
        # 1. Try the path exactly as given
        if (Test-Path -LiteralPath $Path) {
            return (Convert-Path -LiteralPath $Path)
        }
        # 2. If failed, try removing backticks (Fix for single-quoted tab-completions)
        $Sanitized = $Path.Replace('`', '')
        if (Test-Path -LiteralPath $Sanitized) {
            return (Convert-Path -LiteralPath $Sanitized)
        }
        # 3. Fail
        return $null
    }

    # 1. CLEAN & RESOLVE PATHS
    $RealVideoPath = Get-CleanPath -Path $VideoFile
    if (-not $RealVideoPath) { 
        Write-Host "✗ Error: Video not found: $VideoFile" -ForegroundColor Red; return 
    }

    $RealSubPath = Get-CleanPath -Path $SubtitleFile
    if (-not $RealSubPath) { 
        Write-Host "✗ Error: Subtitle not found: $SubtitleFile" -ForegroundColor Red; return 
    }

    # 2. Smart Output Naming
    if (-not $OutputFile) {
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($RealVideoPath)
        $ext = [System.IO.Path]::GetExtension($RealVideoPath)
        $OutputFile = "$baseName`_subs$ext"
    }
    # Ensure Output is absolute path
    $OutputFile = [System.IO.Path]::GetFullPath($OutputFile)

    # 3. COUNT STREAMS (FFPROBE)
    try {
        # Use quoted path for ffprobe
        $existingStreams = ffprobe -v error -select_streams s -show_entries stream=index -of csv=p=0 "$RealVideoPath" 2>$null
        
        if ($null -eq $existingStreams) { $streamCount = 0 }
        elseif ($existingStreams -is [array]) { $streamCount = $existingStreams.Count }
        else { $streamCount = 1 }
    } catch {
        Write-Host "⚠ Warning: Could not count streams. Assuming 0 existing subs." -ForegroundColor Yellow
        $streamCount = 0
    }
    
    $newStreamIndex = $streamCount

    # 4. STATUS DISPLAY
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "  SMART MUX (Tracks detected: $streamCount)" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Video:  $RealVideoPath"
    Write-Host "Subs:   $RealSubPath"
    Write-Host "Target: Stream Index #$newStreamIndex" 
    Write-Host "----------------------------------------" -ForegroundColor DarkGray

    # 5. EXECUTE FFMPEG
    $process = Start-Process -FilePath "ffmpeg" -ArgumentList `
        "-i `"$RealVideoPath`"", `
        "-i `"$RealSubPath`"", `
        "-map 0", `
        "-map 1", `
        "-c copy", `
        "-metadata:s:s:$newStreamIndex language=$Language", `
        "-metadata:s:s:$newStreamIndex title=`"$Title`"", `
        "`"$OutputFile`"" `
        -Wait -NoNewWindow -PassThru

    if ($process.ExitCode -eq 0) {
        Write-Host "`n✓ Success! New file: $OutputFile" -ForegroundColor Green
    } else {
        Write-Host "`n✗ Error: FFmpeg exited with code $($process.ExitCode)" -ForegroundColor Red
    }
}

Set-Alias -Name subs -Value MuxSubs



# --- AUTO-UPDATE SCOOP CONFIG ---
$RepoPath = "$HOME\Documents\PowerShell\" # poner ruta correcta
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