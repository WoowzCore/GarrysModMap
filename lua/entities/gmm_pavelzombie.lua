AddCSLuaFile()

ENT.Type      = "nextbot"
ENT.Base      = "base_nextbot"
ENT.PrintName = "Pave1 ZombШe"
ENT.Author    = "Woowz11"
ENT.Category  = "GMM"
ENT.Spawnable = GMM.Func.DoEntitiesUnlock()

-- ----------------------------------------------------------------------
-- Данные
-- ----------------------------------------------------------------------

local ModelPavel     = "models/woowz11/player/pavelpistv.mdl"
local ModelPiss      = "models/woowz11/player/pisechnik.mdl"
local ModelPissStill = "models/woowz11/player/pisechnik_stilllife.mdl"
local ModelSponge    = "models/woowz_map/prikol/le_sponge_rag_player.mdl"

local Models = {ModelPavel, ModelPiss, ModelPissStill, ModelSponge}

local PlayerColors = {
    Color(255, 255, 255),
    Color(255, 0,   0  ),
    Color(0,   255, 0  ),
    Color(0,   0,   255),
    Color(255, 255, 0  ),
    Color(255, 0,   255),
    Color(0,   255, 255),
    Color(255, 128, 0  ),
    Color(128, 0,   255),
    Color(0,   128, 255)
}

local Speed        = 220
local AttackRange  = 70
local AttackDamage = 15
local AttackDelay  = 1.2

local AttackRangeSqr = AttackRange * AttackRange

local WalkSeqNames = {"walk_all", "walk", "run_all", "run", "wal_all", "walk_all_moderate"}
local IdleSeqNames = {"idle_all_01", "idle_all", "idle", "idle01", "reference"}

local Bootleg = {
    AnimFPS     = 10,
    BaseRate    = 1.1,
    GlitchMin   = 0.3,
    GlitchMax   = 1.2,
    SurgeMin    = 0.4,
    SurgeMax    = 1.8,
    SpeedMults  = {0.15, 0.5, 1, 1, 1, 1.4, 2.2},
    HeadTwitch  = true,
    SoundGlitch = true
}

local HeadEyeOffset = Vector(0, 0, 64)

local SoundIdleCount  = 14
local SoundPainCount  = 6
local SoundAlertCount = 3

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Glow")
end

-- ----------------------------------------------------------------------
-- Сервер
-- ----------------------------------------------------------------------

