GMM_S.Func.IsDoorLocked = function(Ent)
    if not IsValid(Ent) then return false end

    local Flags = Ent:GetInternalVariable("m_spawnflags")
    if Flags and bit.band(Flags, 2048) ~= 0 then
        return true
    end

    local Locked = Ent:GetInternalVariable("m_bLocked")
    if Locked == true or Locked == 1 then
        return true
    end

    return false
end

GMM_S.Func.IsPlayerOnlyDoor = function(Ent)
    if not IsValid(Ent) then return false end

    local Flags = Ent:GetInternalVariable("m_spawnflags")
    if not Flags then return false end

    if bit.band(Flags, 32 ) ~= 0 then return true end
    if bit.band(Flags, 512) ~= 0 then return true end

    return false
end

GMM_S.Func.CanOpenDoor = function(Ent)
    if not IsValid(Ent) then return false end
    if GMM_S.Func.IsDoorLocked(Ent) then return false end
    if GMM_S.Func.IsPlayerOnlyDoor(Ent) then return false end
    return true
end