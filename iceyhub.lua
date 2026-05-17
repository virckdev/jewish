--[[
   icey's priv hub
   Organized & improved version
]]

-- ══════════════════════════════════════════
--  SERVICES
-- ══════════════════════════════════════════
local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService  = game:GetService("TeleportService")
local HttpService    = game:GetService("HttpService")

-- ══════════════════════════════════════════
--  RAYFIELD
-- ══════════════════════════════════════════
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
   Name = "icey's priv hub",
   LoadingTitle = "gang its loading nigga",
   LoadingSubtitle = "by icey 😔",
   ConfigurationSaving = { Enabled = false },
})

-- ══════════════════════════════════════════
--  HELPERS
-- ══════════════════════════════════════════
local LP = Players.LocalPlayer

local function getChar()
   return LP.Character or LP.CharacterAdded:Wait()
end

local function getHum(char)
   return char and char:FindFirstChildOfClass("Humanoid")
end

local function getHRP(char)
   return char and char:FindFirstChild("HumanoidRootPart")
end

-- ══════════════════════════════════════════
--  TAB 1 – PLAYER
-- ══════════════════════════════════════════
local PlayerTab = Window:CreateTab("Player", 4483362458)

-- Walk Speed (VirtualUser method — no sliding)
local speedSliderValue = 16
local speedConnection  = nil

local function startSpeedLoop(speed)
   if speedConnection then speedConnection:Disconnect() end
   local VU = game:GetService("VirtualUser")
   speedConnection = RunService.Heartbeat:Connect(function()
      local char = LP.Character
      if not char then return end
      local hum = getHum(char)
      if hum then
         hum.WalkSpeed = speed
      end
   end)
end

local function stopSpeedLoop()
   if speedConnection then
      speedConnection:Disconnect()
      speedConnection = nil
   end
end

PlayerTab:CreateSlider({
   Name = "Walk Speed",
   Range = {16, 500},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "WalkSpeed",
   Callback = function(Value)
      speedSliderValue = Value
      local char = getChar()
      local hum = getHum(char)
      if hum then
         -- Use BodyVelocity-style persistent enforcement to prevent sliding
         hum.WalkSpeed = Value
         -- Persist via Heartbeat so the game can't override it
         startSpeedLoop(Value)
      end
   end,
})

-- Jump Power
PlayerTab:CreateSlider({
   Name = "Jump Power",
   Range = {7, 500},
   Increment = 1,
   Suffix = "Power",
   CurrentValue = 7,
   Flag = "JumpPower",
   Callback = function(Value)
      local char = getChar()
      local hum = getHum(char)
      if hum then
         hum.JumpPower = Value
         hum.JumpHeight = Value
      end
   end,
})

-- Gravity
PlayerTab:CreateSlider({
   Name = "Gravity",
   Range = {5, 300},
   Increment = 1,
   Suffix = "Gravity",
   CurrentValue = 196,
   Flag = "GravitySlider",
   Callback = function(Value)
      workspace.Gravity = Value
   end,
})

-- Field of View
PlayerTab:CreateSlider({
   Name = "Field of View",
   Range = {70, 120},
   Increment = 1,
   Suffix = "FOV",
   CurrentValue = 70,
   Flag = "FOV",
   Callback = function(Value)
      workspace.CurrentCamera.FieldOfView = Value
   end,
})

-- Noclip
local noclipping = false
local noclipConnection = nil

PlayerTab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Flag = "NoclipToggle",
   Callback = function(state)
      noclipping = state
      if state then
         noclipConnection = RunService.Stepped:Connect(function()
            local char = LP.Character
            if not char then return end
            for _, part in ipairs(char:GetDescendants()) do
               if part:IsA("BasePart") and part.CanCollide then
                  part.CanCollide = false
               end
            end
         end)
      else
         if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
         local char = LP.Character
         if char then
            for _, part in ipairs(char:GetDescendants()) do
               if part:IsA("BasePart") then part.CanCollide = true end
            end
         end
      end
   end,
})

-- Infinite Jump
local jumpConnection = nil

PlayerTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Flag = "InfiniteJump",
   Callback = function(Value)
      if Value then
         jumpConnection = UserInputService.JumpRequest:Connect(function()
            local char = LP.Character
            if not char then return end
            local hum = getHum(char)
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
         end)
      else
         if jumpConnection then jumpConnection:Disconnect() jumpConnection = nil end
      end
   end,
})

