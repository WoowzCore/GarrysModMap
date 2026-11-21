local function AddPlayerModel(Name, Model)
    list.Set("PlayerOptionsModel", Name, Model)
    player_manager.AddValidModel(Name, Model)
end

AddPlayerModel("Pavel Pisechnik TV", "models/woowz11/player/pavelpistv.mdl")
AddPlayerModel("Sranspong", "models/woowz_map/prikol/le_sponge_rag_player.mdl")
AddPlayerModel("Pisechnik", "models/player/pissbaby.mdl")