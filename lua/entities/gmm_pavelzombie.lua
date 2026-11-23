AddCSLuaFile()

ENT.Type      = "nextbot"
ENT.Base      = "base_nextbot"
ENT.PrintName = "Pave1 ZombШe"
ENT.Author    = "Woowz11"
ENT.Category  = "GMM"
ENT.Spawnable = GMM.Func.DoEntitiesUnlock()

if CLIENT then
    killicon.Add("gmm_pavelzombie", "woowz_map/gm_garrymod_map_by_woowz_map_garry_game/icons/killicon_gore")
    language.Add("gmm_pavelzombie", "Pave1 ZombШe")
end

-- ----------------------------------------------------------------------
-- Данные
-- ----------------------------------------------------------------------

local ModelPavel     = "models/woowz11/player/pavelpistv.mdl"
local ModelPiss      = "models/woowz11/player/pisechnik.mdl"
local ModelPissStill = "models/woowz11/player/pisechnik_stilllife.mdl"
local ModelSponge    = "models/woowz_map/prikol/le_sponge_rag_player.mdl"

local Models = {
    {Weight = 50, Path = ModelPavel},
    {Weight = 1 , Path = ModelPiss},
    {Weight = 1 , Path = ModelPissStill},
    {Weight = 1 , Path = ModelSponge}
}

local ModelsWeightTotal = 0

for i = 1, #Models do
    ModelsWeightTotal = ModelsWeightTotal + Models[i].Weight
end

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
local FeedSeqNames = {"cidle_all", "cidle", "crouch_idle"}

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

local SoundPitchMin = 90
local SoundPitchMax = 110

local VoiceVolume   = 2.5
local ZombieVolume  = 1
local VoiceRange    = 900
local VoiceRangeSqr = VoiceRange * VoiceRange

local NetVoice = "gmm_PavelZombie_Voice"

local NwCorpseFlag  = "gmm_PavelCorpse"
local NwCorpseColor = "gmm_PavelCorpseColor"

local Sounds = {
    Idle = {
        "woowz11/pavelzombie/voice1.wav",
        "woowz11/pavelzombie/voice2.wav",
        "woowz11/pavelzombie/voice3.wav",
        "woowz11/pavelzombie/voice4.wav",
        "woowz11/pavelzombie/voice5.wav",
        "woowz11/pavelzombie/voice6.wav",
        "woowz11/pavelzombie/voice7.wav",
        "woowz11/pavelzombie/voice8.wav",
        "woowz11/pavelzombie/voice9.wav",
        "woowz11/pavelzombie/voice10.wav",
        "woowz11/pavelzombie/voice11.wav",
        "woowz11/pavelzombie/voice12.wav",
        "woowz11/pavelzombie/voice13.wav",
        "woowz11/pavelzombie/voice14.wav",
        "woowz11/pavelzombie/voice15.wav",
        "woowz11/pavelzombie/voice16.wav",
        "woowz11/pavelzombie/voice17.wav",
        "woowz11/pavelzombie/voice18.wav",
        "woowz11/pavelzombie/voice19.wav",
        "woowz11/pavelzombie/voice20.wav",
    },

    Alert = {
        "npc/zombie/zombie_alert1.wav",
        "npc/zombie/zombie_alert2.wav",
        "npc/zombie/zombie_alert3.wav",
        "npc/zombie/zombie_alert1.wav",
        "npc/zombie/zombie_alert2.wav",
        "npc/zombie/zombie_alert3.wav",
        "npc/zombie/zombie_alert1.wav",
        "npc/zombie/zombie_alert2.wav",
        "npc/zombie/zombie_alert3.wav",
        "npc/zombie/zombie_alert1.wav",
        "npc/zombie/zombie_alert2.wav",
        "npc/zombie/zombie_alert3.wav",
        "woowz11/pavelzombie/voice1.wav",
        "woowz11/pavelzombie/voice2.wav",
        "woowz11/pavelzombie/voice3.wav",
        "woowz11/pavelzombie/voice4.wav",
        "woowz11/pavelzombie/voice5.wav",
        "woowz11/pavelzombie/voice6.wav",
        "woowz11/pavelzombie/voice7.wav",
        "woowz11/pavelzombie/voice8.wav",
        "woowz11/pavelzombie/voice9.wav",
        "woowz11/pavelzombie/voice10.wav",
        "woowz11/pavelzombie/voice11.wav",
        "woowz11/pavelzombie/voice12.wav",
        "woowz11/pavelzombie/voice13.wav",
        "woowz11/pavelzombie/voice14.wav",
        "woowz11/pavelzombie/voice15.wav",
        "woowz11/pavelzombie/voice16.wav",
        "woowz11/pavelzombie/voice17.wav",
        "woowz11/pavelzombie/voice18.wav",
        "woowz11/pavelzombie/voice19.wav",
        "woowz11/pavelzombie/voice20.wav",
    },

    Attack = {
        "npc/zombie/zo_attack1.wav",
        "npc/zombie/zo_attack2.wav",
        "npc/zombie/zo_attack1.wav",
        "npc/zombie/zo_attack2.wav",
        "npc/zombie/zo_attack1.wav",
        "npc/zombie/zo_attack2.wav",
        "npc/zombie/zo_attack1.wav",
        "npc/zombie/zo_attack2.wav",
        "npc/zombie/zo_attack1.wav",
        "npc/zombie/zo_attack2.wav",
        "npc/zombie/zo_attack1.wav",
        "npc/zombie/zo_attack2.wav",
        "npc/zombie/zo_attack1.wav",
        "npc/zombie/zo_attack2.wav",
        "woowz11/pavelzombie/voice1.wav",
        "woowz11/pavelzombie/voice2.wav",
        "woowz11/pavelzombie/voice3.wav",
        "woowz11/pavelzombie/voice4.wav",
        "woowz11/pavelzombie/voice5.wav",
        "woowz11/pavelzombie/voice6.wav",
        "woowz11/pavelzombie/voice7.wav",
        "woowz11/pavelzombie/voice8.wav",
        "woowz11/pavelzombie/voice9.wav",
        "woowz11/pavelzombie/voice10.wav",
        "woowz11/pavelzombie/voice11.wav",
        "woowz11/pavelzombie/voice12.wav",
        "woowz11/pavelzombie/voice13.wav",
        "woowz11/pavelzombie/voice14.wav",
        "woowz11/pavelzombie/voice15.wav",
        "woowz11/pavelzombie/voice16.wav",
        "woowz11/pavelzombie/voice17.wav",
        "woowz11/pavelzombie/voice18.wav",
        "woowz11/pavelzombie/voice19.wav",
        "woowz11/pavelzombie/voice20.wav",
    },

    Hurt = {
        "npc/zombie/zombie_pain1.wav",
        "npc/zombie/zombie_pain2.wav",
        "npc/zombie/zombie_pain3.wav",
        "npc/zombie/zombie_pain4.wav",
        "npc/zombie/zombie_pain5.wav",
        "npc/zombie/zombie_pain6.wav"
    },

    Death = {
        "npc/zombie/zombie_die1.wav",
        "npc/zombie/zombie_die2.wav",
        "npc/zombie/zombie_die3.wav",
        "woowz11/other/popy.wav"
    }
}

