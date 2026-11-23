AddCSLuaFile()

ENT.Type      = "anim"
ENT.Base      = "base_anim"
ENT.PrintName = "RAD-10"
ENT.Author    = "Woowz11"
ENT.Category  = "GMM"
ENT.Spawnable = GMM.Func.DoEntitiesUnlock()

ENT.IsGMMRadio = true

local BaseURL = "https://woowz11.github.io/woowzsite/"

local ControlCooldown = 0.2
local LookDist        = 250
local LookDistSqr     = LookDist * LookDist
local MenuDistance    = 350
local MenuDistanceSqr = MenuDistance * MenuDistance

local ModeOrder   = 0
local ModeShuffle = 1
local ModeRepeat  = 2
local ModeDefault = ModeOrder

local ModeNames = {[0] = "ORDER", [1] = "SHUFFLE", [2] = "REPEAT"}

local ActionPrev   = 1
local ActionToggle = 2
local ActionNext   = 3
local ActionMode   = 4
local ActionRandom = 5

local VariantMax = 6

local Variants = {
    [0] = {Key = "Normal",  Title = "STANDARD (?)", Weight = 70, Volume = 5,    Rate = 1,   Color = Color(235, 235, 240), Tint = Color(255, 255, 255)},
    [1] = {Key = "Loud",    Title = "LOUD",         Weight = 5,  Volume = 2000, Rate = 1,   Color = Color(255, 220, 40),  Tint = Color(255, 255, 0)},
    [2] = {Key = "Fast",    Title = "FAST x1.5",    Weight = 8,  Volume = 5,    Rate = 1.5, Color = Color(70, 255, 90),   Tint = Color(130, 255, 130)},
    [3] = {Key = "Slow",    Title = "SLOW x0.7",    Weight = 8,  Volume = 5,    Rate = 0.7, Color = Color(255, 60, 70),   Tint = Color(255, 110, 110)},
    [4] = {Key = "Stutter", Title = "DJ GOLUCUBE",  Weight = 4,  Volume = 5,    Rate = 1,   Color = Color(60, 150, 255),  Tint = Color(110, 160, 255)},
    [5] = {Key = "Warp",    Title = "~WARP~",       Weight = 5,  Volume = 5,    Rate = 1,   Color = Color(190, 90, 255),  Tint = Color(200, 130, 255)},
    [6] = {Key = "Chaos",   Title = "CACOPHONY",    Weight = 2,  Volume = 3,    Rate = 1,   Color = Color(235, 235, 240), Tint = Color(25, 25, 28)}
}

local function GetVariantDef(Index)
    return Variants[Index] or Variants[0]
end

local function RollVariant()
    local Total = 0
    for i = 0, VariantMax do
        Total = Total + Variants[i].Weight
    end

    local Roll = math.random() * Total
    for i = 0, VariantMax do
        Roll = Roll - Variants[i].Weight
        if Roll < 0 then return i end
    end

    return 0
end

local WoowzCoreTracks = {
    "source/woowzcore/musics/Avith Ortega - Dopamine for Her Professing - Edit",
    "source/woowzcore/musics/Avith Ortega - Leisure Time",
    "source/woowzcore/musics/EDARUMA - Recent Past",
    "source/woowzcore/musics/fadinglight - company",
    "source/woowzcore/musics/Glwzbll - GLW2000",
    "source/woowzcore/musics/latex fruit - Loveme2",
    "source/woowzcore/musics/Lemon Demon - Brodyquest",
    "source/woowzcore/musics/Seamoon - Six Synergies",
    "source/woowzcore/musics/Spatial Manufacture Ltd.",
    "source/woowzcore/musics/t e l e p a t h - track",
    "source/woowzcore/musics/Visonia - The Amethyst City",
    "source/woowzcore/musics/Visonia - The Moon Doesn't Want to Look at You",
    "source/woowzcore/musics/rodr1se - Hardstyle Drill 2009",
    "source/woowzcore/musics/Rory in early 20s - track",
    "source/woowzcore/musics/t e l e p a t h - track 2",
    "source/woowzcore/musics/t e l e p a t h - track 3",
    "source/woowzcore/musics/t e l e p a t h - track 4",
    "source/woowzcore/musics/T.G.T.B. - Derelict",
    "source/woowzcore/musics/Seamoon - Six Synergies",
    "source/woowzcore/musics/M4 Vaporwave - Murderer Star",
    "source/woowzcore/musics/mayten - self reflection",
    "source/woowzcore/musics/Nmesh - track",
    "source/woowzcore/musics/Oliver Buckland - espial",
    "source/woowzcore/musics/Oneheart - snowfall",
    "source/woowzcore/musics/permskiy krai - The Virus",
    "source/woowzcore/musics/Polligopkalo - bloodyangel.mp666",
    "source/woowzcore/musics/crossing bridges - Deep Under the Surface of Level 7",
    "source/woowzcore/musics/Cult Member - The Ravedeath Still Hurts",
    "source/woowzcore/musics/DJ DR4GM4SHROOM - INTERN3T EXPLOR3R",
    "source/woowzcore/musics/FM Skyline - body_texture render",
    "source/woowzcore/musics/FM Skyline - Harlequin",
    "source/woowzcore/musics/Harold Budd - LAventure",
    "source/woowzcore/musics/KISYZ - Six Forty Seven",
    "source/woowzcore/musics/Wayne Hill - Left Bank Two (Vision On Gallery Theme)",
    "source/woowzcore/musics/Whitewoods - Beat Street",
    "source/woowzcore/musics/Xxtarlit",
    "source/woowzcore/musics/yandere - dreamcore",
    "source/woowzcore/musics/Ray Lynch",
    "source/woowzcore/musics/alone land",
    "source/woowzcore/musics/Constant Smiles - Restlessness (I Dont Sleep Well)",
    "source/woowzcore/musics/Pathetic - escalator",
    "source/woowzcore/musics/Piers Baron - The Last Night on Earth",
    "source/woowzcore/musics/Rory in early 20s - track 2",
    "source/woowzcore/musics/rvfzme - Char",
    "source/woowzcore/musics/Snow Strippers - Fantasy",
    "source/woowzcore/musics/Snow Strippers - Wont Be Back Again",
    "source/woowzcore/musics/VHS Logos - Sony",
    "source/woowzcore/musics/Noisemaker - Magna Aliqua",
    "source/woowzcore/musics/Oliver Buckland - vacillate",
    "source/woowzcore/musics/Betatrip - useless",
    "source/woowzcore/musics/dxnrm - why i'm here",
    "source/woowzcore/musics/Lustre - Let Go Like Leaves of Fall",
    "source/woowzcore/musics/Marc Acardipane - Return to Zero Beztebya",
    "source/woowzcore/musics/Mietze Conte - d(-_-)b dreaming of your latte art d(-_-)b",
    "source/woowzcore/musics/Viselnik - Dying Nature",
    "source/woowzcore/musics/ZanZiglatore",
    "source/woowzcore/musics/Avith Ortega - Betrayal",
    "source/woowzcore/musics/Dargaard - Thy Fleeing Time",
    "source/woowzcore/musics/Green-House - Xylem",
    "source/woowzcore/musics/Molina - Hey Kids",
    "source/woowzcore/musics/Nmesh - track 2",
    "source/woowzcore/musics/naran ratan - Forevertime Journeys II",
    "source/woowzcore/musics/Oliver Buckland - backroom labyrinth",
    "source/woowzcore/musics/Oliver Buckland - Dead God Graveyard",
    "source/woowzcore/musics/Raymond Scott - Portofino 2",
    "source/woowzcore/musics/Robin Guthrie - Imperial",
    "source/woowzcore/musics/Sacre - An Ending (Arena Tv Series)",
    "source/woowzcore/musics/Ssaliva - Arrow",
    "source/woowzcore/musics/Dottie Evans - Tonight You Belong to Me",
    "source/woowzcore/musics/dxnrm - restless dreams",
    "source/woowzcore/musics/Grouper - Poison Tree",
    "source/woowzcore/musics/Kero Kero Bonito - I'd Rather Sleep",
    "source/woowzcore/musics/Lifeformed - Undiscovery",
    "source/woowzcore/musics/Lustre - Petrichor",
    "source/woowzcore/musics/Mild High Club - Homage",
    "source/woowzcore/musics/Art Fact - Whom Are You Dancing For_",
    "source/woowzcore/musics/crossing bridges - Lighters",
    "source/woowzcore/musics/crossing bridges - WaterWorld43",
    "source/woowzcore/musics/CXRGI - weeping (Slowed)",
    "source/woowzcore/musics/special/oldebr_music_0",
    "source/woowzcore/musics/special/oldebr_music_1",
    "source/woowzcore/musics/special/oldebr_music_2",
    "source/woowzcore/musics/special/oldebr_music_3",
    "source/woowzcore/musics/special/oldebr_music_4",
    "source/woowzcore/musics/special/oldebr_music_5",
    "source/woowzcore/musics/special/woowzcore_music",
    "source/woowzcore/musics/stvrshine - Constant Anxiety",
    "source/woowzcore/musics/TPFL - track",
    "source/woowzcore/musics/VAPERROR - Start Up",
    "source/woowzcore/musics/Yabujin - CHALICE OF MIND",
    "source/woowzcore/musics/LobotomyCorporation OST  - Second Warning",
    "source/woowzcore/musics/Mega Degrod - Xleepy",
    "source/woowzcore/musics/myxtica - Old Doll (out of tune) (slowed)",
    "source/woowzcore/musics/Paavoharju - Valo tihkuu kaiken lapi",
    "source/woowzcore/musics/Saul Stokes - Spirit Control",
    "source/woowzcore/musics/stvrshine - At the Speed of Light",
    "source/woowzcore/musics/Saul Stokes - The Telecine Ensemble",
    "source/woowzcore/musics/Blod Besvimelse - Misanthrop",
    "source/woowzcore/musics/Cult Member - U Weren't Here I Really Miss You",
    "source/woowzcore/musics/DXXDLY - Eerie",
    "source/woowzcore/musics/Mega Degrod - Athoth a go!! go!!!",
    "source/woowzcore/musics/Dargaard - The Infinite",
    "source/woowzcore/musics/Pye Corner Audio - Hollow Earth",
    "source/woowzcore/musics/Saul Stokes - Intra-Fantasy",

    "source/musica1",
    "source/musica2",

    "source/The Daniel Pemberton TV Orchestra - The Orb Of Dreamers",
    "source/bass",
    "source/sun",

    "source/specialforrandomsite/f5a28bef9f2a712",
    "source/specialforrandomsite/pern",
    "source/specialforrandomsite/WoowzMegaHit",
    "source/specialforrandomsite/TROLL_HIT_4",
    "source/specialforrandomsite/28_M_Necro",
    "source/specialforrandomsite/It's PINEAPPLE piizza tami(1)",
    "source/specialforrandomsite/寻梦高粱红",
    "source/specialforrandomsite/ВЫЙТИ НА УЛИЦУ ТАМ ЙОБАНЫ ЛОС",
    "source/specialforrandomsite/what-the-song1",
    "source/specialforrandomsite/spongebob-asking-are-you-pooping-made-with",
    "source/specialforrandomsite/spo",
    "source/specialforrandomsite/idiotic music",
    "source/specialforrandomsite/gabber.bootleg",
    "source/specialforrandomsite/Toilet-story",
    "source/specialforrandomsite/Qahwah.Bootleg (feat. ilyhiryu)",
    "source/specialforrandomsite/Mr. Trololo original upload",
    "source/specialforrandomsite/Morning-Flower",
    "source/specialforrandomsite/Cheetahmen",
    "source/specialforrandomsite/ai_music_hits_pro/+Echoes of Poolrooms alt+",
    "source/specialforrandomsite/ai_music_hits_pro/+Echoes of Poolrooms+",
    "source/specialforrandomsite/ai_music_hits_pro/+Silent Hallways+",
    "source/specialforrandomsite/ai_music_hits_pro/Белка на NASM",
    "source/specialforrandomsite/ai_music_hits_pro/Я ХОЧУ СТАТЬ ИГРОЙ",
    "source/specialforrandomsite/ai_music_hits_pro/СПАНЧ В ДУБАЙСКЕ",
    "source/specialforrandomsite/ai_music_hits_pro/Дей — злая обезьяна 2 (Танцуй, маппер!)",
}

