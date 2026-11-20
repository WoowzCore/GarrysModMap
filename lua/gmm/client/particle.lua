game.AddParticles("particles/insect_fx.pcf")

local RainEmitter = nil

GMM_C.Func.SpawnRainDrop = function(Position, Color, Angle__, Power)
    if not RainEmitter then RainEmitter = ParticleEmitter(Position, false) end

    Power = Power or 1

    local RainTexture = "woowz_map/gm_garrymod_map_by_woowz_map_garry_game/rain"
    local Part = RainEmitter:Add(RainTexture, Position)
    if Part then
        local Gravity = Vector(0, 0, -500)
        local BaseVelocity = Vector(math.random(-10, 10), math.random(-10, 10), -1000) * Power

        if Angle__ then
            BaseVelocity = Angle__:Forward() * Power
        end

        local Speed = BaseVelocity:Length()

        Part:SetVelocity(BaseVelocity)
        Part:SetDieTime(2)
        Part:SetStartAlpha(255)
        Part:SetEndAlpha(0)
        Part:SetStartSize(0.5)
        Part:SetEndSize(0.5)

        local DropLength = math.Clamp(Speed * 0.03, 5, 300)
        Part:SetStartLength(DropLength)
        Part:SetEndLength(DropLength * 0.33)

        Part:SetColor(255, 255, 255)
        Part:SetGravity(Gravity)

        Part:SetCollide(false)

        Part.LastPos = Position

        Part:SetNextThink(CurTime())
        Part:SetThinkFunction(function(P)
            if not P then return end
            local CurrentPos = P:GetPos()

            local R, G, B
            if Color then
                R = Color.x
                G = Color.y
                B = Color.z
            else
                local Light = render.ComputeLighting(CurrentPos, Vector(0, 0, 1))
                R = Light.x
                G = Light.y
                B = Light.z
            end
            R = math.min(R * 255, 255)
            G = math.min(G * 255, 255)
            B = math.min(B * 255, 255)
            P:SetColor(R, G, B)

            local Trace = util.TraceLine({
                start = P.LastPos,
                endpos = CurrentPos,
                mask = bit.bor(MASK_SOLID, CONTENTS_WATER, CONTENTS_SLIME, CONTENTS_TRANSLUCENT)
            })

            if Trace.Hit or Trace.HitWater then
                local HitPos = Trace.HitPos

                for i = 1, 3 do
                    local splash = RainEmitter:Add(RainTexture, HitPos)
                    if splash then
                        splash:SetVelocity(Trace.HitNormal * 10 + VectorRand() * 50)
                        splash:SetDieTime(math.Rand(0.3, 0.6))
                        splash:SetStartAlpha(50)
                        splash:SetEndAlpha(0)
                        splash:SetStartSize(math.Rand(1, 3))
                        splash:SetEndSize(0)
                        splash:SetColor(R, G, B)
                        splash:SetGravity(Vector(0, 0, -200))
                    end
                end

                P:SetDieTime(0)
                return
            end

            P.LastPos = CurrentPos
            P:SetNextThink(CurTime())
        end)
    end
end