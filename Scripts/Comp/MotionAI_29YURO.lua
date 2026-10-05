-- Motion AI by 29YURO - DaVinci Resolve / Fusion v1.1
-- Native Fusion Lua script. Reference media is kept separate from content media.

local app = fusion
if not app then
    print("[MotionAI] Fusion scripting host not found.")
    return
end

local comp = app:GetCurrentComp()
if not comp then
    print("[MotionAI] Open a Fusion composition first.")
    return
end

local ui = app.UIManager
local disp = bmd.UIDispatcher(ui)

local win = disp:AddWindow(
    {ID="MotionAI29YURO", WindowTitle="Motion AI by 29YURO", Geometry={120,120,820,760}},
    ui:VGroup{
        ID="root", Spacing=8,
        ui:Label{Text="MOTION AI • DaVinci Resolve / Fusion"},
        ui:TextEdit{ID="prompt", PlaceholderText="Beschreibe die Animation ...", Weight=0.28},
        ui:HGroup{
            ui:Button{ID="addMedia", Text="+ QUELLMEDIUM"},
            ui:Button{ID="addRef", Text="+ REFERENZVIDEO"},
            ui:Button{ID="removeMedia", Text="LETZTES MEDIUM ENTFERNEN"},
            ui:Button{ID="clearRef", Text="REFERENZ ENTFERNEN"}
        },
        ui:Label{ID="mediaLabel", Text="Quellmedien: 0", WordWrap=true},
        ui:Label{ID="refLabel", Text="Referenz: —", WordWrap=true},
        ui:HGroup{
            ui:VGroup{
                ui:Label{Text="TEXT"},
                ui:LineEdit{ID="text", Text="29YURO"},
                ui:Label{Text="Schriftart"},
                ui:LineEdit{ID="font", Text="Arial"},
                ui:Label{Text="Schriftgröße"},
                ui:SpinBox{ID="size", Minimum=10, Maximum=500, Value=96}
            },
            ui:VGroup{
                ui:Label{Text="TEXT / MOTION ANIMATION"},
                ui:ComboBox{ID="anim"},
                ui:Label{Text="Start Frame"},
                ui:SpinBox{ID="start", Minimum=0, Maximum=100000, Value=0},
                ui:Label{Text="Dauer (Frames)"},
                ui:SpinBox{ID="duration", Minimum=1, Maximum=1000, Value=18}
            }
        },
        ui:HGroup{
            ui:Button{ID="generate", Text="AI GENERATE / VARIATION"},
            ui:Button{ID="preview", Text="PLAN VORSCHAU"},
            ui:Button{ID="reset", Text="RESET"}
        },
        ui:Tree{
            ID="plan", ColumnCount=5,
            HeaderLabels={"Layer","Start","Dauer","Animation","Quelle"},
            Weight=0.85
        },
        ui:HGroup{
            ui:Button{ID="edit", Text="AUSWAHL BEARBEITEN"},
            ui:Button{ID="create", Text="IN FUSION ERSTELLEN"}
        },
        ui:Label{
            ID="status",
            Text="Bereit. Referenzvideo dient nur als Stil-/Timing-Vorlage.",
            WordWrap=true
        }
    }
)

local itm = win:GetItems()
local anims = {
    "Fade In","Slide Up","Bounce","Typewriter","Word by Word",
    "3D Pop","3D Spin","3D Fly In","Blur In","Scale In",
    "Rotation","Shake","Wave","Elastic","Kinetic","Tracking","Smooth"
}
for _, a in ipairs(anims) do itm.anim:AddItem(a) end

local media = {}
local ref = nil
local plan = {}
local variation = 0

local function basename(p)
    return p and (p:match("([^/\\]+)$") or p) or ""
end

