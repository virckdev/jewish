do
	local HWID_LIST_URL = "https://raw.githubusercontent.com/HomerSimpson88354/EternoSploitAssets/refs/heads/main/hwid.txt"
	local ACCEPT_URL = "https://raw.githubusercontent.com/virckdev/jewish/refs/heads/main/accept.lua"
	local DENY_URL   = "https://raw.githubusercontent.com/virckdev/jewish/refs/heads/main/deny.lua"
	local MAX_RETRIES = 3
	local RETRY_DELAY = 2

	local function getHWID()
		local ok, id = pcall(function()
			return game:GetService("RbxAnalyticsService"):GetClientId()
		end)
		if ok and type(id) == "string" and #id > 0 then
			return id:lower():gsub("%s+", "")
		end
		return nil
	end

	local function fetchAllowedHWIDs(url)
		local allowed = {}
		local ok, raw = pcall(function()
			return game:HttpGet(url, true)
		end)
		if not ok or type(raw) ~= "string" or #raw == 0 then
			return nil
		end
		for line in raw:gmatch("[^\r\n]+") do
			local clean = line:gsub("#.*$", ""):match("^%s*(.-)%s*$")
			if #clean > 0 then
				allowed[clean:lower()] = true
			end
		end
		return allowed
	end

	local function runUrl(url)
		local ok, src = pcall(function()
			return game:HttpGet(url, true)
		end)
		if ok and type(src) == "string" and #src > 0 then
			local fn, err = loadstring(src)
			if fn then
				fn()
			else
				warn("..." .. tostring(err))
			end
		else
			warn("..." .. tostring(url))
		end
	end

	local myHWID = getHWID()

	if not myHWID then
		runUrl(DENY_URL)
		return
	end

	local allowed = nil
	for attempt = 1, MAX_RETRIES do
		allowed = fetchAllowedHWIDs(HWID_LIST_URL)
		if allowed then break end
		if attempt < MAX_RETRIES then
			task.wait(RETRY_DELAY)
		end
	end

	if not allowed then
		warn("...")
		return
	end

	if not allowed[myHWID] then
		warn("..." .. myHWID)
		runUrl(DENY_URL)
		return
	end

	runUrl(ACCEPT_URL)
end