if SERVER then
    local AiDisabledVar = GetConVar("ai_disabled")

    local function IsAiDisabled()
        return AiDisabledVar ~= nil and AiDisabledVar:GetBool()
    end
    
    function ENT:InitState()
        local Now = CurTime()

        self.AnimCycle       = 0
        self.LastAnimTime    = Now
        self.NextFrameTime   = 0
        self.FreezeUntil     = 0
        self.ReverseUntil    = 0
        self.RateMul         = 1
        self.RateMulUntil    = 0
        self.NextGlitch      = Now + 0.5
        self.MoonwalkUntil   = 0
        self.SpeedMul        = 1
        self.NextSurge       = Now + 1
        self.HeadTwitchUntil = 0
        self.NextHeadTwitch  = Now + 1
        self.HeadRandYaw     = 0
        self.HeadRandPitch   = 0
        self.HeadYaw         = 0
        self.HeadPitch       = 0
        self.NextSoundGlitch = Now + math.Rand(2, 5)
        self.NextAttack      = 0
        self.WalkSeq         = -1
        self.IdleSeq         = -1
    end

    function ENT:FindSeq(Names, Acts)
        for _, Name in ipairs(Names) do
            local Seq = self:LookupSequence(Name)
            if Seq ~= nil and Seq > 0 then return Seq end
        end

        for _, Act in ipairs(Acts) do
            local Seq = self:SelectWeightedSequence(Act)
            if Seq ~= nil and Seq > 0 then return Seq end
        end

        return -1
    end

    function ENT:PlaySeq(Seq)
        if Seq == nil or Seq < 0 then return end
        if self:GetSequence() ~= Seq then self:ResetSequence(Seq) end
    end

    function ENT:ApplyLook(ModelPath)
        if ModelPath == ModelPavel then
            pcall(function()
                local Group = self:FindBodygroupByName("Head")
                if Group == nil or Group < 0 then return end

                local Count = self:GetBodygroupCount(Group)
                if Count == nil or Count <= 1 then return end

                self:SetBodygroup(Group, math.random(1, math.min(10, Count - 1)))
            end)
            return
        end

        if ModelPath == ModelPiss or ModelPath == ModelPissStill then
            pcall(function()
                local Skins = self:SkinCount() or 0
                if Skins > 0 then self:SetSkin(math.random(0, Skins - 1)) end
            end)
        end

        local Pick = PlayerColors[math.random(#PlayerColors)]
        self:SetColor(Color(Pick.r, Pick.g, Pick.b, 255))
    end

    function ENT:Initialize()
        self:InitState()

        local ModelPath = Models[math.random(#Models)]
        self:SetModel(ModelPath)
        self:SetHealth(250)
        self:SetMaxHealth(250)
        self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
        self:SetSolid(SOLID_BBOX)
        self:SetMoveType(MOVETYPE_STEP)
        self:SetCollisionBounds(Vector(-16, -16, 0), Vector(16, 16, 72))

        self:ApplyLook(ModelPath)
        self:SetGlow(ModelPath ~= ModelSponge)

        local Loco = self.loco
        Loco:SetDesiredSpeed(Speed)
        Loco:SetAcceleration(900)
        Loco:SetDeceleration(900)
        Loco:SetJumpHeight(200)
        Loco:SetStepHeight(24)
        if Loco.SetAvoidAllowed then Loco:SetAvoidAllowed(false) end

        self.WalkSeq = self:FindSeq(WalkSeqNames, {ACT_HL2MP_RUN, ACT_HL2MP_WALK, ACT_RUN, ACT_WALK})
        self.IdleSeq = self:FindSeq(IdleSeqNames, {ACT_HL2MP_IDLE, ACT_IDLE})

        if self.WalkSeq < 0 then
            print("[GMM] PAVELZOMBIE WALK SEQUENCE NOT FOUND! MODEL: " .. ModelPath)
            for i, Name in ipairs(self:GetSequenceList() or {}) do
                print("  ", i - 1, Name)
            end
        end

        self.Target = self:FindNearestPlayer()

        self:PlaySeq(self.WalkSeq >= 0 and self.WalkSeq or self.IdleSeq)
        self:SetPlaybackRate(0)
    end

    function ENT:FindNearestPlayer()
        local Best     = nil
        local BestDist = math.huge
        local MyPos    = self:GetPos()

        for _, Ply in ipairs(player.GetAll()) do
            if IsValid(Ply) and Ply:Alive() and not Ply:IsFlagSet(FL_NOTARGET) then
                local Dist = MyPos:DistToSqr(Ply:GetPos())
                if Dist < BestDist then
                    Best     = Ply
                    BestDist = Dist
                end
            end
        end

        return Best
    end

    function ENT:Attack(Enemy)
        if IsAiDisabled() then return end
        if not IsValid(Enemy) or not Enemy:Alive() then return end

        local Now = CurTime()
        if Now < self.NextAttack then return end
        self.NextAttack = Now + AttackDelay

        if self:GetPos():DistToSqr(Enemy:GetPos()) > AttackRangeSqr then return end

        local Damage = DamageInfo()
        Damage:SetDamage(AttackDamage)
        Damage:SetAttacker(self)
        Damage:SetInflictor(self)
        Damage:SetDamageType(DMG_SLASH)
        Enemy:TakeDamageInfo(Damage)

        self:EmitSound("npc/zombie/claw_strike" .. math.random(1, 3) .. ".wav", 75, math.random(70, 130))
        self:RestartGesture(ACT_GMOD_GESTURE_RANGE_ZOMBIE)
    end

    function ENT:BodyUpdate() end

    -- ----------------------------------------------------------------------
    -- Бутлег-анимация
    -- ----------------------------------------------------------------------

    function ENT:UpdateBootlegAnim()
        local Now   = CurTime()
        local Delta = math.Clamp(Now - self.LastAnimTime, 0, 0.2)
        self.LastAnimTime = Now

        local Seq = self.IdleSeq
        if self.WalkSeq >= 0 then Seq = self.WalkSeq end
        if Seq >= 0 and self:GetSequence() ~= Seq then self:ResetSequence(Seq) end

        self:SetPlaybackRate(0)

        if Now >= self.NextGlitch then
            self.NextGlitch = Now + math.Rand(Bootleg.GlitchMin, Bootleg.GlitchMax)

            local Kind = math.random(1, 6)
            if Kind == 1 then
                self.FreezeUntil = Now + math.Rand(0.1, 0.45)
            elseif Kind == 2 then
                self.AnimCycle = self.AnimCycle + math.Rand(0.15, 0.45)
            elseif Kind == 3 then
                self.AnimCycle = self.AnimCycle - math.Rand(0.1, 0.35)
            elseif Kind == 4 then
                self.ReverseUntil = Now + math.Rand(0.2, 0.6)
            elseif Kind == 5 then
                self.RateMul      = math.Rand(2.5, 4)
                self.RateMulUntil = Now + math.Rand(0.2, 0.5)
            else
                self.MoonwalkUntil = Now + math.Rand(0.3, 0.8)
            end
        end

        if Now > self.RateMulUntil then self.RateMul = 1 end

        local Rate = Bootleg.BaseRate * (0.75 + 0.45 * math.sin(Now * 2.7 + self:EntIndex())) * self.RateMul
        if Now < self.ReverseUntil then Rate = -Rate end
        if Now < self.FreezeUntil  then Rate = 0 end

        self.AnimCycle = self.AnimCycle + Delta * Rate

        if Now >= self.NextFrameTime then
            self.NextFrameTime = Now + (1 / Bootleg.AnimFPS) * math.Rand(0.6, 1.5)
            self:SetCycle(self.AnimCycle % 1)
        end

        local MoveX = 1
        local MoveY = math.sin(Now * 5) * 0.25
        if Now < self.MoonwalkUntil then
            MoveX = -1
            MoveY = math.sin(Now * 12) * 0.8
        end

        self:SetPoseParameter("move_x", MoveX)
        self:SetPoseParameter("move_y", MoveY)
    end

    function ENT:UpdateHead()
        local Now = CurTime()
        local TargetYaw   = 0
        local TargetPitch = 0

        if IsValid(self.Target) then
            local Ang  = (self.Target:EyePos() - (self:GetPos() + HeadEyeOffset)):Angle()
            local Diff = self:WorldToLocalAngles(Ang)

            TargetYaw   = Diff.y
            TargetPitch = Diff.p
        end

        if Bootleg.HeadTwitch then
            if Now >= self.NextHeadTwitch then
                self.NextHeadTwitch  = Now + math.Rand(0.6, 2.5)
                self.HeadTwitchUntil = Now + math.Rand(0.1, 0.4)
                self.HeadRandYaw     = math.Rand(-90, 90)
                self.HeadRandPitch   = math.Rand(-45, 45)
            end

            if Now < self.HeadTwitchUntil then
                TargetYaw   = self.HeadRandYaw
                TargetPitch = self.HeadRandPitch
            else
                TargetYaw   = TargetYaw   + math.sin(Now * 9) * 8
                TargetPitch = TargetPitch + math.sin(Now * 7) * 6
            end
        end

        self.HeadYaw   = Lerp(0.25, self.HeadYaw,   TargetYaw)
        self.HeadPitch = Lerp(0.25, self.HeadPitch, TargetPitch)

        self:SetPoseParameter("head_yaw",   self.HeadYaw)
        self:SetPoseParameter("head_pitch", self.HeadPitch)
        self:SetPoseParameter("aim_yaw",    self.HeadYaw)
        self:SetPoseParameter("aim_pitch",  self.HeadPitch)
    end

    function ENT:UpdateSpeedSurge()
        local Now = CurTime()
        if Now < self.NextSurge then return end

        local Mults = Bootleg.SpeedMults
        self.NextSurge = Now + math.Rand(Bootleg.SurgeMin, Bootleg.SurgeMax)
        self.SpeedMul  = Mults[math.random(#Mults)]
    end

    function ENT:UpdateSoundGlitch()
        if not Bootleg.SoundGlitch then return end

        local Now = CurTime()
        if Now < self.NextSoundGlitch then return end
        self.NextSoundGlitch = Now + math.Rand(2, 6)

        local Pick = math.random(3)
        local Path = "npc/zombie/zombie_voice_idle" .. math.random(1, SoundIdleCount) .. ".wav"
        if Pick == 2 then Path = "npc/zombie/zombie_pain" .. math.random(1, SoundPainCount) .. ".wav" end
        if Pick == 3 then Path = "npc/zombie/zombie_alert" .. math.random(1, SoundAlertCount) .. ".wav" end

        self:EmitSound(Path, 75, math.random(40, 160))
    end

    function ENT:Think()
        if self.loco == nil then return end
        if self.AnimCycle == nil then self:InitState() end

        if IsAiDisabled() then
            self.LastAnimTime = CurTime()
            self:NextThink(CurTime())
            return true
        end

        self:UpdateBootlegAnim()
        self:UpdateHead()
        self:UpdateSpeedSurge()
        self:UpdateSoundGlitch()

        self:NextThink(CurTime())
        return true
    end

    -- ----------------------------------------------------------------------
    -- Поведение
    -- ----------------------------------------------------------------------

    function ENT:BehaviourStep()
        local Loco = self.loco

        if IsAiDisabled() then
            Loco:SetDesiredSpeed(0)
            Loco:ClearStuck()
            return
        end

        if not IsValid(self.Target) or not self.Target:Alive() then
            self.Target = self:FindNearestPlayer()
        end

        if not IsValid(self.Target) then
            Loco:ClearStuck()
            return
        end

        local TargetPos = self.Target:GetPos()

        Loco:FaceTowards(TargetPos)
        Loco:SetDesiredSpeed(math.max(Speed * self.SpeedMul, 20))
        Loco:Approach(TargetPos, 1)

        if self:GetPos():DistToSqr(TargetPos) <= AttackRangeSqr then
            self:Attack(self.Target)
        end

        if Loco:IsStuck() then
            Loco:Jump()
            Loco:ClearStuck()
        end
    end

    function ENT:RunBehaviour()
        while true do
            local Ok, Err = pcall(self.BehaviourStep, self)
            if not Ok then
                ErrorNoHalt("[GMM] PAVELZOMBIE BEHAVIOUR FAILED! " .. tostring(Err) .. "\n")
            end

            coroutine.wait(0.05)
        end
    end

    function ENT:OnInjured(Damage)
        local Attacker = Damage:GetAttacker()
        if IsValid(Attacker) and Attacker:IsPlayer() and Attacker:Alive() then
            self.Target = Attacker
        end

        self.FreezeUntil = CurTime() + 0.15
        self.AnimCycle   = self.AnimCycle + math.Rand(0.2, 0.5)
    end

    function ENT:OnKilled(Damage)
        hook.Run("OnNPCKilled", self, Damage:GetAttacker(), Damage:GetInflictor())

        local Color = self:GetColor()
        local Ragdoll = self:BecomeRagdoll(Damage)

        if IsValid(Ragdoll) then Ragdoll:SetColor(Color) end
    end
end

-- ----------------------------------------------------------------------
-- Клиент
-- ----------------------------------------------------------------------

if CLIENT then
    local HaloColor = Color(255, 40, 40)
    local HaloList  = {}
    local HaloNext  = 0

    function ENT:Draw()
        local Now = CurTime()
        local Id  = self:EntIndex()

        if self.GlitchMatrix == nil then
            self.GlitchMatrix  = Matrix()
            self.GlitchOffset  = Vector()
            self.GlitchAng     = Angle()
            self.GlitchScale   = Vector(1, 1, 1)
            self.NextVisGlitch = 0
            self.VisGlitchUntil = 0
        end

        if Now >= self.NextVisGlitch then
            self.NextVisGlitch  = Now + math.Rand(0.4, 2.2)
            self.VisGlitchUntil = Now + math.Rand(0.05, 0.2)

            self.GlitchOffset = VectorRand() * math.Rand(2, 8)
            self.GlitchAng    = Angle(math.Rand(-20, 20), math.Rand(-40, 40), math.Rand(-25, 25))
            self.GlitchScale  = Vector(math.Rand(0.8, 1.3), math.Rand(0.8, 1.3), math.Rand(0.85, 1.2))
        end

        local Pos = self:GetPos()
        local Ang = self:GetAngles()

        Ang.p = Ang.p + math.sin(Now * 4 + Id) * 6
        Ang.r = Ang.r + math.sin(Now * 3.3 + Id * 2) * 9
        Pos.z = Pos.z + math.abs(math.sin(Now * 6 + Id)) * 3

        if Now < self.VisGlitchUntil then
            Pos:Add(self.GlitchOffset)
            Ang:Add(self.GlitchAng)

            self.GlitchMatrix:SetScale(self.GlitchScale)
            self:EnableMatrix("RenderMultiply", self.GlitchMatrix)
        else
            self:DisableMatrix("RenderMultiply")
        end

        self:SetRenderOrigin(Pos)
        self:SetRenderAngles(Ang)
        self:DrawModel()
        self:SetRenderOrigin()
        self:SetRenderAngles()
    end

    hook.Add("PreDrawHalos", "gmm_PavelZombie_Halos", function()
        local Now = RealTime()

        if Now >= HaloNext then
            HaloNext = Now + 0.5
            table.Empty(HaloList)

            for _, Ent in ipairs(ents.FindByClass("gmm_pavelzombie")) do
                if Ent:GetGlow() then HaloList[#HaloList + 1] = Ent end
            end
        end

        for i = #HaloList, 1, -1 do
            if not IsValid(HaloList[i]) then table.remove(HaloList, i) end
        end

        if #HaloList > 0 then
            halo.Add(HaloList, HaloColor, 2, 2, 1, true, false)
        end
    end)
end