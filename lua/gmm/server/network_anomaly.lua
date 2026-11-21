util.AddNetworkString("gmm_AnomalyStateRequest")
util.AddNetworkString("gmm_AnomalyState")
util.AddNetworkString("gmm_AnomalyFire")
util.AddNetworkString("gmm_AnomalyFireResult")

-- ----------------------------------------------------------------------

GMM_S.Func.FindFastEntryOrNil = function()
    local State = GMM_S.AnomalyState
    if State == nil then return nil end

    return GMM_S.Func.FindEntryByFunctionOrNil(State.FastAnomaly)
end

GMM_S.Func.FireRandomAnomaly = function(Who)
    local Entry = GMM_S.Func.FindEntryByFunctionOrNil(GMM_S.Anomaly.GetRandom())
    if Entry == nil then return "", false, "ANOMALY LIST IS EMPTY!" end

    local Ok, Text = GMM_S.Func.FireAnomalyByKey(Entry[2], Who)

    return Entry[2], Ok, Text
end

GMM_S.Func.SendAnomalyState = function(Player, WithList)
    local State  = GMM_S.AnomalyState
    local Status = GMM_S.Func.GetAnomalyStatus()
    local Now    = CurTime()

    local Remaining = 0
    local Total     = 0
    local FastKey   = ""
    local FastTitle = ""

    if Status == "Normal" then
        Remaining = math.max(State.NextTick - Now, 0)
        Total     = GMM_S.Func.GetAnomalyInterval()
    elseif Status == "Fast" then
        Remaining = math.max(State.FastEndTime - Now, 0)

        local Entry = GMM_S.Func.FindFastEntryOrNil()
        if Entry ~= nil then
            FastKey   = Entry[2]
            FastTitle = Entry[3]
        end
    end

    local LastAgo = 0
    if State.LastClock > 0 then LastAgo = math.max(Now - State.LastCurTime, 0) end

    net.Start("gmm_AnomalyState")
    net.WriteString(Status)
    net.WriteFloat(Remaining)
    net.WriteFloat(Total)
    net.WriteString(FastKey)
    net.WriteString(FastTitle)
    net.WriteString(State.LastKey)
    net.WriteString(State.LastTitle)
    net.WriteString(State.LastSource)
    net.WriteString(State.LastWho)
    net.WriteUInt(State.LastClock, 32)
    net.WriteFloat(LastAgo)
    net.WriteBool(State.LastOk)
    net.WriteBool(WithList)

    if WithList then
        local List  = GMM_S.Anomaly.List
        local Count = math.min(#List, 255)

        net.WriteUInt(Count, 8)
        for i = 1, Count do
            net.WriteString(List[i][2])
            net.WriteString(List[i][3])
            net.WriteUInt(List[i][1], 16)
        end
    end

    net.Send(Player)
end

-- ----------------------------------------------------------------------

net.Receive("gmm_AnomalyStateRequest", function(L, Player)
    if not IsValid(Player) then return end

    local WithList = net.ReadBool()

    local Now = CurTime()
    if Now < (Player.__GMM_NextStateRequest or 0) then return end
    Player.__GMM_NextStateRequest = Now + 0.15

    GMM_S.Func.SendAnomalyState(Player, WithList)
end)

net.Receive("gmm_AnomalyFire", function(L, Player)
    if not IsValid(Player) then return end
    if not Player:IsAdmin() then return end

    local Key = net.ReadString()

    local Now = CurTime()
    if Now < (Player.__GMM_NextFire or 0) then return end
    Player.__GMM_NextFire = Now + 0.25

    local Ok   = false
    local Text = "ANOMALIES ARE DISABLED!"

    local Status = GMM_S.Func.GetAnomalyStatus()
    if Status == "Normal" or Status == "Fast" or Status == "Rare" then
        if Key == "" then
            Key, Ok, Text = GMM_S.Func.FireRandomAnomaly(Player:Nick())
        else
            Ok, Text = GMM_S.Func.FireAnomalyByKey(Key, Player:Nick())
        end
    end

    net.Start("gmm_AnomalyFireResult")
    net.WriteString(Key)
    net.WriteBool(Ok and true or false)
    net.WriteString(string.sub(tostring(Text or ""), 1, 200))
    net.Send(Player)

    local LogKey = Key
    if LogKey == "" then LogKey = "RANDOM (FAILED)" end

    print("[GMM] " .. Player:Nick() .. " RUN ANOMALY " .. LogKey)
end)