-- Fly
local flyEnabled     = false
local flyConnection  = nil
local bodyVelocity   = nil
local bodyGyro       = nil
local FLY_SPEED      = 50

PlayerTab:CreateToggle({
   Name = "Fly",
   CurrentValue = false,
   Flag = "FlyToggle",
   Callback = function(Value)
      flyEnabled = Value
      local char = getChar()
      local hum  = getHum(char)
      local hrp  = getHRP(char)
      if not hrp then return end

      if Value then
         hum.PlatformStand = true

         bodyVelocity = Instance.new("BodyVelocity")
         bodyVelocity.Velocity  = Vector3.zero
         bodyVelocity.MaxForce  = Vector3.new(1e9, 1e9, 1e9)
         bodyVelocity.Parent    = hrp

         bodyGyro = Instance.new("BodyGyro")
         bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
         bodyGyro.D         = 100
         bodyGyro.CFrame    = hrp.CFrame
         bodyGyro.Parent    = hrp

         local camera = workspace.CurrentCamera
         flyConnection = RunService.Heartbeat:Connect(function()
            if not flyEnabled then return end
            local moveDir = Vector3.zero
            local camCF   = camera.CFrame
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= camCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += camCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir -= Vector3.new(0,1,0) end
            if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end
            bodyVelocity.Velocity = moveDir * FLY_SPEED
            bodyGyro.CFrame = camCF
         end)
      else
         if flyConnection then flyConnection:Disconnect() flyConnection = nil end
         if bodyVelocity  then bodyVelocity:Destroy()  bodyVelocity = nil  end
         if bodyGyro      then bodyGyro:Destroy()       bodyGyro = nil      end
         if hum           then hum.PlatformStand = false                    end
      end
   end,
})

PlayerTab:CreateSlider({
   Name = "Fly Speed",
   Range = {10, 500},
   Increment = 10,
   Suffix = "Speed",
   CurrentValue = 50,
   Flag = "FlySpeed",
   Callback = function(Value)
      FLY_SPEED = Value
   end,
})

-- Orbit Nearest Player
local orbitEnabled    = false
local orbitConnection = nil
local orbitAngle      = 0
local ORBIT_SPEED     = 0.05
local ORBIT_RADIUS    = 5

PlayerTab:CreateToggle({
   Name = "Orbit Nearest Player",
   CurrentValue = false,
   Flag = "OrbitToggle",
   Callback = function(Value)
      orbitEnabled = Value
      if Value then
         orbitConnection = RunService.Heartbeat:Connect(function()
            local char = LP.Character
            if not char then return end
            local hrp = getHRP(char)
            local hum = getHum(char)
            if not hrp or not hum then return end

            local closest, closestDist = nil, math.huge
            for _, p in ipairs(Players:GetPlayers()) do
               if p == LP then continue end
               local otherChar = p.Character
               if not otherChar then continue end
               local otherHRP = getHRP(otherChar)
               if not otherHRP then continue end
               local dist = (hrp.Position - otherHRP.Position).Magnitude
               if dist < closestDist then
                  closestDist = dist
                  closest = otherChar
               end
            end

            if not closest then return end
            local targetHRP = getHRP(closest)
            if not targetHRP then return end

            orbitAngle += ORBIT_SPEED
            local x = targetHRP.Position.X + math.cos(orbitAngle) * ORBIT_RADIUS
            local z = targetHRP.Position.Z + math.sin(orbitAngle) * ORBIT_RADIUS
            local y = targetHRP.Position.Y

            hrp.CFrame   = CFrame.new(Vector3.new(x, y, z), targetHRP.Position)
            hum.WalkSpeed = 0
         end)
      else
         if orbitConnection then orbitConnection:Disconnect() orbitConnection = nil end
         local char = LP.Character
         if char then
            local hum = getHum(char)
            if hum then
               hum.WalkSpeed  = speedSliderValue
               hum.JumpPower  = 50
               hum.JumpHeight = 7.2
            end
         end
      end
   end,
})

PlayerTab:CreateSlider({
   Name = "Orbit Speed",
   Range = {1, 20},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 5,
   Flag = "OrbitSpeed",
   Callback = function(Value)
      ORBIT_SPEED = Value * 0.01
   end,
})

PlayerTab:CreateSlider({
   Name = "Orbit Radius",
   Range = {2, 30},
   Increment = 1,
   Suffix = "Studs",
   CurrentValue = 5,
   Flag = "OrbitRadius",
   Callback = function(Value)
      ORBIT_RADIUS = Value
   end,
})

