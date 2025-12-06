param(
    [Parameter(Position=0)]
    [string]$InputPath,
    
    [Parameter(Position=1)]
    [string]$OutputPath
)

# Detect system language
$SystemLanguage = (Get-Culture).TwoLetterISOLanguageName

# Messages in both languages
$Messages = @{
    "InputPathNotSpecified" = @{
        "ru" = "Не указан входной путь"
        "en" = "Input path not specified"
    }
    "InputPathNotFound" = @{
        "ru" = "Входной путь не существует: {0}"
        "en" = "Input path does not exist: {0}"
    }
    "GifsicleNotFound" = @{
        "ru" = "gifsicle не найден по пути: {0}"
        "en" = "gifsicle not found at path: {0}"
    }
    "GifdiffNotFound" = @{
        "ru" = "gifdiff не найден по пути: {0}"
        "en" = "gifdiff not found at path: {0}"
    }
    "Start" = @{
        "ru" = "НАЧАЛО: {0}"
        "en" = "START: {0}"
    }
    "SizeHeader" = @{
        "ru" = "Размер в байтах:"
        "en" = "Size in bytes:"
    }
    "SizeRowHeader" = @{
        "ru" = "исх.    сейчас  % от исх.    имя и путь (секунд обработки)"
        "en" = "orig.   current % of orig.   name and path (processing seconds)"
    }
    "NotCompressed" = @{
        "ru" = "не сжался"
        "en" = "not compressed"
    }
    "ValidationFailed" = @{
        "ru" = "ошибка проверки"
        "en" = "validation failed"
    }
    "ErrorProcessing" = @{
        "ru" = "ошибка"
        "en" = "error"
    }
    "ErrorDetailed" = @{
        "ru" = "ОШИБКА: {0} - {1}"
        "en" = "ERROR: {0} - {1}"
    }
    "End" = @{
        "ru" = "КОНЕЦ: {0}"
        "en" = "END: {0}"
    }
    "ReplacePrompt" = @{
        "ru" = "Заменить оригинальные GIF файлы сжатыми версиями? Нажмите Y для ДА или N для НЕТ и нажмите ENTER"
        "en" = "Replace original GIF files with compressed versions? Press Y for YES or N for NO and press ENTER"
    }
    "DoneReplaced" = @{
        "ru" = "Готово. Оригинальные файлы были заменены."
        "en" = "Done. Original files have been replaced."
    }
    "DoneNotReplaced" = @{
        "ru" = "Готово. Оригинальные и сжатые файлы сохранены. Сжатые файлы имеют суффикс .opti"
        "en" = "Done. Original and compressed files are saved. Compressed files have suffix .opti"
    }
    "DoneOutput" = @{
        "ru" = "Готово. Сжатые файлы сохранены в: {0}"
        "en" = "Done. Compressed files are saved in: {0}"
    }
}

# Helper function to get localized message
function Get-LocalizedMessage {
    param([string]$Key, [array]$FormatArgs = @())
    
    $messageTemplate = $Messages[$Key][$SystemLanguage]
    if (-not $messageTemplate) {
        $messageTemplate = $Messages[$Key]["en"] # Fallback to English
    }
    
    if ($FormatArgs.Count -gt 0) {
        return $messageTemplate -f $FormatArgs
    }
    return $messageTemplate
}

# Settings
$GifsiclePath = "gifsicle\gifsicle.exe"
$GifdiffPath = "gifsicle\gifdiff.exe"

# Get number of processor cores for parallel processing
$ProcessorCores = (Get-CimInstance Win32_Processor).NumberOfCores
if (-not $ProcessorCores -or $ProcessorCores -lt 1) {
    $ProcessorCores = 1
}

# Check arguments
if (-not $InputPath) {
    Write-Error (Get-LocalizedMessage "InputPathNotSpecified")
    exit 1
}

if (-not (Test-Path $InputPath)) {
    Write-Error (Get-LocalizedMessage "InputPathNotFound" $InputPath)
    exit 1
}

if (-not $OutputPath) {
    $OutputPath = $InputPath
    $ConfirmReplace = $true
} else {
    if (-not (Test-Path $OutputPath)) {
        New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
    }
    $ConfirmReplace = $false
}

# Check if gifsicle exists
if (-not (Test-Path $GifsiclePath)) {
    Write-Error (Get-LocalizedMessage "GifsicleNotFound" $GifsiclePath)
    exit 1
}

# Check if gifdiff exists
if (-not (Test-Path $GifdiffPath)) {
    Write-Error (Get-LocalizedMessage "GifdiffNotFound" $GifdiffPath)
    exit 1
}

Write-Host (Get-LocalizedMessage "Start" (Get-Date))
Write-Host (Get-LocalizedMessage "SizeHeader")
Write-Host (Get-LocalizedMessage "SizeRowHeader")

# Get all files for processing (only GIF)
$Files = Get-ChildItem -Path $InputPath -Include *.gif -Recurse -File

