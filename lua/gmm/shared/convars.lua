GMM.ConVars = {
    Server = {},
    Client = {},

    ByName = {}
}

-- ----------------------------------------------------------------------

GMM.ConVars.Prefix = "gmm_convar_"

local GlitchChars = {
    "#", "%", "&", "?", "@", "!", "$", "*", "+", "=",
    "~", "^", "/", "\\", "|", "<", ">", ":", ";", "_",
    "0", "1", "3", "7", "9", "X", "Z", "E", "R", "R"
}

GMM.ConVars.IsDoorFound = function()
    if CLIENT then
        if GMM_C ~= nil and GMM_C.CoreTab ~= nil and GMM_C.CoreTab.IsCompleted ~= nil then
            return GMM_C.CoreTab.IsCompleted()
        end

        return cookie.GetNumber("gmm_core_arg", 1) >= 6
    end

    return true
end

GMM.ConVars.CanUse = function(Def)
    if type(Def) == "string" then
        Def = GMM.ConVars.GetDefOrError(Def)
    end
    if Def == nil then return false end

    if type(Def.CanUse) == "function" then
        return Def.CanUse(Def) == true
    end
    if Def.CanUse == false then
        return false
    end

    if type(Def.Secret) == "function" then
        return Def.Secret(Def) == true
    end
    if Def.Secret == true then
        return GMM.ConVars.IsDoorFound()
    end

    return true
end

GMM.ConVars.CanUseOption = function(Def, Option)
    if not GMM.ConVars.CanUse(Def) then return false end
    if Option == nil then return false end

    if type(Option.CanUse) == "function" then
        return Option.CanUse(Def, Option) == true
    end
    if Option.CanUse == false then
        return false
    end

    if type(Option.Secret) == "function" then
        return Option.Secret(Def, Option) == true
    end
    if Option.Secret == true then
        return GMM.ConVars.IsDoorFound()
    end

    return true
end

