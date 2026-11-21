surface.CreateFont("gmm_UI_Title", {font = "Tahoma", size = 20, weight = 800, extended = true})
surface.CreateFont("gmm_UI_Name" , {font = "Tahoma", size = 17, weight = 700, extended = true})
surface.CreateFont("gmm_UI_Value", {font = "Tahoma", size = 16, weight = 700, extended = true})
surface.CreateFont("gmm_UI_Text" , {font = "Tahoma", size = 14, weight = 500, extended = true})
surface.CreateFont("gmm_UI_Small", {font = "Tahoma", size = 13, weight = 500, extended = true})

local ColorRowBack      = Color(20 , 18 , 26 , 255)
local ColorRowBackHover = Color(32 , 27 , 42 , 255)
local ColorTrack        = Color(8  , 7  , 12 , 255)
local ColorName         = Color(245, 245, 250, 255)
local ColorPrefix       = Color(150, 150, 175, 255)
local ColorText         = Color(210, 210, 225, 255)
local ColorDim          = Color(150, 150, 172, 255)
local ColorWarn         = Color(255, 190, 70 , 255)
local ColorGhostA       = Color(255, 50 , 90 , 170)
local ColorGhostB       = Color(50 , 220, 255, 170)
local ColorHeaderAccent = Color(190, 110, 255, 255)

local Pad       = 10
local PadY      = 8
local HeaderH   = 24
local TagH      = 14
local LineH     = 16
local GapY      = 6
local FooterH   = 16
local EnumLineH = 24
local ValueW    = 76
local CutSize   = 8

local ConVarNamePrefix = "gmm_convar_"

-- ----------------------------------------------------------------------

local function ConVarDecimals(Def)
    if Def.Type == "Int" then return 0 end
    if Def.Max - Def.Min <= 1 then return 3 end
    return 2
end

local FormatValue = function(Def, Text)
    if Def.Type == "Bool" then
        if (tonumber(Text) or 0) ~= 0 then return "ВКЛ" end
        return "ВЫКЛ"
    end
    if Def.Type == "Enum" then return Text .. " (" .. GMM.ConVars.GetDisplayText(Def, Text) .. ")" end
    if Text == "" then return "(пусто)" end

    return Text
end

local WrapLines = function(Text, Font, MaxWidth)
    surface.SetFont(Font)

    local Lines = {}
    local Line  = ""

    for Word in string.gmatch(Text, "%S+") do
        local Candidate = Word
        if Line ~= "" then Candidate = Line .. " " .. Word end

        local CandidateW = surface.GetTextSize(Candidate)
        if CandidateW > MaxWidth and Line ~= "" then
            table.insert(Lines, Line)
            Line = Word
        else
            Line = Candidate
        end
    end
    if Line ~= "" then table.insert(Lines, Line) end

    return Lines
end

local BuildCutPoly = function(w, h)
    return {
        {x = 0           , y = 0},
        {x = w - CutSize , y = 0},
        {x = w           , y = CutSize},
        {x = w           , y = h},
        {x = 0           , y = h}
    }
end

local UpdateGlitch = function(Target, Now, MinDelay, MaxDelay)
    if Now >= Target.__NextGlitch then
        Target.__GlitchUntil = Now + 0.12
        Target.__NextGlitch  = Now + math.Rand(MinDelay, MaxDelay)
    end

    return Now < Target.__GlitchUntil
end

local DrawGlitchText = function(Text, Font, X, Y, Color, Glitching, AlignX)
    if Text == "" then return end

    if Glitching then
        draw.SimpleText(Text, Font, X - 2, Y    , ColorGhostA, AlignX, TEXT_ALIGN_CENTER)
        draw.SimpleText(Text, Font, X + 2, Y + 1, ColorGhostB, AlignX, TEXT_ALIGN_CENTER)
    end

    draw.SimpleText(Text, Font, X, Y, Color, AlignX, TEXT_ALIGN_CENTER)
end

-- ----------------------------------------------------------------------

local ApplyConVarLater = function(Def, Value)
    local Delay = 0.05
    if Def.Server then Delay = 0.3 end

    timer.Create("gmm_ConVarApply_" .. Def.Name, Delay, 1, function()
        if Def.Server then
            net.Start("gmm_SetServerConVar")
            net.WriteString(Def.Name)
            net.WriteString(tostring(Value))
            net.SendToServer()
        else
            RunConsoleCommand(Def.Name, tostring(Value))
        end
    end)
