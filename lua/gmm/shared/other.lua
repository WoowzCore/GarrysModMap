do
    local NwCold      = "gmm_Cold"
    local NwFrozen    = "gmm_Frozen"
    local NwIced      = "gmm_Iced"
    local ColdSlowMax = 0.7

    hook.Add("SetupMove", "gmm_Freeze_Slow", function(Ply, Mv, Cmd)
        local Cold = Ply:GetNWFloat(NwCold, 0)
        if Cold <= 0 then return end

        local Factor = 1 - ColdSlowMax * math.min(Cold, 1)

        Mv:SetMaxClientSpeed(Mv:GetMaxClientSpeed() * Factor)
        Mv:SetMaxSpeed(Mv:GetMaxSpeed() * Factor)
    end)

    -- ----------------------------------------------------------------------

    if SERVER then
        timer.Remove("gmm_Freeze_Pending")
        timer.Remove("gmm_Freeze_Fire")

        util.AddNetworkString("gmm_Freeze_Ice")
        util.AddNetworkString("gmm_Freeze_Unfreeze")
        util.AddNetworkString("gmm_Freeze_Kill")

        GMM_S.Func = GMM_S.Func or {}

        GMM_S.Freeze = {
            Immune  = {worldspawn = true, gmm_blackhole = true, prop_coreball = true},
            Pending = {},
            Frozen  = {},
            Cold    = {}
        }

        local Freeze = GMM_S.Freeze

        local FreezeThreshold = 100
        local ColdDecay       = 10
        local StatueColdMin   = 50
        local IceHealth       = 80
        local IceBlastScale   = 2
        local IceMinDamage    = 1
        local IceHitDelay     = 0.08
        local MeltRadius      = 90
        local MeltRadiusSqr   = MeltRadius * MeltRadius
        local FlameClass      = "entityflame"
        local RagdollDelay    = 0.15
        local PendingDelay    = 0.1
        local FireDelay       = 0.2
        local TouchGap        = 6
        local RagdollGap      = 12
        local RestSpeedSqr    = 25
        local RestTime        = 0.15
        local BlockHintDelay  = 0.4
        local TearGrace       = 0.5
        local DropDelay       = 0.05

        local FreezeSound   = "physics/glass/glass_impact_bullet4.wav"
        local UnfreezeSound = "ambient/water/drip1.wav"

        local HitSounds = {
            "physics/glass/glass_impact_bullet1.wav",
            "physics/glass/glass_impact_bullet2.wav",
            "physics/glass/glass_impact_bullet3.wav",
            "physics/glass/glass_impact_bullet4.wav",
            "physics/glass/glass_sheet_impact_hard1.wav",
            "physics/glass/glass_sheet_impact_hard2.wav",
            "physics/glass/glass_sheet_impact_hard3.wav"
        }

        local BreakSounds = {
            "physics/glass/glass_largesheet_break1.wav",
            "physics/glass/glass_largesheet_break2.wav",
            "physics/glass/glass_largesheet_break3.wav",
            "physics/glass/glass_sheet_break1.wav"
        }

        local TouchDirs = {
            Vector(0, 0, -1),
            Vector(1, 0, 0),
            Vector(-1, 0, 0),
            Vector(0, 1, 0),
            Vector(0, -1, 0),
            Vector(0, 0, 1)
        }

        local UpVec     = Vector(0, 0, 1)
        local TraceData = {mask = MASK_SOLID}
        local TraceEnd  = Vector()
        local Reported  = {}

        local FireTick
        local UnfreezeEntity
        local FreezeEntity

        -- ----------------------------------------------------------------------

        local function RunSafe(Name, Func, ...)
            local Ok, Err = pcall(Func, ...)
            if Ok then return true end

            local Key = Name .. tostring(Err)

            if not Reported[Key] then
                Reported[Key] = true
                print("[GMM] FREEZE " .. Name .. " FAILED! ERROR: " .. tostring(Err))
            end

            return false
        end

        local function SetIced(Ent, On, Instant)
            if not IsValid(Ent) then return end

            Ent:SetNWBool(NwIced, On)
            Ent.GMMIceHealth = On and IceHealth or nil

            net.Start("gmm_Freeze_Ice")
            net.WriteEntity(Ent)
            net.WriteBool(On)
            net.WriteBool(Instant == true)
            net.Broadcast()
        end

        local function StartMeltTimer()
            if timer.Exists("gmm_Freeze_Fire") then return end

            timer.Create("gmm_Freeze_Fire", FireDelay, 0, function()
                RunSafe("FIRE TICK", FireTick)
            end)
        end

        -- ----------------------------------------------------------------------

        local function GetCold(Ent)
            local Value = Ent.GMMCold
            if Value == nil then return 0 end

            local Left = Value - (CurTime() - Ent.GMMColdTime) * ColdDecay
            if Left < 0 then return 0 end

            return Left
        end

        local function SetColdLevel(Ent, Value)
            if Ent:IsPlayer() then Ent:SetNWFloat(NwCold, Value / FreezeThreshold) end
        end

        local function ClearCold(Ent)
            Ent.GMMCold      = nil
            Ent.GMMColdTime  = nil
            Freeze.Cold[Ent] = nil

            if Ent:IsPlayer() then Ent:SetNWFloat(NwCold, 0) end
        end

        local function AddCold(Ent, Power)
            local Total = GetCold(Ent) + Power

            Ent.GMMCold      = Total
            Ent.GMMColdTime  = CurTime()
            Freeze.Cold[Ent] = true

            SetColdLevel(Ent, Total)
            StartMeltTimer()

            return Total
        end

        local function ShouldStatue(Ent)
            if Ent.GMMFreezeDeath ~= nil and Ent.GMMFreezeDeath > CurTime() then return true end

            return GetCold(Ent) >= StatueColdMin
        end

        local DeathForce = Vector(0, 0, 0.01)

        local function GetNoticeName(Ent)
            if not IsValid(Ent) then return "" end
            if Ent:IsPlayer() then return Ent:Nick() end

            return Ent.PrintName or ("#" .. Ent:GetClass())
        end

        local function KillAsStatue(Ent, Attacker)
            Ent.GMMFreezeDeath = CurTime() + 1

            net.Start("gmm_Freeze_Kill")
            net.WriteString(GetNoticeName(Ent))
            net.WriteString(GetNoticeName(Attacker))
            net.Broadcast()

            if Ent:IsPlayer() then
                Ent:Kill()
                return
            end

            local Info = DamageInfo()
            Info:SetDamage(Ent:Health() + 100)
            Info:SetDamageType(DMG_GENERIC)
            Info:SetAttacker(game.GetWorld())
            Info:SetInflictor(game.GetWorld())
            Info:SetDamageForce(DeathForce)
            Info:SetDamagePosition(Ent:WorldSpaceCenter())

            Ent:TakeDamageInfo(Info)
        end

        -- ----------------------------------------------------------------------

        local function IsFreezeImmune(Ent)
            if not IsValid(Ent) then return true end
            if Ent:IsWorld() then return true end
            if Ent.GMMFreezeImmune == true then return true end

            return Freeze.Immune[Ent:GetClass()] == true
        end

        local function IsContactTarget(Other)
            if not IsValid(Other) then return false end
            if Other:IsWorld() then return true end
            if Other:IsPlayer() or Other:IsNPC() or Other:IsNextBot() then return false end
            if Other:GetNWBool(NwIced) and not Other:GetNWBool(NwFrozen) then return false end

            return IsValid(Other:GetPhysicsObject())
        end

        local function GetMaxSpeedSqr(Ent)
            local Max = 0

            for i = 0, Ent:GetPhysicsObjectCount() - 1 do
                local Phys = Ent:GetPhysicsObjectNum(i)

                if IsValid(Phys) then
                    local Speed = Phys:GetVelocity():LengthSqr()
                    if Speed > Max then Max = Speed end
                end
            end

            return Max
        end

        local function FindRagdollContact(Ent)
            for i = 0, Ent:GetPhysicsObjectCount() - 1 do
                local Phys = Ent:GetPhysicsObjectNum(i)

                if IsValid(Phys) then
                    local Pos = Phys:GetPos()

                    TraceEnd.x = Pos.x
                    TraceEnd.y = Pos.y
                    TraceEnd.z = Pos.z - RagdollGap

                    TraceData.start  = Pos
                    TraceData.endpos = TraceEnd
                    TraceData.filter = Ent

                    local Tr = util.TraceLine(TraceData)
                    if Tr.Hit and IsContactTarget(Tr.Entity) then return Tr.Entity end
                end
            end

            return nil
        end

        local function FindContact(Ent)
            if Ent:GetPhysicsObjectCount() > 1 then return FindRagdollContact(Ent) end

            local Pos = Ent:GetPos()

            for i = 1, #TouchDirs do
                local Tr = util.TraceEntity({
                    start  = Pos,
                    endpos = Pos + TouchDirs[i] * TouchGap,
                    filter = Ent,
                    mask   = MASK_SOLID
                }, Ent)

                if Tr.Hit and IsContactTarget(Tr.Entity) then return Tr.Entity end
            end

            return nil
        end

        -- ----------------------------------------------------------------------

        local function FreezeStatic(Ent)
            for i = 0, Ent:GetPhysicsObjectCount() - 1 do
                local Phys = Ent:GetPhysicsObjectNum(i)
                if IsValid(Phys) then Phys:EnableMotion(false) end
            end
        end

        local function ReleaseStatic(Ent)
            for i = 0, Ent:GetPhysicsObjectCount() - 1 do
                local Phys = Ent:GetPhysicsObjectNum(i)

                if IsValid(Phys) then
                    Phys:EnableMotion(true)
                    Phys:Wake()
                end
            end
        end

        local function EnsureSolid(Ent)
            local Group = Ent:GetCollisionGroup()

            if Group == COLLISION_GROUP_DEBRIS or Group == COLLISION_GROUP_DEBRIS_TRIGGER or Group == COLLISION_GROUP_WEAPON then
                Ent.GMMIceGroup = Group
                Ent:SetCollisionGroup(COLLISION_GROUP_NONE)
            end

            if bit.band(Ent:GetSolidFlags(), FSOLID_NOT_SOLID) ~= 0 then
                Ent.GMMIceNotSolid = true
                Ent:RemoveSolidFlags(FSOLID_NOT_SOLID)
            end
        end

        local function RestoreSolid(Ent)
            if Ent.GMMIceGroup ~= nil then
                Ent:SetCollisionGroup(Ent.GMMIceGroup)
                Ent.GMMIceGroup = nil
            end

            if Ent.GMMIceNotSolid then
                Ent:AddSolidFlags(FSOLID_NOT_SOLID)
                Ent.GMMIceNotSolid = nil
            end
        end

        local function OnWeldRemoved(Ent)
            if not IsValid(Ent) then return end
            if Ent.GMMFreezeWelds == nil then return end

            local Welds = Ent.GMMFreezeWelds
            Ent.GMMFreezeWelds = nil

            if istable(Welds) then
                for i = 1, #Welds do
                    if IsValid(Welds[i]) then Welds[i]:Remove() end
                end
            end

            timer.Simple(0, function()
                if not IsValid(Ent) then return end

                GMM_S.Freeze.Detach(Ent)
            end)
        end

        local function RemoveWelds(Ent)
            local Welds = Ent.GMMFreezeWelds
            if Welds == nil then return end

            Ent.GMMFreezeWelds = nil

            for i = 1, #Welds do
                if IsValid(Welds[i]) then Welds[i]:Remove() end
            end
        end

        local function WeldTo(Ent, Other)
            local Welds = {}

            for i = 0, Ent:GetPhysicsObjectCount() - 1 do
                local Weld = constraint.Weld(Ent, Other, i, 0, 0, true, false)

                if not IsValid(Weld) then
                    for j = 1, #Welds do
                        if IsValid(Welds[j]) then Welds[j]:Remove() end
                    end

                    return false
                end

                Welds[#Welds + 1] = Weld
            end

            if #Welds == 0 then return false end

            for i = 1, #Welds do
                Welds[i]:CallOnRemove("gmm_Freeze_Weld", function()
                    OnWeldRemoved(Ent)
                end)
            end

            Ent.GMMFreezeWelds = Welds

            return true
        end

        local function RemoveHitCallback(Ent)
            local Id = Ent.GMMFreezeCallback
            if Id == nil then return end

            Ent.GMMFreezeCallback = nil
            Ent:RemoveCallback("PhysicsCollide", Id)
        end

        -- ----------------------------------------------------------------------

        local function ApplyFreeze(Ent, Contact)
            Freeze.Pending[Ent] = nil
            Ent.GMMRestSince    = nil
            Ent.GMMTearUntil    = nil

            RemoveHitCallback(Ent)
            ClearCold(Ent)

            if Ent:IsOnFire() then Ent:Extinguish() end

            EnsureSolid(Ent)

            local Welded = false

            if IsValid(Contact) and not Contact:IsWorld() and not IsFreezeImmune(Contact) then
                Welded = WeldTo(Ent, Contact)
            end

            if not Welded then FreezeStatic(Ent) end

            Ent:SetNWBool(NwFrozen, true)

            if not Ent:GetNWBool(NwIced) then SetIced(Ent, true, false) end

            Ent:EmitSound(FreezeSound, 70, math.random(95, 110))

            Freeze.Frozen[Ent] = true
            StartMeltTimer()
        end

        local function IsReleased(Ent, Now)
            if Ent.GMMTearUntil ~= nil and Now < Ent.GMMTearUntil then return false end
            if Ent:IsPlayerHolding() then return false end

            return true
        end

        local function TryApplyHit(Ent, Other)
            if not IsValid(Ent) or not Freeze.Pending[Ent] then return end
            if not IsContactTarget(Other) then return end
            if not IsReleased(Ent, CurTime()) then return end

            ApplyFreeze(Ent, Other)
        end

        local function CheckPending(Ent, Now)
            if not IsReleased(Ent, Now) then
                Ent.GMMRestSince = nil
                return
            end

            local Contact = FindContact(Ent)

            if Contact ~= nil then
                ApplyFreeze(Ent, Contact)
                return
            end

            if GetMaxSpeedSqr(Ent) > RestSpeedSqr then
                Ent.GMMRestSince = nil
                return
            end

            Ent.GMMRestSince = Ent.GMMRestSince or Now

            if Now - Ent.GMMRestSince >= RestTime then ApplyFreeze(Ent, nil) end
        end

        local function PendingTick()
            local Now = CurTime()

            for Ent in pairs(Freeze.Pending) do
                if not IsValid(Ent) then
                    Freeze.Pending[Ent] = nil
                else
                    RunSafe("PENDING", CheckPending, Ent, Now)
                end
            end

            if next(Freeze.Pending) == nil then timer.Remove("gmm_Freeze_Pending") end
        end

        local function StartPendingTimer()
            if timer.Exists("gmm_Freeze_Pending") then return end

            timer.Create("gmm_Freeze_Pending", PendingDelay, 0, PendingTick)
        end

        local function AddPending(Ent)
            if Freeze.Pending[Ent] then return end

            Freeze.Pending[Ent] = true
            Ent.GMMRestSince    = nil

            RemoveHitCallback(Ent)

            Ent.GMMFreezeCallback = Ent:AddCallback("PhysicsCollide", function(Self, Data)
                local Other = Data.HitEntity
                if Other == Self or not IsContactTarget(Other) then return end

                timer.Simple(0, function()
                    TryApplyHit(Self, Other)
                end)
            end)

            SetIced(Ent, true, false)
            StartPendingTimer()
        end

        local RagdollDown     = Vector(0, 0, -RagdollGap)
        local RagdollRestSqr  = RestSpeedSqr * 4
        local RagdollCheck    = 0.05
        local RagdollWaitName = "gmm_Freeze_RagdollWait_"

        local function WeldRagdoll(Ent)
            if Ent.GMMStatueWelds ~= nil then return end

            local Count = Ent:GetPhysicsObjectCount()
            if Count < 2 then return end

            local Welds = {}

            for i = 1, Count - 1 do
                local Weld = constraint.Weld(Ent, Ent, 0, i, 0)

                if IsValid(Weld) then Welds[#Welds + 1] = Weld end
            end

            Ent.GMMStatueWelds = Welds
        end

        Freeze.ResetRagdoll = function(Ent)
            local Welds = Ent.GMMStatueWelds

            Ent.GMMStatueWelds    = nil
            Ent.GMMRagdollSettled = nil

            timer.Remove(RagdollWaitName .. Ent:EntIndex())

            if not istable(Welds) then return end

            for i = 1, #Welds do
                if IsValid(Welds[i]) then Welds[i]:Remove() end
            end
        end

        local function FreezeRagdollInPlace(Ent, Contact)
            if not IsValid(Ent) then return end

            for i = 0, Ent:GetPhysicsObjectCount() - 1 do
                local Phys = Ent:GetPhysicsObjectNum(i)

                if IsValid(Phys) then
                    Phys:SetVelocity(vector_origin)
                    Phys:AddAngleVelocity(-Phys:GetAngleVelocity())
                end
            end

            WeldRagdoll(Ent)

            Ent.GMMRagdollSettled = true

            ApplyFreeze(Ent, Contact or game.GetWorld())
        end

        local function ScanRagdoll(Ent)
            local Grounded = false
            local Contact  = game.GetWorld()
            local Still    = true

            for i = 0, Ent:GetPhysicsObjectCount() - 1 do
                local Phys = Ent:GetPhysicsObjectNum(i)

                if IsValid(Phys) then
                    if Phys:GetVelocity():LengthSqr() > RagdollRestSqr then Still = false end

                    if not Grounded then
                        local Pos   = Phys:GetPos()
                        local Trace = util.TraceLine({start = Pos, endpos = Pos + RagdollDown, filter = Ent, mask = MASK_SOLID})

                        if Trace.Hit and Trace.HitWorld then
                            Grounded = true
                        elseif Trace.Hit and IsContactTarget(Trace.Entity) then
                            Grounded = true
                            Contact  = Trace.Entity
                        end
                    end
                end
            end

            return Grounded, Contact, Still
        end

        local function WaitRagdoll(Ent, NeedStill)
            local TimerName = RagdollWaitName .. Ent:EntIndex()
            local Start     = CurTime()
            local RestSince = nil

            SetIced(Ent, true, false)

            timer.Create(TimerName, RagdollCheck, 0, function()
                if not IsValid(Ent) then timer.Remove(TimerName) return end
                if Ent:GetNWBool(NwFrozen) then timer.Remove(TimerName) return end
                if not Ent:GetNWBool(NwIced) then timer.Remove(TimerName) return end

                local Now = CurTime()

                if Ent:IsPlayerHolding() or (Ent.GMMTearUntil ~= nil and Ent.GMMTearUntil > Now) then
                    RestSince = nil
                    return
                end

                if Now - Start < RagdollDelay then return end

                local Grounded, Contact, Still = ScanRagdoll(Ent)

                if not Grounded then
                    RestSince = nil
                    return
                end

                if NeedStill then
                    if not Still then
                        RestSince = nil
                        return
                    end

                    if RestSince == nil then RestSince = Now end
                    if Now - RestSince < RestTime then return end
                end

                timer.Remove(TimerName)
                FreezeRagdollInPlace(Ent, Contact)
            end)
        end

        local __AddPendingBase = AddPending

        AddPending = function(Ent)
            if not IsValid(Ent) or not Ent:IsRagdoll() then
                __AddPendingBase(Ent)
                return
            end

            WaitRagdoll(Ent, Ent.GMMRagdollSettled == true)
        end

        -- ----------------------------------------------------------------------

        local function IsMelting(Ent, Positions)
            if Ent:IsOnFire() then return true end

            for i = 1, #Positions do
                if Ent:NearestPoint(Positions[i]):DistToSqr(Positions[i]) < MeltRadiusSqr then return true end
            end

            return false
        end

        local function CollectMelting(Set, Positions, Out)
            for Ent in pairs(Set) do
                if not IsValid(Ent) then
                    Set[Ent] = nil
                elseif IsMelting(Ent, Positions) then
                    Out[#Out + 1] = Ent
                end
            end
        end

        FireTick = function()
            local Melting = {}

            if next(Freeze.Frozen) ~= nil or next(Freeze.Pending) ~= nil then
                local Flames    = ents.FindByClass(FlameClass)
                local Positions = {}

                for i = 1, #Flames do
                    Positions[i] = Flames[i]:GetPos()
                end

                CollectMelting(Freeze.Frozen, Positions, Melting)
                CollectMelting(Freeze.Pending, Positions, Melting)
            end

            for i = 1, #Melting do
                UnfreezeEntity(Melting[i], false)
            end

            for Ent in pairs(Freeze.Cold) do
                if not IsValid(Ent) then
                    Freeze.Cold[Ent] = nil
                elseif Ent:IsOnFire() then
                    ClearCold(Ent)
                else
                    local Left = GetCold(Ent)

                    if Left <= 0 then
                        ClearCold(Ent)
                    else
                        SetColdLevel(Ent, Left)
                    end
                end
            end

            if next(Freeze.Frozen) == nil and next(Freeze.Pending) == nil and next(Freeze.Cold) == nil then
                timer.Remove("gmm_Freeze_Fire")
            end
        end

        -- ----------------------------------------------------------------------

        local function PlayShatterEffect(Ent)
            local Pos    = Ent:LocalToWorld(Ent:OBBCenter())
            local Radius = Ent:BoundingRadius() * 0.5

            for i = 1, 4 do
                local Data = EffectData()
                Data:SetOrigin(Pos + VectorRand() * Radius)
                Data:SetNormal(UpVec)
                Data:SetScale(1)

                util.Effect("GlassImpact", Data)
            end

            sound.Play(BreakSounds[math.random(#BreakSounds)], Pos, 80, math.random(90, 110))
        end

        local function PlayIceHit(Ent)
            local Now = CurTime()

            if Ent.GMMIceSoundNext ~= nil and Ent.GMMIceSoundNext > Now then return end

            Ent.GMMIceSoundNext = Now + IceHitDelay

            Ent:EmitSound(HitSounds[math.random(#HitSounds)], 72, math.random(90, 115))
        end

        UnfreezeEntity = function(Ent, Shatter)
            if not IsValid(Ent) then return false end

            ClearCold(Ent)

            Freeze.Pending[Ent] = nil
            Freeze.Frozen[Ent]  = nil

            RemoveHitCallback(Ent)

            if not Ent:GetNWBool(NwIced) then return false end

            SetIced(Ent, false, Shatter == true)
            Ent:SetNWBool(NwFrozen, false)

            Ent.GMMTearUntil = nil

            RemoveWelds(Ent)
            Freeze.ResetRagdoll(Ent)
            RestoreSolid(Ent)
            ReleaseStatic(Ent)

            if Shatter then
                PlayShatterEffect(Ent)
            else
                Ent:EmitSound(UnfreezeSound, 70, math.random(90, 110))
            end

            return true
        end

        FreezeEntity = function(Ent, Power, Attacker)
            if not IsValid(Ent) then return false end
            if IsFreezeImmune(Ent) then return false end
            if Ent:GetNWBool(NwIced) then return false end
            if Ent:IsNextBot() then return false end

            if Ent:IsPlayer() then
                if not Ent:Alive() then return false end
            elseif Ent:IsNPC() then
                if Ent:Health() <= 0 then return false end
            elseif not IsValid(Ent:GetPhysicsObject()) then
                return false
            end

            local Total = AddCold(Ent, Power or FreezeThreshold)
            if Total < FreezeThreshold then return true end

            if Ent:IsPlayer() or Ent:IsNPC() then
                KillAsStatue(Ent, Attacker)
                return true
            end

            ClearCold(Ent)

            if Ent:IsOnFire() then Ent:Extinguish() end

            AddPending(Ent)

            return true
        end

        -- ----------------------------------------------------------------------

        GMM_S.Func.IsFrozen        = function(Ent) return IsValid(Ent) and Ent:GetNWBool(NwFrozen) end
        GMM_S.Func.IsIced          = function(Ent) return IsValid(Ent) and Ent:GetNWBool(NwIced) end
        GMM_S.Func.GetCold         = function(Ent) return IsValid(Ent) and GetCold(Ent) or 0 end
        GMM_S.Func.IsChilled       = function(Ent) return IsValid(Ent) and GetCold(Ent) > 0 end
        GMM_S.Func.IsFreezeImmune  = IsFreezeImmune
        GMM_S.Func.FreezeEntity    = FreezeEntity
        GMM_S.Func.UnfreezeEntity  = UnfreezeEntity

        GMM_S.Func.SetFreezeImmune = function(Class, Value)
            Freeze.Immune[Class] = Value ~= false and true or nil
        end

        -- ----------------------------------------------------------------------

        hook.Add("EntityTakeDamage", "gmm_Freeze_Break", function(Target, Dmg)
            if Target.GMMIceHealth == nil then return end

            if Dmg:IsDamageType(DMG_BURN) or Dmg:IsDamageType(DMG_SLOWBURN) then return end
            if Dmg:IsDamageType(DMG_CRUSH) and not Target:GetNWBool(NwFrozen) then return true end

            PlayIceHit(Target)

            local Amount = Dmg:GetDamage()
            if Amount < IceMinDamage then return true end

            if Dmg:IsExplosionDamage() then Amount = Amount * IceBlastScale end

            Target.GMMIceHealth = Target.GMMIceHealth - Amount

            if Target.GMMIceHealth <= 0 then
                timer.Simple(0, function()
                    if IsValid(Target) then UnfreezeEntity(Target, true) end
                end)
            end

            return true
        end)

        -- ----------------------------------------------------------------------

        local function ReadBones(Ply)
            local Bones = {}
            if not IsValid(Ply) then return Bones end

            for i = 0, Ply:GetBoneCount() - 1 do
                local Pos, Ang = Ply:GetBonePosition(i)

                if Pos ~= nil and Ang ~= nil then
                    Bones[i] = {Pos = Pos, Ang = Ang}
                end
            end

            return Bones
        end

        local function TakeSnapshot(Ply)
            local Rag   = Ply:GetRagdollEntity()
            local Model = Ply:GetModel() or ""

            if not util.IsValidModel(Model) and IsValid(Rag) then Model = Rag:GetModel() or "" end

            local Groups = {}

            for i = 0, Ply:GetNumBodyGroups() - 1 do
                Groups[i] = Ply:GetBodygroup(i)
            end

            return {
                Model  = Model,
                Skin   = Ply:GetSkin(),
                Groups = Groups,
                Pos    = Ply:GetPos(),
                Ang    = Angle(0, Ply:GetAngles().y, 0),
                Bones  = ReadBones(Ply),
                Vel    = Ply:GetVelocity(),
                Color  = Ply:GetPlayerColor()
            }
        end

        local function ApplyBones(Statue, Snapshot)
            local Bones = Snapshot.Bones
            local Vel   = Snapshot.Vel

            for i = 0, Statue:GetPhysicsObjectCount() - 1 do
                local Phys = Statue:GetPhysicsObjectNum(i)
                local Data = Bones[Statue:TranslatePhysBoneToBone(i)]

                if IsValid(Phys) and Data ~= nil then
                    Phys:Wake()
                    Phys:SetPos(Data.Pos, true)
                    Phys:SetAngles(Data.Ang)
                    Phys:SetVelocity(Vel)
                end
            end
        end

        local function CreateStatue(Snapshot)
            if not util.IsValidModel(Snapshot.Model) then
                print("[GMM] FREEZE STATUE CREATE FAILED! MODEL: " .. tostring(Snapshot.Model))
                return nil
            end

            local Statue = ents.Create("prop_ragdoll")

            if not IsValid(Statue) then
                print("[GMM] FREEZE STATUE CREATE FAILED! CLASS: prop_ragdoll, MODEL: " .. Snapshot.Model)
                return nil
            end

            Statue:SetModel(Snapshot.Model)
            Statue:SetPos(Snapshot.Pos)
            Statue:SetAngles(Snapshot.Ang)
            Statue:SetSkin(Snapshot.Skin)

            for Id, Value in pairs(Snapshot.Groups) do
                Statue:SetBodygroup(Id, Value)
            end

            Statue:Spawn()
            Statue:Activate()

            Statue.GMMStatue = true

            Statue:SetNWBool("gmm_HasColor", Snapshot.Color ~= nil)
            if Snapshot.Color ~= nil then Statue:SetNWVector("gmm_PlayerColor", Snapshot.Color) end

            ApplyBones(Statue, Snapshot)

            return Statue
        end

        local function MakeStatue(Ply, Snapshot)
            if next(Snapshot.Bones) == nil then
                print("[GMM] FREEZE STATUE BONES NOT FOUND! MODEL: " .. tostring(Snapshot.Model) .. ", BONE COUNT: " .. tostring(IsValid(Ply) and Ply:GetBoneCount() or -1))
            end

            local Statue = CreateStatue(Snapshot)
            if Statue == nil then return end

            local function RemoveDeathRagdoll()
                if not IsValid(Ply) then return end

                local Rag = Ply:GetRagdollEntity()
                if IsValid(Rag) then Rag:Remove() end
            end

            RemoveDeathRagdoll()

            timer.Simple(0, function()
                if IsValid(Statue) then ApplyBones(Statue, Snapshot) end

                RemoveDeathRagdoll()
            end)

            FreezeEntity(Statue)
        end

        hook.Add("DoPlayerDeath", "gmm_Freeze_PlayerSnapshot", function(Ply)
            Ply.GMMStatueSnapshot = nil

            if not ShouldStatue(Ply) then return end

            Ply.GMMStatueSnapshot = TakeSnapshot(Ply)
        end)

        hook.Add("PostPlayerDeath", "gmm_Freeze_PlayerDeath", function(Ply)
            local Snapshot = Ply.GMMStatueSnapshot
            Ply.GMMStatueSnapshot = nil

            if Snapshot == nil and ShouldStatue(Ply) then Snapshot = TakeSnapshot(Ply) end
            if Snapshot == nil then return end

            RunSafe("STATUE", MakeStatue, Ply, Snapshot)
        end)

        hook.Add("CreateEntityRagdoll", "gmm_Freeze_NpcRagdoll", function(Owner, Ragdoll)
            if not IsValid(Owner) or Owner:IsPlayer() then return end
            if not ShouldStatue(Owner) then return end

            timer.Simple(0, function()
                if IsValid(Ragdoll) then FreezeEntity(Ragdoll) end
            end)
        end)

        hook.Add("PlayerSpawn", "gmm_Freeze_PlayerSpawn", function(Ply)
            Ply.GMMFreezeDeath = nil
            Ply.GMMStatueSnapshot = nil
            ClearCold(Ply)
        end)

        -- ----------------------------------------------------------------------

        local function PlayBlockHint(Ent)
            local Now = CurTime()

            if Ent.GMMIceBlockNext ~= nil and Ent.GMMIceBlockNext > Now then return end

            Ent.GMMIceBlockNext = Now + BlockHintDelay

            Ent:EmitSound(HitSounds[math.random(#HitSounds)], 70, math.random(90, 115))
        end

        local function TearOff(Ent)
            Freeze.Frozen[Ent] = nil

            Ent:SetNWBool(NwFrozen, false)
            Ent.GMMTearUntil = CurTime() + TearGrace

            ReleaseStatic(Ent)
            AddPending(Ent)

            Ent:EmitSound(BreakSounds[math.random(#BreakSounds)], 75, math.random(100, 120))
        end

        GMM_S.Freeze.Detach = function(Ent)
            if not IsValid(Ent) then return end
            if not Ent:GetNWBool(NwFrozen) then return end
            if Ent.GMMFreezeWelds ~= nil then return end

            TearOff(Ent)
        end

        local function BlockFrozen(Ply, Ent)
            if IsValid(Ent) and Ent:GetNWBool(NwFrozen) then return false end
        end

        hook.Add("CanPlayerUnfreeze",    "gmm_Freeze_Block", BlockFrozen)
        hook.Add("GravGunPickupAllowed", "gmm_Freeze_Block", BlockFrozen)
        hook.Add("GravGunPunt",          "gmm_Freeze_Block", BlockFrozen)
        hook.Add("AllowPlayerPickup",    "gmm_Freeze_Block", BlockFrozen)

        hook.Add("PhysgunPickup", "gmm_Freeze_Block", function(Ply, Ent)
            if not IsValid(Ent) or not Ent:GetNWBool(NwFrozen) then return end

            if Ent.GMMFreezeWelds ~= nil then
                PlayBlockHint(Ent)
                return false
            end

            TearOff(Ent)
        end)

        hook.Add("PhysgunDrop", "gmm_Freeze_Drop", function(Ply, Ent)
            if not IsValid(Ent) then return end
            if not Ent:GetNWBool(NwIced) or Ent:GetNWBool(NwFrozen) then return end

            timer.Simple(DropDelay, function()
                if not IsValid(Ent) then return end
                if not Ent:GetNWBool(NwIced) or Ent:GetNWBool(NwFrozen) then return end
                if Ent:IsPlayerHolding() then return end

                Ent.GMMTearUntil = nil
                Ent.GMMRestSince = nil

                ReleaseStatic(Ent)
                AddPending(Ent)
            end)
        end)

        net.Receive("gmm_Freeze_Unfreeze", function(Len, Ply)
            local Ent = net.ReadEntity()

            if not IsValid(Ent) then return end
            if not Ent:GetNWBool(NwIced) then return end
            if hook.Run("CanProperty", Ply, "gmm_Unfreeze", Ent) == false then return end

            UnfreezeEntity(Ent, false)
        end)

        -- ----------------------------------------------------------------------

        for _, Ent in ipairs(ents.GetAll()) do
            if Ent:GetNWBool(NwFrozen) then
                Ent.GMMIceHealth = Ent.GMMIceHealth or IceHealth
                Ent:SetNWBool(NwIced, true)

                Freeze.Frozen[Ent] = true
            elseif Ent:GetNWBool(NwIced) then
                AddPending(Ent)
            end
        end

        if next(Freeze.Frozen) ~= nil then StartMeltTimer() end
    end

    -- ----------------------------------------------------------------------

    if CLIENT then
        GMM_C = GMM_C or {}

        local OldFreeze = GMM_C.Freeze
        if OldFreeze ~= nil and OldFreeze.Cleanup ~= nil then pcall(OldFreeze.Cleanup) end

        GMM_C.Freeze = {}

        local Freeze = GMM_C.Freeze

        local IceMaterialPath = "woowz_map/gm_garrymod_map_by_woowz_map_garry_game/ice_refract"
        local IceScale        = 1.06
        local DrawRadiusSqr   = 3000 * 3000
        local ScanDelay       = 0.2
        local IceFadeIn       = 0.7
        local IceFadeOut      = 1.5
        local IceMinAlpha     = 0.02
        local IceGrace        = 0.5
        local BlurAlpha       = 0.5

        local ScreenRefractScale = 1.5
        local ScreenFollow       = 5
        local ScreenDoneLevel    = 0.005
        local ScreenOverlayMax   = 235
        local ScreenOverlayCurve = 1.6
        local ScreenOverlayR     = 185
        local ScreenOverlayG     = 220
        local ScreenOverlayB     = 245

        local IceMat = Material(IceMaterialPath)

        if IceMat:IsError() then
            print("[GMM] FREEZE ICE MATERIAL NOT FOUND! PATH: " .. IceMaterialPath)
        end

        local BaseAmount  = IceMat:GetFloat("$refractamount") or 0.12
        local BaseBlur    = IceMat:GetFloat("$bluramount") or 1
        local BaseTint    = IceMat:GetVector("$refracttint") or Vector(0.75, 0.9, 1)
        local BaseEnvTint = IceMat:GetVector("$envmaptint") or Vector(0.4, 0.55, 0.7)
        local BaseFresnel = IceMat:GetFloat("$fresnelreflection") or 0.6

        local TintVec = Vector()
        local EnvVec  = Vector()

        local Frozen        = {}
        local ScreenPower   = 0
        local ScreenSounded = false

        -- ----------------------------------------------------------------------

        local function SetIceLook(Alpha, AmountScale)
            TintVec.x = Lerp(Alpha, 1, BaseTint.x)
            TintVec.y = Lerp(Alpha, 1, BaseTint.y)
            TintVec.z = Lerp(Alpha, 1, BaseTint.z)

            EnvVec.x = BaseEnvTint.x * Alpha
            EnvVec.y = BaseEnvTint.y * Alpha
            EnvVec.z = BaseEnvTint.z * Alpha

            IceMat:SetFloat("$refractamount", BaseAmount * Alpha * AmountScale)
            IceMat:SetFloat("$bluramount", Alpha >= BlurAlpha and BaseBlur or 0)
            IceMat:SetFloat("$fresnelreflection", BaseFresnel * Alpha)
            IceMat:SetVector("$refracttint", TintVec)
            IceMat:SetVector("$envmaptint", EnvVec)
        end

        local function ResetIceLook()
            IceMat:SetFloat("$refractamount", BaseAmount)
            IceMat:SetFloat("$bluramount", BaseBlur)
            IceMat:SetFloat("$fresnelreflection", BaseFresnel)
            IceMat:SetVector("$refracttint", BaseTint)
            IceMat:SetVector("$envmaptint", BaseEnvTint)
        end

        -- ----------------------------------------------------------------------

        local function RemoveEntry(Ent)
            local Entry = Frozen[Ent]
            if Entry == nil then return end

            if IsValid(Entry.Model) then Entry.Model:Remove() end

            Frozen[Ent] = nil
        end

        local function CreateEntry(Ent)
            local Entry = {Model = nil, Offset = Vector(), Alpha = 0, Target = 1, Grace = CurTime() + IceGrace}

            local ModelPath = Ent:GetModel()
            if ModelPath == nil or ModelPath == "" or Ent:IsRagdoll() then return Entry end

            local Model = ClientsideModel(ModelPath, RENDERGROUP_TRANSLUCENT)
            if not IsValid(Model) then return Entry end

            Model:SetNoDraw(true)
            Model:SetModelScale(IceScale, 0)
            Model:SetSkin(Ent:GetSkin())

            Entry.Model  = Model
            Entry.Offset = Ent:OBBCenter() * (1 - IceScale)

            return Entry
        end

        local function ScanFrozen()
            local Origin = EyePos()

            for _, Ent in ipairs(ents.GetAll()) do
                if Ent:GetNWBool(NwIced) then
                    local Entry = Frozen[Ent]

                    if Entry == nil then
                        if Ent:GetPos():DistToSqr(Origin) < DrawRadiusSqr then Frozen[Ent] = CreateEntry(Ent) end
                    else
                        Entry.Target = 1
                    end
                end
            end

            local Now = CurTime()

            for Ent, Entry in pairs(Frozen) do
                if not IsValid(Ent) then
                    RemoveEntry(Ent)
                elseif Now > Entry.Grace and not Ent:GetNWBool(NwIced) then
                    Entry.Target = 0
                end
            end
        end

        timer.Create("gmm_Freeze_Scan", ScanDelay, 0, function()
            pcall(ScanFrozen)
        end)

        local PlayerColorKey = "gmm_PlayerColor"
        local DefaultColor   = Vector(0.24, 0.34, 0.41)

        local function ApplyPlayerColor(Ent)
            if Ent.GMMColorApplied then return end
            if not Ent:GetNWBool("gmm_HasColor", false) then return end

            Ent.GMMColorApplied = true
            Ent.GetPlayerColor  = function(Self)
                return Self:GetNWVector(PlayerColorKey, DefaultColor)
            end
        end

        timer.Create("gmm_Freeze_Color", 0.3, 0, function()
            local List = ents.FindByClass("prop_ragdoll")

            for i = 1, #List do
                ApplyPlayerColor(List[i])
            end
        end)

        killicon.Add("gmm_freeze", "woowz_map/gm_garrymod_map_by_woowz_map_garry_game/icons/killicon_freeze")

        GMM_C.Freeze.Kills = GMM_C.Freeze.Kills or {}

        net.Receive("gmm_Freeze_Kill", function()
            local Victim   = net.ReadString()
            local Attacker = net.ReadString()

            GMM_C.Freeze.Kills[Victim] = {Expire = RealTime() + 2, Attacker = Attacker ~= "" and Attacker or nil}
        end)

        local function WrapDeathNotice()
            if GAMEMODE == nil or GAMEMODE.AddDeathNotice == nil then return end

            if GAMEMODE.GMMFreezeNoticeOriginal == nil then
                GAMEMODE.GMMFreezeNoticeOriginal = GAMEMODE.AddDeathNotice
            end

            local Original = GAMEMODE.GMMFreezeNoticeOriginal
            local Kills    = GMM_C.Freeze.Kills

            GAMEMODE.AddDeathNotice = function(Self, Attacker, Team1, Inflictor, Victim, Team2)
                local Entry = Kills[Victim]

                if Entry ~= nil and RealTime() <= Entry.Expire then
                    Kills[Victim] = nil
                    return Original(Self, Entry.Attacker, Entry.Attacker and -1 or 0, "gmm_freeze", Victim, Team2)
                end

                return Original(Self, Attacker, Team1, Inflictor, Victim, Team2)
            end
        end

        hook.Add("InitPostEntity", "gmm_Freeze_Notice", WrapDeathNotice)
        WrapDeathNotice()
        
        net.Receive("gmm_Freeze_Ice", function()
            local Ent     = net.ReadEntity()
            local On      = net.ReadBool()
            local Instant = net.ReadBool()

            if not IsValid(Ent) then return end

            local Entry = Frozen[Ent]

            if On then
                if Entry == nil then
                    Frozen[Ent] = CreateEntry(Ent)
                else
                    Entry.Target = 1
                    Entry.Grace  = CurTime() + IceGrace
                end

                return
            end

            if Entry == nil then return end

            if Instant then
                RemoveEntry(Ent)
            else
                Entry.Target = 0
            end
        end)

        hook.Add("Think", "gmm_Freeze_Fade", function()
            local Dt = FrameTime()

            for Ent, Entry in pairs(Frozen) do
                if not IsValid(Ent) then
                    RemoveEntry(Ent)
                else
                    if Entry.Alpha < Entry.Target then
                        Entry.Alpha = math.min(Entry.Alpha + Dt / IceFadeIn, Entry.Target)
                    elseif Entry.Alpha > Entry.Target then
                        Entry.Alpha = math.max(Entry.Alpha - Dt / IceFadeOut, Entry.Target)
                    end

                    if Entry.Target == 0 and Entry.Alpha <= IceMinAlpha then RemoveEntry(Ent) end
                end
            end
        end)

        hook.Add("PostDrawTranslucentRenderables", "gmm_Freeze_Draw", function(Depth, Sky)
            if Depth or Sky then return end
            if next(Frozen) == nil then return end

            local Origin = EyePos()

            render.MaterialOverride(IceMat)

            for Ent, Entry in pairs(Frozen) do
                if IsValid(Ent) and not Ent:IsDormant() and Entry.Alpha > 0 and Ent:GetPos():DistToSqr(Origin) < DrawRadiusSqr then
                    SetIceLook(Entry.Alpha, 1)

                    local Model = Entry.Model

                    if IsValid(Model) then
                        Model:SetPos(Ent:LocalToWorld(Entry.Offset))
                        Model:SetAngles(Ent:GetAngles())
                        Model:DrawModel()
                    else
                        Ent:DrawModel()
                    end
                end
            end

            render.MaterialOverride(nil)

            ResetIceLook()
        end)

        -- ----------------------------------------------------------------------

        local Modify = {
            ["$pp_colour_addr"]       = 0,
            ["$pp_colour_addg"]       = 0,
            ["$pp_colour_addb"]       = 0,
            ["$pp_colour_brightness"] = 0,
            ["$pp_colour_contrast"]   = 1,
            ["$pp_colour_colour"]     = 1,
            ["$pp_colour_mulr"]       = 0,
            ["$pp_colour_mulg"]       = 0,
            ["$pp_colour_mulb"]       = 0
        }

        hook.Add("RenderScreenspaceEffects", "gmm_Freeze_Screen", function()
            local Ply = LocalPlayer()
            if not IsValid(Ply) then return end

            local Target = 0
            if Ply:Alive() then Target = Ply:GetNWFloat(NwCold, 0) end

            ScreenPower = Lerp(math.min(FrameTime() * ScreenFollow, 1), ScreenPower, Target)

            if ScreenPower < ScreenDoneLevel then
                if Target == 0 then
                    ScreenPower   = 0
                    ScreenSounded = false
                end

                return
            end

            local Power = ScreenPower

            if not ScreenSounded then
                ScreenSounded = true
                surface.PlaySound("physics/glass/glass_sheet_step1.wav")
            end

            render.UpdateRefractTexture()
            SetIceLook(Power, ScreenRefractScale)
            render.SetMaterial(IceMat)
            render.DrawScreenQuad()
            ResetIceLook()

            surface.SetDrawColor(ScreenOverlayR, ScreenOverlayG, ScreenOverlayB, ScreenOverlayMax * Power ^ ScreenOverlayCurve)
            surface.DrawRect(0, 0, ScrW(), ScrH())

            Modify["$pp_colour_addb"]     = 0.06 * Power
            Modify["$pp_colour_colour"]   = 1 - 0.5 * Power
            Modify["$pp_colour_contrast"] = 1 - 0.1 * Power

            DrawColorModify(Modify)
        end)

        -- ----------------------------------------------------------------------

        properties.Add("gmm_Unfreeze", {
            MenuLabel = "Разморозить",
            Order     = 1999,
            MenuIcon  = "icon16/weather_sun.png",

            Filter = function(self, Ent, Ply)
                if not IsValid(Ent) then return false end

                return Ent:GetNWBool(NwIced)
            end,

            Action = function(self, Ent)
                net.Start("gmm_Freeze_Unfreeze")
                net.WriteEntity(Ent)
                net.SendToServer()
            end
        })

        -- ----------------------------------------------------------------------

        Freeze.Cleanup = function()
            timer.Remove("gmm_Freeze_Scan")
            timer.Remove("gmm_Freeze_Color")

            hook.Remove("Think", "gmm_Freeze_Fade")
            hook.Remove("PostDrawTranslucentRenderables", "gmm_Freeze_Draw")
            hook.Remove("RenderScreenspaceEffects", "gmm_Freeze_Screen")

            for Ent in pairs(Frozen) do
                RemoveEntry(Ent)
            end

            ResetIceLook()
        end
    end
end 