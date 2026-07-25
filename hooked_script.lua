-- 上钩了! v1.4 -- 完整调试版
print("[上钩了] v1.4 加载中...")
local P=game:GetService("Players");local WS=game:GetService("Workspace");local RS=game:GetService("ReplicatedStorage");local UIS=game:GetService("UserInputService");local C=game:GetService("CoreGui");local CA=game:GetService("Camera");local LP=P.LocalPlayer
if not LP then return end
for _,g in ipairs(C:GetChildren())do if g:IsA("ScreenGui")and(g.Name=="A"or g.Name:find("Hook")or g.Name=="WindUI")then pcall(function()g:Destroy()end)end end
local WI=loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WI then return end
print("[上钩了] WindUI OK")
local TEvent=require(RS.Shared.Core.TEvent)
local HF=TEvent.Remote.new("HookFire")
print("[上钩了] HookFire="..tostring(typeof(HF.FireServer)=="function"))
local c=LP.Character;local hrp=c and c:FindFirstChild("HumanoidRootPart")
print("[调试] 角色="..tostring(c~=nil).." HRP="..tostring(hrp~=nil))
local S={AA=false,SA=false,SPD=false,SPDV=24,FLY=false,FLYV=50,ESP=false,ESPR=200};local KB={W="RightShift"};local WN,CT=nil,{};local flyState=false
local function gHRP(pl)return pl and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")end
local function gN(r)
    local c2=LP.Character;local hrp2=c2 and c2:FindFirstChild("HumanoidRootPart")
    if not hrp2 then return nil,999 end
    local p=hrp2.Position;local b,bD=nil,r or 200
    for _,pl in ipairs(P:GetPlayers())do if pl~=LP then
        local hp=gHRP(pl)
        if hp then local d=(hp.Position-p).Magnitude;if d<bD then bD=d;b=pl end end
    end end
    return b,bD
end
local function doAim()
    local t,d=gN(200)
    if not t then print("[瞄准] 无目标");return end
    local hp=gHRP(t);if not hp then print("[瞄准] 目标无HRP");return end
    local c2=LP.Character;local my=c2 and c2:FindFirstChild("HumanoidRootPart")
    if not my then print("[瞄准] 自己无HRP");return end
    if S.AA then
        CA.CFrame=CFrame.lookAt(CA.CFrame.Position,hp.Position)
        print("[瞄准] 转向: "..t.Name.." @"..math.floor(d).."m")
    end
    local dir=(hp.Position-my.Position).Unit;local dist=(hp.Position-my.Position).Magnitude
    local data={hookId=tostring(tick()),batchId="aim",hookCount=1,startPosition=my.Position,direction=dir,distance=dist,hookTravelTime=0.15,hookBackSpeed=60,fireTime=tick()}
    local ok,err=pcall(function()HF:FireServer(data)end)
    print("[瞄准] HookFire "..t.Name.." → "..(ok and "OK" or "ERR: "..tostring(err)))
end
local function enableFly()local c2=LP.Character;local hrp2=c2 and c2:FindFirstChild("HumanoidRootPart");if not hrp2 then return end;local h=c2:FindFirstChildOfClass("Humanoid");if h then h.PlatformStand=true end;flyState=true;spawn(function()while flyState do local c3=LP.Character;local hrp3=c3 and c3:FindFirstChild("HumanoidRootPart");if not hrp3 then break end;local spd=S.FLYV;local cf=CA.CFrame;local fwd=cf.LookVector*Vector3.new(1,0,1).Unit;local rgt=cf.RightVector*Vector3.new(1,0,1).Unit;local mv=Vector3.new();if UIS:IsKeyDown(Enum.KeyCode.W)then mv=mv+fwd end;if UIS:IsKeyDown(Enum.KeyCode.S)then mv=mv-fwd end;if UIS:IsKeyDown(Enum.KeyCode.A)then mv=mv-rgt end;if UIS:IsKeyDown(Enum.KeyCode.D)then mv=mv+rgt end;if UIS:IsKeyDown(Enum.KeyCode.Space)then mv=mv+Vector3.new(0,1,0)end;if UIS:IsKeyDown(Enum.KeyCode.LeftShift)then mv=mv+Vector3.new(0,-1,0)end;if mv.Magnitude>0 then mv=mv.Unit*spd*0.05;hrp3.CFrame=hrp3.CFrame+mv end;wait(0.03)end;local c4=LP.Character;local h4=c4 and c4:FindFirstChildOfClass("Humanoid");if h4 then h4.PlatformStand=false end end)end
local function disableFly()flyState=false;local c2=LP.Character;local h=c2 and c2:FindFirstChildOfClass("Humanoid");if h then h.PlatformStand=false end end
local ESP={}
local function cESP()for _,d in pairs(ESP)do pcall(function()d:Remove()end)end;ESP={}end
local function uESP()
    if not S.ESP then cESP();return end
    local c2=LP.Character;local hrp2=c2 and c2:FindFirstChild("HumanoidRootPart");local pos=hrp2 and hrp2.Position
    if not pos then return end;local seen={}
    for _,pl in ipairs(P:GetPlayers())do if pl~=LP then
        local hp=gHRP(pl)
        if hp then local d=(hp.Position-pos).Magnitude
            if d<=S.ESPR then
                if not ESP[pl]then
                    local n=Drawing.new("Text");n.Size=16;n.Center=true;n.Outline=true;n.Color=Color3.fromRGB(255,80,80);n.Font=2
                    local b=Drawing.new("Square");b.Thickness=2;b.Color=Color3.fromRGB(255,80,80)
                    local l=Drawing.new("Line");l.Thickness=1;l.Color=Color3.fromRGB(255,255,255,120)
                    ESP[pl]={T=n,B=b,L=l}
                    print("[ESP] 创建: "..pl.Name)
                end
                local e=ESP[pl];local sp,on=CA:WorldToViewportPoint(hp.Position)
                e.T.Visible=on;e.B.Visible=on;e.L.Visible=on
                if on then e.T.Position=Vector2.new(sp.X,sp.Y-30);e.T.Text=pl.Name.."["..math.floor(d).."m]";e.B.Position=Vector2.new(sp.X-25,sp.Y-40);e.B.Size=Vector2.new(50,80);e.L.From=Vector2.new(CA.ViewportSize.X/2,CA.ViewportSize.Y);e.L.To=Vector2.new(sp.X,sp.Y)end
                seen[pl]=true
            end
        end
    end end
    for pl,d in pairs(ESP)do if not seen[pl]then d.T.Visible=false;d.B.Visible=false;d.L.Visible=false end end
