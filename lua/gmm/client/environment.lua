GMM_C.Environment = {}

GMM_C.Environment.AmbientSounds = {}
GMM_C.Environment.Particles     = {}
GMM_C.Environment.Zones         = {}
GMM_C.Environment.Nav           = {}

GMM_C.Environment.Create = function()
    for i = #GMM_C.Environment.AmbientSounds, 1, -1 do
        local SoundData = GMM_C.Environment.AmbientSounds[i]
        local Channel = SoundData[1]
        if IsValid(Channel) then
            Channel:Stop()
        end
        table.remove(GMM_C.Environment.AmbientSounds, i)
    end

    GMM_C.Environment.AmbientSounds = {}
    GMM_C.Environment.Particles     = {}
    GMM_C.Environment.Zones         = {}
    GMM_C.Environment.Nav           = {}

    local CreateAmbient = function(SoundFile, Position, IDistance, ADistance, Volume, Delay, Speed)
        SoundFile = "sound/" .. SoundFile

        Volume    = Volume    or 1
        IDistance = IDistance or 100
        ADistance = ADistance or 1500
        Delay     = Delay     or 0
        Speed     = Speed     or 1

        sound.PlayFile(SoundFile, "noplay", function(Channel, eID, e)
            if e then error("[GMM] [ERROR]: FAILED PlayFile AMBIENT SOUND [" .. SoundFile .. "]:", eID, e) return end
            if not IsValid(Channel) then error("[GMM] [ERROR]: FAILED PlayFile AMBIENT SOUND [" .. SoundFile .. "]: Channel is not valid!") return end

            Channel:SetPlaybackRate(Speed)

            table.insert(GMM_C.Environment.AmbientSounds, {Channel, Position, Volume, IDistance, ADistance, Delay, Speed, SoundFile})
        end)
    end

    local CreatePartical = function(Partical, Position, Delay, Angle__, Power)
        Delay = Delay or 0
        Angle__ = Angle__ or Angle(0, 0, 0)
        Power = Power or 0

        local RunFunc = nil

        if Partical == "Bubbles" then
            RunFunc = function()
                effects.Bubbles(Position, Position, 1, 200)
            end
        end
        if Partical == "Fly" then
            RunFunc = function()
                PrecacheParticleSystem("fly_child")
                ParticleEffect("fly_child", Position, Angle(0, 0, 0))
            end
        end
        if Partical == "Cockroach" then
            RunFunc = function()
                PrecacheParticleSystem("roach_fx_4")
                ParticleEffect("roach_fx_4", Position, Angle(0, 0, 0))
            end
        end
        if Partical == "Droplet" then
            RunFunc = function()
                local FinalAngle = Angle__
                if type(Angle__) == "function" then
                    FinalAngle = Angle__()
                end

                GMM_C.Func.SpawnRainDrop(Position, nil, FinalAngle, Power)
            end
        end

        table.insert(GMM_C.Environment.Particles, {Partical, Position, Delay, RunFunc, Angle__, Power})
    end

    local CreateZone = function(Type, Point1, Point2, Color, Density)
        Point1.z = Point1.z - 2
        Point2.z = Point2.z - 2

        Density = Density or 5

        table.insert(GMM_C.Environment.Zones, {Type, Point1, Point2, Density, Color})
    end

    local CreateNav = function(Position)
        table.insert(GMM_C.Environment.Nav, {Position});
    end

    -- ----------------------------------------------------------------------

    local function ShouldSpawn(MapList)
        if GMM.Maps.Goofy then return true end
        for _, MapSuffix in ipairs(MapList) do
            if GMM.Maps[MapSuffix] then return true end
        end
        return false
    end

    for _, Info in ipairs(GMM.Data.MapAssets.Sounds) do
        if ShouldSpawn(Info[1]) then
            local Ambient = Info[2]
            CreateAmbient(Ambient[1], Ambient[2], Ambient[3], Ambient[4], Ambient[5], Ambient[6], Ambient[7])
        end
    end

    for _, Info in ipairs(GMM.Data.MapAssets.Zones) do
        if ShouldSpawn(Info[1]) then
            local Zone = Info[2]
            CreateZone(Zone[1], Zone[2], Zone[3], Zone[4], Zone[5])
        end
    end

    for _, Info in ipairs(GMM.Data.MapAssets.Particles) do
        if ShouldSpawn(Info[1]) then
            local Particle = Info[2]
            CreatePartical(Particle[1], Particle[2], Particle[3], Particle[4], Particle[5])
        end
    end

    for _, Info in ipairs(GMM.Data.MapAssets.Navmesh) do
        if ShouldSpawn(Info[1]) then
            local Nav = Info[2]
            CreateNav(Nav[1])
        end
    end
