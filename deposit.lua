if (not LPH_OBFUSCATED) then
    LPH_NO_VIRTUALIZE = function(...) return (...) end;
    LPH_JIT_MAX = function(...) return (...) end;
    LPH_JIT_ULTRA = function(...) return (...) end;
end

function load()
--// bypassington the anti cheat
for Key, Object in pairs(getgc(true)) do
    if type(Object) == "table" then
        setreadonly(Object, false)
        local indexInstance = rawget(Object, "indexInstance")
        if type(indexInstance) == "table" and indexInstance[1] == "kick" then
            setreadonly(indexInstance, false)
            rawset(Object, "Table", {"kick", function() coroutine.yield() end})
            break
        end
    end
end
--
assert(getrawmetatable)
grm = getrawmetatable(game)
setreadonly(grm, false)
old = grm.__namecall

grm.__namecall = newcclosure(function(self, ...)
    local args = {...}  

    local methodName = tostring(args[1])

    local blockedMethods = {"TeleportDetect", "CHECKER_1", "CHECKER", "GUI_CHECK", "OneMoreTime", "checkingSPEED", "BANREMOTE", "PERMAIDBAN", "KICKREMOTE", "BR_KICKPC", "BR_KICKMOBILE"}

    if table.find(blockedMethods, methodName) then return end

    return old(self, ...)
end)

-- // Services
local MainColor = Color3.fromRGB(255, 105, 180);
local bullettp = false;
local Players           = game:GetService("Players");
local RunService        = game:GetService("RunService");
local UserInputService  = game:GetService("UserInputService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Workspace         = game:GetService("Workspace");
local TweenService      = game:GetService("TweenService");
local Debris            = game:GetService('Debris');
local Lighting       = game:GetService("Lighting");
--
local LocalPlayer       = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local bodyClone = game:GetObjects("rbxassetid://8246626421")[1]; bodyClone.Humanoid:Destroy(); bodyClone.Head.Face:Destroy(); bodyClone.Parent = game.Workspace; bodyClone.HumanoidRootPart.Velocity = Vector3.new(); bodyClone.HumanoidRootPart.CFrame = CFrame.new(9999,9999,9999); bodyClone.HumanoidRootPart.Transparency = 1; bodyClone.HumanoidRootPart.CanCollide = false 
local visualizeChams = Instance.new("Highlight"); visualizeChams.Enabled = true; visualizeChams.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; visualizeChams.FillColor = Color3.fromRGB(102, 60, 153); visualizeChams.OutlineColor =  Color3.fromRGB(0, 0, 0); visualizeChams.Adornee = bodyClone; visualizeChams.OutlineTransparency = 0.2; visualizeChams.FillTransparency = 0.5; visualizeChams.Parent = game.CoreGui

-- // Variables
local crosshair_position = "Middle";
local hitSoundsNames = {"Bameware", "Bubble", "Pick", "Pop", "Rust", "Sans", "Fart", "Big", "Vine", "Bruh", "Skeet", "Neverlose", "Fatality", "Bonk","Minecraft"}
local dahood_ids = {2788229376, 16033173781, 7213786345}
local bullet_path = workspace:FindFirstChild("Ignored") or workspace:FindFirstChild("Ignored") and workspace.Ignored:FindFirstChild("Siren") and workspace.Ignored.Siren:FindFirstChild("Radius") or nil
local old_hrp = nil;
local should_haalfi_destroy = false;
local Radians = 0
--
local HitChamsFolder = Instance.new("Folder")
HitChamsFolder.Name = "HitChamsFolder"
HitChamsFolder.Parent = Workspace
--
-- // Crosshair Handler \\ --
local Cursor = loadstring(game:HttpGet('https://pastebin.com/raw/D662tS1Q', true))() do
    Cursor.enabled = false
    Cursor.color = MainColor
end

-- // Yun Drawing API \\ --
local YunDrawingApi = loadstring(game:HttpGet('https://raw.githubusercontent.com/caIIed/Librarys/main/Yun%20Api.lua', true))()

local TargetCircle = YunDrawingApi:New3DCircle() do
    TargetCircle.Visible = false
    TargetCircle.ZIndex = 1
    TargetCircle.Transparency = 1
    TargetCircle.Color = MainColor
    TargetCircle.Thickness = 1
    TargetCircle.Radius = 2
    TargetCircle.Rotation = Vector2.new(2, 0)
end

-- // Tables
local Script = {
    TargetAim = {
        Enabled = false,
        Type = "Target Aim",
        Method = "FireServer",
        Prediction = 0.143,
        Stuff = {
            LookAt = false,
            Spectate = false,
            Notify = false,
            AutoPrediction = false
        },
        Teleport = {
            GrenadeTP = false,
            RocketTP = false
        },
        HitPart = {
            ClosestPart = false,
            ClosestMode = "Nearest Part",
            Part = "HumanoidRootPart",
        }
    },
    TriggerBot = {
        Enabled = false,
        Visualize = false,
        Prediction = 0.135,
        Range = 20, -- Self Explanatory
        UseDelay = false,
        Delay = 0.02
    },
    AimAssist = {
        Enabled = false,
        ThirdPerson = false,
        FirstPerson = false,
        MouseTP = false,
        Prediction = 0.138,
        HitPart = {
            ClosestPart = false,
            Part = "HumanoidRootPart",
        },
        Shake = {
            Enabled = false,
            Amount = 5
        },
        Smoothness = {
            Enabled = false,
            Amount = 0.1,
            Style = "Elastic",
            Direction = "InOut"
        }
    },
    Checks = {
        Enabled = false,
        Vehicle = false,
        Knocked = false,
        Friend = false,
        Wall = false
    },
    Resolver = {
        Enabled = false,
        Method = "LookVector", -- Options: LookVector, Recalculate, Zero Prediction, Move Direction
        AntiAimViewer = false
    },
    Visuals = {
        SelfESP = {
           Chams = {
                ForcefieldBodyEnabled = false,
                ForcefieldToolsEnabled = false,
                ForcefieldHatsEnabled = false,
                ForcefieldBodyColor = MainColor,
                ForcefieldToolsColor = MainColor,
                ForcefieldHatsColor = MainColor
            },
            Trail = {
                Enabled = false,
                LifeTime = 5,
                Color = MainColor
            },
            Aura = {
                Enabled = false,
                Type = "Heal"
            }
        },
        BulletTracers = {
            Enabled = false,
            Duration = 5,
            Fade = false,
            FadeDuration = 5,
            Color = MainColor,
            Type = "Drawing",
            Mode = "Global"
        },
        BulletImpacts = {
            Enabled = false,
            Width = 0.25,
            Color = MainColor,
            Duration = 5,
            Fade = false,
            FadeDuration = 5
        },
        Hit_Detection = {
            Enabled = false,
            Notify = false,
            Clone = false,
            HitEffect = false,
            HitEffectType = "Nova",
            Sound = false,
            HitSound = "Rust"
        },
        HighLight = {
            Enabled = false,
            Fill = MainColor,
            OutLine = Color3.fromRGB(255, 255, 255)
        },
        Line = {
            Enabled = false,
            Circle = false,
            Color = MainColor,
            Thickness = 2
        },
        Dot = {
            Enabled = false,
            Color = MainColor,
            Size = 1
        },
        FoV = {
            Enabled = false,
            Color = Color3.fromRGB(255, 255, 0),
            Size = 60,
            Sticky = false,
            Position = "Middle"
        },
    },
    Rage = {
       CFrameSpeed = {
            Enabled = false,
            Speed = 4
        },
       AutoArmor = {
            Enabled = false,
            BuyOn = 50,
        },
        Killbot = {
            Enabled = false,
            Type = "Orbit",
            Randomization = 3,
            Speed = 10,
            Distance = 5,
            Height = 5,
            BypassDC = false
        },
        AutoBuy = {
            SelectedFood = "Taco",
            SelectedGun = "LMG",
            SelectedLocation = "School"
        },
        Exploits = {
            AutoStomp = false,
            AntiBag = false,
            AntiRPG = false,
            NoJumpCooldown = false,
            NoSlow = false,
            NoRecoil = false,
        }
    },
    AntiAim = {
        CSync = {
            Enabled = false,
            VoidSpam = false,
            DestroyCheaters = false,
            Attach = false,
            Type = "Random",
            Visualize = {
                Enabled = false,
                Type = "Dot",
                Color = MainColor
            },
            Randomize = { Value = 20 },
            TargetStrafe = {
                Speed = 0,
                Height = 0,
                Distance = 0
            },
            Custom = {
                X = 0,
                Y = 0,
                Z = 0
            }
        },
        VelocitySpoofer = {
            Enabled = false,
            Type = "Custom",
            Pitch = 0,
            Yaw = 0,
            Roll = 0,
            Multiplier = 1,
            ShakeValue = 1,
            AimViewer = {
                Enabled = false,
                Color = Color3.new(255,255,255),
                Thickness = 1
            }
        },
        FFlagDesync = {
            Enabled = false,
            SetNew = false,
            FFlags = {"S2PhysicsSenderRate"},
            SetNewAmount = 15,
            Amount = 2
        },
        Network = {
            Enabled = false,
            WalkingCheck = false,
            Amount = 0.1
        }
    },
    Hooks = {},
}
--
getgenv().taffy_esp = {
    enabled = false,
    box = {
        boxes = false,
        boxtype = "2D",
        filled = false,
        filledColor = Color3.fromRGB(255, 255, 255),
        outline = false,
        healthbar = false,
        healthtext = false,
        healthtextcolor = Color3.new(255, 255, 255),
        color1 = Color3.fromRGB(255, 255, 255),
        color2 = Color3.fromRGB(0, 0, 0),
        healthbarcolor = Color3.fromRGB(0, 255, 0)
    },
    tracer = {
        enabled = false,
        unlocktracers = false,
        color = Color3.fromRGB(255, 255, 255)
    },
    name = {
        enabled = false,
        outline = true,
        size = 16.6,
        font = 2,
        color = Color3.fromRGB(255, 255, 255)
    },
    misc = {
        teamcheck = false,
        useteamcolors = false,
        visibleonly = true,
        target = false,
        fade = false,
        fadespeed = 4
    },  
    Toolsshow = {
        enable = false,
        outline = true,
        size = 8,
        font = 3,
        color = Color3.fromRGB(255, 255, 255)
    },
    Skeletons = {
        Enabled = false,
        Color = Color3.new(255, 255, 255)
    }
}
--
local InnalillahiMichaelJackson = {
    Locals = {
        Angle = 0,
        Target = nil,
        AimAssistTarget = nil,
        HitPart = nil,
        AimAssistHitPart = nil,
        AimPoint = nil,
        AimAssistAimPoint = nil,
        Position = nil,
        AntiRpg = false,
        NetworkPreviousTick = tick(),
        NetworkShouldSleep = false,
        Original = {},
        FFlags = {},
        AntiAimViewer = {
            MouseRemoteFound = false,
            MouseRemote = nil,
            MouseRemoteArgs = nil,
            MouseRemotePositionIndex = nil
        }
    },
    HitSounds = {
        Bameware = "rbxassetid://3124331820",
        Bell = "rbxassetid://6534947240",
        Bubble = "rbxassetid://6534947588",
        Pick = "rbxassetid://1347140027",
        Pop = "rbxassetid://198598793",
        Rust = "rbxassetid://1255040462",
        Sans = "rbxassetid://3188795283",
        Fart = "rbxassetid://130833677",
        Big = "rbxassetid://5332005053",
        Vine = "rbxassetid://5332680810",
        Bruh = "rbxassetid://4578740568",
        Skeet = "rbxassetid://5633695679",
        Neverlose = "rbxassetid://6534948092",
        Fatality = "rbxassetid://6534947869",
        Bonk = "rbxassetid://5766898159",
        Minecraft = "rbxassetid://4018616850"
    },
    Guns = {
        "Revolver",
        "Double-Barrel SG",
        "High-Medium Armor",
        "Flamethrower",
        "SMG",
        "RPG",
        "P90",
        "LMG",
        "Key"
    },
    Food = {
        "Pizza",
        "Taco",
        "Chicken",
        "Cranberry",
        "Popcorn",
        "Hamburger",
        "HotDog"
    },
    Locations = {
       "Uphill",
       "Military",
       "Park",
       "Downhill",
       "Double Barrel",
       "Casino",
       "Trailer",
       "School",
       "Revolver",
       "Bank",
       "Sewer",
       "Fire Station",
       "Hood Fitness",
       "Hood Kicks",
       "Jail",
       "Church",
    }
}
--
local Deposit = {};
local Notifications = {}
--
local MainStartESP = tick()
local Esp = loadstring(game:HttpGet("https://pastebin.com/raw/3K449kRk"))()

for _, Player in pairs(game:GetService("Players"):GetChildren()) do
    Esp:Esp(Player)
end

Players.PlayerAdded:Connect(function(v)
    Esp:Esp(v)
end)
--
local protect_gui = function(Gui, Parent)
    if gethui and syn and syn.protect_gui then 
        Gui.Parent = gethui() 
    elseif not gethui and syn and syn.protect_gui then 
        syn.protect_gui(Gui)
        Gui.Parent = Parent 
    else 
        Gui.Parent = Parent 
    end
end
--
local function GetDictionaryLength(Dictionary: table)
    local Length = 0
    for _ in pairs(Dictionary) do
        Length += 1
    end
    return Length
end
--
local InnalillahiMataKiri = Instance.new("ScreenGui")
InnalillahiMataKiri.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
protect_gui(InnalillahiMataKiri, game:GetService("CoreGui"))
--
local Notifications_Frame = Instance.new("Frame")
Notifications_Frame.Name = "Notifications"
Notifications_Frame.BackgroundTransparency = 1
Notifications_Frame.Size = UDim2.new(1, 0, 1, 36)
Notifications_Frame.Position = UDim2.fromOffset(0, -36)
Notifications_Frame.ZIndex = 5
Notifications_Frame.Parent = InnalillahiMataKiri

function Notifications:Notify(Content: string, Delay: number)
    assert(typeof(Content) == "string", "missing argument #1, (string expected got " .. typeof(Content) .. ")")
    local Delay = typeof(Delay) == "number" and Delay or 3

    local Text = Instance.new("TextLabel")
    local Notification = {
        self = Text,
        Class = "Notification"
    }

    Text.Name = "Notification"
    Text.BackgroundTransparency = 1
    Text.Position = UDim2.new(0.5, -100, 1, -150 - (GetDictionaryLength(Notifications) * 15))
    Text.Size = UDim2.new(0, 0, 0, 15)
    Text.Text = Content
    Text.Font = Enum.Font.SourceSans
    Text.TextSize = 17
    Text.TextColor3 = Color3.new(1, 1, 1)
    Text.TextStrokeTransparency = 0.2
    Text.TextTransparency = 1
    Text.RichText = true
    Text.ZIndex = 4
    Text.Parent = Notifications_Frame

    local function CustomTweenOffset(Offset: number)
        spawn(function()
            local Steps = 33
            for i = 1, Steps do
                Text.Position += UDim2.fromOffset(Offset / Steps, 0)
                RunService.RenderStepped:Wait()
            end
        end)
    end

    function Notification:Update()
        
    end

    function Notification:Destroy()
    Notifications[Notification] = nil
    Text:Destroy()

    local Index = 1
    for _, v in pairs(Notifications) do
        local self = v.self
        self.Position += UDim2.fromOffset(0, 15)
        Index += 1
    end
end


    Notifications[Notification] = Notification
    
    local TweenIn  = TweenService:Create(Text, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0), {TextTransparency = 0})
    local TweenOut = TweenService:Create(Text, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0), {TextTransparency = 1})
    
    TweenIn:Play()
    CustomTweenOffset(100)
    
    TweenIn.Completed:Connect(function()
        delay(Delay, function()
            TweenOut:Play()
            CustomTweenOffset(100)

            TweenOut.Completed:Connect(function()
                Notification:Destroy()
            end)
        end)
    end)
end
--
function Deposit:Render(type,properties)
    local drawing_object = Drawing.new(type)
    for property,value in pairs(properties) do
        drawing_object[property] = value
    end
    return drawing_object
end
--
function Deposit:Instance(type,properties)
    local instance = Instance.new(type)
    for property,value in pairs(properties) do
        instance[property] = value
    end
    return instance
