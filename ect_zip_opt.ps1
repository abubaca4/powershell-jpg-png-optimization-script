param(
    [Parameter(Mandatory=$true, Position=0)][string]$InputPath,
    [Parameter(Position=1)][string]$OutputPath,
    [int]$j,
    [switch]$AsciiTempMode = $true
)

$ScriptDir = $PSScriptRoot
$CoreScript = Join-Path $ScriptDir "Core-Optimizer.ps1"
$Tool = Join-Path $ScriptDir "ect\ect.exe"

$ArgsTemplate = "-9 -zip --disable-png --disable-jpg -quiet {src}"

& $CoreScript -InputPath $InputPath -OutputPath $OutputPath `
              -ToolPath $Tool `
              -ArgumentSets @($ArgsTemplate) `
              -Extensions @("*.zip") `
              -ThrottleLimit $j `
              -AsciiTempMode:$AsciiTempMode
