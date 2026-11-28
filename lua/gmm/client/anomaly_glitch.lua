if SERVER then return end

GMM_C = GMM_C or {}
GMM_C.RenderGlitch = GMM_C.RenderGlitch or {}

local G = GMM_C.RenderGlitch

local NetRenderGlitch      = "gmm_Anomaly_RenderGlitch"
local MaterialKeepDuration = 60

G.Active         = false
G.StartTime      = 0
G.EndTime        = 0
G.Strength       = 1
G.BaseSeed       = 1
G.RngState       = 1
G.Origin         = Vector(0, 0, 0)
G.SavedMats      = G.SavedMats or {}
G.MatModLists    = G.MatModLists or {
    tex   = {},
    color = {},
    tf    = {},
    flags = {}
}
G.MatModMap      = G.MatModMap or {
    tex   = {},
    color = {},
    tf    = {},
    flags = {}
}
G.GlitchModels   = G.GlitchModels or {}
G.DropKind       = nil
G.LightMode      = 0
G.LitActive      = false
G.ViewOffset     = Vector(0, 0, 0)
G.ViewAngle      = Angle(0, 0, 0)
G.ScreenTint     = nil
G.HookGlitchKind = nil

-- ----------------------------------------------------------------------
-- Единый детерминированный ГСЧ
-- ----------------------------------------------------------------------

local function ResetRng(Seed)
    local Base = math.floor(tonumber(Seed) or 1)
    if Base <= 0 then Base = 1 end
    G.RngState = Base % 2147483647
    if G.RngState == 0 then G.RngState = 123456789 end
end

local function SetStepRng(StepIndex, Salt)
    local Combined = (G.BaseSeed + (StepIndex * 104729) + (Salt * 7919)) % 2147483647
    if Combined <= 0 then Combined = 123456789 end
    G.RngState = Combined
end

local function NextRand()
    G.RngState = (G.RngState * 16807) % 2147483647
    return (G.RngState - 1) / 2147483646
end

local function RandRange(MinVal, MaxVal)
    return MinVal + (MaxVal - MinVal) * NextRand()
end

local function RandInt(MinVal, MaxVal)
    if MaxVal <= MinVal then return MinVal end
    return math.floor(MinVal + NextRand() * (MaxVal - MinVal + 1))
end

local function RandVector()
    return Vector(RandRange(-1, 1), RandRange(-1, 1), RandRange(-1, 1))
end

-- ----------------------------------------------------------------------
-- Битые текстуры и материалы (рендерятся строго в PreRender по тикам)
-- ----------------------------------------------------------------------

local RtSize        = 128
local RtCount       = 6
local RTs           = {}
local CModels       = {}
local RtPainted     = false
local RtForceAll    = false
local LastRtTick    = -1

for i = 1, RtCount do
    RTs[i] = GetRenderTarget("gmm_glitch_rt_" .. i, RtSize, RtSize)
    CModels[i] = CreateMaterial("gmm_glitch_mat_" .. i, "VertexLitGeneric", {
        ["$basetexture"] = RTs[i]:GetName(),
        ["$model"]       = 1
    })
end

local function SetRandomDrawColor()
    surface.SetDrawColor(RandInt(0, 255), RandInt(0, 255), RandInt(0, 255), 255)
end

local function PaintGlitchRT(Index)
    local RT = RTs[Index]
    if RT == nil then return end

    render.PushRenderTarget(RT)
    cam.Start2D()
    render.Clear(0, 0, 0, 255, true)
    draw.NoTexture()

    local Pattern = RandInt(1, 4)

    if Pattern == 1 then
        for _ = 1, 70 do
            SetRandomDrawColor()
            local Size = RandInt(1, 6) * 8
            surface.DrawRect(RandInt(-8, RtSize), RandInt(-8, RtSize), Size, Size)
        end
    elseif Pattern == 2 then
        local Y = 0
        while Y < RtSize do
            local H = RandInt(1, 14)
            SetRandomDrawColor()
            surface.DrawRect(RandInt(-40, 0), Y, RtSize + 40, H)
            Y = Y + H
        end
    elseif Pattern == 3 then
        local Cell = RtSize / 8
        for X = 0, 7 do
            for Y = 0, 7 do
                if (X + Y) % 2 == 0 then
                    surface.SetDrawColor(255, 0, 255, 255)
                else
                    surface.SetDrawColor(0, 0, 0, 255)
                end
                surface.DrawRect(X * Cell, Y * Cell, Cell, Cell)
            end
        end
    else
        local X = 0
        while X < RtSize do
            local W = RandInt(1, 10)
            SetRandomDrawColor()
            surface.DrawRect(X, RandInt(-30, 0), W, RtSize + 30)
            X = X + W
        end
    end

    cam.End2D()
    render.PopRenderTarget()
