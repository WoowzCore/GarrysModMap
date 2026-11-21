GMM.ConVars = {
    Server = {},
    Client = {},

    ByName = {}
}

-- ----------------------------------------------------------------------

GMM.ConVars.Prefix = "gmm_convar_"

GMM.ConVars.__BuildEnum = function(Def, Options)
    if type(Options) ~= "table" or #Options == 0 then
        error("[GMM] AddConVar: FOR Enum NEED Options! Name: " .. tostring(Def.Name))
    end

    Def.Options     = {}
    Def.ValueByName = {}
    Def.NameByValue = {}

    for i = 1, #Options do
        local Option      = Options[i]
        local OptionName  = Option
        local OptionValue = i - 1

        if type(Option) == "table" then
            OptionName  = Option[1]
            OptionValue = Option[2]
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

        table.insert(Def.Options, {Name = OptionName, Value = OptionValue})
        Def.ValueByName[OptionName]  = OptionValue
        Def.NameByValue[OptionValue] = OptionName

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

GMM.ConVars.Add = function(Server, Type, Name, Default, Description, Min, Max, Options)
    Name        = GMM.ConVars.Prefix .. Name
    Description = Description or ""

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
        ConVar      = nil
    }

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

GMM.ConVars.AddEnum = function(Server, Name, Default, Description, Options)
    return GMM.ConVars.Add(Server, "Enum", Name, Default, Description, nil, nil, Options)
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
    if Def.Type ~= "Enum" then return Text end

    local Name = Def.NameByValue[tonumber(Text)]
    if Name == nil then return "? " .. Text end

    return Name
end

GMM.ConVars.GetDefOrError = function(ShortName)
    local Def = GMM.ConVars.ByName[GMM.ConVars.Prefix .. ShortName]
    if Def == nil then
        error("[GMM] КОНВАР НЕ НАЙДЕН! ShortName: " .. tostring(ShortName), 3)
    end

    return Def
end

GMM.ConVars.GetInt    = function(ShortName) return GMM.ConVars.GetDefOrError(ShortName).ConVar:GetInt() end
GMM.ConVars.GetFloat  = function(ShortName) return GMM.ConVars.GetDefOrError(ShortName).ConVar:GetFloat() end
GMM.ConVars.GetBool   = function(ShortName) return GMM.ConVars.GetDefOrError(ShortName).ConVar:GetBool() end
GMM.ConVars.GetString = function(ShortName) return GMM.ConVars.GetDefOrError(ShortName).ConVar:GetString() end

GMM.ConVars.GetEnumName = function(ShortName)
    local Def = GMM.ConVars.GetDefOrError(ShortName)

    return GMM.ConVars.GetDisplayText(Def, Def.ConVar:GetString())
end

GMM.ConVars.IsEnum = function(ShortName, OptionName)
    local Def   = GMM.ConVars.GetDefOrError(ShortName)
    local Value = Def.ValueByName and Def.ValueByName[OptionName]
    if Value == nil then
        error("[GMM] У КОНВАРА НЕТ ТАКОГО ВАРИАНТА! ShortName: " .. ShortName .. ", OptionName: " .. tostring(OptionName), 2)
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

GMM.ConVars.AddEnum(true, "anomalies", 1, "Отвечает за работу аномалий.", {
    {"Выключено"           , 0},
    {"Только на GMM картах", 1},
    {"Везде"               , 2}
})