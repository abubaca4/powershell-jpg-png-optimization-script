param(
    [Parameter(Mandatory=$true, Position=0)][string]$InputPath, 
    [Parameter(Position=1)][string]$OutputPath, 
    [int]$j, 
    [switch]$AsciiTempMode
)

$ScriptDir = $PSScriptRoot
$CoreScript = Join-Path $ScriptDir "Core-Optimizer.ps1"
$Tool = Join-Path $ScriptDir "gifsicle\gifsicle.exe"
$ValTool = Join-Path $ScriptDir "gifsicle\gifdiff.exe"

$ArgsTemplate = "-i {src} -O3 -o {dest}"
$ValTemplate = "{src} {dest}"

& $CoreScript -InputPath $InputPath -OutputPath $OutputPath `
              -ToolPath $Tool `
              -ArgumentSets @($ArgsTemplate) `
              -Extensions @("*.gif") `
              -ValidatorPath $ValTool `
              -ValidatorArgs $ValTemplate `
              -ThrottleLimit $j `
              -AsciiTempMode:$AsciiTempMode