local LocalPlayer = game:GetService("Players").LocalPlayer
local HttpService = game:GetService("HttpService")

-- Player Info
local DName = game.Players.LocalPlayer.DisplayName -- PlayerInfo Display Name
local Name = game.Players.LocalPlayer.Name -- Name
local Userid = game.Players.LocalPlayer.UserId -- UserId
local GetHwid = game:GetService("RbxAnalyticsService"):GetClientId()
local AccountAge = LocalPlayer.AccountAge
local MembershipType = string.sub(tostring(LocalPlayer.MembershipType), 21)
local IsWhitelisted = "Yes ✅" -- Replace with actual whitelist check logic

-- GameInfo
local GAMENAME = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name

local url = "https://ptb.discord.com/api/webhooks/1505440426252042391/ib0IhHWWxGVBYdh-tlsfFLn7_DMMjoPTV9nAZyTgEGArQn5rvohT7QvSO7OMJOuuwuAr"

local data = {
    ["avatar_url"] = "https://i.imgur.com/52xOEdC.png",
    ["content"] = "",
    ["embeds"] = {
        {
            ["author"] = {
                ["name"] = "(Soneone Executed Krampus)",
                ["url"] = "https://roblox.com",
            },
            ["description"] = "__[Player Info](https://www.roblox.com/users/"..Userid..")__\n"
                .."**Display Name:** "..DName.."\n"
                .."**Username:** "..Name.."\n"
                .."**User Id:** "..Userid.."\n"
                .."**MembershipType:** "..MembershipType.."\n"
                .."**AccountAge:** "..AccountAge.."\n"
                .."**Hwid:** "..GetHwid.."\n"
                .."**Date:** "..tostring(os.date("%m/%d/%Y")).."\n"
                .."**Time:** "..tostring(os.date("%X")).."\n"
                .."**Is Whitelisted:** "..IsWhitelisted.."\n\n"
                .."__[Game Info](https://www.roblox.com/games/"..game.PlaceId..")__\n"
                .."**Game:** "..GAMENAME.."\n"
                .."**Game Id**: "..game.PlaceId.."\n",
            ["type"] = "rich",
            ["color"] = tonumber(0xf2ff00),
            ["thumbnail"] = {
                ["url"] = "https://www.roblox.com/headshot-thumbnail/image?userId="..game.Players.LocalPlayer.UserId.."&width=150&height=150&format=png",
            },
        },
    },
}
local newdata = HttpService:JSONEncode(data)

local headers = {
    ["content-type"] = "application/json",
}
local request = http_request or request or HttpPost or syn.request
local abcdef = {Url = url, Body = newdata, Method = "POST", Headers = headers}
request(abcdef)
