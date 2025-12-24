param(
    [Parameter(Mandatory=$true, Position=0)][string]$InputPath, 
    [Parameter(Position=1)][string]$OutputPath, 
    [int]$j, 
    [switch]$AsciiTempMode
)

$ScriptDir = $PSScriptRoot
$CoreScript = Join-Path $ScriptDir "Core-Optimizer.ps1"
$Tool = Join-Path $ScriptDir "mozjpeg\jpegtran-static.exe"

$ArgsTemplate = "-outfile {dest} -copy none -optimize {src}"

& $CoreScript -InputPath $InputPath -OutputPath $OutputPath `
              -ToolPath $Tool `
              -ArgumentSets @($ArgsTemplate) `
              -Extensions @("*.jpg", "*.jpeg") `
              -ThrottleLimit $j `
              -AsciiTempMode:$AsciiTempMode