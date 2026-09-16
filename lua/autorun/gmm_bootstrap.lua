-- Что-бы включить отладку, нужно изменить параметр GMM_DEBUG на true

GMM = {
	["Valid"        ] = string.match(game.GetMap(), "^gmm_"),
	["CustomDebug"  ] = GMM_DEBUG or false,
    ["MyMap_Default"] = game.GetMap() == "gmm_garrymod_map_by_woowz_map_garry_game",
    ["MyMap_Flood"  ] = game.GetMap() == "gmm_garrymod_map_by_woowz_flooded_water_blob"
}

if not GMM["Valid"] then return end

-- ----------------------------------------------------------------------

Woowz11 = "STEAM_0:0:158204257"

ErrorPosition = Vector(-100000, -100000, -100000)

if SERVER then
	AddCSLuaFile("gmm_client.lua")
	include("gmm_server.lua")
end

if CLIENT then
	include("gmm_client.lua")
end