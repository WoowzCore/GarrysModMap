if SERVER then
    local StripPlayerWeapons = function(Ply)
        if not IsValid(Ply) then return end

        Ply:StripWeapons()
        Ply:StripAmmo()
    end

    hook.Add("PlayerLoadout", "gmm_WoowzcoreLevel0_Loadout", function(Ply)
        StripPlayerWeapons(Ply)
        return true
    end)

    hook.Add("PlayerSpawn", "gmm_WoowzcoreLevel0_Spawn", function(Ply)
        StripPlayerWeapons(Ply)

        timer.Simple(0, function()
            StripPlayerWeapons(Ply)
        end)
    end)

    -- ----------------------------------------------------------------------

    local MinX = math.min(-5134, 14838)
    local MaxX = math.max(-5134, 14838)
    local MinY = math.min(13839, -7126)
    local MaxY = math.max(13839, -7126)
    local MinZ = math.min(-725 , 14429)
    local MaxZ = math.max(-725 , 14429)

    local ZeroVel = Vector(0, 0, 0)

    local IsOutsideBounds = function(Pos)
        return Pos.x < MinX or Pos.x > MaxX
                or Pos.y < MinY or Pos.y > MaxY
                or Pos.z < MinZ or Pos.z > MaxZ
    end

    local ShouldRemoveOutside = function(Ent)
        if Ent:IsNPC() or Ent:IsNextBot() or Ent:IsRagdoll() or Ent:IsVehicle() then
            return true
        end

        local Class = Ent:GetClass()
        if string.sub(Class, 1, 5) == "prop_" or string.sub(Class, 1, 4) == "npc_" then
            return true
        end

        return false
    end

    local TeleportPlayerToSpawn = function(Ply)
        local SpawnEnt = hook.Run("PlayerSelectSpawn", Ply)
        if not IsValid(SpawnEnt) then
            SpawnEnt = ents.FindByClass("info_player_start")[1]
        end

        Ply:SetLocalVelocity(ZeroVel)

        if IsValid(SpawnEnt) then
            Ply:SetPos(SpawnEnt:GetPos())
            Ply:SetEyeAngles(SpawnEnt:GetAngles())
        else
            Ply:Spawn()
        end
    end

    timer.Create("gmm_WoowzcoreLevel0_BoundsCheck", 0.15, 0, function()
        local Players = player.GetAll()
        for i = 1, #Players do
            local Ply = Players[i]
            if IsValid(Ply) and Ply:Alive() and Ply:GetMoveType() ~= MOVETYPE_NOCLIP then
                if IsOutsideBounds(Ply:GetPos()) then
                    TeleportPlayerToSpawn(Ply)
                end
            end
        end

        local AllEnts = ents.GetAll()
        for i = 1, #AllEnts do
            local Ent = AllEnts[i]
            if IsValid(Ent) and not Ent:IsPlayer() and not IsValid(Ent:GetOwner()) and not IsValid(Ent:GetParent()) then
                if ShouldRemoveOutside(Ent) and IsOutsideBounds(Ent:GetPos()) then
                    Ent:Remove()
                end
            end
        end
    end)
end

-- ----------------------------------------------------------------------

