AddCSLuaFile()

ENT.Type      = "anim"
ENT.Base      = "base_anim"
ENT.PrintName = "Wнat тbe бox?"
ENT.Author    = "Woowz11"
ENT.Category  = "GMM"
ENT.Spawnable = GMM.Func.DoEntitiesUnlock()

-- ----------------------------------------------------------------------
-- Общее
-- ----------------------------------------------------------------------

local ClosedModel = GMM.Maps.Old and "models/props_c17/BriefCase001a.mdl" or "models/woowz11/box_cardboard.mdl"
local OpenModel   = GMM.Maps.Old and "models/props_c17/BriefCase001a.mdl" or "models/woowz11/box_cardboard_open.mdl"
local BoxSkin     = 1

local BeepSound  = "buttons/blip2.wav"
local BeepLevel  = 70
local BeepVolume = 1
local BeepDelay  = 1

local FuseBeeps     = 6
local FuseDelay     = 0.1
local FusePitchStep = 12

local WaveRadius = 800
local GasRadius  = 300
local BlastNet   = "gmm_BombBox_Blast"

local Variants = {
    [0] = {Key = "Normal", Weight = 70, Tint = Color(255, 255, 255), Blast = Color(255, 160, 60),  Pitch = 100, Linger = 0},
    [1] = {Key = "Red",    Weight = 4,  Tint = Color(255, 40, 40),   Blast = Color(255, 70, 20),   Pitch = 130, Linger = 0},
    [2] = {Key = "Green",  Weight = 4,  Tint = Color(70, 255, 70),   Blast = Color(100, 255, 80),  Pitch = 80,  Linger = 10},
    [3] = {Key = "Blue",   Weight = 4,  Tint = Color(60, 110, 255),  Blast = Color(90, 170, 255),  Pitch = 160, Linger = 0},
    [4] = {Key = "Black",  Weight = 1,  Tint = Color(30, 30, 34),    Blast = Color(170, 170, 210), Pitch = 50,  Linger = 0, Requires = "HelpMe"},
    [5] = {Key = "Purple", Weight = 2,  Tint = Color(190, 70, 255),  Blast = Color(200, 90, 255),  Pitch = 115, Linger = 0},
}

local VariantMax = 5

local function GetDef(Index)
    return Variants[Index] or Variants[0]
end

local function IsVariantAllowed(Index)
    local Need = Variants[Index].Requires

    if Need == nil then return true end
    if GMM == nil or GMM.Extra == nil then return false end

    return GMM.Extra[Need] == true
end

local function RollVariant()
    local Total = 0

    for i = 0, VariantMax do
        if IsVariantAllowed(i) then Total = Total + Variants[i].Weight end
    end

    local Roll = math.random() * Total

    for i = 0, VariantMax do
        if IsVariantAllowed(i) then
            Roll = Roll - Variants[i].Weight

            if Roll <= 0 then return i end
        end
    end

    return 0
end

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "Variant")
end

-- ----------------------------------------------------------------------
-- Сервер
-- ----------------------------------------------------------------------

