local SurfaceSolid       = GMM.ConVars.GetFlagValue("debug_hit_surfaces", "Solid")
local SurfaceTransparent = GMM.ConVars.GetFlagValue("debug_hit_surfaces", "Transparent")
local SurfaceWater       = GMM.ConVars.GetFlagValue("debug_hit_surfaces", "Water")
local SurfaceClip        = GMM.ConVars.GetFlagValue("debug_hit_surfaces", "Clip")
local SurfaceSky         = GMM.ConVars.GetFlagValue("debug_hit_surfaces", "Sky")
local SurfaceNoDraw      = GMM.ConVars.GetFlagValue("debug_hit_surfaces", "NoDraw")
local SurfaceEntities    = GMM.ConVars.GetFlagValue("debug_hit_surfaces", "Entities")
local SurfaceProps       = GMM.ConVars.GetFlagValue("debug_hit_surfaces", "Props")

local MaskSolid       = bit.bor(CONTENTS_SOLID, CONTENTS_MOVEABLE, CONTENTS_MONSTER, CONTENTS_DEBRIS, CONTENTS_HITBOX)
local MaskTransparent = bit.bor(CONTENTS_WINDOW, CONTENTS_GRATE)
local MaskWater       = bit.bor(CONTENTS_WATER, CONTENTS_SLIME)
local MaskClip        = bit.bor(CONTENTS_PLAYERCLIP, CONTENTS_MONSTERCLIP)

local SurfacesConVar = nil
local CurrentSurfaces = 0
local LocalPly        = nil
local ClassIsProp     = {}

local function IsPropClass(Class)
    local Cached = ClassIsProp[Class]
    if Cached ~= nil then return Cached end

    local Result = string.StartWith(Class, "prop_")
    ClassIsProp[Class] = Result

    return Result
end

local function TraceFilter(Ent)
    if Ent == LocalPly then return false end
    if Ent:IsWorld() then return true end

    if IsPropClass(Ent:GetClass()) then
        return bit.band(CurrentSurfaces, SurfaceProps) ~= 0
    end

    return bit.band(CurrentSurfaces, SurfaceEntities) ~= 0
end

local function GetHitMask()
    if not SurfacesConVar then SurfacesConVar = GetConVar("gmm_convar_debug_hit_surfaces") end
    if not SurfacesConVar then return 0 end

    CurrentSurfaces = SurfacesConVar:GetInt()
    LocalPly        = LocalPlayer()

    local Mask = 0

    if bit.band(CurrentSurfaces, SurfaceSolid + SurfaceEntities + SurfaceProps) ~= 0 then Mask = bit.bor(Mask, MaskSolid) end
    if bit.band(CurrentSurfaces, SurfaceTransparent) ~= 0 then Mask = bit.bor(Mask, MaskTransparent) end
    if bit.band(CurrentSurfaces, SurfaceWater)       ~= 0 then Mask = bit.bor(Mask, MaskWater) end
    if bit.band(CurrentSurfaces, SurfaceClip)        ~= 0 then Mask = bit.bor(Mask, MaskClip) end

    return Mask
end

local function IsHitAllowed(Trace)
    if Trace.HitSky    and bit.band(CurrentSurfaces, SurfaceSky)    == 0 then return false end
    if Trace.HitNoDraw and bit.band(CurrentSurfaces, SurfaceNoDraw) == 0 then return false end

    if Trace.HitWorld and bit.band(CurrentSurfaces, SurfaceSolid) == 0 then
        if bit.band(Trace.Contents or 0, MaskSolid) ~= 0 then return false end
    end

    return true
end

local LastHitPos    = nil
local LastHitNormal = nil
local LastHitEntity = nil

local HaloEntities = {}
local HaloColor    = Color(255, 255, 0, 255)