if CLIENT then
    surface.CreateFont("gmm_WC2_Main", {
        font      = "Arial",
        size      = 25,
        weight    = 500,
        antialias = true,
        extended  = true
    })

    surface.CreateFont("gmm_WC2_Small", {
        font      = "Arial",
        size      = 21,
        weight    = 500,
        antialias = true,
        extended  = true
    })

    local LevelTitle = "Уровень: 0 (Отладочная карта)"
    local LevelLines = {
        "На эту карту нельзя попасть легально! Она",
        "используется для тестирования различных функций,",
        "а так же является самой первой картой в игре..."
    }

    local RoseMat  = Material("woowz_map/gm_garrymod_map_by_woowz_map_garry_game/icons/woowzcore_icon_cube.vtf", "smooth")
    local SkullMat = Material("woowz_map/gm_garrymod_map_by_woowz_map_garry_game/icons/woowzcore_icon_skull.vtf", "smooth")
    local IconSize = 25

    local BuildTitle   = "Woowzcore 2"
    local BuildVersion = "Build: [GMM] - 27.11.2026 - DEV"
    local BuildStatus  = "ALPHA TEST"

    local Controls = {
        {"а"      , "— Фонарик"     },
        {"и"      , "— Зум"         },
        {"ё"      , "— Консоль"     },
        {"шифт"   , "— Бежать"      },
        {"контрл.", "— Присесть"    },
        {"эскейп" , "— Выйти"       },
        {"м"      , "— Полёт"       },
    }

    local HiddenHud = {
        CHudHealth          = true,
        CHudBattery         = true,
        CHudAmmo            = true,
        CHudSecondaryAmmo   = true,
        CHudCrosshair       = true,
        CHudDeathNotice     = true
    }

    local ColorInfo     = Color(120, 120, 120, 235)
    local ColorWhite    = Color(245, 245, 245, 255)
    local ColorYellow   = Color(250, 230, 35 , 255)
    local ColorRed      = Color(240, 65 , 65 , 255)
    local ColorControls = Color(85 , 85 , 95 , 195)
    local ColorShadow   = Color(0  , 0  , 0  , 150)
    local ColorDot      = Color(255, 255, 255, 245)
    local ColorDotEdge  = Color(0  , 0  , 0  , 90 )

    local FpsValue   = 60
    local NextFpsAt  = 0

    local DrawShadowText = function(Text, Font, X, Y, Col, AlignX, AlignY)
        draw.SimpleText(Text, Font, X + 0.1, Y + 0.1, ColorShadow, AlignX, AlignY)
        draw.SimpleText(Text, Font, X - 0.1, Y - 0.1, ColorShadow, AlignX, AlignY)
        
        return draw.SimpleText(Text, Font, X, Y, Col, AlignX, AlignY)
    end

    hook.Add("HUDShouldDraw", "gmm_WoowzcoreLevel0_HideHUD", function(Name)
        if HiddenHud[Name] then return false end
    end)

    hook.Add("DrawDeathNotice", "gmm_WoowzcoreLevel0_HideDeaths", function()
        return false
    end)

    hook.Add("HUDPaint", "gmm_WoowzcoreLevel0_HUD", function()
        local Ply = LocalPlayer()
        if not IsValid(Ply) then return end

        local Now = RealTime()
        if Now >= NextFpsAt then
            NextFpsAt = Now + 0.2
            FpsValue  = math.Clamp(math.Round(1 / math.max(FrameTime(), 0.0001)), 1, 9999)
        end

        local W   = ScrW()
        local H   = ScrH()

        local CoordText = "0.-784770.516.466"
        local CoordW    = DrawShadowText(CoordText, "gmm_WC2_Main", 6, 4, ColorInfo, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        if not RoseMat:IsError() then
            surface.SetMaterial(RoseMat)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRect(6 + CoordW + 5, 6, IconSize, IconSize)
        end
        DrawShadowText(LevelTitle, "gmm_WC2_Main", 6, 28, ColorInfo, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        for i = 1, #LevelLines do
            DrawShadowText(LevelLines[i], "gmm_WC2_Main", 6, 52 + (i - 1) * 22, ColorInfo, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end

        DrawShadowText(tostring(FpsValue), "gmm_WC2_Main", W * 0.5, 4, ColorInfo, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

        DrawShadowText(BuildTitle  , "gmm_WC2_Main", W - 6, 4 , ColorWhite , TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
        DrawShadowText(BuildVersion, "gmm_WC2_Main", W - 6, 26, ColorYellow, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)

        surface.SetFont("gmm_WC2_Main")
        local StatusW   = surface.GetTextSize(BuildStatus)
        local RightX    = W - 6
        local StatusY   = 48
        local HasSkull  = not SkullMat:IsError()
        local SkullPad  = HasSkull and (IconSize + 4) or 0

        if HasSkull then
            surface.SetMaterial(SkullMat)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRect(RightX - IconSize, StatusY + 2, IconSize, IconSize)
            surface.DrawTexturedRect(RightX - SkullPad - StatusW - SkullPad, StatusY + 2, IconSize, IconSize)
        end

        DrawShadowText(BuildStatus, "gmm_WC2_Main", RightX - SkullPad, StatusY, ColorRed, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)

        local KeyX    = W - 186
        local ActionX = W - 118
        local BaseY   = 74

        for i = 1, #Controls do
            local Row  = Controls[i]
            local RowY = BaseY + (i - 1) * 19

            DrawShadowText(Row[1], "gmm_WC2_Small", KeyX   , RowY, ColorControls, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            DrawShadowText(Row[2], "gmm_WC2_Small", ActionX, RowY, ColorControls, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end

        if Ply:Alive() then
            local Health = math.max(Ply:Health(), 0)
            local Armor  = math.max(Ply:Armor() , 0)
            local HpText = tostring(Health)

            if Armor > 0 then
                HpText = HpText .. " / " .. Armor
            end

            DrawShadowText(HpText, "gmm_WC2_Main", 6, H - 4, ColorInfo, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)

            local Wep = Ply:GetActiveWeapon()
            if IsValid(Wep) then
                local Clip1         = Wep:Clip1()
                local PrimaryType   = Wep:GetPrimaryAmmoType()
                local SecondaryType = Wep:GetSecondaryAmmoType()
                local AmmoText      = ""

                if Clip1 >= 0 then
                    AmmoText = tostring(Clip1)
                    if PrimaryType >= 0 then
                        AmmoText = AmmoText .. " / " .. Ply:GetAmmoCount(PrimaryType)
                    end
                elseif PrimaryType >= 0 then
                    AmmoText = tostring(Ply:GetAmmoCount(PrimaryType))
                end

                if SecondaryType >= 0 then
                    local SecondaryCount = Ply:GetAmmoCount(SecondaryType)
                    if SecondaryCount > 0 then
                        if AmmoText ~= "" then
                            AmmoText = AmmoText .. " (" .. SecondaryCount .. ")"
                        else
                            AmmoText = tostring(SecondaryCount)
                        end
                    end
                end

                if AmmoText ~= "" then
                    DrawShadowText(AmmoText, "gmm_WC2_Main", W - 6, H - 4, ColorInfo, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
                end
            end
        end

        local Cx = math.floor(W * 0.5)
        local Cy = math.floor(H * 0.5)

        draw.RoundedBox(4, Cx - 3, Cy - 3, 6, 6, ColorDotEdge)
        draw.RoundedBox(3, Cx - 2, Cy - 2, 4, 4, ColorDot)
    end)
end

-- ----------------------------------------------------------------------

if CLIENT then
    local MusicUrl     = "https://woowz11.github.io/woowzsite/source/woowzcore/musics/special/woowzcore_music.mp3"
    local MusicVolume  = 0.5
    local MusicChannel = nil
    local MusicLoading = false

    local StartAmbientMusic = function()
        if MusicLoading then return end
        if IsValid(MusicChannel) then
            if MusicChannel:GetState() ~= GMOD_CHANNEL_PLAYING then
                MusicChannel:SetVolume(MusicVolume)
                MusicChannel:Play()
            end
            return
        end

        MusicLoading = true

        sound.PlayURL(MusicUrl, "noblock", function(Channel)
            MusicLoading = false

            if IsValid(Channel) then
                if IsValid(MusicChannel) then
                    MusicChannel:Stop()
                end

                MusicChannel = Channel
                MusicChannel:EnableLooping(true)
                MusicChannel:SetVolume(MusicVolume)
                MusicChannel:Play()
            end
        end)
    end

    hook.Add("InitPostEntity", "gmm_WoowzcoreLevel0_AmbientInit", StartAmbientMusic)

    timer.Create("gmm_WoowzcoreLevel0_AmbientLoop", 2, 0, function()
        if not IsValid(LocalPlayer()) then return end
        StartAmbientMusic()
    end)
end