--[[
    Hooked! - 上钩了！全功能脚本 v1.0
    WindUI 模板 + ESP + 自动瞄准 + 加速 + 飞行 + 自动拾取
--]]

print("[上钩了] v1.0 加载中...")

local P = game:GetService("Players")
local WS = game:GetService("Workspace")
local RS = game:GetService("ReplicatedStorage")
local C = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local LP = P.LocalPlayer
if not LP then return end
print("[上钩了] 玩家: " .. LP.Name)

for _, g in ipairs(C:GetChildren()) do
    if g:IsA("ScreenGui") then
        if g.Name == "A" or g.Name:find("Hooked") or g.Name == "WindUI" then
            pcall(function() g:Destroy() end)
        end
    end
end

local WI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WI then print("[上钩了] WindUI 失败"); return end
print("[上钩了] WindUI OK")

local TEV, TEvent = pcall(function() return require(RS.Shared.Core.TEvent) end)
local HookFire, HookHit, HookRelease
if TEV and TEvent and TEvent.Remote then
    pcall(function() HookFire = TEvent.Remote.new("HookFire") end)
    pcall(function() HookHit = TEvent.Remote.new("HookHit") end)
    pcall(function() HookRelease = TEvent.Remote.new("HookRelease") end)
end
print("[上钩了] HookFire=" .. tostring(HookFire and "OK" or "NIL"))

local function getNearestEnemy(range)
    local c = LP.Character; local hrp = c and c:FindFirstChild("HumanoidRootPart")
    local pos = hrp and hrp.Position; if not pos then return nil end
    local nearest, nearDist = nil, range
    for _, plr in ipairs(P:GetPlayers()) do
        if plr ~= LP then
            local pc = plr.Character; local ph = pc and pc:FindFirstChild("HumanoidRootPart")
            if ph then local d = (ph.Position - pos).Magnitude; if d < nearDist then nearDist = d; nearest = {Player=plr,HRP=ph,Dist=d} end end
        end
    end
    return nearest
end

local function doAim()
    if not S.AutoAim then return end
    local t = getNearestEnemy(200); if not t then return end
    local cam = WS.CurrentCamera; if not cam then return end
    if not S.SilentAim then cam.CFrame = CFrame.lookAt(cam.CFrame.Position, t.HRP.Position) end
end

local function doSpeed()
    local c = LP.Character; local h = c and c:FindFirstChildOfClass("Humanoid")
    if h then if S.Speed then h.WalkSpeed = S.SpeedVal else h.WalkSpeed = 16 end end
end

local function startFly()
    if flying then return end
    local c = LP.Character; if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local h = c:FindFirstChildOfClass("Humanoid"); if h then h.PlatformStand = true end
    flyBV = Instance.new("BodyVelocity"); flyBV.MaxForce = Vector3.new(9e9,9e9,9e9); flyBV.Velocity = Vector3.new(0,0,0); flyBV.P = 1250; flyBV.Parent = hrp
    flyBG = Instance.new("BodyGyro"); flyBG.MaxTorque = Vector3.new(9e9,9e9,9e9); flyBG.P = 1250; flyBG.D = 500; flyBG.CFrame = hrp.CFrame; flyBG.Parent = hrp
    flying = true
    spawn(function()
        while flying and flyBV and flyBV.Parent do
            local c2 = LP.Character; if c2 then
                local h2 = c2:FindFirstChildOfClass("Humanoid"); if h2 then h2.PlatformStand = true end
                local hrp2 = c2:FindFirstChild("HumanoidRootPart"); local cam = WS.CurrentCamera
                if hrp2 and cam then
                    local d = cam.CFrame.LookVector; local r = cam.CFrame.RightVector; local u = cam.CFrame.UpVector
                    local mv = Vector3.new(0,0,0)
                    if UIS:IsKeyDown(Enum.KeyCode.W) then mv = mv + d end; if UIS:IsKeyDown(Enum.KeyCode.S) then mv = mv - d end
                    if UIS:IsKeyDown(Enum.KeyCode.A) then mv = mv - r end; if UIS:IsKeyDown(Enum.KeyCode.D) then mv = mv + r end
                    if UIS:IsKeyDown(Enum.KeyCode.Space) then mv = mv + u end; if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then mv = mv - u end
                    if mv.Magnitude > 0 then mv = mv.Unit * S.FlySpeed end
                    flyBV.Velocity = mv; pcall(function() flyBG.CFrame = cam.CFrame end)
                end
            end
            wait(0.03)
        end
    end)