end
--
local SilentAimFOVCircle = Deposit:Render("Circle", {
    Visible = Script.Visuals.FoV.Enabled,
    Color = Script.Visuals.FoV.Color,
    Radius = Script.Visuals.FoV.Size,
    Thickness = 1
})
--
local TriggerBotDot = Deposit:Render("Circle", {
    Visible = false,
    Color = MainColor,
    Radius = 20,
    Thickness = 1
})
--
local Line = Deposit:Render("Line", {
    Visible = false,
    Color = MainColor,
    Thickness = 2,
    Transparency = 0.5,
})
--
local Dot = Deposit:Render("Circle", {
    Visible = false,
    Filled = true,
    Color = MainColor,
})
--
local TargetChams = Deposit:Instance("Highlight", {
    Parent = nil,
    FillColor = MainColor,
    OutlineColor = MainColor,
})
--
local CFrameDesyncDot  = Deposit:Render("Circle", {
    Visible = false,
    Filled = true
})

local CFrameDesyncTracer  = Deposit:Render("Line", {
    Visible = false,
    Color = MainColor,
    Thickness = 2
})
--
function Gun(Name)
    for Check = 1, 100000 do
        if game.Workspace.Ignored.Shop:FindFirstChild("[" .. Name .. "] - $" .. Check) then
            return tostring("[" .. Name .. "] - $" .. Check)
        end
    end
end

function Ammo(Name)
    for Check1 = 1, 250 do
        for Check2 = 1, 500 do
            if game.Workspace.Ignored.Shop:FindFirstChild(Check1 .. " [" .. Name .. " Ammo] - $" .. Check2) then
                return tostring(Check1 .. " [" .. Name .. " Ammo] - $" .. Check2)
            end
        end
    end
end

function Buy(Target, Delay, LagBack, Times)
    if Times == nil then
        Times = 3
    end
    local item = game.Workspace.Ignored.Shop:FindFirstChild(Target)
    if item then
        savepos = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
        for i = 1, Times do
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = item.Head.CFrame * CFrame.new(0, 3, 0)
            task.wait(0.5)
            for i = 1, 10 do
                fireclickdetector(item.ClickDetector)
            end
            task.wait(0.5)
        end
        if LagBack then
            task.wait(1)
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = savepos
        end
        if Delay ~= nil then
            task.wait(Delay)
        end
    end
end

function BuyGunAndAmmo(GUN, times)
    if
        game.Players.LocalPlayer.Backpack:FindFirstChild("[" .. GUN .. "]") or
            game.Players.LocalPlayer.Character:FindFirstChild("[" .. GUN .. "]")
     then
        Buy(Ammo(GUN), 0.3, true, times)
    else
        Buy(Gun(GUN), 0.5, true)
    end
end

function tp(v) 
   if v == "Uphill" then 
       game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(482, 48, -602)
   elseif v == "Military" then 
       game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(58.71923828125, 25.25499725341797, -869.0357055664062) 
   elseif v == "Park" then 
       game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-268, 22, -754) 
   elseif v == "Admin" then 
       game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-800, -40, -887) 
   elseif v == "Admin Guns" then 
       game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-872, -33, -536) 
   elseif v == "Downhill" then 
       game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-565, 8, -737) 
   elseif v == "Double Barrel" then 
       game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1042, 22, -261) 
   elseif v == "Casino" then 
       game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-864, 22, -143) 
   elseif v == "Trailer" then 
       game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-963, -1, 469) 
   elseif v == "School" then 
       game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-653, 22, 257) 
   elseif v == "Revolver" then 
       game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-642, 22, -124) 
   elseif v == "Bank" then 
       game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-446, 39, -286) 
   elseif v == "Sewer" then 
       game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(112, -27, -277) 
   elseif v == "Fire Station" then 
       game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-150, 54, -94) 
   elseif v == "Hood Fitness" then 
       game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-76, 23, -638) 
   elseif v == "Hood Kicks"  then 
       game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-188, 22, -410) 
   elseif v == "Jail" then 
       game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-299, 22, -91) 
   elseif v == "Church" then 
       game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(205, 22, -80) 
   end
end
--
function Deposit:RandomVectorThree(randomization)
    return Vector3.new(math.random(-randomization, randomization), math.random(-randomization, randomization), math.random(-randomization, randomization))
end
--
function Deposit:BehindWall(player)
	local onskibidi = Camera:GetPartsObscuringTarget({LocalPlayer.Character.HumanoidRootPart.Position, player.Character.HumanoidRootPart.Position}, {LocalPlayer.Character, player.Character});
	return #onskibidi ~= 0;
end
--
function Deposit:UpdateFOV()
    if Settings.TargetAim.Enabled and SilentAimFOVCircle then
        SilentAimFOVCircle.Visible = Script.Visuals.FoV.Enabled
        SilentAimFOVCircle.Radius = Script.Visuals.FoV.Size
        SilentAimFOVCircle.NumSides = 1000
        SilentAimFOVCircle.Transparency = 0.5
        SilentAimFOVCircle.Filled = true
        SilentAimFOVCircle.Color = Script.Visuals.FoV.Color
        --
        if Script.Visuals.FoV.Position == "Middle" then
            SilentAimFOVCircle.Position = Camera.ViewportSize * 0.5
        else
            if Script.Visuals.FoV.Sticky and Target and Target.Character and Target.Character[InnalillahiMichaelJackson.Locals.HitPart] then
                local Position = workspace.CurrentCamera:WorldToViewportPoint(Target.Character[InnalillahiMichaelJackson.Locals.HitPart].Position)
                SilentAimFOVCircle.Position = Vector2.new(Position.X,Position.Y)
            else
                SilentAimFOVCircle.Position = Camera.ViewportSize * 0.5
            end
        end
    else
        SilentAimFOVCircle.Visible = false
    end
end
--
function Deposit:RecalculatePlayerVelocity(player)
    local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
    local initialPosition = rootPart.Position
    local initialTime = tick()

    task.wait()

    local finalPosition = rootPart.Position
    local finalTime = tick()

    local distanceTraveled = finalPosition - initialPosition
    local timeInterval = finalTime - initialTime

    return distanceTraveled / timeInterval
end
--
function Deposit:GetClosestBodyPart(Character)
local closestPart,closestDistance=nil,math.huge

if Character then
    for _,part in ipairs(Character:GetChildren()) do
        if part:IsA("BasePart") then
            local position,onScreen=Workspace.CurrentCamera:WorldToScreenPoint(part.Position)

            if onScreen then
                local distance=(Vector2.new(position.X,position.Y)-Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if distance<closestDistance then
                    closestDistance=distance
                    closestPart=part
                end
            end
        end
    end
end

return closestPart
end
--
function Deposit:GetClosestPoint(part)
    local mouseRay = Mouse.UnitRay
    local adjustedRay = mouseRay.Origin + (mouseRay.Direction * (part.Position - mouseRay.Origin).Magnitude)

    local point = (adjustedRay.Y >= (part.Position - part.Size / 2).Y and adjustedRay.Y <= (part.Position + part.Size / 2).Y) 
        and (part.Position + Vector3.new(0, adjustedRay.Y - part.Position.Y, 0)) 
        or part.Position

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Whitelist
    params.FilterDescendantsInstances = {part}

    local ray = Workspace:Raycast(adjustedRay, (point - adjustedRay), params)

    return ray and ray.Position or Mouse.Hit.Position
end
--
function Deposit:GetClosestPlayerToCursor(Huh)
    closestDist = Huh
    closestTarget = nil
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            if Script.Checks.Enabled and (
                (Script.Checks.Vehicle and v.Character:FindFirstChild("[CarHitBox]")) or
                (Script.Checks.Knocked and v.Character.Humanoid.Health < 4) or
                (Script.Checks.Friend and v:IsFriendsWith(LocalPlayer.UserId)) or
                (Script.Checks.Wall and Deposit:BehindWall(v))
            ) then 
                continue 
            end

            pcall(function()
                local primaryPart = v.Character:FindFirstChild("HumanoidRootPart") or v.Character.PrimaryPart
                if primaryPart then
                    local screenPos, cameraVisible = Camera:WorldToViewportPoint(primaryPart.Position)
                    if cameraVisible then
                        local distToMouse = (Vector2.new(screenPos.X, screenPos.Y) - Camera.ViewportSize * 0.5).magnitude
                        if distToMouse < closestDist then
                            closestTarget = v
                            closestDist = distToMouse
                        end
                    end
                end
            end)
        end
    end
    return closestTarget
end
--
function Deposit:CalculateResolverOfset(Player)
    local prediction = Script.TargetAim.Prediction
    local offset

    if Script.Resolver.Enabled then
        local method = Script.Resolver.Method
        local rootPart = player.Character.HumanoidRootPart

        if method == "Recalculate" then
            offset = Deposit:RecalculatePlayerVelocity(player) * prediction
        elseif method == "Zero Prediction" then
            offset = Vector3.new(rootPart.Velocity.X, 0, rootPart.Velocity.Z) * prediction
        elseif method == "Move Direction" then
            offset = player.Character.Humanoid.MoveDirection * 19.64285714289 * prediction
        elseif method == "Look Vector" then
            offset = player.Character[InnalillahiMichaelJackson.Locals.HitPart].CFrame.LookVector * prediction
        end
    end

    return offset
end
--
function Deposit:AimViewerCalculator()
    if Target and Target.Character and Script.Resolver.AntiAimViewer then
        local endpoint = InnalillahiMichaelJackson.Locals.AntiAimViewer.MouseRemoteArgs
        if Script.Resolver.Enabled then
            endpoint[InnalillahiMichaelJackson.Locals.AntiAimViewer.MouseRemotePositionIndex] = InnalillahiMichaelJackson.Locals.AimPoint + offset
        else
            endpoint[InnalillahiMichaelJackson.Locals.AntiAimViewer.MouseRemotePositionIndex] = InnalillahiMichaelJackson.Locals.AimPoint + (Target.Character[InnalillahiMichaelJackson.Locals.HitPart].Velocity * Script.TargetAim.Prediction)
        end
        InnalillahiMichaelJackson.Locals.AntiAimViewer.MouseRemote:FireServer(unpack(endpoint))
    end
end
--
function Deposit:CalculateAimAssistPredictedPosition()
    if not Script.AimAssist.Enabled or not Target or not Target.Character then return end

    local MousePosition = Mouse
    local Character = Target.Character
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart
    
    if not RootPart then return end
    
    local Position, OnScreen = Workspace.CurrentCamera:WorldToScreenPoint(RootPart.Position)
    local Distance = (Vector2.new(Position.X, Position.Y) - Camera.ViewportSize * 0.5).Magnitude
    local Shake = Vector3.new(0,0,0)
    
    -- Deposit Checks
    if Script.Checks.Enabled and (
        Script.Checks.Vehicle and Character:FindFirstChild("[CarHitBox]") or
        Script.Checks.Knocked and Humanoid.Health < 4 or
        Script.Checks.Friend and Target:IsFriendsWith(LocalPlayer.UserId) or
        Script.Checks.Wall and Deposit:BehindWall(Target)
    ) then
        return
    end
    
    -- Hit part and prediction calculation
    AimAssistHitPart = Script.AimAssist.HitPart.Part
    AimAssistAimPoint = Character[AimAssistHitPart].Position + Shake + Character[AimAssistHitPart].Velocity * Script.AimAssist.Prediction

    -- Shake effect
    if Script.AimAssist.Shake.Enabled then
        Shake = Vector3.new(
            math.random(-Script.AimAssist.Shake.Amount, Script.AimAssist.Shake.Amount),
            math.random(-Script.AimAssist.Shake.Amount, Script.AimAssist.Shake.Amount),
            math.random(-Script.AimAssist.Shake.Amount, Script.AimAssist.Shake.Amount)
        ) * 0.1
    end

    -- Camera movement
    local Main = CFrame.new(Workspace.CurrentCamera.CFrame.p, AimAssistAimPoint)
    local SmoothAmount = Script.AimAssist.Smoothness.Enabled and (100 - Script.AimAssist.Smoothness.Amount / 100) or 1
    
    Workspace.CurrentCamera.CFrame = Workspace.CurrentCamera.CFrame:Lerp(
        Main,
        SmoothAmount,
        Enum.EasingStyle[Script.AimAssist.Smoothness.Style],
        Enum.EasingDirection[Script.AimAssist.Smoothness.Direction]
    )
end
--
function Deposit:TrailCharacter(Bool)
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    if Bool then
        local BlaBla = Instance.new("Trail", humanoidRootPart)
        BlaBla.Name = "BlaBla"
        
        humanoidRootPart.Material = Enum.Material.Neon 
        
        local attachment0 = Instance.new("Attachment", humanoidRootPart)
        attachment0.Position = Vector3.new(0, 1, 0)
        local attachment1 = Instance.new("Attachment", humanoidRootPart)
        attachment1.Position = Vector3.new(0, -1, 0)

        BlaBla.Attachment0 = attachment0
        BlaBla.Attachment1 = attachment1
        
        BlaBla.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Script.Visuals.SelfESP.Trail.Color), ColorSequenceKeypoint.new(1, Script.Visuals.SelfESP.Trail.Color)});
        
        BlaBla.Lifetime = Script.Visuals.SelfESP.Trail.LifeTime
        
        BlaBla.Transparency = NumberSequence.new(0, 0)
        
        BlaBla.LightEmission = 1
        
        BlaBla.WidthScale = NumberSequence.new(0.08)
        
    else
        for _, child in ipairs(humanoidRootPart:GetChildren()) do
            if child:IsA("Trail") and child.Name == 'BlaBla' then
                child:Destroy()
            end
        end
    end
end
--
function Deposit:CloneCharacter(Player,transparency,color,material,duration)
    for _,BodyPart in pairs(Player.Character:GetChildren()) do
        if BodyPart.Name ~= "HumanoidRootPart" and BodyPart:IsA("MeshPart") then
            local Part = Instance.new("Part")
            Part.Name = BodyPart.Name.."_Clone"
            Part.Parent = HitChamsFolder
            Part.Material = material
            Part.Color = color
            Part.Transparency = transparency
            Part.Anchored = true
            Part.Size = BodyPart.Size
            Part.CFrame = BodyPart.CFrame

            task.delay(duration,function()
                Part:Destroy()
            end)
        end
    end
end
--
function Deposit:CreateBeam(from,to,color_1,color_2,duration,fade_enabled,fade_duration)
    local tween
    local total_time = 0

    local main_part = Deposit:Instance("Part",{
        Parent = workspace,
        Size = Vector3.new(0,0,0),
        Massless = true,
        Transparency = 1,
        CanCollide = false,
        Position = from,
        Anchored = true
    })

    local part0 = Deposit:Instance("Part",{
        Parent = main_part,
        Size = Vector3.new(0,0,0),
        Massless = true,
        Transparency = 1,
        CanCollide = false,
        Position = from,
        Anchored = true
    })

    local part1 = Deposit:Instance("Part",{
        Parent = main_part,
        Size = Vector3.new(0,0,0),
        Massless = true,
        Transparency = 1,
        CanCollide = false,
        Position = to,
        Anchored = true
    })

    local attachment0 = Deposit:Instance("Attachment",{
        Parent = part0
    })

    local attachment1 = Deposit:Instance("Attachment",{
        Parent = part1
    })

    local beam = Deposit:Instance("Beam",{
        Texture = "rbxassetid://446111271",
        TextureMode = Enum.TextureMode.Wrap,
        TextureLength = 10,
        LightEmission = 1,
        LightInfluence = 1,
        FaceCamera = true,
        ZOffset = -1,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0,0),
            NumberSequenceKeypoint.new(1,1),
        }),
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,color_1),
            ColorSequenceKeypoint.new(1,color_2),
        }),
        Attachment0 = attachment0,
        Attachment1 = attachment1,
        Enabled = true,
        Parent = main_part
    })

    if fade_enabled then
        tween = RunService.PostSimulation:Connect(function(delta_time) --// credits to xander
            total_time += delta_time
            beam.Transparency = NumberSequence.new(TweenService:GetValue((total_time/fade_duration),Enum.EasingStyle.Quad,Enum.EasingDirection.In))
        end)
    end

    task.delay(duration,function()
        main_part:Destroy()

        if tween then
            tween:Disconnect()
        end
    end)
end
--
function Deposit:CreateImpact(color,size,fade_enabled,fade_duration,duration,position)
    local impact = Deposit:Instance("Part",{
        CanCollide = false,
        Material = Enum.Material.Neon,
        Size = Vector3.new(size,size,size),
        Color = color,
        Position = position,
        Anchored = true,
        Parent = workspace
    })

    local outline = Deposit:Instance("SelectionBox",{ --// credits to xander
        LineThickness = 0.01,
        Color3 = color,
        SurfaceTransparency = 1,
        Adornee = impact,
        Visible = true,
        Parent = impact
    })

    if fade_enabled then
        local tween_info = TweenInfo.new(duration)
        local tween = TweenService:Create(impact,tween_info,{Transparency = 1})
        local tween_outline = TweenService:Create(outline,tween_info,{Transparency = 1})

        tween:Play()
        tween_outline:Play()
    end

    task.delay(duration,function()
        impact:Destroy()
    end)
