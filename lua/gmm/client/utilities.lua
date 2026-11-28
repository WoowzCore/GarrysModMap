surface.CreateFont("gmm_UI_Big"  , {font = "Consolas", size = 30, weight = 400, extended = true})
surface.CreateFont("gmm_UI_Title", {font = "Consolas", size = 20, weight = 500, extended = true})
surface.CreateFont("gmm_UI_Name" , {font = "Consolas", size = 17, weight = 600, extended = true})
surface.CreateFont("gmm_UI_Value", {font = "Consolas", size = 16, weight = 500, extended = true})
surface.CreateFont("gmm_UI_Text" , {font = "Consolas", size = 15, weight = 400, extended = true})
surface.CreateFont("gmm_UI_Small", {font = "Consolas", size = 13, weight = 400, extended = true})
local ColorText          = Color(34 , 38 , 46 , 255)
local ColorTitle         = Color(30 , 57 , 91 , 255)
local ColorTitleGlow     = Color(255, 255, 255, 200)
local ColorDim           = Color(98 , 108, 122, 255)
local ColorPrefix        = Color(124, 138, 158, 255)
local ColorWarn          = Color(176, 90 , 0  , 255)
local ColorWhite         = Color(255, 255, 255, 255)
local ColorCardFill      = Color(252, 253, 255, 255)
local ColorCardFillHot   = Color(243, 249, 255, 255)
local ColorCardBorder    = Color(163, 181, 204, 255)
local ColorCardBorderHot = Color(100, 150, 200, 255)
local ColorInnerLight    = Color(255, 255, 255, 255)
local ColorShadow        = Color(40 , 70 , 110, 38)
local ColorGlassTop      = Color(241, 248, 255, 255)
local ColorGlassBottom   = Color(212, 228, 247, 255)
local ColorDisabledVeil  = Color(252, 253, 255, 150)
local ColorCheck          = Color(33 , 87 , 160, 255)
local ColorGrooveBorder   = Color(160, 168, 178, 255)
local ColorGrooveBack     = Color(232, 236, 240, 255)
local ColorGrooveFill     = Color(110, 175, 228, 255)
local ColorEntryBorder    = Color(171, 173, 179, 255)
local ColorEntryHot       = Color(87 , 148, 191, 255)
local ColorEntryFocus     = Color(51 , 153, 255, 255)
local ColorEntryFill      = Color(255, 255, 255, 255)
local ColorEntryReadOnly  = Color(240, 240, 240, 255)
local ColorProgressBorder = Color(172, 172, 172, 255)
local ColorProgressBack   = Color(232, 232, 232, 255)
local ColorBarGreen       = Color(6  , 176, 37 , 255)
local ColorBarOrange      = Color(240, 160, 30 , 255)
local ColorBadgeFill         = Color(74 , 144, 200, 255)
local ColorBadgeBorder       = Color(44 , 98 , 139, 255)
local ColorBadgeWarnFill     = Color(228, 138, 24 , 255)
local ColorBadgeWarnBorder   = Color(160, 90 , 10 , 255)
local ButtonStyles = {
    Normal   = {Border = Color(112, 112, 112), Top = Color(242, 242, 242), Bottom = Color(219, 219, 219), Text = ColorText},
    Hover    = {Border = Color(60 , 127, 177), Top = Color(234, 246, 253), Bottom = Color(167, 217, 245), Text = ColorText},
    Down     = {Border = Color(44 , 98 , 139), Top = Color(196, 229, 246), Bottom = Color(104, 179, 219), Text = ColorText},
    Disabled = {Border = Color(173, 178, 181), Top = Color(244, 244, 244), Bottom = Color(244, 244, 244), Text = Color(131, 131, 131)}
}
local ItemStyles = {
    Selected = {Border = Color(125, 162, 206), Top = Color(220, 235, 252), Bottom = Color(193, 219, 252)},
    Hover    = {Border = Color(184, 214, 251), Top = Color(250, 252, 255), Bottom = Color(235, 244, 253)}
}
local Pad          = 12
local PadY         = 10
local TitleH       = 26
local TagH         = 16
local LineH        = 17
local GapY         = 8
local FooterH      = 24
local EnumLineH    = 26
local ValueW       = 70
local CornerRadius = 4
local BarH         = 14
local ThumbW       = 12
local ThumbH       = 20
local ResetW       = 84
local ConVarNamePrefix = "gmm_convar_"
-- ----------------------------------------------------------------------
local function ConVarDecimals(Def)
    if Def.Type == "Int" then return 0 end
    if Def.Max - Def.Min <= 1 then return 3 end
    return 2
end
local FormatFlags = function(Def, Text)
    local Mask  = tonumber(Text) or 0
    local Names = {}
    for i = 1, #Def.Flags do
        local Flag = Def.Flags[i]
        if bit.band(Mask, Flag.Value) ~= 0 then table.insert(Names, Flag.Name) end
    end
    if #Names == 0 then return Text .. " (ничего)" end
    return Text .. " (" .. table.concat(Names, ", ") .. ")"
end
local FormatValue = function(Def, Text)
    if Def.Type == "Bool" then
        if (tonumber(Text) or 0) ~= 0 then return "TRUE" end
        return "FALSE"
    end
    if Def.Type == "Enum" then return Text .. " (" .. GMM.ConVars.GetDisplayText(Def, Text) .. ")" end
    if Def.Flags ~= nil then return FormatFlags(Def, Text) end
    if Text == "" then return "(nil)" end
    return Text
end
local FormatAgo = function(Seconds)
    local Total = math.floor(Seconds)
    if Total < 60 then return Total .. " с назад" end
    if Total < 3600 then return math.floor(Total / 60) .. " мин назад" end
    return math.floor(Total / 3600) .. " ч назад"
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
-- ----------------------------------------------------------------------
local DrawGloss = function(X, Y, W, H, Radius, TopColor, BottomColor)
    local HalfH = math.floor(H / 2)
    draw.RoundedBoxEx(Radius, X, Y, W, HalfH, TopColor, true, true, false, false)
    draw.RoundedBoxEx(Radius, X, Y + HalfH, W, H - HalfH, BottomColor, false, false, true, true)