GMM.ConVars.GetGlitchText = function(SeedText, Length)
    SeedText = tostring(SeedText or "")

    if Length == nil then
        local UtfLength = utf8 and utf8.len(SeedText) or #SeedText
        Length = math.Clamp(UtfLength or #SeedText, 5, 32)
    end

    local Now  = CLIENT and RealTime() or CurTime()
    local Tick = math.floor(Now * 10)
    local Hash = 0

    for i = 1, #SeedText do
        Hash = (Hash * 31 + string.byte(SeedText, i)) % 2147483647
    end

    local Out = {}
    for i = 1, Length do
        local Index = ((Hash + i * 73 + Tick * 19 + math.floor((Tick + i) / 3) * 131) % #GlitchChars) + 1
        Out[i] = GlitchChars[Index]
    end

    return table.concat(Out)
end

GMM.ConVars.__ApplyExtra = function(Target, Extra)
    if type(Extra) ~= "table" then return end

    Target.Extra  = Extra
    Target.Secret = Extra.Secret or Extra.NeedDoor or false
    Target.CanUse = Extra.CanUse
end

GMM.ConVars.__BuildEnum = function(Def, Options)
    if type(Options) ~= "table" or #Options == 0 then
        error("[GMM] AddConVar: FOR Enum NEED Options! Name: " .. tostring(Def.Name))
    end

    Def.Options      = {}
    Def.ValueByName  = {}
    Def.NameByValue  = {}
    Def.OptionByValue = {}

    for i = 1, #Options do
        local Option      = Options[i]
        local OptionName  = Option
        local OptionValue = i - 1
        local OptionExtra = nil

        if type(Option) == "table" then
            OptionName  = Option[1]
            OptionValue = Option[2]
            OptionExtra = Option[3]
        end

        if type(OptionName) ~= "string" then
            error("[GMM] AddConVar: Enum OPTION NAME MUST BE string! Name: " .. Def.Name .. ", Index: " .. i)
        end
        if type(OptionValue) ~= "number" or OptionValue ~= math.floor(OptionValue) then
            error("[GMM] AddConVar: Enum OPTION VALUE MUST BE int! Name: " .. Def.Name .. ", Option: " .. OptionName)
        end
        if Def.ValueByName[OptionName] ~= nil then
            error("[GMM] AddConVar: Enum DUPLICATE OPTION NAME! Name: " .. Def.Name .. ", Option: " .. OptionName)
        end
        if Def.NameByValue[OptionValue] ~= nil then
            error("[GMM] AddConVar: Enum DUPLICATE OPTION VALUE! Name: " .. Def.Name .. ", Value: " .. OptionValue)
        end

        local OptionDef = {
            Name  = OptionName,
            Value = OptionValue
        }
        if OptionExtra == true then
            OptionDef.Secret = true
        elseif type(OptionExtra) == "table" then
            GMM.ConVars.__ApplyExtra(OptionDef, OptionExtra)
        end

        table.insert(Def.Options, OptionDef)
        Def.ValueByName[OptionName]    = OptionValue
        Def.NameByValue[OptionValue]   = OptionName
        Def.OptionByValue[OptionValue] = OptionDef

        if Def.Min == nil or OptionValue < Def.Min then Def.Min = OptionValue end
        if Def.Max == nil or OptionValue > Def.Max then Def.Max = OptionValue end
    end

    if type(Def.Default) == "string" then
        Def.Default = Def.ValueByName[Def.Default]
    end
    if Def.Default == nil or Def.NameByValue[Def.Default] == nil then
        error("[GMM] AddConVar: Enum DEFAULT NOT IN Options! Name: " .. Def.Name)
    end
end

GMM.ConVars.Add = function(Server, Type, Name, Default, Description, Min, Max, Extra, Options)
    Name        = GMM.ConVars.Prefix .. Name
    Description = Description or ""

    if type(Min) == "table" and Extra == nil then
        Extra = Min
        Min   = nil
    end

    if Type ~= "Bool" and Type ~= "Int" and Type ~= "Float" and Type ~= "String" and Type ~= "Enum" then
        error("[GMM] AddConVar: UNKNOWN Type! Name: " .. tostring(Name) .. ", Type: " .. tostring(Type))
    end
    if GMM.ConVars.ByName[Name] ~= nil then
        error("[GMM] AddConVar: ALREADY ADDED! Name: " .. tostring(Name))
    end

    if Type == "Bool" then
        Min = 0
        Max = 1
    end
    if (Type == "Int" or Type == "Float") and (Min == nil or Max == nil) then
        error("[GMM] AddConVar: FOR Int & Float NEED Min & Max! Name: " .. tostring(Name))
    end

    local Def = {
        Server      = Server,
        Type        = Type,
        Name        = Name,
        Default     = Default,
        Description = Description,
        Min         = Min,
        Max         = Max,
        ConVar      = nil,
        Extra       = nil,
        Secret      = false,
        CanUse      = nil
    }

    GMM.ConVars.__ApplyExtra(Def, Extra)

    if Type == "Enum" then
        Def.Min = nil
        Def.Max = nil
        GMM.ConVars.__BuildEnum(Def, Options)
    end

    local DefaultText = tostring(Def.Default)
    if Type == "Bool" then
        if Def.Default == true or Def.Default == 1 then
            DefaultText = "1"
        else
            DefaultText = "0"
        end
    end

    if Server then
        local Flags = FCVAR_REPLICATED
        if SERVER then Flags = bit.bor(Flags, FCVAR_ARCHIVE) end
        Def.ConVar = CreateConVar(Name, DefaultText, Flags, Description, Def.Min, Def.Max)
    elseif CLIENT then
        Def.ConVar = CreateClientConVar(Name, DefaultText, true, false, Description, Def.Min, Def.Max)
    end

    table.insert(GMM.ConVars[Server and "Server" or "Client"], Def)
    GMM.ConVars.ByName[Name] = Def

    return Def
end

GMM.ConVars.AddEnum = function(Server, Name, Default, Description, Options, Extra)
    return GMM.ConVars.Add(Server, "Enum", Name, Default, Description, nil, nil, Extra, Options)
end

GMM.ConVars.AddFlags = function(Server, Name, Description, Options, Extra)
    local Flags   = {}
    local Full    = 0
    local Default = 0

    for i, Option in ipairs(Options) do
        local Value = bit.lshift(1, i - 1)

        Full = bit.bor(Full, Value)
        if Option[3] then Default = bit.bor(Default, Value) end

        table.insert(Flags, {Key = Option[1], Name = Option[2], Value = Value})
    end

    GMM.ConVars.Add(Server, "Int", Name, Default, Description, 0, Full, Extra)

    local Def = GMM.ConVars.GetDefOrError(Name)
    Def.Flags = Flags

    return Def
end

GMM.ConVars.GetFlagValue = function(Name, Key)
    local Def = GMM.ConVars.GetDefOrError(Name)

    if Def.Flags == nil then error("[GMM] CONVAR HAS NO FLAGS! SHORTNAME: " .. Name) end

    for i = 1, #Def.Flags do
        if Def.Flags[i].Key == Key then return Def.Flags[i].Value end
    end

    error("[GMM] CONVAR HAS NO SUCH FLAG! SHORTNAME: " .. Name .. ", KEY: " .. Key)
end

GMM.ConVars.HasFlag = function(Mask, Flag)
    return bit.band(Mask, Flag) ~= 0
end

GMM.ConVars.NormalizeValue = function(Def, Text)
    if Def.Type == "Bool" then
        if Text == "1" or Text == "true" then return "1" end
        return "0"
    end

    if Def.Type == "String" then return string.sub(Text, 1, 256) end

    if Def.Type == "Enum" then
        local ValueByName = Def.ValueByName[Text]
        if ValueByName ~= nil then return tostring(ValueByName) end

        local EnumNumber = tonumber(Text)
        if EnumNumber == nil then return nil end
        if Def.NameByValue[EnumNumber] == nil then return nil end

        return tostring(EnumNumber)
    end

    local Number = tonumber(Text)
    if Number == nil then return nil end

    Number = math.Clamp(Number, Def.Min, Def.Max)
    if Def.Type == "Int" then Number = math.floor(Number + 0.5) end

    return tostring(Number)
end

GMM.ConVars.GetDisplayText = function(Def, Text)
    if not GMM.ConVars.CanUse(Def) then
        return GMM.ConVars.GetGlitchText(Def.Name .. "_value", 8)
    end

    if Def.Type ~= "Enum" then return Text end

    local EnumValue = tonumber(Text)
    local Option    = Def.OptionByValue and Def.OptionByValue[EnumValue]
    if Option ~= nil and not GMM.ConVars.CanUseOption(Def, Option) then
        return GMM.ConVars.GetGlitchText(Def.Name .. "_" .. tostring(Text), 8)
    end

    local Name = Def.NameByValue[EnumValue]
    if Name == nil then return "? " .. Text end

    return Name
end

GMM.ConVars.GetDisplayName = function(Def)
    if not GMM.ConVars.CanUse(Def) then
        return GMM.ConVars.GetGlitchText(Def.Name)
    end

    return Def.Name
end

GMM.ConVars.GetDisplayDescription = function(Def)
    if not GMM.ConVars.CanUse(Def) then
        return GMM.ConVars.GetGlitchText(Def.Description ~= "" and Def.Description or Def.Name)
    end

    return Def.Description
end

GMM.ConVars.GetDefOrError = function(ShortName)
    local Def = GMM.ConVars.ByName[GMM.ConVars.Prefix .. ShortName]
    if Def == nil then
        error("[GMM] CONVAR NOT FOUND! SHORTNAME: " .. tostring(ShortName), 3)
    end

    return Def
end

GMM.ConVars.GetInt    = function(ShortName) return GMM.ConVars.GetDefOrError(ShortName).ConVar:GetInt   () end
GMM.ConVars.GetFloat  = function(ShortName) return GMM.ConVars.GetDefOrError(ShortName).ConVar:GetFloat () end
GMM.ConVars.GetBool   = function(ShortName) return GMM.ConVars.GetDefOrError(ShortName).ConVar:GetBool  () end
GMM.ConVars.GetString = function(ShortName) return GMM.ConVars.GetDefOrError(ShortName).ConVar:GetString() end

GMM.ConVars.GetEnumName = function(ShortName)
    local Def = GMM.ConVars.GetDefOrError(ShortName)

    return GMM.ConVars.GetDisplayText(Def, Def.ConVar:GetString())
end

GMM.ConVars.IsEnum = function(ShortName, OptionName)
    local Def   = GMM.ConVars.GetDefOrError(ShortName)
    local Value = Def.ValueByName and Def.ValueByName[OptionName]
    if Value == nil then
        error("[GMM] CONVAR HAS NO SUCH OPTION! SHORTNAME: " .. ShortName .. ", OPTIONNAME: " .. tostring(OptionName), 2)
    end

    return Def.ConVar:GetInt() == Value
end

if SERVER then
    util.AddNetworkString("gmm_SetServerConVar")

    net.Receive("gmm_SetServerConVar", function(L, Player)
        if not IsValid(Player) then return end
        if not Player:IsSuperAdmin() then return end

        local Name = net.ReadString()
        local Text = net.ReadString()

        local Def = GMM.ConVars.ByName[Name]
        if Def == nil or Def.Server ~= true then
            print("[GMM] THAT SERVER CONVAR NOT EXIST! Name: " .. Name .. ", Player: " .. Player:Nick())
            return
        end

        local Value = GMM.ConVars.NormalizeValue(Def, Text)
        if Value == nil then
            print("[GMM] INCORRECT VALUE! Name: " .. Name .. ", Text: " .. Text .. ", Player: " .. Player:Nick())
            return
        end

        if Value == Def.ConVar:GetString() then return end

        Def.ConVar:SetString(Value)
        print("[GMM] " .. Player:Nick() .. " CHANGE " .. Name .. " = " .. Value)
    end)
end

-- ----------------------------------------------------------------------

GMM.ConVars.AddEnum(true, "anomalies", 1, "Отвечает за работу аномалий", {
    {"Никогда"      , 0},
    {"Только на GMM", 1},
    {"Всегда"       , 2}
}, {Secret = true})
GMM.ConVars.Add(true, "Float", "anomalies_timer", 10, "Скорость вызова аномалий", 0.1, 240, {Secret = true})
GMM.ConVars.Add(true, "Bool" , "anomalies_rare" , 1, "Редкие аномалии, даже если отключены аномалии", {Secret = true})
GMM.ConVars.Add(true, "Bool" , "entities_unlock", 0, "GMM энтити можно спавнить на любой карте (нужен перезапуск что-бы появилась вкладка GMM)", {Secret = true})

-- ----------------------------------------------------------------------

GMM.ConVars.AddEnum(false, "void", 1, "Отображать эффект Void", {
    {"Никогда"      , 0},
    {"Только на GMM", 1},
    {"Всегда"       , 2},
    {"ABSOLUTE"     , 3, {Secret = true}}
})
GMM.ConVars.Add(false, "Float", "void_power", 1, "Сила эффекта Void", 0.01, 30)
GMM.ConVars.Add(false, "Bool", "debug_showposition", 0, "Отображать позицию и поворот камеры игрока")
GMM.ConVars.Add(false, "Bool", "debug_showhit", 0, "Отображать Trace.Hit из камеры игрока")
GMM.ConVars.AddFlags(false, "debug_hit_surfaces", "На какие поверхности и объекты реагирует отладочный луч", {
    {"Solid"      , "Твёрдые"                   , true },
    {"Transparent", "Прозрачные"                , true },
    {"Water"      , "Вода"                      , false},
    {"Clip"       , "Невидимые стены (clip)"    , false},
    {"Sky"        , "Небо"                      , true },
    {"NoDraw"     , "Скрытая геометрия (nodraw)", true },
    {"Entities"   , "Энтити"                    , true },
    {"Props"      , "Пропы"                     , true }
})
GMM.ConVars.Add(false, "Bool", "debug_showsounds", 0, "Отображать информацию об Ambient Sounds")