GMM_C = GMM_C or {}

if GMM_C.CoreTab ~= nil and GMM_C.CoreTab.SaveExplore ~= nil then GMM_C.CoreTab.SaveExplore() end

GMM_C.CoreTab = {}

timer.Remove("gmm_Core_Sample")
timer.Remove("gmm_Core_NavTimeout")

surface.CreateFont("gmm_Core_Huge",  {font = "Consolas", size = 54, weight = 800, extended = true})
surface.CreateFont("gmm_Core_Big",   {font = "Consolas", size = 26, weight = 800, extended = true})
surface.CreateFont("gmm_Core_Text",  {font = "Consolas", size = 16, weight = 500, extended = true})
surface.CreateFont("gmm_Core_Small", {font = "Consolas", size = 13, weight = 400, extended = true})

-- ----------------------------------------------------------------------
-- Данные
-- ----------------------------------------------------------------------

local Links = {
    {Name = "\"Адекватная\" версия", Note = "Лучше скачать этот аддон для полный картины", Url = "https://steamcommunity.com/sharedfiles/filedetails/?id=3776326993", Image = "vgui/gmm/adekvat.png"},
    {Name = "TOILETMAP", Note = "КАРТА МОЕГО ДРУГА, СКАЧАЙТЕ", Url = "https://steamcommunity.com/sharedfiles/filedetails/?id=3816052042", Image = "vgui/gmm/toilet.png"},
    {Name = "Evangelium", Note = "Нейрослоп", Url = "https://woowz11.github.io/woowzsite/Lituism/Lituism-manifest", Image = "vgui/gmm/manifest.png"},
}

local MapList = {
    {Key = "Default", Name = "DEFAULT"},
    {Key = "Flood",   Name = "FLOOD"},
    {Key = "Old",     Name = "OLD"},
    {Key = "Real",    Name = "REAL"},
    {Key = "Dark",    Name = "DARK"},
    {Key = "Goofy",   Name = "GOOFY"},
    {Key = "Pavel",   Name = "PAVEL"},
    {Key = "Toilet",  Name = "TOILET"}
}

local MapKnown = {}
for i = 1, #MapList do MapKnown[MapList[i].Key] = true end

local MapAlias = {SToilet = "Toilet", Stoilet = "Toilet", ToiletMap = "Toilet"}

local Pages = {
    {
        Title = "ПИСЬМО_0.TXT",
        Text  = {
            "Ты открыл это не первым.",
            "",
            "Есть место, где свет уходит вниз. Оно есть на каждой карте, но дыра есть только на неадекватной.",
            "",
            "Минус тысяча четыреста восемьдесят девять.",
            "Две тысячи пятьсот двадцать четыре.",
            "Минус четыреста тридцать восемь.",
            "",
            "Приди туда и постой. Я узнаю."
        }
    },
    {
        Title = "ПИСЬМО_1.TXT",
        Maps  = true,
        Text  = {
            "Оно тебя запомнило.",
            "",
            "Теперь выйди за пределы.",
            "",
            "Побывай на каждой карте. Пройди её хотя бы на восемьдесят процентов.",
            "Я буду считать."
        }
    },
    {
        Title = "ПИСЬМО_2.TXT",
        Text  = {
            "Ты был везде. Я посчитал.",
            "",
            "Камни вокруг тебя пишут. Все зелёным. Одна красным.",
            "Она редкая. Найди её и посмотри. Не отводи взгляд."
        }
    },
    {
        Title = "ПИСЬМО_3.TXT",
        Text  = {
            "Всё это время ты слушал тишину.",
            "",
            "Один приёмник не умеет молчать. Он жёлтый, как предупреждение. Разбуди его.",
            "",
            "Есть шахта, у которой нет дна. Пять тысяч двести пятьдесят четыре. Девятьсот семь. Минус две тысячи шестьдесят восемь.",
            "",
            "Отдай ему дорогу вниз. Потом иди следом. Вы должны долететь вместе."
        }
    },
    {
        Title = "ПИСЬМО_4.TXT",
        Text  = {
            "Ты слышал. Это правильно.",
            "",
            "Дверь №0 всегда справа. Она нарисована на тебе.",
            "",
            "Ты не первый здесь.",
            "И не последний."
        }
    }
}

local Whispers = {
    "ты смотришь на меня?",
    "дверь №0 всегда справа",
    "не считай ступеньки",
    "тень не твоя",
    "лишний пол уже под тобой",
    "кнопку не нажимали. честно",
    "0x47554C"
}

local RefuseLines = {"Я же просил.", "Ты опять?", "Хватит.", "Это не смешно.", "Ладно. Смотри."}
local Glyphs      = {"0", "1", "#", "@", "%", "?", "/", "\\", "<", ">", "x", "▒", "░", "ж", "щ", "G", "U", "L"}
local RainGlyphs  = {"0", "1", "#", "@", "?", "/", "<", ">", "x", "▒", "░", "ж", "ы", "4", "7", "G", "U", "L"}

local CookieArg     = "gmm_core_arg"
local CookieExplore = "gmm_core_explore_"
local CookiePresses = "gmm_core_presses"
local CookieShowMap = "gmm_core_showmap"

local HolePos     = Vector(-1489, 2524, -438)
local HoleDistSqr = 300 * 300

local StareSeconds = 2
local StareDistSqr = 600 * 600
local WatchDelay   = 0.25

local ExploreGoal   = 0.8
local CellSize      = 512
local ViewRadiusSqr = 700 * 700
local SaveDelay     = 1
local SampleDelay   = 0.05
local SampleBudget  = 0.003
local SampleLimit   = 16384
local SampleStepZ   = 256
local FallbackTotal = 200

local NavWaitSeconds  = 3
local NavRetrySeconds = 30

local TunnelPos       = Vector(5254, 907, -2068)
local TunnelRadiusSqr = 400 * 400
local FallSpeed       = 600
local FallGrace       = 2
local RadioLoud       = 1
local RadioDistSqr    = 500 * 500

local Pad       = 12
local BannerH   = 140
local CanvasH   = 88
local LinkH     = 72
local ButtonH   = 34
local GridGap   = 6
local ArgTextY  = 74
local ArgLineH  = 20
local ArgTabW   = 34
local MapRowH   = 20
local ToggleH   = 20
local ToggleW   = 280
local ViewH     = 220

local WhisperTime  = 5
local WhisperSpeed = 12

local CorruptIdle  = 0.07
local CorruptBurst = 0.4

local TwoPi = math.pi * 2

-- ----------------------------------------------------------------------
-- Цвета и общие функции
-- ----------------------------------------------------------------------

local ColorBack     = Color(7,   7,   9,   255)
local ColorBone     = Color(208, 202, 190, 255)
local ColorDim      = Color(112, 108, 104, 255)
local ColorFaint    = Color(52,  50,  52,  255)
local ColorRed      = Color(205, 25,  38,  255)
local ColorRedDark  = Color(88,  10,  16,  255)
local ColorSplitR   = Color(255, 0,   60,  150)
local ColorSplitC   = Color(0,   230, 255, 150)
local ColorChatTag  = Color(205, 25,  38,  255)
local ColorChatText = Color(208, 202, 190, 255)

local WaveColors  = {ColorSplitC, ColorSplitR, ColorBone}
local BlockColors = {ColorRed, ColorBone, ColorSplitC, ColorSplitR, ColorFaint}

local ShockUntil = 0

local function Shock(Time) ShockUntil = RealTime() + Time end

local function Hash(Value)
    local Result = math.sin(Value * 12.9898) * 43758.5453
    return Result - math.floor(Result)
end