local Tracks     = {}
local TrackNames = {}

local function EncodeUrlPath(Path)
    return (string.gsub(Path, "[^A-Za-z0-9%-_%.~/]", function(Char)
        return string.format("%%%02X", string.byte(Char))
    end))
end

do
    local Seen = {}

    for _, Name in ipairs(WoowzCoreTracks) do
        if not Seen[Name] then
            Seen[Name] = true

            Tracks    [#Tracks + 1]     = BaseURL .. EncodeUrlPath(Name) .. ".mp3"
            TrackNames[#TrackNames + 1] = string.match(Name, "([^/]+)$") or Name
        end
    end
end

function ENT:SetupDataTables()
    self:NetworkVar("Bool",  0, "Playing")
    self:NetworkVar("Bool",  1, "Init")

    self:NetworkVar("Int",   0, "TrackIndex")
    self:NetworkVar("Int",   1, "Variant")
    self:NetworkVar("Int",   2, "Mode")
    self:NetworkVar("Int",   3, "Session")

    self:NetworkVar("Float", 0, "PlayStart")
    self:NetworkVar("Float", 1, "PauseAt")
end

function ENT:Initialize()
    self:SetModel("models/props/cs_office/radio.mdl")

    self:PhysicsInit(SOLID_VPHYSICS   )
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid   (SOLID_VPHYSICS   )

    local PhysicsObject = self:GetPhysicsObject()
    if IsValid(PhysicsObject) then PhysicsObject:Wake() end

    self.PhysgunDisabled = self.m_PlayerCreator == nil

    if SERVER then
        self:SetUseType(SIMPLE_USE)

        if not self:GetInit() then
            self:SetVariant(RollVariant())
            self:SetMode(ModeDefault)
            self:SetInit(true)
        end

        local Index = self:GetTrackIndex()
        if Index < 1 or Index > #Tracks then
            self:SetTrackIndex(math.random(#Tracks))
        end

        self:SetColor(GetVariantDef(self:GetVariant()).Tint)
    end
end

-- ----------------------------------------------------------------------
-- Сервер
-- ----------------------------------------------------------------------

if SERVER then
    util.AddNetworkString("gmm_radio_Action")
    util.AddNetworkString("gmm_radio_Ended")

    local HistoryLimit = 50

    local function GetKeys(Activator)
        if GMM_S == nil or GMM_S["Clients"] == nil then return false, false end

        local ClientInfo = GMM_S["Clients"][Activator]
        if ClientInfo == nil then return false, false end

        return ClientInfo["Shift"] or false, ClientInfo["Alt"] or false
    end

    function ENT:GetRandomIndex()
        local Count = #Tracks
        if Count <= 1 then return 1 end

        local Current = self:GetTrackIndex()
        local Index   = math.random(Count - 1)
        if Index >= Current then Index = Index + 1 end

        return Index
    end

    function ENT:PlayTrack(Index, NoHistory)
        Index = (Index - 1) % #Tracks + 1

        if not NoHistory and self:GetSession() > 0 then
            local History = self.History
            if History == nil then
                History = {}
                self.History = History
            end

            History[#History + 1] = self:GetTrackIndex()
            if #History > HistoryLimit then table.remove(History, 1) end
        end

        self:SetTrackIndex(Index)
        self:SetPlayStart(CurTime())
        self:SetPauseAt(0)
        self:SetSession(self:GetSession() % 100000 + 1)
        self:SetPlaying(true)
    end

    function ENT:TogglePause()
        if self:GetPlaying() then
            self:SetPauseAt(CurTime() - self:GetPlayStart())
            self:SetPlaying(false)
            return
        end

        if self:GetSession() == 0 then
            self:PlayTrack(self:GetTrackIndex(), true)
            return
        end

        self:SetPlayStart(CurTime() - self:GetPauseAt())
        self:SetPlaying(true)
    end

    function ENT:Next()
        if self:GetMode() == ModeShuffle then
            self:PlayTrack(self:GetRandomIndex())
        else
            self:PlayTrack(self:GetTrackIndex() + 1)
        end
    end

    function ENT:Previous()
        local History = self.History

        if self:GetMode() == ModeShuffle and History ~= nil and #History > 0 then
            self:PlayTrack(table.remove(History), true)
            return
        end

        self:PlayTrack(self:GetTrackIndex() - 1, true)
    end

    function ENT:PlayRandom()
        self:PlayTrack(self:GetRandomIndex())
    end

    function ENT:CycleMode()
        self:SetMode((self:GetMode() + 1) % 3)
    end

    function ENT:Advance()
        if self:GetMode() == ModeRepeat then
            self:PlayTrack(self:GetTrackIndex(), true)
        else
            self:Next()
        end
    end

    function ENT:DoAction(Action)
        if Action == ActionPrev then
            self:EmitSound("buttons/button1.wav", 70, 85)
            self:Previous()
        elseif Action == ActionToggle then
            self:EmitSound("buttons/button1.wav", 70, 100)
            self:TogglePause()
        elseif Action == ActionNext then
            self:EmitSound("buttons/button1.wav", 70, 115)
            self:Next()
        elseif Action == ActionMode then
            self:EmitSound("buttons/button15.wav", 70, 100)
            self:CycleMode()
        elseif Action == ActionRandom then
            self:EmitSound("buttons/button17.wav", 70, 100)
            self:PlayRandom()
        end
    end

    function ENT:Use(Activator, Caller)
        if not IsValid(Activator) then return end
        if not Activator:IsPlayer() then return end

        Activator:PickupObject(self)

        if not GMM.Func.DoEntitiesUnlock() then
            self:EmitSound("ambient/voices/squeal1.wav")
            return
        end

        local ShiftPressed, AltPressed = GetKeys(Activator)
        if not ShiftPressed and not AltPressed then return end

        local Now = CurTime()
        if Now < (self.NextControl or 0) then return end
        self.NextControl = Now + ControlCooldown

        if ShiftPressed and AltPressed then
            self:DoAction(ActionToggle)
            return
        end

        if ShiftPressed then
            self:DoAction(ActionNext)
        else
            self:DoAction(ActionPrev)
        end
    end

    net.Receive("gmm_radio_Action", function(Length, Ply)
        local Ent    = net.ReadEntity()
        local Action = net.ReadUInt(4)

        if not IsValid(Ply) then return end
        if not IsValid(Ent) or not Ent.IsGMMRadio then return end
        if Ply:GetPos():DistToSqr(Ent:GetPos()) > MenuDistanceSqr then return end
        if not GMM.Func.DoEntitiesUnlock() then return end

        local Now = CurTime()
        if Now < (Ent.NextControl or 0) then return end
        Ent.NextControl = Now + ControlCooldown

        Ent:DoAction(Action)
    end)

    net.Receive("gmm_radio_Ended", function(Length, Ply)
        local Ent     = net.ReadEntity()
        local Session = net.ReadInt(32)

        if not IsValid(Ply) then return end
        if not IsValid(Ent) or not Ent.IsGMMRadio then return end
        if not Ent:GetPlaying() then return end
        if Ent:GetSession() ~= Session then return end
        if CurTime() - Ent:GetPlayStart() < 1 then return end
        if not GMM.Func.DoEntitiesUnlock() then return end

        Ent:Advance()
    end)
end

-- ----------------------------------------------------------------------
-- Клиент
-- ----------------------------------------------------------------------

if CLIENT then
    hook.Remove("HUDPaint", "gmm_radio_DrawMessage")

    if IsValid(GMM.RadioMenuPanel) then GMM.RadioMenuPanel:Remove() end
    GMM.RadioMenuPanel = nil

    surface.CreateFont("gmm_radio_Big",    {font = "Consolas", size = 26, weight = 800, antialias = true, extended = true})
    surface.CreateFont("gmm_radio_Button", {font = "Consolas", size = 20, weight = 800, antialias = true, extended = true})
    surface.CreateFont("gmm_radio_Small",  {font = "Consolas", size = 15, weight = 700, antialias = true, extended = true})
    surface.CreateFont("gmm_radio_Tiny",   {font = "Consolas", size = 13, weight = 600, antialias = true, extended = true})

    local BaseWeirdness  = 1
    local ChaosWeirdness = 3.2
    local Weirdness      = BaseWeirdness

    local PanelW = 520
    local PanelH = 152

    local MenuW = 440
    local MenuH = 250

    local BarCount = 32
    local BarW     = 11
    local BarGap   = 3
    local EqH      = 38
    local EqGain   = 1.6

    local FloatBars   = 16
    local FloatBarW   = 6
    local FloatGap    = 3
    local FloatTotalW = FloatBars * FloatBarW + (FloatBars - 1) * FloatGap

    local FFTData = {}
    local BarLo   = {}
    local BarHi   = {}

    local function GetEdge(Index)
        return 1 + math.floor(230 * (Index / BarCount) ^ 2)
    end

    for i = 1, BarCount do
        BarLo[i] = GetEdge(i - 1)
        BarHi[i] = math.max(BarLo[i], GetEdge(i) - 1)
    end

    local ColorOff   = Color(110, 110, 120, 255)
    local ColorError = Color(255, 60, 70, 255)
    local ColorWhite = Color(255, 255, 255, 255)
    local ColorTemp  = Color(255, 255, 255, 255)

    local IconPoly = {{x = 0, y = 0}, {x = 0, y = 0}, {x = 0, y = 0}}
    local EqAng    = Angle(0, 0, 90)

    local ShownRadio = nil
    local ShownUntil = 0
    local PanelRadio = nil
    local PanelAlpha = 0

    local StatusWords = {
        ["Play"]    = {"PLAY", "P L A Y", "PLAY?", "PLAY.", "ИГРАЕТ", "PL4Y"},
        ["Pause"]   = {"PAUSE", "P A U S E", "PAUSE?", "ПАУЗА", "WAIT"},
        ["Stop"]    = {"STOP", "S T O P", "STOP?", "..."},
        ["Loading"] = {"LOADING...", "L04DING...", "WAIT...", "0x47554C"},
        ["Error"]   = {"ERROR!", "3RR0R!", "ERR 0x47554C", "NO SIGNAL"}
    }

    local GlitchChars     = "#%&?@!/\\<>0123456789ABCDEF"
    local GlitchCharCount = #GlitchChars
    local GarbleCache     = {}

    local function SetColor(Col, R, G, B, A)
        Col.r = R
        Col.g = G
        Col.b = B
        Col.a = A
        return Col
    end

    local function FormatTime(Seconds)
        return string.format("%d:%02d", math.floor(Seconds / 60), math.floor(Seconds) % 60)
    end

    local function Hash(Value)
        local Result = math.sin(Value * 12.9898) * 43758.5453
        return Result - math.floor(Result)
    end

    local function Garble(Text, Salt)
        if Weirdness <= 0 then return Text end

        local Tick  = math.floor(CurTime() * 10)
        local Cache = GarbleCache[Salt]

        if Cache ~= nil and Cache.Tick == Tick and Cache.Text == Text then return Cache.Result end

        local Result = Text

        if Hash(Tick * 0.731 + Salt * 17.3) < 0.06 * Weirdness then
            local Parts = {}

            for i = 1, #Text do
                local Byte = string.byte(Text, i)

                if Byte > 32 and Byte < 127 and Hash(Tick * 3.7 + i * 5.1 + Salt) < 0.3 then
                    local Pick = math.floor(Hash(Tick * 1.3 + i * 7.7 + Salt) * GlitchCharCount) + 1
                    Parts[i] = string.sub(GlitchChars, Pick, Pick)
                else
                    Parts[i] = string.char(Byte)
                end
            end

            Result = table.concat(Parts)
        end

        if Cache == nil then
            Cache = {}
            GarbleCache[Salt] = Cache
        end

        Cache.Tick   = Tick
        Cache.Text   = Text
        Cache.Result = Result

        return Result
    end

    local function PickWord(Words, Salt)
        if Weirdness <= 0 then return Words[1] end

        local Tick = math.floor(CurTime() * 2)
        if Hash(Tick * 1.9 + Salt * 3.3) > 0.12 * Weirdness then return Words[1] end

        return Words[2 + math.floor(Hash(Tick * 4.1 + Salt) * (#Words - 1))]
    end

    local ChaosColors = {
        Color(255, 40, 90),
        Color(40, 255, 220),
        Color(255, 220, 40),
        Color(190, 90, 255),
        Color(235, 235, 240)
    }

    local ChaosStatusWords = {
        ["Play"]    = {"PLAY", "P L A Y ??", "PLAYPLAYPLAY", "ИГРАЕТ ВСЁ", "PL4Y 4LL", "NO MORE SILENCE"},
        ["Pause"]   = {"PAUSE", "PAUSE?!", "P4US3", "ОНО СЛЫШИТ", "NOT PAUSED"},
        ["Stop"]    = {"STOP", "S T O P ?", "ST0P", "..."},
        ["Loading"] = {"LOADING...", "L04D1NG 4LL", "MORE...", "0x47554C"},
        ["Error"]   = {"ERROR!", "3RR0R!", "ERR 0x47554C", "TOO MANY SIGNALS"}
    }

    local function IsChaos(Radio)
        return GetVariantDef(Radio:GetVariant()).Key == "Chaos"
    end

    local function ApplyWeirdness(Radio)
        if IsChaos(Radio) then
            Weirdness = ChaosWeirdness
        else
            Weirdness = BaseWeirdness
        end
    end

    local function GetStatusWords(Radio, Key)
        if IsChaos(Radio) then return ChaosStatusWords[Key] end
        return StatusWords[Key]
    end

    local function GetTitleText(Radio, Index)
        local Name = TrackNames[Index] or "???"
        if not IsChaos(Radio) then return Name end

        local Layers = Radio.ChaosLayers
        if Layers == nil then return Name end

        local Version = Radio.ChaosVersion or 0
        if Radio.ChaosTitle ~= nil and Radio.ChaosTitleVersion == Version and Radio.ChaosTitleIndex == Index then
            return Radio.ChaosTitle
        end

        local Parts = {Name}

        for i = 1, #Layers do
            local LayerIndex = Layers[i].Index
            if LayerIndex ~= nil then Parts[#Parts + 1] = TrackNames[LayerIndex] or "???" end
        end

        Radio.ChaosTitle        = table.concat(Parts, "  //  ")
        Radio.ChaosTitleVersion = Version
        Radio.ChaosTitleIndex   = Index

        return Radio.ChaosTitle
    end

    local function NoticeChange(Ent)
        local Ply = LocalPlayer()
        if not IsValid(Ply) then return end
        if Ply:GetPos():DistToSqr(Ent:GetPos()) > 700 * 700 then return end

        ShownRadio = Ent
        ShownUntil = CurTime() + 4
    end

    local function GetAccent(Radio)
        if Radio.RadioError then
            if math.floor(CurTime() * 6) % 2 == 0 then return ColorError end
            return ColorWhite
        end

        if not Radio:GetPlaying() then return ColorOff end

        if IsChaos(Radio) then
            local Pick = 1 + math.floor(Hash(math.floor(RealTime() * 14) * 1.37) * #ChaosColors)
            return ChaosColors[Pick]
        end

        return GetVariantDef(Radio:GetVariant()).Color
    end

    local function GetStatusKey(Radio)
        if Radio.RadioError then return "Error" end

        if Radio:GetPlaying() then
            if IsValid(Radio.RadioChannel) then return "Play" end
            return "Loading"
        end

        if Radio:GetSession() > 0 then return "Pause" end
        return "Stop"
    end

    local function DrawMarquee(Text, FontName, X, Y, Width, Start, Color, OffX, OffY)
        surface.SetFont(FontName)
        local TextW, TextH = surface.GetTextSize(Text)

        render.SetScissorRect(OffX + X, OffY + Y, OffX + X + Width, OffY + Y + TextH + 2, true)

        if TextW <= Width then
            draw.SimpleText(Text, FontName, X, Y, Color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        else
            local Cycle   = TextW + 60
            local Elapsed = math.max(CurTime() - Start - 1.5, 0)
            local Offset  = (Elapsed * 45) % Cycle

            draw.SimpleText(Text, FontName, X - Offset, Y, Color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText(Text, FontName, X - Offset + Cycle, Y, Color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end

        render.SetScissorRect(0, 0, 0, 0, false)
    end

    local function DrawProgress(Radio, X, Y, Width, Alpha, Accent)
        local Channel = Radio.RadioChannel
        local Current = 0
        local Length  = 0

        if IsValid(Channel) then
            Current = Channel:GetTime()
            Length  = Channel:GetLength()
        end

        surface.SetDrawColor(255, 255, 255, 30 * Alpha)
        surface.DrawRect(X, Y, Width, 4)

        if Length > 0 then
            local Fraction = math.Clamp(Current / Length, 0, 1)
            local FillW    = math.floor(Width * Fraction)

            surface.SetDrawColor(Accent.r, Accent.g, Accent.b, 255 * Alpha)
            surface.DrawRect(X, Y, FillW, 4)

            surface.SetDrawColor(255, 255, 255, 255 * Alpha)
            surface.DrawRect(X + FillW - 1, Y - 3, 3, 10)
        end

        local TimeA  = 170 * Alpha
        local LeftT  = Length > 0 and FormatTime(Current) or "--:--"
        local RightT = Length > 0 and FormatTime(Length)  or "--:--"

        draw.SimpleText(Garble(LeftT, 6),  "gmm_radio_Tiny", X,         Y + 8, SetColor(ColorTemp, 160, 160, 170, TimeA), TEXT_ALIGN_LEFT,  TEXT_ALIGN_TOP)
        draw.SimpleText(Garble(RightT, 8), "gmm_radio_Tiny", X + Width, Y + 8, SetColor(ColorTemp, 160, 160, 170, TimeA), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
    end

    -- ----------------------------------------------------------------------
    -- Звук
    -- ----------------------------------------------------------------------

    function ENT:GetElapsed()
        if self:GetPlaying() then return math.max(CurTime() - self:GetPlayStart(), 0) end
        return self:GetPauseAt()
    end

    function ENT:RadioStop()
        self:GlitchReset()
        self:ChaosStop()

        self.RadioToken   = (self.RadioToken or 0) + 1
        self.RadioLoading = false
        self.RadioError   = false
        self.RadioActive  = false

        local Channel = self.RadioChannel
        self.RadioChannel = nil

        if IsValid(Channel) then Channel:Stop() end
    end

    function ENT:RadioStart(Index)
        self.RadioError = false

        local Url = Tracks[Index]
        if Url == nil then
            self.RadioError = true
            print("[GMM] RADIO TRACK INDEX INVALID! INDEX: " .. tostring(Index))
            return
        end

        self.RadioToken   = (self.RadioToken or 0) + 1
        self.RadioLoading = true
        local Token = self.RadioToken

        self:GlitchReset()
        sound.PlayURL(Url, "3d mono noblock", function(Channel, ErrorId, ErrorName)
            if not IsValid(self) or self.RadioToken ~= Token then
                if IsValid(Channel) then Channel:Stop() end
                return
            end

            self.RadioLoading = false

            if not IsValid(Channel) then
                self.RadioError = true
                print("[GMM] RADIO LOAD ERROR! TRACK: " .. tostring(TrackNames[Index]) .. ", CODE: " .. tostring(ErrorId) .. ", " .. tostring(ErrorName) .. ", URL: " .. Url)
                return
            end

            local VariantDef = GetVariantDef(self:GetVariant())
            local Looping    = self:GetMode() == ModeRepeat

            Channel:EnableLooping(Looping)
            Channel:SetPos(self:GetPos())
            Channel:SetVolume(VariantDef.Volume)
            Channel:SetPlaybackRate(VariantDef.Rate)

            self.RadioVolume = VariantDef.Volume
            self.RadioLoop   = Looping

            local Elapsed = self:GetElapsed() * VariantDef.Rate
            local Length  = Channel:GetLength()
            if Elapsed > 1 and Length > 1 then
                Channel:SetTime(Elapsed % Length)
            end

            self.RadioChannel = Channel
            self.RadioActive  = false

            if self:GetPlaying() then
                Channel:Play()
                self.RadioActive      = true
                self.RadioActiveSince = CurTime()
            end
        end)
    end

    function ENT:RadioSync()
        local TrackIndex = self:GetTrackIndex()
        local Session    = self:GetSession()
        local Playing    = self:GetPlaying()
        local Mode       = self:GetMode()

        if TrackIndex ~= self.RadioShownIndex then
            self.RadioShownIndex  = TrackIndex
            self.RadioScrollStart = CurTime()
        end

        if Session ~= self.RadioSession then
            local Old = self.RadioSession
            self.RadioSession = Session

            self:RadioStop()

            if Old ~= nil then NoticeChange(self) end
        end

        if Playing ~= self.RadioWasPlaying then
            local Old = self.RadioWasPlaying
            self.RadioWasPlaying = Playing

            local Channel = self.RadioChannel
            if IsValid(Channel) then
                if Playing then
                    Channel:Play()
                    self.RadioActive      = true
                    self.RadioActiveSince = CurTime()
                else
                    Channel:Pause()
                end
            end

            self:ChaosSetPlaying(Playing)
            
            if Old ~= nil then NoticeChange(self) end
        end

        if Mode ~= self.RadioMode then
            local Old = self.RadioMode
            self.RadioMode = Mode

            local Channel = self.RadioChannel
            if IsValid(Channel) then Channel:EnableLooping(Mode == ModeRepeat) end

            if Old ~= nil then NoticeChange(self) end
        end

        local Channel = self.RadioChannel

        if Playing and not IsValid(Channel) and not self.RadioLoading and not self.RadioError then
            self:RadioStart(TrackIndex)
            return
        end

        if not IsValid(Channel) then return end

        Channel:SetPos(self:GetPos())

        if Playing and self.RadioActive and Session ~= self.RadioEndedSession then
            if CurTime() - (self.RadioActiveSince or 0) > 1 and Channel:GetState() == GMOD_CHANNEL_STOPPED then
                self.RadioEndedSession = Session

                net.Start("gmm_radio_Ended")
                net.WriteEntity(self)
                net.WriteInt(Session, 32)
                net.SendToServer()
            end
        end
    end

    -- ----------------------------------------------------------------------
    -- Глитч-диджей (синее радио)
    -- ----------------------------------------------------------------------

    local GlitchDelayMin = 0.5
    local GlitchDelayMax = 3

    local GlitchTypes = {
        {Weight = 4, Key = "Loop"},
        {Weight = 2, Key = "Back"},
        {Weight = 2, Key = "Skip"},
        {Weight = 2, Key = "Slow"},
        {Weight = 2, Key = "Fast"},
        {Weight = 2, Key = "Scratch"},
    }

    local function PickGlitchKey()
        local Sum = 0
        for _, Type in ipairs(GlitchTypes) do
            Sum = Sum + Type.Weight
        end

        local Roll = math.Rand(0, Sum)
        for _, Type in ipairs(GlitchTypes) do
            Roll = Roll - Type.Weight
            if Roll <= 0 then return Type.Key end
        end

        return "Loop"
    end

    function ENT:GlitchReset()
        self.GlitchNext       = RealTime() + math.Rand(GlitchDelayMin, GlitchDelayMax)
        self.GlitchLoopLeft   = 0
        self.GlitchLoopPos    = 0
        self.GlitchLoopLen    = 0
        self.GlitchLoopNext   = 0
        self.GlitchLoopShrink = 1
        self.GlitchRateKind   = nil
        self.GlitchRateStart  = 0
        self.GlitchRateDur    = 1
        self.GlitchRateStep   = 0.1
        self.GlitchRateTo     = 1
        self.GlitchRateTo2    = 1
        self.GlitchFlash      = 0
    end

    function ENT:GlitchRate(Now)
        local Kind     = self.GlitchRateKind
        local Start    = self.GlitchRateStart
        local Progress = (Now - Start) / self.GlitchRateDur

        if Progress >= 1 then
            self.GlitchRateKind = nil
            self.GlitchNext     = Now + math.Rand(GlitchDelayMin, GlitchDelayMax)
            return 1
        end

        if Kind == "Slow" then return Lerp(Progress * Progress, 1, self.GlitchRateTo) end
        if Kind == "Fast" then return self.GlitchRateTo end

        local Step = math.floor((Now - Start) / self.GlitchRateStep)
        if Step % 2 == 0 then return self.GlitchRateTo end

        return self.GlitchRateTo2
    end

    function ENT:GlitchStart(Channel, Now)
        local Length = Channel:GetLength()
        local Time   = Channel:GetTime()
        local Key    = PickGlitchKey()

        local CanSeek = Length > 3 and Time > 0.7 and Time < Length - 1.5
        if not CanSeek and (Key == "Loop" or Key == "Back" or Key == "Skip") then
            Key = "Slow"
        end

        self.GlitchFlash = Now

        if Key == "Loop" then
            local Len = math.Rand(0.06, 0.3)
            self.GlitchLoopPos    = Time
            self.GlitchLoopLen    = Len
            self.GlitchLoopLeft   = math.random(3, 8)
            self.GlitchLoopNext   = Now + Len
            self.GlitchLoopShrink = math.random() < 0.5 and 0.78 or 1
            return
        end

        if Key == "Back" then
            Channel:SetTime(math.max(0, Time - math.Rand(0.15, 1.2)))
            self.GlitchNext = Now + math.Rand(0.15, 0.6)
            return
        end

        if Key == "Skip" then
            Channel:SetTime(math.min(Length - 1, Time + math.Rand(0.15, 0.9)))
            self.GlitchNext = Now + math.Rand(0.15, 0.6)
            return
        end

        self.GlitchRateKind  = Key
        self.GlitchRateStart = Now

        if Key == "Slow" then
            self.GlitchRateDur = math.Rand(0.35, 1)
            self.GlitchRateTo  = math.Rand(0.2, 0.55)
            return
        end

        if Key == "Fast" then
            self.GlitchRateDur = math.Rand(0.3, 0.9)
            self.GlitchRateTo  = math.Rand(1.6, 2.3)
            return
        end

        self.GlitchRateDur  = math.Rand(0.5, 1.1)
        self.GlitchRateStep = math.Rand(0.07, 0.15)
        self.GlitchRateTo   = math.Rand(0.3, 0.6)
        self.GlitchRateTo2  = math.Rand(1.6, 2.2)
    end

    function ENT:GlitchThink(Channel, Now)
        if self.GlitchNext == nil then self:GlitchReset() end

        local Mult = 1
        if self.GlitchRateKind ~= nil then
            Mult = self:GlitchRate(Now)
            return Mult
        end

        if self.GlitchLoopLeft > 0 then
            if Now >= self.GlitchLoopNext then
                Channel:SetTime(self.GlitchLoopPos)

                self.GlitchLoopLeft = self.GlitchLoopLeft - 1
                self.GlitchLoopLen  = self.GlitchLoopLen * self.GlitchLoopShrink
                self.GlitchLoopNext = Now + self.GlitchLoopLen

                if self.GlitchLoopLeft <= 0 then
                    self.GlitchNext = Now + math.Rand(GlitchDelayMin, GlitchDelayMax)
                end
            end
            return Mult
        end

        if Now < self.GlitchNext then return Mult end

        self:GlitchStart(Channel, Now)

        return Mult
    end

    -- ----------------------------------------------------------------------
    -- Какофония (чёрное радио)
    -- ----------------------------------------------------------------------

    local ChaosLayerCount    = 5
    local ChaosLayerDelayMin = 0.2
    local ChaosLayerDelayMax = 1.5
    local ChaosEventMin      = 1.5
    local ChaosEventMax      = 6
    local ChaosRateMin       = 0.3
    local ChaosRateMax       = 2.6
    local ChaosVolumeMin     = 0.4
    local ChaosVolumeMax     = 1
    local ChaosDropMin       = 0.04
    local ChaosDropMax       = 0.3
    local ChaosNoiseDots     = 24

    local ChaosTypes = {
        {Weight = 4, Key = "Rate"},
        {Weight = 3, Key = "Drop"},
        {Weight = 3, Key = "Loop"},
        {Weight = 3, Key = "Seek"},
        {Weight = 1, Key = "Swap"},
    }

    local function PickChaosKey()
        local Sum = 0
        for _, Type in ipairs(ChaosTypes) do
            Sum = Sum + Type.Weight
        end

        local Roll = math.Rand(0, Sum)
        for _, Type in ipairs(ChaosTypes) do
            Roll = Roll - Type.Weight
            if Roll <= 0 then return Type.Key end
        end

        return "Rate"
    end

    local function PickChaosLayerOrNil(Layers)
        local Ready = {}

        for i = 1, #Layers do
            if IsValid(Layers[i].Channel) then Ready[#Ready + 1] = Layers[i] end
        end

        if #Ready == 0 then return nil end

        return Ready[math.random(#Ready)]
    end

    function ENT:ChaosPickIndex(Slot)
        local Count = #Tracks
        local Index = 1 + math.floor(Hash(self:GetSession() * 13.7 + Slot * 91.3 + self:EntIndex() * 3.1) * Count)

        if Index == self:GetTrackIndex() then Index = Index % Count + 1 end

        return Index
    end

    function ENT:ChaosStop()
        self.ChaosToken     = (self.ChaosToken or 0) + 1
        self.ChaosNextEvent = nil
        self.ChaosMainDrop  = nil

        local Layers = self.ChaosLayers
        self.ChaosLayers = nil

        if Layers == nil then return end

        for i = 1, #Layers do
            local Channel = Layers[i].Channel
            if IsValid(Channel) then Channel:Stop() end
        end
    end

    function ENT:ChaosSetPlaying(Playing)
        local Layers = self.ChaosLayers
        if Layers == nil then return end

        for i = 1, #Layers do
            local Channel = Layers[i].Channel

            if IsValid(Channel) then
                if Playing then
                    Channel:Play()
                else
                    Channel:Pause()
                end
            end
        end
    end

    function ENT:ChaosStartLayer(Layer, Index)
        local Url = Tracks[Index]
        if Url == nil then return end

        local Old = Layer.Channel
        Layer.Channel = nil
        if IsValid(Old) then Old:Stop() end

        Layer.Index   = Index
        Layer.Loading = true
        Layer.Serial  = Layer.Serial + 1

        self.ChaosVersion = (self.ChaosVersion or 0) + 1

        local Serial = Layer.Serial
        local Token  = self.ChaosToken

        sound.PlayURL(Url, "3d mono noblock", function(Channel, ErrorId, ErrorName)
            if not IsValid(self) or self.ChaosToken ~= Token or Layer.Serial ~= Serial then
                if IsValid(Channel) then Channel:Stop() end
                return
            end

            Layer.Loading = false

            if not IsValid(Channel) then
                print("[GMM] RADIO CHAOS LOAD ERROR! TRACK: " .. tostring(TrackNames[Index]) .. ", CODE: " .. tostring(ErrorId) .. ", " .. tostring(ErrorName) .. ", URL: " .. Url)

                Layer.Index   = math.random(#Tracks)
                Layer.StartAt = RealTime() + 5
                return
            end

            local VariantDef = GetVariantDef(self:GetVariant())

            Layer.Channel = Channel
            Layer.Born    = RealTime()
            Layer.Volume  = VariantDef.Volume * math.Rand(ChaosVolumeMin, ChaosVolumeMax)
            Layer.Rate    = math.Rand(ChaosRateMin, ChaosRateMax)

            Channel:EnableLooping(false)
            Channel:SetPos(self:GetPos())
            Channel:SetVolume(Layer.Volume)
            Channel:SetPlaybackRate(Layer.Rate)

            local Length = Channel:GetLength()
            if Length > 3 then Channel:SetTime(math.Rand(0, Length * 0.8)) end

            if self:GetPlaying() then Channel:Play() end
        end)
    end

    function ENT:ChaosSwapLayer(Layer)
        self:ChaosStartLayer(Layer, math.random(#Tracks))
    end

    function ENT:ChaosStart()
        self.ChaosToken   = (self.ChaosToken or 0) + 1
        self.ChaosVersion = (self.ChaosVersion or 0) + 1

        local Now    = RealTime()
        local Layers = {}

        for i = 1, ChaosLayerCount do
            Layers[i] = {
                Channel   = nil,
                Loading   = false,
                Serial    = 0,
                Index     = self:ChaosPickIndex(i),
                StartAt   = Now + math.Rand(ChaosLayerDelayMin, ChaosLayerDelayMax) * i,
                Born      = Now,
                Volume    = 1,
                Rate      = 1,
                Wobble    = math.Rand(0.5, 3),
                DropUntil = 0,
                LoopLeft  = 0,
                LoopPos   = 0,
                LoopLen   = 0,
                LoopNext  = 0
            }
        end

        self.ChaosLayers    = Layers
        self.ChaosNextEvent = Now + math.Rand(ChaosEventMin, ChaosEventMax)
    end

    function ENT:ChaosLayerThink(Layer, Now)
        local Channel = Layer.Channel

        if not IsValid(Channel) then
            if Layer.Loading or Now < Layer.StartAt then return end

            self:ChaosStartLayer(Layer, Layer.Index)
            return
        end

        Channel:SetPos(self:GetPos())

        if Layer.DropUntil > 0 and Now >= Layer.DropUntil then
            Layer.DropUntil = 0
            Channel:SetVolume(Layer.Volume)
        end

        if Layer.LoopLeft > 0 and Now >= Layer.LoopNext then
            Channel:SetTime(Layer.LoopPos)

            Layer.LoopLeft = Layer.LoopLeft - 1
            Layer.LoopNext = Now + Layer.LoopLen
        end

        Channel:SetPlaybackRate(Layer.Rate * (1 + 0.08 * math.sin(Now * Layer.Wobble)))

        if not self:GetPlaying() then return end
        if Now - Layer.Born < 1 then return end
        if Channel:GetState() ~= GMOD_CHANNEL_STOPPED then return end

        self:ChaosSwapLayer(Layer)
    end

    function ENT:ChaosEvent(Channel, Layers, Now)
        local Key = PickChaosKey()

        if Key == "Rate" then
            for i = 1, #Layers do
                Layers[i].Rate = math.Rand(ChaosRateMin, ChaosRateMax)
            end
            return
        end

        if Key == "Drop" then
            local Duration = math.Rand(ChaosDropMin, ChaosDropMax)
            local All      = math.random() < 0.35
            local Pick     = math.random(#Layers)

            for i = 1, #Layers do
                if All or i == Pick then
                    local Layer = Layers[i]
                    Layer.DropUntil = Now + Duration

                    if IsValid(Layer.Channel) then Layer.Channel:SetVolume(0) end
                end
            end

            if All then
                self.ChaosMainDrop = Now + Duration
                Channel:SetVolume(0)
            end

            return
        end

        local Layer = PickChaosLayerOrNil(Layers)
        if Layer == nil then return end

        local LayerChannel = Layer.Channel
        local Length       = LayerChannel:GetLength()

        if Key == "Swap" then
            self:ChaosSwapLayer(Layer)
            return
        end

        if Length < 3 then return end

        if Key == "Loop" then
            Layer.LoopPos  = LayerChannel:GetTime()
            Layer.LoopLen  = math.Rand(0.05, 0.25)
            Layer.LoopLeft = math.random(4, 12)
            Layer.LoopNext = Now + Layer.LoopLen
            return
        end

        LayerChannel:SetTime(math.Rand(0, Length - 1))
    end

    function ENT:ChaosThink(Channel, Now)
        if self.ChaosLayers == nil then self:ChaosStart() end

        local Layers = self.ChaosLayers

        if self.ChaosMainDrop ~= nil and Now >= self.ChaosMainDrop then
            self.ChaosMainDrop = nil
            Channel:SetVolume(self.RadioVolume or 1)
        end

        for i = 1, #Layers do
            self:ChaosLayerThink(Layers[i], Now)
        end

        if Now < self.ChaosNextEvent then return end
        self.ChaosNextEvent = Now + math.Rand(ChaosEventMin, ChaosEventMax)

        self:ChaosEvent(Channel, Layers, Now)
    end

    function ENT:DrawChaosNoise(X, Y, Width, Height, Alpha)
        if not IsChaos(self) then return end

        local Tick   = math.floor(RealTime() * 18)
        local SplitX = math.floor((Hash(Tick * 1.7) - 0.5) * 10)
        local SplitY = math.floor((Hash(Tick * 2.9) - 0.5) * 4)

        surface.SetDrawColor(255, 0, 60, 110 * Alpha)
        surface.DrawOutlinedRect(X + SplitX, Y + SplitY, Width, Height, 1)

        surface.SetDrawColor(0, 255, 220, 110 * Alpha)
        surface.DrawOutlinedRect(X - SplitX, Y - SplitY, Width, Height, 1)

        for i = 1, 3 do
            if Hash(Tick * 3.1 + i * 7.7) > 0.7 then
                local TearY = Y + math.floor(Hash(Tick * 5.3 + i) * Height)
                local TearH = 2 + math.floor(Hash(Tick * 1.1 + i * 3) * 10)
                local TearX = math.floor((Hash(Tick * 2.3 + i * 5) - 0.5) * 30)

                surface.SetDrawColor(235, 235, 240, 40 * Alpha)
                surface.DrawRect(X + TearX, TearY, Width, TearH)

                surface.SetDrawColor(255, 0, 60, 60 * Alpha)
                surface.DrawRect(X - TearX, TearY + TearH, Width, 1)
            end
        end

        surface.SetDrawColor(235, 235, 240, 90 * Alpha)
        for i = 1, ChaosNoiseDots do
            local DotX = X + math.floor(Hash(Tick * 1.3 + i * 9.1) * Width)
            local DotY = Y + math.floor(Hash(Tick * 2.1 + i * 4.3) * Height)

            surface.DrawRect(DotX, DotY, 2, 2)
        end

        if Hash(Tick * 0.37) > 0.96 then
            surface.SetDrawColor(235, 235, 240, 45 * Alpha)
            surface.DrawRect(X, Y, Width, Height)
        end
    end

    function ENT:DrawChaosLayers(X, Y, Width, Alpha)
        if not IsChaos(self) then return end

        local Layers = self.ChaosLayers
        if Layers == nil then return end

        local Tick = math.floor(RealTime() * 8)

        for i = 1, #Layers do
            local Layer  = Layers[i]
            local Active = IsValid(Layer.Channel)
            local RowY   = Y + (i - 1) * 14
            local Pick   = ChaosColors[1 + math.floor(Hash(Tick * 1.3 + i * 4.1) * #ChaosColors)]
            local Name   = "........"
            local Level  = 0

            if Active then
                Name = TrackNames[Layer.Index] or "???"

                local Cut = utf8.offset(Name, 37)
                if Cut ~= nil then Name = string.sub(Name, 1, Cut - 1) .. ".." end

                if Layer.DropUntil == 0 then Level = math.Clamp(Layer.Rate / ChaosRateMax, 0.05, 1) end
            end

            draw.SimpleText(Garble("L" .. i .. "  " .. Name, 40 + i), "gmm_radio_Tiny", X, RowY, SetColor(ColorTemp, Pick.r, Pick.g, Pick.b, 200 * Alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

            surface.SetDrawColor(Pick.r, Pick.g, Pick.b, 160 * Alpha)
            surface.DrawRect(X + Width - 60, RowY + 3, math.floor(60 * Level), 6)
        end
    end

    function ENT:RadioEffects()
        local VariantDef = GetVariantDef(self:GetVariant())
        local Key        = VariantDef.Key

        if Key ~= "Chaos" and self.ChaosLayers ~= nil then self:ChaosStop() end

        if not self:GetPlaying() then return end

        local Channel = self.RadioChannel
        if not IsValid(Channel) then return end

        if Key == "Warp" then
            local Time = CurTime()
            Channel:SetPlaybackRate(1 + 0.16 * math.sin(Time * 0.9 + self:EntIndex()) + 0.06 * math.sin(Time * 3.1))
        elseif Key == "Stutter" then
            local Mult = self:GlitchThink(Channel, RealTime())
            Channel:SetPlaybackRate(VariantDef.Rate * Mult)
        elseif Key == "Chaos" then
            local Now  = RealTime()
            local Mult = self:GlitchThink(Channel, Now)

            Channel:SetPlaybackRate(VariantDef.Rate * Mult)
            self:ChaosThink(Channel, Now)
        end
    end

    function ENT:RadioUpdateBars()
        local Bars  = self.RadioBars
        local Peaks = self.RadioPeaks

        if Bars == nil then
            Bars  = {}
            Peaks = {}
            for i = 1, BarCount do
                Bars [i] = 0
                Peaks[i] = 0
            end
            self.RadioBars  = Bars
            self.RadioPeaks = Peaks
        end

        local Ply = LocalPlayer()
        if not IsValid(Ply) then return end
        if Ply:GetPos():DistToSqr(self:GetPos()) > 1000 * 1000 then return end

        local Channel = self.RadioChannel
        local Fft     = nil

        if IsValid(Channel) and Channel:GetState() == GMOD_CHANNEL_PLAYING then
            if Channel:FFT(FFTData, FFT_1024) > 0 then Fft = FFTData end
        end

        local Loading = self:GetPlaying() and not IsValid(Channel) and not self.RadioError
        local Time    = CurTime()
        local Frame   = FrameTime()
        local Delta   = math.min(Frame * 14, 1)
        local Chaos   = IsChaos(self)

        for i = 1, BarCount do
            local Target = 0

            if Fft ~= nil then
                local Peak = 0
                for Bin = BarLo[i], BarHi[i] do
                    local Value = Fft[Bin]
                    if Value ~= nil and Value > Peak then Peak = Value end
                end

                Target = math.min(math.sqrt(Peak) * EqGain * (0.7 + i / BarCount), 1)
            elseif Loading then
                Target = 0.12 + 0.1 * math.sin(Time * 5 + i * 0.6)
            end

            if Chaos then
                Target = math.min(Target * (0.3 + 1.7 * Hash(Time * 31 + i * 1.7)), 1)
            end

            local Value = Lerp(Delta, Bars[i], Target)
            Bars[i] = Value

            local PeakValue = Peaks[i] - Frame * 0.5
            if Value > PeakValue then PeakValue = Value end
            Peaks[i] = PeakValue
        end
    end

    function ENT:Think()
        self:RadioSync()
        self:RadioEffects()
        self:RadioUpdateBars()
    end

    function ENT:OnRemove()
        local Channel = self.RadioChannel
        local Layers  = self.ChaosLayers

        timer.Simple(0, function()
            if IsValid(self) then return end
            if IsValid(Channel) then Channel:Stop() end
            if Layers == nil then return end

            for i = 1, #Layers do
                local LayerChannel = Layers[i].Channel
                if IsValid(LayerChannel) then LayerChannel:Stop() end
            end
        end)
    end

    -- ----------------------------------------------------------------------
    -- Отрисовка в мире
    -- ----------------------------------------------------------------------

    function ENT:DrawFloatingEq()
        if not self:GetPlaying() then return end

        local Bars = self.RadioBars
        if Bars == nil then return end

        local Ply = LocalPlayer()
        if not IsValid(Ply) then return end

        local Dist  = Ply:GetPos():Distance(self:GetPos())
        local Alpha = 1 - math.Clamp((Dist - 300) / 300, 0, 1)
        if Alpha <= 0.02 then return end

        local Accent = GetAccent(self)

        local Pos = self:GetPos()
        Pos.z = Pos.z + self:OBBMaxs().z + 4
        EqAng.y = Ply:EyeAngles().y - 90

        cam.Start3D2D(Pos, EqAng, 0.1)
        surface.SetDrawColor(Accent.r, Accent.g, Accent.b, 255 * Alpha)

        for j = 1, FloatBars do
            local Value  = (Bars[j * 2 - 1] + Bars[j * 2]) * 0.5
            local Height = 3 + math.floor(Value * 200)
            local BarX   = -FloatTotalW / 2 + (j - 1) * (FloatBarW + FloatGap)

            surface.DrawRect(BarX, -Height, FloatBarW, Height)
        end
        cam.End3D2D()
    end

    function ENT:Draw()
        self:DrawModel()
        self:DrawFloatingEq()
    end

    -- ----------------------------------------------------------------------
    -- Нижняя панель
    -- ----------------------------------------------------------------------

    function ENT:DrawRadioPanel(Alpha)
        ApplyWeirdness(self)

        local Playing   = self:GetPlaying()
        local Index     = self:GetTrackIndex()
        local Bars      = self.RadioBars
        local Peaks     = self.RadioPeaks
        local Time      = CurTime()
        local Tick      = math.floor(Time * 12)
        local Accent    = GetAccent(self)
        local Variant   = GetVariantDef(self:GetVariant())
        local StatusKey = GetStatusKey(self)
        local Status    = Garble(PickWord(GetStatusWords(self, StatusKey), 2), 2)

        local Burst = Weirdness > 0 and Hash(Tick * 2.3) > 1 - 0.1 * Weirdness

        local X = math.floor(ScrW() / 2 - PanelW / 2)
        local Y = ScrH() - PanelH - 110

        if Weirdness > 0 and Hash(Tick * 1.7) > 1 - 0.05 * Weirdness then
            X = X + math.floor((Hash(Tick * 3.1) - 0.5) * 12)
            Y = Y + math.floor((Hash(Tick * 5.3) - 0.5) * 4)
        end

        local InnerX = X + 16
        local InnerW = PanelW - 32

        -- Линейка и подписи над панелью
        surface.SetDrawColor(Accent.r, Accent.g, Accent.b, 90 * Alpha)
        for RulerX = 0, PanelW, 20 do
            local RulerH = (RulerX % 100 == 0) and 7 or 3
            surface.DrawRect(X + RulerX, Y - RulerH - 2, 1, RulerH)
        end

        draw.SimpleText("CH." .. string.format("%03d", Index) .. " // 0x47554C", "gmm_radio_Tiny", X, Y - 24, SetColor(ColorTemp, 160, 160, 170, 90 * Alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(Garble(Variant.Title, 4), "gmm_radio_Tiny", X + PanelW, Y - 24, SetColor(ColorTemp, Variant.Color.r, Variant.Color.g, Variant.Color.b, 255 * Alpha), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)

        -- Рамки
        surface.SetDrawColor(Accent.r, Accent.g, Accent.b, 60 * Alpha)
        surface.DrawOutlinedRect(X + 5, Y - 4, PanelW, PanelH, 1)

        surface.SetDrawColor(8, 8, 12, 235 * Alpha)
        surface.DrawRect(X, Y, PanelW, PanelH)

        surface.SetDrawColor(Accent.r, Accent.g, Accent.b, 200 * Alpha)
        surface.DrawOutlinedRect(X, Y, PanelW, PanelH, 1)

        -- Бегущая полоса
        local SweepY   = Y + (Time * 45) % (PanelH + 40) - 20
        local SweepTop = math.max(SweepY, Y + 1)
        local SweepBot = math.min(SweepY + 5, Y + PanelH - 1)

        if SweepBot > SweepTop then
            surface.SetDrawColor(Accent.r, Accent.g, Accent.b, 16 * Alpha)
            surface.DrawRect(X + 1, SweepTop, PanelW - 2, SweepBot - SweepTop)
        end

        -- Шапка
        local HeaderY = Y + 10

        if StatusKey == "Play" then
            IconPoly[1].x = InnerX
            IconPoly[1].y = HeaderY
            IconPoly[2].x = InnerX + 11
            IconPoly[2].y = HeaderY + 6
            IconPoly[3].x = InnerX
            IconPoly[3].y = HeaderY + 12

            draw.NoTexture()
            surface.SetDrawColor(Accent.r, Accent.g, Accent.b, (150 + 105 * math.abs(math.sin(Time * 3))) * Alpha)
            surface.DrawPoly(IconPoly)
        elseif StatusKey == "Pause" then
            surface.SetDrawColor(Accent.r, Accent.g, Accent.b, 255 * Alpha)
            surface.DrawRect(InnerX, HeaderY + 1, 4, 11)
            surface.DrawRect(InnerX + 7, HeaderY + 1, 4, 11)
        else
            surface.SetDrawColor(Accent.r, Accent.g, Accent.b, 255 * Alpha)
            surface.DrawRect(InnerX, HeaderY + 1, 11, 11)
        end

        local ModeName = ModeNames[self:GetMode()] or "?"
        local Counter  = Garble(ModeName .. "  " .. string.format("%03d / %03d", Index, #Tracks), 3)

        draw.SimpleText(Garble("RAD-10", 7), "gmm_radio_Small", InnerX + 20, HeaderY - 1, SetColor(ColorTemp, 160, 160, 170, 255 * Alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(Status, "gmm_radio_Small", InnerX + 82, HeaderY - 1, SetColor(ColorTemp, Accent.r, Accent.g, Accent.b, 255 * Alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(Counter, "gmm_radio_Small", InnerX + InnerW, HeaderY - 1, SetColor(ColorTemp, 160, 160, 170, 255 * Alpha), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)

        -- Название
        local TitleY     = Y + 32
        local Title      = Garble(GetTitleText(self, Index), 1)
        local TitleAlpha = Playing and 255 or 140
        local Start      = self.RadioScrollStart or Time

        if Burst then
            local Side = (Tick % 2 == 0) and -3 or 3
            DrawMarquee(Title, "gmm_radio_Big", InnerX + Side, TitleY, InnerW, Start, SetColor(ColorTemp, 255, 40, 90, 120 * Alpha), 0, 0)
        end

        DrawMarquee(Title, "gmm_radio_Big", InnerX + 2, TitleY + 1, InnerW, Start, SetColor(ColorTemp, Accent.r, Accent.g, Accent.b, 70 * Alpha), 0, 0)
        DrawMarquee(Title, "gmm_radio_Big", InnerX, TitleY, InnerW, Start, SetColor(ColorTemp, 235, 235, 240, TitleAlpha * Alpha), 0, 0)

        -- Эквалайзер
        if Bars ~= nil then
            local EqBottom = Y + 112
            local EqTotalW = BarCount * BarW + (BarCount - 1) * BarGap
            local EqX      = InnerX + math.floor((InnerW - EqTotalW) / 2)
            local GlitchBar = 1 + math.floor(Hash(Tick * 4.7) * BarCount)

            for i = 1, BarCount do
                local Height = math.max(2, math.floor(Bars[i] * EqH))
                if Burst and i == GlitchBar then Height = EqH end

                local BarX = EqX + (i - 1) * (BarW + BarGap)

                surface.SetDrawColor(Accent.r, Accent.g, Accent.b, 25 * Alpha)
                surface.DrawRect(BarX, EqBottom - EqH, BarW, EqH)

                surface.SetDrawColor(Accent.r, Accent.g, Accent.b, 255 * Alpha)
                surface.DrawRect(BarX, EqBottom - Height, BarW, Height)
            end

            surface.SetDrawColor(8, 8, 12, 235 * Alpha)
            for GapY = EqBottom - 5, EqBottom - EqH, -5 do
                surface.DrawRect(EqX, GapY, EqTotalW, 1)
            end

            surface.SetDrawColor(255, 255, 255, 200 * Alpha)
            for i = 1, BarCount do
                if Peaks[i] > 0.03 then
                    local BarX = EqX + (i - 1) * (BarW + BarGap)
                    surface.DrawRect(BarX, EqBottom - math.floor(Peaks[i] * EqH) - 3, BarW, 2)
                end
            end
        end

        -- Прогресс и подсказка
        DrawProgress(self, InnerX, Y + 122, InnerW, Alpha, Accent)

        draw.SimpleText(Garble("CTRL+E MENU   SHIFT+E >>   ALT+E <<   BOTH = PAUSE", 5), "gmm_radio_Tiny", InnerX + InnerW / 2, Y + 130, SetColor(ColorTemp, 110, 110, 120, 170 * Alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

        self:DrawChaosNoise(X, Y, PanelW, PanelH, Alpha)
        self:DrawChaosLayers(X, Y + PanelH + 6, PanelW, Alpha)
    end

    hook.Add("HUDPaint", "gmm_radio_Hud", function()
        if IsValid(GMM.RadioMenuPanel) then return end

        local Ply = LocalPlayer()
        if not IsValid(Ply) then return end

        local Target = nil

        local Trace   = Ply:GetEyeTrace()
        local LookEnt = Trace.Entity
        if IsValid(LookEnt) and LookEnt.IsGMMRadio and Trace.HitPos:DistToSqr(Ply:EyePos()) < LookDistSqr then
            Target = LookEnt
        elseif IsValid(ShownRadio) and CurTime() < ShownUntil then
            Target = ShownRadio
        end

        if Target ~= nil then PanelRadio = Target end

        PanelAlpha = Lerp(math.min(FrameTime() * 8, 1), PanelAlpha, Target ~= nil and 1 or 0)
        if PanelAlpha < 0.01 then return end
        if not IsValid(PanelRadio) then return end

        PanelRadio:DrawRadioPanel(PanelAlpha)
    end)

    -- ----------------------------------------------------------------------
    -- Меню
    -- ----------------------------------------------------------------------

    local function SendAction(Radio, Action)
        if not IsValid(Radio) then return end

        net.Start("gmm_radio_Action")
        net.WriteEntity(Radio)
        net.WriteUInt(Action, 4)
        net.SendToServer()
    end

    local function CreateMenuButton(Parent, X, Y, Width, Height, Id, GetLabel, OnClick)
        local Button = vgui.Create("DButton", Parent)
        Button:SetPos(X, Y)
        Button:SetSize(Width, Height)
        Button:SetText("")

        Button.ClickTime = -10

        Button.Paint = function(Self, PaintW, PaintH)
            local Radio  = Parent.Radio
            local Accent = IsValid(Radio) and GetAccent(Radio) or ColorOff
            local Hover  = Self:IsHovered()
            local Time   = CurTime()
            local Flash  = math.Clamp(1 - (Time - Self.ClickTime) / 0.18, 0, 1)

            surface.SetDrawColor(Accent.r, Accent.g, Accent.b, 14 + (Hover and 30 or 0) + Flash * 170)
            surface.DrawRect(0, 0, PaintW, PaintH)

            surface.SetDrawColor(Accent.r, Accent.g, Accent.b, Hover and 255 or 140)
            surface.DrawOutlinedRect(0, 0, PaintW, PaintH, 1)

            if Hover then
                surface.SetDrawColor(Accent.r, Accent.g, Accent.b, 70)
                surface.DrawOutlinedRect(4, 4, PaintW - 8, PaintH - 8, 1)
            end

            local OffsetX = 0
            if Flash > 0 then
                OffsetX = math.floor((Hash(Time * 90) - 0.5) * 8 * Flash)
            end

            if Flash > 0.5 then
                SetColor(ColorTemp, 8, 8, 12, 255)
            else
                SetColor(ColorTemp, 235, 235, 240, 255)
            end

            draw.SimpleText(Garble(GetLabel(), Id), "gmm_radio_Button", PaintW / 2 + OffsetX, PaintH / 2, ColorTemp, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        Button.DoClick = function(Self)
            Self.ClickTime = CurTime()
            surface.PlaySound("buttons/button14.wav")
            OnClick()
        end

        return Button
    end

    local function OpenMenu(Radio)
        if not IsValid(Radio) then return end

        if not GMM.Func.DoEntitiesUnlock() then
            surface.PlaySound("ambient/voices/squeal1.wav")
            return
        end

        if IsValid(GMM.RadioMenuPanel) then GMM.RadioMenuPanel:Remove() end

        local InnerW = MenuW - 32

        local Menu = vgui.Create("DPanel")
        Menu:SetSize(MenuW, MenuH)
        local BaseX = math.floor(ScrW() / 2 - MenuW / 2)
        local BaseY = ScrH() - MenuH - 90

        Menu:SetPos(BaseX, BaseY)
        Menu:MakePopup()
        Menu:SetKeyboardInputEnabled(false)

        Menu.Radio    = Radio
        Menu.OpenTime = CurTime()

        GMM.RadioMenuPanel = Menu

        Menu.Think = function(Self)
            local Ply    = LocalPlayer()
            local Target = Self.Radio

            if not IsValid(Ply) or not IsValid(Target) or Ply:GetPos():DistToSqr(Target:GetPos()) > MenuDistanceSqr then
                Self:Remove()
                return
            end

            local OffX = 0
            local OffY = 0

            if IsChaos(Target) then
                local Tick = math.floor(RealTime() * 20)

                if Hash(Tick * 1.9) > 0.8 then
                    OffX = math.floor((Hash(Tick * 3.3) - 0.5) * 24)
                    OffY = math.floor((Hash(Tick * 5.7) - 0.5) * 10)
                end
            end

            Self:SetPos(BaseX + OffX, BaseY + OffY)
        end

        Menu.Paint = function(Self, PaintW, PaintH)
            local Target = Self.Radio
            if not IsValid(Target) then return end

            ApplyWeirdness(Target)

            local Time = CurTime()
            if Time - Self.OpenTime < 0.2 and Hash(Time * 80) < 0.4 then return end
            if IsChaos(Target) and Hash(math.floor(Time * 30) * 1.3) < 0.08 then return end

            local Accent    = GetAccent(Target)
            local Variant   = GetVariantDef(Target:GetVariant())
            local StatusKey = GetStatusKey(Target)
            local Status    = Garble(PickWord(GetStatusWords(Target, StatusKey), 12), 12)
            local Index     = Target:GetTrackIndex()

            surface.SetDrawColor(8, 8, 12, 245)
            surface.DrawRect(0, 0, PaintW, PaintH)

            surface.SetDrawColor(Accent.r, Accent.g, Accent.b, 220)
            surface.DrawOutlinedRect(0, 0, PaintW, PaintH, 1)

            surface.SetDrawColor(Accent.r, Accent.g, Accent.b, 50)
            surface.DrawOutlinedRect(5, 5, PaintW - 10, PaintH - 10, 1)

            draw.SimpleText(Garble("RAD-10 :: MENU", 11), "gmm_radio_Small", 16, 12, SetColor(ColorTemp, 160, 160, 170, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText(Status, "gmm_radio_Small", 150, 12, SetColor(ColorTemp, Accent.r, Accent.g, Accent.b, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText(Garble(Variant.Title, 13), "gmm_radio_Small", PaintW - 48, 12, SetColor(ColorTemp, Variant.Color.r, Variant.Color.g, Variant.Color.b, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)

            local ScreenX, ScreenY = Self:LocalToScreen(0, 0)
            local Title = Garble(GetTitleText(Target, Index), 10)

            DrawMarquee(Title, "gmm_radio_Big", 18, 35, InnerW, Target.RadioScrollStart or Time, SetColor(ColorTemp, Accent.r, Accent.g, Accent.b, 70), ScreenX, ScreenY)
            DrawMarquee(Title, "gmm_radio_Big", 16, 34, InnerW, Target.RadioScrollStart or Time, SetColor(ColorTemp, 235, 235, 240, 255), ScreenX, ScreenY)

            DrawProgress(Target, 16, 78, InnerW, 1, Accent)

            draw.SimpleText(string.format("%03d / %03d  //  %s", Index, #Tracks, ModeNames[Target:GetMode()] or "?"), "gmm_radio_Tiny", 16, PaintH - 28, SetColor(ColorTemp, 110, 110, 120, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText(Garble("MOVE AWAY TO CLOSE", 14), "gmm_radio_Tiny", PaintW - 16, PaintH - 28, SetColor(ColorTemp, 110, 110, 120, 200), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
            Target:DrawChaosNoise(0, 0, PaintW, PaintH, 1)
        end

        local function GetPauseLabel()
            if IsValid(Menu.Radio) and Menu.Radio:GetPlaying() then return "|| PAUSE" end
            return "> PLAY"
        end

        local function GetModeLabel()
            if not IsValid(Menu.Radio) then return "MODE: ?" end
            return "MODE: " .. (ModeNames[Menu.Radio:GetMode()] or "?")
        end

        local ThirdW = math.floor((InnerW - 24) / 3)
        local HalfW  = math.floor((InnerW - 12) / 2)

        CreateMenuButton(Menu, 16,                    108, ThirdW, 46, 21, function() return "<< PREV" end, function() SendAction(Menu.Radio, ActionPrev)   end)
        CreateMenuButton(Menu, 16 + ThirdW + 12,      108, ThirdW, 46, 22, GetPauseLabel,                  function() SendAction(Menu.Radio, ActionToggle) end)
        CreateMenuButton(Menu, 16 + (ThirdW + 12) * 2, 108, ThirdW, 46, 23, function() return "NEXT >>" end, function() SendAction(Menu.Radio, ActionNext)   end)

        CreateMenuButton(Menu, 16,               166, HalfW, 46, 24, GetModeLabel,                         function() SendAction(Menu.Radio, ActionMode)   end)
        CreateMenuButton(Menu, 16 + HalfW + 12,  166, HalfW, 46, 25, function() return "[?] RANDOM TRACK" end, function() SendAction(Menu.Radio, ActionRandom) end)

        CreateMenuButton(Menu, MenuW - 36, 8, 26, 22, 26, function() return "X" end, function() Menu:Remove() end)
    end

    hook.Add("PlayerBindPress", "gmm_radio_OpenMenu", function(Ply, Bind, Pressed)
        if not Pressed then return end
        if string.find(Bind, "+use", 1, true) == nil then return end
        if not IsValid(Ply) or not Ply:KeyDown(IN_DUCK) then return end

        local Trace = Ply:GetEyeTrace()
        local Ent   = Trace.Entity

        if not IsValid(Ent) or not Ent.IsGMMRadio then return end
        if Trace.HitPos:DistToSqr(Ply:EyePos()) > LookDistSqr then return end

        OpenMenu(Ent)
        return true
    end)

    if properties ~= nil then
        properties.Add("gmm_radio_menu", {
            MenuLabel = "Radio menu",
            Order     = 1500,
            MenuIcon  = "icon16/cd.png",
            Filter    = function(Self, Ent, Ply) return IsValid(Ent) and Ent.IsGMMRadio == true end,
            Action    = function(Self, Ent) OpenMenu(Ent) end
        })
    end
end