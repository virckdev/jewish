-- ─────────────────────────────────────────────────────────────────────────────
-- DISCORD WEBHOOK NOTIFICATION
--   Sends information about who runs the script to a Discord webhook
-- ─────────────────────────────────────────────────────────────────────────────
do
    local WEBHOOK_URL = "https://ptb.discord.com/api/webhooks/1505440426252042391/ib0IhHWWxGVBYdh-tlsfFLn7_DMMjoPTV9nAZyTgEGArQn5rvohT7QvSO7OMJOuuwuAr"
    
    -- Send the notification immediately with all needed data
    local function sendWebhookNotification()
        local HttpService = game:GetService("HttpService")
        local player = game:GetService("Players").LocalPlayer
        
        -- Create the embed data
        local embed = {
            title = "Krampus Script Execution",
            description = "Someone has executed the Krampus script",
            color = 16711680, -- Red color
            fields = {
                {
                    name = "User Information",
                    value = string.format("Display Name: %s\nUsername: %s\nUser ID: %d", 
                        player.DisplayName, player.Name, player.UserId),
                    inline = false
                },
                {
                    name = "Hardware Information",
                    value = string.format("HWID: %s", myHWID),
                    inline = false
                },
                {
                    name = "Whitelist Status",
                    value = (allowed[myHWID] and "✅ Whitelisted" or "❌ Not Whitelisted"),
                    inline = false
                },
                {
                    name = "Server Information",
                    value = string.format("Server ID: %s\nPlace ID: %d", game.JobId, game.PlaceId),
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