end
local DrawGlossBox = function(X, Y, W, H, Style, Radius)
    draw.RoundedBox(Radius, X, Y, W, H, Style.Border)
    draw.RoundedBox(math.max(Radius - 1, 1), X + 1, Y + 1, W - 2, H - 2, ColorInnerLight)
    DrawGloss(X + 2, Y + 2, W - 4, H - 4, math.max(Radius - 2, 1), Style.Top, Style.Bottom)
end
local DrawItemBox = function(X, Y, W, H, Style)
    draw.RoundedBox(3, X, Y, W, H, Style.Border)
    DrawGloss(X + 1, Y + 1, W - 2, H - 2, 2, Style.Top, Style.Bottom)
end
local DrawCardBack = function(w, h, Hot)
    local CardH = h - 2
    draw.RoundedBox(CornerRadius, 1, 2, w - 2, CardH, ColorShadow)
    if Hot then
        draw.RoundedBox(CornerRadius, 0, 0, w, CardH, ColorCardBorderHot)
        draw.RoundedBox(CornerRadius - 1, 1, 1, w - 2, CardH - 2, ColorCardFillHot)
    else
        draw.RoundedBox(CornerRadius, 0, 0, w, CardH, ColorCardBorder)
        draw.RoundedBox(CornerRadius - 1, 1, 1, w - 2, CardH - 2, ColorCardFill)
    end
end
local DrawGlassBack = function(w, h)
    local CardH = h - 2
    draw.RoundedBox(CornerRadius, 1, 2, w - 2, CardH, ColorShadow)
    draw.RoundedBox(CornerRadius, 0, 0, w, CardH, ColorCardBorder)
    DrawGloss(1, 1, w - 2, CardH - 2, CornerRadius - 1, ColorGlassTop, ColorGlassBottom)
