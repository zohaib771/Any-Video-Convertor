# Any Video Convertor

Shrink big videos (Unity Recorder ProRes, screen captures, phone clips) into small MP4s that look the same: same colours, resolution, frame rate, length and audio. Works on **Windows, macOS and Linux**, and offline after the first run.

> Example: a 5.09 GB ProRes 4444 gameplay recording went down to **308 MB** (about 16× smaller). Its similarity score against the original is **0.995** (SSIM, where 1.0 means identical).

## Features

- **Easy to start**: double-click to pick videos in a file window, or drop files or a whole folder onto the tool.
- **Auto setup**: if ffmpeg is missing, the first run installs it for you.
- **Same colours**: 4:4:4 sources (ProRes 4444 / Unity Recorder) keep full 4:4:4 colour detail, and colour tags are copied from the source.
- **Smart output format**: ordinary 8-bit videos stay 4:2:0, so they still play everywhere.
- **Safe**: originals are never touched, existing outputs are never overwritten, and if a result would be bigger than its source it is deleted.
- **Cross-platform**: every platform uses the same encoding settings, so the output is identical.

## Quick start

| Platform | How to run |
|---|---|
| **Windows** | Double-click **`Compress Video.bat`**, or drag videos or a folder onto it |
| **macOS** | First time only: `chmod +x "Compress Video.command"` in Terminal. Then double-click **`Compress Video.command`** |
| **Linux** | `bash compress-video.sh` (opens a file picker if `zenity` or `kdialog` is installed), or `bash compress-video.sh <files or folders>` |

The output is saved next to each original as **`<name>_small.mp4`**.

## Setup (automatic)

On the first run the tool checks for ffmpeg and installs it if it is missing. This step needs internet once:

| Platform | What it runs |
|---|---|
| Windows | `winget install Gyan.FFmpeg` |
| macOS | `brew install ffmpeg` (needs [Homebrew](https://brew.sh)) |
| Linux | `apt-get`, `dnf`, `pacman` or `zypper install ffmpeg` (asks for your sudo password) |

**Fully offline setup:** put the `ffmpeg` and `ffprobe` binaries (`ffmpeg.exe` and `ffprobe.exe` on Windows) in a `bin/` folder next to the scripts. The tool uses those first.

> **Fedora:** the default `ffmpeg-free` package has no H.264 encoder. Enable [RPM Fusion](https://rpmfusion.org/Configuration), then run `sudo dnf swap ffmpeg-free ffmpeg --allowerasing`. The tool detects this case and tells you.

## Command line

```bash
# Windows (PowerShell)
.\compress-video.ps1 "D:\Recordings\Movie_004.mov"
.\compress-video.ps1 "D:\Recordings"            # every video in the folder
.\compress-video.ps1 -SelfTest                  # checks the format-selection logic

# macOS / Linux
bash compress-video.sh ~/Movies/Movie_004.mov
bash compress-video.sh ~/Movies                 # every video in the folder
bash compress-video.sh --self-test
```

The exit code is the number of files that failed (0 means all good).

## Encoding settings

| Setting | Value |
|---|---|
| Video codec | H.264 (libx264), `-preset slow -crf 12 -tune film` |
| Pixel format | 4:4:4 source → `yuv444p10le`, 10/12-bit source → `yuv420p10le`, otherwise `yuv420p` |
| Audio | AAC 320 kbps (skipped if the source has no audio) |
| Container | MP4 with `+faststart` |
| Colour | Primaries / transfer / matrix copied from the source |

Supported inputs: `.mov` `.mp4` `.mkv` `.avi` `.webm` `.m4v`

## Notes and limitations

- **4:4:4 output does not play everywhere.** VLC, Premiere, DaVinci and After Effects play it. Browsers, phones and ad-network uploaders often do not. For those platforms, re-export as 4:2:0 instead.
- **No transparency.** MP4 cannot store an alpha channel.
- **Small sources may be skipped.** An already-compressed video can come out larger than its source; the tool then keeps only the original.
- **Some file names break the `.bat`.** Names containing `&` or `%` may not pass through drag and drop on Windows; use the command line for those.
- **Existing outputs are skipped.** Delete the old `_small.mp4` to convert a file again.
- **macOS security warning.** If macOS blocks the `.command` file, right-click it, choose **Open**, then confirm once.

## Files

```
Any Video Convertor/
├── Compress Video.bat       # Windows: double-click or drag-and-drop
├── compress-video.ps1       # Windows converter
├── Compress Video.command   # macOS: double-click
├── compress-video.sh        # macOS / Linux converter
├── bin/                     # optional: ffmpeg + ffprobe for fully offline setup
└── README.md
```