# Function to process a single file
function Optimize-File {
    param($File, $GifsiclePath, $GifdiffPath, $ProcessorCores, $OutputPath, $InputPath, $ConfirmReplace)
    
    $StartTime = Get-Date
    $OriginalFile = $File.FullName

    try {
        # Determine output filename
        if ($ConfirmReplace) {
            # If output to the same folder
            $OutputFile = $File.FullName + ".opti" + $File.Extension
        } else {
            # If output to a different folder
            $OutputFile = Join-Path $OutputPath ($File.BaseName + ".opti" + $File.Extension)
        }
        
        # Create folder for output file if needed
        $OutputDir = Split-Path $OutputFile -Parent
        if (-not (Test-Path $OutputDir)) {
            New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
        }
        
        $OriginalSize = $File.Length
        
        $ProcessInfo = New-Object System.Diagnostics.ProcessStartInfo
        $ProcessInfo.FileName = $GifsiclePath
        $ProcessInfo.Arguments = "-i `"$OriginalFile`" -O3 -j$ProcessorCores -o `"$OutputFile`""
        $ProcessInfo.UseShellExecute = $false
        $ProcessInfo.RedirectStandardOutput = $true
        $ProcessInfo.RedirectStandardError = $true
        $ProcessInfo.CreateNoWindow = $true
        
        $Process = New-Object System.Diagnostics.Process
        $Process.StartInfo = $ProcessInfo
        $Process.Start() | Out-Null
        $Process.WaitForExit()
        $GifsicleExitCode = $Process.ExitCode
        
        if ($GifsicleExitCode -eq 0 -and (Test-Path $OutputFile)) { 
            $NewSize = (Get-Item $OutputFile).Length
            
            # Validate that files are identical using gifdiff
            $DiffProcessInfo = New-Object System.Diagnostics.ProcessStartInfo
            $DiffProcessInfo.FileName = $GifdiffPath
            $DiffProcessInfo.Arguments = "`"$OriginalFile`" `"$OutputFile`""
            $DiffProcessInfo.UseShellExecute = $false
            $DiffProcessInfo.RedirectStandardOutput = $true
            $DiffProcessInfo.RedirectStandardError = $true
            $DiffProcessInfo.CreateNoWindow = $true
            
            $DiffProcess = New-Object System.Diagnostics.Process
            $DiffProcess.StartInfo = $DiffProcessInfo
            $DiffProcess.Start() | Out-Null
            $DiffProcess.WaitForExit()
            $GifdiffExitCode = $DiffProcess.ExitCode
            
            $EndTime = Get-Date
            $TimeSpent = [math]::Round(($EndTime - $StartTime).TotalSeconds, 2)
            
            if ($GifdiffExitCode -eq 0 -and $NewSize -lt $OriginalSize) {
                # Files are identical and compressed file is smaller
                $Percent = [math]::Round(($NewSize / $OriginalSize) * 100, 2)
                Write-Host "$OriginalSize`t$NewSize`t$Percent`t`t$($File.Name) ($TimeSpent)"
                return @{
                    OriginalFile = $OriginalFile
                    OutputFile = $OutputFile
                    OriginalSize = $OriginalSize
                    CompressedSize = $NewSize
                }
            } else {
                # If validation failed or file wasn't compressed, delete output file
                Remove-Item $OutputFile -Force -ErrorAction SilentlyContinue
                
                if ($GifdiffExitCode -ne 0) {
                    Write-Host "$OriginalSize`t----`t$(Get-LocalizedMessage "ValidationFailed")`t`t$($File.Name)"
                } else {
                    Write-Host "$OriginalSize`t----`t$(Get-LocalizedMessage "NotCompressed")`t`t$($File.Name)"
                }
                return $null
            }
        } else {
            # Если gifsicle завершился с ошибкой, получим вывод ошибки
            $ErrorOutput = $Process.StandardError.ReadToEnd()
            if ($ErrorOutput) {
                Write-Host "$OriginalSize`t----`t$(Get-LocalizedMessage "ErrorProcessing"): $ErrorOutput`t$($File.Name)"
            } else {
                Write-Host "$OriginalSize`t----`t$(Get-LocalizedMessage "ErrorProcessing")`t`t$($File.Name)"
            }
            return $null
        }
    }
    catch {
        Write-Host (Get-LocalizedMessage "ErrorDetailed" $File.Name $_.Exception.Message)
        return $null
    }
    finally {
        if ($Process -ne $null) {
            $Process.Dispose()
        }
        if ($DiffProcess -ne $null) {
            $DiffProcess.Dispose()
        }
    }
}

# Process files sequentially
$Results = @()
foreach ($File in $Files) {
    $Result = Optimize-File -File $File -GifsiclePath $GifsiclePath -GifdiffPath $GifdiffPath -ProcessorCores $ProcessorCores -OutputPath $OutputPath -InputPath $InputPath -ConfirmReplace $ConfirmReplace
    if ($Result -ne $null) {
        $Results += $Result
    }
}

Write-Host (Get-LocalizedMessage "End" (Get-Date))

# Prompt for replacing originals if needed
if ($ConfirmReplace -and $Results.Count -gt 0) {
    $Response = Read-Host (Get-LocalizedMessage "ReplacePrompt")
    if ($Response -eq 'Y' -or $Response -eq 'y') {
        foreach ($Result in $Results) {
            if ($Result -ne $null) {
                # Replace original GIF file
                Move-Item $Result.OutputFile $Result.OriginalFile -Force
            }
        }
        Write-Host (Get-LocalizedMessage "DoneReplaced")
    } else {
        Write-Host (Get-LocalizedMessage "DoneNotReplaced")
    }
} else {
    Write-Host (Get-LocalizedMessage "DoneOutput" $OutputPath)
}