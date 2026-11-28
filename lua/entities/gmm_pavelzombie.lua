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
local AttackRange  = 75
local AttackDamage = 15
local AttackRageDamage = 35
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
    SpeedMults  = {1, 1, 1, 1, 1.4, 1.7, 2.2},
    HeadTwitch  = true,
    SoundGlitch = true
}

local HeadEyeOffset = Vector(0, 0, 64)

local RageDuration         = 10
local RageDistanceIncrease = 350
local RageProgressTimeout  = 8
local RageCheckDelay       = 1
local RageSpeed            = 650
local RageAcceleration     = 1800
local RageDeceleration     = 400
local RageBoneUpdateDelay  = 0.08

local SightRange               = 2400
local SightRangeSqr            = SightRange * SightRange
local LoseSightDelay           = 1.0
local SearchDuration           = 12
local SearchArriveRange        = 90
local SearchArriveRangeSqr     = SearchArriveRange * SearchArriveRange
local SearchPauseMin           = 0.7
local SearchPauseMax           = 2.0
local SoundHearMin             = 68
local SoundInvestigateTime     = 7
local SoundInvestigateRange    = 1800
local SoundInvestigateRangeSqr = SoundInvestigateRange * SoundInvestigateRange
local IdleThinkDelay           = 0.25
local IdleWanderChance         = 0.12
local IdleWanderDistance       = 180
local AmbushMinRange           = 300
local AmbushMaxRange           = 850
local AmbushChance             = 0.18
local AmbushPauseMin           = 0.8
local AmbushPauseMax           = 1.8
local AmbushRushDuration       = 2.5
local LowHealthRatio           = 0.35
local LowHealthPriority        = 0.72
local PropPushRange            = 58
local PropPushDelay            = 0.7
local PropPushForce            = 260
local SatietyPerBite           = 1.8
local SatietyDecay             = 0.025
local SatietyFull              = 100
local SatietySearchThreshold   = 92
local CorpseThreatRange        = 360
local CorpseThreatRangeSqr     = CorpseThreatRange * CorpseThreatRange

local BasePlayerHeight = 72
local MinHeightUnits   = 62  -- чуть ниже стандартного роста игрока (72)
local MaxHeightUnits   = 118 -- около 3 метров

local MinModelScale = MinHeightUnits / BasePlayerHeight
local MaxModelScale = MaxHeightUnits / BasePlayerHeight

local SoundPitchMin = 90
local SoundPitchMax = 110

local VoiceVolume   = 2.5
local ZombieVolume  = 1
local VoiceRange    = 900
local VoiceRangeSqr = VoiceRange * VoiceRange

local NetVoice = "gmm_PavelZombie_Voice"