end
--
function Deposit:CreateDrawingBeam(v1,v2)
    local line = Drawing.new("Line")
    line.Visible = true
    line.Color = Script.Visuals.BulletTracers.Color
    line.Thickness = 1

    local function UpdateLine()
        local startPos = workspace.CurrentCamera:WorldToViewportPoint(v1)
        local endPos = workspace.CurrentCamera:WorldToViewportPoint(v2)
        local isVisible = startPos.Z > 0 and endPos.Z > 0
        if isVisible then
            line.From = Vector2.new(startPos.X,startPos.Y)
            line.To = Vector2.new(endPos.X,endPos.Y)
        else
            line.Visible = false
        end
    end

    local startTime = tick()
    local connection
    connection = RunService.RenderStepped:Connect(function()
        UpdateLine()

        local elapsedTime = tick() - startTime
        if elapsedTime >= Script.Visuals.BulletTracers.Duration then
            connection:Disconnect()
            line:Remove()
        else
            local alpha = 1 - (elapsedTime/Script.Visuals.BulletTracers.Duration)
            line.Transparency = alpha
        end
    end)
end
--
RunService.PostSimulation:Connect(function()
    local TriggerBotTarget = Deposit:GetClosestPlayerToCursor(Script.TriggerBot.Range)
    if TriggerBotTarget and Script.TriggerBot.Enabled then
        local hrp = TriggerBotTarget.Character and TriggerBotTarget.Character:FindFirstChild("HumanoidRootPart")
        local playerTool = Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if hrp and playerTool then
            local toolName = playerTool.Name
            local validTool = toolName ~= "[Knife]" and toolName ~= "Wallet" -- Blacklisted Tool
            if validTool then
                local aimPos = hrp.Position + hrp.Velocity * Script.TriggerBot.Prediction
                local screenPos, onScreen = Camera:WorldToViewportPoint(aimPos)
                if onScreen then
                    TriggerBotDot.Position = Vector2.new(screenPos.X, screenPos.Y)
                    TriggerBotDot.Visible = Script.TriggerBot.Visualize
                    local mousePos = Camera.ViewportSize * 0.5
                    local distance = (mousePos - TriggerBotDot.Position).magnitude
                    if distance <= TriggerBotDot.Radius then
                        local activateTool = function()
                            playerTool:Activate()
                            TriggerBotDot.Color = Color3.fromRGB(255, 0, 0) -- Red
                        end
                        if Script.TriggerBot.UseDelay then
                            task.delay(Script.TriggerBot.Delay, activateTool)
                        else
                            activateTool()
                        end
                    else
                        TriggerBotDot.Color = MainColor -- OG
                    end
                else
                    TriggerBotDot.Visible = false
                end
            else
                TriggerBotDot.Visible = false
            end
        else
            TriggerBotDot.Visible = false
        end
    else
        TriggerBotDot.Visible = false
    end
end)

RunService.PostSimulation:Connect(function()
    if Target and Target.Character then
        if Script.TargetAim.HitPart.ClosestPart then
            local hitPartName = tostring(Deposit:GetClosestBodyPart(Target.Character))
            if Script.TargetAim.HitPart.ClosestMode == "Nearest Part" then
                InnalillahiMichaelJackson.Locals.HitPart = hitPartName
                InnalillahiMichaelJackson.Locals.AimPoint = Target.Character[hitPartName].Position
            elseif Script.TargetAim.HitPart.ClosestMode == "Nearest Point" then
                InnalillahiMichaelJackson.Locals.HitPart = hitPartName
                InnalillahiMichaelJackson.Locals.AimPoint = Deposit:GetClosestPoint(Target.Character[hitPartName])
            end
        else
            InnalillahiMichaelJackson.Locals.HitPart = Script.TargetAim.HitPart.Part
            local hitPart = Target.Character[InnalillahiMichaelJackson.Locals.HitPart]
            InnalillahiMichaelJackson.Locals.AimPoint = hitPart.Position
        end
		-- 
        local Position = workspace.CurrentCamera:WorldToViewportPoint(Target.Character[InnalillahiMichaelJackson.Locals.HitPart].Position)
        --
        if Script.Resolver.Enabled then
            offset = calculateResolverOffset(Target)
        end
        --
        if Script.TargetAim.Stuff.LookAt and Target.Character:FindFirstChild("LowerTorso") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(LocalPlayer.Character.HumanoidRootPart.CFrame.Position, Vector3.new(Target.Character.HumanoidRootPart.CFrame.X, LocalPlayer.Character.HumanoidRootPart.CFrame.Position.Y, Target.Character.HumanoidRootPart.CFrame.Z))
        end
        --
        if Script.TargetAim.Stuff.Spectate then
            Camera.CameraSubject = Target.Character
        else
            Camera.CameraSubject = LocalPlayer.Character
        end
        --
        if Script.Rage.Killbot.Enabled and (not Script.Rage.Killbot.BypassDC or (Script.Rage.Killbot.BypassDC and Target.Character.HumanoidRootPart.Position.Y >= -10000)) then
            if Script.TargetAim.LookAt == true then
                Script.TargetAim.LookAt = false
                wait()
                Script.TargetAim.LookAt = true
            end
            local strafe
            if Script.Rage.Killbot.Type == "Orbit" then
                local current_time = tick()
                strafe = CFrame.new(Target.Character.HumanoidRootPart.Position) * CFrame.Angles(0, 2 * math.pi * current_time * Script.Rage.Killbot.Speed % (2 * math.pi), 0) * CFrame.new(0, Script.Rage.Killbot.Height, Script.Rage.Killbot.Distance)
            else
                strafe = Target.Character.HumanoidRootPart.CFrame * CFrame.new(Deposit:RandomVectorThree(Script.Rage.Killbot.Randomization))
            end
            LocalPlayer.Character.HumanoidRootPart.CFrame = strafe
        end
        --
        local predicted_position = Position
        -- 
        if Script.Visuals.HighLight.Enabled then
			TargetChams.Parent = Target.Character
			TargetChams.FillColor =  Script.Visuals.HighLight.Fill
			TargetChams.OutlineColor = Script.Visuals.HighLight.OutLine
		else
		    TargetChams.Parent = nil
		end
		--
        if Script.Visuals.Dot.Enabled then
            Dot.Visible = predicted_position and true or false
            Dot.Position = Vector2.new(predicted_position.X, predicted_position.Y)
            Dot.Color = Script.Visuals.Dot.Color
            Dot.Radius = Script.Visuals.Dot.Size
        end
        --
        if Script.Visuals.Line.Enabled then
            local from_position = Camera:WorldToViewportPoint(LocalPlayer.Character.HumanoidRootPart.Position)
            Line.Visible = predicted_position and true or false
            Line.From = Vector2.new(from_position.X, from_position.Y)
            Line.To = Vector2.new(predicted_position.X, predicted_position.Y)
            Line.Color = Script.Visuals.Line.Color
            Line.Thickness = Script.Visuals.Line.Thickness
        end
        -- 
        if Script.Visuals.Line.Circle then
            local torso = Target.Character:FindFirstChild("UpperTorso") or Target.Character:FindFirstChild("Torso") -- Handle both R15 and R6 rigs
            if torso then
                TargetCircle.Visible = true
                TargetCircle.Position = torso.Position
                TargetCircle.Color = Script.Visuals.Line.Color
                TargetCircle.Radius = 2
                TargetCircle.Sides = 2
            else
                TargetCircle.Visible = false
            end
        else
            TargetCircle.Visible = false
        end
        --
        if Cursor.sticky then
            Cursor.mode = 'custom'
            Cursor.position = Vector2.new(Position.X, Position.Y)
        else
            Cursor.mode = crosshair_position
        end
    else
        Cursor.mode = crosshair_position
        --
        if Dot.Visible == true then
            Dot.Visible = false
        end
        --
        if Line.Visible == true then
            Line.Visible = false
        end
        --
        if TargetCircle.Visible == true then
            TargetCircle.Visible = false
        end
        --
        TargetChams.Parent = nil
        Camera.CameraSubject = LocalPlayer.Character
    end
end)

RunService.PostSimulation:Connect(function()
   if Script.TargetAim.Enabled and Script.TargetAim.Type == "Silent Aim" then
        Target = Deposit:GetClosestPlayerToCursor(Script.Visuals.FoV.Size+15)
    end
    --
    if Script.Rage.Exploits.AntiBag then
        LocalPlayer.Character["Christmas_Sock"]:Destroy()
    end
    --
    if Script.Rage.Exploits.AutoStomp then
        game.ReplicatedStorage.MainEvent:FireServer("Stomp")
    end
    --
    Deposit:CalculateAimAssistPredictedPosition()
end)

RunService.PostSimulation:Connect(function()
    if Script.TargetAim.Teleport.GrenadeTP and Target and Target.Character and workspace:FindFirstChild("Ignored") then
        if workspace.Ignored:FindFirstChild("Handle") then
            workspace.Ignored.Handle.Position = Target.Character[InnalillahiMichaelJackson.Locals.HitPart].Position + (Target.Character[InnalillahiMichaelJackson.Locals.HitPart].Velocity * Script.TargetAim.Prediction);
        end
    end;
end)

RunService.PostSimulation:Connect(function()
   -- // CFrame Desync
   if (Script.AntiAim.CSync.Enabled or Script.AntiAim.CSync.VoidSpam or Script.AntiAim.CSync.DestroyCheaters) and LocalPlayer.Character then
        old_hrp = LocalPlayer.Character.HumanoidRootPart.CFrame
        Radians += Script.AntiAim.CSync.TargetStrafe.Speed
        local attach = (Script.AntiAim.CSync.Attach and Target and Target.Character and Target.Character.HumanoidRootPart) or LocalPlayer.Character.HumanoidRootPart
        
        local cframe_position = {
            ["Custom"] = attach.CFrame * CFrame.new(Script.AntiAim.CSync.Custom.X, Script.AntiAim.CSync.Custom.Y, Script.AntiAim.CSync.Custom.Z),
            ["Random"] = attach.CFrame + Deposit:RandomVectorThree(Script.AntiAim.CSync.Randomize.Value),
            ["Target Strafe"] = attach.CFrame * CFrame.Angles(0, math.rad(Radians), 0) * CFrame.new(0, Script.AntiAim.CSync.TargetStrafe.Height, Script.AntiAim.CSync.TargetStrafe.Distance),
            ["Destroy Cheaters"] = attach.CFrame * CFrame.new(9e9, 0/0, math.huge),
            ["Void Spam"] = should_haalfi_destroy and attach.CFrame * CFrame.new(0, 0/1, math.huge) or attach.CFrame
        }
    
        local csync_type = Script.AntiAim.CSync.VoidSpam and cframe_position["Void Spam"] or Script.AntiAim.CSync.DestroyCheaters and cframe_position["Destroy Cheaters"] or cframe_position[Script.AntiAim.CSync.Type]
    
        LocalPlayer.Character.HumanoidRootPart.CFrame = csync_type
    
        if Script.AntiAim.CSync.Visualize.Enabled and Script.AntiAim.CSync.Visualize.Type == "Line" and typeof(csync_type) == "CFrame" then
            local hrp_pos = workspace.CurrentCamera:WorldToViewportPoint(attach.Position)
            local desynced_pos = workspace.CurrentCamera:WorldToViewportPoint(csync_type.Position)
    
            CFrameDesyncTracer.Visible = true
            CFrameDesyncTracer.From = Vector2.new(hrp_pos.X, hrp_pos.Y)
            CFrameDesyncTracer.To = Vector2.new(desynced_pos.X, desynced_pos.Y)
            CFrameDesyncTracer.Color = Script.AntiAim.CSync.Visualize.Color
        else
            CFrameDesyncTracer.Visible = false
        end
    
        if Script.AntiAim.CSync.Visualize.Enabled and Script.AntiAim.CSync.Visualize.Type == "Dot" and typeof(csync_type) == "CFrame" then
            local desynced_pos = workspace.CurrentCamera:WorldToViewportPoint(csync_type.Position)
    
            CFrameDesyncDot.Visible = true
            CFrameDesyncDot.Color = Script.AntiAim.CSync.Visualize.Color
            CFrameDesyncDot.Position = desynced_pos
            CFrameDesyncDot.Radius = 10
        else
            CFrameDesyncDot.Visible = false
        end
        
        if Script.AntiAim.CSync.Visualize.Enabled and Script.AntiAim.CSync.Visualize.Type == "Character" then 
             bodyClone:SetPrimaryPartCFrame(LocalPlayer.Character.HumanoidRootPart.CFrame)    
             visualizeChams.FillColor = Script.AntiAim.CSync.Visualize.Color
             visualizeChams.OutlineColor = Color3.new(1,1,1)
        else
             bodyClone:SetPrimaryPartCFrame(CFrame.new(9999, 9999, 9999))    
        end          
    
        RunService.RenderStepped:Wait()
    
        LocalPlayer.Character.HumanoidRootPart.CFrame = old_hrp
    else
        CFrameDesyncTracer.Visible = false
        CFrameDesyncDot.Visible = false
        bodyClone:SetPrimaryPartCFrame(CFrame.new(9999, 9999, 9999))    
    end
    
    --// FFlag Desync
    if Script.AntiAim.FFlagDesync.Enabled then
        for FFlag, _ in pairs(Script.AntiAim.FFlagDesync.FFlags) do
            local Value = Script.AntiAim.FFlagDesync.Amount
            setfflag(FFlag, tostring(Value))
    
            RunService.RenderStepped:Wait()
            if Script.AntiAim.FFlagDesync.SetNew then
                setfflag(FFlag, tostring(Script.AntiAim.FFlagDesync.SetNewAmount))
            end
        end
    end
    
    --// Network Desync
    if Script.AntiAim.Network.Enabled then
        local NetworkTickInterval = (Script.AntiAim.Network.Amount / math.pi) / 10000
        local MoveDirection = LocalPlayer.Character.Humanoid.MoveDirection.Magnitude > 0
    
        if (tick() - InnalillahiMichaelJackson.Locals.NetworkPreviousTick) >= NetworkTickInterval or (Script.AntiAim.Network.WalkingCheck and MoveDirection) then
            InnalillahiMichaelJackson.Locals.NetworkShouldSleep = not InnalillahiMichaelJackson.Locals.NetworkShouldSleep
            InnalillahiMichaelJackson.Locals.NetworkPreviousTick = tick()
            sethiddenproperty(LocalPlayer.Character.HumanoidRootPart, "NetworkIsSleeping", InnalillahiMichaelJackson.Locals.NetworkShouldSleep)
        end
    end
end)

RunService.PostSimulation:Connect(function()
    if Script.AntiAim.VelocitySpoofer.Enabled then
        local velocity = LocalPlayer.Character.HumanoidRootPart.Velocity
        if Script.AntiAim.VelocitySpoofer.Type == "Custom" then
            LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(Script.AntiAim.VelocitySpoofer.Yaw, Script.AntiAim.VelocitySpoofer.Pitch, Script.AntiAim.VelocitySpoofer.Roll) 
            RunService.RenderStepped:Wait()
            LocalPlayer.Character.HumanoidRootPart.Velocity = velocity
        elseif Script.AntiAim.VelocitySpoofer.Type == "Pred Multiplier" then
            LocalPlayer.Character.HumanoidRootPart.Velocity = velocity * Vector3.new(Script.AntiAim.VelocitySpoofer.Multiplier, Script.AntiAim.VelocitySpoofer.Multiplier, Script.AntiAim.VelocitySpoofer.Multiplier) 
            RunService.RenderStepped:Wait()
            LocalPlayer.Character.HumanoidRootPart.Velocity = velocity
        elseif Script.AntiAim.VelocitySpoofer.Type == "Sky" then
            LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0, Script.AntiAim.VelocitySpoofer.Roll, 0) 
            RunService.RenderStepped:Wait()
            LocalPlayer.Character.HumanoidRootPart.Velocity = velocity 
        elseif Script.AntiAim.VelocitySpoofer.Type == "Underground" then
            LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0, -Script.AntiAim.VelocitySpoofer.Roll, 0) 
            RunService.RenderStepped:Wait()
            LocalPlayer.Character.HumanoidRootPart.Velocity = velocity
        elseif Script.AntiAim.VelocitySpoofer.Type == "Shake" then
            LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(math.random() * Script.AntiAim.VelocitySpoofer.ShakeValue - Script.AntiAim.VelocitySpoofer.ShakeValue / 2, 0, math.random() * Script.AntiAim.VelocitySpoofer.ShakeValue - Script.AntiAim.VelocitySpoofer.ShakeValue / 2) 
            RunService.RenderStepped:Wait()
            LocalPlayer.Character.HumanoidRootPart.Velocity = velocity
        elseif Script.AntiAim.VelocitySpoofer.Type == "Pred Breaker" then
            LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0) 
            RunService.RenderStepped:Wait()
            LocalPlayer.Character.HumanoidRootPart.Velocity = velocity
        end
    end
