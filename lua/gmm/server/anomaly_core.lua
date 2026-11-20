local NextAnomalyTick = 0
local FastModeEndTime = 0
local ActiveFastAnomaly = nil

GMM.Func.FireAnomaly = function()
    local Anomaly = nil

    if ActiveFastAnomaly then
        Anomaly = ActiveFastAnomaly
    else
        Anomaly = GMM_S.Anomaly.GetRandom()

        if math.random() < 0.005 then
            FastModeEndTime = CurTime() + math.random(5, 30)
            ActiveFastAnomaly = Anomaly
        end
    end

    if Anomaly then
        Anomaly()
    else
        print("[GMM] ANOMALY SELECTION FAILED!")
    end
end

if GMM.Valid and GMM.DoAnomalies then
    local AnomalyTick = GMM.Maps.Goofy and 0.5 or 10

    timer.Create("gmm_AnomalyTimer", 0.1, 0, function()
        local T = CurTime()

        if ActiveFastAnomaly then
            if T > FastModeEndTime then
                ActiveFastAnomaly = nil
                NextAnomalyTick = T + AnomalyTick
            else
                GMM.Func.FireAnomaly()
            end
        else
            if T >= NextAnomalyTick then
                GMM.Func.FireAnomaly()
                NextAnomalyTick = T + AnomalyTick
            end
        end
    end)
else
    timer.Create("gmm_AnomalyTimer", 1, 0, function()
        if math.random() > 0.999 then
            GMM.Func.FireAnomaly()
        end
    end)
end