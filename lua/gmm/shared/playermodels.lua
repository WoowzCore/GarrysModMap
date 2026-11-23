local function AddPlayerModel(Name, Model, ArmsModel, ArmsModelSkin)
    list.Set("PlayerOptionsModel", Name, Model)
    player_manager.AddValidModel(Name, Model)

    if ArmsModel then
        if ArmsModelSkin == nil then ArmsModelSkin = 0 end
        player_manager.AddValidHands(Name, ArmsModel, ArmsModelSkin)
    end
end

AddPlayerModel("Pavel Pisechnik TV", "models/woowz11/player/pavelpistv.mdl", "models/weapons/c_arms_dod.mdl")
AddPlayerModel("Sranspong", "models/woowz_map/prikol/le_sponge_rag_player.mdl", "models/weapons/c_arms_citizen.mdl", 2)
AddPlayerModel("Pisechnik", "models/woowz11/player/pisechnik.mdl", "models/woowz11/player/pisechnik_arms.mdl")
AddPlayerModel("Pisechnik Still Life", "models/woowz11/player/pisechnik_stilllife.mdl", "models/woowz11/player/pisechnik_arms.mdl")