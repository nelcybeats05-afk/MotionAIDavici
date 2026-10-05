# Motion AI by 29YURO — DaVinci Resolve / Fusion v1.1 FIXED

GitHub-ready Fusion Lua script.

## Fixes in v1.1
- Correct Fusion keyframing through input[frame] assignments instead of changing CurrentTime and assigning plain values.
- Text and imported media now receive a Transform node so motion presets can animate both.
- Fade In uses the Transform Blend control.
- Added removal for the last source medium and a separate remove-reference button.
- Reference video remains separate and is never inserted as content.
- Loader path assignment has a compatibility fallback.
- Safer error handling, Undo and composition locking.
- Plan selection/edit logic no longer relies on IndexOfTopLevelItem.
- Blur In can add a Blur node.
- Font and font size remain available.
- Existing animation list retained.

## Install
Copy `Scripts/Comp/MotionAI_29YURO.lua` into the Fusion Comp scripts folder used by your DaVinci Resolve installation, then restart Resolve.

## Important
The local script creates and edits Fusion nodes and keyframes. It does **not** perform real multimodal AI analysis of a reference video by itself. Real frame understanding requires an external/local AI backend that receives actual video frames.
