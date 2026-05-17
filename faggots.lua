-- ─────────────────────────────────────────────────────────────────────────────
-- DISCORD WEBHOOK NOTIFICATION
--   Sends information about who runs the script to a Discord webhook
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
    
    -- Send the notification immediately with all needed data
    local function sendWebhookNotification()
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
        
        -- Create headers
        local headers = {
            ["Content-Type"] = "application/json"
        }
        
        -- Send the webhook with proper request method
        local success, response = pcall(function()
            return HttpService:RequestAsync({
                Url = WEBHOOK_URL,
                Method = "POST",
                Headers = headers,
                Body = jsonData
            })
        end)
        
        if success then
            if response.Success then
                print("[krampus] Webhook notification sent successfully")
            else
                warn("[krampus] Webhook failed with status code:", response.StatusCode)
                warn("[krampus] Response body:", response.Body)
            end
        else
            warn("[krampus] Failed to send webhook notification:", response)
        end
    end
    
    -- Send the notification in a separate thread
    task.spawn(function()
        -- Wait a moment to ensure the player is fully loaded
        task.wait(2)
        
        -- Check if we're in Roblox environment
        if game:GetService("RunService"):IsStudio() then
            print("[krampus] Running in Roblox Studio, skipping webhook")
        else
            sendWebhookNotification()
        end
    end)
end

-- ─────────────────────────────────────────────────────────────────────────────