end)
--
local AimViewerLine = YunDrawingApi:New3DLine(); AimViewerLine.Visible = false; AimViewerLine.Color = Color3.new(255, 255, 255); AimViewerLine.Thickness = 1;

RunService.PostSimulation:Connect(function()
    if Script.AntiAim.VelocitySpoofer.AimViewer.Enabled and Target then
        AimViewerLine.Color = Script.AntiAim.VelocitySpoofer.AimViewer.Color
        AimViewerLine.Thickness = Script.AntiAim.VelocitySpoofer.AimViewer.Thickness
        AimViewerLine.From = Target.Character.Head.Position
        AimViewerLine.To = Target.Character.BodyEffects["MousePos"].Value
        AimViewerLine.Visible = true
    else
        AimViewerLine.Visible = false
    end
end)

task.spawn(function()
	while task.wait(0.1) do
		should_haalfi_destroy = not should_haalfi_destroy;
	end;
end);

function refreshGrip(tool)
    tool.Parent = LocalPlayer.Backpack;
    tool.Parent = LocalPlayer.Character;
 end

function setPosition(tool, pos, oldPos)
    tool.GripPos = pos
    tool.Default.Transparency = 1
    refreshGrip(tool)
    task.wait(0.03)
    tool.GripPos = oldPos
    tool.Default.Transparency = 0
    refreshGrip(tool)
 end
   
function bulletTeleport(character)
   local equipped, equippedtool, oldPos;

   local function toolActivated()
      if bullettp and equippedtool then
         if Target then
               local getPos = LocalPlayer.Character.HumanoidRootPart.CFrame:PointToObjectSpace(Target.Character.HumanoidRootPart.Position);
               local setPos = Vector3.new(-getPos.Z, 0, getPos.X);
               setPosition(equippedtool, setPos, oldPos);
         end;
      end
   end
   
   local function childAdded(tool)
      if tool:IsA("Tool") and bullettp then
         equippedtool = tool;
         oldPos = tool.GripPos;
         equipped = tool.Activated:Connect(toolActivated);
      end
   end
   
   local function childRemoved(tool)
      if tool:IsA("Tool") then
         equippedtool = nil;
         if equipped then
               equipped:Disconnect();
         end
      end
   end

   character.ChildAdded:Connect(childAdded);
   character.ChildRemoved:Connect(childRemoved);
end

pcall(bulletTeleport, LocalPlayer.Character)

do -- // hit detection
    local function FindTargetOnPart(Part)
        local Target,HitPart = nil,nil
        local Distance = 2

        for _,Player in pairs(game.Players:GetPlayers()) do
            if Player == LocalPlayer then continue end

            local Char = Player.Character
            local Root = Char and Char:FindFirstChild("HumanoidRootPart")

            for _,Obj in pairs(Char:GetChildren()) do
                if not Obj:IsA("BasePart") then continue end
                local Mag = (Obj.Position - Part.Position).Magnitude
                if Mag < Distance then
                    Distance = Mag
                    Target = Player
                    HitPart = Obj
                end
            end
        end

        return Target,HitPart
    end

    local function SirenAdded(Obj)
        local Character = LocalPlayer.Character
        local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")

        local function VerifyBullet(obj)
            return (obj.Name == 'BULLET_RAYS' or obj.Name == 'Part' or obj.Name:lower():find('bullet') or obj:WaitForChild('Attachment', 1) or obj:WaitForChild('GunBeam', 1)) and obj
        end

        local PlayerChecks = {PlayerGun = false}
        local BulletRay = VerifyBullet(Obj)
    
        if BulletRay and RootPart then
            local Mag = (RootPart.Position - BulletRay.Position).Magnitude
            if Mag <= 13 then PlayerChecks.PlayerGun = true end

            if PlayerChecks.PlayerGun then
                local GunBeam = BulletRay:WaitForChild("GunBeam") or BulletRay:WaitForChild("gb")
                
                local Attachment0 = GunBeam.Attachment0 -- closest to player
                local Attachment1 = GunBeam.Attachment1 -- mouse position
    
                if Script.Visuals.BulletTracers.Enabled and Script.Visuals.BulletTracers.Mode == "Global" then
                    GunBeam:Destroy()
                    if Script.Visuals.BulletTracers.Type == "Beam" then
                        Deposit:CreateBeam(BulletRay.Position, Attachment1.WorldCFrame.Position, Script.Visuals.BulletTracers.Color, Script.Visuals.BulletTracers.Color, Script.Visuals.BulletTracers.Duration, Script.Visuals.BulletTracers.Fade, Script.Visuals.BulletTracers.FadeDuration)
                    else
                        Deposit:CreateDrawingBeam(BulletRay.Position, Attachment1.WorldCFrame.Position)
                    end
                end
                
                if Script.Visuals.BulletImpacts.Enabled then
                    Deposit:CreateImpact(Script.Visuals.BulletImpacts.Color, Script.Visuals.BulletImpacts.Width, Script.Visuals.BulletImpacts.Fade, Script.Visuals.BulletImpacts.FadeDuration, Script.Visuals.BulletImpacts.Duration, Attachment1.WorldPosition)
                end                
                
                if Script.Visuals.Hit_Detection.Enabled then
                    local Part = Instance.new('Part', workspace)
                    Part.Anchored = true
                    Part.Size = Vector3.new(0.25, 0.25, 0.25)
                    Part.Position = Attachment1.WorldCFrame.Position
                    Part.Material = Enum.Material.Neon
                    Part.Color = MainColor
                    Part.CanCollide = false
                    Part.Transparency = 1
    
                    Debris:AddItem(Part,2)
    
                    local Target,HitPart = FindTargetOnPart(Part)
                    if Target then
                        if Script.Visuals.Hit_Detection.Notify then
                            Notifications:Notify('[<font color="#'..tostring(MainColor:ToHex())..'">deposit</font>] Hitted <font color="#'..tostring(MainColor:ToHex())..'">'..tostring(Target.DisplayName)..'</font> in the <font color="#'..tostring(MainColor:ToHex())..'">'..tostring(HitPart)..'</font>', 5)
                        end

                        if Script.Visuals.Hit_Detection.Clone then
                            Deposit:CloneCharacter(Target,0.5,MainColor,"Neon",5)
                        end
                        
                        if Script.Visuals.Hit_Detection.Sound then
                            local Sound = Deposit:Instance("Sound", {
                                SoundId = InnalillahiMichaelJackson.HitSounds[Script.Visuals.Hit_Detection.HitSound],
                                Volume = 1,
                                Parent = Obj
                            })
                            Sound:Play()
                        end
                    end
                end
            end
        end
    end

    if bullet_path then bullet_path.ChildAdded:Connect(SirenAdded) end
end

task.spawn(function()
    while RunService.RenderStepped:Wait() do
        if Script.Rage.AutoArmor.Enabled then 
			if LocalPlayer.Character.BodyEffects.Armor.Value == Script.Rage.AutoArmor.BuyOn then 
				local Old_Ammo_Position = LocalPlayer.Character.HumanoidRootPart.CFrame
				-- 
				LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Ignored.Shop["[High-Medium Armor] - $2163"].Head.CFrame
				wait(0.1)
				fireclickdetector(workspace.Ignored.Shop["[High-Medium Armor] - $2163"].ClickDetector)
				wait(0.1)
				if LocalPlayer.Character.BodyEffects.Armor.Value > 0 then 
					LocalPlayer.Character.HumanoidRootPart.CFrame = Old_Ammo_Position
				else 
					fireclickdetector(workspace.Ignored.Shop["[High-Medium Armor] - $2163"].ClickDetector)
				end 
			end  
		end  
		--
        if LocalPlayer.Character then
            if getgenv().Loop then 
                getgenv().Loop:Disconnect()
            end
            --
            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
            if tool and Script.Visuals.BulletTracers.Enabled and Script.Visuals.BulletTracers.Mode == "Local" and tool:FindFirstChild("Ammo") then
                getgenv().Loop = tool.Ammo.Changed:Connect(function()
                    if tool.Ammo.Value ~= tool.MaxAmmo.Value then
                        if Script.Visuals.BulletTracers.Type == "Beam" then
                            Deposit:CreateBeam(tool.Handle.Position, LocalPlayer.Character.BodyEffects.MousePos.Value, Script.Visuals.BulletTracers.Color, Script.Visuals.BulletTracers.Color, Script.Visuals.BulletTracers.Duration, Script.Visuals.BulletTracers.Fade, Script.Visuals.BulletTracers.FadeDuration)
                       else
                            Deposit:CreateDrawingBeam(tool.Handle.Position, LocalPlayer.Character.BodyEffects.MousePos.Value)
                       end
                        --
                        RunService.RenderStepped:Wait()
                        --
                        for _,v in pairs(Workspace.Ignored:GetChildren()) do
                            if v:IsA("Part") and v.Name == bullet_name then
                                v:Destroy()
                            end
                        end
                    end
                end)
            end
        end
    end
end)
--
if game:GetService("Workspace"):FindFirstChild("Ignored") then
    game:GetService("Workspace").Ignored.ChildAdded:Connect(function(obj)
        if obj.Name == "Launcher" and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and Script.Rage.Exploits.AntiRPG then
            InnalillahiMichaelJackson.Locals.AntiRpg = true
            local connection
            connection = RunService.PostSimulation:Connect(function()
                if ((obj.Position - LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position).Magnitude) < 20 then
                    connection:Disconnect()
                    local time = 0
                    local unnamed
                    unnamed = RunService.PostSimulation:Connect(function()
                        if time < 1 then
                            time = time + (1 / 60)
                            InnalillahiMichaelJackson.Locals.Original[1] = LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame
                            LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame = LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame + Vector3.new(math.random(-1500, 1500), math.random(-1500, 1500), math.random(-1500, 1500))
                            RunService.RenderStepped:Wait()
                            LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame = InnalillahiMichaelJackson.Locals.Original[1]
                        else
                            unnamed:Disconnect()
                            time = 0
                            LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame = InnalillahiMichaelJackson.Locals.Original[1]
                            InnalillahiMichaelJackson.Locals.AntiRpg = false
                        end
                    end)
                end
            end)
        end
    end)
end
--
if game:GetService("Workspace"):FindFirstChild("Ignored") then
    game:GetService("Workspace").Ignored.ChildAdded:Connect(function(object)
        if (Script.TargetAim.Enabled and Script.TargetAim.Teleport.RocketTP and 
            Target and 
            Target.Character and 
            (object.Name == "Model" or object.Name == "GrenadeLauncherAmmo")) then
            
            local SkibidiGrenadeLauncher = object.Name == "GrenadeLauncherAmmo"
            local target = Target
            local part = SkibidiGrenadeLauncher and object:WaitForChild("Main") or object:WaitForChild("Launcher")
            
            part.CFrame = CFrame.new(1,1,1)
            
            if not SkibidiGrenadeLauncher then
                part.BodyVelocity:Destroy()
                part.TouchInterest:Destroy()
            end
            
            local connection
            connection = RunService.PostSimulation:Connect(function()
                if target and target.character then
                    part.CFrame = target.Character.HumanoidRootPart.CFrame
                    part.Velocity = Vector3.new(0, 0.001, 0)
                end
            end)
            
            object.Destroying:Connect(function()
                connection:Disconnect()
            end)
        end
    end)
end

do -- // Hooking
    Script.Hooks[1] = hookmetamethod(game, "__namecall", function(Self, ...)
        local Args = {...}
        local Method = tostring(getnamecallmethod())
        if not checkcaller() and Method == "FireServer" then
            for i, Arg in pairs(Args) do
                if typeof(Arg) == "Vector3" then
                --
                InnalillahiMichaelJackson.Locals.AntiAimViewer.MouseRemote = Self
                InnalillahiMichaelJackson.Locals.AntiAimViewer.MouseRemoteFound = true
                InnalillahiMichaelJackson.Locals.AntiAimViewer.MouseRemoteArgs = Args
                InnalillahiMichaelJackson.Locals.AntiAimViewer.MouseRemotePositionIndex = i
                --
                    if Target and Script.TargetAim.Enabled and Script.TargetAim.Method == "FireServer" and not Script.Resolver.AntiAimViewer then
                        Args[i] = InnalillahiMichaelJackson.Locals.AimPoint + (Script.Resolver.Enabled and offset or Target.Character[InnalillahiMichaelJackson.Locals.HitPart].Velocity * Script.TargetAim.Prediction)
                    end
                    return Script.Hooks[1](Self, unpack(Args))
                end
            end
        end
        return Script.Hooks[1](Self, ...)
    end)
    --
    Script.Hooks[2] = hookmetamethod(game, "__index", function(self, property)
        if not checkcaller() then
            if InnalillahiMichaelJackson.Locals.AntiRpg and InnalillahiMichaelJackson.Locals.Original[1] and property == "CFrame" and self.Name == "HumanoidRootPart" and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid") then
                return InnalillahiMichaelJackson.Locals.Original[1]
            end
        end
        return Script.Hooks[2](self, property)
    end)
    
    Script.Hooks[3] = hookmetamethod(LocalPlayer:GetMouse(), "__index", newcclosure(function(self,index)
        if index == "Hit" and Script.TargetAim.Method == "Spoof Mouse" and Target.Character ~= nil and Script.TargetAim.Enabled then
            local position = InnalillahiMichaelJackson.Locals.AimPoint + (Script.Resolver.Enabled and offset or Target.Character[InnalillahiMichaelJackson.Locals.HitPart].Velocity * Script.TargetAim.Prediction)
            return position
        end
        return Script.Hooks[3](self,index)
    end))
    
	Script.Hooks[4] = hookmetamethod(game, "__index", LPH_NO_VIRTUALIZE(function(self, key)
		if not checkcaller() then
			if key == "CFrame" and LocalPlayer.Character and self == LocalPlayer.Character.HumanoidRootPart and ((Script.AntiAim.CSync.Enabled) or (Script.AntiAim.CSync.DestroyCheaters) or (Script.AntiAim.CSync.VoidSpam)) and old_hrp ~= nil and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character:FindFirstChild("Humanoid").Health > 0 then
				return old_hrp
			end
		end 
		return Script.Hooks[4](self, key)
	end))
end
--
connection = function(Character)
    Character.ChildAdded:Connect(function(Tool)
        if Tool:IsA('Tool') then
            Tool.Activated:Connect(function()
                Deposit:AimViewerCalculator()
            end)
        end
    end)
end

game.Players.LocalPlayer.CharacterAdded:Connect(connection)
connection(game.Players.LocalPlayer.Character)
--
local Attachment = Instance.new("Attachment")
local swirl = Instance.new("ParticleEmitter")
swirl.Name = "swirl"
swirl.Lifetime = NumberRange.new(2, 2)
swirl.SpreadAngle = Vector2.new(-360, 360)
swirl.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5006226, 0.5), NumberSequenceKeypoint.new(1, 1)})
swirl.LightEmission = 1
swirl.Color = ColorSequence.new(Color3.fromRGB(66,60,255))
swirl.VelocitySpread = -360
swirl.Squash = NumberSequence.new(0)
swirl.Speed = NumberRange.new(0.01, 0.01)
swirl.Size = NumberSequence.new(7)
swirl.ZOffset = -1
swirl.ShapeInOut = Enum.ParticleEmitterShapeInOut.InAndOut
swirl.Rate = 150
swirl.Texture = "rbxassetid://10558425570"
swirl.RotSpeed = NumberRange.new(200, 200)
swirl.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
swirl.Parent = Attachment
--
local HealingWave1 = Instance.new("ParticleEmitter")
HealingWave1.Name = "Healing Wave 1"
HealingWave1.Lifetime = NumberRange.new(1, 1)
HealingWave1.SpreadAngle = Vector2.new(10, -10)
HealingWave1.LockedToPart = true
HealingWave1.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.1702454, 0.7, 0.014881), NumberSequenceKeypoint.new(0.2254601, 0.03125, 0.03125), NumberSequenceKeypoint.new(0.2852761, 0), NumberSequenceKeypoint.new(0.702454, 0), NumberSequenceKeypoint.new(0.8374233, 0.9125, 0.0601461), NumberSequenceKeypoint.new(1, 1)})
HealingWave1.LightEmission = 0.4
HealingWave1.Color = ColorSequence.new(Color3.fromRGB(234, 8, 255))
HealingWave1.VelocitySpread = 10
HealingWave1.Speed = NumberRange.new(3, 6)
HealingWave1.Brightness = 10
HealingWave1.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 3.0624998, 1.8805969), NumberSequenceKeypoint.new(0.6420546, 1.9999999, 1.7619393), NumberSequenceKeypoint.new(1, 0.7499999, 0.7499999)})
HealingWave1.Rate = 10
HealingWave1.Texture = "rbxassetid://8047533775"
HealingWave1.RotSpeed = NumberRange.new(200, 400)
HealingWave1.Rotation = NumberRange.new(-180, 180)
HealingWave1.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
HealingWave1.Parent = Attachment