hook.Add("HUDPaint", "gmm_InterfaceDrawCoordinates", function()
    local ConVar_ShowPosition = GMM.ConVars.GetBool("debug_showposition")
    local ConVar_ShowHit      = GMM.ConVars.GetBool("debug_showhit")
    
    if not ConVar_ShowHit and not ConVar_ShowPosition then return end
    
    local Position = EyePos   ()
    local Angle    = EyeAngles()

    local HitMask = GetHitMask()

    if HitMask == 0 then
        LastHitPos    = nil
        LastHitNormal = nil
        LastHitEntity = nil

        return
    end

    local Filter = LocalPly
    if bit.band(CurrentSurfaces, SurfaceEntities + SurfaceProps) ~= SurfaceEntities + SurfaceProps then Filter = TraceFilter end

    local Trace = util.TraceLine({
        start  = Position,
        endpos = Position + Angle:Forward() * 32768,
        filter = Filter,
        mask   = HitMask
    })

    local HitPos    = Trace.HitPos
    local HitEntity = Trace.Entity
    local Hit       = Trace.Hit and IsHitAllowed(Trace)

    if Hit then
        LastHitPos    = HitPos
        LastHitNormal = Trace.HitNormal
    else
        LastHitPos    = nil
        LastHitNormal = nil
        HitEntity     = nil
    end

    LastHitEntity = nil
    if Hit and IsValid(HitEntity) and not HitEntity:IsWorld() then LastHitEntity = HitEntity end

    if not ConVar_ShowPosition then return end

    local EntityName = "None"
    if IsValid(HitEntity) then
        EntityName = HitEntity:GetClass()
        if HitEntity:IsPlayer() then
            EntityName = "Player: " .. HitEntity:Nick()
        elseif HitEntity:GetModel() then
            EntityName = EntityName .. " (" .. HitEntity:GetModel() .. ")"
        end
    end

    local Text = string.format(
        "X: %.1f  Y: %.1f  Z: %.1f  |  Pitch: %.1f°  Yaw: %.1f°  Roll: %.1f°\n" ..
                "Hit: X: %.1f  Y: %.1f  Z: %.1f | Dist.: %.1f | HitEnt.: %s",
        Position.x, Position.y, Position.z,
        Angle.pitch, Angle.yaw, Angle.roll,
        HitPos.x, HitPos.y, HitPos.z,
        Position:Distance(HitPos),
        EntityName
    )

    surface.SetFont("DermaDefaultBold")
    local TextW, TextH = surface.GetTextSize(Text)

    local Padding = 10
    local RectX = ScrW() / 2 - TextW / 2 - Padding
    local RectY = 10 - Padding
    local RectW = TextW + Padding * 2
    local RectH = TextH + Padding * 2

    draw.RoundedBox(
        8,
        RectX, RectY,
        RectW, RectH,
        Color(0, 0, 0, 180)
    )

    local Lines = string.Explode("\n", Text)
    for i, Line in ipairs(Lines) do
        draw.SimpleText(
            Line,
            "DermaDefaultBold",
            ScrW() / 2, RectY + Padding + (i - 1) * (TextH / #Lines),
            Color(255, 255, 255, 255),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_TOP
        )
    end
end)

hook.Add("PostDrawTranslucentRenderables", "gmm_DrawHitPoint", function()
    if not GMM.ConVars.GetBool("debug_showhit") then return end
    
    if not LastHitPos then return end

    render.DrawWireframeSphere(LastHitPos, 1, 12, 12, Color(255, 255, 0, 255), true)

    if LastHitNormal then
        render.DrawLine(LastHitPos, LastHitPos + LastHitNormal * 15, Color(0, 255, 0, 255), true)
    end
end)

hook.Add("PreDrawHalos", "gmm_DrawHitHalo", function()
    if not GMM.ConVars.GetBool("debug_showhit") then return end
    if not IsValid(LastHitEntity) then return end

    HaloEntities[1] = LastHitEntity

    halo.Add(HaloEntities, HaloColor, 2, 2, 2, true, true)
end)

hook.Add("PostDrawTranslucentRenderables", "gmm_DebugDraw", function()
    if not (GMM.ConVars.GetBool("debug_showsounds") or (GMM.Maps.Goofy and math.random() > 0.9)) then return end
    
    local CurrentTime = RealTime()

    for i = 1, #GMM_C.Environment.AmbientSounds do
        local SoundData = GMM_C.Environment.AmbientSounds[i]

        local Channel   = SoundData[1 ]
        local Position  = SoundData[2 ]
        local Volume    = SoundData[3 ]
        local IDistance = SoundData[4 ]
        local ADistance = SoundData[5 ]
        local Delay     = SoundData[6 ]
        local Speed     = SoundData[7 ]
        local SoundFile = SoundData[8 ]
        local StartTime = SoundData[9 ]
        local Working   = SoundData[10]
        local Length    = Channel:GetLength()

        if StartTime then
            if type(Position) == "number" then
                local Target = Position
                if GMM_C.Data.Positions then
                    Position = GMM_C.Data.Positions[Target]

                    if Position ~= nil then
                        if TypeID(Position) ~= TYPE_VECTOR then
                            Position = ErrorPosition
                        end
                    else
                        Position = ErrorPosition
                    end
                else
                    Position = ErrorPosition
                end
            end

            local Progress = math.Clamp((CurrentTime - StartTime) / Length, 0, 1)
            local Alpha = math.Clamp(Volume / 50, 0, 1)

            local R, G, B = 0, 0, 0

            if Speed <= 1 then
                R = 255 * Speed
                G = 0
                B = 255 * (1 - Speed)
            else
                local T = math.Clamp((Speed - 1) / 5, 0, 1)
                R = 255 * (1 - T)
                G = 255 * T
                B = 0
            end

            local Col = Color(
                R,
                G,
                B,
                255 * Alpha
            )
            if CurrentTime - StartTime > (Length / Speed) then
                Col = Color(255, 255, 255, 255 * Alpha)
            end

            render.DrawWireframeSphere(Position, IDistance, 6 + 24 * Progress, 6 + 24 * Progress, Color(0, 255, 0, 255 * Alpha))
            render.DrawWireframeSphere(Position, ADistance, 6 + 24 * Progress, 6 + 24 * Progress, Col)
        end
    end
end)