end
local DrawTitleText = function(Text, Font, X, Y)
    draw.SimpleText(Text, Font, X + 1, Y + 1, ColorTitleGlow, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText(Text, Font, X    , Y    , ColorTitle    , TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end
local DrawBadge = function(Text, Font, RightX, CenterY, Fill, Border)
    surface.SetFont(Font)
    local TW, TH = surface.GetTextSize(Text)
    local W = TW + 18
    local H = TH + 4
    local X = math.floor(RightX - W)
    local Y = math.floor(CenterY - H / 2)
    local R = math.floor(H / 2)
    draw.RoundedBox(R, X, Y, W, H, Border)
    draw.RoundedBox(R - 1, X + 1, Y + 1, W - 2, H - 2, Fill)
    draw.SimpleText(Text, Font, X + W / 2, Y + H / 2, ColorWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end
local DrawCheckMark = function(X, Y, Color)
    surface.SetDrawColor(Color)
    surface.DrawLine(X + 3, Y + 7 , X + 6 , Y + 10)
    surface.DrawLine(X + 3, Y + 8 , X + 6 , Y + 11)
    surface.DrawLine(X + 6, Y + 10, X + 11, Y + 4)
    surface.DrawLine(X + 6, Y + 11, X + 11, Y + 5)
end
local DrawCheckBox = function(X, Y, Checked, Hot)
    local Style = ButtonStyles.Normal
    if Hot then Style = ButtonStyles.Hover end
    DrawGlossBox(X, Y, 14, 14, Style, 2)
    if Checked then DrawCheckMark(X, Y, ColorCheck) end
end
local DrawProgress = function(X, Y, W, H, Fraction, Fill, Alpha)
    draw.RoundedBox(3, X, Y, W, H, ColorProgressBorder)
    draw.RoundedBox(2, X + 1, Y + 1, W - 2, H - 2, ColorProgressBack)
    local FillW = math.floor((W - 2) * Fraction)
    if FillW < 1 then return end
    surface.SetDrawColor(Fill.r, Fill.g, Fill.b, Alpha)
    surface.DrawRect(X + 1, Y + 1, FillW, H - 2)
    surface.SetDrawColor(255, 255, 255, 70)
    surface.DrawRect(X + 1, Y + 1, FillW, math.floor((H - 2) / 2))
end
local StyleGlossButton = function(Button, Text)
    Button:SetText("")
    Button.Paint = function(self, w, h)
        local State = "Normal"
        if not self:IsEnabled() then
            State = "Disabled"
        elseif self:IsDown() then
            State = "Down"
        elseif self:IsHovered() then
            State = "Hover"
        end
        local Style = ButtonStyles[State]
        DrawGlossBox(0, 0, w, h, Style, CornerRadius)
        draw.SimpleText(self.__Label or Text, "gmm_UI_Text", w / 2, h / 2, Style.Text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
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
    Row.__Text     = Text
    Row.__ResyncAt = RealTime() + 1.2
    ApplyConVarLater(Row.__Def, Text)
end
local ApplyRowText = function(Row, Text)
    Row.__Text = Text
    local Control = Row.__Control
    if Control ~= nil and Control.__ApplyText ~= nil then Control:__ApplyText(Text) end
end
-- ----------------------------------------------------------------------
local BuildBoolControl = function(Row)
    local Control = vgui.Create("DButton", Row)
    Control:SetText("")
    Row.__ControlHeight = 22
    Control.Paint = function(self, w, h)
        local IsOn = (tonumber(Row.__Text) or 0) ~= 0
        local Style = ButtonStyles.Normal
        if self:IsHovered() then Style = ButtonStyles.Hover end
        local BoxY = math.floor((h - 14) / 2)
        DrawGlossBox(0, BoxY, 14, 14, Style, 2)
        if IsOn and not Row.__Locked then DrawCheckMark(0, BoxY, ColorCheck) end
        local Label = "FALSE"
        if IsOn then Label = "TRUE" end
        if Row.__Locked then Label = GMM.ConVars.GetGlitchText(Row.__Def.Name .. "_bool", 5) end
        draw.SimpleText(Label, "gmm_UI_Value", 24, h / 2, ColorText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
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
local StyleEntry = function(Entry, Row)
    Entry:SetFont("gmm_UI_Value")
    Entry:SetUpdateOnType(false)
    Entry:SetEnabled(not Row.__ReadOnly)
    Entry.Paint = function(self, w, h)
        local Border = ColorEntryBorder
        if self:HasFocus() then
            Border = ColorEntryFocus
        elseif self:IsHovered() then
            Border = ColorEntryHot
        end
        local Fill = ColorEntryFill
        if Row.__ReadOnly then Fill = ColorEntryReadOnly end
        draw.RoundedBox(2, 0, 0, w, h, Border)
        draw.RoundedBox(1, 1, 1, w - 2, h - 2, Fill)
        if Row.__Locked then
            draw.SimpleText(GMM.ConVars.GetGlitchText(Row.__Def.Name .. "_entry", 6), "gmm_UI_Value", 4, h / 2, ColorWarn, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            return
        end
        self:DrawTextEntryText(ColorText, ColorEntryFocus, ColorText)
    end
    local BaseLoseFocus = Entry.OnLoseFocus
    Entry.OnLoseFocus = function(self)
        if BaseLoseFocus ~= nil then BaseLoseFocus(self) end
        if self.__Commit ~= nil then self:__Commit() end
    end
    Entry.OnEnter = function(self)
        if self.__Commit ~= nil then self:__Commit() end
    end
end
local BuildSliderControl = function(Row)
    local Def      = Row.__Def
    local Decimals = ConVarDecimals(Def)
    local Range    = Def.Max - Def.Min
    local Control = vgui.Create("DPanel", Row)
    Control:SetPaintBackground(false)
    Control:SetCursor("hand")
    Row.__ControlHeight = 26
    local Entry = vgui.Create("DTextEntry", Control)
    StyleEntry(Entry, Row)
    Control.__Entry = Entry
    Entry.__Commit = function(self)
        local Number = tonumber(self:GetValue())
        if Number == nil then
            self:SetValue(Row.__Text)
            return
        end
        Number = math.Round(math.Clamp(Number, Def.Min, Def.Max), Decimals)
        local Text = tostring(Number)
        SetRowText(Row, Text)
        self:SetValue(Text)
    end
    Control.PerformLayout = function(self, w, h)
        Entry:SetPos(w - ValueW, 0)
        Entry:SetSize(ValueW, h)
    end
    Control.__ApplyText = function(self, Text)
        if Entry:HasFocus() then return end
        Entry:SetValue(Text)
    end
    Control.__SetFromX = function(self, X)
        local Span = self:GetWide() - ValueW - 6 - ThumbW
        if Span < 1 then return end
        local Fraction = math.Clamp((X - ThumbW / 2) / Span, 0, 1)
        local Value    = math.Round(Def.Min + Range * Fraction, Decimals)
        SetRowText(Row, tostring(Value))
        Entry:SetValue(tostring(Value))
    end
    Control.Paint = function(self, w, h)
        local TrackW   = w - ValueW - 6
        local Span     = TrackW - ThumbW
        local Number   = tonumber(Row.__Text) or Def.Min
        local Fraction = 0
        if Range > 0 and not Row.__Locked then Fraction = math.Clamp((Number - Def.Min) / Range, 0, 1) end
        local CenterY = math.floor(h / 2)
        local ThumbX  = math.floor(Span * Fraction)
        draw.RoundedBox(2, 0, CenterY - 3, TrackW, 6, ColorGrooveBorder)
        draw.RoundedBox(1, 1, CenterY - 2, TrackW - 2, 4, ColorGrooveBack)
        surface.SetDrawColor(ColorGrooveFill)
        surface.DrawRect(1, CenterY - 2, ThumbX + math.floor(ThumbW / 2), 4)
        local Style = ButtonStyles.Normal
        if self.__Dragging then
            Style = ButtonStyles.Down
        elseif self:IsHovered() then
            Style = ButtonStyles.Hover
        end
        DrawGlossBox(ThumbX, CenterY - ThumbH / 2, ThumbW, ThumbH, Style, 3)
    end
    Control.OnMousePressed = function(self, Code)
        if Code ~= MOUSE_LEFT then return end
        if Entry:HasFocus() then Entry:KillFocus() end
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
    StyleEntry(Control, Row)
    Row.__ControlHeight = 26
    Control.__Commit = function(self)
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
            local CanOption = GMM.ConVars.CanUseOption(Def, Option)
            local Selected  = CanOption and (tonumber(Row.__Text) == Option.Value)
            local Hot       = CanOption and self:IsHovered()
            if Selected then
                DrawItemBox(0, 0, w, h, ItemStyles.Selected)
            elseif Hot then
                DrawItemBox(0, 0, w, h, ItemStyles.Hover)
            end
            DrawCheckBox(8, math.floor(h / 2) - 7, Selected, Hot)
            local OptName  = Option.Name
            local OptValue = tostring(Option.Value)
            local OptColor = ColorText
            if not CanOption then
                OptName  = GMM.ConVars.GetGlitchText(Def.Name .. "_opt_" .. i, 10)
                OptValue = GMM.ConVars.GetGlitchText(Def.Name .. "_val_" .. i, 2)
                OptColor = ColorWarn
            end
            draw.SimpleText(OptName , "gmm_UI_Value", 32   , h / 2, OptColor, TEXT_ALIGN_LEFT , TEXT_ALIGN_CENTER)
            draw.SimpleText(OptValue, "gmm_UI_Small", w - 8, h / 2, ColorDim, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end
        Button.DoClick = function()
            if not GMM.ConVars.CanUseOption(Def, Option) then
                surface.PlaySound("buttons/button10.wav")
                return
            end
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
local BuildFlagsControl = function(Row)
    local Def = Row.__Def
    local Control = vgui.Create("DPanel", Row)
    Control:SetPaintBackground(false)
    Control.__Buttons   = {}
    Row.__ControlHeight = #Def.Flags * EnumLineH
    for i = 1, #Def.Flags do
        local Flag = Def.Flags[i]
        local Button = vgui.Create("DButton", Control)
        Button:SetText("")
        Button:SetPos(0, (i - 1) * EnumLineH)
        Button:SetTall(EnumLineH - 2)
        Button.Paint = function(self, w, h)
            local Selected = (not Row.__Locked) and (bit.band(tonumber(Row.__Text) or 0, Flag.Value) ~= 0)
            local Hot      = (not Row.__Locked) and self:IsHovered()
            if Selected then
                DrawItemBox(0, 0, w, h, ItemStyles.Selected)
            elseif Hot then
                DrawItemBox(0, 0, w, h, ItemStyles.Hover)
            end
            DrawCheckBox(8, math.floor(h / 2) - 7, Selected, Hot)
            local FlagName = Flag.Name
            if Row.__Locked then FlagName = GMM.ConVars.GetGlitchText(Def.Name .. "_flag_" .. i, 12) end
            draw.SimpleText(FlagName, "gmm_UI_Value", 32, h / 2, ColorText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        Button.DoClick = function()
            local Mask = bit.bxor(tonumber(Row.__Text) or 0, Flag.Value)
            SetRowText(Row, tostring(Mask))
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
    Row:SetTall(100)
    local PrefixText = ""
    local ShortName  = Def.Name
    if string.StartWith(Def.Name, ConVarNamePrefix) then
        PrefixText = ConVarNamePrefix
        ShortName  = string.sub(Def.Name, #ConVarNamePrefix + 1)
    end
    surface.SetFont("gmm_UI_Name")
    local PrefixW = surface.GetTextSize(PrefixText)
    local RealmText = "CLIENT"
    if Def.Server then RealmText = "SERVER" end
    local TypeText = Def.Type
    if Def.Flags ~= nil then TypeText = "Flags" end
    local Tag = TypeText .. " / " .. RealmText
    if not CanEdit then Tag = Tag .. " / ONLY READ" end
    local DefaultText = Def.ConVar:GetDefault()
    local Locked        = not GMM.ConVars.CanUse(Def)
    Row.__Def           = Def
    Row.__Index         = Index
    Row.__CanEdit       = CanEdit
    Row.__Locked        = Locked
    Row.__ReadOnly      = (not CanEdit) or Locked
    Row.__PrefixText    = PrefixText
    Row.__ShortName     = ShortName
    Row.__PrefixW       = PrefixW
    Row.__Tag           = Tag
    Row.__DefaultText   = DefaultText
    Row.__DefaultShown  = FormatValue(Def, DefaultText)
    Row.__Text          = Def.ConVar:GetString()
    Row.__LastText      = Row.__Text
    Row.__NextCheck     = 0
    Row.__ResyncAt      = nil
    Row.__DescLines     = {}
    Row.__WrapWidth     = -1
    Row.__DescY         = 0
    Row.__ControlY      = 0
    Row.__FooterY       = 0
    Row.__ControlHeight = 24
    Row.__ResetButton   = nil
    if Def.Flags ~= nil then
        Row.__Control = BuildFlagsControl(Row)
    elseif Def.Type == "Bool" then
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
    if CanEdit then
        local ResetButton = vgui.Create("DButton", Row)
        StyleGlossButton(ResetButton, "Сбросить")
        ResetButton:SetEnabled(not Row.__Locked)
        ResetButton.DoClick = function() SetRowText(Row, Row.__DefaultText) end
        Row.__ResetButton = ResetButton
    end
    Row.PerformLayout = function(self, w, h)
        if w < 60 then return end
        local InnerW = w - Pad * 2
        if self.__WrapWidth ~= InnerW then
            self.__WrapWidth = InnerW
            self.__DescLines = WrapLines(self.__Def.Description, "gmm_UI_Text", InnerW)
        end
        self.__DescY    = PadY + TitleH + TagH + 2
        self.__ControlY = self.__DescY + #self.__DescLines * LineH + GapY
        self.__FooterY  = self.__ControlY + self.__ControlHeight + GapY
        local Needed = self.__FooterY + FooterH + PadY + 2
        if self:GetTall() ~= Needed then self:SetTall(Needed) end
        self.__Control:SetPos(Pad, self.__ControlY)
        self.__Control:SetSize(InnerW, self.__ControlHeight)
        if self.__ResetButton ~= nil then
            self.__ResetButton:SetPos(w - Pad - ResetW, self.__FooterY)
            self.__ResetButton:SetSize(ResetW, FooterH)
        end
    end
    Row.Think = function(self)
        local Now = RealTime()
        if Now < self.__NextCheck then return end
        self.__NextCheck = Now + 0.2
        local Locked = not GMM.ConVars.CanUse(self.__Def)
        if Locked ~= self.__Locked then
            self.__Locked   = Locked
            self.__ReadOnly = (not self.__CanEdit) or Locked
            self.__Control:SetMouseInputEnabled(not self.__ReadOnly)
            if self.__Control.__Entry ~= nil then self.__Control.__Entry:SetEnabled(not self.__ReadOnly) end
            if self.__Def.Type == "String" then self.__Control:SetEnabled(not self.__ReadOnly) end
            if self.__ResetButton ~= nil then self.__ResetButton:SetEnabled(not self.__ReadOnly) end
        end
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
    Row.Paint = function(self, w, h)
        local Hot = self:IsHovered() or self:IsChildHovered()
        DrawCardBack(w, h, Hot)
        local NameY        = PadY + TitleH / 2
        local ShortName    = self.__ShortName
        local Tag          = self.__Tag
        local DefaultShown = self.__DefaultShown
        local NameColor    = ColorTitle
        if self.__Locked then
            ShortName    = GMM.ConVars.GetGlitchText(self.__ShortName, #self.__ShortName)
            Tag          = GMM.ConVars.GetGlitchText(self.__Tag, #self.__Tag)
            DefaultShown = GMM.ConVars.GetGlitchText(self.__DefaultShown, 8)
            NameColor    = ColorWarn
        end
        draw.SimpleText(self.__PrefixText, "gmm_UI_Name", Pad                 , NameY, ColorPrefix, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(ShortName        , "gmm_UI_Name", Pad + self.__PrefixW, NameY, NameColor  , TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        local TagColor = ColorDim
        if self.__ReadOnly then TagColor = ColorWarn end
        draw.SimpleText(Tag, "gmm_UI_Small", Pad, PadY + TitleH + TagH / 2 - 2, TagColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        local Lines = self.__DescLines
        for i = 1, #Lines do
            local LineText = Lines[i]
            if self.__Locked then LineText = GMM.ConVars.GetGlitchText(LineText) end
            draw.SimpleText(LineText, "gmm_UI_Text", Pad, self.__DescY + (i - 1) * LineH + LineH / 2, ColorText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        draw.SimpleText("По умолчанию: " .. DefaultShown, "gmm_UI_Small", Pad, self.__FooterY + FooterH / 2, ColorDim, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    Row.PaintOver = function(self, w, h)
        if not self.__ReadOnly then return end
        surface.SetDrawColor(ColorDisabledVeil)
        surface.DrawRect(Pad, self.__ControlY, w - Pad * 2, self.__ControlHeight)
    end
    Panel:AddItem(Row)
    return Row
end
local CreateHeader = function(Panel, Title, Count, Note, Warn)
    local Header = vgui.Create("DPanel")
    Header:SetPaintBackground(false)
    Header:SetTall(70)
    local NoteColor = ColorText
    if Warn then NoteColor = ColorWarn end
    Header.__Lines = {}
    Header.PerformLayout = function(self, w, h)
        if w < 60 then return end
        self.__Lines = WrapLines(Note, "gmm_UI_Text", w - Pad * 2)
        local Needed = PadY + TitleH + #self.__Lines * LineH + PadY + 2
        if self:GetTall() ~= Needed then self:SetTall(Needed) end
    end
    Header.Paint = function(self, w, h)
        DrawGlassBack(w, h)
        local TitleY = PadY + TitleH / 2
        DrawTitleText(Title, "gmm_UI_Title", Pad, TitleY)
        DrawBadge(tostring(Count), "gmm_UI_Small", w - Pad, TitleY, ColorBadgeFill, ColorBadgeBorder)
        local Lines = self.__Lines
        for i = 1, #Lines do
            draw.SimpleText(Lines[i], "gmm_UI_Text", Pad, PadY + TitleH + (i - 1) * LineH + LineH / 2, NoteColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    end
    Panel:AddItem(Header)
    return Header
end
local CreateButton = function(Panel, Text, DoClick)
    local Button = vgui.Create("DButton")
    Button:SetTall(28)
    StyleGlossButton(Button, Text)
    Button.DoClick = DoClick
    Panel:AddItem(Button)
    return Button
end
local CreateResetAllButton = function(Panel, Rows)
    local Button = CreateButton(Panel, "Сбросить всё", function() end)
    Button.__ConfirmUntil = 0
    Button.DoClick = function(self)
        local Now = RealTime()
        if Now > self.__ConfirmUntil then
            self.__ConfirmUntil = Now + 3
            self.__Label        = "Точно? Нажми ещё раз"
            return
        end
        self.__ConfirmUntil = 0
        self.__Label        = nil
        for i = 1, #Rows do
            local Row = Rows[i]
            if not Row.__ReadOnly then
                SetRowText(Row, Row.__DefaultText)
                ApplyRowText(Row, Row.__DefaultText)
            end
        end
    end
    Button.Think = function(self)
        if self.__Label == nil then return end
        if RealTime() <= self.__ConfirmUntil then return end
        self.__Label = nil
    end
    return Button
end
-- ----------------------------------------------------------------------
local function FillConVarPanel(Panel, Server)
    Panel:ClearControls()
    local List  = GMM.ConVars[Server and "Server" or "Client"]
    local Title = ".client settings"
    if Server then Title = ".server settings" end
    local CanEdit = true
    local Note    = "Изменения применяются сразу. Если менять ConVar в консоли, значение здесь обновится само."
    local Warn    = false
    if Server then
        local Ply = LocalPlayer()
        CanEdit = IsValid(Ply) and Ply:IsSuperAdmin()
        if not CanEdit then
            Note = "Менять серверные настройки может только SUPERADMIN. Ниже текущие значения."
            Warn = true
        end
    end
    if #List == 0 then
        CreateHeader(Panel, Title, 0, "LIST IS EMPTY!", true)
        return
    end
    CreateHeader(Panel, Title, #List, Note, Warn)
    local Rows = {}
    for i = 1, #List do
        table.insert(Rows, CreateRow(Panel, List[i], i, CanEdit))
    end
    if CanEdit then CreateResetAllButton(Panel, Rows) end
end
-- ----------------------------------------------------------------------
local IsAnomaliesUnlocked = function()
    if GMM_C ~= nil and GMM_C.CoreTab ~= nil and GMM_C.CoreTab.IsCompleted ~= nil then
        return GMM_C.CoreTab.IsCompleted()
    end
    return cookie.GetNumber("gmm_core_arg", 1) >= 6
end
local AnomalyStatusInfo = {
    Locked   = {Tag = "LOCKED"       , Warn = true , Timer = false, Text = "Доступ закрыт. Пройдите квест в вкладке CORE до конца."},
    Unknown  = {Tag = "Connection...", Warn = false, Timer = false, Text = "Жду ответа сервера..."},
    NoReply  = {Tag = "NO LINK"      , Warn = true , Timer = false, Text = "СЕРВЕР УНИЧТОЖЕН! Скрипт: gmm/server/anomaly_net.lua загружен ли?"},
    Normal   = {Tag = "TIMER"        , Warn = false, Timer = true , Text = "Время до следующей аномалии."},
    Fast     = {Tag = "FAST"         , Warn = true , Timer = true , Text = "Одна и та же аномалия идёт подряд до конца таймера."},
    Rare     = {Tag = "RARE"         , Warn = false, Timer = false, Text = "Редкие аномалии случаются... (gmm_convar_anomalies_rare = 1)"},
    Disabled = {Tag = "DISABLED"     , Warn = true , Timer = false, Text = "Аномалии отключены: gmm_convar_anomalies = 0 и gmm_convar_anomalies_rare = 0."},
    NotOnMap = {Tag = "NO"           , Warn = true , Timer = false, Text = "На этой карте нет аномалий, а редкие отключены (gmm_convar_anomalies_rare = 0)"},
    Empty    = {Tag = "EMPTY"        , Warn = true , Timer = false, Text = "ГДЕ СУКА СПИСОК АНОМАЛИЙ А?! ТЫ ЧЁ СДЕЛАЛ УПЫРЬ?"}
}
local AnomalySourceNames = {
    Timer  = "таймер",
    Fast   = "вспышка",
    Rare   = "редкая",
    Manual = "вручную"
}
local AnomalyListStatuses = {Normal = true, Fast = true, Rare = true}
local AnomalyState = {
    Status       = "Unknown",
    EndsAt       = 0,
    Total        = 0,
    FastKey      = "",
    FastTitle    = "",
    FastTotal    = 0,
    LastKey      = "",
    LastTitle    = "",
    LastSource   = "",
    LastWho      = "",
    LastClock    = 0,
    LastAt       = 0,
    LastOk       = true,
    LastReply    = 0,
    List         = {},
    ListReceived = false,
    ResultText   = "",
    ResultOk     = true,
    ResultAt     = 0
}
local FindAnomalyTitle = function(Key)
    local List = AnomalyState.List
    for i = 1, #List do
        if List[i].Key == Key then return List[i].Title end
    end
    return Key
end
local GetFastSubject = function()
    if AnomalyState.FastKey == "" then return "UNKNOWN ANOMALY!" end
    local Title = AnomalyState.FastTitle
    if Title == "" then Title = FindAnomalyTitle(AnomalyState.FastKey) end
    return Title .. " (" .. AnomalyState.FastKey .. ")"
end
local GetLastSubject = function()
    return AnomalyState.LastTitle .. " (" .. AnomalyState.LastKey .. ")"
end
local GetLastSourceText = function()
    local Text = AnomalySourceNames[AnomalyState.LastSource] or AnomalyState.LastSource
    if AnomalyState.LastSource == "Manual" and AnomalyState.LastWho ~= "" then
        Text = Text .. ": " .. AnomalyState.LastWho
    end
    if not AnomalyState.LastOk then Text = Text .. " / ERROR!" end
    return Text
end
local GetAnomalyStatusKey = function(Card, Now)
    if not IsAnomaliesUnlocked() then return "Locked" end
    local Silence = Now - math.max(AnomalyState.LastReply, Card.__CreatedAt)
    if Silence > 3 then return "NoReply" end
    return AnomalyState.Status
end
local GetAnomalyLayoutKey = function()
    if not IsAnomaliesUnlocked() then return "Locked" end
    local Show = "N"
    if AnomalyListStatuses[AnomalyState.Status] then Show = "L" end
    return Show .. #AnomalyState.List
end
net.Receive("gmm_AnomalyState", function()
    local Now        = RealTime()
    local Status     = net.ReadString()
    local Remaining  = net.ReadFloat()
    local Total      = net.ReadFloat()
    local FastKey    = net.ReadString()
    local FastTitle  = net.ReadString()
    local LastKey    = net.ReadString()
    local LastTitle  = net.ReadString()
    local LastSource = net.ReadString()
    local LastWho    = net.ReadString()
    local LastClock  = net.ReadUInt(32)
    local LastAgo    = net.ReadFloat()
    local LastOk     = net.ReadBool()
    local WithList   = net.ReadBool()
    if Status == "Fast" then
        if AnomalyState.Status ~= "Fast" or Remaining > AnomalyState.FastTotal then
            AnomalyState.FastTotal = Remaining
        end
    else
        AnomalyState.FastTotal = 0
    end
    AnomalyState.Status     = Status
    AnomalyState.EndsAt     = Now + Remaining
    AnomalyState.Total      = Total
    AnomalyState.FastKey    = FastKey
    AnomalyState.FastTitle  = FastTitle
    AnomalyState.LastKey    = LastKey
    AnomalyState.LastTitle  = LastTitle
    AnomalyState.LastSource = LastSource
    AnomalyState.LastWho    = LastWho
    AnomalyState.LastClock  = LastClock
    AnomalyState.LastAt     = Now - LastAgo
    AnomalyState.LastOk     = LastOk
    AnomalyState.LastReply  = Now
    if not WithList then return end
    local Count = net.ReadUInt(8)
    local List  = {}
    for i = 1, Count do
        local Key    = net.ReadString()
        local Title  = net.ReadString()
        local Weight = net.ReadUInt(16)
        List[i] = {Key = Key, Title = Title, Weight = Weight}
    end
    AnomalyState.List         = List
    AnomalyState.ListReceived = true
end)
net.Receive("gmm_AnomalyFireResult", function()
    local Key  = net.ReadString()
    local Ok   = net.ReadBool()
    local Text = net.ReadString()
    local Title = FindAnomalyTitle(Key)
    if Key == "" then Title = "RANDOM" end
    AnomalyState.ResultOk = Ok
    AnomalyState.ResultAt = RealTime()
    if Ok then
        AnomalyState.ResultText = Title .. ": Successfully launched!"
        return
    end
    AnomalyState.ResultText = "ERROR! " .. Title .. ": " .. Text
    print("[GMM] ANOMALY FIRE ERROR! KEY: " .. Key .. ", TEXT: " .. Text)
end)
-- ----------------------------------------------------------------------
local CreateAnomalyCard = function(Panel, Rebuild)
    local Card = vgui.Create("DPanel")
    Card:SetPaintBackground(false)
    Card:SetTall(120)
    local Now = RealTime()
    Card.__CreatedAt      = Now
    Card.__NextRequest    = 0
    Card.__ShownKey       = GetAnomalyLayoutKey()
    Card.__StatusKey      = GetAnomalyStatusKey(Card, Now)
    Card.__LayoutSig      = ""
    Card.__Rebuilding     = false
    Card.__ShowLast       = false
    Card.__Lines          = {}
    Card.__ResultLines    = {}
    Card.__Subject        = ""
    Card.__SubjectLabelW  = 0
    Card.__LastSubject    = ""
    Card.__LastLabelW     = 0
    Card.__LastClockText  = ""
    Card.__LastSourceText = ""
    Card.__TimerY         = 0
    Card.__BarY           = 0
    Card.__SubjectY       = 0
    Card.__LinesY         = 0
    Card.__ResultY        = 0
    Card.__LastY          = 0
    Card.PerformLayout = function(self, w, h)
        if w < 60 then return end
        local InnerW = w - Pad * 2
        local Info   = AnomalyStatusInfo[self.__StatusKey] or AnomalyStatusInfo.Unknown
        self.__Lines       = WrapLines(Info.Text, "gmm_UI_Text", InnerW)
        self.__ResultLines = {}
        if self.__StatusKey ~= "Locked" and AnomalyState.ResultText ~= "" then
            self.__ResultLines = WrapLines(AnomalyState.ResultText, "gmm_UI_Small", InnerW)
        end
        local Y = PadY + TitleH
        if Info.Timer then
            self.__TimerY = Y
            Y = Y + 36
            self.__BarY = Y
            Y = Y + BarH + GapY
        end
        if self.__StatusKey == "Fast" then
            surface.SetFont("gmm_UI_Text")
            self.__SubjectLabelW = surface.GetTextSize("Аномалия: ")
            self.__Subject       = GetFastSubject()
            self.__SubjectY      = Y
            Y = Y + 24
        end
        self.__LinesY = Y
        Y = Y + #self.__Lines * LineH
        if #self.__ResultLines > 0 then
            Y = Y + GapY
            self.__ResultY = Y
            Y = Y + #self.__ResultLines * LineH
        end
        if self.__ShowLast then
            surface.SetFont("gmm_UI_Text")
            self.__LastLabelW     = surface.GetTextSize("Последняя: ")
            self.__LastSubject    = GetLastSubject()
            self.__LastClockText  = os.date("%H:%M:%S", AnomalyState.LastClock)
            self.__LastSourceText = GetLastSourceText()
            Y = Y + GapY
            self.__LastY = Y
            Y = Y + 22 + LineH
        end
        local Needed = Y + PadY + 2
        if self:GetTall() ~= Needed then self:SetTall(Needed) end
    end
    Card.Think = function(self)
        local Now      = RealTime()
        local Unlocked = IsAnomaliesUnlocked()
        if Unlocked and Now >= self.__NextRequest then
            self.__NextRequest = Now + 0.3
            if net.Start("gmm_AnomalyStateRequest") then
                net.WriteBool(not AnomalyState.ListReceived)
                net.SendToServer()
            end
        end
        local StatusKey = GetAnomalyStatusKey(self, Now)
        self.__StatusKey = StatusKey
        self.__ShowLast  = Unlocked and AnomalyState.LastClock > 0 and StatusKey ~= "NoReply"
        local Sig = StatusKey .. "|" .. AnomalyState.ResultAt .. "|" .. AnomalyState.FastKey
        Sig = Sig .. "|" .. tostring(self.__ShowLast) .. "|" .. AnomalyState.LastClock .. "|" .. AnomalyState.LastKey
        Sig = Sig .. "|" .. AnomalyState.LastSource .. "|" .. tostring(AnomalyState.LastOk)
        if Sig ~= self.__LayoutSig then
            self.__LayoutSig = Sig
            self:InvalidateLayout()
        end
        if self.__Rebuilding then return end
        if GetAnomalyLayoutKey() == self.__ShownKey then return end
        self.__Rebuilding = true
        timer.Simple(0, function()
            if IsValid(self) and IsValid(Panel) then Rebuild(Panel) end
        end)
    end
    Card.Paint = function(self, w, h)
        local Now  = RealTime()
        local Info = AnomalyStatusInfo[self.__StatusKey] or AnomalyStatusInfo.Unknown
        local Fast = self.__StatusKey == "Fast"
        DrawGlassBack(w, h)
        local TitleY = PadY + TitleH / 2
        DrawTitleText(":ANOMALIES:", "gmm_UI_Title", Pad, TitleY)
        if Info.Warn then
            DrawBadge(Info.Tag, "gmm_UI_Small", w - Pad, TitleY, ColorBadgeWarnFill, ColorBadgeWarnBorder)
        else
            DrawBadge(Info.Tag, "gmm_UI_Small", w - Pad, TitleY, ColorBadgeFill, ColorBadgeBorder)
        end
        if Info.Timer then
            local Left = math.max(AnomalyState.EndsAt - Now, 0)
            local TimeColor = ColorTitle
            local BarColor  = ColorBarGreen
            if Info.Warn then
                TimeColor = ColorWarn
                BarColor  = ColorBarOrange
            end
            draw.SimpleText(string.format("%.2f", Left) .. " с", "gmm_UI_Big", Pad, self.__TimerY + 18, TimeColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            local Total    = AnomalyState.Total
            local Fraction = 0
            if Fast then Total = AnomalyState.FastTotal end
            if Total > 0 then
                Fraction = math.Clamp(Left / Total, 0, 1)
                if not Fast then Fraction = 1 - Fraction end
                DrawProgress(Pad, self.__BarY, w - Pad * 2, BarH, Fraction, BarColor, 255)
            else
                DrawProgress(Pad, self.__BarY, w - Pad * 2, BarH, 1, BarColor, 150 + 105 * math.abs(math.sin(Now * 6)))
            end
        end
        if Fast then
            local CenterY = self.__SubjectY + 10
            draw.SimpleText("Аномалия: "   , "gmm_UI_Text", Pad                       , CenterY, ColorDim , TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(self.__Subject , "gmm_UI_Name", Pad + self.__SubjectLabelW, CenterY, ColorWarn, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        local Lines = self.__Lines
        for i = 1, #Lines do
            draw.SimpleText(Lines[i], "gmm_UI_Text", Pad, self.__LinesY + (i - 1) * LineH + LineH / 2, ColorText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        local ResultColor = ColorDim
        if not AnomalyState.ResultOk then ResultColor = ColorWarn end
        local ResultLines = self.__ResultLines
        for i = 1, #ResultLines do
            draw.SimpleText(ResultLines[i], "gmm_UI_Small", Pad, self.__ResultY + (i - 1) * LineH + LineH / 2, ResultColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        if self.__ShowLast then
            local SubjectY = self.__LastY + 11
            local DetailsY = self.__LastY + 22 + LineH / 2
            local SubjectColor = ColorTitle
            local DetailsColor = ColorDim
            if not AnomalyState.LastOk then
                SubjectColor = ColorWarn
                DetailsColor = ColorWarn
            end
            local Ago = math.max(Now - AnomalyState.LastAt, 0)
            draw.SimpleText("Последняя: "      , "gmm_UI_Text", Pad                    , SubjectY, ColorDim    , TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(self.__LastSubject , "gmm_UI_Name", Pad + self.__LastLabelW, SubjectY, SubjectColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(self.__LastClockText .. " (" .. FormatAgo(Ago) .. ") / " .. self.__LastSourceText, "gmm_UI_Small", Pad, DetailsY, DetailsColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    end
    Panel:AddItem(Card)
    return Card
end
local CreateAnomalyRow = function(Panel, Entry, Index, TotalWeight, CanFire)
    local Row = vgui.Create("DButton")
    Row:SetText("")
    Row:SetTall(52)
    local Percent = 0
    if TotalWeight > 0 then Percent = Entry.Weight / TotalWeight * 100 end
    Row.__Tag = Entry.Key .. " / вес " .. Entry.Weight .. " / " .. string.format("%.0f", Percent) .. "%"
    Row.Paint = function(self, w, h)
        local Hot = CanFire and self:IsHovered()
        DrawCardBack(w, h, Hot)
        draw.SimpleText(Entry.Title, "gmm_UI_Name" , Pad, 17, ColorTitle, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(self.__Tag  , "gmm_UI_Small", Pad, 36, ColorDim  , TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        local State = "Normal"
        if not CanFire then
            State = "Disabled"
        elseif self:IsDown() then
            State = "Down"
        elseif Hot then
            State = "Hover"
        end
        local Style   = ButtonStyles[State]
        local ButtonW = 104
        local ButtonH = 26
        local ButtonX = w - Pad - ButtonW
        local ButtonY = math.floor((h - 2 - ButtonH) / 2)
        local Label = "RUN"
        if not CanFire then Label = "ONLY ADMIN" end
        DrawGlossBox(ButtonX, ButtonY, ButtonW, ButtonH, Style, CornerRadius)
        draw.SimpleText(Label, "gmm_UI_Text", ButtonX + ButtonW / 2, ButtonY + ButtonH / 2, Style.Text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    Row.DoClick = function(self)
        if not CanFire then return end
        AnomalyState.ResultOk   = true
        AnomalyState.ResultText = "Запускаю: " .. Entry.Title .. "..."
        AnomalyState.ResultAt   = RealTime()
        if net.Start("gmm_AnomalyFire") then
            net.WriteString(Entry.Key)
            net.SendToServer()
        end
    end
    Panel:AddItem(Row)
    return Row
end
local function FillAnomalyPanel(Panel)
    Panel:ClearControls()
    CreateAnomalyCard(Panel, FillAnomalyPanel)
    if not IsAnomaliesUnlocked() then return end
    if not AnomalyListStatuses[AnomalyState.Status] then return end
    local List        = AnomalyState.List
    local TotalWeight = 0
    for i = 1, #List do
        TotalWeight = TotalWeight + List[i].Weight
    end
    local Ply     = LocalPlayer()
    local CanFire = IsValid(Ply) and Ply:IsAdmin()
    local RandomButton = CreateButton(Panel, "RUN RANDOM", function()
        AnomalyState.ResultOk   = true
        AnomalyState.ResultText = "Запускаю случайную аномалию..."
        AnomalyState.ResultAt   = RealTime()
        if net.Start("gmm_AnomalyFire") then
            net.WriteString("")
            net.SendToServer()
        end
    end)
    RandomButton:SetEnabled(CanFire)
    for i = 1, #List do
        CreateAnomalyRow(Panel, List[i], i, TotalWeight, CanFire)
    end
end
hook.Add("PopulateToolMenu", "gmm_PopulateTools", function()
    spawnmenu.AddToolMenuOption("Utilities", "GMM", "gmm_Menu_Main", "CORE", "", "", function(Panel)
        if GMM_C.CoreTab == nil then
            Panel:Help("CORE TAB FAILED TO LOAD!")
            return
        end
        GMM_C.CoreTab.Build(Panel)
    end)
    spawnmenu.AddToolMenuOption("Utilities", "GMM", "gmm_Menu_ServerConVars", "CONVAR_SERVER", "", "", function(Panel)
        FillConVarPanel(Panel, true)
    end)
    spawnmenu.AddToolMenuOption("Utilities", "GMM", "gmm_Menu_ClientConVars", "CONVAR_CLIENT", "", "", function(Panel)
        FillConVarPanel(Panel, false)
    end)
    if IsAnomaliesUnlocked() then
        spawnmenu.AddToolMenuOption("Utilities", "GMM", "gmm_Menu_Anomalies", "ANOMALIES", "", "", function(Panel)
            FillAnomalyPanel(Panel)
        end)
    end
end)