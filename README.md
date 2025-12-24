# PowerShell Image Optimization Suite

A collection of PowerShell scripts for batch image optimization using industry-standard tools (**oxipng**, **MozJPEG**, and **Gifsicle**). These scripts automate the process of finding the best compression parameters to reduce file size without compromising quality.

## 🛠 Prerequisites & Installation

**Important:** These scripts now require **PowerShell 7.0 or higher**. They utilize `ForEach-Object -Parallel` for high-performance concurrent processing.

To use these scripts, you must download the required binaries and place them in specific subdirectories within the script folder.

1. **MozJPEG:** [Download from GitHub](https://github.com/garyzyg/mozjpeg-windows/releases)
2. **oxipng:** [Download from GitHub](https://github.com/oxipng/oxipng/releases)
3. **Gifsicle:** [Download from eternallybored.org](https://eternallybored.org/misc/gifsicle/)

**Required Directory Structure:**

```text
/ProjectRoot
│   ├── mozjpeg/
│   │   ├── cjpeg-static.exe
│   │   └── jpegtran-static.exe
│   ├── oxipng/
│   │   └── oxipng.exe
│   ├── gifsicle/
│   │   ├── gifsicle.exe
│   │   └── gifdiff.exe
│   ├── jpg_opt.ps1
│   ├── png_opt.ps1
│   └── ... (other scripts)
```

## 🚀 Usage

Run the scripts via PowerShell 7 (`pwsh`). You can specify an output directory or omit it to optimize files in place (requires confirmation).

**Syntax:**

```powershell
.\<Script_Name.ps1> -InputPath "<Path>" [-OutputPath "<Path>"] [-j <Threads>] [-AsciiTempMode]
```

**Parameters:**

* `-InputPath`: The folder containing images to optimize (Recursive).
* `-OutputPath`: (Optional) Where to save optimized files. If omitted, it prompts to replace originals.
* `-j`: (Optional) Number of parallel threads. Defaults to the number of CPU cores.
* `-AsciiTempMode`: (Optional) A compatibility switch. If enabled, files are copied to a temporary directory with ASCII-only filenames before processing. Use this if the underlying tools (like MozJPEG) struggle with Unicode/Special characters in file paths.

**Example:**

```powershell
.\jpg_opt.ps1 "C:\Photos\Input" -j 4 -AsciiTempMode
```

## 📜 Script Descriptions

All scripts utilize parallel processing via `Core-Optimizer.ps1`.

| Script Name | Target | Description |
| --- | --- | --- |
| **`jpg_opt.ps1`** | JPG, PNG, BMP, etc. | **Brute-force.** Tests 21 MozJPEG parameter combinations per file and selects the smallest. Converts non-JPG inputs to JPG. |
| **`jpg_opt_losless.ps1`** | JPG | **Lossless.** Uses `jpegtran` to optimize Huffman tables and strip metadata. |
| **`png_opt.ps1`** | PNG, APNG | **Standard.** Uses `oxipng` with `max` optimization and safe metadata stripping. |
| **`png_opt_slow.ps1`** | PNG, APNG | **Max Compression.** Uses `oxipng` with the **Zopfli** algorithm. Much slower, but produces the smallest possible PNGs. |
| **`png_opt_not_safe.ps1`** | PNG, APNG | **Aggressive.** Removes all metadata/chunks and uses aggressive alpha handling. |
| **`png_opt_slow_not_safe.ps1`** | PNG, APNG | **Ultra Aggressive.** Combines Zopfli compression with "not safe" metadata/alpha stripping. |
| **`gif_opt_losless.ps1`** | GIF | **Lossless.** Uses `gifsicle` (O3) and verifies integrity using `gifdiff` to ensure frames remain identical. |

## ⚠️ Important Notes

* **PowerShell Version:** Legacy PowerShell 5.1 is no longer supported.
* **Backup:** Always backup your images before choosing to overwrite original files, especially when using `not_safe` variants.
* **Localization:** Scripts automatically detect system language (English/Russian) for console output.
* **Validation:** GIF optimization includes a validation step to ensure the optimized file is visually identical to the source.