end

local SetRowText = function(Row, Text)
    if Row.__ReadOnly then return end
    if Text == Row.__Text then return end

    local Now = RealTime()
    Row.__Text        = Text
    Row.__GlitchUntil = Now + 0.35
    Row.__ResyncAt    = Now + 1.2

    ApplyConVarLater(Row.__Def, Text)
end

local ApplyRowText = function(Row, Text)
    if Text ~= Row.__Text then Row.__GlitchUntil = RealTime() + 0.35 end
    Row.__Text = Text

    local Control = Row.__Control
    if Control ~= nil and Control.__ApplyText ~= nil then Control:__ApplyText(Text) end
end

-- ----------------------------------------------------------------------

local BuildBoolControl = function(Row)
    local Control = vgui.Create("DButton", Row)
    Control:SetText("")
    Row.__ControlHeight = 24

    Control.Paint = function(self, w, h)
        local IsOn   = (tonumber(Row.__Text) or 0) ~= 0
        local Target = 0
        if IsOn then Target = 1 end

        if self.__Anim == nil then self.__Anim = Target end
        self.__Anim = Lerp(math.min(FrameTime() * 14, 1), self.__Anim, Target)

        local Anim   = self.__Anim
        local Accent = Row.__Accent
        local TrackW = 46

        surface.SetDrawColor(ColorTrack)
        surface.DrawRect(0, 2, TrackW, h - 4)
        surface.SetDrawColor(Accent.r, Accent.g, Accent.b, 30 + 120 * Anim)
        surface.DrawRect(0, 2, TrackW, h - 4)
        surface.SetDrawColor(Accent.r, Accent.g, Accent.b, 255)
        surface.DrawOutlinedRect(0, 2, TrackW, h - 4)

        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawRect(3 + (TrackW - 6 - 16) * Anim, 5, 16, h - 10)

        local Label = "ВЫКЛ"
        if IsOn then Label = "ВКЛ" end
        DrawGlitchText(Label, "gmm_UI_Value", TrackW + 12, h / 2, ColorName, Row.__Glitching == true, TEXT_ALIGN_LEFT)
    end

    Control.DoClick = function()
        if (tonumber(Row.__Text) or 0) ~= 0 then
            SetRowText(Row, "0")
        else
            SetRowText(Row, "1")
        end
    end

    return Control
end

local BuildSliderControl = function(Row)
    local Def      = Row.__Def
    local Decimals = ConVarDecimals(Def)
    local Range    = Def.Max - Def.Min

    local Control = vgui.Create("DPanel", Row)
    Control:SetPaintBackground(false)
    Control:SetCursor("hand")
    Row.__ControlHeight = 24

    Control.__SetFromX = function(self, X)
        local TrackW = self:GetWide() - ValueW - 6
        if TrackW < 1 then return end

        local Fraction = math.Clamp(X / TrackW, 0, 1)
        local Value    = math.Round(Def.Min + Range * Fraction, Decimals)

        SetRowText(Row, tostring(Value))
    end

    Control.Paint = function(self, w, h)
        local Accent   = Row.__Accent
        local TrackW   = w - ValueW - 6
        local Number   = tonumber(Row.__Text) or Def.Min
        local Fraction = 0
        if Range > 0 then Fraction = math.Clamp((Number - Def.Min) / Range, 0, 1) end

        local CenterY = math.floor(h / 2)
        local FillW   = math.floor(TrackW * Fraction)

        surface.SetDrawColor(ColorTrack)
        surface.DrawRect(0, CenterY - 3, TrackW, 6)
        surface.SetDrawColor(Accent.r, Accent.g, Accent.b, 255)
        surface.DrawRect(0, CenterY - 3, FillW, 6)

        surface.SetDrawColor(255, 255, 255, 45)
        for i = 0, 10 do
            surface.DrawRect(math.floor(TrackW * i / 10), CenterY + 6, 1, 4)
        end

        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawRect(FillW - 3, CenterY - 8, 6, 16)

        DrawGlitchText(Row.__Text, "gmm_UI_Value", w, CenterY, ColorName, Row.__Glitching == true, TEXT_ALIGN_RIGHT)
    end

    Control.OnMousePressed = function(self, Code)
        if Code ~= MOUSE_LEFT then return end

        self.__Dragging = true
        self:MouseCapture(true)

        local X = self:ScreenToLocal(gui.MouseX(), 0)
        self:__SetFromX(X)
    end

    Control.OnCursorMoved = function(self, X, Y)
        if not self.__Dragging then return end
        self:__SetFromX(X)
    end

    Control.OnMouseReleased = function(self, Code)
        self.__Dragging = false
        self:MouseCapture(false)
    end

    return Control
