# powershell-img-optimization-script
Using oxipng and mozjpeg

Place oxipng.exe in oxipng dir, cjpeg-static.exe, jpegtran-static.exe in mozjpeg dir and gifdiff.exe, gifsicle.exe in gifsicle dir

Download exe from https://github.com/garyzyg/mozjpeg-windows/releases https://github.com/oxipng/oxipng/releases and https://eternallybored.org/misc/gifsicle/

Using

```.\<script name> "<input path>" "<output path>"```

or

```.\<script name> "<input path>"```

jpg_opt.ps1 test 21 parameter combinations and select best

jpg_opt_losless.ps1 use jpegtran to losless jpg optimization

png_opt.ps1 oxipng optimization

png_opt_slow.ps1 oxipng optimization with Zopfli(x100 slower, 2-8% better)

gif_opt_losless.ps1 gifsicle with -O3 -j<core> and result check with gifdiff

png_opt.ps1 and png_opt_slow.ps1 always multithreaded since multithreading is built into oxipng

jpg_opt.ps1 and jpg_opt_losless.ps1 multithread if ps version 7+
