# Motion AI by 29YURO — DaVinci Resolve / Fusion

GitHub-ready Windows package for the native Fusion Lua script.

## GitHub build / download
1. Upload the complete contents of this repository to GitHub.
2. Open **Actions**.
3. Run/open **Build MotionAI DaVinci**.
4. When the run is green, download the artifact **MotionAI-DaVinci-29YURO-Windows**.
5. Extract the downloaded artifact ZIP, then extract/open the contained install ZIP if necessary.
6. Run `install_windows.bat` and restart DaVinci Resolve.

## Manual install
Copy `Scripts/Comp/MotionAI_29YURO.lua` to:

`%APPDATA%\Blackmagic Design\DaVinci Resolve\Support\Fusion\Scripts\Comp\`

Then restart Resolve, open a Fusion composition and launch the script from the Fusion scripts menu.

## Included features
- Multiple source media files
- Separate removable reference video
- Text, font and font-size controls
- Editable animation plan before creation
- Fade In, Slide Up, Bounce, Typewriter, Word by Word, 3D Pop, 3D Spin, 3D Fly In, Blur In, Scale In, Rotation, Shake, Wave, Elastic, Kinetic, Tracking and Smooth presets
- Fusion TextPlus / Loader / Transform creation with editable keyframes

## Important limitation
This repository currently provides a **native Fusion Lua tool**, not a compiled OFX plugin or `.drfx` package. The reference video is kept separate as a style/timing reference. Real multimodal AI analysis of uploaded images/video/audio requires an additional local or remote AI backend; this script alone does not infer frames from the reference video.