end
local function stopFly()
    flying = false; if flyBV then pcall(function() flyBV:Destroy() end); flyBV = nil end
    if flyBG then pcall(function() flyBG:Destroy() end); flyBG = nil end
end

local function clearESP()
    for _, d in pairs(espDrawings) do for _, o in pairs(d) do pcall(function() o.Visible = false; o:Remove() end) end end
    espDrawings = {}
end
local function updateESP()
    if not S.EspEnabled then clearESP(); return end
    local c = LP.Character; local hrp = c and c:FindFirstChild("HumanoidRootPart"); local pos = hrp and hrp.Position; if not pos then return end
    local seen = {}
    for _, plr in ipairs(P:GetPlayers()) do if plr ~= LP then
        local pc = plr.Character; local ph = pc and pc:FindFirstChild("HumanoidRootPart")
        if ph then local d = (ph.Position - pos).Magnitude
            if d <= S.EspRange then
                local k = plr.Name
                if not espDrawings[k] then
                    espDrawings[k] = {Box=Drawing.new("Square"),Name=Drawing.new("Text"),Dist=Drawing.new("Text"),Line=Drawing.new("Line")}
                    for _, o in pairs(espDrawings[k]) do o.Visible = false; o.Center = true; o.Outline = true end
                    espDrawings[k].Name.Size = 16; espDrawings[k].Dist.Size = 14; espDrawings[k].Box.Thickness = 1; espDrawings[k].Line.Thickness = 1
                end
                local e = espDrawings[k]; local ss, on = WS.CurrentCamera:WorldToViewportPoint(ph.Position)
                if on then
                    local sz = math.clamp(500/d, 20, 120); local col = Color3.fromRGB(255,80,80); local vs = WS.CurrentCamera.ViewportSize
                    e.Box.Color = col; e.Name.Color = col; e.Dist.Color = col; e.Line.Color = col
                    e.Box.Size = Vector2.new(sz, sz*1.5); e.Box.Position = Vector2.new(ss.X-sz/2, ss.Y-sz*1.5/2); e.Box.Visible = true
                    e.Name.Position = Vector2.new(ss.X, ss.Y-sz*1.5/2-14); e.Name.Text = plr.Name; e.Name.Visible = true
                    e.Dist.Position = Vector2.new(ss.X, ss.Y+sz*1.5/2+2); e.Dist.Text = math.floor(d).."m"; e.Dist.Visible = true
                    e.Line.From = Vector2.new(vs.X/2, vs.Y); e.Line.To = Vector2.new(ss.X, ss.Y); e.Line.Visible = true
                    seen[k] = true
                end
            end
        end
    end end
    for k, e in pairs(espDrawings) do if not seen[k] then for _, o in pairs(e) do pcall(function() o.Visible = false end) end end end
end

local function doHeal()
    if not S.AutoHeal then return end
    local gs = WS:FindFirstChild("GameSystem"); local hd = gs and gs:FindFirstChild("HealDrops"); if not hd then return end
    local c = LP.Character; local hrp = c and c:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    for _, d in ipairs(hd:GetChildren()) do if d:IsA("Part") or d:IsA("Model") then
        local dp = d:IsA("Part") and d or d:FindFirstChildWhichIsA("BasePart",true)
        if dp and (dp.Position-hrp.Position).Magnitude < 30 then
            hrp.CFrame = dp.CFrame * CFrame.new(0,0,2); wait(0.2)
            pcall(function() RS:FindFirstChild("Remote_Event"):FireServer(d) end); print("[拾取] "..d.Name); break
        end
    end end