end

GMM_C.Environment.Update = function()
    local CurrentTime = RealTime()

    for i = #GMM_C.Environment.AmbientSounds, 1, -1 do
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

        if Working == nil then Working = true end

        if StartTime == nil or (CurrentTime - StartTime > ((Length / Speed) + Delay)) then
            StartTime = CurrentTime
            Channel:Play()
            GMM_C.Environment.AmbientSounds[i][9] = StartTime
        end

        if type(Position) == "number" then
            local Target = Position
            if GMM_C.Data.Positions then
                Position = GMM_C.Data.Positions[Target]

                if Position ~= nil then
                    if TypeID(Position) ~= TYPE_VECTOR then
                        if Working then print("[GMM] [ERROR] FAILED SET TARGET TO SOUND [" .. SoundFile .. "]! TARGET [" .. Target .. "] IS NOT VECTOR!") end
                        Working = false
                        Position = ErrorPosition
                    end
                else
                    Position = ErrorPosition
                end
            else
                Position = ErrorPosition
            end
        end

        local Distance = GMM_C.CameraPosition:Distance(Position)

        local __Volume = 0
        if Distance <= IDistance then
            __Volume = 1
        elseif Distance >= ADistance then
            __Volume = 0
        else
            __Volume = 1 - ((Distance - IDistance) / (ADistance - IDistance))
        end

        __Volume = __Volume * Volume

        if not Working then __Volume = 0 end
        GMM_C.Environment.AmbientSounds[i][10] = Working
        Channel:SetVolume(__Volume)
    end

    for i = #GMM_C.Environment.Particles, 1, -1 do
        local ParticalData = GMM_C.Environment.Particles[i]

        local Partical  = ParticalData[1]
        local Position  = ParticalData[2]
        local Delay     = ParticalData[3]
        local RunFunc   = ParticalData[4]
        local Angle__   = ParticalData[5]
        local Power     = ParticalData[6]
        local StartTime = ParticalData[7]

        if StartTime == nil or (CurrentTime - StartTime > Delay) then
            StartTime = CurrentTime
            RunFunc()
            GMM_C.Environment.Particles[i][7] = StartTime
        end
    end

    for _, Zone in ipairs(GMM_C.Environment.Zones) do
        local Type    = Zone[1]
        local P1      = Zone[2]
        local P2      = Zone[3]
        local Density = Zone[4]
        local Color   = Zone[5]

        local MinX, MaxX = math.min(P1.x, P2.x), math.max(P1.x, P2.x)
        local MinY, MaxY = math.min(P1.y, P2.y), math.max(P1.y, P2.y)
        local MinZ, MaxZ = math.min(P1.z, P2.z), math.max(P1.z, P2.z)

        local Center = (P1 + P2) / 2

        local IsNear = GMM_C.CameraPosition:DistToSqr(Center) < (2500*2500)
        local IsInside = (GMM_C.CameraPosition.x >= MinX and GMM_C.CameraPosition.x <= MaxX) and
                (GMM_C.CameraPosition.y >= MinY and GMM_C.CameraPosition.y <= MaxY) and
                (GMM_C.CameraPosition.z >= MinZ and GMM_C.CameraPosition.z <= MaxZ)

        if IsNear or IsInside then
            if Type == "Rain" then
                for i = 1, Density do
                    GMM_C.Func.SpawnRainDrop(Vector(math.random(MinX, MaxX), math.random(MinY, MaxY), math.max(math.min(GMM_C.CameraPosition.z + 1000, MaxZ), MinZ)), Color)
                end
            end
        end
    end
end