local function SplitChars(Text)
    local Chars = {}

    for Char in string.gmatch(Text, utf8.charpattern) do
        Chars[#Chars + 1] = Char
    end

    return Chars
end

local function WrapLines(Text, Font, MaxWidth)
    surface.SetFont(Font)

    local Lines = {}
    local Line  = ""

    for Word in string.gmatch(Text, "%S+") do
        local Candidate = Word
        if Line ~= "" then Candidate = Line .. " " .. Word end

        if Line ~= "" and surface.GetTextSize(Candidate) > MaxWidth then
            Lines[#Lines + 1] = Line
            Line = Word
        else
            Line = Candidate
        end
    end

    if Line ~= "" then Lines[#Lines + 1] = Line end

    return Lines
end

local function DrawGlitchText(Text, Font, X, Y, Color, Power, AlignX, AlignY)
    if Power > 0 then
        local Slot  = math.floor(RealTime() * 14)
        local Shift = (Hash(Slot * 1.37 + X * 0.11 + Y * 0.07) - 0.5) * 2 * 3 * Power

        draw.SimpleText(Text, Font, X + Shift - 1, Y, ColorSplitR, AlignX, AlignY)
        draw.SimpleText(Text, Font, X - Shift + 1, Y, ColorSplitC, AlignX, AlignY)
    end

    draw.SimpleText(Text, Font, X, Y, Color, AlignX, AlignY)
end

local function DrawScan(w, h, Now, Alpha)
    surface.SetDrawColor(0, 0, 0, Alpha)

    for Y = 0, h, 3 do
        surface.DrawRect(0, Y, w, 1)
    end

    surface.SetDrawColor(255, 255, 255, 8)
    surface.DrawRect(0, (Now * 40) % (h + 40) - 20, w, 14)
end

local function DrawFrame(w, h, Color)
    surface.SetDrawColor(Color)
    surface.DrawOutlinedRect(0, 0, w, h, 1)

    surface.DrawRect(0,      0,      10, 2)
    surface.DrawRect(0,      0,      2,  10)
    surface.DrawRect(w - 10, 0,      10, 2)
    surface.DrawRect(w - 2,  0,      2,  10)
    surface.DrawRect(0,      h - 2,  10, 2)
    surface.DrawRect(0,      h - 10, 2,  10)
    surface.DrawRect(w - 10, h - 2,  10, 2)
    surface.DrawRect(w - 2,  h - 10, 2,  10)
end

-- ----------------------------------------------------------------------
-- Эффекты
-- ----------------------------------------------------------------------

local Fx = {Start = 0, Stop = 0, Text = ""}

local function Flash(Text, Time)
    Fx.Start = RealTime()
    Fx.Stop  = Fx.Start + Time
    Fx.Text  = Text
end

hook.Add("DrawOverlay", "gmm_Core_Fx", function()
    local Now = RealTime()
    if Now >= Fx.Stop then return end

    local Left = (Fx.Stop - Now) / (Fx.Stop - Fx.Start)
    local W    = ScrW()
    local H    = ScrH()
    local Slot = math.floor(Now * 20)

    surface.SetDrawColor(0, 0, 0, 240 * Left)
    surface.DrawRect(0, 0, W, H)

    for i = 1, 8 do
        local Y      = Hash(Slot + i * 3.1) * H
        local StripH = 2 + Hash(Slot * 1.3 + i) * 24

        if Hash(Slot + i * 7.7) < 0.5 then
            surface.SetDrawColor(205, 25, 38, 180 * Left)
        else
            surface.SetDrawColor(0, 230, 255, 120 * Left)
        end

        surface.DrawRect(0, Y, W, StripH)
    end

    if Fx.Text == "" then return end

    DrawGlitchText(Fx.Text, "gmm_Core_Big", W / 2, H / 2, ColorBone, 3 * Left, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end)

local function Say(Text)
    chat.AddText(ColorChatTag, "[GMM] ", ColorChatText, Text)
end

local function Echo(Count, StartPitch)
    for i = 1, Count do
        timer.Simple((i - 1) * 0.18, function()
            local Ply = LocalPlayer()
            if not IsValid(Ply) then return end

            Ply:EmitSound("buttons/blip1.wav", 70, StartPitch - (i - 1) * 18)
        end)
    end
end

local function ScrambleText(Length)
    local Parts = {}

    for i = 1, Length do
        Parts[i] = Glyphs[math.random(#Glyphs)]
    end

    return table.concat(Parts)
end

-- ----------------------------------------------------------------------
-- Canvas: каждый рисует свою странность
-- ----------------------------------------------------------------------

local function PaintStatic(Panel, w, h, Now, Power)
    local Cell   = 6
    local Chance = 0.16 * Power
    local Slot   = math.floor(Now * 14)

    for Y = 0, h - Cell, Cell do
        for X = 0, w - Cell, Cell do
            if math.random() < Chance then
                local Value = math.random(50, 255)

                surface.SetDrawColor(Value, Value, Value, 190)
                surface.DrawRect(X, Y, Cell, Cell)
            end
        end
    end

    local TearY = math.floor(Hash(Slot) * h)

    surface.SetDrawColor(ColorSplitR)
    surface.DrawRect(0, TearY, w, 3)
    surface.SetDrawColor(ColorSplitC)
    surface.DrawRect(0, TearY + 3, w, 2)

    if Hash(Slot * 1.7) < 0.15 then
        draw.SimpleText("NO SIGNAL", "gmm_Core_Big", w / 2, h / 2, ColorBone, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

local function PaintRain(Panel, w, h, Now, Power)
    local Step    = 14
    local Columns = math.floor(w / Step)
    local Rows    = math.floor(h / Step) + 1
    local Slot    = math.floor(Now * 3)

    surface.SetFont("gmm_Core_Small")

    for Column = 1, Columns do
        local Speed = 3 + Hash(Column) * 7
        local Head  = (Now * Speed * Power + Hash(Column * 3.1) * 40) % (Rows + 8)

        for Trail = 0, 5 do
            local Row = math.floor(Head) - Trail

            if Row >= 0 and Row < Rows then
                local Glyph = RainGlyphs[math.floor(Hash(Column * 7 + Row * 13 + Slot) * #RainGlyphs) + 1]
                local Fade  = 1 - Trail / 6

                if Trail == 0 then
                    surface.SetTextColor(255, 230, 230, 255)
                else
                    surface.SetTextColor(math.floor(205 * Fade), math.floor(25 * Fade), math.floor(38 * Fade), 255)
                end

                surface.SetTextPos((Column - 1) * Step + 2, Row * Step)
                surface.DrawText(Glyph)
            end
        end
    end
end

local function PaintEyes(Panel, w, h, Now, Power)
    local Count   = 5
    local Hot     = Panel:IsHovered()
    local Mx, My  = Panel:CursorPos()
    local Watcher = math.floor(Now / 3) % Count + 1
    local EyeW    = math.min(56, w / Count - 8)

    for i = 1, Count do
        local Cx = w * (i - 0.5) / Count
        local Cy = h / 2 + 4 + math.sin(Now * 0.8 + i) * 4

        local Period = 3 + i * 0.37
        local Phase  = (Now + i * 0.9) % Period
        local Lid    = 0

        if Phase > Period - 0.2 then
            Lid = 1 - math.abs(Phase - (Period - 0.1)) / 0.1
        end

        local Height = math.max(30 * (1 - Lid), 2)

        draw.RoundedBox(Height / 2 + 1, Cx - EyeW / 2 - 1, Cy - Height / 2 - 1, EyeW + 2, Height + 2, ColorRedDark)
        draw.RoundedBox(Height / 2,     Cx - EyeW / 2,     Cy - Height / 2,     EyeW,     Height,     ColorBone)

        local Radius = math.min(11, Height / 2 - 1)

        if Radius >= 2 then
            if i == Watcher then
                draw.RoundedBox(Radius, Cx - Radius, Cy - Radius, Radius * 2, Radius * 2, ColorRed)
                draw.RoundedBox(2,      Cx - 2,      Cy - 2,      4,          4,          ColorBack)
            else
                local Ox = math.sin(Now * 0.7 + i * 1.9) * 9
                local Oy = math.cos(Now * 0.5 + i) * 3

                if Hot then
                    local Dx   = Mx - Cx
                    local Dy   = My - Cy
                    local Dist = math.sqrt(Dx * Dx + Dy * Dy)

                    if Dist > 1 then
                        local Move = math.min(Dist / 5, 10)

                        Ox = Dx / Dist * Move
                        Oy = Dy / Dist * Move * 0.4
                    end
                end

                draw.RoundedBox(Radius, Cx + Ox - Radius, Cy + Oy - Radius, Radius * 2, Radius * 2, ColorBack)

                surface.SetDrawColor(ColorRed)
                surface.DrawRect(Cx + Ox - 1, Cy + Oy - 1, 2, 2)
            end
        end
    end
end

local function PaintTunnel(Panel, w, h, Now, Power)
    local Cx    = w / 2
    local Cy    = h / 2
    local Count = 12
    local Slot  = math.floor(Now * 10)

    for i = 0, Count - 1 do
        local T     = (i / Count + Now * 0.25 * Power) % 1
        local Scale = T * T * 1.2
        local W     = w * Scale
        local H     = h * Scale
        local Shift = 0

        if Hash(Slot + i) < 0.04 * Power then Shift = (Hash(Slot * 2.3 + i) - 0.5) * 24 end

        surface.SetDrawColor(205, 25, 38, 255 * T)
        surface.DrawOutlinedRect(Cx - W / 2 + Shift, Cy - H / 2, W, H, 1)

        surface.SetDrawColor(0, 230, 255, 70 * T)
        surface.DrawOutlinedRect(Cx - W / 2 + Shift + 2, Cy - H / 2 + 1, W, H, 1)
    end

    if Hash(Slot * 1.9) > 0.3 then
        surface.SetDrawColor(ColorBone)
        surface.DrawRect(Cx - 2, Cy - 2, 4, 4)
    end
end

local function PaintWave(Panel, w, h, Now, Power)
    local Mid    = h / 2 + 6
    local Slot   = math.floor(Now * 12)
    local Spike  = Hash(Slot) < 0.14 * Power
    local SpikeX = Hash(Slot * 2.1) * w

    for Line = 1, 3 do
        surface.SetDrawColor(WaveColors[Line])

        local Amp   = (10 + Line * 4) * (0.5 + 0.5 * math.sin(Now * 0.7 + Line)) * (0.6 + Power * 0.4)
        local PrevX = 0
        local PrevY = Mid

        for X = 0, w, 4 do
            local Y = Mid + math.sin(X * 0.04 * Line + Now * (1.5 + Line)) * Amp

            if Spike and math.abs(X - SpikeX) < 14 then Y = Y + (Hash(X + Slot) - 0.5) * 60 end
            if X > 0 then surface.DrawLine(PrevX, PrevY, X, Y) end

            PrevX = X
            PrevY = Y
        end
    end
end

local function PaintBlocks(Panel, w, h, Now, Power)
    local Slot  = math.floor(Now * 9)
    local Count = 6 + math.floor(Power * 3)

    for i = 1, Count do
        local Seed = Slot * 17.3 + i * 3.7

        local X = Hash(Seed) * w
        local Y = Hash(Seed + 1.1) * h
        local W = 10 + Hash(Seed + 2.2) * w * 0.5
        local H = 2 + Hash(Seed + 3.3) * 14

        surface.SetDrawColor(BlockColors[math.floor(Hash(Seed + 4.4) * #BlockColors) + 1])
        surface.DrawRect(X, Y, W, H)
    end
end

local function PaintRadar(Panel, w, h, Now, Power)
    local Cx     = w / 2
    local Cy     = h / 2 + 4
    local Radius = math.min(w, h) / 2 - 8
    local Angle  = Now * 2 * Power

    for i = 1, 3 do
        local T = (Now * 0.4 * Power + i / 3) % 1
        surface.DrawCircle(Cx, Cy, Radius * T, 205, 25, 38, 255 * (1 - T))
    end

    surface.DrawCircle(Cx, Cy, Radius, 112, 108, 104, 120)

    surface.SetDrawColor(ColorRed)
    surface.DrawLine(Cx, Cy, Cx + math.cos(Angle) * Radius, Cy + math.sin(Angle) * Radius)

    for i = 1, 4 do
        local Contact = Hash(i * 5.1) * TwoPi
        local Dist    = (0.3 + Hash(i * 9.7) * 0.6) * Radius
        local Fade    = 1 - ((Angle - Contact) % TwoPi) / TwoPi

        surface.SetDrawColor(208, 202, 190, 255 * Fade)
        surface.DrawRect(Cx + math.cos(Contact) * Dist - 2, Cy + math.sin(Contact) * Dist - 2, 4, 4)
    end

    local Approach = Radius * (1 - (Now * 0.04) % 1)

    surface.SetDrawColor(ColorRed)
    surface.DrawRect(Cx + math.cos(2.4) * Approach - 3, Cy + math.sin(2.4) * Approach - 3, 6, 6)

    if Panel:IsHovered() then
        surface.SetDrawColor(ColorBone)
        surface.DrawRect(Cx - 2, Cy - 2, 4, 4)
    end
end

local function HexRow(Index)
    if Index % 23 == 0 then return "47 55 4C 47 55 4C 47 55", true end

    local Parts = {}

    for i = 1, 8 do
        Parts[i] = string.format("%02X", math.floor(Hash(Index * 8 + i) * 256))
    end

    return table.concat(Parts, " "), false
end

local function PaintHex(Panel, w, h, Now, Power)
    local RowH   = 14
    local Rows   = math.floor(h / RowH) + 2
    local Offset = Now * 20 * Power
    local Base   = math.floor(Offset / RowH)
    local Shift  = Offset % RowH

    surface.SetFont("gmm_Core_Small")

    for i = 0, Rows - 1 do
        local Index         = Base + i
        local Bytes, Marked = HexRow(Index)
        local Y             = i * RowH - Shift

        surface.SetTextColor(ColorFaint)
        surface.SetTextPos(10, Y)
        surface.DrawText(string.format("%04X", (Index * 8) % 65536))

        if Marked then
            surface.SetTextColor(ColorRed)
        else
            surface.SetTextColor(ColorBone)
        end

        surface.SetTextPos(56, Y)
        surface.DrawText(Bytes)
    end
end

local function PaintClock(Panel, w, h, Now, Power)
    local Cx     = w / 2
    local Cy     = h / 2 + 4
    local Radius = math.min(w, h) / 2 - 10
    local Step   = TwoPi / 13
    local Top    = math.pi / 2

    surface.DrawCircle(Cx, Cy, Radius, 208, 202, 190, 255)

    surface.SetDrawColor(ColorDim)

    for i = 0, 12 do
        local Angle = i * Step - Top
        local Cos   = math.cos(Angle)
        local Sin   = math.sin(Angle)

        surface.DrawLine(Cx + Cos * (Radius - 6), Cy + Sin * (Radius - 6), Cx + Cos * Radius, Cy + Sin * Radius)
    end

    local Tick = math.floor(Now * 3 * Power)
    if Hash(Tick) < 0.14 then Tick = Tick - 2 end

    local Second = Tick * Step - Top
    local Minute = Now * 0.3 - Top
    local Hour   = -Now * 0.05 - Top

    surface.SetDrawColor(ColorBone)
    surface.DrawLine(Cx, Cy, Cx + math.cos(Minute) * Radius * 0.75, Cy + math.sin(Minute) * Radius * 0.75)
    surface.DrawLine(Cx, Cy, Cx + math.cos(Hour) * Radius * 0.5, Cy + math.sin(Hour) * Radius * 0.5)

    surface.SetDrawColor(ColorRed)
    surface.DrawLine(Cx, Cy, Cx + math.cos(Second) * Radius * 0.9, Cy + math.sin(Second) * Radius * 0.9)

    draw.SimpleText("13", "gmm_Core_Small", Cx, Cy - Radius + 14, ColorRed, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

local Canvases = {
    {Name = "STATIC", Paint = PaintStatic},
    {Name = "RAIN",   Paint = PaintRain},
    {Name = "EYES",   Paint = PaintEyes},
    {Name = "TUNNEL", Paint = PaintTunnel},
    {Name = "WAVE",   Paint = PaintWave},
    {Name = "BLOCKS", Paint = PaintBlocks},
    {Name = "RADAR",  Paint = PaintRadar},
    {Name = "HEX",    Paint = PaintHex},
    {Name = "CLOCK",  Paint = PaintClock}
}

local function CreateCanvas(Info)
    local Canvas = vgui.Create("DPanel")
    Canvas:SetTall(CanvasH)
    Canvas:SetCursor("hand")

    surface.SetFont("gmm_Core_Small")

    Canvas.ShockUntil = 0
    Canvas.LabelW     = surface.GetTextSize(Info.Name)

    Canvas.Paint = function(self, w, h)
        local Now   = RealTime()
        local Power = 1

        if self:IsHovered() then Power = 2 end
        if Now < self.ShockUntil or Now < ShockUntil then Power = 5 end

        surface.SetDrawColor(ColorBack)
        surface.DrawRect(0, 0, w, h)

        Info.Paint(self, w, h, Now, Power)

        DrawScan(w, h, Now, 50)

        surface.SetDrawColor(0, 0, 0, 170)
        surface.DrawRect(2, 2, self.LabelW + 14, 17)

        DrawGlitchText(Info.Name, "gmm_Core_Small", 8, 4, ColorBone, Power - 1)

        if Power > 1 then
            DrawFrame(w, h, ColorRed)
        else
            DrawFrame(w, h, ColorFaint)
        end
    end

    Canvas.OnMousePressed = function(self, Code)
        self.ShockUntil = RealTime() + 0.6
        surface.PlaySound("buttons/blip1.wav")
    end

    return Canvas
end

-- ----------------------------------------------------------------------
-- Баннер
-- ----------------------------------------------------------------------

local WhisperChars = {}
for i = 1, #Whispers do WhisperChars[i] = SplitChars(Whispers[i]) end

local function CreateBanner()
    local Banner = vgui.Create("DPanel")
    Banner:SetTall(BannerH)
    Banner:SetCursor("hand")

    Banner.ScrambleUntil = 0
    Banner.ShownIndex    = 0
    Banner.ShownCount    = -1
    Banner.ShownText     = ""
    Banner.ShownW        = 0

    Banner.Paint = function(self, w, h)
        local Now    = RealTime()
        local Slot   = math.floor(Now * 10)
        local Glitch = Hash(Slot) < 0.12 or Now < ShockUntil
        local Power  = 0.5

        if Glitch then Power = 3 end

        surface.SetDrawColor(ColorBack)
        surface.DrawRect(0, 0, w, h)

        DrawGlitchText("GMM",   "gmm_Core_Huge", 16, 10, ColorBone, Power)
        DrawGlitchText(".core", "gmm_Core_Text", 20, 74, ColorRed,  Power * 0.5)

        draw.SimpleText("НАБЛЮДЕНИЕ", "gmm_Core_Small", w - 16, 14, ColorDim, TEXT_ALIGN_RIGHT)

        if math.floor(Now * 1.5) % 2 == 0 then
            draw.SimpleText("●", "gmm_Core_Small", w - 112, 13, ColorRed, TEXT_ALIGN_RIGHT)
        end

        local Index = math.floor(Now / WhisperTime) % #Whispers + 1
        local Chars = WhisperChars[Index]
        local Count = math.min(math.floor((Now % WhisperTime) * WhisperSpeed), #Chars)

        if Count ~= self.ShownCount or Index ~= self.ShownIndex then
            self.ShownCount = Count
            self.ShownIndex = Index

            local Parts = {}
            for i = 1, Count do Parts[i] = Chars[i] end

            self.ShownText = table.concat(Parts)

            surface.SetFont("gmm_Core_Text")
            self.ShownW = surface.GetTextSize(self.ShownText)
        end

        local Text = self.ShownText
        if Now < self.ScrambleUntil then Text = ScrambleText(Count) end

        draw.SimpleText(Text, "gmm_Core_Text", 16, h - 28, ColorDim)

        if math.floor(Now * 2) % 2 == 0 then
            draw.SimpleText("_", "gmm_Core_Text", 16 + self.ShownW, h - 28, ColorDim)
        end

        if Glitch then
            for i = 1, 3 do
                local Y = Hash(Slot + i * 2.7) * h

                surface.SetDrawColor(ColorBack)
                surface.DrawRect(0, Y, w, 5)
                surface.SetDrawColor(ColorRed)
                surface.DrawRect(0, Y + 5, w, 1)
            end
        end

        DrawScan(w, h, Now, 55)
        DrawFrame(w, h, ColorDim)
    end

    Banner.OnMousePressed = function(self, Code)
        self.ScrambleUntil = RealTime() + 1
        Shock(0.6)
        surface.PlaySound("buttons/blip1.wav")
    end

    return Banner
end

-- ----------------------------------------------------------------------
-- Заголовки и ссылки
-- ----------------------------------------------------------------------

local function CreateHeader(Panel, Text)
    local Header = vgui.Create("DPanel")
    Header:SetTall(30)

    Header.Paint = function(self, w, h)
        local Power = 0
        if Hash(math.floor(RealTime() * 8) + #Text) < 0.06 then Power = 2 end

        DrawGlitchText(Text, "gmm_Core_Text", 0, h / 2, ColorBone, Power, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        surface.SetDrawColor(ColorRedDark)
        surface.DrawRect(0, h - 2, w, 1)
    end

    Panel:AddItem(Header)

    return Header
end

local function CreateLinkRow(Panel, Info)
    local Row = vgui.Create("DButton")
    Row:SetText("")
    Row:SetTall(LinkH)
    Row:SetCursor("hand")

    Row.Info     = Info
    Row.Image    = nil
    Row.ShownUrl = string.gsub(Info.Url, "^https?://", "")

    if #Row.ShownUrl > 32 then Row.ShownUrl = string.sub(Row.ShownUrl, 1, 31) .. "…" end

    if Info.Image ~= "" then
        local Mat = Material(Info.Image, "smooth")
        if not Mat:IsError() then Row.Image = Mat end
    end

    Row.Paint = function(self, w, h)
        local Now = RealTime()
        local Hot = self:IsHovered()

        surface.SetDrawColor(ColorBack)
        surface.DrawRect(0, 0, w, h)

        local Size = h - 16

        surface.SetDrawColor(ColorFaint)
        surface.DrawRect(8, 8, Size, Size)

        if self.Image then
            surface.SetMaterial(self.Image)

            if Hot then
                local Shift = 2 + math.sin(Now * 30) * 2

                surface.SetDrawColor(255, 40, 80, 150)
                surface.DrawTexturedRect(8 - Shift, 8, Size, Size)
                surface.SetDrawColor(0, 230, 255, 120)
                surface.DrawTexturedRect(8 + Shift, 8, Size, Size)
            end

            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRect(8, 8, Size, Size)
        else
            draw.SimpleText("?", "gmm_Core_Big", 8 + Size / 2, 8 + Size / 2, ColorDim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        local Power = 0
        if Hot then Power = 1.2 end

        DrawGlitchText(self.Info.Name, "gmm_Core_Text", Size + 20, 12, ColorBone, Power)

        draw.SimpleText(self.Info.Note, "gmm_Core_Small", Size + 20, 34, ColorDim)
        draw.SimpleText(self.ShownUrl,  "gmm_Core_Small", Size + 20, 50, ColorFaint)

        if Hot or math.floor(Now * 2) % 2 == 0 then
            draw.SimpleText(">>", "gmm_Core_Text", w - 14, h / 2, ColorRed, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end

        if Hot then
            DrawFrame(w, h, ColorRed)
        else
            DrawFrame(w, h, ColorFaint)
        end
    end

    Row.DoClick = function(self)
        surface.PlaySound("buttons/blip1.wav")
        gui.OpenURL(self.Info.Url)
    end

    Panel:AddItem(Row)

    return Row
end

-- ----------------------------------------------------------------------
-- АРГ: прогресс
-- ----------------------------------------------------------------------

local ArgState = {Unlocked = 1, Page = 1, Stare = 0}

local ShowExplored = cookie.GetNumber(CookieShowMap, 0) == 1

local function LoadArg()
    ArgState.Unlocked = math.Clamp(cookie.GetNumber(CookieArg, 1), 1, #Pages)
    ArgState.Page     = math.Clamp(ArgState.Page, 1, ArgState.Unlocked)
end

LoadArg()

local function UnlockPage(Index)
    if Index <= ArgState.Unlocked then return end

    ArgState.Unlocked = Index
    ArgState.Stare    = 0

    cookie.Set(CookieArg, Index)

    Flash(Pages[Index].Title, 1.8)
    Say("Что-то изменилось.")
    surface.PlaySound("ambient/energy/zap9.wav")
end

local CoreKey       = nil
local CoreKeyWarned = ""

local function ResolveCoreKey()
    local Ok, Key = pcall(GMM.Func.GetMapKeyOrNil)

    if Ok and Key ~= nil then
        Key = MapAlias[Key] or Key
        if MapKnown[Key] then return Key end
    end

    if string.find(string.lower(game.GetMap()), "toilet", 1, true) then return "Toilet" end

    for i = 1, #MapList do
        local Name = MapList[i].Key

        if GMM.Maps[Name] == true or GMM.Maps["S" .. Name] == true then return Name end
    end

    return nil
end

local function GetMapKey()
    if CoreKey ~= nil then return CoreKey end

    CoreKey = ResolveCoreKey()

    if CoreKey == nil and CoreKeyWarned ~= game.GetMap() then
        CoreKeyWarned = game.GetMap()
        print("[GMM] CORE MAP KEY NOT FOUND! MAP: " .. CoreKeyWarned)
    end

    return CoreKey
end

local function FlatDistSqr(A, B)
    local Dx = A.x - B.x
    local Dy = A.y - B.y

    return Dx * Dx + Dy * Dy
end

-- ----------------------------------------------------------------------
-- АРГ: изучение карт
-- ----------------------------------------------------------------------

local Explore    = {}
local Sample     = nil
local SampledKey = nil

local Nav = {State = "None", NextAsk = 0}

local SampleStart  = Vector()
local SampleEnd    = Vector()
local SampleResult = {}
local SampleTrace  = {start = SampleStart, endpos = SampleEnd, mask = MASK_SOLID_BRUSHONLY, output = SampleResult}

local function CellId(Cx, Cy)
    return (Cx + 1024) * 2048 + (Cy + 1024)
end

local function GetExplore(Key)
    local Data = Explore[Key]
    if Data ~= nil then return Data end

    Data = {Visited = {}, Playable = nil, Total = 0, Count = 0, Dirty = false, Strict = false}

    local Saved = util.JSONToTable(cookie.GetString(CookieExplore .. Key, ""))

    if Saved ~= nil and Saved.Cells ~= nil then
        for i = 1, #Saved.Cells do
            Data.Visited[Saved.Cells[i]] = true
        end

        Data.Count = Saved.Count or #Saved.Cells
        Data.Total = Saved.Total or 0
    end

    Explore[Key] = Data

    return Data
end

local function GetProgress(Key)
    local Data = GetExplore(Key)
    if Data.Total <= 0 then return 0 end

    return math.min(Data.Count / Data.Total, 1)
end

local function SaveExplore()
    for Key, Data in pairs(Explore) do
        if Data.Dirty then
            local Cells = {}

            for Id in pairs(Data.Visited) do
                Cells[#Cells + 1] = Id
            end

            cookie.Set(CookieExplore .. Key, util.TableToJSON({Cells = Cells, Total = Data.Total, Count = Data.Count}))
            Data.Dirty = false
        end
    end
end

timer.Create("gmm_Core_Save", SaveDelay, 0, function()
    pcall(SaveExplore)
end)

hook.Add("ShutDown", "gmm_Core_Save", function()
    pcall(SaveExplore)
end)

local function MarkCell(Data, Id)
    if Data.Visited[Id] then return end

    local Playable = Data.Playable

    if Playable ~= nil and not Playable[Id] then
        if Data.Strict then return end

        Playable[Id] = true
        Data.Total   = Data.Total + 1
    end

    Data.Visited[Id] = true
    Data.Count       = Data.Count + 1
    Data.Dirty       = true
end

local function TrackExplore(Ply, Data)
    local Pos = Ply:GetPos()
    local Cx  = math.floor(Pos.x / CellSize)
    local Cy  = math.floor(Pos.y / CellSize)

    MarkCell(Data, CellId(Cx, Cy))

    if Data.Playable == nil then return end

    for Dx = -1, 1 do
        for Dy = -1, 1 do
            local Id = CellId(Cx + Dx, Cy + Dy)

            if Data.Playable[Id] and not Data.Visited[Id] then
                local CenterX = (Cx + Dx + 0.5) * CellSize - Pos.x
                local CenterY = (Cy + Dy + 0.5) * CellSize - Pos.y

                if CenterX * CenterX + CenterY * CenterY < ViewRadiusSqr then MarkCell(Data, Id) end
            end
        end
    end
end

local function HasGround(X, Y, ZMin, ZMax)
    for Z = ZMax, ZMin, -SampleStepZ do
        SampleStart:SetUnpacked(X, Y, Z)

        if bit.band(util.PointContents(SampleStart), CONTENTS_SOLID) == 0 then
            SampleEnd:SetUnpacked(X, Y, Z - SampleStepZ)
            util.TraceLine(SampleTrace)

            if SampleResult.Hit and not SampleResult.HitSky then return true end
        end
    end

    return false
end

local function FinishSample()
    local Data     = GetExplore(Sample.Key)
    local Playable = Sample.Playable
    local Total    = Sample.Total

    if Total == 0 then
        print("[GMM] CORE MAP SAMPLE FOUND NO FLOOR! MAP: " .. Sample.Key)
        Total = FallbackTotal
    end

    local Count = 0

    for Id in pairs(Data.Visited) do
        Count = Count + 1

        if not Playable[Id] then
            Playable[Id] = true
            Total        = Total + 1
        end
    end

    Data.Playable = Playable
    Data.Total    = Total
    Data.Count    = Count
    Data.Strict   = false
    Data.Dirty    = true

    Sample = nil
    timer.Remove("gmm_Core_Sample")
end

local function SampleStep()
    if Sample == nil then return end

    local Near  = CellSize * 0.25
    local Far   = CellSize * 0.75
    local Begin = SysTime()

    while SysTime() - Begin < SampleBudget do
        if Sample.Cy > Sample.MaxCy then
            FinishSample()
            return
        end

        local X0   = Sample.Cx * CellSize
        local Y0   = Sample.Cy * CellSize
        local ZMin = Sample.ZMin
        local ZMax = Sample.ZMax

        local Found = HasGround(X0 + Near, Y0 + Near, ZMin, ZMax)
        if not Found then Found = HasGround(X0 + Far, Y0 + Near, ZMin, ZMax) end
        if not Found then Found = HasGround(X0 + Near, Y0 + Far, ZMin, ZMax) end
        if not Found then Found = HasGround(X0 + Far, Y0 + Far, ZMin, ZMax) end

        if Found then
            Sample.Playable[CellId(Sample.Cx, Sample.Cy)] = true
            Sample.Total = Sample.Total + 1
        end

        Sample.Cx = Sample.Cx + 1

        if Sample.Cx > Sample.MaxCx then
            Sample.Cx = Sample.MinCx
            Sample.Cy = Sample.Cy + 1
        end
    end
end

local function SampleTick()
    local Ok, Error = pcall(SampleStep)
    if Ok then return end

    print("[GMM] CORE MAP SAMPLE FAILED! " .. tostring(Error))

    if Sample == nil then
        timer.Remove("gmm_Core_Sample")
        return
    end

    Sample.Total = 0
    FinishSample()
end

local function StartSample(Key)
    local Mins = Vector(-SampleLimit, -SampleLimit, -SampleLimit)
    local Maxs = Vector(SampleLimit, SampleLimit, SampleLimit)

    local Ok, WorldMins, WorldMaxs = pcall(function() return game.GetWorld():GetModelBounds() end)

    if Ok and WorldMins ~= nil and WorldMaxs ~= nil and WorldMins:DistToSqr(WorldMaxs) > 1 then
        Mins = WorldMins
        Maxs = WorldMaxs
    end

    local MinX = math.max(Mins.x, -SampleLimit)
    local MinY = math.max(Mins.y, -SampleLimit)
    local MaxX = math.min(Maxs.x, SampleLimit)
    local MaxY = math.min(Maxs.y, SampleLimit)

    Sample = {
        Key      = Key,
        Playable = {},
        Total    = 0,
        MinCx    = math.floor(MinX / CellSize),
        MaxCx    = math.floor(MaxX / CellSize),
        MaxCy    = math.floor(MaxY / CellSize),
        ZMin     = math.max(Mins.z, -SampleLimit),
        ZMax     = math.min(Maxs.z, SampleLimit)
    }

    Sample.Cx = Sample.MinCx
    Sample.Cy = math.floor(MinY / CellSize)

    timer.Create("gmm_Core_Sample", SampleDelay, 0, SampleTick)
end

local function RequestNav()
    net.Start("gmm_CoreNavRequest")
    net.SendToServer()
end

local function StartFallback(Key)
    if Nav.State ~= "Waiting" then return end

    Nav.State   = "Failed"
    Nav.NextAsk = RealTime() + NavRetrySeconds

    StartSample(Key)
end

local function BeginNav(Key)
    Sample = nil

    timer.Remove("gmm_Core_Sample")
    timer.Remove("gmm_Core_NavTimeout")

    Nav.State = "Waiting"

    if not pcall(RequestNav) then
        StartFallback(Key)
        return
    end

    timer.Create("gmm_Core_NavTimeout", NavWaitSeconds, 1, function()
        StartFallback(Key)
    end)
end

local function ApplyNav(Key, Set, Total)
    local Data  = GetExplore(Key)
    local Count = 0

    for Id in pairs(Data.Visited) do
        if Set[Id] then Count = Count + 1 end
    end

    Sample = nil

    timer.Remove("gmm_Core_Sample")
    timer.Remove("gmm_Core_NavTimeout")

    Data.Playable = Set
    Data.Total    = Total
    Data.Count    = Count
    Data.Strict   = true
    Data.Dirty    = true

    Nav.State = "Ready"
end

net.Receive("gmm_CoreNavData", function()
    local MapName = net.ReadString()
    local Count   = net.ReadUInt(16)
    local Set     = {}

    for i = 1, Count do
        Set[net.ReadUInt(22)] = true
    end

    if MapName ~= game.GetMap() then return end
    if Nav.State == "None" or Nav.State == "Ready" then return end

    local Key = GetMapKey()
    if Key == nil then return end

    if Count == 0 then
        StartFallback(Key)
        return
    end

    ApplyNav(Key, Set, Count)
end)

local function WatchExplore(Ply)
    local Key = GetMapKey()
    if Key == nil then return end

    if SampledKey ~= Key then
        SampledKey = Key
        BeginNav(Key)
    end

    if Nav.State == "Failed" and RealTime() >= Nav.NextAsk then
        Nav.NextAsk = RealTime() + NavRetrySeconds
        pcall(RequestNav)
    end

    TrackExplore(Ply, GetExplore(Key))
end

-- ----------------------------------------------------------------------
-- АРГ: условия
-- ----------------------------------------------------------------------

local FallUntil = 0

local function StareReset()
    ArgState.Stare = 0
    return false
end

local Conditions = {}

Conditions[2] = function(Ply)
    if not GMM.Maps.Goofy then return false end

    return Ply:GetPos():DistToSqr(HolePos) < HoleDistSqr
end

Conditions[3] = function(Ply)
    for i = 1, #MapList do
        if GetProgress(MapList[i].Key) < ExploreGoal then return false end
    end

    return true
end

Conditions[4] = function(Ply)
    local Trace = Ply:GetEyeTrace()
    local Ent   = Trace.Entity

    if not IsValid(Ent) then return StareReset() end
    if Ent.GetTextID == nil then return StareReset() end
    if not Ent:GetTextRare() then return StareReset() end
    if Ent:GetTextRandom() then return StareReset() end
    if Ent:GetTextMix() then return StareReset() end
    if Trace.HitPos:DistToSqr(Trace.StartPos) > StareDistSqr then return StareReset() end

    ArgState.Stare = ArgState.Stare + WatchDelay

    return ArgState.Stare >= StareSeconds
end

local function HasLoudRadio(Pos)
    local Radios = ents.FindByClass("gmm_radio")

    for i = 1, #Radios do
        local Radio    = Radios[i]
        local RadioPos = Radio:GetPos()

        if Radio:GetPlaying() and Radio:GetVariant() == RadioLoud then
            if RadioPos:DistToSqr(Pos) < RadioDistSqr and FlatDistSqr(RadioPos, TunnelPos) < TunnelRadiusSqr then return true end
        end
    end

    return false
end

local function IsFallingWithRadio(Ply)
    if Ply:GetVelocity().z > -FallSpeed then return false end

    local Pos = Ply:GetPos()
    if FlatDistSqr(Pos, TunnelPos) > TunnelRadiusSqr then return false end

    return HasLoudRadio(Pos)
end

local function WatchFall(Ply)
    if ArgState.Unlocked + 1 ~= #Pages then return end

    if Ply:Alive() then
        if IsFallingWithRadio(Ply) then FallUntil = RealTime() + FallGrace end
        return
    end

    if RealTime() < FallUntil then UnlockPage(#Pages) end

    FallUntil = 0
end

local WatchError = ""

local function Watch()
    local Ply = LocalPlayer()
    if not IsValid(Ply) then return end

    WatchFall(Ply)

    if not Ply:Alive() then return end
    if ArgState.Unlocked >= #Pages then return end

    WatchExplore(Ply)

    local Next  = ArgState.Unlocked + 1
    local Check = Conditions[Next]
    if Check == nil then return end

    if Check(Ply) then UnlockPage(Next) end
end

timer.Create("gmm_Core_ArgWatch", WatchDelay, 0, function()
    local Ok, Error = pcall(Watch)
    if Ok then return end

    Error = tostring(Error)
    if Error == WatchError then return end

    WatchError = Error
    print("[GMM] CORE WATCH FAILED! " .. Error)
end)

-- ----------------------------------------------------------------------
-- АРГ: панель
-- ----------------------------------------------------------------------

local function DrawMaps(w, Y)
    local Current = GetMapKey()
    local BarX    = Pad + 100
    local BarW    = w - BarX - Pad - 48
    local GoalX   = BarX + math.floor(BarW * ExploreGoal)

    for i = 1, #MapList do
        local Info      = MapList[i]
        local Data      = GetExplore(Info.Key)
        local Progress  = GetProgress(Info.Key)
        local Done      = Progress >= ExploreGoal
        local RowY      = Y + (i - 1) * MapRowH
        local Name      = Info.Name
        local Percent   = math.floor(Progress * 100) .. "%"
        local FillColor = ColorRed
        local TextColor = ColorDim

        if Info.Key == Current then Name = "> " .. Name end
        if Info.Key == Current and Data.Playable == nil then Percent = "..." end

        if Done then
            FillColor = ColorBone
            TextColor = ColorBone
        end

        draw.SimpleText(Name, "gmm_Core_Small", Pad, RowY + 3, TextColor)

        surface.SetDrawColor(ColorFaint)
        surface.DrawRect(BarX, RowY + 4, BarW, 10)

        surface.SetDrawColor(FillColor)
        surface.DrawRect(BarX, RowY + 4, math.floor(BarW * Progress), 10)

        surface.SetDrawColor(ColorBone)
        surface.DrawRect(GoalX, RowY + 2, 1, 14)

        draw.SimpleText(Percent, "gmm_Core_Small", w - Pad, RowY + 3, TextColor, TEXT_ALIGN_RIGHT)
    end
end

local ViewCache = {Key = nil, Playable = nil, DataTotal = -1, DataCount = -1, Ready = false, Empty = true, Gray = {}, Red = {}, MinCx = 0, MaxCy = 0, SpanX = 1, SpanY = 1}

local function ExpandBounds(Bounds, Id)
    local Cx = math.floor(Id / 2048) - 1024
    local Cy = Id % 2048 - 1024

    if Cx < Bounds.MinCx then Bounds.MinCx = Cx end
    if Cx > Bounds.MaxCx then Bounds.MaxCx = Cx end
    if Cy < Bounds.MinCy then Bounds.MinCy = Cy end
    if Cy > Bounds.MaxCy then Bounds.MaxCy = Cy end
end

local function GetCellState(Data, Id)
    local Playable = Data.Playable

    if Playable ~= nil and not Playable[Id] then return 0 end
    if Data.Visited[Id] then return 2 end
    if Playable ~= nil then return 1 end

    return 0
end

local function AddRun(Runs, X, Y, Length)
    local Count = #Runs

    Runs[Count + 1] = X
    Runs[Count + 2] = Y
    Runs[Count + 3] = Length
end

local function RebuildView(Key, Data)
    local Bounds   = {MinCx = math.huge, MaxCx = -math.huge, MinCy = math.huge, MaxCy = -math.huge}
    local Gray     = {}
    local Red      = {}
    local Playable = Data.Playable

    for Id in pairs(Data.Visited) do
        if Playable == nil or Playable[Id] then ExpandBounds(Bounds, Id) end
    end

    if Playable ~= nil then
        for Id in pairs(Playable) do ExpandBounds(Bounds, Id) end
    end

    ViewCache.Key       = Key
    ViewCache.Playable  = Playable
    ViewCache.DataTotal = Data.Total
    ViewCache.DataCount = Data.Count
    ViewCache.Ready     = Playable ~= nil
    ViewCache.Empty     = Bounds.MinCx == math.huge
    ViewCache.Gray      = Gray
    ViewCache.Red       = Red

    if ViewCache.Empty then return end

    local MinCx = Bounds.MinCx
    local MaxCx = Bounds.MaxCx

    ViewCache.MinCx = MinCx
    ViewCache.MaxCy = Bounds.MaxCy
    ViewCache.SpanX = MaxCx - MinCx + 1
    ViewCache.SpanY = Bounds.MaxCy - Bounds.MinCy + 1

    for Cy = Bounds.MinCy, Bounds.MaxCy do
        local Row      = Bounds.MaxCy - Cy
        local RunState = 0
        local RunStart = MinCx

        for Cx = MinCx, MaxCx + 1 do
            local State = 0
            if Cx <= MaxCx then State = GetCellState(Data, CellId(Cx, Cy)) end

            if State ~= RunState then
                if RunState == 1 then AddRun(Gray, RunStart - MinCx, Row, Cx - RunStart) end
                if RunState == 2 then AddRun(Red,  RunStart - MinCx, Row, Cx - RunStart) end

                RunState = State
                RunStart = Cx
            end
        end
    end
end

local function DrawRuns(Runs, OffX, OffY, Cell, Height)
    for i = 1, #Runs, 3 do
        surface.DrawRect(OffX + Runs[i] * Cell, OffY + Runs[i + 1] * Cell, Runs[i + 2] * Cell, Height)
    end
end

local function DrawExploreView(X, Y, W, H)
    local Now = RealTime()

    surface.SetDrawColor(ColorFaint)
    surface.DrawOutlinedRect(X, Y, W, H, 1)

    local Key = GetMapKey()

    if Key == nil then
        draw.SimpleText("КАРТА НЕ ИЗВЕСТНА", "gmm_Core_Small", X + W / 2, Y + H / 2, ColorDim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        return
    end

    local Data = GetExplore(Key)

    local Stale = ViewCache.Key ~= Key or ViewCache.DataTotal ~= Data.Total or ViewCache.DataCount ~= Data.Count
    if ViewCache.Playable ~= Data.Playable then Stale = true end
    if ViewCache.Ready ~= (Data.Playable ~= nil) then Stale = true end

    if Stale then RebuildView(Key, Data) end

    if ViewCache.Empty then
        draw.SimpleText("НЕТ ДАННЫХ", "gmm_Core_Small", X + W / 2, Y + H / 2, ColorDim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        return
    end

    local Inner = 10
    local SpanX = ViewCache.SpanX
    local SpanY = ViewCache.SpanY
    local Cell  = math.min((W - Inner * 2) / SpanX, (H - Inner * 2) / SpanY)
    local OffX  = X + (W - Cell * SpanX) / 2
    local OffY  = Y + (H - Cell * SpanY) / 2
    local Gap   = 0

    if Cell > 4 then Gap = 1 end

    local Height = Cell - Gap

    surface.SetDrawColor(ColorFaint)
    DrawRuns(ViewCache.Gray, OffX, OffY, Cell, Height)

    surface.SetDrawColor(ColorRed)
    DrawRuns(ViewCache.Red, OffX, OffY, Cell, Height)

    local Ply = LocalPlayer()

    if IsValid(Ply) and math.floor(Now * 3) % 2 == 0 then
        local Pos = Ply:GetPos()
        local Px  = OffX + (Pos.x / CellSize - ViewCache.MinCx) * Cell
        local Py  = OffY + (ViewCache.MaxCy + 1 - Pos.y / CellSize) * Cell

        surface.SetDrawColor(ColorBone)
        surface.DrawRect(Px - 2, Py - 2, 5, 5)
    end

    draw.SimpleText("КАРТА: " .. string.upper(Key), "gmm_Core_Small", X + 6, Y + 4, ColorDim)

    if Data.Playable == nil then
        draw.SimpleText("СКАНИРОВАНИЕ...", "gmm_Core_Small", X + W - 6, Y + 4, ColorRed, TEXT_ALIGN_RIGHT)
    end
end

local function GetExtraH(Page)
    if not Page.Maps then return 0 end

    local Result = #MapList * MapRowH + 8 + ToggleH + 6

    if ShowExplored then Result = Result + ViewH + 8 end

    return Result
end

local function CreateArg(Panel)
    local Arg = vgui.Create("DPanel")
    Arg:SetTall(260)

    Arg.PlainLines = {}
    Arg.LineChars  = {}
    Arg.Shown      = {}
    Arg.WrapW      = -1
    Arg.ShownPage  = 0
    Arg.CacheSlot  = -1
    Arg.ExtraH     = 0

    local Tabs = {}

    for i = 1, #Pages do
        local Number = tostring(i)

        local Tab = vgui.Create("DButton", Arg)
        Tab:SetText("")
        Tab:SetCursor("hand")

        Tab.Paint = function(self, w, h)
            if i > ArgState.Unlocked then
                surface.SetDrawColor(ColorFaint)
                surface.DrawOutlinedRect(0, 0, w, h, 1)
                draw.SimpleText("▒", "gmm_Core_Text", w / 2, h / 2, ColorFaint, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                return
            end

            if i == ArgState.Page then
                surface.SetDrawColor(ColorBone)
                surface.DrawRect(0, 0, w, h)
                draw.SimpleText(Number, "gmm_Core_Text", w / 2, h / 2, ColorBack, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                return
            end

            local Border = ColorDim
            if self:IsHovered() then Border = ColorRed end

            surface.SetDrawColor(Border)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
            draw.SimpleText(Number, "gmm_Core_Text", w / 2, h / 2, Border, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        Tab.DoClick = function()
            if i > ArgState.Unlocked then
                surface.PlaySound("buttons/button10.wav")
                return
            end

            ArgState.Page = i
            surface.PlaySound("buttons/blip1.wav")
        end

        Tabs[i] = Tab
    end

    local Toggle = vgui.Create("DButton", Arg)
    Toggle:SetText("")
    Toggle:SetCursor("hand")
    Toggle:SetVisible(false)

    Toggle.Paint = function(self, w, h)
        local Hot    = self:IsHovered()
        local Border = ColorDim
        local Power  = 0

        if Hot then
            Border = ColorRed
            Power  = 1
        end

        surface.SetDrawColor(Border)
        surface.DrawOutlinedRect(0, 3, 14, 14, 1)

        if ShowExplored then
            surface.SetDrawColor(ColorRed)
            surface.DrawRect(3, 6, 8, 8)
        end

        DrawGlitchText("ПОКАЗАТЬ ИЗУЧЕННЫЕ ОБЛАСТИ", "gmm_Core_Small", 22, h / 2, ColorBone, Power, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    Toggle.DoClick = function()
        ShowExplored = not ShowExplored

        local Value = 0
        if ShowExplored then Value = 1 end

        cookie.Set(CookieShowMap, Value)
        surface.PlaySound("buttons/blip1.wav")

        Arg:InvalidateLayout()
    end

    Arg.Rebuild = function(self, Width)
        local Page  = Pages[ArgState.Page]
        local Plain = {}
        local Chars = {}

        for i = 1, #Page.Text do
            local Paragraph = Page.Text[i]

            if Paragraph == "" then
                Plain[#Plain + 1] = ""
            else
                local Wrapped = WrapLines(Paragraph, "gmm_Core_Text", Width)

                for j = 1, #Wrapped do
                    Plain[#Plain + 1] = Wrapped[j]
                end
            end
        end

        for i = 1, #Plain do
            Chars[i] = SplitChars(Plain[i])
        end

        self.PlainLines = Plain
        self.LineChars  = Chars
        self.Shown      = {}
        self.WrapW      = Width
        self.ShownPage  = ArgState.Page
        self.CacheSlot  = -1
    end

    Arg.Corrupt = function(self, Rate)
        for i = 1, #self.PlainLines do
            if Rate <= 0 or self.PlainLines[i] == "" then
                self.Shown[i] = self.PlainLines[i]
            else
                local Chars = self.LineChars[i]
                local Parts = {}

                for j = 1, #Chars do
                    local Char = Chars[j]
                    if Char ~= " " and math.random() < Rate then Char = Glyphs[math.random(#Glyphs)] end

                    Parts[j] = Char
                end

                self.Shown[i] = table.concat(Parts)
            end
        end
    end

    Arg.PerformLayout = function(self, w, h)
        if w < 60 then return end

        for i = 1, #Tabs do
            Tabs[i]:SetPos(Pad + (i - 1) * (ArgTabW + 6), 34)
            Tabs[i]:SetSize(ArgTabW, 24)
        end

        local Width = w - Pad * 2
        if self.WrapW ~= Width or self.ShownPage ~= ArgState.Page then self:Rebuild(Width) end

        local Page    = Pages[ArgState.Page]
        local TextEnd = ArgTextY + #self.PlainLines * ArgLineH

        self.ExtraH = GetExtraH(Page)

        if Page.Maps then
            Toggle:SetVisible(true)
            Toggle:SetPos(Pad, TextEnd + 6 + #MapList * MapRowH + 4)
            Toggle:SetSize(ToggleW, ToggleH)
        else
            Toggle:SetVisible(false)
        end

        local Needed = TextEnd + self.ExtraH + 44
        if self:GetTall() ~= Needed then self:SetTall(Needed) end
    end

    Arg.Think = function(self)
        if self.ShownPage ~= ArgState.Page then self:InvalidateLayout() end
    end

    Arg.Paint = function(self, w, h)
        local Now  = RealTime()
        local Slot = math.floor(Now * 10)
        local Hot  = self:IsHovered() or self:IsChildHovered()

        surface.SetDrawColor(ColorBack)
        surface.DrawRect(0, 0, w, h)

        if Slot ~= self.CacheSlot then
            self.CacheSlot = Slot

            local Rate = CorruptIdle

            if Hot then
                Rate = 0
            elseif Hash(Slot) < 0.05 then
                Rate = CorruptBurst
            end

            self:Corrupt(Rate)
        end

        local TitlePower = 0
        if Hash(Slot * 1.9) < 0.08 then TitlePower = 2 end

        draw.SimpleText("ДОКУМЕНТ " .. ArgState.Page .. "/" .. #Pages, "gmm_Core_Small", Pad, 12, ColorDim)
        DrawGlitchText(Pages[ArgState.Page].Title, "gmm_Core_Text", w - Pad, 10, ColorRed, TitlePower, TEXT_ALIGN_RIGHT)

        local Count      = #self.Shown
        local GlitchLine = 0

        if Count > 0 and not Hot and Hash(Slot * 3.3) < 0.3 then
            GlitchLine = math.floor(Hash(Slot * 0.77) * Count) + 1
        end

        for i = 1, Count do
            local Line = self.Shown[i]

            if Line ~= "" then
                local Y = ArgTextY + (i - 1) * ArgLineH

                if i == GlitchLine then
                    DrawGlitchText(Line, "gmm_Core_Text", Pad, Y, ColorBone, 2)
                else
                    draw.SimpleText(Line, "gmm_Core_Text", Pad, Y, ColorBone)
                end
            end
        end

        local TextEnd = ArgTextY + #self.PlainLines * ArgLineH

        if self.ExtraH > 0 then
            DrawMaps(w, TextEnd + 6)

            if ShowExplored then DrawExploreView(Pad, TextEnd + 6 + #MapList * MapRowH + 4 + ToggleH + 6, w - Pad * 2, ViewH) end
        end

        local FooterY = TextEnd + self.ExtraH + 14

        if ArgState.Unlocked < #Pages then
            if ArgState.Page == ArgState.Unlocked then
                draw.SimpleText("▒▒▒ СЛЕДУЮЩИЙ ДОКУМЕНТ ЗАКРЫТ ▒▒▒", "gmm_Core_Small", Pad, FooterY, ColorFaint)
            end
        else
            draw.SimpleText("— КОНЕЦ —", "gmm_Core_Small", Pad, FooterY, ColorRedDark)
        end

        DrawScan(w, h, Now, 40)
        DrawFrame(w, h, ColorDim)
    end

    Panel:AddItem(Arg)

    return Arg
end

-- ----------------------------------------------------------------------
-- Кнопки
-- ----------------------------------------------------------------------

local function CreateGrid(Columns, ItemH, Count)
    local Grid = vgui.Create("DPanel")
    Grid:SetPaintBackground(false)
    Grid:SetTall(math.ceil(Count / Columns) * (ItemH + GridGap) - GridGap)

    Grid.PerformLayout = function(self, w, h)
        local ItemW = (w - GridGap * (Columns - 1)) / Columns

        for i, Child in ipairs(self:GetChildren()) do
            local Column = (i - 1) % Columns
            local Row    = math.floor((i - 1) / Columns)

            Child:SetPos(math.floor(Column * (ItemW + GridGap)), Row * (ItemH + GridGap))
            Child:SetSize(math.floor(ItemW), ItemH)
        end
    end

    return Grid
end

local function CreateButton(Parent, Label, Action)
    local Button = vgui.Create("DButton", Parent)
    Button:SetText("")
    Button:SetCursor("hand")

    Button.Label   = Label
    Button.Presses = 0

    Button.Paint = function(self, w, h)
        local Hot  = self:IsHovered()
        local Down = self:IsDown()

        if Down then
            surface.SetDrawColor(ColorBone)
        else
            surface.SetDrawColor(ColorBack)
        end

        surface.DrawRect(0, 0, w, h)

        if Down then
            draw.SimpleText(self.Label, "gmm_Core_Text", w / 2, h / 2, ColorBack, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            return
        end

        local Power = 0
        if Hot then Power = 1.2 end

        DrawGlitchText(self.Label, "gmm_Core_Text", w / 2, h / 2, ColorBone, Power, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        if Hot then
            DrawFrame(w, h, ColorRed)
        else
            DrawFrame(w, h, ColorFaint)
        end
    end

    Button.DoClick = function(self)
        self.Presses = self.Presses + 1
        Action(self)
    end

    return Button
end

local function CreateActions(Banner)
    local Grid = CreateGrid(2, ButtonH, 8)

    local Unknown = {
        function()
            Flash("", 0.4)
            surface.PlaySound("buttons/blip1.wav")
        end,
        function()
            Say("Ничего не произошло.")
            timer.Simple(2, function() Say("Или произошло.") end)
        end,
        function()
            Echo(3, 120)
        end,
        function()
            Flash("не оборачивайся", 2)
        end,
        function()
            Banner.ScrambleUntil = RealTime() + 2
        end,
        function()
            Shock(3)
            Echo(2, 90)
        end
    }

    CreateButton(Grid, "НЕ НАЖИМАТЬ", function(Button)
        Say(RefuseLines[math.min(Button.Presses, #RefuseLines)])

        if Button.Presses == 3 then Button.Label = "ПОЖАЛУЙСТА" end
        if Button.Presses ~= #RefuseLines then return end

        Button.Label = "..."
        Flash("СМОТРИ", 2.5)
    end)

    CreateButton(Grid, "???", function()
        Unknown[math.random(#Unknown)]()
    end)

    CreateButton(Grid, "КТО ТЫ", function()
        Say("Ты — " .. LocalPlayer():Nick() .. ".")

        timer.Simple(1,   function() Say("Карта: " .. game.GetMap() .. ". Идёт " .. math.floor(CurTime() / 60) .. " мин.") end)
        timer.Simple(2.5, function() Say("Мы помним.") end)
    end)

    CreateButton(Grid, "ЭХО", function()
        Echo(5, 160)
    end)

    CreateButton(Grid, "ПЕРЕМЕШАТЬ", function()
        Banner.ScrambleUntil = RealTime() + 3
        surface.PlaySound("buttons/button10.wav")
    end)

    CreateButton(Grid, "ВВЕРХ", function(Button)
        local Ply = LocalPlayer()
        local Ang = Ply:EyeAngles()

        Ang.p = -89
        Ply:SetEyeAngles(Ang)

        if Button.Presses < 3 then
            Say("Там ничего нет.")
            return
        end

        Say("Там что-то есть.")
    end)

    CreateButton(Grid, "ЗАПОМНИТЬ", function()
        local Count = cookie.GetNumber(CookiePresses, 0) + 1

        cookie.Set(CookiePresses, Count)
        Say("Нажатий за всё время: " .. Count .. ". Мы считаем.")
    end)

    local Door = CreateButton(Grid, "▒▒▒▒▒", function()
        if ArgState.Unlocked < #Pages then
            Say("Закрыто.")
            surface.PlaySound("buttons/button10.wav")
            return
        end

        Flash("ДВЕРИ НЕТ", 3)
        Say("Ты не первый здесь.")
    end)

    Door.Think = function(self)
        if ArgState.Unlocked >= #Pages then
            self.Label = "ДВЕРЬ №0"
        else
            self.Label = "▒▒▒▒▒"
        end
    end

    return Grid
end

-- ----------------------------------------------------------------------
-- Вкладка
-- ----------------------------------------------------------------------

GMM_C.CoreTab.Build = function(Panel)
    Panel:ClearControls()

    LoadArg()

    local Banner = CreateBanner()
    Panel:AddItem(Banner)

    CreateHeader(Panel, ":LINKS:")
    for i = 1, #Links do CreateLinkRow(Panel, Links[i]) end

    CreateHeader(Panel, ":DOCUMENTS:")
    CreateArg(Panel)

    CreateHeader(Panel, ":SIGNALS:")
    for i = 1, #Canvases do Panel:AddItem(CreateCanvas(Canvases[i])) end

    CreateHeader(Panel, ":BUTTONS:")
    Panel:AddItem(CreateActions(Banner))
end

GMM_C.CoreTab.SaveExplore = SaveExplore
GMM_C.CoreTab.GetKey      = GetMapKey

GMM_C.CoreTab.Unlock = function(Index)
    UnlockPage(Index)
end

GMM_C.CoreTab.GetStats = function()
    local Stats = {}

    for Key, Data in pairs(Explore) do
        local Source = "NONE"

        if Data.Playable ~= nil then
            Source = "SAMPLE"
            if Data.Strict then Source = "NAV" end
        end

        Stats[Key] = {Count = Data.Count, Total = Data.Total, Percent = math.floor(GetProgress(Key) * 100), Source = Source}
    end

    return Stats
end

GMM_C.CoreTab.Reset = function()
    cookie.Delete(CookieArg)
    cookie.Delete(CookieShowMap)

    for i = 1, #MapList do
        cookie.Delete(CookieExplore .. MapList[i].Key)
    end

    for Key in pairs(Explore) do
        Explore[Key] = nil
    end

    timer.Remove("gmm_Core_Sample")
    timer.Remove("gmm_Core_NavTimeout")

    Sample = nil

    ArgState.Unlocked = 1
    ArgState.Page     = 1
    ArgState.Stare    = 0
    ShowExplored      = false
    SampledKey        = nil
    CoreKey           = nil
    Nav.State         = "None"
    ViewCache.Key     = nil
end

net.Receive("gmm_CoreReset", function()
    GMM_C.CoreTab.Reset()
    Say("Прогресс сброшен.")
end)