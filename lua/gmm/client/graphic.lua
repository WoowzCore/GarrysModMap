hook.Add("RenderScreenspaceEffects", "gmm_WaterOverlay", function()
    if not GMM.Valid then return end

    local Contents = util.PointContents(GMM_C.CameraPosition)

    local InWater = bit.band(Contents, CONTENTS_WATER) ~= 0
    local InSlime = bit.band(Contents, CONTENTS_SLIME) ~= 0

    if InWater or InSlime then
        DrawMaterialOverlay(InSlime and "woowz_map/gm_garrymod_map_by_woowz_map_garry_game/water_warp_slime" or "woowz_map/gm_garrymod_map_by_woowz_map_garry_game/water_warp", 0.05)
    end
end)