local NwCorpseFlag = "gmm_PlayerCorpse"

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

    local IgnorePlayersVar = GetConVar("ai_ignoreplayers")

    local function IgnorePlayers()
        return IgnorePlayersVar ~= nil and IgnorePlayersVar:GetBool()
    end

    local NpcSearchRange = 3000
    local RetargetDelay  = 0.5
    local GrudgeTime     = 3

    local IgnoreClasses = {
        gmm_pavelzombie     = true,
        npc_bullseye        = true,
        npc_grenade_frag    = true,
        npc_satchel         = true,
        npc_tripmine        = true,
        npc_furniture       = true,
        npc_crow            = true,
        npc_seagull         = true,
        npc_pigeon          = true,
        npc_cscanner        = true,
        npc_clawscanner     = true,
        npc_combinegunship  = true,
        npc_helicopter      = true,
        npc_combinedropship = true
    }

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
            return not IgnorePlayers() and Ent:Alive() and not Ent:IsFlagSet(FL_NOTARGET)
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

    local CorpseOfferDelay     = 0.05
    local CorpseOfferRetry     = 0.15
    local CorpseOfferTries     = 5
    local CorpseNoticeRange    = 1800
    local CorpseNoticeRangeSqr = CorpseNoticeRange * CorpseNoticeRange
    local CorpseMaxTime        = 90

    local PlayerCorpseLife = 120

    local FetchTimeout = 14
    local GrabRange    = 85
    local GrabRangeSqr = GrabRange * GrabRange

    local DragSpeed       = 130
    local DragTimeout     = 10
    local DragDistMin     = 500
    local DragDistMax     = 3000
    local DragTries       = 8
    local DragFloorDepth  = 80
    local DragFloorDiff   = 40
    local DragArriveRange = 60
    local DragArriveSqr   = DragArriveRange * DragArriveRange
    local DragDecalDelay  = 0.3

    local GripForward   = 34
    local GripHeight    = 26
    local GripPull      = 14
    local GripBreakDist = 240
    local GripBreakSqr  = GripBreakDist * GripBreakDist
    local MaxGripBreaks = 3

    local FeedRange         = 75
    local FeedRangeSqr      = FeedRange * FeedRange
    local FeedArriveTimeout = 6
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
        "ValveBiped.Bip01_L_Thigh",

        "ValveBiped.Bip01_Head1",
        "ValveBiped.Bip01_Spine2",
        "ValveBiped.Bip01_Pelvis"
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

    local EdibleSurfaceProps = {
        flesh       = true,
        bloodyflesh = true,
        alienflesh  = true,
        zombieflesh = true,
        antlion     = true,
        watermelon  = true,
        armorflesh  = true
    }

    local InedibleModelWords = {
        "skeleton",
        "strider",
        "dog.mdl",
        "hunter",
        "turret",
        "manhack",
        "scanner",
        "rollermine",
        "helicopter",
        "gunship",
        "dropship"
    }

    local EdibleMaterialWords = {
        "flesh",
        "meat",
        "alien",
        "watermelon",
        "melon",
        "antlion",
        "headcrab",
        "gib",
        "gore",
        "skin",
        "body"
    }

    local function GetCorpsePos(Corpse)
        if not IsValid(Corpse) then return nil end

        local Phys = Corpse:GetPhysicsObjectNum(0)
        if IsValid(Phys) then return Phys:GetPos() end

        return Corpse:WorldSpaceCenter()
    end

    local function GetCorpseDistSqr(BotPos, Corpse)
        local Pos = GetCorpsePos(Corpse)
        if Pos == nil then return math.huge end

        local d1 = BotPos:DistToSqr(Pos)
        local d2 = BotPos:DistToSqr(Corpse:NearestPoint(BotPos))

        return math.min(d1, d2)
    end

    local ForbiddenCorpseModels = {
        ["models/woowz11/player/pavelpistv.mdl"] = true,
        ["models/woowz_map/prikol/le_sponge_rag_player.mdl"] = true,
    }

    local function IsEdibleCorpse(Corpse)
        if not IsValid(Corpse) then return false end
        if Corpse.GMMIsSkeleton then return false end

        local Model = string.lower(Corpse:GetModel() or "")
        if ForbiddenCorpseModels[Model] then
            return false
        end

        for i = 1, #InedibleModelWords do
            if string.find(Model, InedibleModelWords[i], 1, true) then
                return false
            end
        end

        if Corpse:GetNWBool(NwCorpseFlag) then return true end

        local PhysCount = Corpse:GetPhysicsObjectCount()
        for i = 0, PhysCount - 1 do
            local Phys = Corpse:GetPhysicsObjectNum(i)
            if IsValid(Phys) then
                local Mat = string.lower(Phys:GetMaterial() or "")
                if EdibleSurfaceProps[Mat] or string.find(Mat, "flesh", 1, true) then
                    return true
                end
            end
        end

        local Pelvis = Corpse:LookupBone("ValveBiped.Bip01_Pelvis")
        local Head   = Corpse:LookupBone("ValveBiped.Bip01_Head1")
        if (Pelvis ~= nil and Pelvis >= 0) or (Head ~= nil and Head >= 0) then
            return true
        end

        local Materials = Corpse:GetMaterials()
        if Materials ~= nil then
            for i = 1, #Materials do
                local Material = string.lower(Materials[i] or "")
                if string.find(Material, "skeleton", 1, true) then
                    return false
                end
                for j = 1, #EdibleMaterialWords do
                    if string.find(Material, EdibleMaterialWords[j], 1, true) then
                        return true
                    end
                end
            end
        end

        return false
    end

    local function IsCorpseUsable(Corpse)
        if not IsValid(Corpse) then return false end
        if not Corpse:IsRagdoll() then return false end
        if Corpse:GetPhysicsObjectCount() < 1 then return false end
        if Corpse.GMMStatue then return false end
        if Corpse:GetNWBool(NwIced) then return false end
        if not IsEdibleCorpse(Corpse) then return false end

        return true
    end

    local function CollectBones(Ent, Bone, Seen, Out)
        if Seen[Bone] then return end

        Seen[Bone]    = true
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

        for i = #List, 2, -1 do
            local RandomIndex = math.random(i)
            List[i], List[RandomIndex] = List[RandomIndex], List[i]
        end

        return List
    end

    local function GetItemPos(Corpse, Item)
        if Item.Root ~= nil then
            local Pos = Corpse:GetBonePosition(Item.Root)
            if Pos ~= nil then return Pos end
        end

        return GetCorpsePos(Corpse) or Corpse:WorldSpaceCenter()
    end

    local function CreateSkeletonFromCorpse(Corpse)
        if not IsValid(Corpse) then return end

        local SkeletonModel = "models/player/skeleton.mdl"

        if not util.IsValidModel(SkeletonModel) then
            Corpse:Remove()
            return
        end

        local Pos = GetCorpsePos(Corpse) or Corpse:GetPos()
        local Ang = Corpse:GetAngles()

        local Skeleton = ents.Create("prop_ragdoll")

        if not IsValid(Skeleton) then
            Corpse:Remove()
            return
        end

        Skeleton:SetModel(SkeletonModel)
        Skeleton:SetPos(Pos)
        Skeleton:SetAngles(Ang)
        Skeleton:Spawn()
        Skeleton:Activate()
        Skeleton:SetSkin(2)
        Skeleton:SetCollisionGroup(COLLISION_GROUP_NONE)

        Skeleton.GMMIsSkeleton = true

        local PhysCount = Skeleton:GetPhysicsObjectCount()

        for i = 0, PhysCount - 1 do
            local SkeletonBone = Skeleton:TranslatePhysBoneToBone(i)

            if SkeletonBone ~= nil and SkeletonBone >= 0 then
                local BoneName   = Skeleton:GetBoneName(SkeletonBone)
                local CorpseBone = Corpse:LookupBone(BoneName)

                if CorpseBone ~= nil and CorpseBone >= 0 then
                    local CorpsePhysId = Corpse:TranslateBoneToPhysBone(CorpseBone)

                    if CorpsePhysId ~= nil and CorpsePhysId >= 0 then
                        local SourcePhys = Corpse:GetPhysicsObjectNum(CorpsePhysId)
                        local TargetPhys = Skeleton:GetPhysicsObjectNum(i)

                        if IsValid(SourcePhys) and IsValid(TargetPhys) then
                            TargetPhys:SetPos(SourcePhys:GetPos())
                            TargetPhys:SetAngles(SourcePhys:GetAngles())
                            TargetPhys:Wake()
                        end
                    end
                end
            end
        end

        Corpse:Remove()

        return Skeleton
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

        self.ModelScale = 1

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

        self.RageUntil          = 0
        self.WasRaging          = false
        self.RageSoundPlayed    = false
        self.NextRageSound      = 0
        self.ExhaustedUntil     = 0
        self.IrritatedUntil     = 0
        self.NextRageCheck      = 0
        self.LastTargetDistance = nil
        self.TargetProgressTime = 0
        self.RageBones          = {}
        self.NextRageBoneUpdate = 0
        self.NextRageArmSwing   = 0

        self.NextCorpseSearch = 0

        self.LastSeenPos          = nil
        self.LastSeenTarget       = nil
        self.LastSeenTime         = 0
        self.SearchUntil          = 0
        self.SearchPos            = nil
        self.SearchNextMove       = 0
        self.SearchPauseUntil     = 0
        self.SearchLookUntil      = 0
        self.SearchLookPos        = nil
        self.HeardPos             = nil
        self.HeardUntil           = 0
        self.HeardSource          = nil
        self.NextIdleThink        = 0
        self.IdleUntil            = 0
        self.IdleLookPos          = nil
        self.IdleWanderPos        = nil
        self.AmbushUntil          = 0
        self.AmbushRushUntil      = 0
        self.AmbushTarget         = nil
        self.GrudgeTarget         = nil
        self.GrudgeUntil          = 0
        self.NextPropPush         = 0
        self.Satiety              = 0
        self.FeedBiteDelay        = BiteDelay
        self.LastVisibleTarget    = nil
        self.NextSoundInvestigate = 0

        self.FeedArms         = {}
        self.FeedArmsActive   = false
        self.NextFeedArmUpdate = 0
        self.FeedTearDir      = 1
    end

    function ENT:ApplyHeightScale()
        local Scale = math.Rand(MinModelScale, MaxModelScale)
        self.ModelScale = Scale

        self:SetModelScale(Scale, 0)
        self:SetCollisionBounds(Vector(-16 * Scale, -16 * Scale, 0), Vector(16 * Scale, 16 * Scale, 72 * Scale))

        if self.loco ~= nil then
            self.loco:SetStepHeight(40 * Scale)
            self.loco:SetJumpHeight(140 * Scale)
            self.loco:SetDesiredSpeed(Speed * math.Clamp(0.85 + Scale * 0.2, 0.8, 1.35))
        end
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

                self:SetBodygroup(Group, math.random(1, Count - 1))
                
                self:SetSkin(1)
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
        self:InitRageBones()
        self:SetHealth(250)
        self:SetMaxHealth(250)
        self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
        self:SetSolid(SOLID_BBOX)
        self:SetMoveType(MOVETYPE_STEP)
        self:SetCollisionBounds(Vector(-16, -16, 0), Vector(16, 16, 72))
        self:SetCustomCollisionCheck(true)
        
        self:ApplyLook(ModelPath)
        self:SetGlow(ModelPath ~= ModelSponge)

        local Loco = self.loco
        Loco:SetDesiredSpeed(Speed)
        Loco:SetAcceleration(900)
        Loco:SetDeceleration(900)
        Loco:SetJumpHeight(140)
        Loco:SetStepHeight(40)
        if Loco.SetAvoidAllowed then Loco:SetAvoidAllowed(false) end

        self:ApplyHeightScale()
        
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

    function ENT:IsRaging()
        return CurTime() < self.RageUntil
    end

    function ENT:EnterRage(Reason)
        local Now = CurTime()

        self.RageUntil          = math.max(self.RageUntil, Now + RageDuration)
        self.NextRageBoneUpdate = 0
        self.NextRageArmSwing   = 0

        if not self.RageSoundPlayed or Now >= (self.NextRageSound or 0) then
            self.RageSoundPlayed = true
            self.NextRageSound   = Now + 3

            self:PlayVoice("Attack")
        end
    end

    function ENT:CalmDown()
        self.RageUntil          = 0
        self.RageSoundPlayed    = false
        self.LastTargetDistance = nil
        self.TargetProgressTime = 0

        for i = 1, #self.RageBones do
            local Bone = self.RageBones[i]

            if Bone >= 0 then
                self:ManipulateBoneAngles(Bone, Angle(0, 0, 0))
            end
        end
    end

    function ENT:UpdateRageState(Target, Now)
        if not IsValid(Target) then
            self.LastTargetDistance = nil
            self.TargetProgressTime = 0
            return
        end

        if Now < self.NextRageCheck then return end

        self.NextRageCheck = Now + RageCheckDelay

        local Distance = self:GetPos():Distance(Target:GetPos())

        if self.LastTargetDistance == nil then
            self.LastTargetDistance = Distance
            self.TargetProgressTime = Now
            return
        end

        local DistanceChange = Distance - self.LastTargetDistance

        if DistanceChange >= RageDistanceIncrease then
            self:EnterRage("TARGET_ESCAPING")
            self.TargetProgressTime = Now
        elseif Distance < self.LastTargetDistance - 10 then
            self.TargetProgressTime = Now
        elseif Distance > 200 and Now - self.TargetProgressTime >= RageProgressTimeout then
            self:EnterRage("NO_PROGRESS")
            self.TargetProgressTime = Now
        end

        self.LastTargetDistance = Distance
    end

    function ENT:FindNearestPlayer()
        local Best     = nil
        local BestDist = math.huge
        local MyPos    = self:GetPos()

        for _, Ply in ipairs(player.GetAll()) do
            if not IgnorePlayers() and IsValid(Ply) and Ply:Alive() and not Ply:IsFlagSet(FL_NOTARGET) then
                local Dist = MyPos:DistToSqr(Ply:GetPos())
                if Dist < BestDist then
                    Best     = Ply
                    BestDist = Dist
                end
            end
        end

        return Best
    end

    local function CanSeeTarget(Bot, Target)
        if not IsValid(Target) then return false end

        local Start  = Bot:EyePos()
        local Finish = Target:IsPlayer() and Target:EyePos() or Target:WorldSpaceCenter()
        local Trace  = util.TraceLine({
            start  = Start,
            endpos = Finish,
            filter = {Bot, Target},
            mask   = MASK_VISIBLE
        })

        return not Trace.Hit
    end

    function ENT:RememberTarget(Target, Now)
        if not IsValid(Target) then return end

        self.LastSeenPos       = Target:GetPos()
        self.LastSeenTarget    = Target
        self.LastSeenTime      = Now
        self.LastVisibleTarget = Target
    end

    function ENT:GetEnemyPriority(Enemy)
        local Dist  = GetEnemyDistSqr(self, Enemy)
        local Score = Dist

        if Enemy == self.GrudgeTarget and CurTime() < (self.GrudgeUntil or 0) then
            Score = Score * 0.55
        end

        if Enemy:IsPlayer() then
            local MaxHealth   = math.max(Enemy:GetMaxHealth(), 1)
            local HealthRatio = math.Clamp(Enemy:Health() / MaxHealth, 0, 1)
            if HealthRatio <= LowHealthRatio then Score = Score * LowHealthPriority end
        end

        return Score
    end

    function ENT:FindNearestEnemy()
        local Best      = nil
        local BestScore = math.huge
        local MyPos     = self:GetPos()

        for _, Ply in ipairs(player.GetAll()) do
            if IsEnemyValid(Ply) then
                local Score = self:GetEnemyPriority(Ply)
                if Score < BestScore then
                    Best      = Ply
                    BestScore = Score
                end
            end
        end

        local List = ents.FindInSphere(MyPos, math.max(NpcSearchRange, SightRange))
        for i = 1, #List do
            local Ent = List[i]
            if Ent ~= self and not Ent:IsPlayer() and IsEnemyValid(Ent) then
                local Score = self:GetEnemyPriority(Ent)
                if Score < BestScore then
                    Best      = Ent
                    BestScore = Score
                end
            end
        end

        return Best
    end

    function ENT:StartSearch(Position, Now)
        if Position == nil then return end
        local Destination = Vector(Position.x, Position.y, Position.z)
        local Direction   = Destination - self:GetPos()
        Direction.z = 0

        if Direction:LengthSqr() > 1 then
            Direction:Normalize()
            local Side       = Vector(-Direction.y, Direction.x, 0)
            local Candidates = {Destination + Side * 100, Destination - Side * 100}
            for i = 1, #Candidates do
                local Candidate = Candidates[i]
                local Trace = util.TraceHull({
                    start  = self:GetPos() + Vector(0, 0, 36),
                    endpos = Candidate + Vector(0, 0, 36),
                    mins   = Vector(-14, -14, -8),
                    maxs   = Vector(14, 14, 8),
                    filter = self,
                    mask   = MASK_NPCSOLID
                })
                if not Trace.Hit and not Trace.StartSolid then
                    Destination = Candidate
                    break
                end
            end
        end

        self.SearchPos        = Destination
        self.SearchUntil      = Now + SearchDuration
        self.SearchNextMove   = Now
        self.SearchPauseUntil = 0
        self.SearchLookUntil  = 0
        self.Target           = nil
    end

    function ENT:StepSearch(Now)
        if self.SearchPos == nil or Now >= self.SearchUntil then
            self.SearchPos = nil
            return false
        end

        local Loco = self.loco
        local Pos  = self:GetPos()

        if self.SearchLookPos ~= nil and Now < self.SearchLookUntil then
            Loco:SetDesiredSpeed(0)
            Loco:FaceTowards(self.SearchLookPos)
            return true
        end

        if Pos:DistToSqr(self.SearchPos) <= SearchArriveRangeSqr then
            if self.SearchPauseUntil <= 0 then
                self.SearchPauseUntil = Now + math.Rand(SearchPauseMin, SearchPauseMax)
                self.SearchLookPos    = self.SearchPos + VectorRand() * 180 + Vector(0, 0, 35)
                self.SearchLookUntil  = self.SearchPauseUntil
                self.SearchNextMove   = self.SearchPauseUntil
                self:PlayVoice("Idle")
            end

            if Now < self.SearchPauseUntil then
                Loco:SetDesiredSpeed(0)
                Loco:FaceTowards(self.SearchLookPos or self.SearchPos)
                return true
            end

            local Offset = VectorRand() * math.Rand(100, 240)
            Offset.z = 0
            self.SearchPos        = self.SearchPos + Offset
            self.SearchPauseUntil = 0
            self.SearchLookPos    = nil
        end

        Loco:SetDesiredSpeed(math.max(Speed * 0.72, 80))
        Loco:FaceTowards(self.SearchPos)
        self:MoveWithWallSlide(self.SearchPos)
        return true
    end

    function ENT:HearPosition(Position, Source, Now)
        if self.CorpseState ~= nil then return end
        if IsValid(Source) and Source == self then return end
        if self:GetPos():DistToSqr(Position) > SoundInvestigateRangeSqr then return end

        self.HeardPos    = Vector(Position.x, Position.y, Position.z)
        self.HeardUntil  = Now + SoundInvestigateTime
        self.HeardSource = IsValid(Source) and Source or nil
    end

    function ENT:StepInvestigateSound(Now)
        if self.HeardPos == nil or Now >= self.HeardUntil then
            self.HeardPos    = nil
            self.HeardSource = nil
            return false
        end

        local Loco = self.loco
        if self:GetPos():DistToSqr(self.HeardPos) <= SearchArriveRangeSqr then
            Loco:SetDesiredSpeed(0)
            Loco:FaceTowards(self.HeardPos)
            if Now >= self.NextSoundInvestigate then
                self.NextSoundInvestigate = Now + math.Rand(1.5, 3)
                self:PlayVoice("Idle")
            end
            return true
        end

        Loco:SetDesiredSpeed(Speed * 0.8)
        Loco:FaceTowards(self.HeardPos)
        self:MoveWithWallSlide(self.HeardPos)
        return true
    end

    function ENT:UpdateIdleBehaviour(Now)
        if Now < self.NextIdleThink then
            if self.IdleWanderPos ~= nil and Now < self.IdleUntil then
                if self:GetPos():DistToSqr(self.IdleWanderPos) > 45 * 45 then
                    self.loco:SetDesiredSpeed(55)
                    self.loco:FaceTowards(self.IdleWanderPos)
                    self:MoveWithWallSlide(self.IdleWanderPos)
                else
                    self.IdleWanderPos = nil
                    self.loco:SetDesiredSpeed(0)
                end
            end
            return
        end
        self.NextIdleThink = Now + IdleThinkDelay

        if Now < self.IdleUntil then
            if self.IdleWanderPos ~= nil then
                if self:GetPos():DistToSqr(self.IdleWanderPos) > 45 * 45 then
                    self.loco:SetDesiredSpeed(55)
                    self.loco:FaceTowards(self.IdleWanderPos)
                    self:MoveWithWallSlide(self.IdleWanderPos)
                else
                    self.IdleWanderPos = nil
                    self.loco:SetDesiredSpeed(0)
                end
            else
                self.loco:SetDesiredSpeed(0)
                if self.IdleLookPos ~= nil then self.loco:FaceTowards(self.IdleLookPos) end
            end
            return
        end

        self.IdleWanderPos = nil
        if math.Rand(0, 1) < IdleWanderChance then
            local Offset = VectorRand() * IdleWanderDistance
            Offset.z = 0
            self.IdleWanderPos = self:GetPos() + Offset
            self.IdleLookPos   = self.IdleWanderPos
            self.IdleUntil     = Now + math.Rand(1.5, 3.0)
            self.loco:SetDesiredSpeed(55)
            self.loco:FaceTowards(self.IdleWanderPos)
        elseif math.Rand(0, 1) < 0.08 then
            self.IdleLookPos = self:GetPos() + VectorRand() * 100
            self.IdleUntil   = Now + math.Rand(0.4, 1.2)
            self.loco:SetDesiredSpeed(0)
            self.loco:FaceTowards(self.IdleLookPos)
        elseif math.Rand(0, 1) < 0.08 then
            self:PlayVoice("Idle")
        end
    end

    function ENT:TryAmbush(Target, Now)
        if self.AmbushUntil > Now or self.AmbushRushUntil > Now then return end
        if not IsValid(Target) or not Target:IsPlayer() then return end
        if self:IsRaging() or self:GetFeeding() then return end

        local Dist = self:GetPos():DistToSqr(Target:GetPos())
        if Dist < AmbushMinRange * AmbushMinRange or Dist > AmbushMaxRange * AmbushMaxRange then return end
        if math.Rand(0, 1) > AmbushChance then return end

        self.AmbushTarget    = Target
        self.AmbushUntil     = Now + math.Rand(AmbushPauseMin, AmbushPauseMax)
        self.AmbushRushUntil = self.AmbushUntil + AmbushRushDuration
    end

    function ENT:UpdateEnvironment(Now)
        if Now < self.NextPropPush or self:GetFeeding() then return end
        if self.loco:GetVelocity():Length2DSqr() < 900 then return end

        self.NextPropPush = Now + PropPushDelay
        local List = ents.FindInSphere(self:GetPos(), PropPushRange)
        for i = 1, #List do
            local Ent = List[i]
            if IsValid(Ent) and Ent:GetMoveType() == MOVETYPE_VPHYSICS and not Ent:IsPlayer() and not Ent:IsRagdoll() then
                local Phys = Ent:GetPhysicsObject()
                if IsValid(Phys) and Phys:IsMotionEnabled() then
                    local Direction = (Ent:WorldSpaceCenter() - self:WorldSpaceCenter())
                    Direction.z = math.max(Direction.z, 25)
                    if Direction:LengthSqr() > 0 then
                        Direction:Normalize()
                        Phys:ApplyForceCenter(Direction * PropPushForce * math.max(Phys:GetMass(), 1))
                        if Ent:GetClass() == "prop_physics" then
                            Ent:EmitSound("physics/wood/wood_box_impact_hard" .. math.random(1, 3) .. ".wav", 55, math.random(85, 110))
                        end
                    end
                end
            end
        end
    end

    function ENT:Attack(Enemy)
        if IsAiDisabled() then return end
        if not IsEnemyValid(Enemy) then return end

        local Now = CurTime()
        if Now < self.NextAttack then return end
        self.NextAttack = Now + AttackDelay

        if GetEnemyDistSqr(self, Enemy) > AttackRangeSqr then return end

        if Enemy:IsNPC() and Enemy.SetShouldServerRagdoll then
            Enemy:SetShouldServerRagdoll(true)
        end

        local Damage = DamageInfo()
        Damage:SetDamage(self.RageUntil > Now and AttackRageDamage or AttackDamage)
        Damage:SetAttacker(self)
        Damage:SetInflictor(self)
        Damage:SetDamageType(DMG_SLASH)
        Enemy:TakeDamageInfo(Damage)

        local BloodPos = Enemy:NearestPoint(self:WorldSpaceCenter())
        BloodBurst(BloodPos, 3)

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

        local Velocity  = self.loco:GetVelocity()
        local MoveSpeed = Velocity:Length2D()
        local IsMoving  = MoveSpeed > 8

        local Seq = self.IdleSeq
        if Seq < 0 then Seq = self.WalkSeq end

        if IsMoving and self.WalkSeq >= 0 then Seq = self.WalkSeq end
        if self:GetFeeding() and self.FeedSeq >= 0 then Seq = self.FeedSeq end

        if Seq >= 0 and self:GetSequence() ~= Seq then
            self:ResetSequence(Seq)
            self.AnimCycle = 0
        end

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

        local SpeedMul = IsMoving and math.Clamp(MoveSpeed / Speed, 0.35, 1.5) or 0.35
        local Rate     = Bootleg.BaseRate * (0.75 + 0.45 * math.sin(Now * 2.7 + self:EntIndex())) * self.RateMul * SpeedMul

        if Now < self.ReverseUntil then Rate = -Rate end
        if Now < self.FreezeUntil then Rate = 0 end

        self.AnimCycle = self.AnimCycle + Delta * Rate

        if Now >= self.NextFrameTime then
            self.NextFrameTime = Now + (1 / Bootleg.AnimFPS) * math.Rand(0.6, 1.5)
            self:SetCycle(self.AnimCycle % 1)
        end

        local MoveX = 1
        local MoveY = math.sin(Now * 5) * 0.25

        if Now < self.MoonwalkUntil then
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

        if self.CorpseState ~= nil and IsValid(Corpse) then
            return GetCorpsePos(Corpse)
        end
        if IsValid(self.Target) then return self.Target:EyePos() end

        return nil
    end

    function ENT:UpdateHead()
        local Now         = CurTime()
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

    local function IsWaterAt(Pos)
        return bit.band(util.PointContents(Pos), CONTENTS_WATER) ~= 0
    end

    local function FindWaterSurface(Pos)
        local StartZ   = Pos.z - 8
        local StartPos = Vector(Pos.x, Pos.y, StartZ)

        if not IsWaterAt(StartPos) then return nil end

        local WaterZ = StartZ
        local AirZ   = nil

        for i = 1, 256 do
            local CheckZ   = StartZ + i * 8
            local CheckPos = Vector(Pos.x, Pos.y, CheckZ)

            if not IsWaterAt(CheckPos) then
                AirZ = CheckZ
                break
            end

            WaterZ = CheckZ
        end

        if AirZ == nil then return nil end

        for i = 1, 8 do
            local MidZ   = (WaterZ + AirZ) * 0.5
            local MidPos = Vector(Pos.x, Pos.y, MidZ)

            if IsWaterAt(MidPos) then
                WaterZ = MidZ
            else
                AirZ = MidZ
            end
        end

        return (WaterZ + AirZ) * 0.5
    end

    function ENT:UpdateWaterWalk()
        local Loco     = self.loco
        local Pos      = self:GetPos()
        local SurfaceZ = FindWaterSurface(Pos)

        if SurfaceZ == nil then
            self.WaterWalking = false
            return false
        end

        self.WaterWalking = true

        local TargetZ  = SurfaceZ + 2
        local Velocity = Loco:GetVelocity()

        if math.abs(Pos.z - TargetZ) > 1 then
            self:SetPos(Vector(Pos.x, Pos.y, TargetZ))
        end

        Loco:SetVelocity(Vector(Velocity.x, Velocity.y, 0))
        return true
    end

    function ENT:UpdateSlopeGrip()
        local Loco = self.loco

        if self.WaterWalking or not Loco:IsOnGround() then return end

        local GroundNormal = Loco:GetGroundNormal()
        if GroundNormal.z >= 0.999 then return end

        local Gravity      = Vector(0, 0, -Loco:GetGravity())
        local SlopeGravity = Gravity - GroundNormal * Gravity:Dot(GroundNormal)

        if SlopeGravity:LengthSqr() <= 0.01 then return end

        local Velocity = Loco:GetVelocity()
        Loco:SetVelocity(Velocity - SlopeGravity * FrameTime() * 1.5)
    end

    function ENT:Think()
        self:UpdateRageBones()

        if self.loco == nil then return end
        if self.AnimCycle == nil then self:InitState() end

        self:UpdateWaterWalk()
        self:UpdateSlopeGrip()

        if IsAiDisabled() then
            self.LastAnimTime = CurTime()
            self:NextThink(CurTime())
            return true
        end

        self:UpdateBootlegAnim()
        self:UpdateHead()
        self:UpdateFeedArms()
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
        if IsValid(Corpse.GMMEatenBy) and Corpse.GMMEatenBy ~= self then return false, "CORPSE TAKEN" end

        return true
    end

    function ENT:StartCorpse(Corpse)
        local Now = CurTime()

        Corpse.GMMEatenBy = self

        self.Corpse         = Corpse
        self.CorpseDeadline = Now + CorpseMaxTime
        self.GripBreaks     = 0
        self.GripBroken     = false
        self.SearchPos      = nil
        self.HeardPos       = nil

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
        if IsValid(self.Corpse) and self.Corpse.GMMEatenBy == self then
            self.Corpse.GMMEatenBy = nil
        end

        self:ReleaseGrip(self.Corpse)
        self:ResetFeedArms()
        self:SetFeeding(false)

        self.Corpse      = nil
        self.CorpseState = nil
        self.DragPos     = nil
        self.FeedEnd     = nil
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

        local PhysCount = math.max(self.Corpse:GetPhysicsObjectCount(), 1)
        self.FeedBiteDelay = math.Clamp(BiteDelay * math.sqrt(PhysCount / 8), 0.18, 0.65)
        self.NextBite      = Now + self.FeedBiteDelay
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
        local Dx      = GripTarget.x - PhysPos.x
        local Dy      = GripTarget.y - PhysPos.y
        local Dz      = GripTarget.z - PhysPos.z

        if Dx * Dx + Dy * Dy + Dz * Dz > GripBreakSqr then
            self.GripBroken = true
            return
        end

        GripVel.x = Dx * GripPull
        GripVel.y = Dy * GripPull
        GripVel.z = Dz * GripPull

        Phys:Wake()
        Phys:SetVelocity(GripVel)

        local RootPhys = Corpse:GetPhysicsObjectNum(0)
        if IsValid(RootPhys) and RootPhys ~= Phys then
            RootPhys:Wake()
            RootPhys:SetVelocity(GripVel * 0.6)
        end
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
        local Pos  = GetCorpsePos(Corpse)
        if Pos == nil then
            self:EndCorpse()
            return
        end

        if GetCorpseDistSqr(self:GetPos(), Corpse) <= GrabRangeSqr then
            if self.GripBreaks >= MaxGripBreaks or not self:StartDrag(Corpse, Now) then
                self:StartFeed(Now)
            end
            return
        end

        Loco:FaceTowards(Pos)
        Loco:SetDesiredSpeed(Speed)
        self:MoveWithWallSlide(Pos)
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
        self:MoveWithWallSlide(self.DragPos)
        Loco:ClearStuck()

        if Now >= self.NextDragDecal then
            self.NextDragDecal = Now + DragDecalDelay
            local cPos = GetCorpsePos(Corpse)
            if cPos ~= nil then PlaceBlood(cPos, 12, self, Corpse) end
        end

        if self:GetPos():DistToSqr(self.DragPos) <= DragArriveSqr or Now > self.StateUntil then
            self:ReleaseGrip(Corpse)
            self:StartFeed(Now)
        end
    end

    function ENT:ApplyBloodySkin()
        if self:GetModel() ~= ModelPavel then return end

        local Skins = self:SkinCount() or 0
        if Skins > 2 and self:GetSkin() < 2 then
            self:SetSkin(2)
        end
    end

    local TearVecA = Vector()
    local TearVecB = Vector()

    local function RipCorpseApart(Zombie, Corpse, OriginPos, Intensity)
        if not IsValid(Corpse) then return end

        local Count = Corpse:GetPhysicsObjectCount()
        if Count < 1 then return end

        local PhysA = Corpse:GetPhysicsObjectNum(math.random(0, Count - 1))
        local PhysB = Count > 1 and Corpse:GetPhysicsObjectNum(math.random(0, Count - 1)) or nil

        local Forward = Zombie:GetForward()
        local Right   = Zombie:GetRight()
        local Dir     = (Right * (math.random(0, 1) == 0 and -1 or 1) + Forward * 0.45 + Vector(0, 0, 0.35)):GetNormalized()

        if IsValid(PhysA) then
            TearVecA.x = Dir.x * Intensity
            TearVecA.y = Dir.y * Intensity
            TearVecA.z = math.abs(Dir.z) * Intensity * 0.65
            PhysA:Wake()
            PhysA:AddVelocity(TearVecA)
        end

        if IsValid(PhysB) and PhysB ~= PhysA then
            TearVecB.x = -Dir.x * Intensity * 0.85
            TearVecB.y = -Dir.y * Intensity * 0.85
            TearVecB.z = math.Rand(20, 65)
            PhysB:Wake()
            PhysB:AddVelocity(TearVecB)
        end
    end
    
    function ENT:Bite(Corpse, Now)
        local Item = self.EatList[self.EatIndex]

        if Item == nil then
            if self.FeedEnd == nil then
                self.FeedEnd = Now + FeedRestTime
            end

            if Now >= self.FeedEnd then
                CreateSkeletonFromCorpse(Corpse)
                self:EndCorpse()
            end

            return
        end

        local Pos = GetItemPos(Corpse, Item)

        self.EatBites    = self.EatBites + 1
        self.BloodyUntil = Now + BloodyFeetTime
        self.Satiety     = math.min(SatietyFull, (self.Satiety or 0) + SatietyPerBite)
        self:ApplyBloodySkin()

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
            Corpse:EmitSound(FinishSound, 75, math.random(SoundPitchMin - 5, SoundPitchMax + 5))
            RipCorpseApart(self, Corpse, Pos, TugSpeed * 2.4)

            self.EatIndex = self.EatIndex + 1
            self.EatBites = 0
        else
            self:EmitSound(EatSounds[math.random(#EatSounds)], 72, math.random(SoundPitchMin, SoundPitchMax))
            RipCorpseApart(self, Corpse, Pos, TugSpeed * 1.35)
        end

        self:RestartGesture(ACT_GMOD_GESTURE_RANGE_ZOMBIE)

        if self.EatBites % 2 == 0 then self:RestartGesture(ACT_GMOD_GESTURE_RANGE_ZOMBIE) end

        TugCorpse(Corpse)
    end

    function ENT:StepFeed(Corpse, Now)
        local Loco = self.loco
        local Pos  = GetCorpsePos(Corpse)
        if Pos == nil then
            self:EndCorpse()
            return
        end

        Loco:FaceTowards(Pos)

        if not self:GetFeeding() then
            if GetCorpseDistSqr(self:GetPos(), Corpse) > FeedRangeSqr and Now <= self.StateUntil then
                Loco:SetDesiredSpeed(Speed)
                self:MoveWithWallSlide(Pos)
                return
            end

            self:SetFeeding(true)
            self.NextBite = Now + (self.FeedBiteDelay or BiteDelay)
        end

        Loco:SetDesiredSpeed(0)

        if Now < self.NextBite then return end

        self.NextBite = Now + (self.FeedBiteDelay or BiteDelay)

        self:Bite(Corpse, Now)
    end

    function ENT:CorpseStep()
        if self.CorpseState == nil then return false end

        local Corpse = self.Corpse
        local Now    = CurTime()

        if not IsCorpseUsable(Corpse) or Now > self.CorpseDeadline then
            self:EndCorpse()
            return false
        end

        local Threat = self.Target
        if IsEnemyValid(Threat) and GetEnemyDistSqr(self, Threat) <= CorpseThreatRangeSqr and CanSeeTarget(self, Threat) then
            self:SetFeeding(false)
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

    function ENT:FindNearestCorpse()
        local Best     = nil
        local BestDist = CorpseNoticeRangeSqr
        local List     = ents.FindByClass("prop_ragdoll")
        local MyPos    = self:GetPos()

        for i = 1, #List do
            local Corpse = List[i]

            if self:WantsCorpse(Corpse) then
                local Dist = GetCorpseDistSqr(MyPos, Corpse)

                if Dist < BestDist then
                    Best     = Corpse
                    BestDist = Dist
                end
            end
        end

        return Best
    end

    -- ----------------------------------------------------------------------
    -- Поведение
    -- ----------------------------------------------------------------------

    function ENT:MoveWithWallSlide(TargetPos)
        local Loco = self.loco
        local Pos  = self:GetPos()

        if self.WaterWalking then
            local WaterTarget = Vector(TargetPos.x, TargetPos.y, Pos.z)

            Loco:Approach(WaterTarget, 1)
            return
        end

        local Direction = TargetPos - Pos
        Direction.z = 0

        if Direction:LengthSqr() < 1 then return end

        Direction:Normalize()

        local Trace = util.TraceHull({
            start  = Pos + Vector(0, 0, 42),
            endpos = Pos + Vector(0, 0, 42) + Direction * 48,
            mins   = Vector(-14, -14, -8),
            maxs   = Vector(14, 14, 8),
            filter = self,
            mask   = MASK_NPCSOLID
        })

        if Trace.Hit and not Trace.StartSolid and Trace.HitNormal.z < 0.2 then
            local Slide = Direction - Trace.HitNormal * Direction:Dot(Trace.HitNormal)

            Slide.z = 0

            if Slide:LengthSqr() <= 0.01 then
                Slide.x = -Trace.HitNormal.y
                Slide.y = Trace.HitNormal.x

                if Slide:Dot(self:GetRight()) < 0 then
                    Slide:Mul(-1)
                end
            end

            if Slide:LengthSqr() > 0.01 then
                Slide:Normalize()
                TargetPos = Pos + Slide * 128
            end
        end

        Loco:Approach(TargetPos, 1)
    end

    function ENT:BehaviourStep()
        local Loco = self.loco
        local Now  = CurTime()

        self.Satiety = math.max((self.Satiety or 0) - SatietyDecay, 0)

        local Raging = self:IsRaging()
        if self.WasRaging and not Raging then
            self.ExhaustedUntil = Now + 4
            self:CalmDown()
        end
        self.WasRaging = Raging

        if IsAiDisabled() then
            Loco:SetDesiredSpeed(0)
            Loco:ClearStuck()
            return
        end

        if IsEnemyValid(self.Target) then
            if CanSeeTarget(self, self.Target) then
                self:RememberTarget(self.Target, Now)
            elseif self.LastSeenTarget == self.Target and Now - self.LastSeenTime >= LoseSightDelay then
                local LastPos = self.LastSeenPos
                self:StartSearch(LastPos, Now)
            end
        end

        if not IsEnemyValid(self.Target) or Now >= self.NextRetarget then
            local Lost = not IsEnemyValid(self.Target)
            self.NextRetarget = Now + RetargetDelay
            local NewTarget = self:FindNearestEnemy()
            if IsValid(NewTarget) and self.SearchPos ~= nil and NewTarget == self.LastSeenTarget and not CanSeeTarget(self, NewTarget) then
                NewTarget = nil
            end

            if IsValid(NewTarget) then
                self.Target    = NewTarget
                self.SearchPos = nil
                self.HeardPos  = nil
                if Lost and NewTarget ~= self.LastSeenTarget then self:PlayVoice("Alert") end
            elseif Lost then
                self.Target = nil
            end
        end

        if self.CorpseState ~= nil then
            local Threat = self.Target
            if IsEnemyValid(Threat) and GetEnemyDistSqr(self, Threat) <= CorpseThreatRangeSqr and CanSeeTarget(self, Threat) then
                self:SetFeeding(false)
                Loco:SetDesiredSpeed(math.max(Speed * self.SpeedMul, 80))
                Loco:FaceTowards(Threat:GetPos())
                self:MoveWithWallSlide(Threat:GetPos())
                self:Attack(Threat)
                return
            end

            if self:CorpseStep() then return end
        end

        if self.Satiety < SatietySearchThreshold and self.CorpseState == nil and Now >= self.NextCorpseSearch then
            self.NextCorpseSearch = Now + 0.4
            local Corpse = self:FindNearestCorpse()
            if IsValid(Corpse) then
                self:StartCorpse(Corpse)
                if self:CorpseStep() then return end
            end
        end

        if IsEnemyValid(self.Target) then
            local Target    = self.Target
            local TargetPos = Target:GetPos()
            local Visible   = CanSeeTarget(self, Target)

            if Visible then
                self:RememberTarget(Target, Now)
                self:UpdateRageState(Target, Now)
                self:TryAmbush(Target, Now)

                if Now < self.AmbushUntil then
                    Loco:SetDesiredSpeed(0)
                    Loco:FaceTowards(TargetPos)
                    return
                end

                local BaseSpeed = math.max(Speed * self.SpeedMul, 20)
                if Now < self.IrritatedUntil then BaseSpeed = BaseSpeed * 1.2 end
                if Now < self.ExhaustedUntil then BaseSpeed = BaseSpeed * 0.65 end
                if Now < self.AmbushRushUntil then BaseSpeed = math.max(BaseSpeed, Speed * 1.8) end

                if self:IsRaging() then
                    Loco:SetAcceleration(RageAcceleration)
                    Loco:SetDeceleration(RageDeceleration)
                    Loco:SetDesiredSpeed(RageSpeed)
                    self:MoveWithWallSlide(TargetPos)
                else
                    Loco:SetAcceleration(900)
                    Loco:SetDeceleration(900)
                    Loco:SetDesiredSpeed(BaseSpeed)
                    self:MoveWithWallSlide(TargetPos)
                end

                if GetEnemyDistSqr(self, Target) <= AttackRangeSqr then self:Attack(Target) end
                self:UpdateEnvironment(Now)
                if Loco:IsStuck() then Loco:ClearStuck() end
                return
            end

            if self.LastSeenPos ~= nil and Now - self.LastSeenTime < SearchDuration then
                self:StartSearch(self.LastSeenPos, Now)
            end
        end

        if self:StepSearch(Now) then
            self:UpdateEnvironment(Now)
            return
        end

        if self:StepInvestigateSound(Now) then return end

        self:UpdateIdleBehaviour(Now)
        if Now >= self.IdleUntil then
            Loco:SetDesiredSpeed(0)
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
        self:EnterRage("INJURED")

        local Now      = CurTime()
        local Attacker = Damage:GetAttacker()

        if IsEnemyValid(Attacker) then
            self.Target       = Attacker
            self.GrudgeTarget = Attacker
            self.GrudgeUntil  = Now + GrudgeTime
            self.NextRetarget = Now + GrudgeTime
            self:RememberTarget(Attacker, Now)
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

        local Color   = self:GetColor()
        local Ragdoll = self:BecomeRagdoll(Damage)
        local Skin    = self:GetSkin()
        local Scale   = self.ModelScale or 1
        
        if IsValid(Ragdoll) then
            Ragdoll:SetColor(Color)
            Ragdoll:SetSkin(Skin)
            Ragdoll:SetModelScale(Scale, 0)
        end
    end

    function ENT:OnRemove()
        self:EndCorpse()
    end

    local FeedArmBoneNames = {
        "ValveBiped.Bip01_L_UpperArm",
        "ValveBiped.Bip01_R_UpperArm",
        "ValveBiped.Bip01_L_Forearm",
        "ValveBiped.Bip01_R_Forearm",
        "ValveBiped.Bip01_L_Hand",
        "ValveBiped.Bip01_R_Hand"
    }

    function ENT:InitFeedArms()
        self.FeedArms = {}

        for i = 1, #FeedArmBoneNames do
            local Bone = self:LookupBone(FeedArmBoneNames[i])

            if Bone ~= nil and Bone >= 0 then
                self.FeedArms[#self.FeedArms + 1] = Bone
            end
        end
    end

    function ENT:ResetFeedArms()
        if not self.FeedArmsActive then return end
        self.FeedArmsActive = false

        for i = 1, #self.FeedArms do
            local Bone = self.FeedArms[i]
            if Bone >= 0 then
                self:ManipulateBoneAngles(Bone, Angle(0, 0, 0))
            end
        end
    end

    function ENT:UpdateFeedArms()
        if not self:GetFeeding() then
            self:ResetFeedArms()
            return
        end

        if #self.FeedArms == 0 then
            self:InitFeedArms()
        end

        local Now = CurTime()
        if Now < self.NextFeedArmUpdate then return end

        self.NextFeedArmUpdate = Now + 0.06
        self.FeedArmsActive    = true
        self.FeedTearDir       = -self.FeedTearDir

        local Dir = self.FeedTearDir

        for i = 1, #self.FeedArms do
            local Bone = self.FeedArms[i]
            if Bone >= 0 then
                local Side  = (i % 2 == 0) and 1 or -1
                local Pitch = math.Rand(-45, 35) * Dir
                local Yaw   = math.Rand(20, 65) * Side * Dir
                local Roll  = math.Rand(-55, 55) * Side

                self:ManipulateBoneAngles(Bone, Angle(Pitch, Yaw, Roll))
            end
        end
    end
    
    function ENT:InitRageBones()
        self.RageBones = {}

        local BoneNames = {
            "ValveBiped.Bip01_L_UpperArm",
            "ValveBiped.Bip01_R_UpperArm",
            "ValveBiped.Bip01_L_Forearm",
            "ValveBiped.Bip01_R_Forearm",
            "ValveBiped.Bip01_L_Hand",
            "ValveBiped.Bip01_R_Hand",
            "ValveBiped.Bip01_Spine",
            "ValveBiped.Bip01_Head1"
        }

        for i = 1, #BoneNames do
            local Bone = self:LookupBone(BoneNames[i])

            if Bone ~= nil and Bone >= 0 then
                self.RageBones[#self.RageBones + 1] = Bone
            end
        end
    end

    function ENT:UpdateRageBones()
        if not self:IsRaging() then return end

        local Now = CurTime()
        if Now < self.NextRageBoneUpdate then return end

        self.NextRageBoneUpdate = Now + RageBoneUpdateDelay

        for i = 1, #self.RageBones do
            local Bone = self.RageBones[i]

            local Pitch = math.Rand(-35, 35)
            local Yaw   = math.Rand(-55, 55)
            local Roll  = math.Rand(-65, 65)

            self:ManipulateBoneAngles(Bone, Angle(Pitch, Yaw, Roll))
        end

        if Now >= self.NextRageArmSwing then
            self.NextRageArmSwing = Now + math.Rand(0.1, 0.25)

            self:RestartGesture(ACT_GMOD_GESTURE_RANGE_ZOMBIE)
        end
    end

    -- ----------------------------------------------------------------------
    -- Трупы: хуки
    -- ----------------------------------------------------------------------

    local function GiveCorpse(Ragdoll)
        if not IsValid(Ragdoll) then return end

        local Pos      = GetCorpsePos(Ragdoll) or Ragdoll:GetPos()
        local Best     = nil
        local BestDist = math.huge
        local Why      = nil
        local WhyDist  = math.huge
        local List     = ents.FindByClass(ClassName)

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
            elseif IsDeveloper() then
                print("[GMM] PAVELZOMBIE CORPSE NOT USABLE! CLASS: " .. Ragdoll:GetClass() .. ", PHYS COUNT: " .. Ragdoll:GetPhysicsObjectCount())
            end

            return
        end

        GiveCorpse(Ragdoll)
    end

    hook.Add("DoPlayerDeath", "gmm_PavelZombie_PlayerSnapshot", function(Ply, Attacker, Damage)
        Ply.GMMPavelSnap = nil

        local Inflictor = IsValid(Damage) and Damage:GetInflictor() or nil
        local ByPavel   = false

        if IsValid(Attacker) and Attacker:GetClass() == ClassName then ByPavel = true end
        if IsValid(Inflictor) and Inflictor:GetClass() == ClassName then ByPavel = true end

        if not ByPavel then return end

        if GMM.Func and GMM.Func.TakePlayerSnapshot then
            Ply.GMMPavelSnap = GMM.Func.TakePlayerSnapshot(Ply)
        end
    end)

    hook.Add("ShouldCollide", "gmm_PavelZombie_NoRagdollCollide", function(EntA, EntB)
        if not IsValid(EntA) or not IsValid(EntB) then return end

        local AIsZombie = EntA:GetClass() == ClassName
        local BIsZombie = EntB:GetClass() == ClassName

        if not AIsZombie and not BIsZombie then return end

        local Other = AIsZombie and EntB or EntA
        if IsValid(Other) and Other:GetClass() == "prop_ragdoll" then
            return false
        end
    end)

    hook.Add("PostPlayerDeath", "gmm_PavelZombie_PlayerCorpse", function(Ply)
        local Snap = Ply.GMMPavelSnap
        if Snap == nil then return end

        Ply.GMMPavelSnap = nil

        local DefaultRagdoll = Ply:GetRagdollEntity()
        if IsValid(DefaultRagdoll) then
            DefaultRagdoll:Remove()
        end

        if GMM.Func and GMM.Func.CreatePlayerRagdoll then
            local Corpse = GMM.Func.CreatePlayerRagdoll(Snap, PlayerCorpseLife)
            if IsValid(Corpse) then
                timer.Simple(CorpseOfferDelay, function()
                    OfferCorpse(Corpse, CorpseOfferTries)
                end)
            end
        end
    end)

    hook.Add("CreateEntityRagdoll", "gmm_PavelZombie_NpcCorpse", function(Owner, Ragdoll)
        if IsValid(Owner) and Owner:GetClass() == ClassName then return end

        timer.Simple(CorpseOfferDelay, function()
            OfferCorpse(Ragdoll, CorpseOfferTries)
        end)
    end)

    hook.Add("EntityEmitSound", "gmm_PavelZombie_InvestigateSound", function(Data)
        local Source = Data.Entity
        if IsValid(Source) and Source:GetClass() == ClassName then return end
        if (Data.SoundLevel or 0) < SoundHearMin then return end

        local Now = CurTime()
        if IsValid(Source) then
            if (Source.GMMPavelSoundUntil or 0) > Now then return end
            Source.GMMPavelSoundUntil = Now + 0.35
        end

        local Position = Data.Pos
        if Position == nil and IsValid(Source) then Position = Source:WorldSpaceCenter() end
        if Position == nil then return end

        for _, Bot in ipairs(ents.FindByClass(ClassName)) do
            if IsValid(Bot) and Bot.CorpseState == nil and not IsEnemyValid(Bot.Target) then
                Bot:HearPosition(Position, Source, Now)
            end
        end
    end)

    hook.Add("PlayerFootstep", "gmm_PavelZombie_InvestigateFootstep", function(Ply, Position)
        if not IsValid(Ply) or not Ply:Alive() or IgnorePlayers() then return end
        local Now = CurTime()
        for _, Bot in ipairs(ents.FindByClass(ClassName)) do
            if IsValid(Bot) and Bot.CorpseState == nil and not IsEnemyValid(Bot.Target) then
                Bot:HearPosition(Position, Ply, Now)
            end
        end
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

    local HaloColor = Color(255, 40, 40)
    local HaloList  = {}
    local HaloNext  = 0

    local FeedLean = 28
    local FeedBob  = 10

    function ENT:Draw()
        local Now = CurTime()
        local Id  = self:EntIndex()

        if self.GlitchMatrix == nil then
            self.GlitchMatrix   = Matrix()
            self.GlitchOffset   = Vector()
            self.GlitchAng      = Angle()
            self.GlitchScale    = Vector(1, 1, 1)
            self.NextVisGlitch  = 0
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