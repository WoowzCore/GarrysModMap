-- Что-бы включить отладку, нужно изменить параметр GMM_DEBUG на true

local MapName = game.GetMap()

GMM = {
	["Valid"        ] = string.match(MapName, "^gmm_") or MapName == "toiletmap",
	["CustomDebug"  ] = GMM_DEBUG or false,
    ["MyMap_Default"] = MapName == "gmm_garrymod_map_by_woowz_map_garry_game",
    ["MyMap_Flood"  ] = MapName == "gmm_garrymod_map_by_woowz_flooded_water_blob",
	["MyMap_Old"    ] = MapName == "gmm_garrymod_map_by_woowz_old_alpha_beta",
	["MyMap_Real"   ] = MapName == "gmm_garrymod_map_by_woowz_real_rp_normal",
    ["MyMap_Dark"   ] = MapName == "gmm_garrymod_map_by_woowz_dark_horror_night",
	["MyMap_Goofy"  ] = MapName == "gmm_garrymod_map_by_woowz_help_me",
	
	["DoAnomalies"] = true,
	
	Func = {}
}

if GMM["MyMap_Real"] then GMM["DoAnomalies"] = false end

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