end

-- ----------------------------------------------------------------------
-- Поверхности карты и детерминированный список сущностей вокруг Origin
-- ----------------------------------------------------------------------

local CachedSurfs   = {}
local CachedSurfMap = nil
local SurfRetryTime = 0

local function GetWorldSurfaces()
    local CurrentMap = game.GetMap()
    local Now        = CurTime()

    if CachedSurfMap ~= CurrentMap or (#CachedSurfs == 0 and Now > SurfRetryTime) then
        SurfRetryTime = Now + 3
        local World = game.GetWorld()
        if IsValid(World) then
            local Ok, Res = pcall(function() return World:GetBrushSurfaces() end)
            CachedSurfs = (Ok and Res) or {}
            if #CachedSurfs > 0 then
                CachedSurfMap = CurrentMap
            end
        end
    end

    return CachedSurfs
end

local function PickSurface(MaxDist, Tries)
    local List  = GetWorldSurfaces()
    local Count = #List
    if Count == 0 then return nil end

    local Origin   = G.Origin
    local MaxDist2 = MaxDist and (MaxDist * MaxDist) or nil
    local MaxTries = Tries or 25

    for _ = 1, MaxTries do
        local Surf = List[RandInt(1, Count)]
        if Surf ~= nil and not (Surf:IsSky() or Surf:IsWater() or Surf:IsNoDraw()) then
            if not MaxDist2 then return Surf end
            local Verts = Surf:GetVertices()
            if Verts and Verts[1] and Verts[1]:DistToSqr(Origin) < MaxDist2 then
                return Surf, Verts
            end
        end
    end

    for _ = 1, 15 do
        local Surf = List[RandInt(1, Count)]
        if Surf ~= nil and not (Surf:IsSky() or Surf:IsWater() or Surf:IsNoDraw()) then
            return Surf
        end
    end

    return nil
end

local function WorldMatOK(Mat)
    local Name = string.lower(Mat:GetName())
    if string.find(Name, "^tools/", 1, false)
            or string.find(Name, "sky", 1, true)
            or string.find(Name, "water", 1, true)
            or string.find(Name, "^effects/", 1, false)
    then
        return false
    end

    local Shader = Mat:GetShader()
    return Shader == "LightmappedGeneric" or Shader == "WorldVertexTransition"
end

local NearbyPool     = {}
local NearbyPoolTime = 0

local function IsEligibleEntity(Ent)
    if not IsValid(Ent) or Ent:IsPlayer() or Ent:IsWeapon() or Ent:GetNoDraw() then
        return false
    end
    if Ent:EntIndex() <= 0 then
        return false
    end
    local Mdl = Ent:GetModel()
    if not Mdl or Mdl == "" then
        return false
    end
    return Ent:IsNPC()
            or Ent:IsNextBot()
            or Ent:IsRagdoll()
            or string.find(Ent:GetClass(), "^prop_", 1, false) ~= nil
end

local function SortByEntIndex(A, B)
    return A:EntIndex() < B:EntIndex()
end

local function GetNearbyEntities(ForceRefresh)
    local Now = CurTime()
    if ForceRefresh or Now > NearbyPoolTime then
        NearbyPoolTime = Now + 0.5
        NearbyPool     = {}
        local Found = ents.FindInSphere(G.Origin, 2500)
        for i = 1, #Found do
            local Ent = Found[i]
            if IsEligibleEntity(Ent) then
                NearbyPool[#NearbyPool + 1] = Ent
            end
        end
        table.sort(NearbyPool, SortByEntIndex)
    end

    return NearbyPool
end

local function GetNearbyRandomEntity()
    local Pool = GetNearbyEntities(false)
    if #Pool == 0 then return nil end
    local Ent = Pool[RandInt(1, #Pool)]
    if IsValid(Ent) then return Ent end
    return nil
end

-- ----------------------------------------------------------------------
-- Реестр материалов: сохранение оригиналов и откат по полям
-- Поля: tex ($basetexture) | color ($color2) | tf ($basetexturetransform) | flags ($flags)
-- ----------------------------------------------------------------------

local function MatApply(Mat, Field, Value)
    if Field == "tex" then
        if type(Value) == "string" then
            local TexMat = Material(Value)
            local TexObj = TexMat and TexMat:GetTexture("$basetexture")
            if TexObj then
                Mat:SetTexture("$basetexture", TexObj)
            else
                Mat:SetTexture("$basetexture", Value)
            end
        else
            Mat:SetTexture("$basetexture", Value)
        end
    elseif Field == "color" then
        Mat:SetVector("$color2", Value)
    elseif Field == "tf" then
        Mat:SetMatrix("$basetexturetransform", Value)
    elseif Field == "flags" then
        Mat:SetInt("$flags", Value)
        Mat:Recompute()
    end
end

local function MatSetRaw(Mat, Field, Value)
    if Mat == nil or Mat:IsError() then return false end
    local Name  = Mat:GetName()
    local Saved = G.SavedMats[Name]

    if not Saved then
        Saved = {
            Mat   = Mat,
            Orig  = {},
            Dirty = {}
        }
        G.SavedMats[Name] = Saved
    end

    if not Saved.Dirty[Field] then
        local OrigVal = nil
        if Field == "tex" then
            OrigVal = Mat:GetTexture("$basetexture")
            if not OrigVal then return false end
        elseif Field == "color" then
            OrigVal = Mat:GetVector("$color2") or Vector(1, 1, 1)
        elseif Field == "tf" then
            OrigVal = Mat:GetMatrix("$basetexturetransform") or Matrix()
        elseif Field == "flags" then
            OrigVal = Mat:GetInt("$flags")
            if not OrigVal then return false end
        end
        Saved.Orig[Field]  = OrigVal
        Saved.Dirty[Field] = true
    end

    MatApply(Mat, Field, Value)
    return true
end

local function MatSet(Mat, Field, Value)
    local Ok, Res = pcall(MatSetRaw, Mat, Field, Value)
    return Ok and Res or false
end

local function MatRestore(Name, Field)
    local Saved = G.SavedMats[Name]
    if not Saved or not Saved.Dirty[Field] then return end
    pcall(MatApply, Saved.Mat, Field, Saved.Orig[Field])
    Saved.Dirty[Field] = nil
end

local function RegisterMatMod(Field, Name, Data)
    local List = G.MatModLists[Field]
    local Map  = G.MatModMap[Field]
    local Old  = Map[Name]

    if Old then
        for i = 1, #List do
            if List[i].Name == Name then
                List[i] = Data
                break
            end
        end
    else
        List[#List + 1] = Data
    end

    Map[Name] = Data
end

local function RemoveMatModAt(Field, Index)
    local List = G.MatModLists[Field]
    local Data = List[Index]
    if Data then
        G.MatModMap[Field][Data.Name] = nil
    end
    table.remove(List, Index)
end

local function RestoreAllMaterials()
    local Fields = { "tex", "color", "tf", "flags" }
    for f = 1, #Fields do
        local Field = Fields[f]
        local List  = G.MatModLists[Field]
        for i = #List, 1, -1 do
            MatRestore(List[i].Name, Field)
            List[i] = nil
        end
        G.MatModMap[Field] = {}
    end

    for Name, Saved in pairs(G.SavedMats) do
        for Field in pairs(Saved.Dirty) do
            MatRestore(Name, Field)
        end
        G.SavedMats[Name] = nil
    end
end

-- ----------------------------------------------------------------------
-- Глюки материалов (worldtex, modeltex, worlduv, worldcolor, worldflags)
-- ----------------------------------------------------------------------

local DevTexList = { "dev/graygrid", "dev/dev_measuregeneric01", "dev/dev_measurewall01a" }
local UvKinds    = { "swim", "scroll", "stretch" }
local WorldFlags = { 268435456, 32768, 128, 8192 } -- WIREFRAME, IGNOREZ, ADDITIVE, NOCULL

local function PickWorldMat()
    local Surf = PickSurface(3500, 40)
    if not Surf then return nil end
    local Mat = Surf:GetMaterial()
    if Mat and not Mat:IsError() and WorldMatOK(Mat) then
        return Mat
    end
    return nil
end

local function PickModelMat()
    local Ent = GetNearbyRandomEntity()
    if not Ent then return nil end
    local List = Ent:GetMaterials()
    if not List or #List == 0 then return nil end
    local Mat = Material(List[RandInt(1, #List)])
    if not Mat or Mat:IsError() then return nil end
    local Shader = Mat:GetShader()
    if Shader == "VertexLitGeneric" or Shader == "UnlitGeneric" then
        return Mat
    end
    return nil
end

local function PickCorruptTex()
    local Roll = NextRand()
    if Roll < 0.40 then
        local Mat = PickWorldMat()
        if Mat then
            local Tex = Mat:GetTexture("$basetexture")
            if Tex then return Tex end
        end
    elseif Roll < 0.70 then
        return RTs[RandInt(1, RtCount)]
    elseif Roll < 0.85 then
        return DevTexList[RandInt(1, #DevTexList)]
    end
    return "error"
end

local function MakeRandomTint()
    local Roll = NextRand()
    if Roll < 0.25 then return Vector(0.05, 0.05, 0.05) end
    if Roll < 0.45 then return Vector(4, 4, 4) end
    local Col = HSVToColor(RandRange(0, 360), 1, 1)
    return Vector(Col.r / 255 * 2.5, Col.g / 255 * 2.5, Col.b / 255 * 2.5)
end

local function ApplyUvTransform(Mat, Data, Strength, Now)
    local MatTf = Matrix()
    if Data.Kind == "swim" then
        MatTf:SetTranslation(Vector(RandRange(-0.1, 0.1) * Strength, RandRange(-0.1, 0.1) * Strength, 0))
    elseif Data.Kind == "scroll" then
        local Elapsed = Now - Data.StartTime
        MatTf:SetTranslation(Vector(Data.Vx * Elapsed, Data.Vy * Elapsed, 0))
    else
        local Jitter = 1 + RandRange(-0.15, 0.15)
        MatTf:SetScale(Vector(Data.Sx * Jitter, Data.Sy * Jitter, 1))
    end
    return MatSet(Mat, "tf", MatTf)
end

local function SpawnWorldTexGlitch(Now)
    local Mat = PickWorldMat()
    if not Mat then return end
    local Name = Mat:GetName()
    if MatSet(Mat, "tex", PickCorruptTex()) then
        RegisterMatMod("tex", Name, {
            Name      = Name,
            Mat       = Mat,
            UntilTime = Now + MaterialKeepDuration
        })
    end
end

local function SpawnModelTexGlitch(Now)
    local Mat = PickModelMat()
    if not Mat then return end
    local Name = Mat:GetName()
    if MatSet(Mat, "tex", PickCorruptTex()) then
        RegisterMatMod("tex", Name, {
            Name      = Name,
            Mat       = Mat,
            UntilTime = Now + MaterialKeepDuration
        })
    end
end

local function SpawnWorldUvGlitch(Now)
    local Mat = PickWorldMat()
    if not Mat then return end
    local Name = Mat:GetName()
    local Data = {
        Name      = Name,
        Mat       = Mat,
        Kind      = UvKinds[RandInt(1, #UvKinds)],
        StartTime = Now,
        Vx        = RandRange(-2, 2),
        Vy        = RandRange(-2, 2),
        Sx        = 2 ^ RandRange(-3, 3),
        Sy        = 2 ^ RandRange(-3, 3),
        UntilTime = Now + MaterialKeepDuration
    }
    if ApplyUvTransform(Mat, Data, G.Strength, Now) then
        RegisterMatMod("tf", Name, Data)
    end
end

local function SpawnWorldColorGlitch(Now)
    local Mat = PickWorldMat()
    if not Mat then return end
    local Name = Mat:GetName()
    if MatSet(Mat, "color", MakeRandomTint()) then
        RegisterMatMod("color", Name, {
            Name      = Name,
            Mat       = Mat,
            UntilTime = Now + MaterialKeepDuration
        })
    end
end

local function SpawnWorldFlagsGlitch(Now)
    local Mat = PickWorldMat()
    if not Mat then return end
    local Name = Mat:GetName()
    local Flag = WorldFlags[RandInt(1, #WorldFlags)]
    local Cur  = Mat:GetInt("$flags") or 0
    if MatSet(Mat, "flags", bit.bor(Cur, Flag)) then
        RegisterMatMod("flags", Name, {
            Name      = Name,
            Mat       = Mat,
            UntilTime = Now + RandRange(0.15, 0.85)
        })
    end
end

local function ApplyLongMaterials(Now)
    local TexCount   = RandInt(3, 6)
    local ModelCount = RandInt(2, 4)
    local UvCount    = RandInt(2, 5)
    local ColorCount = RandInt(2, 5)
    local FlagCount  = RandInt(1, 3)

    for _ = 1, TexCount do SpawnWorldTexGlitch(Now) end
    for _ = 1, ModelCount do SpawnModelTexGlitch(Now) end
    for _ = 1, UvCount do SpawnWorldUvGlitch(Now) end
    for _ = 1, ColorCount do SpawnWorldColorGlitch(Now) end
    for _ = 1, FlagCount do SpawnWorldFlagsGlitch(Now) end
end

local LastMatTick = -1

local function UpdateLongMaterials(Now)
    local Elapsed = math.max(0, Now - G.StartTime)
    local MatTick = math.floor(Elapsed / 0.05)
    local DoStep  = MatTick ~= LastMatTick

    if DoStep then
        LastMatTick = MatTick
        SetStepRng(MatTick, 1)
    end

    -- 1. Откат и обновление текстур ($basetexture)
    local TexList = G.MatModLists.tex
    for i = #TexList, 1, -1 do
        local Data = TexList[i]
        if Now >= Data.UntilTime then
            MatRestore(Data.Name, "tex")
            RemoveMatModAt("tex", i)
        elseif G.Active and DoStep and NextRand() < 0.20 then
            MatSet(Data.Mat, "tex", PickCorruptTex())
        end
    end

    -- 2. Откат и обновление цветов ($color2)
    local ColorList = G.MatModLists.color
    for i = #ColorList, 1, -1 do
        local Data = ColorList[i]
        if Now >= Data.UntilTime then
            MatRestore(Data.Name, "color")
            RemoveMatModAt("color", i)
        elseif G.Active and DoStep and NextRand() < 0.25 then
            MatSet(Data.Mat, "color", MakeRandomTint())
        end
    end

    -- 3. Откат и обновление UV ($basetexturetransform)
    local TfList = G.MatModLists.tf
    for i = #TfList, 1, -1 do
        local Data = TfList[i]
        if Now >= Data.UntilTime then
            MatRestore(Data.Name, "tf")
            RemoveMatModAt("tf", i)
        elseif DoStep and (G.Active or Data.Kind == "scroll") then
            ApplyUvTransform(Data.Mat, Data, G.Strength, Now)
        end
    end

    -- 4. Откат флагов ($flags)
    local FlagList = G.MatModLists.flags
    for i = #FlagList, 1, -1 do
        local Data = FlagList[i]
        if Now >= Data.UntilTime then
            MatRestore(Data.Name, "flags")
            RemoveMatModAt("flags", i)
        end
    end

    -- Пока импульс активен — детерминированно по тику добавляем новые сбои
    if G.Active and DoStep then
        if NextRand() < 0.25 then SpawnWorldTexGlitch(Now) end
        if NextRand() < 0.15 then SpawnModelTexGlitch(Now) end
        if NextRand() < 0.20 then SpawnWorldUvGlitch(Now) end
        if NextRand() < 0.20 then SpawnWorldColorGlitch(Now) end
        if NextRand() < 0.10 then SpawnWorldFlagsGlitch(Now) end
    end
end

-- ----------------------------------------------------------------------
-- Откат моделей и хуков рендера
-- ----------------------------------------------------------------------

local function RestoreSingleModel(Item)
    if Item == nil then return end
    local Ent = Item.Ent
    if not IsValid(Ent) then return end

    if Item.Hooked then
        Ent.RenderOverride = Item.OldOverride
    end

    Ent:DisableMatrix("RenderMultiply")
    Ent:SetRenderOrigin()
    Ent:SetRenderAngles()

    if Item.OldMat ~= nil then
        Ent:SetMaterial(Item.OldMat)
    end
end

local function RestoreGlitchModels()
    for i = #G.GlitchModels, 1, -1 do
        RestoreSingleModel(G.GlitchModels[i])
        G.GlitchModels[i] = nil
    end
end

function G.StopPulse()
    G.Active         = false
    G.EndTime        = 0
    G.DropKind       = nil
    G.LightMode      = 0
    G.HookGlitchKind = nil
    G.ScreenTint     = nil
    G.ViewOffset     = Vector(0, 0, 0)
    G.ViewAngle      = Angle(0, 0, 0)

    RestoreGlitchModels()

    local FlagList = G.MatModLists.flags
    for i = #FlagList, 1, -1 do
        MatRestore(FlagList[i].Name, "flags")
        RemoveMatModAt("flags", i)
    end

    if G.LitActive then
        render.SetLightingMode(0)
        G.LitActive = false
    end
end

function G.StopAll()
    G.StopPulse()
    RestoreAllMaterials()
end

-- ----------------------------------------------------------------------
-- Глюки рендера моделей и хуков
-- ----------------------------------------------------------------------

local ModelOverrideMats = {
    "models/debug/debugwhite",
    "models/wireframe",
    "debug/env_cubemap_model",
    "models/shiny",
    "error"
}

local function ApplyModelGlitches()
    local Candidates = GetNearbyEntities(true)
    if #Candidates == 0 then return end

    local PickCount = math.min(#Candidates, RandInt(1, 3))

    for _ = 1, PickCount do
        local Ent  = Candidates[RandInt(1, #Candidates)]
        local Kind = RandInt(1, 4)

        local Item = {
            Ent         = Ent,
            OldOverride = Ent.RenderOverride,
            OldMat      = Ent:GetMaterial(),
            Hooked      = false
        }

        if Kind == 1 then
            local OverrideMat = CModels[RandInt(1, RtCount)]
            Item.Hooked = true
            Ent.RenderOverride = function(Self, Flags)
                if OverrideMat ~= nil and not OverrideMat:IsError() then
                    render.ModelMaterialOverride(OverrideMat)
                end
                Self:DrawModel(Flags)
                render.ModelMaterialOverride()
            end
        elseif Kind == 2 then
            local Mat = Matrix()
            Mat:Scale(Vector(
                    math.max(0.15, 1 + RandRange(-0.4, 1.2) * G.Strength),
                    math.max(0.15, 1 + RandRange(-0.4, 1.2) * G.Strength),
                    math.max(0.15, 1 + RandRange(-0.4, 1.2) * G.Strength)
            ))
            Ent:EnableMatrix("RenderMultiply", Mat)
        elseif Kind == 3 then
            Ent:SetRenderOrigin(Ent:GetPos() + RandVector() * RandRange(3, 16) * G.Strength)
            Ent:SetRenderAngles(Ent:GetAngles() + Angle(RandRange(-20, 20), RandRange(-40, 40), RandRange(-25, 25)) * G.Strength)
        else
            Ent:SetMaterial(ModelOverrideMats[RandInt(1, #ModelOverrideMats)])
        end

        G.GlitchModels[#G.GlitchModels + 1] = Item
    end
end

local DropKinds       = { "sky", "opaque", "players", "translucent" }
local HookGlitchKinds = { "view_tilt", "view_shift", "screen_flash" }

local function ApplyHookGlitches()
    G.DropKind       = nil
    G.LightMode      = 0
    G.HookGlitchKind = nil
    G.ScreenTint     = nil
    G.ViewOffset     = Vector(0, 0, 0)
    G.ViewAngle      = Angle(0, 0, 0)

    if NextRand() < 0.65 then
        G.DropKind = DropKinds[RandInt(1, #DropKinds)]
    end

    if NextRand() < 0.65 then
        G.LightMode = NextRand() < 0.65 and 1 or 2
    end

    if NextRand() < 0.85 then
        local Kind = HookGlitchKinds[RandInt(1, #HookGlitchKinds)]
        G.HookGlitchKind = Kind

        if Kind == "view_tilt" then
            G.ViewAngle = Angle(
                    RandRange(-8, 8) * G.Strength,
                    RandRange(-12, 12) * G.Strength,
                    RandRange(-16, 16) * G.Strength
            )
        elseif Kind == "view_shift" then
            G.ViewOffset = RandVector() * RandRange(8, 28) * G.Strength
        elseif Kind == "screen_flash" then
            local Col = HSVToColor(RandRange(0, 360), 0.9, 1)
            G.ScreenTint = Color(Col.r, Col.g, Col.b, math.Clamp(math.floor(45 * G.Strength), 20, 110))
        end
    end
end

-- ----------------------------------------------------------------------
-- Запуск и хуки
-- ----------------------------------------------------------------------

local function TriggerOnce(StartTime, Duration, Strength, Seed, Origin)
    G.StopPulse()

    local ClampedDur = math.Clamp(Duration, 0.2, 60)

    G.Active    = true
    G.StartTime = StartTime
    G.EndTime   = StartTime + ClampedDur
    G.Strength  = math.Clamp(Strength, 0.2, 2.5)
    G.BaseSeed  = math.floor(tonumber(Seed) or 1)
    G.Origin    = Origin or Vector(0, 0, 0)

    LastMatTick = -1
    LastRtTick  = -1
    RtForceAll  = true

    ResetRng(G.BaseSeed)

    ApplyLongMaterials(StartTime)
    ApplyModelGlitches()
    ApplyHookGlitches()
end

net.Receive(NetRenderGlitch, function()
    local Enabled   = net.ReadBool()
    local StartTime = net.ReadFloat()
    local Duration  = net.ReadFloat()
    local Strength  = net.ReadFloat()
    local Seed      = net.ReadUInt(31)
    local Origin    = net.ReadVector()

    if not Enabled then
        G.StopAll()
        return
    end

    TriggerOnce(StartTime, Duration, Strength, Seed, Origin)
end)

hook.Add("Think", "GMM_Anomaly_RenderGlitch_Think", function()
    local Now = CurTime()

    UpdateLongMaterials(Now)

    if G.Active and Now >= G.EndTime then
        G.StopPulse()
    end
end)

hook.Add("CalcView", "GMM_Anomaly_RenderGlitch_CalcView", function(Ply, Pos, Angles, FOV)
    if not G.Active then return end
    if G.HookGlitchKind ~= "view_tilt" and G.HookGlitchKind ~= "view_shift" then return end

    return {
        origin     = Pos + G.ViewOffset,
        angles     = Angles + G.ViewAngle,
        fov        = FOV,
        drawviewer = false
    }
end)

hook.Add("RenderScreenspaceEffects", "GMM_Anomaly_RenderGlitch_ScreenFX", function()
    if not G.Active or G.ScreenTint == nil then return end

    surface.SetDrawColor(G.ScreenTint.r, G.ScreenTint.g, G.ScreenTint.b, G.ScreenTint.a)
    surface.DrawRect(0, 0, ScrW(), ScrH())
end)

hook.Add("PreRender", "GMM_Anomaly_RenderGlitch_PreRender", function()
    local Now = CurTime()

    if not RtPainted or RtForceAll then
        SetStepRng(0, 2)
        for i = 1, RtCount do
            PaintGlitchRT(i)
        end
        RtPainted  = true
        RtForceAll = false
    elseif G.Active then
        local Elapsed = math.max(0, Now - G.StartTime)
        local RtTick  = math.floor(Elapsed / 0.08)
        if RtTick ~= LastRtTick then
            LastRtTick = RtTick
            SetStepRng(RtTick, 2)
            PaintGlitchRT(RandInt(1, RtCount))
        end
    end

    if not G.Active or G.LightMode == 0 then return end

    render.SetLightingMode(G.LightMode)
    G.LitActive = true
end)

hook.Add("PostRender", "GMM_Anomaly_RenderGlitch_PostRender", function()
    if G.LitActive then
        render.SetLightingMode(0)
        G.LitActive = false
    end
end)

hook.Add("PreDrawSkyBox", "GMM_Anomaly_RenderGlitch_DropSky", function()
    if G.Active and G.DropKind == "sky" then return true end
end)

hook.Add("PreDrawOpaqueRenderables", "GMM_Anomaly_RenderGlitch_DropOpaque", function()
    if G.Active and G.DropKind == "opaque" then return true end
end)

hook.Add("PrePlayerDraw", "GMM_Anomaly_RenderGlitch_DropPlayers", function()
    if G.Active and G.DropKind == "players" then return true end
end)

hook.Add("PreDrawTranslucentRenderables", "GMM_Anomaly_RenderGlitch_DropTrans", function()
    if G.Active and G.DropKind == "translucent" then return true end
end)

hook.Add("ShutDown", "GMM_Anomaly_RenderGlitch_ShutDown", function()
    G.StopAll()
end)