end
WN=WI:CreateWindow({Title="上钩了! v1.4",Author="b站英吉利超入_",Icon="solar:hook-bold",Size=UDim2.fromOffset(750,520),ToggleKey=Enum.KeyCode.RightShift,Folder="hooked-script",Acrylic=true,Resizable=false,ScrollBarEnabled=true,HideSearchBar=true,OnClose=function()cESP();S.FLY=false;disableFly();for _,ct in pairs(CT)do if ct and type(ct.Set)=="function"then pcall(function()ct:Set(false)end)end end end})
spawn(function()wait(0.8)pcall(function()if WN and WN.Parent then WN.Parent.ClipsDescendants=true end end)end)
local t1=WN:Tab({Title="主控面板",Icon="solar:slider-vertical-bold"})
CT.AA=t1:Toggle({Flag="AA",Title="自动瞄准(HookFire)",Value=false,Callback=function(v)S.AA=v end})
CT.SA=t1:Toggle({Flag="SA",Title="静默瞄准",Value=false,Callback=function(v)S.SA=v end})
t1:Divider()
CT.SPD=t1:Toggle({Flag="SPD",Title="加速",Value=false,Callback=function(v)S.SPD=v end})
CT.SPDV=t1:Slider({Flag="SPDV",Title="速度",Step=5,Value={Min=16,Max=120,Default=24},Width=200,Callback=function(v)S.SPDV=v end})
CT.FLY=t1:Toggle({Flag="FLY",Title="飞行",Value=false,Callback=function(v)S.FLY=v;if v then enableFly()else disableFly()end end})
CT.FLYV=t1:Slider({Flag="FLYV",Title="飞行速度",Step=10,Value={Min=10,Max=150,Default=50},Width=200,Callback=function(v)S.FLYV=v end})
local t2=WN:Tab({Title="透视",Icon="solar:eye-bold"})
CT.ESP=t2:Toggle({Flag="ESP",Title="玩家透视",Value=false,Callback=function(v)S.ESP=v;if not v then cESP()end end})
CT.ESPR=t2:Slider({Flag="ESPR",Title="透视范围",Step=25,Value={Min=25,Max=500,Default=200},Width=200,Callback=function(v)S.ESPR=v end})
local t3=WN:Tab({Title="快捷键",Icon="solar:settings-bold"})
t3:Keybind({Flag="WK",Title="窗口开关",Value="RightShift",Callback=function(v)KB.W=v;pcall(function()WN:SetToggleKey(v)end)end})
local t4=WN:Tab({Title="UI设置",Icon="solar:monitor-bold"})
t4:Toggle({Flag="ACR",Title="毛玻璃",Value=true,Callback=function(v)pcall(function()WI:ToggleAcrylic(v)end)end})
t4:Toggle({Flag="TRN",Title="透明",Value=false,Callback=function(v)pcall(function()WN:ToggleTransparency(v)end)end})
t4:Dropdown({Flag="THM",Title="主题",Values={"Dark","Light","Rose","Plant","Ocean","Sunset","Midnight","Forest","Lavender","Coral","Mint","Sky","Blood","Lemon","Cyber"},Value="Dark",Callback=function(v)pcall(function()WI:SetTheme(v)end)end})
local t5=WN:Tab({Title="信息统计",Icon="solar:chart-bold"});local sp5=t5:Paragraph({Title="在线玩家: 0"})
local t6=WN:Tab({Title="配置管理",Icon="solar:diskette-bold"});local t7=WN:Tab({Title="关于",Icon="solar:info-square-bold"})
t7:Paragraph({Title="上钩了! v1.4"});t7:Divider();t7:Paragraph({Title="作者",Desc="b站英吉利超入_"})
UIS.InputBegan:Connect(function(input,gpe)if gpe then return end;if input.UserInputType==Enum.UserInputType.Keyboard then local kn=input.KeyCode and input.KeyCode.Name or "";if kn==KB.W and WN then pcall(function()WN:Toggle()end)end end end)
print("[上钩了] v1.4 运行中")
spawn(function()
    local last=0
    while true do
        if S.AA or S.SA then pcall(doAim)end
        if S.SPD and LP.Character then local h=LP.Character:FindFirstChildOfClass("Humanoid");if h then h.WalkSpeed=S.SPDV end end
        pcall(uESP)
        local now=tick()
        if now-last>3 then last=now;if sp5 then pcall(function()sp5:SetTitle("在线玩家: "..#P:GetPlayers())end)end end
        wait(0.08)
    end
end)