local HealingWave2 = Instance.new("ParticleEmitter")
HealingWave2.Name = "Healing Wave 2"
HealingWave2.Lifetime = NumberRange.new(1, 1)
HealingWave2.SpreadAngle = Vector2.new(10, -10)
HealingWave2.LockedToPart = true
HealingWave2.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.2254601, 0.03125, 0.03125), NumberSequenceKeypoint.new(0.6288344, 0.25625, 0.0593491), NumberSequenceKeypoint.new(0.8374233, 0.9125, 0.0601461), NumberSequenceKeypoint.new(1, 1)})
HealingWave2.LightEmission = 1
HealingWave2.Color = ColorSequence.new(Color3.fromRGB(238, 3, 255))
HealingWave2.VelocitySpread = 10
HealingWave2.Speed = NumberRange.new(3, 5)
HealingWave2.Brightness = 10
HealingWave2.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 3.125), NumberSequenceKeypoint.new(0.4165329, 1.3749999, 1.3749999), NumberSequenceKeypoint.new(1, 0.9375, 0.9375)})
HealingWave2.Rate = 10
HealingWave2.Texture = "rbxassetid://8047796070"
HealingWave2.RotSpeed = NumberRange.new(100, 300)
HealingWave2.Rotation = NumberRange.new(-180, 180)
HealingWave2.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
HealingWave2.Parent = Attachment

local Sparks = Instance.new("ParticleEmitter")
Sparks.Name = "Sparks"
Sparks.Lifetime = NumberRange.new(0.3, 1)
Sparks.SpreadAngle = Vector2.new(180, -180)
Sparks.LightEmission = 1
Sparks.Color = ColorSequence.new(Color3.fromRGB(255, 21, 255))
Sparks.Drag = 3
Sparks.VelocitySpread = 180
Sparks.Speed = NumberRange.new(5, 15)
Sparks.Brightness = 10
Sparks.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.14687, 0.4374999, 0.1875001), NumberSequenceKeypoint.new(1, 0)})
Sparks.Acceleration = Vector3.new(0, 3, 0)
Sparks.ZOffset = -1
Sparks.Rate = 30
Sparks.Texture = "rbxassetid://8611887361"
Sparks.RotSpeed = NumberRange.new(-30, 30)
Sparks.Orientation = Enum.ParticleOrientation.VelocityParallel
Sparks.Parent = Attachment

local StarSparks = Instance.new("ParticleEmitter")
StarSparks.Name = "Star Sparks"
StarSparks.Lifetime = NumberRange.new(1, 1)
StarSparks.SpreadAngle = Vector2.new(180, -180)
StarSparks.LightEmission = 1
StarSparks.Color = ColorSequence.new(Color3.fromRGB(226, 60, 255))
StarSparks.Drag = 3
StarSparks.VelocitySpread = 180
StarSparks.Speed = NumberRange.new(5, 10)
StarSparks.Brightness = 10
StarSparks.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.1492777, 0.6874996, 0.6874996), NumberSequenceKeypoint.new(1, 0)})
StarSparks.Acceleration = Vector3.new(0, 3, 0)
StarSparks.ZOffset = 2
StarSparks.Texture = "rbxassetid://8611887703"
StarSparks.RotSpeed = NumberRange.new(-30, 30)
StarSparks.Rotation = NumberRange.new(-30, 30)
StarSparks.Parent = Attachment
--
local function setupParticles()
    local player = Players.LocalPlayer
    local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    
    if humanoidRootPart and not Attachment.Parent then
        Attachment.Parent = humanoidRootPart -- Ensure attachment is parented
    end
    
    if Script.Visuals.SelfESP.Aura.Enabled then
        if Script.Visuals.SelfESP.Aura.Type == "Swirl" then
            swirl.Enabled = true
            StarSparks.Enabled = false
            Sparks.Enabled = false
            HealingWave1.Enabled = false
            HealingWave2.Enabled = false
        elseif Script.Visuals.SelfESP.Aura.Type == "Heal" then
            swirl.Enabled = false
            StarSparks.Enabled = true
            Sparks.Enabled = true
            HealingWave1.Enabled = true
            HealingWave2.Enabled = true
        end
    else
        swirl.Enabled = false
        StarSparks.Enabled = false
        Sparks.Enabled = false
        HealingWave1.Enabled = false
        HealingWave2.Enabled = false
    end
