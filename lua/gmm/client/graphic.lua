hook.Add("RenderScreenspaceEffects", "gmm_WaterOverlay", function()
    if not GMM.WaterPostEffectWork() then return end

    local Contents = util.PointContents(GMM_C.CameraPosition)

    local InWater = bit.band(Contents, CONTENTS_WATER) ~= 0
    local InSlime = bit.band(Contents, CONTENTS_SLIME) ~= 0

    if InWater or InSlime then
        DrawMaterialOverlay(InSlime and "woowz_map/gm_garrymod_map_by_woowz_map_garry_game/water_warp_slime" or "woowz_map/gm_garrymod_map_by_woowz_map_garry_game/water_warp", 0.05)
    end
end)

do
    if CLIENT then
        local MatPath       = "woowz_map/gm_garrymod_map_by_woowz_map_garry_game/woowzcore/textmeshpro"
        local TargetMat     = Material(MatPath)

        local TileScale     = 0.5
        local DistortPower  = 1
        local HammerUvScale = 0.25

        local TexMatrix     = Matrix()
        local TraceResult   = {}
        local TraceData     = {
            start  = Vector(0, 0, 0),
            endpos = Vector(0, 0, 0),
            mask   = MASK_SOLID,
            output = TraceResult
        }

        local AxisPosX      = Vector(1,  0,  0)
        local AxisPosY      = Vector(0,  1,  0)
        local AxisNegY      = Vector(0, -1,  0)
        local AxisNegZ      = Vector(0,  0, -1)

        local GetBrushAxes = function(Normal)
            local Nx = math.abs(Normal.x)
            local Ny = math.abs(Normal.y)
            local Nz = math.abs(Normal.z)

            if Nz >= Nx and Nz >= Ny then
                return AxisPosX, AxisNegY
            elseif Nx >= Ny and Nx >= Nz then
                return AxisPosY, AxisNegZ
            else
                return AxisPosX, AxisNegZ
            end
        end

        hook.Add("PreRender", "gmm_Woowzcore_ViewLockedMaterial", function()
            if not TargetMat or TargetMat:IsError() then return end

            local Ply = LocalPlayer()
            if not IsValid(Ply) then return end

            local EyeOrigin = Ply:EyePos()
            local EyeAng    = Ply:EyeAngles()
            local Forward   = EyeAng:Forward()
            local Right     = EyeAng:Right()
            local Up        = EyeAng:Up()

            TraceData.start  = EyeOrigin
            TraceData.endpos = EyeOrigin + Forward * 16384
            TraceData.filter = Ply
            util.TraceLine(TraceData)

            local HitPos    = TraceResult.Hit and TraceResult.HitPos or (EyeOrigin + Forward * 256)
            local HitNormal = (TraceResult.Hit and not TraceResult.StartSolid) and TraceResult.HitNormal or (-Forward)

            local AxisU, AxisV = GetBrushAxes(HitNormal)

            local LookStraight = math.Clamp(math.abs(Forward:Dot(HitNormal)), 0.12, 1.0)
            local ObliqueWarp  = math.pow(1.0 / LookStraight, DistortPower - 1.0)

            local M11 =  AxisU:Dot(Right) * TileScale * ObliqueWarp
            local M12 =  AxisV:Dot(Right) * TileScale * ObliqueWarp
            local M21 = -AxisU:Dot(Up)    * TileScale * ObliqueWarp
            local M22 = -AxisV:Dot(Up)    * TileScale * ObliqueWarp

            local BaseTex = TargetMat:GetTexture("$basetexture")
            local TexW    = (BaseTex and BaseTex:Width()  > 0) and BaseTex:Width()  or 512
            local TexH    = (BaseTex and BaseTex:Height() > 0) and BaseTex:Height() or 512

            local CenterU = HitPos:Dot(AxisU) / (HammerUvScale * TexW)
            local CenterV = HitPos:Dot(AxisV) / (HammerUvScale * TexH)

            local TransX  = 0.5 - (M11 * CenterU + M12 * CenterV)
            local TransY  = 0.5 - (M21 * CenterU + M22 * CenterV)

            TexMatrix:Identity()
            TexMatrix:SetField(1, 1, M11)
            TexMatrix:SetField(1, 2, M12)
            TexMatrix:SetField(1, 4, TransX)
            TexMatrix:SetField(2, 1, M21)
            TexMatrix:SetField(2, 2, M22)
            TexMatrix:SetField(2, 4, TransY)

            TargetMat:SetMatrix("$basetexturetransform", TexMatrix)
        end)
    end
end