end

local BuildStringControl = function(Row)
    local Control = vgui.Create("DTextEntry", Row)
    Control:SetFont("gmm_UI_Value")
    Control:SetUpdateOnType(false)
    Control:SetEnabled(not Row.__ReadOnly)
    Row.__ControlHeight = 26

    Control.Paint = function(self, w, h)
        local Accent = Row.__Accent

        surface.SetDrawColor(ColorTrack)
        surface.DrawRect(0, 0, w, h)

        local Alpha = 120
        if self:HasFocus() then Alpha = 255 end
        surface.SetDrawColor(Accent.r, Accent.g, Accent.b, Alpha)
        surface.DrawOutlinedRect(0, 0, w, h)

        self:DrawTextEntryText(ColorName, Accent, ColorName)
    end

    Control.OnEnter = function(self)
        SetRowText(Row, self:GetValue())
    end

    Control.__ApplyText = function(self, Text)
        if self:HasFocus() then return end
        self:SetValue(Text)
    end

    return Control
end

local BuildEnumControl = function(Row)
    local Def = Row.__Def

    local Control = vgui.Create("DPanel", Row)
    Control:SetPaintBackground(false)
    Control.__Buttons   = {}
    Row.__ControlHeight = #Def.Options * EnumLineH

    for i = 1, #Def.Options do
        local Option = Def.Options[i]

        local Button = vgui.Create("DButton", Control)
        Button:SetText("")
        Button:SetPos(0, (i - 1) * EnumLineH)
        Button:SetTall(EnumLineH - 2)

        Button.Paint = function(self, w, h)
            local Accent   = Row.__Accent
            local Selected = tonumber(Row.__Text) == Option.Value

            if Selected then
                surface.SetDrawColor(Accent.r, Accent.g, Accent.b, 55)
                surface.DrawRect(0, 0, w, h)
            elseif self:IsHovered() then
                surface.SetDrawColor(255, 255, 255, 14)
                surface.DrawRect(0, 0, w, h)
            end

            local Alpha = 110
            if Selected then Alpha = 255 end
            surface.SetDrawColor(Accent.r, Accent.g, Accent.b, Alpha)
            surface.DrawOutlinedRect(7, h / 2 - 5, 10, 10)
            if Selected then surface.DrawRect(10, h / 2 - 2, 4, 4) end

            local TextColor = ColorText
            if Selected then TextColor = ColorName end
            DrawGlitchText(Option.Name, "gmm_UI_Value", 28, h / 2, TextColor, Selected and Row.__Glitching == true, TEXT_ALIGN_LEFT)

            draw.SimpleText(tostring(Option.Value), "gmm_UI_Small", w - 8, h / 2, ColorDim, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end

        Button.DoClick = function()
            SetRowText(Row, tostring(Option.Value))
        end

        table.insert(Control.__Buttons, Button)
    end

    Control.PerformLayout = function(self, w, h)
        for i = 1, #self.__Buttons do
            self.__Buttons[i]:SetWide(w)
        end
    end

    return Control
end

-- ----------------------------------------------------------------------

local CreateRow = function(Panel, Def, Index, CanEdit)
    local Row = vgui.Create("DPanel")
    Row:SetPaintBackground(false)
    Row:SetTall(90)

    local PrefixText = ""
    local ShortName  = Def.Name
    if string.StartWith(Def.Name, ConVarNamePrefix) then
        PrefixText = ConVarNamePrefix
        ShortName  = string.sub(Def.Name, #ConVarNamePrefix + 1)
    end

    surface.SetFont("gmm_UI_Name")
    local PrefixW = surface.GetTextSize(PrefixText)

    local RealmText = "КЛИЕНТ"
    if Def.Server then RealmText = "СЕРВЕР" end

    local Tag = string.format("0x%02X", Index) .. " / " .. Def.Type .. " / " .. RealmText
    if not CanEdit then Tag = Tag .. " / ТОЛЬКО ЧТЕНИЕ" end

    local DefaultText = Def.ConVar:GetDefault()

    Row.__Def           = Def
    Row.__Index         = Index
    Row.__ReadOnly      = not CanEdit
    Row.__PrefixText    = PrefixText
    Row.__ShortName     = ShortName
    Row.__PrefixW       = PrefixW
    Row.__Tag           = Tag
    Row.__DefaultText   = DefaultText
    Row.__DefaultShown  = FormatValue(Def, DefaultText)
    Row.__Text          = Def.ConVar:GetString()
    Row.__LastText      = Row.__Text
    Row.__Accent        = HSVToColor((Index * 47) % 360, 0.55, 1)
    Row.__Glitching     = false
    Row.__GlitchUntil   = 0
    Row.__NextGlitch    = RealTime() + math.Rand(1, 8)
    Row.__NextCheck     = 0
    Row.__ResyncAt      = nil
    Row.__DescLines     = {}
    Row.__WrapWidth     = -1
    Row.__DescY         = 0
    Row.__ControlY      = 0
    Row.__FooterY       = 0
    Row.__ControlHeight = 24
    Row.__Poly          = nil

    if Def.Type == "Bool" then
        Row.__Control = BuildBoolControl(Row)
    elseif Def.Type == "Enum" then
        Row.__Control = BuildEnumControl(Row)
    elseif Def.Type == "String" then
        Row.__Control = BuildStringControl(Row)
    else
        Row.__Control = BuildSliderControl(Row)
    end

    Row.__Control:SetMouseInputEnabled(not Row.__ReadOnly)
    if Row.__Control.__ApplyText ~= nil then Row.__Control:__ApplyText(Row.__Text) end

    Row.PerformLayout = function(self, w, h)
        if w < 60 then return end

        local InnerW = w - Pad * 2
        if self.__WrapWidth ~= InnerW then
            self.__WrapWidth = InnerW
            self.__DescLines = WrapLines(self.__Def.Description, "gmm_UI_Text", InnerW)
        end

        self.__DescY    = PadY + HeaderH + TagH + 4
        self.__ControlY = self.__DescY + #self.__DescLines * LineH + GapY
        self.__FooterY  = self.__ControlY + self.__ControlHeight + GapY

        local Needed = self.__FooterY + FooterH + PadY
        if self:GetTall() ~= Needed then self:SetTall(Needed) end

        self.__Control:SetPos(Pad, self.__ControlY)
        self.__Control:SetSize(InnerW, self.__ControlHeight)

        self.__Poly = BuildCutPoly(w, Needed)
    end

    Row.Think = function(self)
        local Now = RealTime()
        if Now < self.__NextCheck then return end
        self.__NextCheck = Now + 0.2

        self.__Accent = HSVToColor((self.__Index * 47 + Now * 12) % 360, 0.55, 1)

        if timer.Exists("gmm_ConVarApply_" .. self.__Def.Name) then return end

        local Forced = false
        if self.__ResyncAt ~= nil and Now >= self.__ResyncAt then
            self.__ResyncAt = nil
            Forced = true
        end

        local Text = self.__Def.ConVar:GetString()
        if Text == self.__LastText and not Forced then return end

        self.__LastText = Text
        ApplyRowText(self, Text)
    end

    Row.OnMousePressed = function(self, Code)
        if Code ~= MOUSE_RIGHT then return end
        SetRowText(self, self.__DefaultText)
    end

    Row.Paint = function(self, w, h)
        local Poly = self.__Poly
        if Poly == nil then return end

        local Now       = RealTime()
        local Accent    = self.__Accent
        local Hovered   = self:IsHovered() or self:IsChildHovered()
        local Glitching = UpdateGlitch(self, Now, 5, 14)
        self.__Glitching = Glitching

        draw.NoTexture()
        if Hovered then
            surface.SetDrawColor(ColorRowBackHover)
        else
            surface.SetDrawColor(ColorRowBack)
        end
        surface.DrawPoly(Poly)

        local BarW = 3
        if Hovered then BarW = 5 end
        surface.SetDrawColor(Accent.r, Accent.g, Accent.b, 255)
        surface.DrawRect(0, 0, BarW, h)
        surface.DrawLine(w - CutSize, 0, w, CutSize)

        local NameY = PadY + HeaderH / 2
        DrawGlitchText(self.__PrefixText, "gmm_UI_Name", Pad                , NameY, ColorPrefix, Glitching, TEXT_ALIGN_LEFT)
        DrawGlitchText(self.__ShortName , "gmm_UI_Name", Pad + self.__PrefixW, NameY, ColorName  , Glitching, TEXT_ALIGN_LEFT)

        local TagColor = ColorDim
        if self.__ReadOnly then TagColor = ColorWarn end
        draw.SimpleText(self.__Tag, "gmm_UI_Small", Pad, PadY + HeaderH + TagH / 2, TagColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        local Lines = self.__DescLines
        for i = 1, #Lines do
            draw.SimpleText(Lines[i], "gmm_UI_Text", Pad, self.__DescY + (i - 1) * LineH + LineH / 2, ColorText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        local FooterY = self.__FooterY + FooterH / 2
        draw.SimpleText("По умолчанию: " .. self.__DefaultShown, "gmm_UI_Small", Pad, FooterY, ColorDim, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        if not self.__ReadOnly then
            draw.SimpleText("ПКМ по тексту: сбросить", "gmm_UI_Small", w - Pad, FooterY, ColorDim, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end

        if Glitching then
            surface.SetDrawColor(255, 255, 255, 40)
            surface.DrawRect(0, math.random(0, h - 1), w, 1)
        end
    end

    Row.PaintOver = function(self, w, h)
        if not self.__ReadOnly then return end

        surface.SetDrawColor(20, 18, 26, 100)
        surface.DrawRect(Pad, self.__ControlY, w - Pad * 2, self.__ControlHeight)
    end

    Panel:AddItem(Row)

    return Row
end

local CreateHeader = function(Panel, Title, Count, Note, Warn)
    local Header = vgui.Create("DPanel")
    Header:SetPaintBackground(false)
    Header:SetTall(70)

    surface.SetFont("gmm_UI_Title")
    local PrefixW = surface.GetTextSize("GMM::")

    local NoteColor = ColorText
    if Warn then NoteColor = ColorWarn end

    Header.__NextGlitch  = RealTime() + 1
    Header.__GlitchUntil = 0
    Header.__Lines       = {}
    Header.__Poly        = nil

    Header.PerformLayout = function(self, w, h)
        if w < 60 then return end

        self.__Lines = WrapLines(Note, "gmm_UI_Text", w - Pad * 2)

        local Needed = PadY + 28 + #self.__Lines * LineH + PadY
        if self:GetTall() ~= Needed then self:SetTall(Needed) end

        self.__Poly = BuildCutPoly(w, Needed)
    end

    Header.Paint = function(self, w, h)
        local Poly = self.__Poly
        if Poly == nil then return end

        local Glitching = UpdateGlitch(self, RealTime(), 2, 6)

        draw.NoTexture()
        surface.SetDrawColor(ColorRowBack)
        surface.DrawPoly(Poly)

        surface.SetDrawColor(ColorHeaderAccent)
        surface.DrawRect(0, 0, 4, h)
        surface.DrawLine(w - CutSize, 0, w, CutSize)

        local TitleY = PadY + 12
        DrawGlitchText("GMM::", "gmm_UI_Title", Pad          , TitleY, ColorPrefix, Glitching, TEXT_ALIGN_LEFT)
        DrawGlitchText(Title  , "gmm_UI_Title", Pad + PrefixW, TitleY, ColorName  , Glitching, TEXT_ALIGN_LEFT)
        draw.SimpleText("[" .. Count .. "]", "gmm_UI_Value", w - Pad, TitleY, ColorDim, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

        local Lines = self.__Lines
        for i = 1, #Lines do
            draw.SimpleText(Lines[i], "gmm_UI_Text", Pad, PadY + 28 + (i - 1) * LineH + LineH / 2, NoteColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    end

    Panel:AddItem(Header)

    return Header
end

local CreateButton = function(Panel, Text, DoClick)
    local Button = vgui.Create("DButton")
    Button:SetText("")
    Button:SetTall(30)

    Button.Paint = function(self, w, h)
        if self:IsHovered() then
            surface.SetDrawColor(ColorRowBackHover)
        else
            surface.SetDrawColor(ColorRowBack)
        end
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(ColorHeaderAccent)
        surface.DrawOutlinedRect(0, 0, w, h)

        draw.SimpleText(Text, "gmm_UI_Value", w / 2, h / 2, ColorName, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    Button.DoClick = DoClick

    Panel:AddItem(Button)

    return Button
end

-- ----------------------------------------------------------------------

local function FillConVarPanel(Panel, Server)
    Panel:ClearControls()

    local List  = GMM.ConVars[Server and "Server" or "Client"]
    local Title = "КЛИЕНТ"
    if Server then Title = "СЕРВЕР" end

    local CanEdit = true
    local Note    = "Изменения применяются сразу. Если менять конвар в консоли, строка обновится сама."
    local Warn    = false

    if Server then
        local Ply = LocalPlayer()
        CanEdit = IsValid(Ply) and Ply:IsSuperAdmin()
        if not CanEdit then
            Note = "Менять серверные настройки может только суперадмин. Ниже текущие значения."
            Warn = true
        end
    end

    if #List == 0 then
        CreateHeader(Panel, Title, 0, "Список пуст.", false)
        return
    end

    CreateHeader(Panel, Title, #List, Note, Warn)

    for i = 1, #List do
        CreateRow(Panel, List[i], i, CanEdit)
    end

    CreateButton(Panel, "Обновить", function() FillConVarPanel(Panel, Server) end)
end

hook.Add("PopulateToolMenu", "gmm_PopulateTools", function()
    spawnmenu.AddToolMenuOption("Utilities", "GMM", "gmm_Menu_Main", "CORE", "", "", function(panel)
        panel:ClearControls()

        panel:Help("Скоро может быть тут что-то появится...")
        panel:Help("")

        local Power = 2
        local Speed = 0.5

        local Canvas = vgui.Create("DPanel", panel)
        Canvas:SetTall(300)
        Canvas:Dock(TOP)
        Canvas:SetPaintBackground(false)

        Canvas.Paint = function(self, w, h)
            local T = CurTime()

            local HueOffset = (T * 120 * Speed) % 360
            for i = 0, h, 6 do
                local Hue = (HueOffset + i * 0.8) % 360
                local C   = HSVToColor(Hue, 0.9, 1)
                surface.SetDrawColor(C.r, C.g, C.b, 120)
                surface.DrawRect(0, i, w, 6)
            end

            for i = 1, math.floor(8 * Power) do
                local Y      = math.random(0, h - 4)
                local StripH = math.random(1, math.floor(8 * Power))
                local Hue    = (T * 300 * Speed + i * 60) % 360
                local C      = HSVToColor(Hue, 1, 1)
                surface.SetDrawColor(C.r, C.g, C.b, math.random(120, 220))
                surface.DrawRect(0, Y, w, StripH)
            end

            draw.NoTexture()
            for i = 1, math.floor(5 * Power) do
                local Hue  = (T * 180 * Speed + i * 90) % 360
                local C    = HSVToColor(Hue, 1, 1)
                local Size = 20 + math.sin(T * Speed * i) * 15 * Power
                local X    = (w / 2) + math.cos(T * Speed * i * 1.3) * (w / 3) * Power
                local Y    = (h / 2) + math.sin(T * Speed * i * 1.7) * (h / 3) * Power
                surface.SetDrawColor(C.r, C.g, C.b, 180)
                surface.DrawRect(X - Size / 2, Y - Size / 2, Size, Size)
            end

            if math.sin(T * Speed * 8) > 0.3 then
                local C = HSVToColor((T * 400 * Speed) % 360, 1, 1)
                surface.SetDrawColor(C.r, C.g, C.b, 255)
                surface.DrawOutlinedRect(0, 0, w, h)
                surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
            end

            surface.SetFont("DermaLarge")
            local Text = "GMM WIP ADDON"
            local TW, TH = surface.GetTextSize(Text)
            local C = HSVToColor((T * 200 * Speed) % 360, 1, 1)
            surface.SetTextColor(C.r, C.g, C.b, 255)
            surface.SetTextPos((w - TW) / 2, (h - TH) / 2)
            surface.DrawText(Text)
        end

        local id = "gmm_FuckedCanvas_" .. tostring(Canvas)
        timer.Create(id, 0, 0, function()
            if IsValid(Canvas) then
                Canvas:InvalidateLayout()
            end
        end)

        Canvas.OnRemove = function()
            timer.Remove(id)
        end
    end)

    spawnmenu.AddToolMenuOption("Utilities", "GMM", "gmm_Menu_ServerConVars", "CONVAR_SERVER", "", "", function(Panel)
        FillConVarPanel(Panel, true)
    end)

    spawnmenu.AddToolMenuOption("Utilities", "GMM", "gmm_Menu_ClientConVars", "CONVAR_CLIENT", "", "", function(Panel)
        FillConVarPanel(Panel, false)
    end)
end)