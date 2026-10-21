@echo off
rem Double-click to pick videos, or drag videos/folders onto this file. Writes <name>_small.mp4 next to each one. Works offline.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0compress-video.ps1" %*
pause
