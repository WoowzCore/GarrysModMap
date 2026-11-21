GMM_S.Func.GetAnomalyInterval = function()
    if GMM.Maps.Goofy then return 0.5 end

    return GMM.ConVars.GetFloat("anomalies_timer")
end

GMM_S.Func.ResetAnomalyTimer = function()
    if GMM_S.AnomalyState == nil then return end

    GMM_S.AnomalyState.NextTick = CurTime() + GMM_S.Func.GetAnomalyInterval()
end

GMM_S.AnomalyState = {
    NextTick    = CurTime() + GMM_S.Func.GetAnomalyInterval(),
    NextRare    = 0,
    FastEndTime = 0,
    FastAnomaly = nil,

    LastKey     = "",
    LastTitle   = "",
    LastSource  = "",
    LastWho     = "",
    LastClock   = 0,
    LastCurTime = 0,
    LastOk      = true
}

-- ----------------------------------------------------------------------

GMM_S.Func.IsRegularAnomalies = function()
    return GMM.Func.DoAnomalies()
end

GMM_S.Func.IsRareAnomalies = function()
    if GMM_S.Func.IsRegularAnomalies() then return false end

    return GMM.ConVars.GetBool("anomalies_rare")
end

GMM_S.Func.GetRareDelay = function()
    return math.Rand(10, 1000)
end

-- ----------------------------------------------------------------------

GMM_S.Func.FindEntryByFunctionOrNil = function(Anomaly)
    if Anomaly == nil then return nil end

    local List = GMM_S.Anomaly.List
    for i = 1, #List do
        if GMM_S.Anomaly[List[i][2]] == Anomaly then return List[i] end
    end

    return nil
end

GMM_S.Func.RememberAnomaly = function(Entry, Source, Who, Ok)
    local State = GMM_S.AnomalyState

    State.LastKey     = Entry[2]
    State.LastTitle   = Entry[3]
    State.LastSource  = Source
    State.LastWho     = Who or ""
    State.LastClock   = os.time()
    State.LastCurTime = CurTime()
    State.LastOk      = Ok and true or false
end

-- ----------------------------------------------------------------------

GMM_S.Func.FireAnomaly = function(AllowFast)
    local State   = GMM_S.AnomalyState
    local Anomaly = State.FastAnomaly

    local Source = "Rare"
    if AllowFast then Source = "Timer" end
    if Anomaly ~= nil then Source = "Fast" end

    if Anomaly == nil then
        Anomaly = GMM_S.Anomaly.GetRandom()

        if AllowFast and Anomaly ~= nil and math.random() < 0.005 then
            State.FastEndTime = CurTime() + math.random(5, 30)
            State.FastAnomaly = Anomaly
        end
    end

    if Anomaly == nil then
        print("[GMM] ANOMALY SELECTION FAILED!")
        return
    end

    local Ok, Error = pcall(Anomaly)
    if not Ok then
        ErrorNoHalt("[GMM] ANOMALY CRASHED! " .. tostring(Error) .. "\n")
    end

    local Entry = GMM_S.Func.FindEntryByFunctionOrNil(Anomaly)
    if Entry ~= nil then GMM_S.Func.RememberAnomaly(Entry, Source, "", Ok) end
end

GMM_S.Func.FireAnomalyByKey = function(Key, Who)
    local Entry = GMM_S.Anomaly.FindEntryOrNil(Key)
    if Entry == nil then return false, "NO ANOMALY WITH KEY " .. tostring(Key) .. "!" end

    local Anomaly = GMM_S.Anomaly[Entry[2]]
    if Anomaly == nil then return false, "NO FUNCTION GMM_S.Anomaly." .. Entry[2] .. "!" end

    local Ok, Error = pcall(Anomaly)
    GMM_S.Func.RememberAnomaly(Entry, "Manual", Who, Ok)

    if not Ok then return false, tostring(Error) end

    return true, ""
end

GMM_S.Func.GetAnomalyStatus = function()
    local Regular = GMM_S.Func.IsRegularAnomalies()
    local Rare    = GMM_S.Func.IsRareAnomalies()

    if not Regular and not Rare then
        if GMM.ConVars.GetInt("anomalies") == 0 then return "Disabled" end

        return "NotOnMap"
    end

    if #GMM_S.Anomaly.List == 0 then return "Empty" end
    if Rare then return "Rare" end
    if GMM_S.AnomalyState.FastAnomaly ~= nil then return "Fast" end

    return "Normal"
end

-- ----------------------------------------------------------------------

timer.Create("gmm_AnomalyTimer", 0.1, 0, function()
    local State    = GMM_S.AnomalyState
    local T        = CurTime()
    local Interval = GMM_S.Func.GetAnomalyInterval()

    if GMM_S.Func.IsRegularAnomalies() then
        State.NextRare = 0

        if State.FastAnomaly ~= nil then
            if T <= State.FastEndTime then
                GMM_S.Func.FireAnomaly(true)
                return
            end

            State.FastAnomaly = nil
            State.NextTick    = T + Interval
            return
        end

        if T < State.NextTick then return end

        State.NextTick = T + Interval
        GMM_S.Func.FireAnomaly(true)
        return
    end

    State.FastAnomaly = nil
    State.NextTick    = T + Interval

    if not GMM_S.Func.IsRareAnomalies() then
        State.NextRare = 0
        return
    end

    if State.NextRare == 0 then
        State.NextRare = T + GMM_S.Func.GetRareDelay()
        return
    end

    if T < State.NextRare then return end

    State.NextRare = T + GMM_S.Func.GetRareDelay()
    GMM_S.Func.FireAnomaly(false)
end)

-- ----------------------------------------------------------------------

cvars.AddChangeCallback("gmm_convar_anomalies_timer", function(Name, OldValue, NewValue)
    GMM_S.Func.ResetAnomalyTimer()
end, "gmm_AnomalyTimerReset")