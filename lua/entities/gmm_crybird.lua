AddCSLuaFile()

if SERVER then
	AddCSLuaFile("gmm/data/crybird_talk.lua")

    util.AddNetworkString("gmm_CryBirdChat")
    util.AddNetworkString("gmm_CryBirdFarewell")
end

include("gmm/data/crybird_talk.lua")

ENT.Type         = "anim"
ENT.Base         = "base_anim"
ENT.PrintName    = "CRYBIRD.lit"
ENT.Author       = "Woowz11"
ENT.Category     = "GMM"
ENT.Spawnable    = GMM.Func.DoEntitiesUnlock()
ENT.IsGMMCryBird = true
ENT.GMMFreezeImmune = true

if CLIENT then
    killicon.Add("gmm_crybird", "woowz_map/gm_garrymod_map_by_woowz_map_garry_game/icons/killicon_freeze")
    language.Add("gmm_crybird", "CRYBIRD.lit")
end

-- ----------------------------------------------------------------------
-- Общее
-- ----------------------------------------------------------------------

local ClassName  = "gmm_crybird"
local ModelPath  = "models/woowz_map/prikol/le_bird.mdl"
local ModelScale = 0.5

local MoodSad      = 0
local MoodLure     = 1
local MoodOffended = 2
local MoodAngry    = 3
local MoodHappy    = 4

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "Mood")
    self:NetworkVar("Int", 1, "SayId")

    self:NetworkVar("Float", 0, "SayStart")
    self:NetworkVar("Float", 1, "SayDuration")

    self:NetworkVar("String", 0, "SayText")
end

function ENT:Initialize()
    self:SetModel(ModelPath)
    self:SetModelScale(ModelScale, 0)

    if SERVER then self:InitServer() end
    if CLIENT then self:InitClient() end
end

-- ----------------------------------------------------------------------
-- Сервер
-- ----------------------------------------------------------------------