end

-- particles
local function sP()
    if PR then return end
    if PC then pcall(function() local p=PC.Parent; if p then p:Destroy() end end); PC = nil end; PS = {}; wait(0.3)
    local sg = Instance.new("ScreenGui"); sg.Name = "HP"; sg.ResetOnSpawn = false; sg.DisplayOrder = 999999; sg.IgnoreGuiInset = true; sg.Parent = C
    PC = Instance.new("Frame"); PC.Size = UDim2.new(1,0,1,0); PC.BackgroundTransparency = 1; PC.BorderSizePixel = 0; PC.Parent = sg
    for i = 1, 50 do
        local d = Instance.new("Frame"); local sz = math.random(5,10)
        d.Size = UDim2.new(0,sz,0,sz); d.Position = UDim2.new(0.2+math.random()*0.6,0,0.2+math.random()*0.6,0)
        d.BackgroundColor3 = S.ParticleColor; d.BackgroundTransparency = 0.3+math.random()*0.5; d.BorderSizePixel = 0; d.Parent = PC
        Instance.new("UICorner",d).CornerRadius = UDim.new(0,10)
        local a = math.random()*6.28; local sp = 0.0008+math.random()*0.002
        table.insert(PS,{F=d,Sx=d.Position.X.Scale,Sy=d.Position.Y.Scale,Vx=math.cos(a)*sp,Vy=math.sin(a)*sp,Ph=math.random()*6.28,Sz=sz})
    end
    PR = true; spawn(function() local t=0; while PR and PC do t=t+0.03
        pcall(function() local c=S.ParticleColor; for _,p in ipairs(PS) do if p.F and p.F.Parent then
            local sx=math.max(0.05,math.min(0.95,p.Sx+p.Vx)); local sy=math.max(0.05,math.min(0.95,p.Sy+p.Vy))
            if sx>=0.95 or sx<=0.05 then p.Vx=-p.Vx end; if sy>=0.95 or sy<=0.05 then p.Vy=-p.Vy end
            p.Sx=sx; p.Sy=sy; p.F.Position=UDim2.new(sx,0,sy,0); p.F.BackgroundColor3=c
            p.F.BackgroundTransparency=0.3+math.sin(t*0.8+p.Ph)*0.4
            p.F.Size=UDim2.new(0,math.max(2,p.Sz+math.sin(t+p.Ph)*1.5),0,math.max(2,p.Sz+math.sin(t+p.Ph)*1.5))
    end end end) wait(0.03) end end)
end
local function xP() PR=false; if PC then pcall(function() local p=PC.Parent; if p then p:Destroy() end end); PC=nil end; PS={} end

local tc_t={Dark=Color3.fromRGB(80,170,255),Light=Color3.fromRGB(60,130,210),Rose=Color3.fromRGB(255,130,170),Plant=Color3.fromRGB(70,210,130),Ocean=Color3.fromRGB(60,190,240),Sunset=Color3.fromRGB(255,160,70),Midnight=Color3.fromRGB(130,100,240),Forest=Color3.fromRGB(60,180,90),Lavender=Color3.fromRGB(190,140,255),Coral=Color3.fromRGB(255,140,90),Mint=Color3.fromRGB(80,230,190),Sky=Color3.fromRGB(100,190,255),Blood=Color3.fromRGB(230,90,80),Lemon=Color3.fromRGB(230,210,70),Cyber=Color3.fromRGB(0,235,210)}
local function tc(n) return tc_t[n] or Color3.fromRGB(80,170,255) end

-- settings & variables
local S = {AutoAim=false,SilentAim=false,EspEnabled=false,Speed=false,SpeedVal=40,Fly=false,FlySpeed=50,AutoHeal=false,EspRange=300,Particles=true,Acrylic=true,Transparent=false,ParticleColor=Color3.fromRGB(80,170,255)}
local KB = {Toggle="RightShift"}; local WN,CT = {},{}
local PR,PS,PC = false,{},nil; local flying = false; local flyBV,flyBG = nil,nil; local espDrawings = {}; local last = 0

