param(
    [Parameter(Mandatory=$true, Position=0)][string]$InputPath, 
    [Parameter(Position=1)][string]$OutputPath, 
    [int]$j, 
    [switch]$AsciiTempMode
)

$ScriptDir = $PSScriptRoot
$CoreScript = Join-Path $ScriptDir "Core-Optimizer.ps1"
$Tool = Join-Path $ScriptDir "mozjpeg\cjpeg-static.exe"

$Params = @(
    "-dct float -quant-table 1 -nojfif -dc-scan-opt 2 -outfile {dest} {src}",
    "-dct float -quant-table 2 -nojfif -dc-scan-opt 2 -outfile {dest} {src}",
    "-dct float -quant-table 3 -nojfif -dc-scan-opt 2 -outfile {dest} {src}",
    "-dct float -tune-ms-ssim -nojfif -dc-scan-opt 2 -outfile {dest} {src}",
    "-dct float -tune-ms-ssim -quant-table 3 -nojfif -dc-scan-opt 2 -outfile {dest} {src}",
    "-dct float -tune-ssim -nojfif -dc-scan-opt 2 -outfile {dest} {src}",
    "-dct float -tune-ssim -quant-table 0 -nojfif -dc-scan-opt 2 -outfile {dest} {src}",
    "-dct float -tune-ssim -quant-table 1 -nojfif -dc-scan-opt 2 -outfile {dest} {src}",
    "-dct float -tune-ssim -quant-table 2 -nojfif -dc-scan-opt 2 -outfile {dest} {src}",
    "-dct float -tune-ssim -quant-table 3 -nojfif -dc-scan-opt 1 -outfile {dest} {src}",
    "-dct float -tune-ssim -quant-table 3 -nojfif -dc-scan-opt 2 -outfile {dest} {src}",
    "-dct float -tune-ssim -quant-table 4 -nojfif -dc-scan-opt 2 -outfile {dest} {src}",
    "-quant-table 2 -nojfif -dc-scan-opt 1 -outfile {dest} {src}",
    "-quant-table 2 -nojfif -dc-scan-opt 2 -outfile {dest} {src}",
    "-tune-ssim -nojfif -dc-scan-opt 2 -outfile {dest} {src}",
    "-tune-ssim -quant-table 1 -nojfif -dc-scan-opt 2 -outfile {dest} {src}",
    "-tune-ssim -quant-table 2 -nojfif -outfile {dest} {src}",
    "-tune-ssim -quant-table 2 -nojfif -dc-scan-opt 0 -outfile {dest} {src}",
    "-tune-ssim -quant-table 2 -nojfif -dc-scan-opt 2 -outfile {dest} {src}",
    "-tune-ssim -quant-table 3 -nojfif -dc-scan-opt 1 -outfile {dest} {src}",
    "-tune-ssim -quant-table 3 -nojfif -dc-scan-opt 2 -outfile {dest} {src}"
)

$Exts = @("*.png", "*.ppm", "*.pnm", "*.pgm", "*.pbm", "*.bmp", "*.dib", "*.tga", "*.icb", "*.vda", "*.vst", "*.rle", "*.jpg", "*.jpeg")

& $CoreScript -InputPath $InputPath -OutputPath $OutputPath `
              -ToolPath $Tool `
              -ArgumentSets $Params `
              -Extensions $Exts `
              -OutputExtension ".jpg" `
              -ThrottleLimit $j `
              -AsciiTempMode:$AsciiTempMode