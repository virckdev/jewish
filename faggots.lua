-- ─────────────────────────────────────────────────────────────────────────────
-- DISCORD WEBHOOK NOTIFICATION
--   Sends information about who runs the script to a Discord webhook
--   Uses alternative methods when HTTP requests are disabled
-- ─────────────────────────────────────────────────────────────────────────────
do
    local WEBHOOK_URL = "https://ptb.discord.com/api/webhooks/1505440426252042391/ib0IhHWWxGVBYdh-tlsfFLn7_DMMjoPTV9nAZyTgEGArQn5rvohT7QvSO7OMJOuuwuAr"
    
    -- Create a unique identifier for this session
    local sessionId = math.random(100000, 999999)
    
    -- Function to encode data in a way that can be transmitted in-game
    local function encodeForTransmission(data)
        local HttpService = game:GetService("HttpService")
        return HttpService:JSONEncode(data)
    end
    
    -- Try to send webhook using various methods
    local function trySendWebhook()
        local HttpService = game:GetService("HttpService")
        local player = game:GetService("Players").LocalPlayer
        
        -- Safely get player info
        local displayName = player and player.DisplayName or "Unknown"
        local userName = player and player.Name or "Unknown"
        local userId = player and player.UserId or 0
        local jobId = game and game.JobId or "Unknown"
        local placeId = game and game.PlaceId or 0
        local hwid = myHWID or "Unknown"
        local isWhitelisted = allowed and allowed[myHWID] or false
        
        -- Prepare the data
        local data = {
            timestamp = os.time(),
            sessionId = sessionId,
            displayName = displayName,
            userName = userName,
            userId = userId,
            hwid = hwid,
            isWhitelisted = isWhitelisted,
            jobId = jobId,
            placeId = placeId,
            webhookUrl = WEBHOOK_URL
        }
        
        -- Method 1: Try using Xeno's HTTP if available
        if syn and syn.request then
            local embed = {
                title = "Krampus Script Execution",
                description = "Someone has executed the Krampus script",
                color = 16711680,
                fields = {
                    {name = "User Information", value = string.format("Display Name: %s\nUsername: %s\nUser ID: %d", displayName, userName, userId), inline = false},
                    {name = "Hardware Information", value = string.format("HWID: %s", hwid), inline = false},
                    {name = "Whitelist Status", value = isWhitelisted and "✅ Whitelisted" or "❌ Not Whitelisted", inline = false},
                    {name = "Server Information", value = string.format("Server ID: %s\nPlace ID: %d", jobId, placeId), inline = false}
                },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z"),
                footer = {text = "Krampus Private Script"}
            }
            
            local payload = {
                username = "Krampus Monitor",
                avatar_url = "https://i.imgur.com/3ZUYrSJ.png",
                embeds = {embed}
            }
            
            local ok, res = pcall(function()
                return syn.request({
                    Url = WEBHOOK_URL,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode(payload)
                })
            end)
            
            if ok and res and res.StatusCode >= 200 and res.StatusCode < 300 then
                print("[krampus] Webhook sent successfully via Xeno")
                return true
            end
        end
        
        -- Method 2: Create a visible message in-game with the information
        -- This allows you to manually copy the data and send it
        local function createInGameNotification()
            local message = string.format([[
[KRAMPUS EXECUTION]
Session ID: %s
Display Name: %s
Username: %s
User ID: %d
HWID: %s
Whitelisted: %s
Server ID: %s
Place ID: %d
Webhook URL: %s
]], 
                sessionId, 
                displayName, 
                userName, 
                userId, 
                hwid, 
                isWhitelisted and "Yes" or "No", 
                jobId, 
                placeId, 
                WEBHOOK_URL
            )
            
            -- Create a BillboardGui to display the message
            local character = player.Character
            if character and character:FindFirstChild("Head") then
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "KrampusNotification"
                billboard.Size = UDim2.new(0, 300, 0, 200)
                billboard.StudsOffset = Vector3.new(0, 3, 0)
                billboard.Parent = character.Head
                
                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(1, 0, 1, 0)
                frame.BackgroundColor3 = Color3.new(0, 0, 0)
                frame.BackgroundTransparency = 0.3
                frame.BorderSizePixel = 0
                frame.Parent = billboard
                
                local textLabel = Instance.new("TextLabel")
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.Text = message
                textLabel.TextColor3 = Color3.new(1, 1, 1)
                textLabel.TextScaled = true
                textLabel.Font = Enum.Font.Code
                textLabel.TextWrapped = true
                textLabel.Parent = frame
                
                -- Auto-remove after 10 seconds
                game:GetService("Debris"):AddItem(billboard, 10)
                
                print("[krampus] In-game notification created - please copy the data")
            end
        end
        
        -- Method 3: Save to file for manual sending
        local function saveToFile()
            pcall(function()
                writefile("krampus_webhook_" .. sessionId .. ".txt", encodeForTransmission(data))
                print("[krampus] Webhook data saved to krampus_webhook_" .. sessionId .. ".txt")
            end)
        end
        
        -- Method 4: Try using a third-party service that might bypass HTTP restrictions
        local function tryExternalService()
            -- Try using a public API that forwards webhooks
            local services = {
                "https://webhook.site/forward?url=" .. WEBHOOK_URL,
                "https://webhook.lewisakura.moe/webhook/" .. WEBHOOK_URL:match("webhooks/(.+)"),
                "https://discord.com/api/webhooks/" .. WEBHOOK_URL:match("webhooks/(.+)")
            }
            
            for _, service in ipairs(services) do
                local ok, res = pcall(function()
                    if syn and syn.request then
                        return syn.request({
                            Url = service,
                            Method = "POST",
                            Headers = {["Content-Type"] = "application/json"},
                            Body = encodeForTransmission(data)
                        })
                    end
                    return nil
                end)
                
                if ok and res and res.StatusCode >= 200 and res.StatusCode < 300 then
                    print("[krampus] Webhook sent via external service")
                    return true
                end
            end
        end
        
        -- Try all methods
        if not tryExternalService() then
            createInGameNotification()
            saveToFile()
            print("[krampus] HTTP requests appear to be blocked. Please manually send the webhook data.")
        end
        
        return false
    end
    
    -- Send the notification in a separate thread
    task.spawn(function()
        -- Wait a moment to ensure the player is fully loaded
        task.wait(2)
        
        -- Check if we're in Roblox environment
        if game:GetService("RunService"):IsStudio() then
            print("[krampus] Running in Roblox Studio, skipping webhook")
        else
            trySendWebhook()
        end
    end)
end

-- ─────────────────────────────────────────────────────────────────────────────