local HurtSoundDelay = 0.6

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Glow")
    self:NetworkVar("Bool", 1, "Feeding")
end

-- ----------------------------------------------------------------------
-- Сервер
-- ----------------------------------------------------------------------

if SERVER then
    local AiDisabledVar = GetConVar("ai_disabled")
    local DeveloperVar  = GetConVar("developer")

    local function IsAiDisabled()
        return AiDisabledVar ~= nil and AiDisabledVar:GetBool()
    end

    local function IsDeveloper()
        return DeveloperVar ~= nil and DeveloperVar:GetInt() > 0
    end

    util.AddNetworkString(NetVoice)

    -- ----------------------------------------------------------------------
    -- Цели
    -- ----------------------------------------------------------------------

    local ClassName = "gmm_pavelzombie"
    local NwIced    = "gmm_Iced"

    local NpcSearchRange = 3000
    local RetargetDelay  = 0.5
    local GrudgeTime     = 3

    local IgnoreClasses = {
        gmm_pavelzombie       = true,
        npc_bullseye          = true,
        npc_grenade_frag      = true,
        npc_satchel           = true,
        npc_tripmine          = true,
        npc_furniture         = true,
        npc_crow              = true,
        npc_seagull           = true,
        npc_pigeon            = true,
        npc_cscanner          = true,
        npc_clawscanner       = true,
        npc_combinegunship    = true,
        npc_helicopter        = true,
        npc_combinedropship   = true
    }
    
    local FearRange     = 1200
    local FearDelay     = 0.5
    local FearPriority  = 99
    local FearIgnore    = {
        npc_turret_floor = true,
        npc_turret_ceiling = true,
        npc_rollermine = true
    }

    local function MakeFear(Npc, Zombie)
        local Class = Npc:GetClass()

        if IgnoreClasses[Class] or FearIgnore[Class] then return end

        Npc:AddEntityRelationship(Zombie, D_FR, FearPriority)
        Npc:SetEnemy(Zombie)
        Npc:UpdateEnemyMemory(Zombie, Zombie:GetPos())

        if Npc:IsCurrentSchedule(SCHED_RUN_FROM_ENEMY) then return end

        Npc:SetSchedule(SCHED_RUN_FROM_ENEMY)
    end

    timer.Create("gmm_PavelZombie_Fear", FearDelay, 0, function()
        if IsAiDisabled() then return end

        for _, Zombie in ipairs(ents.FindByClass(ClassName)) do
            for _, Ent in ipairs(ents.FindInSphere(Zombie:GetPos(), FearRange)) do
                if Ent:IsNPC() and Ent:Health() > 0 then
                    MakeFear(Ent, Zombie)
                end
            end
        end
    end)

    GMM_S.Func.GetPavelThreat = function(Ent, Range)
        if IsAiDisabled() then return nil end

        local Pos     = Ent:GetPos()
        local BestSqr = Range * Range
        local Best    = nil

        for _, Zombie in ipairs(ents.FindByClass(ClassName)) do
            local DistSqr = Pos:DistToSqr(Zombie:GetPos())

            if DistSqr < BestSqr then
                BestSqr = DistSqr
                Best    = Zombie
            end
        end

        return Best
    end

    GMM_S.Func.FleeStep = function(Bot, Threat, Speed)
        local Pos  = Bot:GetPos()
        local Away = Pos - Threat:GetPos()

        Away.z = 0

        if Away:LengthSqr() < 1 then
            Away = VectorRand()
            Away.z = 0
        end

        Away:Normalize()

        local Goal = Pos + Away * 200
        local Loco = Bot.loco

        Loco:SetDesiredSpeed(Speed)
        Loco:FaceTowards(Goal)
        Loco:Approach(Goal, 1)
    end

    local function IsEnemyValid(Ent)
        if not IsValid(Ent) then return false end

        if Ent:IsPlayer() then
            return Ent:Alive() and not Ent:IsFlagSet(FL_NOTARGET)
        end

        if not Ent:IsNPC() and not Ent:IsNextBot() then return false end
        if IgnoreClasses[Ent:GetClass()] then return false end
        if Ent:Health() <= 0 then return false end
        if Ent:IsFlagSet(FL_NOTARGET) then return false end

        return true
    end

    local function GetEnemyDistSqr(Zombie, Enemy)
        local MyPos = Zombie:GetPos()

        if Enemy:IsPlayer() then return MyPos:DistToSqr(Enemy:GetPos()) end

        return MyPos:DistToSqr(Enemy:NearestPoint(MyPos))
    end

    -- ----------------------------------------------------------------------
    -- Трупы: данные
    -- ----------------------------------------------------------------------

    local CorpseOfferDelay     = 0.15
    local CorpseOfferRetry     = 0.2
    local CorpseOfferTries     = 5
    local CorpseNoticeRange    = 1500
    local CorpseNoticeRangeSqr = CorpseNoticeRange * CorpseNoticeRange
    local CorpseMaxTime        = 90

    local PlayerCorpseLife = 120

    local DistractRange    = 400
    local DistractRangeSqr = DistractRange * DistractRange
    local DistractCheck    = 0.25

    local FetchTimeout  = 12
    local GrabRange     = 60
    local GrabRangeSqr  = GrabRange * GrabRange

    local DragSpeed       = 130
    local DragTimeout     = 10
    local DragDistMin     = 250
    local DragDistMax     = 600
    local DragTries       = 8
    local DragFloorDepth  = 80
    local DragFloorDiff   = 40
    local DragArriveRange = 50
    local DragArriveSqr   = DragArriveRange * DragArriveRange
    local DragDecalDelay  = 0.3

    local GripForward   = 34
    local GripHeight    = 26
    local GripPull      = 12
    local GripBreakDist = 200
    local GripBreakSqr  = GripBreakDist * GripBreakDist
    local MaxGripBreaks = 3

    local FeedRange         = 42
    local FeedRangeSqr      = FeedRange * FeedRange
    local FeedArriveTimeout = 8
    local FeedRestTime      = 2.5

    local BiteDelay     = 0.3
    local BoneBites     = 5
    local MinScale      = 0.01
    local FallbackItems = 3
    local TugSpeed      = 60

    local BloodSpread    = 36
    local BiteBlood      = 2
    local FinishBlood    = 5
    local BiteDecals     = 2
    local BloodyFeetTime = 25
    local BloodStepDelay = 0.35

    local EatSounds = {
        "physics/flesh/flesh_squishy_impact_hard1.wav",
        "physics/flesh/flesh_squishy_impact_hard2.wav",
        "physics/flesh/flesh_squishy_impact_hard3.wav",
        "physics/flesh/flesh_squishy_impact_hard4.wav"
    }

    local FinishSound = "physics/flesh/flesh_bloody_break.wav"

    local GripBones = {
        "ValveBiped.Bip01_R_Hand",
        "ValveBiped.Bip01_L_Hand",
        "ValveBiped.Bip01_R_Foot",
        "ValveBiped.Bip01_L_Foot",
        "ValveBiped.Bip01_Head1"
    }

    local EatOrder = {
        "ValveBiped.Bip01_R_Hand",
        "ValveBiped.Bip01_R_Forearm",
        "ValveBiped.Bip01_L_Hand",
        "ValveBiped.Bip01_L_Forearm",
        "ValveBiped.Bip01_R_Foot",
        "ValveBiped.Bip01_R_Calf",
        "ValveBiped.Bip01_L_Foot",
        "ValveBiped.Bip01_L_Calf",
        "ValveBiped.Bip01_R_UpperArm",
        "ValveBiped.Bip01_L_UpperArm",
        "ValveBiped.Bip01_R_Thigh",
        "ValveBiped.Bip01_L_Thigh"
    }

    local GripTarget  = Vector()
    local GripVel     = Vector()
    local TugVec      = Vector()
    local ScaleVec    = Vector(1, 1, 1)
    local DecalStart  = Vector()
    local DecalEnd    = Vector()
    local DecalFilter = {}

    -- ----------------------------------------------------------------------
    -- Трупы: вспомогательные функции
    -- ----------------------------------------------------------------------

    local function IsCorpseUsable(Corpse)
        if not IsValid(Corpse) then return false end
        if not Corpse:IsRagdoll() then return false end
        if Corpse:GetPhysicsObjectCount() < 1 then return false end
        if Corpse.GMMStatue then return false end
        if Corpse:GetNWBool(NwIced) then return false end

        return true
    end

    local function CollectBones(Ent, Bone, Seen, Out)
        if Seen[Bone] then return end

        Seen[Bone]  = true
        Out[#Out + 1] = Bone

        local Children = Ent:GetChildBones(Bone)
        if Children == nil then return end

        for i = 1, #Children do
            CollectBones(Ent, Children[i], Seen, Out)
        end
    end

    local function BuildEatList(Corpse)
        local List = {}
        local Seen = {}

        for i = 1, #EatOrder do
            local Bone = Corpse:LookupBone(EatOrder[i])

            if Bone ~= nil and Bone >= 0 and not Seen[Bone] then
                local Bones = {}

                CollectBones(Corpse, Bone, Seen, Bones)

                List[#List + 1] = {Root = Bone, Bones = Bones}
            end
        end

        if #List == 0 then
            for i = 1, FallbackItems do
                List[i] = {Root = nil, Bones = {}}
            end
        end

        return List
    end

    local function GetItemPos(Corpse, Item)
        if Item.Root ~= nil then
            local Pos = Corpse:GetBonePosition(Item.Root)
            if Pos ~= nil then return Pos end
        end

        return Corpse:WorldSpaceCenter()
    end

    local function PlaceBlood(Pos, Spread, IgnoreA, IgnoreB)
        DecalFilter[1] = IgnoreA
        DecalFilter[2] = IgnoreB

        DecalStart.x = Pos.x + math.Rand(-Spread, Spread)
        DecalStart.y = Pos.y + math.Rand(-Spread, Spread)
        DecalStart.z = Pos.z + 16

        DecalEnd.x = DecalStart.x
        DecalEnd.y = DecalStart.y
        DecalEnd.z = Pos.z - 48

        util.Decal("Blood", DecalStart, DecalEnd, DecalFilter)
    end

    local function BloodBurst(Pos, Count)
        for i = 1, Count do
            local Data = EffectData()
            Data:SetOrigin(Pos)
            Data:SetNormal(VectorRand())
            Data:SetScale(1)
            Data:SetColor(BLOOD_COLOR_RED)

            util.Effect("BloodImpact", Data)
        end
    end

    local function TugCorpse(Corpse)
        local Count = Corpse:GetPhysicsObjectCount()
        if Count < 1 then return end

        local Phys = Corpse:GetPhysicsObjectNum(math.random(0, Count - 1))
        if not IsValid(Phys) then return end

        TugVec.x = math.Rand(-1, 1) * TugSpeed
        TugVec.y = math.Rand(-1, 1) * TugSpeed
        TugVec.z = math.Rand(0.2, 1) * TugSpeed

        Phys:AddVelocity(TugVec)
    end

    -- ----------------------------------------------------------------------
    -- Состояние и анимация
    -- ----------------------------------------------------------------------

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
        self.NextHurtSound   = 0
        self.NextRetarget    = 0
        self.WalkSeq         = -1
        self.IdleSeq         = -1
        self.FeedSeq         = -1

        self.Corpse         = nil
        self.CorpseState    = nil
        self.CorpseDeadline = 0
        self.StateUntil     = 0
        self.NextDistract   = 0
        self.Distracted     = false
        self.GripBreaks     = 0
        self.GripPhys       = 0
        self.GripBroken     = false
        self.OldGroup       = nil
        self.DragPos        = nil
        self.NextDragDecal  = 0
        self.EatList        = {}
        self.EatIndex       = 1
        self.EatBites       = 0
        self.NextBite       = 0
        self.FeedEnd        = nil
        self.NextBloodDecal = 0
        self.BloodyUntil    = 0
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

    local function PickModel()
        local Roll = math.Rand(0, ModelsWeightTotal)

        for i = 1, #Models do
            Roll = Roll - Models[i].Weight
            if Roll <= 0 then return Models[i].Path end
        end

        return Models[1].Path
    end

    function ENT:Initialize()
        self:InitState()

        local ModelPath = PickModel()
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
        self.FeedSeq = self:FindSeq(FeedSeqNames, {ACT_HL2MP_IDLE_CROUCH, ACT_CROUCHIDLE})

        if self.WalkSeq < 0 then
            print("[GMM] PAVELZOMBIE WALK SEQUENCE NOT FOUND! MODEL: " .. ModelPath)
            for i, Name in ipairs(self:GetSequenceList() or {}) do
                print("  ", i - 1, Name)
            end
        end

        self.Target = self:FindNearestEnemy()

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

    function ENT:FindNearestEnemy()
        local Best     = nil
        local BestDist = math.huge
        local MyPos    = self:GetPos()

        for _, Ply in ipairs(player.GetAll()) do
            if IsEnemyValid(Ply) then
                local Dist = MyPos:DistToSqr(Ply:GetPos())

                if Dist < BestDist then
                    Best     = Ply
                    BestDist = Dist
                end
            end
        end

        local List = ents.FindInSphere(MyPos, NpcSearchRange)

        for i = 1, #List do
            local Ent = List[i]

            if Ent ~= self and not Ent:IsPlayer() and IsEnemyValid(Ent) then
                local Dist = MyPos:DistToSqr(Ent:GetPos())

                if Dist < BestDist then
                    Best     = Ent
                    BestDist = Dist
                end
            end
        end

        return Best
    end

    function ENT:Attack(Enemy)
        if IsAiDisabled() then return end
        if not IsEnemyValid(Enemy) then return end

        local Now = CurTime()
        if Now < self.NextAttack then return end
        self.NextAttack = Now + AttackDelay

        if GetEnemyDistSqr(self, Enemy) > AttackRangeSqr then return end

        local Damage = DamageInfo()
        Damage:SetDamage(AttackDamage)
        Damage:SetAttacker(self)
        Damage:SetInflictor(self)
        Damage:SetDamageType(DMG_SLASH)
        Enemy:TakeDamageInfo(Damage)

        self:PlayVoice("Attack")
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
        if self.FeedSeq >= 0 and self:GetFeeding() then Seq = self.FeedSeq end
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

        if self:GetFeeding() then
            MoveX = 0
            MoveY = 0
        end

        self:SetPoseParameter("move_x", MoveX)
        self:SetPoseParameter("move_y", MoveY)
    end

    function ENT:GetLookPos()
        local Corpse = self.Corpse

        if self.CorpseState ~= nil and IsValid(Corpse) then return Corpse:GetPos() end
        if IsValid(self.Target) then return self.Target:EyePos() end

        return nil
    end

    function ENT:UpdateHead()
        local Now = CurTime()
        local TargetYaw   = 0
        local TargetPitch = 0

        local LookPos = self:GetLookPos()

        if LookPos ~= nil then
            local Ang  = (LookPos - (self:GetPos() + HeadEyeOffset)):Angle()
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

        if self:GetFeeding() then TargetPitch = TargetPitch + math.sin(Now * 13) * 12 end

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

    function ENT:PlayVoice(GroupName)
        local Group = Sounds[GroupName]
        if Group == nil or #Group == 0 then return end

        local Path   = Group[math.random(#Group)]
        local Pitch  = math.random(SoundPitchMin, SoundPitchMax)
        local Volume = string.StartWith(Path, "woowz11/") and VoiceVolume or ZombieVolume
        local MyPos  = self:GetPos()

        for _, Ply in ipairs(player.GetAll()) do
            if IsValid(Ply) then
                local DistSqr = MyPos:DistToSqr(Ply:GetPos())

                if DistSqr <= VoiceRangeSqr then
                    local Fade = 1 - math.sqrt(DistSqr) / VoiceRange

                    net.Start(NetVoice)
                    net.WriteString(Path)
                    net.WriteUInt(Pitch, 8)
                    net.WriteFloat(Volume * Fade)
                    net.Send(Ply)
                end
            end
        end
    end

    function ENT:UpdateSoundGlitch()
        if not Bootleg.SoundGlitch then return end

        local Now = CurTime()
        if Now < self.NextSoundGlitch then return end
        self.NextSoundGlitch = Now + math.Rand(2, 6)

        self:PlayVoice("Idle")
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
        self:UpdateGrip()
        self:UpdateBloodTrail()

        self:NextThink(CurTime())
        return true
    end

    -- ----------------------------------------------------------------------
    -- Трупы: логика
    -- ----------------------------------------------------------------------

    function ENT:WantsCorpse(Corpse)
        if self.CorpseState ~= nil then return false, "ZOMBIE BUSY" end
        if IsAiDisabled() then return false, "AI DISABLED" end
        if not IsCorpseUsable(Corpse) then return false, "CORPSE NOT USABLE" end
        if Corpse.GMMEatenBy ~= nil then return false, "CORPSE TAKEN" end

        local Ply = self:FindNearestPlayer()
        if IsValid(Ply) and self:GetPos():DistToSqr(Ply:GetPos()) < DistractRangeSqr then return false, "PLAYER NEAR" end

        return true
    end

    function ENT:StartCorpse(Corpse)
        local Now = CurTime()

        Corpse.GMMEatenBy = self

        self.Corpse         = Corpse
        self.CorpseDeadline = Now + CorpseMaxTime
        self.NextDistract   = Now + DistractCheck
        self.Distracted     = false
        self.GripBreaks     = 0
        self.GripBroken     = false

        self:StartFetch(Now)
    end

    function ENT:StartFetch(Now)
        self.CorpseState = "Fetch"
        self.StateUntil  = Now + FetchTimeout
    end

    function ENT:ReleaseGrip(Corpse)
        if self.OldGroup == nil then return end

        if IsValid(Corpse) then Corpse:SetCollisionGroup(self.OldGroup) end

        self.OldGroup = nil
    end

    function ENT:EndCorpse()
        self:ReleaseGrip(self.Corpse)
        self:SetFeeding(false)

        self.Corpse      = nil
        self.CorpseState = nil
        self.DragPos     = nil
        self.FeedEnd     = nil
        self.Distracted  = false
    end

    function ENT:IsDistracted(Now)
        if Now >= self.NextDistract then
            self.NextDistract = Now + DistractCheck

            local Ply = self:FindNearestPlayer()

            self.Distracted = IsValid(Ply) and self:GetPos():DistToSqr(Ply:GetPos()) < DistractRangeSqr
        end

        return self.Distracted
    end

    function ENT:PickGripIndex(Corpse)
        local Count = #GripBones
        local Start = math.random(Count)

        for i = 0, Count - 1 do
            local Name = GripBones[(Start + i - 1) % Count + 1]
            local Bone = Corpse:LookupBone(Name)

            if Bone ~= nil and Bone >= 0 then
                local PhysId = Corpse:TranslateBoneToPhysBone(Bone)

                if PhysId ~= nil and PhysId >= 0 and IsValid(Corpse:GetPhysicsObjectNum(PhysId)) then return PhysId end
            end
        end

        if IsValid(Corpse:GetPhysicsObjectNum(0)) then return 0 end

        return nil
    end

    function ENT:FindDragPos(Corpse)
        local Origin = self:GetPos()
        local Eye    = Origin + Vector(0, 0, 24)
        local Filter = {self, Corpse}

        for i = 1, DragTries do
            local Dir = Angle(0, math.Rand(0, 360), 0):Forward()
            local Far = Eye + Dir * math.Rand(DragDistMin, DragDistMax)

            local Wall = util.TraceLine({start = Eye, endpos = Far, filter = Filter, mask = MASK_PLAYERSOLID})

            if not Wall.Hit then
                local Floor = util.TraceLine({start = Far, endpos = Far - Vector(0, 0, DragFloorDepth), filter = Filter, mask = MASK_PLAYERSOLID})

                if Floor.Hit and not Floor.StartSolid and math.abs(Floor.HitPos.z - Origin.z) < DragFloorDiff then return Floor.HitPos end
            end
        end

        return nil
    end

    function ENT:StartDrag(Corpse, Now)
        local PhysId = self:PickGripIndex(Corpse)
        if PhysId == nil then return false end

        local Dest = self:FindDragPos(Corpse)
        if Dest == nil then return false end

        self.GripPhys   = PhysId
        self.GripBroken = false
        self.DragPos    = Dest
        self.StateUntil = Now + DragTimeout
        self.OldGroup   = Corpse:GetCollisionGroup()

        Corpse:SetCollisionGroup(COLLISION_GROUP_WEAPON)

        self.CorpseState = "Drag"

        return true
    end

    function ENT:StartFeed(Now)
        self.CorpseState = "Feed"
        self.StateUntil  = Now + FeedArriveTimeout
        self.EatList     = BuildEatList(self.Corpse)
        self.EatIndex    = 1
        self.EatBites    = 0
        self.FeedEnd     = nil
        self.NextBite    = Now + BiteDelay
    end

    function ENT:UpdateGrip()
        if self.CorpseState ~= "Drag" or self.GripBroken then return end

        local Corpse = self.Corpse
        if not IsValid(Corpse) then return end

        local Phys = Corpse:GetPhysicsObjectNum(self.GripPhys)
        if not IsValid(Phys) then return end

        local Pos = self:GetPos()
        local Fwd = self:GetForward()

        GripTarget.x = Pos.x + Fwd.x * GripForward
        GripTarget.y = Pos.y + Fwd.y * GripForward
        GripTarget.z = Pos.z + GripHeight

        local PhysPos = Phys:GetPos()
        local Dx = GripTarget.x - PhysPos.x
        local Dy = GripTarget.y - PhysPos.y
        local Dz = GripTarget.z - PhysPos.z

        if Dx * Dx + Dy * Dy + Dz * Dz > GripBreakSqr then
            self.GripBroken = true
            return
        end

        GripVel.x = Dx * GripPull
        GripVel.y = Dy * GripPull
        GripVel.z = Dz * GripPull

        Phys:Wake()
        Phys:SetVelocity(GripVel)
    end

    function ENT:UpdateBloodTrail()
        local Now = CurTime()

        if Now >= self.BloodyUntil or Now < self.NextBloodDecal then return end
        if self.loco:GetVelocity():LengthSqr() < 400 then return end

        self.NextBloodDecal = Now + BloodStepDelay

        PlaceBlood(self:GetPos(), 8, self, self)
    end

    function ENT:StepFetch(Corpse, Now)
        if Now > self.StateUntil then
            self:EndCorpse()
            return
        end

        local Loco = self.loco
        local Pos  = Corpse:GetPos()

        if self:GetPos():DistToSqr(Pos) <= GrabRangeSqr then
            if self.GripBreaks >= MaxGripBreaks or not self:StartDrag(Corpse, Now) then self:StartFeed(Now) end
            return
        end

        Loco:FaceTowards(Pos)
        Loco:SetDesiredSpeed(Speed)
        Loco:Approach(Pos, 1)
    end

    function ENT:StepDrag(Corpse, Now)
        if self.GripBroken then
            self.GripBreaks = self.GripBreaks + 1

            self:ReleaseGrip(Corpse)
            self:StartFetch(Now)
            return
        end

        local Loco = self.loco

        Loco:FaceTowards(self.DragPos)
        Loco:SetDesiredSpeed(DragSpeed)
        Loco:Approach(self.DragPos, 1)
        Loco:ClearStuck()

        if Now >= self.NextDragDecal then
            self.NextDragDecal = Now + DragDecalDelay

            PlaceBlood(Corpse:GetPos(), 12, self, Corpse)
        end

        if self:GetPos():DistToSqr(self.DragPos) <= DragArriveSqr or Now > self.StateUntil then
            self:ReleaseGrip(Corpse)
            self:StartFeed(Now)
        end
    end

    function ENT:Bite(Corpse, Now)
        local Item = self.EatList[self.EatIndex]

        if Item == nil then
            if self.FeedEnd == nil then self.FeedEnd = Now + FeedRestTime end
            if Now >= self.FeedEnd then self:EndCorpse() end
            return
        end

        local Pos = GetItemPos(Corpse, Item)

        self.EatBites    = self.EatBites + 1
        self.BloodyUntil = Now + BloodyFeetTime

        local Scale    = math.max(1 - self.EatBites / BoneBites, MinScale)
        local Finished = self.EatBites >= BoneBites

        ScaleVec.x = Scale
        ScaleVec.y = Scale
        ScaleVec.z = Scale

        for i = 1, #Item.Bones do
            Corpse:ManipulateBoneScale(Item.Bones[i], ScaleVec)
        end

        BloodBurst(Pos, Finished and FinishBlood or BiteBlood)

        for i = 1, BiteDecals do
            PlaceBlood(Pos, BloodSpread, self, Corpse)
        end

        if Finished then
            Corpse:EmitSound(FinishSound, 70, math.random(SoundPitchMin, SoundPitchMax))

            self.EatIndex = self.EatIndex + 1
            self.EatBites = 0
        else
            self:EmitSound(EatSounds[math.random(#EatSounds)], 70, math.random(SoundPitchMin, SoundPitchMax))
        end

        if self.EatBites % 2 == 0 then self:RestartGesture(ACT_GMOD_GESTURE_RANGE_ZOMBIE) end

        TugCorpse(Corpse)
    end

    function ENT:StepFeed(Corpse, Now)
        local Loco = self.loco
        local Pos  = Corpse:GetPos()

        Loco:FaceTowards(Pos)

        if not self:GetFeeding() then
            if self:GetPos():DistToSqr(Pos) > FeedRangeSqr and Now <= self.StateUntil then
                Loco:SetDesiredSpeed(Speed)
                Loco:Approach(Pos, 1)
                return
            end

            self:SetFeeding(true)
            self.NextBite = Now + BiteDelay
        end

        Loco:SetDesiredSpeed(0)

        if Now < self.NextBite then return end

        self.NextBite = Now + BiteDelay

        self:Bite(Corpse, Now)
    end

    function ENT:CorpseStep()
        if self.CorpseState == nil then return false end

        local Corpse = self.Corpse
        local Now    = CurTime()

        if not IsCorpseUsable(Corpse) or Now > self.CorpseDeadline or self:IsDistracted(Now) then
            self:EndCorpse()
            return false
        end

        local State = self.CorpseState

        if State == "Fetch" then
            self:StepFetch(Corpse, Now)
        elseif State == "Drag" then
            self:StepDrag(Corpse, Now)
        else
            self:StepFeed(Corpse, Now)
        end

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

        if self:CorpseStep() then return end

        local Now = CurTime()

        if not IsEnemyValid(self.Target) or Now >= self.NextRetarget then
            local Lost = not IsEnemyValid(self.Target)

            self.NextRetarget = Now + RetargetDelay
            self.Target       = self:FindNearestEnemy()

            if Lost and IsValid(self.Target) then self:PlayVoice("Alert") end
        end

        if not IsValid(self.Target) then
            Loco:ClearStuck()
            return
        end

        local TargetPos = self.Target:GetPos()

        Loco:FaceTowards(TargetPos)
        Loco:SetDesiredSpeed(math.max(Speed * self.SpeedMul, 20))
        Loco:Approach(TargetPos, 1)

        if GetEnemyDistSqr(self, self.Target) <= AttackRangeSqr then
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
        local Now      = CurTime()
        local Attacker = Damage:GetAttacker()

        if IsEnemyValid(Attacker) then
            self.Target       = Attacker
            self.NextRetarget = Now + GrudgeTime

            if self.CorpseState ~= nil then self:EndCorpse() end
        end

        if Now >= self.NextHurtSound then
            self.NextHurtSound = Now + HurtSoundDelay
            self:PlayVoice("Hurt")
        end

        self.FreezeUntil = CurTime() + 0.15
        self.AnimCycle   = self.AnimCycle + math.Rand(0.2, 0.5)
    end

    function ENT:OnKilled(Damage)
        hook.Run("OnNPCKilled", self, Damage:GetAttacker(), Damage:GetInflictor())

        self:EndCorpse()
        self:PlayVoice("Death")

        local Color = self:GetColor()
        local Ragdoll = self:BecomeRagdoll(Damage)

        if IsValid(Ragdoll) then Ragdoll:SetColor(Color) end
    end

    function ENT:OnRemove()
        self:EndCorpse()
    end

    -- ----------------------------------------------------------------------
    -- Рэгдолл игрока
    -- ----------------------------------------------------------------------

    local function TakeSnapshot(Ply, ByPavel)
        local Snap = {
            Pavel       = ByPavel,
            Model       = Ply:GetModel(),
            Skin        = Ply:GetSkin(),
            Pos         = Ply:GetPos(),
            Ang         = Angle(0, Ply:EyeAngles().y, 0),
            Vel         = Ply:GetVelocity(),
            Color       = Ply:GetPlayerColor(),
            RenderColor = Ply:GetColor(),
            Groups      = {},
            Bones       = {}
        }

        for i = 0, Ply:GetNumBodyGroups() - 1 do
            Snap.Groups[i] = Ply:GetBodygroup(i)
        end

        for i = 0, Ply:GetBoneCount() - 1 do
            local Pos, Ang = Ply:GetBonePosition(i)

            if Pos ~= nil and Ang ~= nil then Snap.Bones[i] = {Pos = Pos, Ang = Ang} end
        end

        return Snap
    end

    local function CreatePlayerCorpse(Snap)
        local Ragdoll = ents.Create("prop_ragdoll")

        if not IsValid(Ragdoll) then
            print("[GMM] PAVELZOMBIE CORPSE CREATE FAILED! MODEL: " .. tostring(Snap.Model))
            return nil
        end

        Ragdoll:SetModel(Snap.Model)
        Ragdoll:SetPos(Snap.Pos)
        Ragdoll:SetAngles(Snap.Ang)
        Ragdoll:SetSkin(Snap.Skin)
        Ragdoll:SetColor(Snap.RenderColor)

        for Group, Value in pairs(Snap.Groups) do
            Ragdoll:SetBodygroup(Group, Value)
        end

        Ragdoll:Spawn()
        Ragdoll:Activate()

        local Count = Ragdoll:GetPhysicsObjectCount()

        if Count < 1 then
            print("[GMM] PAVELZOMBIE CORPSE HAS NO PHYSICS! MODEL: " .. tostring(Snap.Model))
            Ragdoll:Remove()
            return nil
        end

        for i = 0, Count - 1 do
            local Phys = Ragdoll:GetPhysicsObjectNum(i)

            if IsValid(Phys) then
                local Data = Snap.Bones[Ragdoll:TranslatePhysBoneToBone(i)]

                if Data ~= nil then
                    Phys:SetPos(Data.Pos)
                    Phys:SetAngles(Data.Ang)
                end

                Phys:SetVelocity(Snap.Vel)
                Phys:Wake()
            end
        end

        Ragdoll:SetNWBool(NwCorpseFlag, true)
        Ragdoll:SetNWVector(NwCorpseColor, Snap.Color)

        SafeRemoveEntityDelayed(Ragdoll, PlayerCorpseLife)

        return Ragdoll
    end

    -- ----------------------------------------------------------------------
    -- Трупы: хуки
    -- ----------------------------------------------------------------------

    local function GiveCorpse(Ragdoll)
        local Pos       = Ragdoll:GetPos()
        local Best      = nil
        local BestDist  = math.huge
        local Why       = nil
        local WhyDist   = math.huge
        local List      = ents.FindByClass(ClassName)

        for i = 1, #List do
            local Zombie = List[i]
            local Dist   = Zombie:GetPos():DistToSqr(Pos)

            if Dist < CorpseNoticeRangeSqr then
                local Wants, Reason = Zombie:WantsCorpse(Ragdoll)

                if Wants then
                    if Dist < BestDist then
                        Best     = Zombie
                        BestDist = Dist
                    end
                elseif Dist < WhyDist then
                    Why     = Reason
                    WhyDist = Dist
                end
            end
        end

        if Best ~= nil then
            Best:StartCorpse(Ragdoll)
            return
        end

        if Why ~= nil and IsDeveloper() then
            print("[GMM] PAVELZOMBIE CORPSE REFUSED! REASON: " .. Why .. ", CLASS: " .. Ragdoll:GetClass())
        end
    end

    local function OfferCorpse(Ragdoll, Tries)
        if not IsValid(Ragdoll) then return end

        if Ragdoll:GetPhysicsObjectCount() < 1 then
            if Tries > 0 then
                timer.Simple(CorpseOfferRetry, function()
                    OfferCorpse(Ragdoll, Tries - 1)
                end)
            else
                print("[GMM] PAVELZOMBIE CORPSE NOT USABLE! CLASS: " .. Ragdoll:GetClass() .. ", PHYS COUNT: " .. Ragdoll:GetPhysicsObjectCount())
            end

            return
        end

        GiveCorpse(Ragdoll)
    end

    local function OfferPlayerCorpse(Ply, Snap, Tries)
        local Ragdoll = Snap.Corpse

        if not IsValid(Ragdoll) and IsValid(Ply) then Ragdoll = Ply:GetRagdollEntity() end

        if IsValid(Ragdoll) and Ragdoll:GetPhysicsObjectCount() > 0 then
            GiveCorpse(Ragdoll)
            return
        end

        if Tries > 0 then
            timer.Simple(CorpseOfferRetry, function()
                OfferPlayerCorpse(Ply, Snap, Tries - 1)
            end)
            return
        end

        if not IsValid(Ragdoll) then return end

        local Own = CreatePlayerCorpse(Snap)
        if not IsValid(Own) then return end

        Ragdoll:Remove()

        Snap.Corpse = Own

        GiveCorpse(Own)
    end

    hook.Add("DoPlayerDeath", "gmm_PavelZombie_PlayerSnapshot", function(Ply, Attacker, Damage)
        if #ents.FindByClass(ClassName) == 0 then
            Ply.GMMPavelSnap = nil
            return
        end

        local Inflictor = Damage:GetInflictor()
        local ByPavel   = false

        if IsValid(Attacker) and Attacker:GetClass() == ClassName then ByPavel = true end
        if IsValid(Inflictor) and Inflictor:GetClass() == ClassName then ByPavel = true end

        Ply.GMMPavelSnap = TakeSnapshot(Ply, ByPavel)
    end)

    hook.Add("PostPlayerDeath", "gmm_PavelZombie_PlayerCorpse", function(Ply)
        local Snap = Ply.GMMPavelSnap
        if Snap == nil then return end

        Ply.GMMPavelSnap = nil

        if Snap.Pavel and not IsValid(Ply:GetRagdollEntity()) then
            Snap.Corpse = CreatePlayerCorpse(Snap)
        end

        timer.Simple(CorpseOfferDelay, function()
            OfferPlayerCorpse(Ply, Snap, CorpseOfferTries)
        end)
    end)

    hook.Add("CreateEntityRagdoll", "gmm_PavelZombie_NpcCorpse", function(Owner, Ragdoll)
        if IsValid(Owner) and Owner:GetClass() == ClassName then return end

        timer.Simple(CorpseOfferDelay, function()
            OfferCorpse(Ragdoll, CorpseOfferTries)
        end)
    end)
end

-- ----------------------------------------------------------------------
-- Клиент
-- ----------------------------------------------------------------------

if CLIENT then
    timer.Remove("gmm_PavelZombie_VoiceClean")

    local VoiceChannels = {}

    local Distort = {
        WobbleSpeedA = 7,
        WobbleSpeedB = 17,
        WobbleDepthA = 0.04,
        WobbleDepthB = 0.02,
        GlitchMin    = 0.15,
        GlitchMax    = 0.6,
        DropMin      = 0.04,
        DropMax      = 0.12,
        StutterMin   = 0.04,
        StutterMax   = 0.14,
        DragMin      = 0.5,
        DragMax      = 0.75,
        BurstMin     = 1.4,
        BurstMax     = 1.8,
        RateTimeMin  = 0.08,
        RateTimeMax  = 0.25
    }

    local function UpdateVoice(Voice, Now)
        local Channel = Voice.Channel
        local Time    = Now - Voice.Start

        if Now >= Voice.NextGlitch then
            Voice.NextGlitch = Now + math.Rand(Distort.GlitchMin, Distort.GlitchMax)

            local Kind = math.random(1, 4)
            if Kind == 1 then
                Voice.DropUntil = Now + math.Rand(Distort.DropMin, Distort.DropMax)
            elseif Kind == 2 then
                Channel:SetTime(math.max(Channel:GetTime() - math.Rand(Distort.StutterMin, Distort.StutterMax), 0))
            elseif Kind == 3 then
                Voice.RateMul   = math.Rand(Distort.DragMin, Distort.DragMax)
                Voice.RateUntil = Now + math.Rand(Distort.RateTimeMin, Distort.RateTimeMax)
            else
                Voice.RateMul   = math.Rand(Distort.BurstMin, Distort.BurstMax)
                Voice.RateUntil = Now + math.Rand(Distort.RateTimeMin, Distort.RateTimeMax)
            end
        end

        if Now >= Voice.RateUntil then Voice.RateMul = 1 end

        local Wobble = 1
        Wobble = Wobble + math.sin(Time * Distort.WobbleSpeedA + Voice.Phase) * Distort.WobbleDepthA
        Wobble = Wobble + math.sin(Time * Distort.WobbleSpeedB) * Distort.WobbleDepthB

        Channel:SetPlaybackRate(Voice.Pitch * Wobble * Voice.RateMul)
        Channel:SetVolume(Now < Voice.DropUntil and 0 or Voice.Volume)
    end

    net.Receive(NetVoice, function()
        local Path   = net.ReadString()
        local Pitch  = net.ReadUInt(8)
        local Volume = net.ReadFloat()

        sound.PlayFile("sound/" .. Path, "noplay", function(Channel, ErrCode, ErrStr)
            if not IsValid(Channel) then
                print("[GMM] PAVELZOMBIE VOICE FAILED! PATH: " .. Path .. ", CODE: " .. tostring(ErrCode) .. ", ERROR: " .. tostring(ErrStr))
                return
            end

            local Now = RealTime()

            Channel:SetPlaybackRate(Pitch / 100)
            Channel:SetVolume(Volume)
            Channel:Play()

            VoiceChannels[#VoiceChannels + 1] = {
                Channel    = Channel,
                Pitch      = Pitch / 100,
                Volume     = Volume,
                Start      = Now,
                Phase      = math.Rand(0, 6.28),
                NextGlitch = Now + math.Rand(0.1, 0.4),
                DropUntil  = 0,
                RateMul    = 1,
                RateUntil  = 0
            }
        end)
    end)

    hook.Add("Think", "gmm_PavelZombie_VoiceFX", function()
        local Count = #VoiceChannels
        if Count == 0 then return end

        local Now = RealTime()

        for i = Count, 1, -1 do
            local Channel = VoiceChannels[i].Channel

            if not IsValid(Channel) or Channel:GetState() == GMOD_CHANNEL_STOPPED then
                table.remove(VoiceChannels, i)
            else
                UpdateVoice(VoiceChannels[i], Now)
            end
        end
    end)

    local CorpseColorDelay = 0.5
    local CorpseColorNext  = 0

    local function GetCorpseColor(Self)
        return Self.GMMCorpseColor
    end

    hook.Add("Think", "gmm_PavelZombie_CorpseColor", function()
        local Now = RealTime()
        if Now < CorpseColorNext then return end

        CorpseColorNext = Now + CorpseColorDelay

        local List = ents.FindByClass("prop_ragdoll")

        for i = 1, #List do
            local Ent = List[i]

            if Ent.GMMCorpseColor == nil and Ent:GetNWBool(NwCorpseFlag) then
                Ent.GMMCorpseColor = Ent:GetNWVector(NwCorpseColor)
                Ent.GetPlayerColor = GetCorpseColor
            end
        end
    end)

    local HaloColor = Color(255, 40, 40)
    local HaloList  = {}
    local HaloNext  = 0

    local FeedLean = 28
    local FeedBob  = 10

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

        if self:GetFeeding() then
            Ang.p = Ang.p + FeedLean + math.sin(Now * 13 + Id) * FeedBob
        end

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