-- UI
local function mW()
    WN = WI:CreateWindow({Title="Hooked Script",Author="b站英吉利超入_",Icon="solar:code-bold",Size=UDim2.fromOffset(750,560),ToggleKey=Enum.KeyCode.RightShift,Folder="hooked-script",Acrylic=true,Resizable=false,ScrollBarEnabled=true,HideSearchBar=true,
        OnClose=function() xP();stopFly();for _,ct in pairs(CT) do if ct and type(ct.Set)=="function" then pcall(function() ct:Set(false) end) end end end,
        OnOpen=function() if S.Particles then sP() end end})
    spawn(function() wait(0.8) pcall(function() if WN and WN.Parent then WN.Parent.ClipsDescendants=true end end) end)
    local t1=WN:Tab({Title="Main",Icon="solar:slider-vertical-bold"})
    CT.AutoAim=t1:Toggle({Flag="AutoAim",Title="Auto Aim",Value=false,Callback=function(v)S.AutoAim=v end})
    CT.SilentAim=t1:Toggle({Flag="SilentAim",Title="Silent Aim",Value=false,Callback=function(v)S.SilentAim=v end})
    t1:Divider()
    CT.Speed=t1:Toggle({Flag="Speed",Title="Speed",Value=false,Callback=function(v)S.Speed=v;if not v then local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid");if h then h.WalkSpeed=16 end end end})
    CT.SpeedVal=t1:Slider({Flag="SpeedVal",Title="Speed Value",Step=5,Value={Min=10,Max=200,Default=40},Width=200,IsTextbox=true,Callback=function(v)S.SpeedVal=v;if S.Speed then doSpeed()end end})
    t1:Divider()
    CT.Fly=t1:Toggle({Flag="Fly",Title="Fly",Value=false,Callback=function(v)S.Fly=v;if v then startFly()else stopFly()end end})
    CT.FlySpeed=t1:Slider({Flag="FlySpeed",Title="Fly Speed",Step=5,Value={Min=10,Max=150,Default=50},Width=200,IsTextbox=true,Callback=function(v)S.FlySpeed=v end})
    t1:Divider()
    CT.AutoHeal=t1:Toggle({Flag="AutoHeal",Title="Auto Heal Pickup",Value=false,Callback=function(v)S.AutoHeal=v end})
    local t2=WN:Tab({Title="ESP",Icon="solar:eye-bold"})
    CT.Esp=t2:Toggle({Flag="Esp",Title="Player ESP",Value=false,Callback=function(v)S.EspEnabled=v;if not v then clearESP()end end})
    CT.EspRange=t2:Slider({Flag="EspRange",Title="ESP Range",Step=25,Value={Min=50,Max=500,Default=300},Width=200,IsTextbox=true,Callback=function(v)S.EspRange=v end})
    local t3=WN:Tab({Title="Keys",Icon="solar:settings-bold"})
    t3:Keybind({Flag="ToggleKey",Title="Toggle Window",Value="RightShift",Callback=function(v)KB.Toggle=v;pcall(function() WN:SetToggleKey(v)end)end})
    local t4=WN:Tab({Title="UI",Icon="solar:monitor-bold"})
    CT.Particles=t4:Toggle({Flag="Particles",Title="Particles",Value=true,Callback=function(v)S.Particles=v;if v then sP()else xP()end end})
    t4:Toggle({Flag="Acrylic",Title="Acrylic",Value=true,Callback=function(v)S.Acrylic=v;pcall(function()WI:ToggleAcrylic(v)end)end})
    t4:Toggle({Flag="Transparent",Title="Transparent",Value=false,Callback=function(v)S.Transparent=v;pcall(function()WN:ToggleTransparency(v)end)end})
    local tns={"Dark","Light","Rose","Plant","Ocean","Sunset","Midnight","Forest","Lavender","Coral","Mint","Sky","Blood","Lemon","Cyber"}
    t4:Dropdown({Flag="Theme",Title="Theme",Values=tns,Value="Dark",Callback=function(v)pcall(function()WI:SetTheme(v)end);S.ParticleColor=tc(v)end})
    local t5=WN:Tab({Title="Stats",Icon="solar:chart-bold"});local pC=t5:Paragraph({Title="Players:0"})
    local t6=WN:Tab({Title="Config",Icon="solar:diskette-bold"})
    pcall(function()
        local CM=WN.ConfigManager;if not CM then return end
        local cni=t6:Input({Flag="CN",Title="Config Name",Value="default",Icon="solar:file-text-bold",Callback=function(v)end})
        t6:Space();local AC={};pcall(function()AC=CM:AllConfigs()end);local DV=nil;for _,v in ipairs(AC) do if v=="default" then DV="default";break end end
        local ACD=t6:Dropdown({Title="Saved",Values=AC,Value=DV,Callback=function(v)if v then pcall(function()cni:Set(v)end)end end})
        t6:Space();t6:Button({Title="Save",Icon="solar:check-circle-bold",Justify="Center",Color=Color3.fromHex("#305dff"),Callback=function()if not CM then return end;local c=CM:Config("default");if c and c:Save() then WI:Notify({Title="Saved",Content="OK",Duration=3,Icon="solar:check-circle-bold"});pcall(function()ACD:Refresh(CM:AllConfigs())end)end end})
        t6:Space();t6:Button({Title="Load",Icon="solar:refresh-circle-bold",Justify="Center",Color=Color3.fromHex("#10C550"),Callback=function()if not CM then return end;local c=CM:CreateConfig("default",false);if c and c:Load() then WI:Notify({Title="Loaded",Content="OK",Duration=3,Icon="solar:refresh-circle-bold"})end end})
        t6:Space();t6:Button({Title="Delete",Icon="solar:trash-bin-trash-bold",Justify="Center",Color=Color3.fromHex("#ff3040"),Callback=function()if not CM then return end;local c=CM:Config("default");if c and c:Delete() then WI:Notify({Title="Deleted",Content="OK",Duration=3,Icon="solar:trash-bin-trash-bold"});pcall(function()ACD:Refresh(CM:AllConfigs())end)end end})
        spawn(function()wait(1)pcall(function()CM:CreateConfig("default",true)end)end)end)
    local t7=WN:Tab({Title="About",Icon="solar:info-square-bold"})
    t7:Paragraph({Title="Hooked! Script v1.0"});t7:Divider()
    t7:Paragraph({Title="Author",Desc="b站英吉利超入_"})
    t7:Paragraph({Title="Features",Desc="Auto Aim / Silent Aim / ESP / Speed / Fly / Auto Heal"})
    return pC
end

pcall(function()WI:SetTheme("Dark")end);S.ParticleColor=tc("Dark")
local PP=false
WI:Popup({Title="Hooked! v1.0",Content="Auto Aim / ESP / Speed / Fly / Auto Heal",Buttons={{Title="Load",Callback=function()PP=true end,Variant="Primary"},{Title="Cancel",Callback=function()return end}}})
while not PP do wait(0.1)end

spawn(function()
    local pC=mW();print("[上钩了] v1.0 运行中")
    UIS.InputBegan:Connect(function(input,gpe)if gpe or input.UserInputType~=Enum.UserInputType.Keyboard then return end;if input.KeyCode and input.KeyCode.Name==KB.Toggle and WN then pcall(function()WN:Toggle()end)end end)
    while true do pcall(doAim);pcall(doHeal);pcall(doSpeed);pcall(updateESP)
        if pC and tick()-last>3 then last=tick();pcall(function()pC:SetTitle("Players: "..#P:GetPlayers())end)end
        wait(0.05)
    end
end)