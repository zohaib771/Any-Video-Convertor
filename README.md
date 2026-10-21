<div align="center">

# 🎬 Any Video Convertor

**Shrink huge videos into small MP4s that look the same.**<br>
Same colours · same resolution · same frame rate · same length · same audio

![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)
![macOS](https://img.shields.io/badge/macOS-000000?style=for-the-badge&logo=apple&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![FFmpeg](https://img.shields.io/badge/Powered%20by-FFmpeg-007808?style=for-the-badge&logo=ffmpeg&logoColor=white)

[Quick start](#-quick-start) · [Features](#-features) · [Command line](#-command-line) · [Encoding settings](#-encoding-settings) · [Notes](#-notes-and-limitations)

</div>

---

## 📉 Real result

| | Original | Compressed |
|---|:---:|:---:|
| **Format** | ProRes 4444 (Unity Recorder) | H.264 MP4, 4:4:4 |
| **Size** | 5.09 GB | **308 MB** |
| **Reduction** | — | **about 16× smaller** 🔥 |
| **Similarity (SSIM)** | 1.0 | **0.995** |

> SSIM measures how alike two videos look; 1.0 means identical.

Made for Unity Recorder ProRes, screen captures and phone clips. Works offline after the first run.

## ✨ Features

| | |
|---|---|
| 🖱️ **Easy to start** | Double-click to pick videos in a file window, or drop files or a whole folder onto the tool |
| ⚙️ **Auto setup** | If ffmpeg is missing, the first run installs it for you |
| 🎨 **Same colours** | 4:4:4 sources (ProRes 4444 / Unity Recorder) keep full 4:4:4 colour detail, and colour tags are copied from the source |
| 🧠 **Smart output format** | Ordinary 8-bit videos stay 4:2:0, so they still play everywhere |
| 🛡️ **Safe** | Originals are never touched, existing outputs are never overwritten, and a result bigger than its source is deleted |
| 🌍 **Cross-platform** | Every platform uses the same encoding settings, so the output is identical |

## 🚀 Quick start

```bash
git clone https://github.com/zohaibhassan-Mindstrom/Any-Video-Convertor.git
```

| Platform | How to run |
|---|---|
| 🪟 **Windows** | Double-click **`Compress Video.bat`**, or drag videos or a folder onto it |
| 🍎 **macOS** | Double-click **`Compress Video.command`** |
| 🐧 **Linux** | `bash compress-video.sh` (opens a file picker if `zenity` or `kdialog` is installed), or `bash compress-video.sh <files or folders>` |

The output is saved next to each original as **`<name>_small.mp4`** ✅

> [!TIP]
> Downloaded the ZIP instead of cloning on macOS? Run `chmod +x "Compress Video.command"` in Terminal once, so the file can be double-clicked.

## 📦 Setup (automatic)

On the first run the tool checks for ffmpeg and installs it if it is missing. This step needs internet once:

| Platform | What it runs |
|---|---|
| Windows | `winget install Gyan.FFmpeg` |
| macOS | `brew install ffmpeg` (needs [Homebrew](https://brew.sh)) |
| Linux | `apt-get`, `dnf`, `pacman` or `zypper install ffmpeg` (asks for your sudo password) |

> [!NOTE]
> **Fully offline setup:** put the `ffmpeg` and `ffprobe` binaries (`ffmpeg.exe` and `ffprobe.exe` on Windows) in a `bin/` folder next to the scripts. The tool uses those first.

> [!WARNING]
> **Fedora:** the default `ffmpeg-free` package has no H.264 encoder. Enable [RPM Fusion](https://rpmfusion.org/Configuration), then run `sudo dnf swap ffmpeg-free ffmpeg --allowerasing`. The tool detects this case and tells you.

## 💻 Command line

<details open>
<summary><b>🪟 Windows (PowerShell)</b></summary>

```powershell
.\compress-video.ps1 "D:\Recordings\Movie_004.mov"
.\compress-video.ps1 "D:\Recordings"            # every video in the folder
.\compress-video.ps1 -SelfTest                  # checks the format-selection logic
```

</details>

<details open>
<summary><b>🍎 macOS / 🐧 Linux</b></summary>

```bash
bash compress-video.sh ~/Movies/Movie_004.mov
bash compress-video.sh ~/Movies                 # every video in the folder
bash compress-video.sh --self-test              # checks the format-selection logic
```

</details>

The exit code is the number of files that failed (`0` means all good).

## 🔧 Encoding settings

| Setting | Value |
|---|---|
| 🎥 Video codec | H.264 (libx264), `-preset slow -crf 12 -tune film` |
| 🌈 Pixel format | 4:4:4 source → `yuv444p10le` · 10/12-bit source → `yuv420p10le` · otherwise `yuv420p` |
| 🔊 Audio | AAC 320 kbps (skipped if the source has no audio) |
| 📦 Container | MP4 with `+faststart` |
| 🎨 Colour | Primaries / transfer / matrix copied from the source |

**Supported inputs:** `.mov` `.mp4` `.mkv` `.avi` `.webm` `.m4v`

## 📝 Notes and limitations

> [!IMPORTANT]
> **4:4:4 output does not play everywhere.** VLC, Premiere, DaVinci and After Effects play it. Browsers, phones and ad-network uploaders often do not. For those platforms, re-export as 4:2:0 instead.

- 🚫 **No transparency.** MP4 cannot store an alpha channel.
- ⏭️ **Small sources may be skipped.** An already-compressed video can come out larger than its source; the tool then keeps only the original.
- ⚠️ **Some file names break the `.bat`.** Names containing `&` or `%` may not pass through drag and drop on Windows; use the command line for those.
- 🔁 **Existing outputs are skipped.** Delete the old `_small.mp4` to convert a file again.
- 🔒 **macOS security warning.** If macOS blocks the `.command` file, right-click it, choose **Open**, then confirm once.

## 📁 Files

```
Any-Video-Convertor/
├── Compress Video.bat       # Windows: double-click or drag-and-drop
├── compress-video.ps1       # Windows converter
├── Compress Video.command   # macOS: double-click
├── compress-video.sh        # macOS / Linux converter
├── bin/                     # optional: ffmpeg + ffprobe for fully offline setup
└── README.md
```

---

<div align="center">

Made with ❤️ and [FFmpeg](https://ffmpeg.org)

</div>
