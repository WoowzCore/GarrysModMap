local LastHitPos    = nil
local LastHitNormal = nil

hook.Add("HUDPaint", "gmm_InterfaceDrawCoordinates", function()
    local Developer = GetConVar("developer")

    if not GMM_C.Debug then
        if not Developer or Developer:GetInt() == 0 then return end
    end

    local Position = EyePos   ()
    local Angle    = EyeAngles()

    local Trace = util.TraceLine({
        start  = Position,
        endpos = Position + Angle:Forward() * 32768,
        filter = GMM_C.Player,
        mask   = bit.bor(MASK_SHOT, CONTENTS_TRANSLUCENT, CONTENTS_WATER, CONTENTS_SLIME, CONTENTS_GRATE)
    })

    local HitPos    = Trace.HitPos
    local HitEntity = Trace.Entity

    if Trace.Hit then
        LastHitPos    = HitPos
        LastHitNormal = Trace.HitNormal
    else
        LastHitPos    = nil
        LastHitNormal = nil
    end

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
    local Developer = GetConVar("developer")
    if not Developer or Developer:GetInt() == 0 then return end
    if not GMM.Valid then return end
    if not LastHitPos then return end

    render.DrawWireframeSphere(LastHitPos, 1, 12, 12, Color(255, 255, 0, 255), true)

    if LastHitNormal then
        render.DrawLine(LastHitPos, LastHitPos + LastHitNormal * 15, Color(0, 255, 0, 255), true)
    end
end)

hook.Add("PostDrawTranslucentRenderables", "gmm_DebugDraw", function()
    local CurrentTime = RealTime()

    local Developer = GetConVar("developer")
    if not Developer or Developer:GetInt() == 0 then return end

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