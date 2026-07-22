GMM = {
	["Valid"] = string.match(game.GetMap(), "^gmm_"),
	["MyMap"] = game.GetMap() == "gmm_garrymod_map_by_woowz_map_garry_game"
}

if not GMM["Valid"] then return end
include("gmm_shared.lua")