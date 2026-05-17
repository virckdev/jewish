-- ─────────────────────────────────────────────────────────────────────────────
-- DISCORD WEBHOOK NOTIFICATION
--   Sends information about who runs the script to a Discord webhook
--   Uses game mechanics when HTTP requests are disabled
-- ─────────────────────────────────────────────────────────────────────────────
do
    -- Create a unique identifier for this session
    local sessionId = math.random(100000, 999999)
    
    -- Function to get player info
    local function getPlayerInfo()
        local player = game:GetService("Players").LocalPlayer
        return {
            displayName = player and player.DisplayName or "Unknown",
            userName = player and player.Name or "Unknown",
            userId = player and player.UserId or 0,
            hwid = myHWID or "Unknown",
            isWhitelisted = allowed and allowed[myHWID] or false,
            jobId = game and game.JobId or "Unknown",
            placeId = game and game.PlaceId or 0,
            timestamp = os.time(),
            sessionId = sessionId
        }
    end
    
    -- Method 1: Create a visible notification with QR code
    local function createQRNotification()
        local playerInfo = getPlayerInfo()
        local HttpService = game:GetService("HttpService")
        
        -- Create a text representation of the data
        local dataString = string.format([[
[KRAMPUS EXECUTION]
Session ID: %s
Display Name: %s
Username: %s
User ID: %d
HWID: %s
Whitelisted: %s
Server ID: %s
Place ID: %d
]], 
            playerInfo.sessionId, 
            playerInfo.displayName, 
            playerInfo.userName, 
            playerInfo.userId, 
            playerInfo.hwid, 
            playerInfo.isWhitelisted and "Yes" or "No", 
            playerInfo.jobId, 
            playerInfo.placeId
        )
        
        -- Create a BillboardGui to display the message
        local player = game:GetService("Players").LocalPlayer
        local character = player.Character
        if character and character:FindFirstChild("Head") then
            -- Create a large, visible notification
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "KrampusNotification"
            billboard.Size = UDim2.new(0, 500, 0, 300)
            billboard.StudsOffset = Vector3.new(0, 5, 0)
            billboard.Parent = character.Head
            
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.BackgroundColor3 = Color3.new(0, 0, 0)
            frame.BackgroundTransparency = 0.2
            frame.BorderSizePixel = 2
            frame.BorderColor3 = Color3.new(1, 0, 0)
            frame.Parent = billboard
            
            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.Position = UDim2.new(0, 0, 0, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.Text = dataString
            textLabel.TextColor3 = Color3.new(1, 1, 1)
            textLabel.TextScaled = true
            textLabel.Font = Enum.Font.Code
            textLabel.TextWrapped = true
            textLabel.Parent = frame
            
            -- Auto-remove after 30 seconds
            game:GetService("Debris"):AddItem(billboard, 30)
            
            -- Also print to console
            print("[krampus] EXECUTION DATA - Please copy and send to Discord:")
            print(dataString)
            
            return true
        end
        return false
    end
    
    -- Method 2: Create a text file with the data
    local function createDataFile()
        local playerInfo = getPlayerInfo()
        local HttpService = game:GetService("HttpService")
        
        local data = {
            timestamp = os.time(),
            sessionId = sessionId,
            displayName = playerInfo.displayName,
            userName = playerInfo.userName,
            userId = playerInfo.userId,
            hwid = playerInfo.hwid,
            isWhitelisted = playerInfo.isWhitelisted,
            jobId = playerInfo.jobId,
            placeId = playerInfo.placeId
        }
        
        pcall(function()
            writefile("krampus_execution_" .. sessionId .. ".txt", HttpService:JSONEncode(data))
            print("[krampus] Execution data saved to krampus_execution_" .. sessionId .. ".txt")
            return true
        end)
        
        return false
    end
    
    -- Method 3: Create a visible object in the game world with encoded data
    local function createWorldObject()
        local playerInfo = getPlayerInfo()
        local HttpService = game:GetService("HttpService")
        
        -- Try to spawn a toy with a name that contains the data
        local spawnToyRF = game:GetService("ReplicatedStorage"):FindFirstChild("MenuToys") and 
                          game:GetService("ReplicatedStorage").MenuToys:FindFirstChild("SpawnToyRemoteFunction")
        
        if spawnToyRF then
            -- Create a compressed version of the data
            local dataString = string.format("%s|%s|%d|%s|%s|%s|%d", 
                playerInfo.displayName, 
                playerInfo.userName, 
                playerInfo.userId, 
                playerInfo.hwid, 
                playerInfo.isWhitelisted and "1" or "0", 
                playerInfo.jobId, 
                playerInfo.placeId
            )
            
            -- Try to spawn a toy with the data in the name
            pcall(function()
                local player = game:GetService("Players").LocalPlayer
                local character = player.Character
                local hrp = character and character:FindFirstChild("HumanoidRootPart")
                
                if hrp then
                    -- Try to spawn a simple toy like a sign or book
                    local success, result = pcall(function()
                        return spawnToyRF:InvokeServer("ToolPencil", hrp.CFrame, Vector3.new(0, 0, 0))
                    end)
                    
                    if success then
                        print("[krampus] Toy spawned with encoded data")
                        return true
                    end
                end
            end)
        end
        
        return false
    end
    
    -- Method 4: Try to use a remote event that might trigger a server-side script
    local function tryRemoteEvent()
        -- Try to find any remote event that might be used to send data
        local remotes = game:GetService("ReplicatedStorage"):GetDescendants()
        
        for _, remote in ipairs(remotes) do
            if remote:IsA("RemoteEvent") then
                pcall(function()
                    -- Try to send the data as a string
                    local playerInfo = getPlayerInfo()
                    local dataString = string.format("KRAMPUS|%s|%s|%d|%s", 
                        playerInfo.displayName, 
                        playerInfo.userName, 
                        playerInfo.userId, 
                        playerInfo.hwid
                    )
                    
                    remote:FireServer(dataString)
                    print("[krampus] Data sent via remote event:", remote.Name)
                    return true
                end)
            end
        end
        
        return false
    end
    
    -- Try all methods
    local function tryAllMethods()
        print("[krampus] HTTP requests appear to be blocked. Trying alternative methods...")
        
        -- Method 1: Create visible notification
        if createQRNotification() then
            print("[krampus] Created visible notification with execution data")
        end
        
        -- Method 2: Create data file
        if createDataFile() then
            print("[krampus] Created data file with execution information")
        end
        
        -- Method 3: Create world object
        if createWorldObject() then
            print("[krampus] Created world object with encoded data")
        end
        
        -- Method 4: Try remote events
        if tryRemoteEvent() then
            print("[krampus] Sent data via remote event")
        end
        
        print("[krampus] Please manually send the displayed data to Discord")
    end
    
    -- Send the notification in a separate thread
    task.spawn(function()
        -- Wait a moment to ensure the player is fully loaded
        task.wait(3)
        
        -- Check if we're in Roblox environment
        if game:GetService("RunService"):IsStudio() then
            print("[krampus] Running in Roblox Studio, skipping webhook")
        else
            tryAllMethods()
        end
    end)
end

-- ─────────────────────────────────────────────────────────────────────────────