if SERVER then
    local NoticeRange    = 320
    local LeaveRange     = 520
    local ChatRange      = 350
    local MutterRange    = 700
    local FlashRange     = 160
    local WrathRange     = 900

    local NoticeRangeSqr = NoticeRange * NoticeRange
    local LeaveRangeSqr  = LeaveRange * LeaveRange
    local ChatRangeSqr   = ChatRange * ChatRange
    local MutterRangeSqr = MutterRange * MutterRange
    local FlashRangeSqr  = FlashRange * FlashRange
    local WrathRangeSqr  = WrathRange * WrathRange

    local ThinkDelay       = 0.2
    local LureMax          = 3
    local LureDelayMin     = 5
    local LureDelayMax     = 8
    local TalkIdleSeconds  = 30
    local MoodHold         = 5
    local OffendedSeconds  = 20
    local MutterMin        = 25
    local MutterMax        = 60

    local AngerMax         = 100
    local AngerSulk        = 25
    local AngerWarn        = 60
    local AngerDecay       = 1.5
    local ReactDelay       = 2
    local OffenceDelay     = 0.8
    local SpamLimit        = 4
    local SpamWindow       = 1.2
    local SecretTrust      = 5

    local WrathDuration    = 6
    local WrathTick        = 0.5
    local WrathCold        = 16
    local WrathFinishCold  = 100
    local ApologyChance    = 0.35

    local ThrowSpeed       = 250
    local ThrowWatch       = 0.4
    local ThrowSpeedSqr    = ThrowSpeed * ThrowSpeed

    local BuddyRange       = 350
    local BuddyLookRange   = 500
    local BuddyDropRange   = 650
    local BuddyDelayMin    = 40
    local BuddyDelayMax    = 120
    local BuddyRetry       = 3
    local BuddyLinePause   = 1.2
    local BuddyPlayerChance = 0.5
    local BuddyAloneChance  = 0.6
    local BuddyFirstMin = 3
    local BuddyFirstMax = 10
    local BuddyMissMin  = 8
    local BuddyMissMax  = 20
    local FarewellRange    = 1000

    local BuddyRangeSqr     = BuddyRange * BuddyRange
    local BuddyLookRangeSqr = BuddyLookRange * BuddyLookRange
    local BuddyDropRangeSqr = BuddyDropRange * BuddyDropRange
    local FarewellRangeSqr  = FarewellRange * FarewellRange

    local Offences = {
        Pickup     = {Anger = 12, Group = "Pickup"},
        Punt       = {Anger = 45, Group = "Punt"},
        Throw      = {Anger = 35, Group = "Throw"},
        Tool       = {Anger = 20, Group = "Tool"},
        Flashlight = {Anger = 6,  Group = "Flashlight"}
    }

    local AiDisabledVar = GetConVar("ai_disabled")
    local MissingWarned = {}
    local ShuttingDown  = false

    local function IsAiDisabled()
        return AiDisabledVar ~= nil and AiDisabledVar:GetBool()
    end

    local function GetTalkData()
        if GMM == nil or GMM.Data == nil then return nil end
        return GMM.Data.CryBirdTalk
    end

    local function FormatLine(Line, Ply)
        return string.Replace(Line, "{Name}", IsValid(Ply) and Ply:Nick() or "")
    end

    local function WarnMissing(GroupName)
        if MissingWarned[GroupName] then return end

        MissingWarned[GroupName] = true
        print("[GMM] CRYBIRD LINE GROUP NOT FOUND! GROUP: " .. tostring(GroupName))
    end

    local function PickLine(GroupName, Ply)
        local Data  = GetTalkData()
        local Group = Data ~= nil and Data[GroupName] or nil

        if Group == nil or #Group == 0 then
            WarnMissing(GroupName)
            return nil
        end

        return FormatLine(Group[math.random(#Group)], Ply)
    end

    local function PickBuddyDialogue()
        local Data      = GetTalkData()
        local Dialogues = Data ~= nil and Data.BuddyTalk or nil

        if Dialogues == nil or #Dialogues == 0 then
            WarnMissing("BuddyTalk")
            return nil
        end

        return Dialogues[math.random(#Dialogues)]
    end

    local function LowerText(Text)
        local Out = {}

        for _, Code in utf8.codes(Text) do
            if Code >= 0x41 and Code <= 0x5A then
                Code = Code + 32
            elseif Code >= 0x410 and Code <= 0x42F then
                Code = Code + 32
            elseif Code == 0x401 then
                Code = 0x451
            end

            Out[#Out + 1] = utf8.char(Code)
        end

        return table.concat(Out)
    end

    local function FindTopic(Topics, Lower)
        if Topics == nil then return nil end

        for _, Topic in ipairs(Topics) do
            for _, Key in ipairs(Topic.Keys) do
                if string.find(Lower, Key, 1, true) ~= nil then return Topic end
            end
        end

        return nil
    end

    local function SendChat(Ply, Text, Mood)
        net.Start("gmm_CryBirdChat")
        net.WriteString(Text)
        net.WriteUInt(Mood, 3)
        net.Send(Ply)
    end

    -- ----------------------------------------------------------------------

    function ENT:InitServer()
        self:InitState()

        local Mins, Maxs = self:GetModelBounds()
        if Maxs:LengthSqr() < 1 then
            Mins = Vector(-10, -10, 0)
            Maxs = Vector(10, 10, 30)
        end

        self:PhysicsInitBox(Mins * ModelScale, Maxs * ModelScale)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)
        self:SetMaxHealth(1000)
        self:SetHealth(1000)
        self:SetMood(MoodSad)

        local Phys = self:GetPhysicsObject()
        if IsValid(Phys) then
            Phys:SetMass(20)
            Phys:EnableMotion(false)
        end
    end

    function ENT:InitState()
        local Now = CurTime()

        self.Memory      = setmetatable({}, {__mode = "k"})
        self.Visitor     = nil
        self.Wrath       = nil
        self.Chat        = nil
        self.LureCount   = 0
        self.NextLure    = 0
        self.NextNotice  = 0
        self.NextReact   = 0
        self.BusyUntil   = 0
        self.MoodUntil   = 0
        self.NextMutter  = Now + math.Rand(MutterMin, MutterMax)
        self.NextBuddy   = Now + math.Rand(BuddyFirstMin, BuddyFirstMax)
        self.LastThink   = Now
        self.VisitTalked = false
        self.VisitParted = false
        self.IdleSaid    = false
    end

    function ENT:GetMemoryOrNew(Ply)
        local Mem = self.Memory[Ply]
        if Mem ~= nil then return Mem end

        Mem = {
            Talks       = 0,
            Trust       = 0,
            Anger       = 0,
            Left        = 0,
            Kills       = 0,
            Story       = 0,
            Spam        = 0,
            LastUse     = 0,
            LastTalk    = 0,
            NextOffence = 0,
            Offended    = false,
            Warned      = false,
            Greeted     = false
        }

        self.Memory[Ply] = Mem
        return Mem
    end

    function ENT:CanSee(Ply)
        local Tr = util.TraceLine({
            start  = self:WorldSpaceCenter(),
            endpos = Ply:EyePos(),
            mask   = MASK_SOLID_BRUSHONLY
        })

        if Tr.Hit then return false end
        return true
    end

    function ENT:CanSeeBird(Other)
        local Tr = util.TraceLine({
            start  = self:WorldSpaceCenter(),
            endpos = Other:WorldSpaceCenter(),
            mask   = MASK_SOLID_BRUSHONLY
        })

        if Tr.Hit then return false end
        return true
    end

    function ENT:IsStill()
        local Phys = self:GetPhysicsObject()
        if not IsValid(Phys) then return false end
        if Phys:IsMotionEnabled() then return false end
        if self:IsPlayerHolding() then return false end

        return true
    end

    -- ----------------------------------------------------------------------
    -- Речь
    -- ----------------------------------------------------------------------

    function ENT:Say(Text, Mood, Target)
        if Text == nil or Text == "" then return 0 end
        if IsAiDisabled() then return 0 end

        local Now      = CurTime()
        local Length   = utf8.len(Text) or #Text
        local Duration = math.Clamp(2.5 + Length * 0.09, 3, 12)

        self:SetSayText(Text)
        self:SetSayDuration(Duration)
        self:SetSayStart(Now)
        self:SetSayId(self:GetSayId() + 1)
        self:SetMood(Mood)

        self.BusyUntil = Now + Duration
        self.MoodUntil = Now + Duration + MoodHold

        if IsValid(Target) then SendChat(Target, Text, Mood) end

        local Pitch = Mood == MoodAngry and math.random(40, 60) or math.random(170, 210)
        self:EmitSound("npc/headcrab/pain" .. math.random(1, 3) .. ".wav", 60, Pitch, 0.4)

        return Duration
    end

    function ENT:SayGroup(GroupName, Mood, Target)
        local Line = PickLine(GroupName, Target)
        if Line == nil then return 0 end

        return self:Say(Line, Mood, Target)
    end

    function ENT:SayTalk(Ply, Mem)
        if not Mem.Greeted then
            Mem.Greeted = true
            self:SayGroup("Greet", MoodLure, Ply)
            return
        end

        if Mem.Trust >= SecretTrust and math.random() < 0.3 then
            self:SayGroup("Secret", MoodSad, Ply)
            return
        end

        local Data  = GetTalkData()
        local Story = Data ~= nil and Data.Story or nil

        if Story ~= nil and Mem.Story < #Story and math.random() < 0.75 then
            Mem.Story = Mem.Story + 1
            self:Say(FormatLine(Story[Mem.Story], Ply), MoodSad, Ply)
            return
        end

        self:SayGroup("Whine", MoodSad, Ply)
    end

    -- ----------------------------------------------------------------------
    -- Визит
    -- ----------------------------------------------------------------------

    function ENT:FindNewVisitor()
        local Center   = self:WorldSpaceCenter()
        local Best     = nil
        local BestDist = NoticeRangeSqr

        for _, Ply in ipairs(player.GetAll()) do
            if Ply:Alive() and not Ply:IsFlagSet(FL_NOTARGET) then
                local Dist = Center:DistToSqr(Ply:GetPos())

                if Dist < BestDist and self:CanSee(Ply) then
                    Best     = Ply
                    BestDist = Dist
                end
            end
        end

        return Best
    end

    function ENT:TakeVisitor(Ply)
        if self.Visitor == Ply then return end

        self.Visitor     = Ply
        self.LureCount   = LureMax
        self.VisitTalked = false
        self.VisitParted = false
    end

    function ENT:BeginVisit(Ply, Now)
        local Mem = self:GetMemoryOrNew(Ply)

        self.Visitor     = Ply
        self.LureCount   = 0
        self.NextLure    = Now + 0.6
        self.VisitTalked = false
        self.VisitParted = false
        self.IdleSaid    = false

        if Mem.Anger >= AngerSulk then
            self.LureCount = LureMax
            self:SayGroup("Sulk", MoodOffended, Ply)
            return
        end

        if not Mem.Offended then return end

        Mem.Offended   = false
        self.LureCount = 1
        self.NextLure  = Now + math.Rand(LureDelayMin, LureDelayMax)
        self:SayGroup(Mem.Left >= 3 and "ReturnOften" or "Return", MoodLure, Ply)
    end

    function ENT:EndVisit(Now)
        local Visitor = self.Visitor
        local Talked  = self.VisitTalked
        local Parted  = self.VisitParted
        local Lured   = self.LureCount > 0

        self.Visitor     = nil
        self.VisitTalked = false
        self.VisitParted = false
        self.IdleSaid    = false
        self.NextNotice  = Now + 3

        if not IsValid(Visitor) or not Visitor:Alive() then return end
        if Parted then return end

        local Mem = self:GetMemoryOrNew(Visitor)
        if Mem.Anger >= AngerSulk then return end

        local Group = nil
        if Talked then Group = "LeftTalk" elseif Lured then Group = "LeftLure" end
        if Group == nil then return end

        Mem.Left     = Mem.Left + 1
        Mem.Offended = true

        self:SayGroup(Group, MoodOffended, Visitor)
        self.MoodUntil = math.max(self.MoodUntil, Now + OffendedSeconds)
    end

    function ENT:LureThink(Now, Mem)
        if self.VisitTalked then
            if self.IdleSaid or self.VisitParted then return end
            if Now - Mem.LastTalk < TalkIdleSeconds then return end
            if Now < self.BusyUntil then return end

            self.IdleSaid = true
            self:SayGroup("Silence", MoodSad, self.Visitor)
            return
        end

        if self.LureCount >= LureMax then return end
        if Now < self.NextLure then return end
        if Now < self.BusyUntil then return end

        local Group = "LureAgain"
        if self.LureCount == 0 then Group = "Lure" end
        if self.LureCount == LureMax - 1 then Group = "LureLast" end

        self:SayGroup(Group, MoodLure, self.Visitor)
        self.LureCount = self.LureCount + 1
        self.NextLure  = Now + math.Rand(LureDelayMin, LureDelayMax)
    end

    function ENT:MutterThink(Now)
        if Now < self.NextMutter then return end
        self.NextMutter = Now + math.Rand(MutterMin, MutterMax)

        local Center = self:WorldSpaceCenter()

        for _, Ply in ipairs(player.GetAll()) do
            if Center:DistToSqr(Ply:GetPos()) < MutterRangeSqr then
                self:SayGroup("Mutter", MoodSad, nil)
                return
            end
        end
    end

    function ENT:VisitorThink(Now)
        if self.Wrath ~= nil then return end

        local Visitor = self.Visitor

        if Visitor == nil then
            if self.Chat == nil then self:MutterThink(Now) end

            if Now < self.NextNotice then return end
            self.NextNotice = Now + 0.5

            local Found = self:FindNewVisitor()
            if Found ~= nil then self:BeginVisit(Found, Now) end
            return
        end

        if not IsValid(Visitor) or not Visitor:Alive() then
            self:EndVisit(Now)
            return
        end

        if self:GetPos():DistToSqr(Visitor:GetPos()) > LeaveRangeSqr then
            self:EndVisit(Now)
            return
        end

        if self.Chat ~= nil then return end

        self:LureThink(Now, self:GetMemoryOrNew(Visitor))
    end

    -- ----------------------------------------------------------------------
    -- Общение между собой
    -- ----------------------------------------------------------------------

    function ENT:IsBuddyFree(Now)
        if self.Chat ~= nil then return false end
        if self.Wrath ~= nil then return false end
        if Now < self.BusyUntil then return false end

        return self:IsStill()
    end

    function ENT:FindBuddy(Now)
        local Center   = self:WorldSpaceCenter()
        local Birds    = ents.FindByClass(ClassName)
        local Best     = nil
        local BestDist = BuddyRangeSqr

        for i = 1, #Birds do
            local Other = Birds[i]

            if Other ~= self and Other.Memory ~= nil and Other:IsBuddyFree(Now) then
                local Dist = Center:DistToSqr(Other:WorldSpaceCenter())

                if Dist < BestDist and self:CanSeeBird(Other) then
                    Best     = Other
                    BestDist = Dist
                end
            end
        end

        return Best
    end

    function ENT:BeginBuddyChat(Other, Now)
        local Lines = PickBuddyDialogue()
        if Lines == nil then return end

        local State = {
            ["A"]     = self,
            ["B"]     = Other,
            ["Lines"] = Lines,
            ["Index"] = 1,
            ["Next"]  = Now + 0.8
        }

        self.Chat  = State
        Other.Chat = State
    end

    function ENT:EndBuddyChat(Chat, Now)
        local A = Chat.A
        local B = Chat.B

        if IsValid(A) and A.Chat == Chat then
            A.Chat      = nil
            A.NextBuddy = Now + math.Rand(BuddyDelayMin, BuddyDelayMax)
        end

        if IsValid(B) and B.Chat == Chat then
            B.Chat      = nil
            B.NextBuddy = Now + math.Rand(BuddyDelayMin, BuddyDelayMax)
        end
    end

    function ENT:BuddyChatBroken(Other)
        if not IsValid(Other) then return true end
        if self.Wrath ~= nil then return true end
        if Other.Wrath ~= nil then return true end
        if not self:IsStill() then return true end
        if not Other:IsStill() then return true end
        if self:GetPos():DistToSqr(Other:GetPos()) > BuddyDropRangeSqr then return true end

        return false
    end

    function ENT:BuddyChatThink(Chat, Now)
        if Chat.A ~= self then
            if not IsValid(Chat.A) or Chat.A.Chat ~= Chat then self.Chat = nil end
            return
        end

        local Other = Chat.B

        if self:BuddyChatBroken(Other) then
            self:EndBuddyChat(Chat, Now)
            return
        end

        if Chat.Index > #Chat.Lines then
            if Now >= Chat.Next then self:EndBuddyChat(Chat, Now) end
            return
        end

        if Now < Chat.Next then return end

        local Speaker = self
        if Chat.Index % 2 == 0 then Speaker = Other end

        local Line = Chat.Lines[Chat.Index]
        local Mood = MoodSad
        if string.sub(Line, -1) == "?" then Mood = MoodLure end

        local Duration = Speaker:Say(Line, Mood, nil)

        Chat.Index = Chat.Index + 1
        Chat.Next  = Now + math.max(Duration, 1) + BuddyLinePause
    end

    function ENT:BuddyThink(Now)
        local Chat = self.Chat

        if Chat ~= nil then
            self:BuddyChatThink(Chat, Now)
            return
        end

        if Now < self.NextBuddy then return end
        self.NextBuddy = Now + BuddyRetry

        if not self:IsBuddyFree(Now) then return end

        local Other = self:FindBuddy(Now)
        if Other == nil then return end

        local Chance = BuddyAloneChance
        if self.Visitor ~= nil then Chance = BuddyPlayerChance end

        if math.random() > Chance then
            self.NextBuddy = Now + math.Rand(BuddyMissMin, BuddyMissMax)
            return
        end

        self:BeginBuddyChat(Other, Now)
    end

    function ENT:LeaveBuddy()
        local Chat = self.Chat
        if Chat == nil then return end

        local Other = Chat.A
        if Other == self then Other = Chat.B end

        self.Chat = nil

        if IsValid(Other) and Other.Chat == Chat then
            Other.Chat      = nil
            Other.NextBuddy = CurTime() + math.Rand(BuddyDelayMin, BuddyDelayMax)
        end

        if ShuttingDown then return end
        if not IsValid(Other) then return end

        Other:Say(PickLine("BuddyGone", nil), MoodSad, nil)
    end

    -- ----------------------------------------------------------------------
    -- Взаимодействие
    -- ----------------------------------------------------------------------

    function ENT:UseTalk(Activator, Caller, Pet)
        if not IsValid(Activator) or not Activator:IsPlayer() then return end
        if IsAiDisabled() then return end
        if self.Memory == nil then self:InitState() end
        if self.Wrath ~= nil then return end

        local Now = CurTime()
        local Mem = self:GetMemoryOrNew(Activator)

        if Now - Mem.LastUse < SpamWindow then
            Mem.Spam = Mem.Spam + 1
        else
            Mem.Spam = math.max(Mem.Spam - 1, 0)
        end
        Mem.LastUse = Now

        if Mem.Spam >= SpamLimit then
            Mem.Spam = 0
            self:AddAnger(Activator, 8, "Annoyed")
            return
        end

        if Now < self.BusyUntil then return end

        if self.Chat ~= nil then self:EndBuddyChat(self.Chat, Now) end
        
        if Mem.Anger >= AngerSulk and not Pet then
            self:SayGroup("Sulk", MoodOffended, Activator)
            return
        end

        self:TakeVisitor(Activator)
        self.VisitTalked = true
        self.VisitParted = false
        self.IdleSaid    = false

        Mem.LastTalk = Now
        Mem.Talks    = Mem.Talks + 1
        Mem.Trust    = Mem.Trust + 1

        if Pet then
            Mem.Trust    = Mem.Trust + 1
            Mem.Anger    = math.max(Mem.Anger - 15, 0)
            Mem.Offended = false
            if Mem.Anger < AngerSulk then Mem.Warned = false end

            self:SayGroup("Pet", MoodHappy, Activator)
            return
        end

        self:SayTalk(Activator, Mem)
    end

    function ENT:Heard(Ply, Text)
        if IsAiDisabled() then return end
        if self.Memory == nil then self:InitState() end
        if not Ply:Alive() then return end

        local First = string.sub(Text, 1, 1)
        if First == "!" or First == "/" then return end

        local Data  = GetTalkData()
        local Topic = nil

        if Data ~= nil then
            local Ok, Lower = pcall(LowerText, Text)
            if not Ok then Lower = string.lower(Text) end

            Topic = FindTopic(Data.Topics, Lower)
        end

        if self.Wrath ~= nil then
            if self.Wrath.Target ~= Ply then return end
            if Topic == nil or (Topic.Anger or 0) >= 0 then return end

            if math.random() < ApologyChance then
                self:EndWrath("Forgiven")
            else
                self:SayGroup("TooLate", MoodAngry, Ply)
            end
            return
        end

        timer.Simple(math.Rand(0.7, 1.4), function()
            if not IsValid(self) or not IsValid(Ply) then return end
            self:Reply(Ply, Topic)
        end)
    end

    function ENT:Reply(Ply, Topic)
        if self.Wrath ~= nil then return end
        if not Ply:Alive() then return end

        local Now = CurTime()
        local Mem = self:GetMemoryOrNew(Ply)
        if self.Chat ~= nil then self:EndBuddyChat(self.Chat, Now) end

        self:TakeVisitor(Ply)
        self.VisitTalked = true
        self.VisitParted = Topic ~= nil and Topic.Parting == true
        self.IdleSaid    = false

        Mem.LastTalk = Now
        Mem.Talks    = Mem.Talks + 1

        if Topic == nil then
            if Mem.Anger >= AngerSulk then
                self:SayGroup("Sulk", MoodOffended, Ply)
                return
            end

            self:SayGroup("Unknown", MoodSad, Ply)
            return
        end

        local TopicAnger = Topic.Anger or 0

        if TopicAnger > 0 then
            self.NextReact = 0
            self:AddAnger(Ply, TopicAnger, Topic.Group)
            return
        end

        if TopicAnger < 0 then
            Mem.Anger    = math.max(Mem.Anger + TopicAnger, 0)
            Mem.Offended = false
            if Mem.Anger < AngerSulk then Mem.Warned = false end

            self:SayGroup(Topic.Group, MoodHappy, Ply)
            return
        end

        if Mem.Anger >= AngerSulk then
            self:SayGroup("Sulk", MoodOffended, Ply)
            return
        end

        self:SayGroup(Topic.Group, MoodSad, Ply)
    end

    function ENT:Offend(Ply, Kind)
        local Offence = Offences[Kind]
        if Offence == nil then
            print("[GMM] CRYBIRD OFFENCE NOT FOUND! KIND: " .. tostring(Kind))
            return
        end

        if not IsValid(Ply) then return end
        if self.Memory == nil then self:InitState() end

        local Now = CurTime()
        local Mem = self:GetMemoryOrNew(Ply)

        if Now < Mem.NextOffence then return end
        Mem.NextOffence = Now + OffenceDelay

        self:AddAnger(Ply, Offence.Anger, Offence.Group)
    end

    function ENT:OnTakeDamage(Dmg)
        if self.Memory == nil then self:InitState() end

        local Amount = Dmg:GetDamage()
        if Amount < 1 then return end

        local Attacker = Dmg:GetAttacker()
        local Culprit  = self.Visitor
        if IsValid(Attacker) and Attacker:IsPlayer() then Culprit = Attacker end

        self:EmitSound("physics/glass/glass_impact_bullet" .. math.random(1, 4) .. ".wav", 65, math.random(140, 170))
        self:AddAnger(Culprit, math.Clamp(Amount * 1.5, 8, 40), "Hurt")
    end

    -- ----------------------------------------------------------------------
    -- Злость
    -- ----------------------------------------------------------------------

    function ENT:AddAnger(Ply, Amount, GroupName)
        if IsAiDisabled() then return end
        if self.Memory == nil then self:InitState() end

        local Now = CurTime()

        if not IsValid(Ply) then
            if Now < self.NextReact then return end
            self.NextReact = Now + ReactDelay

            self:SayGroup(GroupName, MoodAngry, nil)
            return
        end

        local Mem = self:GetMemoryOrNew(Ply)
        Mem.Anger = math.Clamp(Mem.Anger + Amount, 0, AngerMax)

        if self.Wrath ~= nil then return end

        if Mem.Anger >= AngerMax then
            self:StartWrath(Ply, Now)
            return
        end

        if Now < self.NextReact then return end
        self.NextReact = Now + ReactDelay

        if Mem.Anger >= AngerWarn and not Mem.Warned then
            Mem.Warned = true
            self:SayGroup("Warn", MoodAngry, Ply)
            return
        end

        self:SayGroup(GroupName, MoodAngry, Ply)
    end

    function ENT:DecayAnger(Delta)
        for Ply, Mem in pairs(self.Memory) do
            local IsTarget = self.Wrath ~= nil and self.Wrath.Target == Ply

            if Mem.Anger > 0 and not IsTarget then
                Mem.Anger = math.max(Mem.Anger - AngerDecay * Delta, 0)
                if Mem.Anger < AngerSulk then Mem.Warned = false end
            end
        end
    end

    function ENT:StartWrath(Ply, Now)
        self.Wrath = {
            ["Target"]   = Ply,
            ["Start"]    = Now,
            ["NextTick"] = Now + 1,
            ["Ticks"]    = 0
        }

        self.Visitor     = nil
        self.VisitTalked = false
        self.NextReact   = 0
        self.MoodUntil   = Now + WrathDuration + 10

        self:SetMood(MoodAngry)
        self:SayGroup("Wrath", MoodAngry, Ply)
        self:EmitSound("ambient/wind/windgust_strong.wav", 80, 100)
        util.ScreenShake(self:GetPos(), 4, 20, 1, 500)
    end

    function ENT:EndWrath(Reason)
        local State = self.Wrath
        if State == nil then return end

        self.Wrath = nil

        local Now    = CurTime()
        local Target = State.Target

        self.Visitor     = nil
        self.VisitTalked = false
        self.NextNotice  = Now + 6
        self.MoodUntil   = Now

        if not IsValid(Target) then return end

        local Mem = self:GetMemoryOrNew(Target)

        if Reason == "Killed" then
            Mem.Kills = Mem.Kills + 1
            Mem.Anger = 30
            self:SayGroup("Kill", MoodSad, Target)
        elseif Reason == "Escaped" then
            Mem.Anger  = AngerWarn
            Mem.Warned = true
            self:SayGroup("Escaped", MoodOffended, Target)
        elseif Reason == "Forgiven" then
            Mem.Anger    = AngerSulk - 5
            Mem.Warned   = false
            Mem.Offended = false
            self:SayGroup("Forgiven", MoodHappy, Target)
        end
    end

    function ENT:WrathThink(Now)
        local State = self.Wrath
        if State == nil then return end

        local Target = State.Target

        if not IsValid(Target) then
            self:EndWrath("Lost")
            return
        end

        if not Target:Alive() then
            self:EndWrath("Killed")
            return
        end

        if Now < State.NextTick then return end
        State.NextTick = Now + WrathTick
        State.Ticks    = State.Ticks + 1

        if self:GetPos():DistToSqr(Target:GetPos()) > WrathRangeSqr then
            self:EndWrath("Escaped")
            return
        end

        if not self:CanSee(Target) then
            self:EndWrath("Escaped")
            return
        end

        Target:ViewPunch(Angle(math.Rand(-3, 3), math.Rand(-3, 3), math.Rand(-4, 4)))

        if State.Ticks % 4 == 0 then self:SayGroup("WrathLine", MoodAngry, Target) end

        local Power = WrathCold
        if Now - State.Start >= WrathDuration then Power = WrathFinishCold end

        GMM_S.Func.FreezeEntity(Target, Power, self)
    end

    -- ----------------------------------------------------------------------

    function ENT:MoodThink(Now)
        if self.Wrath ~= nil then return end
        if Now < self.MoodUntil then return end

        if self:GetMood() ~= MoodSad then self:SetMood(MoodSad) end
    end

    function ENT:Think()
        local Now = CurTime()
        self:NextThink(Now + ThinkDelay)

        if self.Memory == nil then self:InitState() end

        if IsAiDisabled() then
            if self.Wrath ~= nil then self:EndWrath("Silent") end
            if self.Chat ~= nil then self:EndBuddyChat(self.Chat, Now) end
            return true
        end

        local Delta = Now - self.LastThink
        self.LastThink = Now

        self:DecayAnger(Delta)
        self:WrathThink(Now)
        self:VisitorThink(Now)
        self:BuddyThink(Now)
        self:MoodThink(Now)

        return true
    end

    -- ----------------------------------------------------------------------
    -- Прощание
    -- ----------------------------------------------------------------------

    function ENT:SayFarewell()
        local Text = PickLine("Farewell", nil)
        if Text == nil then return end

        local Pos     = self:GetPos()
        local _, Maxs = self:WorldSpaceAABB()
        local Top     = Vector(Pos.x, Pos.y, Maxs.z)

        sound.Play("npc/headcrab/pain" .. math.random(1, 3) .. ".wav", Pos, 60, math.random(170, 210), 0.4)

        for _, Ply in ipairs(player.GetAll()) do
            if Pos:DistToSqr(Ply:GetPos()) < FarewellRangeSqr then
                net.Start("gmm_CryBirdFarewell")
                net.WriteVector(Top)
                net.WriteString(Text)
                net.WriteUInt(MoodSad, 3)
                net.Send(Ply)
            end
        end
    end

    function ENT:OnRemove()
        local Wrathful = self.Wrath ~= nil

        self:LeaveBuddy()

        if ShuttingDown then return end
        if Wrathful then return end
        if self.Memory == nil then return end
        if IsAiDisabled() then return end

        self:SayFarewell()
    end

    -- ----------------------------------------------------------------------
    -- Хуки
    -- ----------------------------------------------------------------------

    hook.Add("ShutDown", "gmm_CryBird_ShutDown", function()
        ShuttingDown = true
    end)

    hook.Add("PlayerSay", "gmm_CryBird_Say", function(Ply, Text)
        if not IsValid(Ply) then return end

        local Pos = Ply:GetPos()

        for _, Bird in ipairs(ents.FindByClass(ClassName)) do
            if Bird:GetPos():DistToSqr(Pos) < ChatRangeSqr then Bird:Heard(Ply, Text) end
        end
    end)

    hook.Add("PhysgunPickup", "gmm_CryBird_Physgun", function(Ply, Ent)
        if not IsValid(Ent) or not Ent.IsGMMCryBird then return end

        Ent.Holder = Ply
        Ent:Offend(Ply, "Pickup")
    end)

    hook.Add("GravGunOnPickedUp", "gmm_CryBird_GravPickup", function(Ply, Ent)
        if not IsValid(Ent) or not Ent.IsGMMCryBird then return end

        Ent.Holder = Ply
        Ent:Offend(Ply, "Pickup")
    end)

    hook.Add("GravGunPunt", "gmm_CryBird_GravPunt", function(Ply, Ent)
        if IsValid(Ent) and Ent.IsGMMCryBird then Ent:Offend(Ply, "Punt") end
    end)

    hook.Add("CanTool", "gmm_CryBird_Tool", function(Ply, Trace)
        local Ent = Trace.Entity
        if IsValid(Ent) and Ent.IsGMMCryBird then Ent:Offend(Ply, "Tool") end
    end)

    hook.Add("PlayerSwitchFlashlight", "gmm_CryBird_Flashlight", function(Ply, Enabled)
        if not Enabled then return end

        local Eye = Ply:EyePos()
        local Dir = Ply:GetAimVector()

        for _, Bird in ipairs(ents.FindByClass(ClassName)) do
            local To      = Bird:WorldSpaceCenter() - Eye
            local DistSqr = To:LengthSqr()

            if DistSqr < FlashRangeSqr and To:GetNormalized():Dot(Dir) > 0.9 then Bird:Offend(Ply, "Flashlight") end
        end
    end)

    -- ----------------------------------------------------------------------
    -- Подъём, поворот, ходьба
    -- ----------------------------------------------------------------------

    local FollowRange    = 1000
    local WatchRange     = 2500
    local WalkStopDist   = 90
    local WalkSpeed      = 70
    local TurnSpeed      = 140
    local YawOffset      = 0
    local WatchDot       = 0.5
    local WatchDelay     = 0.1
    local StepUp         = 8
    local StepDown       = 24
    local SettleReach    = 40
    local SettleSeconds  = 0.6
    local SettleMax      = 6
    local SettleSpeedSqr = 25

    local FollowRangeSqr = FollowRange * FollowRange
    local WatchRangeSqr  = WatchRange * WatchRange
    local WalkStopSqr    = WalkStopDist * WalkStopDist

    local FloorStart  = Vector()
    local FloorEnd    = Vector()
    local FloorResult = {}
    local FloorData   = {start = FloorStart, endpos = FloorEnd, mask = MASK_SOLID, output = FloorResult}

    local WalkPos    = Vector()
    local HullResult = {}
    local HullData   = {endpos = WalkPos, mask = MASK_SOLID, output = HullResult}

    local ViewFilter = {}
    local ViewResult = {}
    local ViewData   = {mask = MASK_OPAQUE, filter = ViewFilter, output = ViewResult}

    local function FindFloorZ(Ent, X, Y, FeetZ, Up, Down)
        FloorStart.x = X
        FloorStart.y = Y
        FloorStart.z = FeetZ + Up

        FloorEnd.x = X
        FloorEnd.y = Y
        FloorEnd.z = FeetZ - Down

        FloorData.filter = Ent
        util.TraceLine(FloorData)

        if FloorResult.StartSolid then return nil end
        if not FloorResult.Hit then return nil end

        return FloorResult.HitPos.z
    end

    local function IsWatchedBy(Ent, Ply, Center)
        local Eye  = Ply:EyePos()
        local Dir  = Center - Eye
        local Dist = Dir:Length()

        if Dist < 1 then return true end

        Dir:Div(Dist)
        if Ply:GetAimVector():Dot(Dir) < WatchDot then return false end

        ViewFilter[1] = Ply
        ViewFilter[2] = Ent
        ViewData.start  = Eye
        ViewData.endpos = Center
        util.TraceLine(ViewData)

        if not ViewResult.Hit then return true end

        return false
    end

    function ENT:CacheBounds()
        if self.WalkMins ~= nil then return end

        local Mins   = self:OBBMins()
        local Maxs   = self:OBBMaxs()
        local Radius = math.max(Maxs.x, -Mins.x, Maxs.y, -Mins.y)

        self.WalkMins     = Mins
        self.WalkHullMins = Vector(-Radius, -Radius, Mins.z + StepUp)
        self.WalkHullMaxs = Vector(Radius, Radius, Maxs.z)
    end

    function ENT:PickUp(Ply)
        local Phys = self:GetPhysicsObject()
        if not IsValid(Phys) then return end

        self.SettleStart = nil
        self.SettleSince = nil
        self.Holder      = Ply

        Phys:EnableMotion(true)
        Phys:Wake()
        Ply:PickupObject(self)

        self:Offend(Ply, "Pickup")
    end

    function ENT:Use(Activator, Caller)
        if not IsValid(Activator) or not Activator:IsPlayer() then return end

        if Activator:KeyDown(IN_SPEED) then
            self:UseTalk(Activator, Caller, true)
            return
        end

        if Activator:KeyDown(IN_WALK) then
            self:UseTalk(Activator, Caller, false)
            return
        end

        self:PickUp(Activator)
    end

    function ENT:FreezeUpright(Phys)
        self.SettleStart = nil
        self.SettleSince = nil

        self:CacheBounds()

        local Pos = self:GetPos()
        local Ang = self:GetAngles()
        Ang.p = 0
        Ang.r = 0

        local FloorZ = FindFloorZ(self, Pos.x, Pos.y, Pos.z + self.WalkMins.z, SettleReach, SettleReach)
        if FloorZ == nil then return end

        Phys:EnableMotion(false)

        Pos.z = FloorZ - self.WalkMins.z
        self:SetAngles(Ang)
        self:SetPos(Pos)

        self.Holder = nil
    end

    function ENT:HoldThink(Phys, Now)
        if self:IsPlayerHolding() then
            self.WasHeld    = true
            self.ThrowUntil = nil
            return
        end

        if self.WasHeld then
            self.WasHeld    = false
            self.ThrowUntil = Now + ThrowWatch
            self.ThrowBy    = self.Holder
        end

        local Until = self.ThrowUntil
        if Until == nil then return end

        if Now > Until or not IsValid(self.ThrowBy) then
            self.ThrowUntil = nil
            return
        end

        if Phys:GetVelocity():LengthSqr() < ThrowSpeedSqr then return end

        self.ThrowUntil = nil
        self:Offend(self.ThrowBy, "Throw")
    end

    function ENT:SettleThink(Phys, Now)
        if self:IsPlayerHolding() then
            self.SettleStart = nil
            self.SettleSince = nil
            return
        end

        if self.SettleStart == nil then self.SettleStart = Now end

        local Still = Phys:GetVelocity():LengthSqr() < SettleSpeedSqr and Phys:GetAngleVelocity():LengthSqr() < SettleSpeedSqr
        if not Still then
            self.SettleSince = nil
        elseif self.SettleSince == nil then
            self.SettleSince = Now
        end

        local Calm    = self.SettleSince ~= nil and Now - self.SettleSince >= SettleSeconds
        local Timeout = Now - self.SettleStart >= SettleMax
        if not Calm and not Timeout then return end

        self:FreezeUpright(Phys)
    end

    function ENT:UpdateWatch(Birds)
        local Center    = self:WorldSpaceCenter()
        local Players   = player.GetAll()
        local Target    = nil
        local TargetSqr = FollowRangeSqr
        local Watched   = false

        for i = 1, #Players do
            local Ply = Players[i]

            if Ply:Alive() then
                local DistSqr = Center:DistToSqr(Ply:GetPos())

                if DistSqr < TargetSqr then
                    Target    = Ply
                    TargetSqr = DistSqr
                end

                if not Watched and DistSqr < WatchRangeSqr and IsWatchedBy(self, Ply, Center) then
                    Watched = true
                end
            end
        end

        local Buddy    = nil
        local BuddySqr = BuddyLookRangeSqr

        for i = 1, #Birds do
            local Other = Birds[i]

            if Other ~= self then
                local DistSqr = Center:DistToSqr(Other:GetPos())

                if DistSqr < BuddySqr then
                    Buddy    = Other
                    BuddySqr = DistSqr
                end
            end
        end

        self.FollowTarget = Target
        self.BuddyBird    = Buddy
        self.Watched      = Watched
    end

    function ENT:WalkTick(Now, Delta, Birds)
        local Phys = self:GetPhysicsObject()
        if not IsValid(Phys) then return end

        if Phys:IsMotionEnabled() then
            self:HoldThink(Phys, Now)
            self:SettleThink(Phys, Now)
            return
        end

        if self:IsPlayerHolding() then return end
        if IsAiDisabled() then return end

        if Now >= (self.NextWatch or 0) then
            self.NextWatch = Now + WatchDelay
            self:UpdateWatch(Birds)
        end

        local LookPos = nil
        local CanWalk = false
        local Chat    = self.Chat

        if Chat ~= nil then
            local Partner = Chat.A
            if Partner == self then Partner = Chat.B end

            if IsValid(Partner) then LookPos = Partner:GetPos() end
        end

        if LookPos == nil then
            local Target = self.FollowTarget

            if IsValid(Target) and Target:Alive() then
                LookPos = Target:GetPos()
                CanWalk = true
            end
        end

        if LookPos == nil then
            local Buddy = self.BuddyBird
            if IsValid(Buddy) then LookPos = Buddy:GetPos() end
        end

        if LookPos == nil then return end

        self:CacheBounds()

        local Pos      = self:GetPos()
        local ToLook   = LookPos - Pos
        local Ang      = self:GetAngles()
        local WantYaw  = math.deg(math.atan2(ToLook.y, ToLook.x)) + YawOffset
        local Yaw      = math.ApproachAngle(Ang.y, WantYaw, TurnSpeed * Delta)

        if Yaw ~= Ang.y then
            Ang.y = Yaw
            self:SetAngles(Ang)
        end

        if not CanWalk then return end
        if self.Watched then return end

        local DistSqr = ToLook.x * ToLook.x + ToLook.y * ToLook.y
        if DistSqr < WalkStopSqr then return end

        local Step = WalkSpeed * Delta / math.sqrt(DistSqr)
        local NewX = Pos.x + ToLook.x * Step
        local NewY = Pos.y + ToLook.y * Step

        local FloorZ = FindFloorZ(self, NewX, NewY, Pos.z + self.WalkMins.z, StepUp, StepDown)
        if FloorZ == nil then return end

        WalkPos.x = NewX
        WalkPos.y = NewY
        WalkPos.z = FloorZ - self.WalkMins.z

        HullData.start  = Pos
        HullData.mins   = self.WalkHullMins
        HullData.maxs   = self.WalkHullMaxs
        HullData.filter = self
        util.TraceHull(HullData)

        if HullResult.Hit then return end

        self:SetPos(WalkPos)
    end

    hook.Add("Tick", "gmm_CryBird_Walk", function()
        local Birds = ents.FindByClass(ClassName)
        local Count = #Birds
        if Count == 0 then return end

        local Now   = CurTime()
        local Delta = engine.TickInterval()

        for i = 1, Count do
            Birds[i]:WalkTick(Now, Delta, Birds)
        end
    end)
end

-- ----------------------------------------------------------------------
-- Клиент
-- ----------------------------------------------------------------------

if CLIENT then
    local ParticleDelay = 0.25
    local ParticleRange    = 1500
    local LightRange       = 900
    local ParticleRangeSqr = ParticleRange * ParticleRange
    local LightRangeSqr    = LightRange * LightRange

    local SayNearDist = 600
    local SayFarDist  = 1000
    local SayMaxWidth = 400
    local SayScale    = 0.12
    local SayFont     = "gmm_CryBirdSay"
    local SayLift     = 8

    local GhostMax = 16

    local BoundsPadLow  = Vector(40, 40, 0)
    local BoundsPadHigh = Vector(40, 40, 70)

    local PosTemp   = Vector()
    local VelTemp   = Vector()
    local GhostPos  = Vector()

    local Ghosts = {}

    local ColorChatText = Color(230, 230, 235)

    surface.CreateFont(SayFont, {
        font     = "Consolas",
        size     = 28,
        weight   = 700,
        extended = true,
        antialias = true
    })

    local function MakeMood(Rate, Speed, Rise, Size, Life, R, G, B, TR, TG, TB)
        return {
            Rate    = Rate,
            Speed   = Speed,
            Gravity = Vector(0, 0, Rise),
            Size    = Size,
            Life    = Life,
            R       = R,
            G       = G,
            B       = B,
            TR      = TR,
            TG      = TG,
            TB      = TB,
            Col     = Color(TR, TG, TB)
        }
    end

    local Moods = {
        [MoodSad]      = MakeMood(4,  14,  -22, 3, 3.2, 190, 225, 255, 150, 200, 255),
        [MoodLure]     = MakeMood(6,  20,   10, 3, 3.0, 220, 240, 255, 210, 235, 255),
        [MoodOffended] = MakeMood(2,  8,   -35, 3, 3.5, 170, 180, 215, 190, 170, 220),
        [MoodAngry]    = MakeMood(25, 130,  -5, 4, 1.8, 255, 190, 190, 255,  70,  70),
        [MoodHappy]    = MakeMood(7,  22,   25, 3, 2.8, 255, 255, 255, 255, 235, 170)
    }

    local function WrapText(Text, MaxWidth)
        surface.SetFont(SayFont)

        local Lines = {}
        local Line  = ""

        for Word in string.gmatch(Text, "%S+") do
            local Test = Word
            if Line ~= "" then Test = Line .. " " .. Word end

            local Width = surface.GetTextSize(Test)
            if Width > MaxWidth and Line ~= "" then
                Lines[#Lines + 1] = Line
                Line = Word
            else
                Line = Test
            end
        end

        if Line ~= "" then Lines[#Lines + 1] = Line end
        return Lines
    end

    local function MeasureText(Text)
        local Lines = WrapText(Text, SayMaxWidth)

        surface.SetFont(SayFont)

        local Widths = {}
        for Index, Line in ipairs(Lines) do
            Widths[Index] = surface.GetTextSize(Line)
        end

        local _, LineH = surface.GetTextSize("A")

        return Lines, Widths, LineH
    end

    local function DrawBubble(DrawPos, Ang, Lines, Widths, LineH, Info, Alpha, Shake)
        local Total = #Lines * LineH

        cam.Start3D2D(DrawPos, Ang, SayScale)
        surface.SetFont(SayFont)

        for Index, Line in ipairs(Lines) do
            local X = -Widths[Index] / 2 + Shake
            local Y = -Total + (Index - 1) * LineH

            surface.SetTextColor(0, 0, 0, Alpha * 0.8)
            surface.SetTextPos(X + 2, Y + 2)
            surface.DrawText(Line)

            surface.SetTextColor(Info.TR, Info.TG, Info.TB, Alpha)
            surface.SetTextPos(X, Y)
            surface.DrawText(Line)
        end

        cam.End3D2D()
    end

    net.Receive("gmm_CryBirdChat", function()
        local Text = net.ReadString()
        local Info = Moods[net.ReadUInt(3)] or Moods[MoodSad]

        chat.AddText(Info.Col, "CRYBIRD: ", ColorChatText, Text)
    end)

    net.Receive("gmm_CryBirdFarewell", function()
        local Pos  = net.ReadVector()
        local Text = net.ReadString()
        local Info = Moods[net.ReadUInt(3)] or Moods[MoodSad]

        chat.AddText(Info.Col, "CRYBIRD: ", ColorChatText, Text)

        local Lines, Widths, LineH = MeasureText(Text)
        local Length = utf8.len(Text) or #Text

        if #Ghosts >= GhostMax then table.remove(Ghosts, 1) end

        Ghosts[#Ghosts + 1] = {
            ["Pos"]      = Pos,
            ["Start"]    = CurTime(),
            ["Duration"] = math.Clamp(2.5 + Length * 0.09, 3, 12),
            ["Lines"]    = Lines,
            ["Widths"]   = Widths,
            ["LineH"]    = LineH,
            ["Info"]     = Info
        }
    end)

    hook.Add("PostDrawTranslucentRenderables", "gmm_CryBird_Ghost", function(Depth, Skybox)
        if Skybox then return end

        local Count = #Ghosts
        if Count == 0 then return end

        local Ply = LocalPlayer()
        if not IsValid(Ply) then return end

        local Now = CurTime()
        local Ang = Angle(0, Ply:EyeAngles().y - 90, 90)

        for i = Count, 1, -1 do
            local Ghost    = Ghosts[i]
            local Age      = Now - Ghost.Start
            local Duration = Ghost.Duration

            if Age >= Duration then
                table.remove(Ghosts, i)
            else
                local Pos       = Ghost.Pos
                local Dist      = Pos:Distance(Ply:GetPos())
                local DistAlpha = 1 - math.Clamp((Dist - SayNearDist) / (SayFarDist - SayNearDist), 0, 1)

                if DistAlpha > 0.01 then
                    local FadeIn  = math.min(Age / 0.25, 1)
                    local FadeOut = math.min((Duration - Age) / 0.8, 1)
                    local Alpha   = math.floor(255 * math.min(FadeIn, FadeOut) * DistAlpha)
                    local Bob     = math.sin(Now * 1.5 + i)

                    GhostPos:SetUnpacked(Pos.x, Pos.y, Pos.z + SayLift + Bob)

                    DrawBubble(GhostPos, Ang, Ghost.Lines, Ghost.Widths, Ghost.LineH, Ghost.Info, Alpha, 0)
                end
            end
        end
    end)

    -- ----------------------------------------------------------------------

    function ENT:InitClient()
        local Mins, Maxs = self:GetModelBounds()

        self.Height      = math.max(Maxs.z * ModelScale, 10)
        self.Spread      = math.max(math.max(Maxs.x - Mins.x, Maxs.y - Mins.y) * ModelScale * 0.5, 5)
        self.ParticleAcc = 0
        self.SayBuiltId  = 0

        self:SetRenderBounds(Mins * ModelScale - BoundsPadLow, Maxs * ModelScale + BoundsPadHigh)
    end

    function ENT:Think()
        self:NextThink(CurTime() + ParticleDelay)

        if self.Height == nil then self:InitClient() end

        local Ply = LocalPlayer()
        if not IsValid(Ply) then return true end

        local Pos     = self:GetPos()
        local DistSqr = Pos:DistToSqr(Ply:GetPos())
        if DistSqr > ParticleRangeSqr then return true end

        local Mood = Moods[self:GetMood()] or Moods[MoodSad]

        if DistSqr < LightRangeSqr then
            local Light = DynamicLight(self:EntIndex())

            if Light then
                Light.Pos        = Pos + Vector(0, 0, self.Height * 0.5)
                Light.r          = Mood.R
                Light.g          = Mood.G
                Light.b          = Mood.B
                Light.Brightness = 1
                Light.Size       = 110
                Light.Decay      = 800
                Light.DieTime    = CurTime() + 0.3
            end
        end

        -- Считаем по реальному времени, а не по тикам
        local Now = CurTime()
        local Last = self.ParticleLast or Now
        self.ParticleLast = Now

        local Dt = math.min(Now - Last, 0.25)   -- защита от больших скачков
        self.ParticleAcc = self.ParticleAcc + Mood.Rate * Dt

        local Count = math.floor(self.ParticleAcc)
        self.ParticleAcc = self.ParticleAcc - Count
        if Count < 1 then return true end

        if self.Emitter == nil then self.Emitter = ParticleEmitter(Pos, false) end

        local Emitter = self.Emitter
        local Spread  = self.Spread
        local Height  = self.Height
        local Speed   = Mood.Speed

        for i = 1, Count do
            PosTemp:SetUnpacked(Pos.x + math.Rand(-Spread, Spread), Pos.y + math.Rand(-Spread, Spread), Pos.z + math.Rand(0, Height))

            local Particle = Emitter:Add("woowz_map/gm_garrymod_map_by_woowz_map_garry_game/particle/snowflake", PosTemp)

            if Particle ~= nil then
                local Size = math.Rand(Mood.Size * 0.2, Mood.Size * 0.5)

                VelTemp:SetUnpacked(math.Rand(-Speed, Speed), math.Rand(-Speed, Speed), math.Rand(-Speed * 0.3, Speed * 0.3))

                Particle:SetVelocity(VelTemp)
                Particle:SetGravity(Mood.Gravity)
                Particle:SetAirResistance(100)
                Particle:SetDieTime(math.Rand(Mood.Life * 2, Mood.Life * 4))
                Particle:SetStartAlpha(255)
                Particle:SetEndAlpha(0)
                Particle:SetStartSize(Size * 0.1)
                Particle:SetEndSize(Size)
                Particle:SetRoll(math.Rand(0, 360))
                Particle:SetRollDelta(math.Rand(-2, 2))
                Particle:SetColor(Mood.R, Mood.G, Mood.B)
                Particle:SetCollide(true)
            end
        end

        return true
    end

    function ENT:OnRemove()
        if self.Emitter == nil then return end

        self.Emitter:Finish()
        self.Emitter = nil
    end

    function ENT:BuildSay(Id)
        local Lines, Widths, LineH = MeasureText(self:GetSayText())

        self.SayBuiltId = Id
        self.SayLines   = Lines
        self.SayWidths  = Widths
        self.SayLineH   = LineH
        self.SayMood    = self:GetMood()
    end

    function ENT:DrawSay()
        local Id = self:GetSayId()
        if Id == 0 then return end

        local Now      = CurTime()
        local Age      = math.max(Now - self:GetSayStart(), 0)
        local Duration = self:GetSayDuration()
        if Age >= Duration then return end

        local Ply = LocalPlayer()
        if not IsValid(Ply) then return end

        local Pos       = self:GetPos()
        local Dist      = Pos:Distance(Ply:GetPos())
        local DistAlpha = 1 - math.Clamp((Dist - SayNearDist) / (SayFarDist - SayNearDist), 0, 1)
        if DistAlpha <= 0.01 then return end

        if Id ~= self.SayBuiltId then self:BuildSay(Id) end

        local FadeIn  = math.min(Age / 0.25, 1)
        local FadeOut = math.min((Duration - Age) / 0.5, 1)
        local Alpha   = math.floor(255 * math.min(FadeIn, FadeOut) * DistAlpha)

        local Mood  = Moods[self.SayMood] or Moods[MoodSad]
        local Shake = self.SayMood == MoodAngry and math.Rand(-1.5, 1.5) or 0
        local Bob   = math.sin(Now * 1.5 + self:EntIndex()) * 1

        local DrawPos = Pos + Vector(0, 0, self.Height + SayLift + Bob)
        local Ang     = Angle(0, Ply:EyeAngles().y - 90, 90)

        DrawBubble(DrawPos, Ang, self.SayLines, self.SayWidths, self.SayLineH, Mood, Alpha, Shake)
    end

    function ENT:Draw()
        self:DrawModel()
        self:DrawSay()
    end
end