end
--
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/jamkless/Linoria_Mobile/refs/heads/main/lib.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Mc4121ban/Linoria-Library-Mobile/refs/heads/main/Gui%20Lib%20%5BThemeManager%5D"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Mc4121ban/Linoria-Library-Mobile/refs/heads/main/Gui%20Lib%20%5BSaveManager%5D"))()
local Window = Library:CreateWindow({
    Title = 'Deposit<font color="rgb(255,105,180)">.lua</font>',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Frame.Size = UDim2.new(0, 100, 0, 50)
Frame.Position = UDim2.new(1, -120, 0, 0)

local TextButton = Instance.new("TextButton")
TextButton.Parent = Frame
TextButton.BackgroundColor3 = Color3.fromRGB(0, 0, 200)
TextButton.BackgroundTransparency = 1.000
TextButton.Size = UDim2.new(1, 0, 1, 0)
TextButton.Font = Enum.Font.SourceSans
TextButton.Text = ">_<"
TextButton.TextColor3 = Color3.fromRGB(0, 0, 0)
TextButton.TextScaled = true
TextButton.TextSize = 30
TextButton.TextStrokeColor3 = Color3.fromRGB(0, 0, 200)
TextButton.TextStrokeTransparency = 0.000
TextButton.TextWrapped = true
TextButton.MouseButton1Down:Connect(function() task.spawn(Library.Toggle) end)

local UITextSizeConstraint = Instance.new("UITextSizeConstraint")
UITextSizeConstraint.Parent = TextButton
UITextSizeConstraint.MaxTextSize = 30

local playeruh = game.Players.LocalPlayer
local function onCharacterAdded(character)
    ScreenGui.Parent = playeruh.PlayerGui
end
local function connectCharacterAdded()
    playeruh.CharacterAdded:Connect(onCharacterAdded)
end
connectCharacterAdded()
playeruh.CharacterRemoving:Connect(function() ScreenGui.Parent = nil end)

local Tabs = {
    Combat = Window:AddTab("Aiming"),
    Rage = Window:AddTab("Rage"),
    Visuals = Window:AddTab("Visuals"),
    AntiAim = Window:AddTab("Anti Aim"),
    ['UI Settings'] = Window:AddTab('Options')
}

local Sections = {
    Combat = {
        Main = Tabs.Combat:AddLeftGroupbox("Target Aim"),
        Resolver = Tabs.Combat:AddLeftGroupbox("Resolver"),
        Checks = Tabs.Combat:AddRightGroupbox("Checks"),
        AimAssist = Tabs.Combat:AddRightGroupbox("Aim Assist"),
        TriggerBot = Tabs.Combat:AddRightGroupbox("Trigger Bot")
     },
     Rage = {
        CFSpeed = Tabs.Rage:AddLeftGroupbox("CFrame Speed"),
        AutoArmor = Tabs.Rage:AddLeftGroupbox("Auto Armor"),
        Exploits = Tabs.Rage:AddLeftGroupbox("Exploits"),
        AutoBuy = Tabs.Rage:AddRightGroupbox("Auto Buy"),
        Teleport = Tabs.Rage:AddRightGroupbox("Teleport"),
        Killbot = Tabs.Rage:AddRightGroupbox("Killbot")
     },
     Visuals = {
    	ESP = Tabs.Visuals:AddLeftGroupbox("Esp"),
        SelfESP = Tabs.Visuals:AddLeftGroupbox("Self ESP"),
    	Crosshair = Tabs.Visuals:AddRightGroupbox("Crosshair"),
        OnHit = Tabs.Visuals:AddRightGroupbox("Hit Detection"),
        BulletTracers = Tabs.Visuals:AddRightGroupbox("Bullet Tracers"),
        BulletImpacts = Tabs.Visuals:AddRightGroupbox("Bullet Impacts"),
    },
    AntiAim = {
        CFrameDesync = Tabs.AntiAim:AddRightGroupbox("CFrame Desync"),
        FFlag = Tabs.AntiAim:AddRightGroupbox("FFlag Desync"),
        VelocitySpoofer = Tabs.AntiAim:AddLeftGroupbox("Velocity Spoofer"),
        Network = Tabs.AntiAim:AddLeftGroupbox("Network")
    },
}

do
    -- Target Aim Section
    Sections.Combat.Main:AddToggle("LockEnabled", {
        Text = "Enabled",
        Default = Script.TargetAim.Enabled,
        Tooltip = nil,
        Callback = function(W)
            Script.TargetAim.Enabled = W
        end
    }):AddKeyPicker("TargetAimKeybind", {
          Default = "b",
          SyncToggleState = true,
          Mode = "Toggle",
          Text = "Target Aim",
          NoUI = false,
          Callback = function()
            local combatSettings = Script -- Ensure combatSettings is properly set up
            if combatSettings.TargetAim.Enabled then
                if string.lower(combatSettings.TargetAim.Type) == "target aim" then
                    if not Target then
                        Target = Deposit:GetClosestPlayerToCursor(math.huge)
                        Notifications:Notify('[<font color="#' .. MainColor:ToHex() .. '">deposit</font>] Target: ' .. tostring(Target), 1.5)
                    else
                        Target = nil
                        Notifications:Notify('[<font color="#' .. tostring(MainColor:ToHex()) .. '">deposit</font>] Unlocked', 1.5)
                    end
                end
            end
        end
     })

    Sections.Combat.Main:AddButton("Load Button", function()
        local BladLock = Instance.new("ScreenGui")
        BladLock.Name = "BladLock"
        BladLock.Parent = game.CoreGui
        BladLock.ZIndexBehavior = Enum.ZIndexBehavior.Global

        local Frame = Instance.new("Frame")
        Frame.Parent = BladLock
        Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Frame.BorderSizePixel = 0
        Frame.Position = UDim2.new(0.133798108, 0, 0.20107238, 0)
        Frame.Size = UDim2.new(0, 80, 0, 70)
        Frame.Active = true
        Frame.Draggable = true

        local Logo = Instance.new("ImageLabel")
        Logo.Name = "Logo"
        Logo.Parent = Frame
        Logo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Logo.BackgroundTransparency = 5.000
        Logo.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Logo.BorderSizePixel = 0
        Logo.Position = UDim2.new(0.326732665, 0, 0, 0)
        Logo.Size = UDim2.new(0, 43, 0, 43)
        Logo.ImageTransparency = 0.200

        local TextButton = Instance.new("TextButton")
        TextButton.Parent = Frame
        TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TextButton.BackgroundTransparency = 5.000
        TextButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TextButton.BorderSizePixel = 0
        TextButton.Position = UDim2.new(0.0792079195, 0, 0.18571429, 0)
        TextButton.Size = UDim2.new(0, 80, 0, 44)
        TextButton.Font = Enum.Font.SourceSansSemibold
        TextButton.Text = "Deposit"
        TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        TextButton.TextScaled = true
        TextButton.TextSize = 14.000
        TextButton.TextWrapped = true

        local UICorner = Instance.new("UICorner")
        UICorner.Parent = Frame

        local state = true
        TextButton.MouseButton1Click:Connect(function()
            local combatSettings = Script -- Ensure combatSettings is properly set up
            if combatSettings.TargetAim.Enabled then
                if string.lower(combatSettings.TargetAim.Type) == "target aim" then
                    if not Target then
                        TextButton.Text = "Deposit ON"
                        Target = Deposit:GetClosestPlayerToCursor(math.huge)
                        Notifications:Notify('[<font color="#' .. MainColor:ToHex() .. '">deposit</font>] Target: ' .. tostring(Target), 1.5)
                    else
                        Target = nil
                        TextButton.Text = "Deposit OFF"
                        Notifications:Notify('[<font color="#' .. tostring(MainColor:ToHex()) .. '">deposit</font>] Unlocked', 1.5)
                    end
                end
            end
        end)

        local UICorner2 = Instance.new("UICorner")
        UICorner2.Parent = TextButton
    end)
    
    Sections.Combat.Main:AddButton("Load Tool", function()
        local Tool = Instance.new("Tool")
        Tool.RequiresHandle = false
        Tool.Name = "Silent Aim Tool"
        Tool.Parent = game.Players.LocalPlayer.Backpack
        
        local player = game.Players.LocalPlayer
        
        local function connectCharacterAdded()
            player.CharacterAdded:Connect(onCharacterAdded)
        end
        
        connectCharacterAdded()
        
        player.CharacterRemoving:Connect(function()
             Tool.Parent = game.Players.LocalPlayer.Backpack
         end)
         
         Tool.Activated:Connect(function()
            local combatSettings = Script -- Ensure combatSettings is properly set up
            if combatSettings.TargetAim.Enabled then
                if string.lower(combatSettings.TargetAim.Type) == "target aim" then
                    if not Target then
                        Target = Deposit:GetClosestPlayerToCursor(math.huge)
                        Notifications:Notify('[<font color="#' .. MainColor:ToHex() .. '">deposit</font>] Target: ' .. tostring(Target), 1.5)
                    else
                        Target = nil
                        Notifications:Notify('[<font color="#' .. tostring(MainColor:ToHex()) .. '">deposit</font>] Unlocked', 1.5)
                    end
                end
            end
         end)
    end)
    
    Sections.Combat.Main:AddDropdown("TargetAimType", {
        Text = "Type",
        Values = {"Target Aim", "Silent Aim"},
        Default = "Target Aim",
        Multi = false,
        Callback = function(W)
            Script.TargetAim.Type = W
        end
    })
    
    if not table.find(dahood_ids,game.PlaceId) then
        Sections.Combat.Main:AddToggle("BulletTP",{
            Text="Bullet TP",
            Default=bullettp,
            Tooltip=nil,
            Callback=function(W)
                bullettp=W
            end
        })
    else
        Sections.Combat.Main:AddToggle("GrenadeTP",{
            Text="Grenade TP",
            Default=Script.TargetAim.Teleport.GrenadeTP,
            Tooltip=nil,
            Callback=function(W)
                Script.TargetAim.Teleport.GrenadeTP=W
            end
        })
        
        Sections.Combat.Main:AddToggle("RocketTP",{
            Text="Rocket TP",
            Default=Script.TargetAim.Teleport.RocketTP,
            Tooltip=nil,
            Callback=function(W)
                Script.TargetAim.Teleport.RocketTP=W
            end
        })
    end
    
    Sections.Combat.Main:AddToggle("LookAt", {
        Text = "Face Target",
        Default = Script.TargetAim.Stuff.LookAt,
        Tooltip = nil,
        Callback = function(W)
            Script.TargetAim.Stuff.LookAt = W
        end
    })
    
    Sections.Combat.Main:AddToggle("ViewAt", {
        Text = "Spectate",
        Default = Script.TargetAim.Stuff.Spectate,
        Tooltip = nil,
        Callback = function(W)
            Script.TargetAim.Stuff.Spectate = W
        end
    })
    
    Sections.Combat.Main:AddToggle("AntiAimViewer", {
        Text = "Anti Aim Viewer",
        Default = Script.Resolver.AntiAimViewer,
        Tooltip = nil,
        Callback = function(W)
            Script.Resolver.AntiAimViewer = W
        end
    })

    Sections.Combat.Main:AddInput("LockPrediction", {
        Text = "Prediction",
        Default = "0.134",
        Tooltip = nil,
        Callback = function(W)
            Script.TargetAim.Prediction = W
        end
    })
    
    Sections.Combat.Main:AddDropdown("TargetAimAimingMethod", {
        Text = "Aiming Method",
        Values = {"FireServer", "Spoof Mouse"},
        Default = "Spoof Mouse",
        Multi = false,
        Callback = function(W)
            Script.TargetAim.Method = W
        end
    })

    Sections.Combat.Main:AddDropdown("LockPart", {
        Text = "Hit Part",
        Values = {"HumanoidRootPart", "UpperTorso", "LowerTorso", "Head"},
        Default = "HumanoidRootPart",
        Multi = false,
        Callback = function(W)
            Script.TargetAim.HitPart.Part = W
        end
    })

    Sections.Combat.Main:AddToggle("ClosestPartLOL", {
        Text = "Closest Part",
        Default = Script.TargetAim.HitPart.ClosestPart,
        Tooltip = nil,
        Callback = function(W)
            Script.TargetAim.HitPart.ClosestPart = W
        end
    })

    Sections.Combat.Main:AddDropdown("ClosestPartMode", {
        Text = "Closest Mode",
        Values = {"Nearest Part", "Nearest Point"},
        Default = "Nearest Part",
        Multi = false,
        Callback = function(W)
            Script.TargetAim.HitPart.ClosestMode = W
        end
    })

    Sections.Combat.Main:AddToggle("AntiGroundShotsEnabled", {
        Text = "Anti Ground Shots",
        Default = false,
        Tooltip = nil,
        Callback = function(W)
            Script.TargetAim.Checks.AntiGroundShots.Enabled = W
        end
    })

    Sections.Combat.Main:AddSlider("AntiGroundShotsValue", {
        Text = "Dampening Factor",
        Default = 1,
        Min = 0.1,
        Max = 1,
        Rounding = 1,
        Callback = function(v)
            Script.TargetAim.Checks.AntiGroundShots.ToTakeOff = v
        end
    })
    
    Sections.Combat.Main:AddToggle("TracerEnabled", {
        Text = "Tracer",
        Default = Script.Visuals.Line.Enabled,
        Tooltip = nil,
        Callback = function(W)
            Script.Visuals.Line.Enabled = W
        end
    }):AddColorPicker("TracerColor", {
        Text = "Color",
        Default = Script.Visuals.Line.Color,
        Callback = function(W)
            Script.Visuals.Line.Color = W
        end
    })
    
    Sections.Combat.Main:AddToggle("TracerCircleEnabled", {
        Text = "3D Circle",
        Default = Script.Visuals.Line.Circle,
        Tooltip = nil,
        Callback = function(W)
            Script.Visuals.Line.Circle = W
        end
    })
    
    Sections.Combat.Main:AddSlider("TracerThickness", {
        Text = "Tracer Thickness",
        Default = 1,
        Min = 1,
        Max = 6,
        Rounding = 1,
        Callback = function(v)
            Script.Visuals.Line.Thickness = v
        end
    })
    
    Sections.Combat.Main:AddToggle("DotEnabled", {
        Text = "Dot",
        Default = Script.Visuals.Dot.Enabled,
        Tooltip = nil,
        Callback = function(W)
            Script.Visuals.Dot.Enabled = W
        end
    }):AddColorPicker("DotColor", {
        Text = "Color",
        Default = Script.Visuals.Dot.Color,
        Callback = function(W)
            Script.Visuals.Dot.Color = W
        end
    })
    
    Sections.Combat.Main:AddSlider("DotSize", {
        Text = "Dot Size",
        Default = 1,
        Min = 1,
        Max = 16,
        Rounding = 1,
        Callback = function(v)
            Script.Visuals.Dot.Size = v
        end
    })
    
    Sections.Combat.Main:AddToggle("HighlightingEnabled", {
        Text = "Chams",
        Default = Script.Visuals.HighLight.Enabled,
        Tooltip = nil,
        Callback = function(W)
            Script.Visuals.HighLight.Enabled = W
        end
    }):AddColorPicker("HighLightFillColor", {
        Text = "Fill Color",
        Default = Script.Visuals.HighLight.Fill,
        Callback = function(W)
            Script.Visuals.HighLight.Fill = W
        end
    }):AddColorPicker("HighLightOutlineColor", {
        Text = "Outline Color",
        Default = Script.Visuals.HighLight.OutLine,
        Callback = function(W)
            Script.Visuals.HighLight.OutLine = W
        end
    })
end

do
    -- Resolver Section
    Sections.Combat.Resolver:AddToggle("ResolverEnabled", {
        Text = "Enabled",
        Default = Script.Resolver.Enabled,
        Tooltip = nil,
        Callback = function(W)
            Script.Resolver.Enabled = W
        end
    })
    
    Sections.Combat.Resolver:AddDropdown("ResolverType", {
        Text = "Resolver Type",
        Values = {"Recalculate", "Move Direction", "Look Vector", "Zero Prediction"},
        Default = "Recalculate",
        Multi = false,
        Callback = function(W)
            Script.Resolver.Enabled = W
        end
    })
end

do
    -- Checks Section
    Sections.Combat.Checks:AddToggle("ChecksEnabled", {
        Text = "Enabled",
        Default = Script.Checks.Enabled,
        Tooltip = nil,
        Callback = function(W)
            Script.Checks.Enabled = W
        end
    })
    
    Sections.Combat.Checks:AddToggle("Vehicle", {
        Text = "Vehicle",
        Default = Script.Checks.Vehicle,
        Tooltip = nil,
        Callback = function(W)
            Script.Checks.Vehicle = W
        end
    })
    
    Sections.Combat.Checks:AddToggle("KnockedCheck", {
        Text = "Knocked",
        Default = Script.Checks.Knocked,
        Tooltip = nil,
        Callback = function(W)
            Script.Checks.Knocked = W
        end
    })
    
    Sections.Combat.Checks:AddToggle("FriendCheck", {
        Text = "Friend",
        Default = Script.Checks.Friend,
        Tooltip = nil,
        Callback = function(W)
            Script.Checks.Friend = W
        end
    })
    
    Sections.Combat.Checks:AddToggle("WallCheck", {
        Text = "Wall",
        Default = Script.Checks.Wall,
        Tooltip = nil,
        Callback = function(W)
            Script.Checks.Wall = W
        end
    })
end

do
    -- Aim Assist Section
    Sections.Combat.AimAssist:AddToggle("AimAssistEnabled", {
        Text = "Enabled",
        Default = Script.AimAssist.Enabled,
        Tooltip = nil,
        Callback = function(W)
            Script.AimAssist.Enabled = W
        end
    }):AddKeyPicker("AimAssistKeybind", {
          Default = "c",
          SyncToggleState = true,
          Mode = "Toggle",
          Text = "Aim Assist",
          NoUI = false,
     })
    
    Sections.Combat.AimAssist:AddInput("AimAssistPrediction", {
        Text = "Prediction",
        Default = "0.134",
        Tooltip = nil,
        Callback = function(W)
            Script.AimAssist.Prediction = W
        end
    })
    
    Sections.Combat.AimAssist:AddDropdown("AimAssistPart", {
        Text = "Hit Part",
        Values = {"HumanoidRootPart", "UpperTorso", "LowerTorso", "Head"},
        Default = "HumanoidRootPart",
        Multi = false,
        Callback = function(W)
            Script.AimAssist.HitPart.Part = W
        end
    })
    
    Sections.Combat.AimAssist:AddToggle("AimAssistShake", {
        Text = "Shake",
        Default = Script.AimAssist.Shake.Enabled,
        Tooltip = nil,
        Callback = function(W)
            Script.AimAssist.Shake.Enabled = W
        end
    })
    
    Sections.Combat.AimAssist:AddSlider("ShakeAmount", {
        Text = "Shake Amount",
        Default = 50,
        Min = 1,
        Max = 50,
        Rounding = 1,
        Callback = function(v)
            Script.AimAssist.Shake.Amount = v
        end
    })
    
    Sections.Combat.AimAssist:AddToggle("AimAssistSmoothing", {
        Text = "Smoothing",
        Default = Script.AimAssist.Smoothness.Enabled,
        Tooltip = nil,
        Callback = function(W)
            Script.AimAssist.Smoothness.Enabled = W
        end
    })
    
    Sections.Combat.AimAssist:AddSlider("SmoothnessAmount", {
        Text = "Smoothness Amount",
        Default = 100,
        Min = 1,
        Max = 100,
        Rounding = 1,
        Callback = function(v)
            Script.AimAssist.Smoothness.Amount = v
        end
    })
    
    Sections.Combat.AimAssist:AddDropdown("EasingStyle", {
        Text = "Easing Style",
        Values = {"Linear", "Sine", "Back", "Quad", "Quart", "Quint", "Bounce", "Elastic", "Exponential", "Circular", "Cubic"},
        Default = "Linear",
        Multi = false,
        Callback = function(W)
            Script.AimAssist.Smoothness.Style = W
        end
    })
    
    Sections.Combat.AimAssist:AddDropdown("EasingDirection", {
        Text = "Easing Directiom",
        Values = {"In", "Out", "InOut"},
        Default = "InOut",
        Multi = false,
        Callback = function(W)
            Script.AimAssist.Smoothness.Direction = W
        end
    })
end

do
    -- Trigger Bot Section
    Sections.Combat.TriggerBot:AddToggle("TriggerBotEnabled", {
        Text = "Enabled",
        Default = Script.TriggerBot.Enabled,
        Tooltip = nil,
        Callback = function(W)
            Script.TriggerBot.Enabled = W
        end
    }):AddKeyPicker("TriggerBotKeybind", {
          Default = "z",
          SyncToggleState = true,
          Mode = "Toggle",
          Text = "Trigger Bot",
          NoUI = false,
     })
    
    Sections.Combat.TriggerBot:AddToggle("TriggerBotVisualize", {
        Text = "Visualize",
        Default = Script.TriggerBot.Visualize,
        Tooltip = nil,
        Callback = function(W)
            Script.TriggerBot.Visualize = W
        end
    })
    
    Sections.Combat.TriggerBot:AddInput("TriggerBotPrediction", {
        Text = "Prediction",
        Default = "0.134",
        Tooltip = nil,
        Callback = function(W)
            Script.TriggerBot.Prediction = W
        end
    })
    
    Sections.Combat.TriggerBot:AddToggle("TriggerBotUseDelay", {
        Text = "Use Delay",
        Default = Script.TriggerBot.UseDelay,
        Tooltip = nil,
        Callback = function(W)
            Script.TriggerBot.UseDelay = W
        end
    })
    
    Sections.Combat.TriggerBot:AddSlider("DelayAmount", {
        Text = "Delay",
        Default = 1,
        Min = 0.01,
        Max = 1,
        Rounding = 1,
        Callback = function(v)
            Script.TriggerBot.Delay = v
        end
    })
end

do
    -- Visuals Section
    Sections.Visuals.ESP:AddToggle("ESPMainSwitch", {
        Text = "Enabled",
        Default = taffy_esp.enabled,
        Callback = function(w)
            taffy_esp.enabled = w
        end
    }):AddKeyPicker("ESPKeybind", {
          Default = "c",
          SyncToggleState = true,
          Mode = "Toggle",
          Text = "ESP",
          NoUI = false,
     })
    
    Sections.Visuals.ESP:AddToggle("ESPTargetOnlu", {
        Text = "Target Only",
        Default = taffy_esp.misc.target,
        Callback = function(w)
            taffy_esp.misc.target = w
        end
    })

    Sections.Visuals.ESP:AddToggle("ESPBoxes", {
        Text = "Bounding Box",
        Default = taffy_esp.box.boxes,
        Callback = function(W)
            taffy_esp.box.boxes = W
        end
    }):AddColorPicker("EspBoxesColor", {
        Text = "Color",
        Default = taffy_esp.box.color1,
        Callback = function(W)
            taffy_esp.box.color1 = W
        end
    })
    Sections.Visuals.ESP:AddDropdown("BoxTypeLOL", {
        Text = "Box Type",
        Values = {"2D", "3D"},
        Default = "2D",
        Multi = false,
        Callback = function(W)
            taffy_esp.box.boxtype = W
        end
    })
    
    Sections.Visuals.ESP:AddToggle("ESPBoxes.BoxFilled", {
        Text = "Bounding Box Fill",
        Default = taffy_esp.box.filled,
        Callback = function(W)
            taffy_esp.box.filled = W
        end
    }):AddColorPicker("EspBoxes.BoxFilledColor", {
        Text = "Color",
        Default = taffy_esp.box.filledColor,
        Callback = function(W)
            taffy_esp.box.filledColor = W
        end
    })

    Sections.Visuals.ESP:AddToggle("ESPHealthBar", {
        Text = "Health Bar",
        Default = taffy_esp.box.healthbar,
        Callback = function(W)
            taffy_esp.box.healthbar = W
        end
    }):AddColorPicker("EspHealthBarColor", {
        Text = "Color",
        Default = taffy_esp.box.healthbarcolor,
        Callback = function(W)
            taffy_esp.box.healthbarcolor = W
        end
    })
    
    Sections.Visuals.ESP:AddToggle("Esphealthtext", {
        Text = "Health Text",
        Default = taffy_esp.box.healthtext,
        Callback = function(W)
            taffy_esp.box.healthtext = W
        end
    }):AddColorPicker("EspHealthTextColor", {
        Text = "Color",
        Default = taffy_esp.box.healthtextcolor,
        Callback = function(W)
            taffy_esp.box.healthtextcolor = W
        end
    })
    
    Sections.Visuals.ESP:AddToggle("EspTracer", {
        Text = "Tracer",
        Default = taffy_esp.tracer.enabled,
        Callback = function(W)
            taffy_esp.tracer.enabled = W
        end
    }):AddColorPicker("EspTracersColor", {
        Text = "Color",
        Default = taffy_esp.tracer.color,
        Callback = function(W)
            taffy_esp.tracer.color = W
        end
    })
    
    Sections.Visuals.ESP:AddToggle("EspName", {
        Text = "Name",
        Default = taffy_esp.name.enabled,
        Callback = function(W)
            taffy_esp.name.enabled = W
        end
    }):AddColorPicker("EspNameColor", {
        Text = "Color",
        Default = taffy_esp.name.color,
        Callback = function(W)
            taffy_esp.name.color = W
        end
    })
    
    Sections.Visuals.ESP:AddToggle("EspTool", {
        Text = "Tool",
        Default = taffy_esp.Toolsshow.enable,
        Callback = function(W)
            taffy_esp.Toolsshow.enable = W
        end
    }):AddColorPicker("EspToolColor", {
        Text = "Color",
        Default = taffy_esp.Toolsshow.color,
        Callback = function(W)
            taffy_esp.Toolsshow.color = W
        end
    })
    
    Sections.Visuals.ESP:AddToggle("EspSkeleton", {
        Text = "Skeleton",
        Default = taffy_esp.Skeletons.Enabled,
        Callback = function(W)
            taffy_esp.Skeletons.Enabled = W
        end
    }):AddColorPicker("EspSkeletonColor", {
        Text = "Color",
        Default = taffy_esp.Skeletons.Color,
        Callback = function(W)
            taffy_esp.Skeletons.Color = W
        end
    })
end

do
    -- Self ESP Section
    function applyForcefieldToParts(parts,isEnabled,color)
        for _,part in pairs(parts) do
            if part:IsA("BasePart") then
                if isEnabled then
                    part.Material = Enum.Material.ForceField
                    part.Color = color
                else
                    part.Material = Enum.Material.Plastic
                end
            end
        end
    end
    
    function applyForcefieldToBody()
        local character = game.Players.LocalPlayer.Character
        applyForcefieldToParts(character:GetChildren(),Script.Visuals.SelfESP.Chams.ForcefieldBodyEnabled,Script.Visuals.SelfESP.Chams.ForcefieldBodyColor)
    end
    
    function applyForcefieldToTools()
        local backpack = game.Players.LocalPlayer.Backpack
        for _,tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                applyForcefieldToParts(tool:GetChildren(),Script.Visuals.SelfESP.Chams.ForcefieldToolsEnabled,Script.Visuals.SelfESP.Chams.ForcefieldToolsColor)
            end
        end
    end
    
    function applyForcefieldToHats()
        local character = game.Players.LocalPlayer.Character
        for _,accessory in pairs(character:GetChildren()) do
            if accessory:IsA("Accessory") then
                applyForcefieldToParts(accessory:GetChildren(),Script.Visuals.SelfESP.Chams.ForcefieldHatsEnabled,Script.Visuals.SelfESP.Chams.ForcefieldHatsColor)
            end
        end
    end
    
    Sections.Visuals.SelfESP:AddToggle("ForcefieldBodyLOL", {
        Text = "Forcefield Body",
        Default = Script.Visuals.SelfESP.Chams.ForcefieldBodyEnabled,
        Callback = function(w)
            Script.Visuals.SelfESP.Chams.ForcefieldBodyEnabled = w
            applyForcefieldToBody()
        end
    }):AddColorPicker("ForcefieldBodyColor", {
        Text = "Color",
        Default = Script.Visuals.SelfESP.Chams.ForcefieldBodyColor,
        Callback = function(W)
            Script.Visuals.SelfESP.Chams.ForcefieldBodyColor = W
            applyForcefieldToBody()
        end
    })
    
    Sections.Visuals.SelfESP:AddToggle("ForcefieldToolsLOL", {
        Text = "Forcefield Tools",
        Default = Script.Visuals.SelfESP.Chams.ForcefieldToolsEnabled,
        Callback = function(w)
            Script.Visuals.SelfESP.Chams.ForcefieldToolsEnabled = w
            applyForcefieldToTools()
        end
    }):AddColorPicker("ForcefieldToolsColor", {
        Text = "Color",
        Default = Script.Visuals.SelfESP.Chams.ForcefieldToolsColor,
        Callback = function(W)
            Script.Visuals.SelfESP.Chams.ForcefieldToolsColor = W
            applyForcefieldToTools()
        end
    })
    
    Sections.Visuals.SelfESP:AddToggle("ForcefieldHatsLOL", {
        Text = "Forcefield Hats",
        Default = Script.Visuals.SelfESP.Chams.ForcefieldHatsEnabled,
        Callback = function(w)
            Script.Visuals.SelfESP.Chams.ForcefieldHatsEnabled = w
            applyForcefieldToHats()
        end
    }):AddColorPicker("ForcefieldHatsColor", {
        Text = "Color",
        Default = Script.Visuals.SelfESP.Chams.ForcefieldHatsColor,
        Callback = function(W)
            Script.Visuals.SelfESP.Chams.ForcefieldHatsColor = W
            applyForcefieldToHats()
        end
    })
    
    Sections.Visuals.SelfESP:AddToggle("SelfESPAura", {
        Text = "Aura",
        Default = Script.Visuals.SelfESP.Aura.Enabled,
        Callback = function(w)
            Script.Visuals.SelfESP.Aura.Enabled = w
            setupParticles()
        end
    })
    
    Sections.Visuals.SelfESP:AddDropdown("SelfESPAuraType", {
        Text = "Aura Type",
        Values = {"Heal", "Swirl"},
        Default = "Heal",
        Multi = false,
        Callback = function(W)
            Script.Visuals.SelfESP.Aura.Type = W
            setupParticles()
        end
    })
    
    Sections.Visuals.SelfESP:AddToggle("SelfESPTrail", {
        Text = "Trail",
        Default = Script.Visuals.SelfESP.Trail.Enabled,
        Callback = function(w)
            Deposit:TrailCharacter(w)
        end
    }):AddColorPicker("TrailColor", {
        Text = "Color",
        Default = Script.Visuals.SelfESP.Trail.Color,
        Callback = function(W)
            Script.Visuals.SelfESP.Trail.Color = W
        end
    })
    
    Sections.Visuals.SelfESP:AddSlider("TrailLifeTime", {
        Text = "Life Time",
        Default = Script.Visuals.SelfESP.Trail.LifeTime,
        Min = 1,
        Max = 10,
        Rounding = 1,
        Callback = function(W)
            Script.Visuals.SelfESP.Trail.LifeTime = W
        end
    })
end

do -- Crosshair Section
    Sections.Visuals.Crosshair:AddToggle("CrosshairShow", {
        Text = "Enabled",
        Default = Cursor.enabled,
        Callback = function(W)
            Cursor.enabled = W
        end
    }):AddColorPicker("CrosshairColor", {
        Text = "Color",
        Default = Cursor.color,
        Callback = function(W)
            Cursor.color = W
        end
    })

    Sections.Visuals.Crosshair:AddDropdown("CrosshairMode", {
        Text = "Type",
        Default = "Middle",
        Values = {"Mouse", "Middle"},
        Callback = function(W)
            crosshair_position = W
        end
    })

    Sections.Visuals.Crosshair:AddToggle("CrosshairStick", {
        Text = "Stick",
        Default = Cursor.sticky,
        Callback = function(W)
            Cursor.sticky = W
        end
    })
    
    Sections.Visuals.Crosshair:AddSlider("CrosshairSize", {
        Text = "Size",
        Default = Cursor.length,
        Min = 10,
        Max = 50,
        Rounding = 1,
        Callback = function(W)
            Cursor.length = W
        end
    })
    
    Sections.Visuals.Crosshair:AddSlider("CrosshairGap", {
        Text = "Gap",
        Default = Cursor.radius,
        Min = 10,
        Max = 50,
        Rounding = 1,
        Callback = function(W)
            Cursor.radius = W
        end
    })

    Sections.Visuals.Crosshair:AddToggle("CrosshairSpin", {
        Text = "Spinning",
        Default = Cursor.spin,
        Callback = function(W)
            Cursor.spin = W
        end
    })

    Sections.Visuals.Crosshair:AddSlider("CrosshairSpinSpeed", {
        Text = "Spinning Speed",
        Default = Cursor.spin_speed,
        Min = 1,
        Max = 340,
        Rounding = 1,
        Callback = function(W)
            Cursor.spin_speed = W
        end
    })

    Sections.Visuals.Crosshair:AddToggle("CrosshairResize", {
        Text = "Resize",
        Default = Cursor.resize,
        Callback = function(W)
            Cursor.resize = W
        end
    })

    Sections.Visuals.Crosshair:AddSlider("CrosshairResizeSpeed", {
        Text = "Resize Speed",
        Default = Cursor.resize_speed,
        Min = 1,
        Max = 40,
        Rounding = 1,
        Callback = function(W)
            Cursor.resize_speed = W
        end
    })
end

do -- OnHit Section
    Sections.Visuals.OnHit:AddToggle("OnHitEnabked", {
        Text = "Enabled",
        Default = Script.Visuals.Hit_Detection.Enabled,
        Callback = function(W)
            Script.Visuals.Hit_Detection.Enabled = W
        end
    })
    
    Sections.Visuals.OnHit:AddToggle("OnHitLogs", {
        Text = "Notify",
        Default = Script.Visuals.Hit_Detection.Notify,
        Callback = function(W)
            Script.Visuals.Hit_Detection.Notify = W
        end
    })
    
    Sections.Visuals.OnHit:AddToggle("OnHitChams", {
        Text = "Clone",
        Default = Script.Visuals.Hit_Detection.Clone,
        Callback = function(W)
            Script.Visuals.Hit_Detection.Clone = W
        end
    })
    
    Sections.Visuals.OnHit:AddToggle("OnHitSound", {
        Text = "Sound",
        Default = Script.Visuals.Hit_Detection.Sound,
        Callback = function(W)
            Script.Visuals.Hit_Detection.Sound = W
        end
    })
    
    Sections.Visuals.OnHit:AddDropdown("SoundToPlayXDXD", {
        Text = "Sound To Play",
        Default = "Rust",
        Values = hitSoundsNames,
        Callback = function(W)
            Script.Visuals.Hit_Detection.HitSound = W
        end
    })
end

do -- Bullet Tracers Section
    Sections.Visuals.BulletTracers:AddToggle("BulletTracersEnabled", {
        Text = "Enabled",
        Default = Script.Visuals.BulletTracers.Enabled,
        Callback = function(W)
            Script.Visuals.BulletTracers.Enabled = W
        end
    }):AddColorPicker("BulletTracersColor", {
        Text = "Color",
        Default = Script.Visuals.BulletTracers.Color,
        Callback = function(W)
            Script.Visuals.BulletTracers.Color = W
        end
    })
    
    Sections.Visuals.BulletTracers:AddDropdown("TypeLOL", {
        Text = "Type",
        Default = "Drawing",
        Values = {"Beam", "Drawing"},
        Callback = function(W)
            Script.Visuals.BulletTracers.Type = W
        end
    })
    
    Sections.Visuals.BulletTracers:AddSlider("BulletTracersDuration", {
        Text = "Duration",
        Default = Script.Visuals.BulletTracers.Duration,
        Min = 1,
        Max = 10,
        Rounding = 1,
        Callback = function(W)
            Script.Visuals.BulletTracers.Duration = W
        end
    })
    
    Sections.Visuals.BulletTracers:AddToggle("BulletTracersFadeEnabled", {
        Text = "Fade",
        Default = Script.Visuals.BulletTracers.Fade,
        Callback = function(W)
            Script.Visuals.BulletTracers.Fade = W
        end
    })
    
    Sections.Visuals.BulletTracers:AddSlider("BulletTracersFadeDuration", {
        Text = "Fade Duration",
        Default = Script.Visuals.BulletTracers.FadeDuration,
        Min = 1,
        Max = 10,
        Rounding = 1,
        Callback = function(W)
            Script.Visuals.BulletTracers.FadeDuration = W
        end
    })
    
    Sections.Visuals.BulletTracers:AddDropdown("BulletTracersMode", {
        Text = "Mode",
        Default = "Local",
        Values = {"Local", "Global"},
        Callback = function(W)
            Script.Visuals.BulletTracers.Mode = W
        end
    })
end

do -- Bullet Impacts Section
    Sections.Visuals.BulletImpacts:AddToggle("BulletImpactsEnabled", {
        Text = "Enabled",
        Default = Script.Visuals.BulletImpacts.Enabled,
        Callback = function(W)
            Script.Visuals.BulletImpacts.Enabled = W
        end
    }):AddColorPicker("BulletImpactsColor", {
        Text = "Color",
        Default = Script.Visuals.BulletImpacts.Color,
        Callback = function(W)
            Script.Visuals.BulletImpacts.Color = W
        end
    })
    
    Sections.Visuals.BulletImpacts:AddSlider("BulletImpactsWidth", {
        Text = "Width",
        Default = 0.25,
        Min = 0.1,
        Max = 5,
        Rounding = 1,
        Callback = function(W)
            Script.Visuals.BulletImpacts.Width = W
        end
    })
    
    Sections.Visuals.BulletImpacts:AddSlider("BulletImpactsDuration", {
        Text = "Duration",
        Default = Script.Visuals.BulletImpacts.Duration,
        Min = 1,
        Max = 10,
        Rounding = 1,
        Callback = function(W)
            Script.Visuals.BulletImpacts.Duration = W
        end
    })
    
    Sections.Visuals.BulletImpacts:AddToggle("BulletImpactsFadeEnabled", {
        Text = "Fade",
        Default = Script.Visuals.BulletImpacts.Fade,
        Callback = function(W)
            Script.Visuals.BulletImpacts.Fade = W
        end
    })
    
    Sections.Visuals.BulletImpacts:AddSlider("BulletImpactsFadeDuration", {
        Text = "Fade Duration",
        Default = Script.Visuals.BulletImpacts.FadeDuration,
        Min = 1,
        Max = 10,
        Rounding = 1,
        Callback = function(W)
            Script.Visuals.BulletImpacts.FadeDuration = W
        end
    })
end

do
    -- Auto Buy Section
    Sections.Rage.AutoBuy:AddSlider("AutoBuyMultiplier", {
        Text = "Multiplier",
        Default = 1,
        Min = 1,
        Max = 10,
        Rounding = 1,
        Callback = function(W)
            autobuymultiplier = W
        end
    })
    
    Sections.Rage.AutoBuy:AddDropdown("SelectGuns", {
        Text = "Guns",
        Default = "Revolver",
        Values = InnalillahiMichaelJackson.Guns,
        Callback = function(W)
            Script.Rage.AutoBuy.SelectedGun = W
        end
    })
    
    Sections.Rage.AutoBuy:AddButton("Buy Gun / Ammo", function()
       BuyGunAndAmmo(Script.Rage.AutoBuy.SelectedGun, autobuymultiplier)
    end)
    
    Sections.Rage.AutoBuy:AddDropdown("SelectFood", {
        Text = "Food",
        Default = "Taco",
        Values = InnalillahiMichaelJackson.Food,
        Callback = function(W)
            Script.Rage.AutoBuy.SelectedFood = W
        end
    })
    
    Sections.Rage.AutoBuy:AddButton("Buy Food", function()
       Buy(Gun(Script.Rage.AutoBuy.SelectedFood),0.3,true,1)
    end)
end

do
    -- Teleport Section
    Sections.Rage.Teleport:AddDropdown("SelectLocation", {
        Text = "Locations",
        Default = "Uphill",
        Values = InnalillahiMichaelJackson.Locations,
        Callback = function(W)
            Script.Rage.AutoBuy.SelectedLocation = W
        end
    })
    
    Sections.Rage.Teleport:AddButton("Goto", function()
       tp(Script.Rage.AutoBuy.SelectedLocation)
    end)
    
    Sections.Rage.Teleport:AddButton("Goto Random", function()
       tp(InnalillahiMichaelJackson.Locations[math.random(1,#InnalillahiMichaelJackson.Locations)])
    end)
end

do
    -- killbot Section
    Sections.Rage.Killbot:AddToggle("KillbotEnabled", {
        Text = "Enabled",
        Default = Script.Rage.Killbot.Enabled,
        Tooltip = nil,
        Callback = function(W)
            Script.Rage.Killbot.Enabled = W
        end
    })
    
    Sections.Rage.Killbot:AddDropdown("KillbotMethod", {
        Text = "Killbot Method",
        Default = "Randomize TP",
        Values = {"Orbit", "Randomize TP"},
        Callback = function(W)
            Script.Rage.Killbot.Type = W
        end
    })
    
    Sections.Rage.Killbot:AddSlider("KillbotSpeed", {
        Text = "Speed",
        Default = Script.Rage.Killbot.Speed,
        Min = 1,
        Max = 20,
        Rounding = 1,
        Callback = function(W)
            Script.Rage.Killbot.Speed = W
        end
    })
    
    Sections.Rage.Killbot:AddSlider("KillbotDistance", {
        Text = "Distance",
        Default = Script.Rage.Killbot.Distance,
        Min = 1,
        Max = 20,
        Rounding = 1,
        Callback = function(W)
            Script.Rage.Killbot.Distance = W
        end
    })
    
    Sections.Rage.Killbot:AddSlider("KillbotHeight", {
        Text = "Height",
        Default = Script.Rage.Killbot.Height,
        Min = 1,
        Max = 20,
        Rounding = 1,
        Callback = function(W)
            Script.Rage.Killbot.Height = W
        end
    })
    
    Sections.Rage.Killbot:AddSlider("KillbotRandomization", {
        Text = "Randomization",
        Default = Script.Rage.Killbot.Randomization,
        Min = 1,
        Max = 20,
        Rounding = 1,
        Callback = function(W)
            Script.Rage.Killbot.Randomization = W
        end
    })
end

do
    -- CFrame Speed Section
    Sections.Rage.CFSpeed:AddToggle("CFrameSpeedEnabled", {
        Text = "Enabled",
        Default = Script.Rage.CFrameSpeed.Enabled,
        Tooltip = nil,
        Callback = function(W)
            Script.Rage.CFrameSpeed.Enabled = W
        end
    }):AddKeyPicker("CFrameSpeedKeybind", {
          Default = "b",
          SyncToggleState = true,
          Mode = "Toggle",
          Text = "CFrame Speed",
          NoUI = false,
     })
     
     game:GetService("RunService").Stepped:Connect(function()
            if Script.Rage.CFrameSpeed.Enabled then
                local character = game.Players.LocalPlayer.Character
                if character then
                    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                    local moveDirection = character:FindFirstChild("Humanoid") and character.Humanoid.MoveDirection or Vector3.new(0, 0, 0)

                    if humanoidRootPart then
                        humanoidRootPart.CFrame = humanoidRootPart.CFrame + moveDirection * Script.Rage.CFrameSpeed.Speed
                    end
                end
            end
        end)
     
    Sections.Rage.CFSpeed:AddButton("Load Button", function()
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
        ScreenGui.ResetOnSpawn = false

        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Text = "Toggle Speed"
        ToggleButton.Parent = ScreenGui
        ToggleButton.BackgroundTransparency = 0.5
        ToggleButton.BorderSizePixel = 0
        ToggleButton.Position = UDim2.new(1, -120, 0, 75) -- Adjusted the position to top right corner
        ToggleButton.Size = UDim2.new(0, 100, 0, 18)
        ToggleButton.BackgroundColor3 = Color3.fromRGB(69,0,0)
        ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)

        local UICorner = Instance.new("UICorner")
        UICorner.Parent = ToggleButton

        local function onButtonClicked()
            Script.Rage.CFrameSpeed.Enabled = not Script.Rage.CFrameSpeed.Enabled
        end

        ToggleButton.MouseButton1Click:Connect(onButtonClicked)
    end)
    
    Sections.Rage.CFSpeed:AddSlider("SpeedAmount", {
        Text = "Speed Amount",
        Default = Script.Rage.CFrameSpeed.Speed,
        Min = 1,
        Max = 10,
        Rounding = 1,
        Callback = function(W)
            Script.Rage.CFrameSpeed.Speed = W
        end
    })
end

do
    -- Auto Armor Sections
    Sections.Rage.AutoArmor:AddToggle("AutoArmorEnabled", {
        Text = "Auto Armor",
        Default = Script.Rage.AutoArmor.Enabled,
        Tooltip = nil,
        Callback = function(W)
            Script.Rage.AutoArmor.Enabled = W
        end
    })
    
    Sections.Rage.AutoArmor:AddSlider("AutoArmorBuyOn", {
        Text = "Buy On %",
        Default = Script.Rage.AutoArmor.BuyOn,
        Min = 1,
        Max = 70,
        Rounding = 1,
        Callback = function(W)
            Script.Rage.AutoArmor.BuyOn = W
        end
    })
end

do
    -- Exploits Section
    Sections.Rage.Exploits:AddToggle("AutoStomp", {
        Text = "Auto Stomp",
        Default = Script.Rage.Exploits.AutoStomp,
        Tooltip = nil,
        Callback = function(W)
            Script.Rage.Exploits.AutoStomp = W
        end
    })
    
    Sections.Rage.Exploits:AddToggle("AntiBag", {
        Text = "Anti Bag",
        Default = Script.Rage.Exploits.AntiBag,
        Tooltip = nil,
        Callback = function(W)
            Script.Rage.Exploits.AntiBag = W
        end
    })
    
    Sections.Rage.Exploits:AddToggle("AntiRPF", {
        Text = "Anti RPG",
        Default = Script.Rage.Exploits.AntiRPG,
        Tooltip = nil,
        Callback = function(W)
            Script.Rage.Exploits.AntiRPG = W
        end
    })
    
    Sections.Rage.Exploits:AddToggle("No Recoil", {
        Text = "No Recoil",
        Default = Script.Rage.Exploits.NoRecoil,
        Tooltip = nil,
        Callback = function(W)
            Script.Rage.Exploits.NoRecoil = W
        end
    })
    
    Sections.Rage.Exploits:AddToggle("NJC", {
        Text = "No Jump Cooldown",
        Default = Script.Rage.Exploits.NoJumpCooldown,
        Tooltip = nil,
        Callback = function(W)
            Script.Rage.Exploits.NoJumpCooldown = W
        end
    })
    
    Sections.Rage.Exploits:AddToggle("NoSlowDown", {
        Text = "No Slowdown",
        Default = Script.Rage.Exploits.NoSlow,
        Tooltip = nil,
        Callback = function(W)
            Script.Rage.Exploits.NoSlow = W
        end
    })
end

--// Velocity Spoofer
do
    Sections.AntiAim.VelocitySpoofer:AddToggle("AntiAimVelocitySpooferEnabled", {
        Text = "Enabled",
        Default = false,
        Tooltip = nil,
        Callback = function(W)
            Script.AntiAim.VelocitySpoofer.Enabled = W
        end
    })

    Sections.AntiAim.VelocitySpoofer:AddDropdown("AntiAimVelocitySpooferType", {
        Values = {"Custom", "Pred Multiplier", "Sky", "Underground", "Shake", "Pred Breaker"},
        Default = 1,
        Multi = false,
        Text = "Type",
        Tooltip = nil,
        Callback = function(W)
            Script.AntiAim.VelocitySpoofer.Type = W
        end
    })
    
    Sections.AntiAim.VelocitySpoofer:AddSlider("AntiAimVelocitySpooferYaw", {
        Text = "Yaw",
        Default = 0,
        Min = 0,
        Max = 100,
        Rounding = 3,
        Compact = false,
        Callback = function(W)
            Script.AntiAim.VelocitySpoofer.Yaw = W
        end
    })

    Sections.AntiAim.VelocitySpoofer:AddSlider("AntiAimVelocitySpooferPitch", {
        Text = "Pitch",
        Default = 0,
        Min = 0,
        Max = 100,
        Rounding = 3,
        Compact = false,
        Callback = function(W)
            Script.AntiAim.VelocitySpoofer.Pitch = W
        end
    })

    Sections.AntiAim.VelocitySpoofer:AddSlider("AntiAimVelocitySpooferRoll", {
        Text = "Roll",
        Default = 0,
        Min = 0,
        Max = 100,
        Rounding = 3,
        Compact = false,
        Callback = function(W)
            Script.AntiAim.VelocitySpoofer.Roll = W
        end
    })
    
    Sections.AntiAim.VelocitySpoofer:AddSlider("AntiAimVelocitySpooferMultiplier", {
        Text = "Multiplier",
        Default = 1,
        Min = 1.5,
        Max = 10,
        Rounding = 1,
        Compact = false,
        Callback = function(W)
            Script.AntiAim.VelocitySpoofer.Roll = W
        end
    })
    
    Sections.AntiAim.VelocitySpoofer:AddSlider("AntiAimVelocitySpooferShake", {
        Text = "Shake",
        Default = 1,
        Min = 0,
        Max = 100,
        Rounding = 3,
        Compact = false,
        Callback = function(W)
            Script.AntiAim.VelocitySpoofer.ShakeValue = W
        end
    })
    
    Sections.AntiAim.VelocitySpoofer:AddToggle("AimViewerEnabled", {
        Text = "Aim Viewer",
        Default = false,
        Tooltip = nil,
        Callback = function(W)
            Script.AntiAim.VelocitySpoofer.AimViewer.Enabled = W
        end
    }):AddColorPicker("AimViewerColor", {
        Default = Color3.new(1,1,1),
        Title = "Aim Viewer Color",
        Transparency = nil,
        Callback = function(W)
            Script.AntiAim.VelocitySpoofer.AimViewer.Color = W
        end
    })
end

--// C-Sync
do
    Sections.AntiAim.CFrameDesync:AddToggle("CSyncAntiAimEnabled", {
        Text = "Enabled",
        Default = false,
        Tooltip = nil,
    }):AddKeyPicker("CSyncAntiAimKeyPicker", {
        Default = "b",
        SyncToggleState = true,
        Mode = "Toggle",
        Text = "C-Sync",
        NoUI = false,
    })

    Toggles.CSyncAntiAimEnabled:OnChanged(function()
        Script.AntiAim.CSync.Enabled = Toggles.CSyncAntiAimEnabled.Value
    end)
    
    Sections.AntiAim.CFrameDesync:AddToggle("CSyncAntiAimAttach", {
        Text = "Attach To Target",
        Default = false,
        Tooltip = nil,
        Callback = function(w)
          Script.AntiAim.CSync.Attach = w
        end
    })

    Sections.AntiAim.CFrameDesync:AddToggle("CSyncAntiAimVisualizeEnabled", {
        Text = "Visualize",
        Default = false,
        Tooltip = nil,
    }):AddColorPicker("CSyncAntiAimVisualizeColor", {
        Default = Color3.new(1,1,1),
        Title = "CFrame Visualize Color",
        Transparency = nil,
    })
    
    Sections.AntiAim.CFrameDesync:AddDropdown("CSyncVisualizerType", {
        Values = {"Dot", "Line", "Character"},
        Default = 1,
        Multi = false,
        Text = "Visualizer Type",
        Tooltip = nil,
        Callback = function(w)
           Script.AntiAim.CSync.Visualize.Type = w
        end
    })

    Sections.AntiAim.CFrameDesync:AddDropdown("CSyncAntiAimType", {
        Values = {"Custom", "Random", "Target Strafe"},
        Default = 1,
        Multi = false,
        Text = "Type",
        Tooltip = nil,
    })

    Toggles.CSyncAntiAimVisualizeEnabled:OnChanged(function()
        Script.AntiAim.CSync.Visualize.Enabled = Toggles.CSyncAntiAimVisualizeEnabled.Value
    end)

    Options.CSyncAntiAimVisualizeColor:OnChanged(function()
        Script.AntiAim.CSync.Visualize.Color = Options.CSyncAntiAimVisualizeColor.Value
    end)

    Options.CSyncAntiAimType:OnChanged(function()
        Script.AntiAim.CSync.Type = Options.CSyncAntiAimType.Value
    end)

    Sections.AntiAim.CFrameDesync:AddSlider("CSyncAntiAimRandomRange", {
        Text = "Randomization",
        Default = 0.1,
        Min = 0,
        Max = 20,
        Rounding = 1,
        Compact = false,
    })

    Options.CSyncAntiAimRandomRange:OnChanged(function()
        Script.AntiAim.CSync.Randomize.Value = Options.CSyncAntiAimRandomRange.Value
    end)

    Sections.AntiAim.CFrameDesync:AddSlider("CSyncAntiAimCustomX", {
        Text = "Custom X",
        Default = 0.1,
        Min = 0,
        Max = 500,
        Rounding = 1,
        Compact = false,
    })

    Options.CSyncAntiAimCustomX:OnChanged(function()
        Script.AntiAim.CSync.Custom.X = Options.CSyncAntiAimCustomX.Value
    end)

    Sections.AntiAim.CFrameDesync:AddSlider("CSyncAntiAimCustomY", {
        Text = "Custom Y",
        Default = 0.1,
        Min = 0,
        Max = 500,
        Rounding = 1,
        Compact = false,
    })

    Options.CSyncAntiAimCustomY:OnChanged(function()
        Script.AntiAim.CSync.Custom.Y = Options.CSyncAntiAimCustomY.Value
    end)

    Sections.AntiAim.CFrameDesync:AddSlider("CSyncAntiAimCustomZ", {
        Text = "Custom Z",
        Default = 0.1,
        Min = 0,
        Max = 500,
        Rounding = 1,
        Compact = false,
    })

    Options.CSyncAntiAimCustomZ:OnChanged(function()
        Script.AntiAim.CSync.Custom.Z = Options.CSyncAntiAimCustomZ.Value
    end)

    Sections.AntiAim.CFrameDesync:AddSlider("CSyncAntiAimTargetStrafeSpeed", {
        Text = "Speed",
        Default = 1,
        Min = 0,
        Max = 20,
        Rounding = 1,
        Compact = false,
    })

    Options.CSyncAntiAimTargetStrafeSpeed:OnChanged(function()
        Script.AntiAim.CSync.TargetStrafe.Speed = Options.CSyncAntiAimTargetStrafeSpeed.Value
    end)

    Sections.AntiAim.CFrameDesync:AddSlider("CSyncAntiAimTargetStrafeDistance", {
        Text = "Distance",
        Default = 1,
        Min = 0,
        Max = 20,
        Rounding = 1,
        Compact = false,
    })

    Options.CSyncAntiAimTargetStrafeDistance:OnChanged(function()
        Script.AntiAim.CSync.TargetStrafe.Distance = Options.CSyncAntiAimTargetStrafeDistance.Value
    end)

    Sections.AntiAim.CFrameDesync:AddSlider("CSyncAntiAimTargetStrafeHeight", {
        Text = "Height",
        Default = 1,
        Min = 0,
        Max = 20,
        Rounding = 1,
        Compact = false,
    })

    Options.CSyncAntiAimTargetStrafeHeight:OnChanged(function()
        Script.AntiAim.CSync.TargetStrafe.Height = Options.CSyncAntiAimTargetStrafeHeight.Value
    end)
end


--// Fake Lag
do
    Sections.AntiAim.Network:AddToggle("AntiAimNetworkEnabled", {
        Text = "Enabled",
        Default = false,
    }):AddKeyPicker("AntiAimNetworkKeyPicker", {
        Default = "b",
        SyncToggleState = true,
        Mode = "Toggle",
        Text = "Network",
        NoUI = false,
    }):OnChanged(function()
        Script.AntiAim.Network.Enabled = Toggles.AntiAimNetworkEnabled.Value
    end)

    Sections.AntiAim.Network:AddToggle("AntiAimNetworkWalkingCheck", {
        Text = "Walking Check",
        Default = false,
    }):OnChanged(function()
        Script.AntiAim.Network.WalkingCheck = Toggles.AntiAimNetworkWalkingCheck.Value
    end)

    Sections.AntiAim.Network:AddSlider("AntiAimNetworkAmount", {
        Text = "Amount",
        Default = 0.1,
        Min = 0,
        Max = 30,
        Rounding = 3,
    }):OnChanged(function()
        Script.AntiAim.Network.Amount = Options.AntiAimNetworkAmount.Value
    end)
end

--// FFlag Desync
do
    Sections.AntiAim.FFlag:AddToggle("AntiAimFFlagDesyncEnabled", {
        Text = "Enabled",
        Default = false,
    }):AddKeyPicker("AntiAimFFlagDesyncKeyPicker", {
        Default = "b",
        SyncToggleState = true,
        Mode = "Toggle",
        Text = "FFlag Desync",
        NoUI = false,
    }):OnChanged(function()
        Script.AntiAim.FFlagDesync.Enabled = Toggles.AntiAimFFlagDesyncEnabled.Value
        if not Script.AntiAim.FFlagDesync.Enabled then
            for FFlag, Value in pairs(InnalillahiMichaelJackson.Locals.FFlags) do
                setfflag(FFlag, Value)
            end
        end
    end)

    Sections.AntiAim.FFlag:AddToggle("AntiAimFFlagDesyncSetNew", {
        Text = "Set New",
        Default = false,
    }):OnChanged(function()
        Script.AntiAim.FFlagDesync.SetNew = Toggles.AntiAimFFlagDesyncSetNew.Value
    end)

    Sections.AntiAim.FFlag:AddDropdown("AntiAimFFlagDesyncFFlags", {
        Values = {"S2PhysicsSenderRate", "PhysicsSenderMaxBandwidthBps", "DataSenderMaxJoinBandwidthBps"},
        Default = {"S2PhysicsSenderRate"},
        Multi = true,
        Text = "FFlags",
    }):OnChanged(function()
        Script.AntiAim.FFlagDesync.FFlags = Options.AntiAimFFlagDesyncFFlags.Value
    end)

    Sections.AntiAim.FFlag:AddSlider("AntiAimFFlagDesyncAmount", {
        Text = "Amount",
        Default = 2,
        Min = 0.1,
        Max = 10,
        Rounding = 3,
    }):OnChanged(function()
        Script.AntiAim.FFlagDesync.Amount = Options.AntiAimFFlagDesyncAmount.Value
    end)

    Sections.AntiAim.FFlag:AddSlider("AntiAimFFlagDesyncSetnewAmount", {
        Text = "Set New Amount",
        Default = 15,
        Min = 0.1,
        Max = 20,
        Rounding = 3,
    }):OnChanged(function()
        Script.AntiAim.FFlagDesync.SetNewAmount = Options.AntiAimFFlagDesyncSetnewAmount.Value
    end)
end


-- UI Settings
Library:SetWatermark('Deposit.lua | '..os.date("%B %d %Y").." | 1.0.1")
Library:SetWatermarkVisibility(false)
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
local MenuGroup2 = Tabs['UI Settings']:AddRightGroupbox('More Settings')
MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = "V", NoUI = true, Text = 'Menu keybind' })

MenuGroup2:AddToggle('togglekeybindmenu', {
    Text = 'Keybind Menu',
    Default = false,
    Callback = function(V) Library.KeybindFrame.Visible = Toggles.togglekeybindmenu.Value end
})

MenuGroup2:AddToggle('togglewatermark', {
    Text = 'Watermark',
    Default = false,
    Callback = function(V) Library:SetWatermarkVisibility(Toggles.togglewatermark.Value) end
})

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
ThemeManager:ApplyToTab(Tabs['UI Settings'])
ThemeManager:SetFolder("Deposit")

SaveManager:SetLibrary(Library)
SaveManager:SetFolder("Deposit/RaidAwareness")
SaveManager:IgnoreThemeSettings()
SaveManager:BuildConfigSection(Tabs['UI Settings'])
end

load()