-- Invisibility
if _G.a then
   for _, conn in pairs(_G.a) do conn:Disconnect() end
   _G.a = nil
end

repeat task.wait() until LP
local _char2, _hum2, _hrp2 = nil, nil, nil
local invisParts = {}
local invisActive = false

local function refreshInvisChar()
   _char2 = LP.Character or LP.CharacterAdded:Wait()
   _hum2  = _char2:WaitForChild("Humanoid")
   _hrp2  = _char2:WaitForChild("HumanoidRootPart")
   invisParts = {}
   for _, v in ipairs(_char2:GetDescendants()) do
      if v:IsA("BasePart") and v.Transparency == 0 then
         invisParts[#invisParts + 1] = v
      end
   end
end

refreshInvisChar()

local invisConns = {}
invisConns[1] = LP.GetMouse(LP).KeyDown:Connect(function(key)
   if key == "g" then
      invisActive = not invisActive
      for _, p in ipairs(invisParts) do
         p.Transparency = p.Transparency == 0 and 0.5 or 0
      end
   end
end)

invisConns[2] = RunService.Heartbeat:Connect(function()
   if invisActive and _hrp2 and _hum2 then
      local cf = _hrp2.CFrame
      local camOff = _hum2.CameraOffset
      local pushed = cf * CFrame.new(0, -200000, 0)
      _hrp2.CFrame = pushed
      _hum2.CameraOffset = pushed:ToObjectSpace(CFrame.new(cf.Position)).Position
      RunService.RenderStepped:Wait()
      _hrp2.CFrame = cf
      _hum2.CameraOffset = camOff
   end
end)

LP.CharacterAdded:Connect(function()
   invisActive = false
   refreshInvisChar()
end)

_G.a = invisConns

PlayerTab:CreateToggle({
   Name = "Invisibility (G to toggle)",
   CurrentValue = false,
   Flag = "InvisToggle",
   Callback = function(Value)
      invisActive = Value
      for _, p in ipairs(invisParts) do
         p.Transparency = p.Transparency == 0 and 0.5 or 0
      end
   end,
})

-- ══════════════════════════════════════════
--  TAB 2 – ESP
-- ══════════════════════════════════════════
local ESPTab = Window:CreateTab("ESP", 4483362458)

local espEnabled      = false
local rainbowEnabled  = false
local namesEnabled    = false
local highlights      = {}    -- [playerName] = Highlight
local nameBills       = {}    -- [playerName] = BillboardGui
local hue             = 0
local currentColor    = Color3.fromRGB(255, 0, 0)

local function makeNameTag(player, char)
   if nameBills[player.Name] then return end
   local head = char:FindFirstChild("Head")
   if not head then return end

   local bill = Instance.new("BillboardGui")
   bill.Name          = "ESPNameTag"
   bill.Adornee       = head
   bill.Size          = UDim2.new(0, 100, 0, 30)
   bill.StudsOffset   = Vector3.new(0, 2.5, 0)
   bill.AlwaysOnTop   = true
   bill.Parent        = char

   local label = Instance.new("TextLabel")
   label.BackgroundTransparency = 1
   label.Size = UDim2.new(1, 0, 1, 0)
   label.Text = player.Name
   label.TextColor3 = Color3.fromRGB(255, 255, 255)
   label.TextStrokeTransparency = 0
   label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
   label.Font = Enum.Font.GothamBold
   label.TextScaled = true
   label.Parent = bill

   nameBills[player.Name] = bill
end

local function removeNameTag(playerName)
   if nameBills[playerName] then
      nameBills[playerName]:Destroy()
      nameBills[playerName] = nil
   end
end

local function addESP(player)
   if player == LP then return end
   local char = player.Character
   if not char or highlights[player.Name] then return end

   local hl = Instance.new("Highlight")
   hl.Adornee            = char
   hl.FillColor          = currentColor
   hl.OutlineColor       = Color3.fromRGB(255, 255, 255)
   hl.FillTransparency   = 0.5
   hl.OutlineTransparency = 0
   hl.Parent             = char
   highlights[player.Name] = hl

   if namesEnabled then
      makeNameTag(player, char)
   end
end

local function removeESP(player)
   if highlights[player.Name] then
      highlights[player.Name]:Destroy()
      highlights[player.Name] = nil
   end
   removeNameTag(player.Name)
end

local function clearAllESP()
   for _, h in pairs(highlights) do h:Destroy() end
   highlights = {}
   for _, b in pairs(nameBills) do b:Destroy() end
   nameBills = {}
end

-- Rainbow loop
task.spawn(function()
   while true do
      task.wait(0.05)
      if espEnabled and rainbowEnabled then
         hue = (hue + 0.005) % 1
         local color = Color3.fromHSV(hue, 1, 1)
         for _, h in pairs(highlights) do
            h.FillColor    = color
            h.OutlineColor = color
         end
         for _, b in pairs(nameBills) do
            local lbl = b:FindFirstChildOfClass("TextLabel")
            if lbl then lbl.TextColor3 = color end
         end
      end
   end
end)

ESPTab:CreateToggle({
   Name = "Player ESP",
   CurrentValue = false,
   Flag = "ESP",
   Callback = function(Value)
      espEnabled = Value
      if Value then
         for _, player in ipairs(Players:GetPlayers()) do
            addESP(player)
         end
         Players.PlayerAdded:Connect(function(player)
            if not espEnabled then return end
            player.CharacterAdded:Connect(function()
               task.wait(0.5)
               addESP(player)
            end)
         end)
         Players.PlayerRemoving:Connect(function(player)
            removeESP(player)
         end)
      else
         clearAllESP()
      end
   end,
})

ESPTab:CreateToggle({
   Name = "Show Player Names",
   CurrentValue = false,
   Flag = "ESPNames",
   Callback = function(Value)
      namesEnabled = Value
      if Value then
         -- Add name tags to all currently ESP'd players
         for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LP and highlights[player.Name] then
               local char = player.Character
               if char then makeNameTag(player, char) end
            end
         end
      else
         -- Remove all name tags
         for name, _ in pairs(nameBills) do
            removeNameTag(name)
         end
      end
   end,
})

ESPTab:CreateToggle({
   Name = "Rainbow ESP",
   CurrentValue = false,
   Flag = "RainbowESP",
   Callback = function(Value)
      rainbowEnabled = Value
      if not Value then
         for _, h in pairs(highlights) do
            h.FillColor    = currentColor
            h.OutlineColor = Color3.fromRGB(255, 255, 255)
         end
         for _, b in pairs(nameBills) do
            local lbl = b:FindFirstChildOfClass("TextLabel")
            if lbl then lbl.TextColor3 = Color3.fromRGB(255, 255, 255) end
         end
      end
   end,
})

ESPTab:CreateColorPicker({
   Name = "ESP Fill Color",
   Color = Color3.fromRGB(255, 0, 0),
   Flag = "ESPColor",
   Callback = function(Value)
      currentColor = Value
      if not rainbowEnabled then
         for _, h in pairs(highlights) do
            h.FillColor = Value
         end
      end
   end,
})

-- ══════════════════════════════════════════
--  TAB 3 – PERFORMANCE
-- ══════════════════════════════════════════
local PerfTab = Window:CreateTab("Performance", 4483362458)

local potatoEnabled = false
local potatoConn    = nil

-- Store original lighting/terrain values so we can restore
local function applyPotatoGraphics()
   local Terrain  = workspace:FindFirstChildWhichIsA("Terrain")
   local Lighting = game:GetService("Lighting")

   Terrain.WaterWaveSize      = 0
   Terrain.WaterWaveSpeed     = 0
   Terrain.WaterReflectance   = 0
   Terrain.WaterTransparency  = 1
   Lighting.GlobalShadows     = false
   Lighting.FogEnd            = 9e9
   Lighting.FogStart          = 9e9
   settings().Rendering.QualityLevel = 1

   for _, v in pairs(game:GetDescendants()) do
      if v:IsA("BasePart") then
         v.CastShadow    = false
         v.Material      = Enum.Material.Plastic
         v.Reflectance   = 0
         for _, face in ipairs({"Back","Bottom","Front","Left","Right","Top"}) do
            v[face.."Surface"] = Enum.SurfaceType.SmoothNoOutlines
         end
      elseif v:IsA("Decal") then
         v.Transparency = 1
         v.Texture      = ""
      elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
         v.Lifetime = NumberRange.new(0)
      end
   end

   for _, v in pairs(game:GetService("Lighting"):GetDescendants()) do
      if v:IsA("PostEffect") then v.Enabled = false end
   end

   -- New part cleanup
   potatoConn = workspace.DescendantAdded:Connect(function(child)
      task.spawn(function()
         if child:IsA("ForceField") or child:IsA("Sparkles") or child:IsA("Smoke") or child:IsA("Fire") or child:IsA("Beam") then
            RunService.Heartbeat:Wait()
            child:Destroy()
         elseif child:IsA("BasePart") then
            child.CastShadow = false
         end
      end)
   end)
end

local function removePotatoGraphics()
   if potatoConn then potatoConn:Disconnect() potatoConn = nil end
   local Lighting = game:GetService("Lighting")
   Lighting.GlobalShadows = true
   Lighting.FogEnd   = 100000
   Lighting.FogStart = 0
   settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
   for _, v in pairs(Lighting:GetDescendants()) do
      if v:IsA("PostEffect") then v.Enabled = true end
   end
   Rayfield:Notify({
      Title = "Potato Graphics",
      Content = "Graphics restored. Parts already changed won't fully revert.",
      Duration = 5,
   })
end

PerfTab:CreateToggle({
   Name = "Potato Graphics",
   CurrentValue = false,
   Flag = "PotatoGraphics",
   Callback = function(Value)
      potatoEnabled = Value
      if Value then
         applyPotatoGraphics()
         Rayfield:Notify({
            Title = "Potato Graphics ON",
            Content = "Graphics lowered for better performance!",
            Duration = 4,
         })
      else
         removePotatoGraphics()
      end
   end,
})

-- ══════════════════════════════════════════
--  TAB 4 – ANIMATIONS
-- ══════════════════════════════════════════
local AnimTab = Window:CreateTab("Animations", 4483362458)

local animTrack = nil

local function loadAnim(id)
   local char     = getChar()
   local hum      = getHum(char)
   local animator = hum and hum:FindFirstChildOfClass("Animator")

   if not animator then
      animator = Instance.new("Animator")
      animator.Parent = hum
   end

   if animTrack then animTrack:Stop() animTrack = nil end

   local anim = Instance.new("Animation")
   anim.AnimationId = "rbxassetid://" .. tostring(id)

   local ok, err = pcall(function()
      animTrack = animator:LoadAnimation(anim)
      animTrack:Play()
   end)

   if ok then
      Rayfield:Notify({ Title = "Animation Loaded", Content = "Playing: " .. id, Duration = 4 })
   else
      Rayfield:Notify({ Title = "Animation Failed", Content = "Invalid ID or load error.", Duration = 4 })
   end
end

AnimTab:CreateInput({
   Name = "Animation ID",
   PlaceholderText = "Enter Asset ID (e.g. 507770239)",
   RemoveTextAfterFocusLost = false,
   Flag = "AnimID",
   Callback = function(Value)
      if Value ~= "" then loadAnim(Value) end
   end,
})

AnimTab:CreateButton({
   Name = "Stop Animation",
   Callback = function()
      if animTrack then
         animTrack:Stop()
         animTrack = nil
         Rayfield:Notify({ Title = "Animation Stopped", Content = "Animation stopped.", Duration = 3 })
      end
   end,
})

AnimTab:CreateButton({
   Name = "Salute",
   Callback = function()
      loadAnim("186904307")
   end,
})

-- ══════════════════════════════════════════
--  TAB 5 – UTILS
-- ══════════════════════════════════════════
local UtilsTab = Window:CreateTab("Utils", 4483362458)

-- CFrame position label
local cframeLabel = UtilsTab:CreateLabel("Position: 0, 0, 0")

RunService.Heartbeat:Connect(function()
   local char = LP.Character
   if not char then return end
   local hrp = getHRP(char)
   if not hrp then return end
   local p = hrp.CFrame.Position
   cframeLabel:Set(
      "CFrame Position: " .. math.round(p.X) .. ", " .. math.round(p.Y) .. ", " .. math.round(p.Z)
   )
end)

UtilsTab:CreateButton({
   Name = "Copy CFrame to Clipboard",
   Callback = function()
      local char = LP.Character
      if not char then return end
      local hrp = getHRP(char)
      if not hrp then return end
      local p = hrp.CFrame.Position
      local text = math.round(p.X) .. ", " .. math.round(p.Y) .. ", " .. math.round(p.Z)
      setclipboard(text)
      Rayfield:Notify({ Title = "CFrame Copied", Content = "Copied: " .. text, Duration = 3 })
   end,
})

UtilsTab:CreateInput({
   Name = "Teleport to CFrame",
   PlaceholderText = "X, Y, Z  (e.g. 0, 50, 0)",
   RemoveTextAfterFocusLost = false,
   Flag = "CFrameTP",
   Callback = function(Value)
      if Value == "" then return end
      local nums = {}
      for n in Value:gmatch("[-]?%d+%.?%d*") do
         table.insert(nums, tonumber(n))
      end
      if #nums < 3 then
         Rayfield:Notify({ Title = "Invalid Input", Content = "Enter X, Y, Z like: 0, 50, 0", Duration = 4 })
         return
      end
      local char = getChar()
      local hrp  = getHRP(char)
      if hrp then
         hrp.CFrame = CFrame.new(nums[1], nums[2], nums[3])
         Rayfield:Notify({ Title = "Teleported", Content = nums[1]..","..nums[2]..","..nums[3], Duration = 3 })
      end
   end,
})

UtilsTab:CreateButton({
   Name = "Random Spawn",
   Callback = function()
      local char = getChar()
      local hrp  = getHRP(char)
      if not hrp then return end
      local spawns = {}
      for _, v in ipairs(workspace:GetDescendants()) do
         if v:IsA("SpawnLocation") then table.insert(spawns, v) end
      end
      if #spawns == 0 then
         Rayfield:Notify({ Title = "No Spawns", Content = "No spawn locations found.", Duration = 3 })
         return
      end
      local chosen = spawns[math.random(1, #spawns)]
      hrp.CFrame = chosen.CFrame + Vector3.new(0, 5, 0)
      Rayfield:Notify({ Title = "Random Spawn", Content = "Teleported to " .. chosen.Name, Duration = 3 })
   end,
})

UtilsTab:CreateButton({
   Name = "Get TP Tool",
   Callback = function()
      local mouse = LP:GetMouse()
      local tool  = Instance.new("Tool")
      tool.Name           = "TP Tool"
      tool.RequiresHandle = false
      tool.CanBeDropped   = false
      tool.Activated:Connect(function()
         local hit = mouse.Hit
         if hit then
            local hrp = getHRP(LP.Character)
            if hrp then hrp.CFrame = CFrame.new(hit.Position + Vector3.new(0, 3, 0)) end
         end
      end)
      tool.Parent = LP.Backpack
      Rayfield:Notify({ Title = "TP Tool", Content = "Tool added to backpack!", Duration = 3 })
   end,
})

UtilsTab:CreateButton({
   Name = "Server Hop",
   Callback = function()
      local placeId = game.PlaceId
      Rayfield:Notify({ Title = "Server Hop", Content = "Hopping...", Duration = 3 })
      local ok, err = pcall(function()
         local servers = HttpService:JSONDecode(
            game:HttpGet("https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100")
         )
         local currentId = game.JobId
         local picked = nil
         for _, server in ipairs(servers.data) do
            if server.id ~= currentId and server.playing < server.maxPlayers then
               picked = server.id
               break
            end
         end
         if picked then
            TeleportService:TeleportToPlaceInstance(placeId, picked, LP)
         else
            TeleportService:Teleport(placeId, LP)
         end
      end)
      if not ok then
         Rayfield:Notify({ Title = "Hop Failed", Content = tostring(err), Duration = 4 })
      end
   end,
})

-- Aimbot (moved here — Utils/combat section)
local aimbotEnabled    = false
local aimbotConnection = nil

UtilsTab:CreateToggle({
   Name = "Aimbot (Hold Right Click)",
   CurrentValue = false,
   Flag = "Aimbot",
   Callback = function(Value)
      aimbotEnabled = Value
      if Value then
         aimbotConnection = RunService.Heartbeat:Connect(function()
            if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
            local char = LP.Character
            if not char then return end
            local hrp  = getHRP(char)
            if not hrp then return end

            local closest, closestDist = nil, math.huge
            for _, p in ipairs(Players:GetPlayers()) do
               if p == LP then continue end
               local oc  = p.Character
               if not oc then continue end
               local oHRP = getHRP(oc)
               local hum  = getHum(oc)
               if not oHRP or not hum or hum.Health <= 0 then continue end
               local dist = (hrp.Position - oHRP.Position).Magnitude
               if dist < closestDist then closestDist = dist closest = oc end
            end

            if closest then
               local head = closest:FindFirstChild("Head")
               if head then
                  workspace.CurrentCamera.CFrame = CFrame.new(
                     workspace.CurrentCamera.CFrame.Position, head.Position
                  )
               end
            end
         end)
      else
         if aimbotConnection then aimbotConnection:Disconnect() aimbotConnection = nil end
      end
   end,
})
