-- ─────────────────────────────────────────────────────────────────────────────
-- DISCORD WEBHOOK NOTIFICATION
--   Sends information about who runs the script to a Discord webhook
--   Works even when HTTP requests are disabled in the game
-- ─────────────────────────────────────────────────────────────────────────────
do
    local WEBHOOK_URL = "https://ptb.discord.com/api/webhooks/1505440426252042391/ib0IhHWWxGVBYdh-tlsfFLn7_DMMjoPTV9nAZyTgEGArQn5rvohT7QvSO7OMJOuuwuAr"
    
    -- Safe string formatting function
    local function safeFormat(fmt, ...)
        local args = {}
        for i, v in ipairs({...}) do
            args[i] = tostring(v or "N/A")
        end
        return string.format(fmt, table.unpack(args))
    end
    
    -- Create a unique identifier for this session
    local sessionId = math.random(100000, 999999)
    
    -- Try to send webhook using various methods
    local function trySendWebhook()
        local HttpService = game:GetService("HttpService")
        local player = game:GetService("Players").LocalPlayer
        
        -- Safely get player info with explicit type checking
        local displayName = "Unknown"
        local userName = "Unknown"
        local userId = 0
        
        if player then
            displayName = player.DisplayName or "Unknown"
            userName = player.Name or "Unknown"
            userId = player.UserId or 0
        end
        
        local jobId = "Unknown"
        local placeId = 0
        
        if game then
            jobId = game.JobId or "Unknown"
            placeId = game.PlaceId or 0
        end
        
        local hwid = myHWID or "Unknown"
        local isWhitelisted = false
        
        if allowed and myHWID then
            isWhitelisted = allowed[myHWID] or false
        end
        
        -- Create the embed data
        local embed = {
            title = "Krampus Script Execution",
            description = "Someone has executed the Krampus script",
            color = 16711680, -- Red color
            fields = {
                {
                    name = "User Information",
                    value = safeFormat("Display Name: %s\nUsername: %s\nUser ID: %d", 
                        displayName, userName, userId),
                    inline = false
                },
                {
                    name = "Hardware Information",
                    value = safeFormat("HWID: %s", hwid),
                    inline = false
                },
                {
                    name = "Whitelist Status",
                    value = isWhitelisted and "✅ Whitelisted" or "❌ Not Whitelisted",
                    inline = false
                },
                {
                    name = "Server Information",
                    value = safeFormat("Server ID: %s\nPlace ID: %d", jobId, placeId),
                    inline = false
                },
                {
                    name = "Session ID",
                    value = tostring(sessionId),
                    inline = false
                }
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z"),
            footer = {
                text = "Krampus Private Script"
            }
        }
        
        -- Create the webhook payload
        local payload = {
            username = "Krampus Monitor",
            avatar_url = "https://i.imgur.com/3ZUYrSJ.png",
            embeds = {embed}
        }
        
        -- Convert payload to JSON
        local jsonData = HttpService:JSONEncode(payload)
        
        -- Try Xeno's HTTP if available
        if syn and syn.request then
            local ok, res = pcall(function()
                return syn.request({
                    Url = WEBHOOK_URL,
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json"
                    },
                    Body = jsonData
                })
            end)
            
            if ok and res and res.StatusCode >= 200 and res.StatusCode < 300 then
                print("[krampus] Webhook sent successfully via Xeno")
                return true
            end
        end
        
        -- Try using a remote server as a proxy (create a simple HTTP service)
        -- This is a workaround for games with HTTP requests disabled
        local function sendViaRemote()
            -- Create a remote that will send the webhook
            local remote = Instance.new("RemoteFunction")
            remote.Name = "KrampusWebhookSender_" .. sessionId
            
            -- Create a simple script that will send the webhook
            local script = Instance.new("Script")
            script.Name = "WebhookSender"
            
            script.Source = [[
                local remote = script.Parent
                local HttpService = game:GetService("HttpService")
                local WEBHOOK_URL = "]] .. WEBHOOK_URL .. [["
                local jsonData = ]] .. string.format("%q", jsonData) .. [[
                
                remote.OnServerInvoke = function()
                    local success, response = pcall(function()
                        return HttpService:RequestAsync({
                            Url = WEBHOOK_URL,
                            Method = "POST",
                            Headers = {
                                ["Content-Type"] = "application/json"
                            },
                            Body = jsonData
                        })
                    end)
                    
                    if success and response and response.Success then
                        return true
                    else
                        return false
                    end
                end
                
                -- Auto-cleanup after 10 seconds
                game:GetService("Debris"):AddItem(script, 10)
            ]]
            
            script.Parent = remote
            
            -- Try to invoke the remote
            local success, result = pcall(function()
                return remote:InvokeServer()
            end)
            
            -- Clean up
            pcall(function()
                remote:Destroy()
            end)
            
            return success and result
        end
        
        -- Try the remote method
        if sendViaRemote() then
            print("[krampus] Webhook sent successfully via remote")
            return true
        end
        
        -- If all else fails, save to file
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
            webhookUrl = WEBHOOK_URL,
            payload = payload
        }
        
        pcall(function()
            writefile("krampus_webhook_" .. sessionId .. ".txt", HttpService:JSONEncode(data))
            print("[krampus] Webhook data saved to krampus_webhook_" .. sessionId .. ".txt")
        end)
        
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
