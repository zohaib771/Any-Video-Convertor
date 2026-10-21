# Offline video shrinker: same settings as Movie_004_master.mp4 (x264 CRF 12 slow, AAC 320k, colour tags kept).
# Keeps 4:4:4 colour when the source has it (Unity Recorder ProRes), so colours match the original in any player.
# Usage: double-click "Compress Video.bat" to pick files, drag videos/folders onto it, or: compress-video.ps1 <file|folder>...
# -SelfTest checks the format-selection logic.
param([switch]$SelfTest, [Parameter(ValueFromRemainingArguments = $true)][string[]]$Paths)

$ErrorActionPreference = "Stop"
$VideoExt = ".mov", ".mp4", ".mkv", ".avi", ".webm", ".m4v"

function Get-TargetPixFmt([string]$sourcePixFmt) {
    if ($sourcePixFmt -match "444") { return "yuv444p10le" }   # full colour detail (ProRes 4444 etc.)
    if ($sourcePixFmt -match "p1[0-6]") { return "yuv420p10le" } # keep 10/12-bit depth
    return "yuv420p"                                            # ordinary 8-bit video stays playable everywhere
}

if ($SelfTest) {
    $cases = @{ "yuv444p12le" = "yuv444p10le"; "yuva444p12le" = "yuv444p10le"; "yuv420p10le" = "yuv420p10le"; "yuv422p10le" = "yuv420p10le"; "yuv420p" = "yuv420p"; "yuvj420p" = "yuv420p" }
    foreach ($k in $cases.Keys) { if ((Get-TargetPixFmt $k) -ne $cases[$k]) { throw "SelfTest failed: $k -> $(Get-TargetPixFmt $k), expected $($cases[$k])" } }
    Write-Host "SelfTest passed"; exit 0
}

function Test-FFmpeg {
    $bin = Join-Path $PSScriptRoot "bin"   # fully offline option: drop ffmpeg.exe + ffprobe.exe here
    if (Test-Path (Join-Path $bin "ffmpeg.exe")) { $env:Path = "$bin;$env:Path" }
    return (Get-Command ffmpeg -ErrorAction SilentlyContinue) -and (Get-Command ffprobe -ErrorAction SilentlyContinue)
}
if (-not (Test-FFmpeg)) {
    Write-Host "ffmpeg is missing - installing it now (one time, needs internet)..." -ForegroundColor Yellow
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "winget not found. Download ffmpeg from https://www.gyan.dev/ffmpeg/builds/ and put ffmpeg.exe + ffprobe.exe in: $PSScriptRoot\bin" -ForegroundColor Red; exit 1
    }
    & winget install --id Gyan.FFmpeg -e --accept-source-agreements --accept-package-agreements
    $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")
    if (-not (Test-FFmpeg)) { Write-Host "ffmpeg was installed but this window can't see it yet - close it and run the tool again." -ForegroundColor Red; exit 1 }
}
if (-not ((& ffmpeg -hide_banner -encoders) -match "libx264")) { Write-Host "This ffmpeg has no H.264 encoder (libx264). Install the full build: winget install Gyan.FFmpeg" -ForegroundColor Red; exit 1 }
if (-not $Paths) {   # double-clicked: let the user pick files
    Add-Type -AssemblyName System.Windows.Forms
    $dlg = New-Object System.Windows.Forms.OpenFileDialog -Property @{
        Title = "Select videos to compress"; Multiselect = $true
        Filter = "Videos|" + (($VideoExt | ForEach-Object { "*$_" }) -join ";") + "|All files|*.*"
    }
    if ($dlg.ShowDialog() -ne "OK") { Write-Host "No video selected."; exit 0 }
    $Paths = $dlg.FileNames
}

$files = foreach ($p in $Paths) {
    if (Test-Path -LiteralPath $p -PathType Container) { Get-ChildItem -LiteralPath $p -File | Where-Object { $VideoExt -contains $_.Extension.ToLower() } }
    elseif (Test-Path -LiteralPath $p) { Get-Item -LiteralPath $p }
    else { Write-Host "Not found: $p" -ForegroundColor Yellow }
}

$failed = 0
foreach ($f in $files) {
    if ($f.BaseName -like "*_small") { continue }   # don't re-compress our own output when a folder is dropped
    $out = Join-Path $f.DirectoryName ($f.BaseName + "_small.mp4")
    if (Test-Path -LiteralPath $out) { Write-Host "Skip (already exists): $out" -ForegroundColor Yellow; continue }

    $pix = Get-TargetPixFmt (& ffprobe -v error -select_streams v:0 -show_entries stream=pix_fmt -of csv=p=0 $f.FullName)
    Write-Host "`n$($f.Name)  ($([math]::Round($f.Length / 1MB)) MB, $pix)" -ForegroundColor Cyan
    & ffmpeg -hide_banner -loglevel error -stats -n -i $f.FullName -map 0:v:0 -map 0:a? -c:v libx264 -preset slow -crf 12 -pix_fmt $pix -tune film -c:a aac -b:a 320k -movflags +faststart $out
    if ($LASTEXITCODE -ne 0) { Write-Host "FAILED: $($f.Name)" -ForegroundColor Red; Remove-Item -LiteralPath $out -ErrorAction SilentlyContinue; $failed++; continue }

    $newSize = (Get-Item -LiteralPath $out).Length
    if ($newSize -ge $f.Length) { Remove-Item -LiteralPath $out; Write-Host "Source is already smaller than the result - kept the original only." -ForegroundColor Yellow; continue }
    Write-Host ("Done: {0}  {1} MB -> {2} MB ({3}x smaller)" -f (Split-Path $out -Leaf), [math]::Round($f.Length / 1MB), [math]::Round($newSize / 1MB), [math]::Round($f.Length / $newSize, 1)) -ForegroundColor Green
}
exit $failed
