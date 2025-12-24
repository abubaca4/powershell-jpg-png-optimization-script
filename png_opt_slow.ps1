param(
    [Parameter(Mandatory=$true, Position=0)][string]$InputPath, 
    [Parameter(Position=1)][string]$OutputPath, 
    [int]$j, 
    [switch]$AsciiTempMode
)

$ScriptDir = $PSScriptRoot
$CoreScript = Join-Path $ScriptDir "Core-Optimizer.ps1"
$Tool = Join-Path $ScriptDir "oxipng\oxipng.exe"

$ArgsTemplate = "--opt max --strip safe --quiet --zopfli --out {dest} {src}"

& $CoreScript -InputPath $InputPath -OutputPath $OutputPath `
              -ToolPath $Tool `
              -ArgumentSets @($ArgsTemplate) `
              -Extensions @("*.png", "*.apng") `
              -ThrottleLimit $j `
              -AsciiTempMode:$AsciiTempMode