local function refreshLabels()
    local names = {}
    for _, p in ipairs(media) do names[#names+1] = basename(p) end
    itm.mediaLabel.Text = "Quellmedien: "..tostring(#media)..
        (#names > 0 and (" • "..table.concat(names, ", ")) or "")
    itm.refLabel.Text = "Referenz: "..(ref and basename(ref) or "—")
end

local function refreshPlan()
    itm.plan:Clear()
    for _, p in ipairs(plan) do
        local row = ui:TreeItem()
        row.Text[0] = p.name
        row.Text[1] = tostring(p.start)
        row.Text[2] = tostring(p.duration)
        row.Text[3] = p.anim
        row.Text[4] = basename(p.source or "")
        itm.plan:AddTopLevelItem(row)
    end
end

local function setAt(tool, inputName, frame, value)
    local input = tool and tool[inputName]
    if input == nil then return false end
    local ok = pcall(function() input[frame] = value end)
    return ok
end

local function connect(inputTool, sourceTool)
    if not inputTool or not sourceTool then return false end
    local ok = pcall(function() inputTool.Input = sourceTool.Output end)
    return ok
end

local function addTransformFor(source, name)
    local tr = comp:AddTool("Transform", -32768, -32768)
    if not tr then return nil end
    tr:SetAttrs({TOOLS_Name=name.."_Motion"})
    connect(tr, source)
    return tr
end

local function animateTransform(tr, p)
    local s = tonumber(p.start) or 0
    local e = s + math.max(1, tonumber(p.duration) or 18)
    local mid = math.floor((s + e) / 2)
    local a = p.anim or "Fade In"

    -- Use Transform inputs for motion so text and imported media share the same animation system.
    if a == "Fade In" or a == "Typewriter" or a == "Word by Word" or a == "Tracking" then
        setAt(tr, "Blend", s, 0)
        setAt(tr, "Blend", e, 1)
    elseif a == "Slide Up" then
        setAt(tr, "Center", s, {0.5, 0.36})
        setAt(tr, "Center", e, {0.5, 0.5})
        setAt(tr, "Blend", s, 0)
        setAt(tr, "Blend", math.min(e, s+5), 1)
    elseif a == "Scale In" or a == "3D Pop" then
        setAt(tr, "Size", s, 0.05)
        setAt(tr, "Size", e, 1.0)
        setAt(tr, "Blend", s, 0)
        setAt(tr, "Blend", math.min(e, s+4), 1)
    elseif a == "Rotation" or a == "3D Spin" then
        setAt(tr, "Angle", s, -55)
        setAt(tr, "Angle", e, 0)
        setAt(tr, "Size", s, 0.72)
        setAt(tr, "Size", e, 1.0)
    elseif a == "3D Fly In" then
        setAt(tr, "Center", s, {0.12, 0.5})
        setAt(tr, "Center", e, {0.5, 0.5})
        setAt(tr, "Size", s, 0.35)
        setAt(tr, "Size", e, 1.0)
        setAt(tr, "Angle", s, -18)
        setAt(tr, "Angle", e, 0)
    elseif a == "Bounce" or a == "Elastic" then
        setAt(tr, "Size", s, 0.05)
        setAt(tr, "Size", mid, 1.18)
        setAt(tr, "Size", e, 1.0)
    elseif a == "Shake" or a == "Kinetic" then
        setAt(tr, "Center", s, {0.46, 0.5})
        setAt(tr, "Center", math.min(e, s+3), {0.54, 0.49})
        setAt(tr, "Center", math.min(e, s+6), {0.48, 0.52})
        setAt(tr, "Center", e, {0.5, 0.5})
    elseif a == "Wave" then
        setAt(tr, "Angle", s, -8)
        setAt(tr, "Angle", mid, 8)
        setAt(tr, "Angle", e, 0)
    elseif a == "Blur In" then
        -- Transform handles the fade; a Blur node is added by createSourceChain.
        setAt(tr, "Blend", s, 0)
        setAt(tr, "Blend", e, 1)
        setAt(tr, "Size", s, 1.08)
        setAt(tr, "Size", e, 1.0)
    else
        setAt(tr, "Blend", s, 0)
        setAt(tr, "Blend", e, 1)
    end
end

local function createTextSource(p)
    local t = comp:AddTool("TextPlus", -32768, -32768)
    if not t then error("TextPlus konnte nicht erstellt werden.") end
    t:SetAttrs({TOOLS_Name=p.name})
    pcall(function() t.StyledText = itm.text.Text end)
    pcall(function() t.Font = itm.font.Text end)
    pcall(function() t.Size = math.max(0.01, tonumber(itm.size.Value)/1000) end)
    return t
end

local function createMediaSource(p)
    local l = comp:AddTool("Loader", -32768, -32768)
    if not l then error("Loader konnte nicht erstellt werden.") end
    l:SetAttrs({TOOLS_Name=p.name})
    local ok = pcall(function() l.Clip[0] = p.source end)
    if not ok then
        ok = pcall(function() l.Clip = p.source end)
    end
    if not ok then error("Medium konnte nicht in Loader geladen werden: "..tostring(p.source)) end
    return l
end

local function createSourceChain(p)
    local src = p.source and createMediaSource(p) or createTextSource(p)
    local tr = addTransformFor(src, p.name)
    if not tr then error("Transform-Node konnte nicht erstellt werden.") end
    animateTransform(tr, p)

    if p.anim == "Blur In" then
        local blur = comp:AddTool("Blur", -32768, -32768)
        if blur then
            blur:SetAttrs({TOOLS_Name=p.name.."_Blur"})
            connect(blur, tr)
            setAt(blur, "XBlurSize", p.start, 12)
            setAt(blur, "YBlurSize", p.start, 12)
            setAt(blur, "XBlurSize", p.start+p.duration, 0)
            setAt(blur, "YBlurSize", p.start+p.duration, 0)
        end
    end
    return tr
end

local function selectedPlanIndex()
    local ok, rows = pcall(function() return itm.plan.SelectedItems end)
    if not ok or not rows or #rows == 0 then return nil end
    local target = rows[1]
    for i=0, itm.plan.TopLevelItemCount-1 do
        local row = itm.plan:TopLevelItem(i)
        if row == target then return i+1 end
    end
    return nil
end

function win.On.addMedia.Clicked(ev)
    local p = app:RequestFile("", "*.*", {FReqS_Title="Quellmedium auswählen"})
    if p and p ~= "" then media[#media+1] = p; refreshLabels() end
end

function win.On.addRef.Clicked(ev)
    local p = app:RequestFile("", "*.*", {FReqS_Title="Referenzvideo auswählen"})
    if p and p ~= "" then ref = p; refreshLabels() end
end

function win.On.removeMedia.Clicked(ev)
    if #media > 0 then table.remove(media, #media) end
    refreshLabels()
end

function win.On.clearRef.Clicked(ev)
    ref = nil
    refreshLabels()
end

function win.On.reset.Clicked(ev)
    media = {}; ref = nil; plan = {}; variation = 0
    refreshLabels(); refreshPlan()
    itm.status.Text = "Zurückgesetzt."
end

function win.On.generate.Clicked(ev)
    variation = variation + 1
    plan = {}
    local base = tonumber(itm.start.Value) or 0
    local dur = tonumber(itm.duration.Value) or 18
    local selectedAnim = itm.anim.CurrentText
    if not selectedAnim or selectedAnim == "" then selectedAnim = "Fade In" end

    if itm.text.Text and itm.text.Text ~= "" then
        plan[#plan+1] = {
            name="Text "..variation, start=base, duration=dur,
            anim=selectedAnim, source=nil
        }
    end

    for i, path in ipairs(media) do
        local animIndex = ((i + variation - 2) % #anims) + 1
        plan[#plan+1] = {
            name="Media "..i,
            start=base + (i-1)*math.max(4, math.floor(dur*0.55)),
            duration=dur,
            anim=anims[animIndex],
            source=path
        }
    end

    refreshPlan()
    itm.status.Text = "Motion-Plan Variante "..variation..
        " erstellt. Referenz bleibt nur Vorlage und wird nicht importiert."
end

function win.On.preview.Clicked(ev)
    refreshPlan()
    itm.status.Text = "Plan aktualisiert. Bearbeite Start, Dauer und Animation vor dem Erstellen."
end

function win.On.edit.Clicked(ev)
    local idx = selectedPlanIndex()
    if not idx or not plan[idx] then
        itm.status.Text = "Wähle zuerst einen Eintrag im Plan aus."
        return
    end
    plan[idx].start = tonumber(itm.start.Value) or plan[idx].start
    plan[idx].duration = tonumber(itm.duration.Value) or plan[idx].duration
    local a = itm.anim.CurrentText
    if a and a ~= "" then plan[idx].anim = a end
    refreshPlan()
    itm.status.Text = "Ausgewählter Plan-Eintrag aktualisiert."
end

function win.On.create.Clicked(ev)
    if #plan == 0 then
        itm.status.Text = "Erst AI GENERATE / VARIATION drücken."
        return
    end

    comp:StartUndo("Motion AI by 29YURO")
    comp:Lock()
    local ok, err = pcall(function()
        for _, p in ipairs(plan) do createSourceChain(p) end
    end)
    comp:Unlock()
    comp:EndUndo(ok)

    if ok then
        itm.status.Text = "In Fusion erstellt. Loader/TextPlus + Transform-Nodes bleiben editierbar."
    else
        itm.status.Text = "Fehler: "..tostring(err)
    end
end

function win.On.MotionAI29YURO.Close(ev)
    disp:ExitLoop()
end

refreshLabels()
refreshPlan()
win:Show()
disp:RunLoop()
win:Hide()