if SERVER then
    util.AddNetworkString(BlastNet)

    local HitSpeedMin   = 350
    local HitSpeedFull  = 1200
    local HitDamageMin  = 1
    local HitDamageFull = 60
    local HitChance     = 0.7
    local HitCooldown   = 0.3
    local PickupMass = 30

    local BlastRadius = 350
    local BlastDamage = 220

    local WaveSpeedProp   = 900
    local WaveSpeedPlayer = 700
    local WaveSpeedNpc    = 600
    local WaveLiftFactor  = 0.4
    local WaveSpin        = 200

    local ShakeAmplitude = 25
    local ShakeFrequency = 150
    local ShakeDuration  = 2

    local DecalFloorCount  = 10
    local DecalFloorSpread = 180
    local DecalFloorDrop   = 120
    local DecalWallCount   = 10
    local DecalWallReach   = 260

    local ExplodeSounds = {"weapons/explode3.wav", "weapons/explode4.wav", "weapons/explode5.wav"}
    local RumbleSound   = "ambient/explosions/explode_4.wav"

    local BurnFactor  = 0.6
    local OpenBoxKick = 80
    local OpenBoxLift = 200

    local FireRadius        = 450
    local FireSeconds       = 8
    local FirePlayerSeconds = 4

    local GasTickDelay = 0.5
    local GasDamage    = 4

    local CryoRadius  = 500
    local CryoSeconds = 6
    local CryoSlow    = 0.25
    local CryoColor   = Color(120, 180, 255, 140)

    local VoidHeight  = 260
    local VoidSeconds = 12

    local GravityRadius  = 600
    local GravitySeconds = 8
    local GravityPlayer  = 0.15
    local GravityKick    = 350

    local UpVector = Vector(0, 0, 1)

    local function GetKind(Source, Ent)
        if not IsValid(Ent) then return nil end
        if Ent == Source then return nil end
        if Ent:GetClass() == "gmm_blackhole" then return nil end

        if Ent:IsPlayer() then
            if not Ent:Alive() then return nil end
            if Ent:GetMoveType() == MOVETYPE_NOCLIP then return nil end
            return "Player"
        end

        if Ent:IsNPC() or Ent:IsNextBot() then return "Npc" end
        if Ent:IsWeapon() then return nil end
        if IsValid(Ent:GetParent()) then return nil end
        if Ent:GetMoveType() ~= MOVETYPE_VPHYSICS then return nil end

        return "Prop"
    end

    local function PushProp(Ent, Dir, Fraction)
        if Ent:IsPlayerHolding() then return end

        local Add = Dir * WaveSpeedProp * Fraction

        for i = 0, Ent:GetPhysicsObjectCount() - 1 do
            local Phys = Ent:GetPhysicsObjectNum(i)

            if IsValid(Phys) and Phys:IsMotionEnabled() then
                Phys:Wake()
                Phys:AddVelocity(Add)
                Phys:AddAngleVelocity(VectorRand() * WaveSpin * Fraction)
            end
        end
    end

    local function ShockWave(Source, Pos)
        local Found = ents.FindInSphere(Pos, WaveRadius)

        for i = 1, #Found do
            local Ent  = Found[i]
            local Kind = GetKind(Source, Ent)

            if Kind ~= nil then
                local Dir  = Ent:WorldSpaceCenter() - Pos
                local Dist = Dir:Length()

                if Dist < 1 then
                    Dir:SetUnpacked(0, 0, 1)
                else
                    Dir:Normalize()
                end

                Dir.z = Dir.z + WaveLiftFactor
                Dir:Normalize()

                local Fraction = 1 - math.min(Dist / WaveRadius, 1)

                if Kind == "Player" then
                    Ent:SetVelocity(Dir * WaveSpeedPlayer * Fraction)
                elseif Kind == "Npc" then
                    if Ent:IsNextBot() then
                        local Loco = Ent.loco

                        if Loco ~= nil then
                            Loco:SetVelocity(Loco:GetVelocity() + Dir * WaveSpeedNpc * Fraction)
                        end
                    else
                        Ent:SetVelocity(Dir * WaveSpeedNpc * Fraction)
                    end
                else
                    PushProp(Ent, Dir, Fraction)
                end
            end
        end
    end

    local function LeaveDecals(Source, Pos)
        for i = 1, DecalFloorCount do
            local Offset = Vector(math.Rand(-1, 1), math.Rand(-1, 1), 0) * DecalFloorSpread

            util.Decal("Scorch", Pos + Offset + UpVector * 20, Pos + Offset - UpVector * DecalFloorDrop, Source)
        end

        for i = 1, DecalWallCount do
            local Dir = VectorRand():GetNormalized()

            util.Decal(i % 3 == 0 and "FadingScorch" or "Scorch", Pos, Pos + Dir * DecalWallReach, Source)
        end
    end

    local function LeaveOpenBox(Source)
        local Box = ents.Create("prop_physics")

        if not IsValid(Box) then
            print("[GMM] BOMB BOX OPEN CREATE FAILED! MODEL: " .. OpenModel .. ", POS: " .. tostring(Source:GetPos()))
            return nil
        end

        local Tint = Source:GetColor()

        Box:SetModel(OpenModel)
        Box:SetSkin(BoxSkin)
        Box:SetPos(Source:GetPos())
        Box:SetAngles(Source:GetAngles())
        Box:SetColor(Color(Tint.r * BurnFactor, Tint.g * BurnFactor, Tint.b * BurnFactor, 255))
        Box:Spawn()
        Box:Activate()

        local Phys = Box:GetPhysicsObject()

        if IsValid(Phys) then
            Phys:Wake()
            Phys:SetVelocity(VectorRand() * OpenBoxKick + UpVector * OpenBoxLift)
        end

        return Box
    end

    local function EffectFire(Source, Pos, Box)
        local Found = ents.FindInSphere(Pos, FireRadius)

        for i = 1, #Found do
            local Ent  = Found[i]
            local Kind = GetKind(Source, Ent)

            if Kind == "Player" then
                Ent:Ignite(FirePlayerSeconds)
            elseif Kind ~= nil then
                Ent:Ignite(FireSeconds)
            end
        end
    end

    local function EffectGas(Source, Pos, Box)
        local Name  = "gmm_BombBox_Gas_" .. Source:EntIndex() .. "_" .. math.floor(CurTime() * 100)
        local Ticks = math.floor(GetDef(2).Linger / GasTickDelay)
        local World = game.GetWorld()

        timer.Create(Name, GasTickDelay, Ticks, function()
            local Found = ents.FindInSphere(Pos, GasRadius)

            for i = 1, #Found do
                local Ent  = Found[i]
                local Kind = GetKind(nil, Ent)

                if Kind == "Player" or Kind == "Npc" then
                    local Dmg = DamageInfo()

                    Dmg:SetDamage(GasDamage)
                    Dmg:SetDamageType(DMG_POISON)
                    Dmg:SetAttacker(World)
                    Dmg:SetInflictor(World)

                    Ent:TakeDamageInfo(Dmg)
                end
            end
        end)
    end

    local function EffectCryo(Source, Pos, Box)
        local Found   = ents.FindInSphere(Pos, CryoRadius)
        local Players = {}
        local Frozen  = {}

        for i = 1, #Found do
            local Ent  = Found[i]
            local Kind = GetKind(Source, Ent)

            if Kind == "Player" then
                Ent:SetLaggedMovementValue(CryoSlow)
                Ent:ScreenFade(SCREENFADE.IN, CryoColor, 1, 0.5)

                Players[#Players + 1] = Ent
            elseif Kind == "Prop" and Ent ~= Box then
                for p = 0, Ent:GetPhysicsObjectCount() - 1 do
                    local Phys = Ent:GetPhysicsObjectNum(p)

                    if IsValid(Phys) and Phys:IsMotionEnabled() then
                        Phys:EnableMotion(false)
                        Frozen[#Frozen + 1] = Phys
                    end
                end
            end
        end

        timer.Simple(CryoSeconds, function()
            for i = 1, #Players do
                if IsValid(Players[i]) then Players[i]:SetLaggedMovementValue(1) end
            end

            for i = 1, #Frozen do
                if IsValid(Frozen[i]) then
                    Frozen[i]:EnableMotion(true)
                    Frozen[i]:Wake()
                end
            end
        end)
    end

    local function EffectVoid(Source, Pos, Box)
        if scripted_ents.Get("gmm_blackhole") == nil then
            print("[GMM] BOMB BOX VOID FAILED! CLASS NOT FOUND: gmm_blackhole")
            return
        end

        local Hole = ents.Create("gmm_blackhole")

        if not IsValid(Hole) then
            print("[GMM] BOMB BOX VOID CREATE FAILED! CLASS: gmm_blackhole, POS: " .. tostring(Pos))
            return
        end

        Hole:SetPos(Pos + UpVector * VoidHeight)
        Hole:Spawn()
        Hole:Activate()

        local Phys = Hole:GetPhysicsObject()
        if IsValid(Phys) then Phys:EnableMotion(false) end

        if IsValid(Box) then
            local BoxPhys = Box:GetPhysicsObject()
            if IsValid(BoxPhys) then BoxPhys:EnableMotion(false) end
        end

        SafeRemoveEntityDelayed(Hole, VoidSeconds)
    end

    local function EffectGravity(Source, Pos, Box)
        local Found   = ents.FindInSphere(Pos, GravityRadius)
        local Players = {}
        local Floated = {}

        for i = 1, #Found do
            local Ent  = Found[i]
            local Kind = GetKind(Source, Ent)

            if Kind == "Player" then
                Ent:SetGravity(GravityPlayer)
                Ent:SetVelocity(UpVector * GravityKick)

                Players[#Players + 1] = Ent
            elseif Kind == "Prop" then
                for p = 0, Ent:GetPhysicsObjectCount() - 1 do
                    local Phys = Ent:GetPhysicsObjectNum(p)

                    if IsValid(Phys) and Phys:IsMotionEnabled() then
                        Phys:Wake()
                        Phys:EnableGravity(false)
                        Phys:AddVelocity(UpVector * GravityKick * 0.5)

                        Floated[#Floated + 1] = Phys
                    end
                end
            end
        end

        timer.Simple(GravitySeconds, function()
            for i = 1, #Players do
                if IsValid(Players[i]) then Players[i]:SetGravity(1) end
            end

            for i = 1, #Floated do
                if IsValid(Floated[i]) then
                    Floated[i]:EnableGravity(true)
                    Floated[i]:Wake()
                end
            end
        end)
    end

    local VariantEffects = {
        [1] = EffectFire,
        [2] = EffectGas,
        [3] = EffectCryo,
        [4] = EffectVoid,
        [5] = EffectGravity,
    }

    local function HitChanceOf(Strength, Min, Full)
        if Strength <= Min then return 0 end

        return math.min((Strength - Min) / (Full - Min), 1) * HitChance
    end

    function ENT:Initialize()
        self.Exploded = false
        self.Armed    = false
        self.FuseLeft = 0
        self.NextHit  = 0

        self:SetModel(ClosedModel)
        self:SetSkin(BoxSkin)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)

        local Phys = self:GetPhysicsObject()

        if not IsValid(Phys) then
            print("[GMM] BOMB BOX PHYSICS NOT FOUND! MODEL: " .. ClosedModel .. ", POS: " .. tostring(self:GetPos()))
            return
        end

        if Phys:GetMass() > PickupMass then Phys:SetMass(PickupMass) end

        Phys:Wake()

        self:SetVariant(RollVariant())
        self:ApplyVariant()
        self:NextThink(CurTime() + math.Rand(0, BeepDelay))
    end

    function ENT:ApplyVariant()
        self:SetColor(GetDef(self:GetVariant()).Tint)
    end

    function ENT:Use(Activator)
        if self.Exploded then return end
        if not IsValid(Activator) or not Activator:IsPlayer() then return end
        if self:IsPlayerHolding() then return end

        local Phys = self:GetPhysicsObject()

        if not IsValid(Phys) then return end
        if not Phys:IsMotionEnabled() then return end

        Activator:PickupObject(self)
    end

    function ENT:Arm(Delay)
        if self.Exploded or self.Armed then return end

        self.Armed    = true
        self.FuseLeft = FuseBeeps

        self:NextThink(CurTime() + (Delay or 0))
    end

    function ENT:RollHit(Strength, Min, Full)
        if self.Exploded or self.Armed then return end

        if math.random() < HitChanceOf(Strength, Min, Full) then self:Arm(0) end
    end

    function ENT:PhysicsCollide(Data, Phys)
        if self.Exploded then return end

        local Now = CurTime()
        if Now < self.NextHit then return end

        local Our   = Data.OurOldVelocity
        local Their = Data.TheirOldVelocity
        local Dx    = Our.x - Their.x
        local Dy    = Our.y - Their.y
        local Dz    = Our.z - Their.z
        local Speed = math.sqrt(Dx * Dx + Dy * Dy + Dz * Dz)

        if Speed < HitSpeedMin then return end

        self.NextHit = Now + HitCooldown

        self:RollHit(Speed, HitSpeedMin, HitSpeedFull)
    end

    function ENT:OnTakeDamage(Dmg)
        if self.Exploded then return end
        if Dmg:IsDamageType(DMG_CRUSH) then return end

        self:TakePhysicsDamage(Dmg)

        if Dmg:IsExplosionDamage() then
            self:Arm(math.Rand(0.1, 0.4))
            return
        end

        self:RollHit(Dmg:GetDamage(), HitDamageMin, HitDamageFull)
    end

    function ENT:Think()
        if self.Exploded then return end

        local Now = CurTime()
        local Def = GetDef(self:GetVariant())

        if self.Armed then
            if self.FuseLeft <= 0 then
                self:Explode()
                return
            end

            local Pitch = Def.Pitch + (FuseBeeps - self.FuseLeft) * FusePitchStep

            self:EmitSound(BeepSound, BeepLevel, math.min(Pitch, 255), BeepVolume)

            self.FuseLeft = self.FuseLeft - 1

            self:NextThink(Now + FuseDelay)
            return true
        end

        self:EmitSound(BeepSound, BeepLevel, Def.Pitch, BeepVolume)

        self:NextThink(Now + BeepDelay)

        return true
    end

    function ENT:Explode()
        if self.Exploded then return end

        self.Exploded = true

        local Pos   = self:WorldSpaceCenter()
        local Index = self:GetVariant()
        local Def   = GetDef(Index)
        local Data  = EffectData()

        Data:SetOrigin(Pos)
        Data:SetScale(1)
        Data:SetMagnitude(1)

        util.Effect("Explosion", Data)

        util.BlastDamage(self, self, Pos, BlastRadius, BlastDamage)
        ShockWave(self, Pos)
        LeaveDecals(self, Pos)

        sound.Play(ExplodeSounds[math.random(#ExplodeSounds)], Pos, 140, math.random(85, 105), 1)
        sound.Play(RumbleSound, Pos, 130, 60, 1)

        util.ScreenShake(Pos, ShakeAmplitude, ShakeFrequency, ShakeDuration, WaveRadius * 3)

        net.Start(BlastNet)
        net.WriteVector(Pos)
        net.WriteUInt(Index, 4)
        net.Broadcast()

        local Box   = LeaveOpenBox(self)
        local Extra = VariantEffects[Index]

        if Extra ~= nil then
            local Ok, Err = pcall(Extra, self, Pos, Box)

            if not Ok then
                print("[GMM] BOMB BOX VARIANT EFFECT FAILED! VARIANT: " .. Def.Key .. ", ERROR: " .. tostring(Err))
            end
        end

        self:Remove()
    end
end

-- ----------------------------------------------------------------------
-- Клиент
-- ----------------------------------------------------------------------

if CLIENT then
    local OldFX = GMM_BombBoxFX
    if OldFX ~= nil and OldFX.Cleanup ~= nil then pcall(OldFX.Cleanup) end

    local FX = {}
    GMM_BombBoxFX = FX

    local RingSeconds = 0.6
    local RingAlpha   = 110

    local LightSeconds = 0.6
    local LightSize    = 900
    local LightBright  = 6
    local LightIdBase  = 21000
    local LightIdCount = 32

    local FireballCount = 30
    local SmokeCount    = 24
    local SparkCount    = 40
    local DustCount     = 24
    local GasPartDelay  = 0.1
    local GasPartCount  = 4

    local FireMaterial  = Material("effects/fire_cloud1")
    local SmokeMaterial = Material("particle/particle_smokegrenade")
    local SparkMaterial = Material("effects/spark")

    local UpVector      = Vector(0, 0, 1)
    local GravityVector = Vector(0, 0, -600)
    local RingColor     = Color(255, 255, 255, 255)

    local Blasts       = {}
    local BlastCounter = 0

    local function SpawnBurst(Emitter, Pos, Def)
        local Tone = Def.Blast
        local SmokeR = 40 + Tone.r * 0.15
        local SmokeG = 40 + Tone.g * 0.15
        local SmokeB = 40 + Tone.b * 0.15

        for i = 1, FireballCount do
            local Part = Emitter:Add(FireMaterial, Pos + VectorRand() * 20)

            if Part ~= nil then
                Part:SetVelocity(VectorRand() * math.Rand(150, 550))
                Part:SetAirResistance(150)
                Part:SetDieTime(math.Rand(0.5, 1.1))
                Part:SetStartAlpha(255)
                Part:SetEndAlpha(0)
                Part:SetStartSize(math.Rand(50, 90))
                Part:SetEndSize(math.Rand(120, 200))
                Part:SetRoll(math.Rand(0, 360))
                Part:SetRollDelta(math.Rand(-2, 2))
                Part:SetColor(Tone.r, Tone.g, Tone.b)
            end
        end

        for i = 1, SmokeCount do
            local Part = Emitter:Add(SmokeMaterial, Pos + VectorRand() * 30)

            if Part ~= nil then
                Part:SetVelocity(VectorRand() * 120 + UpVector * 150)
                Part:SetAirResistance(80)
                Part:SetGravity(UpVector * 20)
                Part:SetDieTime(math.Rand(3, 5))
                Part:SetStartAlpha(200)
                Part:SetEndAlpha(0)
                Part:SetStartSize(math.Rand(60, 100))
                Part:SetEndSize(math.Rand(220, 300))
                Part:SetRoll(math.Rand(0, 360))
                Part:SetRollDelta(math.Rand(-1, 1))
                Part:SetColor(SmokeR, SmokeG, SmokeB)
            end
        end

        for i = 1, SparkCount do
            local Part = Emitter:Add(SparkMaterial, Pos)

            if Part ~= nil then
                Part:SetVelocity(VectorRand():GetNormalized() * math.Rand(300, 1000))
                Part:SetGravity(GravityVector)
                Part:SetDieTime(math.Rand(0.8, 1.6))
                Part:SetStartAlpha(255)
                Part:SetEndAlpha(0)
                Part:SetStartSize(4)
                Part:SetEndSize(1)
                Part:SetStartLength(40)
                Part:SetEndLength(4)
                Part:SetCollide(true)
                Part:SetBounce(0.4)
                Part:SetColor(Tone.r, Tone.g, Tone.b)
            end
        end

        for i = 1, DustCount do
            local Dir  = Vector(math.Rand(-1, 1), math.Rand(-1, 1), 0):GetNormalized()
            local Part = Emitter:Add(SmokeMaterial, Pos + Dir * 20)

            if Part ~= nil then
                Part:SetVelocity(Dir * math.Rand(300, 700) + UpVector * math.Rand(0, 40))
                Part:SetAirResistance(200)
                Part:SetDieTime(math.Rand(1.2, 2))
                Part:SetStartAlpha(120)
                Part:SetEndAlpha(0)
                Part:SetStartSize(math.Rand(40, 70))
                Part:SetEndSize(math.Rand(120, 180))
                Part:SetRoll(math.Rand(0, 360))
                Part:SetColor(160, 150, 130)
            end
        end
    end

    local function SpawnGas(Blast)
        local Tone = Blast.Def.Blast

        for i = 1, GasPartCount do
            local Part = Blast.Emitter:Add(SmokeMaterial, Blast.Pos + VectorRand() * GasRadius)

            if Part ~= nil then
                Part:SetVelocity(VectorRand() * 20 + UpVector * 25)
                Part:SetDieTime(math.Rand(2, 3))
                Part:SetStartAlpha(60)
                Part:SetEndAlpha(0)
                Part:SetStartSize(math.Rand(60, 90))
                Part:SetEndSize(math.Rand(160, 220))
                Part:SetRoll(math.Rand(0, 360))
                Part:SetRollDelta(math.Rand(-0.5, 0.5))
                Part:SetColor(Tone.r, Tone.g, Tone.b)
            end
        end
    end

    local function UpdateBlast(Blast, Now)
        local Age = Now - Blast.Start

        if Age < LightSeconds then
            local Light = DynamicLight(Blast.LightId)

            if Light ~= nil then
                local Fade = 1 - Age / LightSeconds
                local Tone = Blast.Def.Blast

                Light.Pos        = Blast.Pos
                Light.r          = Tone.r
                Light.g          = Tone.g
                Light.b          = Tone.b
                Light.Brightness = LightBright * Fade
                Light.Size       = LightSize * (0.4 + 0.6 * Fade)
                Light.Decay      = 1000
                Light.DieTime    = CurTime() + 0.1
            end
        end

        if Blast.Emitter ~= nil and Age < Blast.Def.Linger and Now >= Blast.NextGas then
            Blast.NextGas = Now + GasPartDelay
            SpawnGas(Blast)
        end
    end

    net.Receive(BlastNet, function()
        local Pos   = net.ReadVector()
        local Index = net.ReadUInt(4)
        local Def   = GetDef(Index)
        local Now   = RealTime()

        local Emitter = ParticleEmitter(Pos, false)

        SpawnBurst(Emitter, Pos, Def)

        BlastCounter = BlastCounter + 1

        local Blast = {
            Pos     = Pos,
            Start   = Now,
            Def     = Def,
            Emitter = nil,
            NextGas = 0,
            LightId = LightIdBase + BlastCounter % LightIdCount,
            End     = Now + math.max(RingSeconds, LightSeconds, Def.Linger),
        }

        if Def.Linger > 0 then
            Blast.Emitter = Emitter
        else
            Emitter:Finish()
        end

        Blasts[#Blasts + 1] = Blast
    end)

    hook.Add("Think", "gmm_BombBox_Think", function()
        local Count = #Blasts
        if Count == 0 then return end

        local Now = RealTime()

        for i = Count, 1, -1 do
            local Blast = Blasts[i]

            if Now >= Blast.End then
                if Blast.Emitter ~= nil then Blast.Emitter:Finish() end

                table.remove(Blasts, i)
            else
                UpdateBlast(Blast, Now)
            end
        end
    end)

    hook.Add("PostDrawTranslucentRenderables", "gmm_BombBox_Draw", function(Depth, Skybox, Sky3D)
        if Skybox or Sky3D then return end

        local Count = #Blasts
        if Count == 0 then return end

        local Now = RealTime()

        render.SetColorMaterial()

        for i = 1, Count do
            local Blast = Blasts[i]
            local Age   = (Now - Blast.Start) / RingSeconds

            if Age < 1 then
                local Radius = WaveRadius * (1 - (1 - Age) * (1 - Age))
                local Tone   = Blast.Def.Blast

                RingColor.r = Tone.r
                RingColor.g = Tone.g
                RingColor.b = Tone.b
                RingColor.a = RingAlpha * (1 - Age)

                render.DrawSphere(Blast.Pos, Radius, 24, 24, RingColor)
                render.DrawSphere(Blast.Pos, -Radius, 24, 24, RingColor)
            end
        end
    end)

    FX.Cleanup = function()
        for i = 1, #Blasts do
            if Blasts[i].Emitter ~= nil then Blasts[i].Emitter:Finish() end
        end

        Blasts = {}

        hook.Remove("Think", "gmm_BombBox_Think")
        hook.Remove("PostDrawTranslucentRenderables", "gmm_BombBox_Draw")
    end
end