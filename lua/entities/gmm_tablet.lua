AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "I-N-F-O-T-A-S-K"
ENT.Author = "Woowz11"
ENT.Category = "GMM"
ENT.Spawnable = GMM["Valid"]

local TabletText = {
    "Карта валидна, можно играть. Игры игры игрушечки, играем мы в игры, вкусно играли, доигрались...",
    "Привет, эта табличка здесь новая, поздоровайтесь с ней! Привет, привет, как дела? Нормально вот лежу, а у тебя? Да вот карту делаю. ЗАЧЕМ.",
    "Sample Text, Example Text: Кодим на языках, пайтон говно, пайтон говно, пайтон говно, кодим дальше, смайлеки",
    "Ссаки, ккаки, табличка это типо отсылка на ТЕКСТ??? Вы знаете? 61 88 33 50 10 20 66 01 22 15 14 66 22 66? Это просто набор цифр?!(числ)",
    "Hi, welcome here! Кто сказал эту фразу? вы знаете как его зовут, ВЫ ЗЕ ВСЗНАЕТЕ ЕГО ИЯ, напишите мне: god_of_lithium_universe"
}

local TabletTextRare = {
    [1] = "Помогите что мне делать? Что если я хочу сделать свою игру, но ... допишите текст"
}

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "TextID")
    self:NetworkVar("Bool", 1, "TextRare")
end

function ENT:Initialize()
	self:SetModel("models/hunter/plates/plate05x05.mdl")
    self:SetMaterial("woowz_map/gm_garrymod_map_by_woowz_map_garry_game/model/tablet_base")

    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local PhysicsObject = self:GetPhysicsObject()
    if IsValid(PhysicsObject) then
        PhysicsObject:Wake()
        PhysicsObject:SetMaterial("rock")
        PhysicsObject:SetMass(20)
    end
    
    self.PhysgunDisabled = self.m_PlayerCreator == nil
    
	if SERVER then
		self:SetUseType(SIMPLE_USE)

        local IsRare = self.m_PlayerCreator == nil and math.random() > 0.95
        self:SetTextRare(IsRare)
        
        local Pool = IsRare and TabletTextRare or TabletText
        
        self:SetTextID(math.random(1, #Pool))
	end
end

function ENT:Use(Activator, Caller)
    if not IsValid(Activator) then return end
    if not Activator:IsPlayer() then return end

    Activator:PickupObject(self)
end

if CLIENT then
	local TabletMaterial = Material("woowz_map/gm_garrymod_map_by_woowz_map_garry_game/model/tablet")
	
	local LerpAlpha = 0 
	local CurrentText = ""
    local DisplayColor = Color(0, 255, 0)
    local TextID = -1

    surface.CreateFont("GMM_TabletFont", {
		font = "Arial",
		size = 22,
		weight = 800,
		extended = true,
	})

	hook.Add("HUDPaint", "GMM_Tablet_GUI", function()
		local localPlayer = LocalPlayer()
		if not IsValid(localPlayer) then return end
		local Trace = localPlayer:GetEyeTrace()
		local TEntity = Trace.Entity
		
		local IsTargeting = IsValid(TEntity) and TEntity.GetTextID and Trace.HitPos:Distance(Trace.StartPos) < 200
        
		if IsTargeting then
            local IsRare = TEntity:GetTextRare()
			TextID = TEntity:GetTextID()
            local Pool = IsRare and TabletTextRare or TabletText
			CurrentText = Pool[TextID] or "[INVALID TEXT ID (" .. TextID .. " | " .. IsRare .. ")]"
			LerpAlpha = Lerp(FrameTime() * 10, LerpAlpha, 1)

            if IsRare then
                DisplayColor = Color(255, 0, 0)
            else
                DisplayColor = Color(0, 255, 0)
            end
		else
			LerpAlpha = Lerp(FrameTime() * 10, LerpAlpha, 0)
		end

		if LerpAlpha > 0.001 then
			local SW, SH = ScrW(), ScrH()
			local BoxW = 400
			local Padding = 20
			
			surface.SetFont("GMM_TabletFont")
			local Margin = 25
			local TextW = BoxW - Margin * 2
			
			local Words = string.Explode(" ", CurrentText)
			local Lines = {}
			local CurrentLine = ""
			for _, Word in ipairs(Words) do
				local TestLine = CurrentLine == "" and Word or CurrentLine .. " " .. Word
				local W, _ = surface.GetTextSize(TestLine)
				if W > TextW then
					table.insert(Lines, CurrentLine)
					CurrentLine = Word
				else
					CurrentLine = TestLine
				end
			end
			table.insert(Lines, CurrentLine)

			local LineHeight = 24
			local BoxH = 60 + (#Lines * LineHeight)
			local X = SW - (BoxW + Padding) * LerpAlpha
			local Y = SH / 2 - (BoxH / 2)
            
            local FinalColor = Color(DisplayColor.r, DisplayColor.g, DisplayColor.b, 255 * LerpAlpha)
            
			draw.RoundedBox(0, X, Y, BoxW, BoxH, Color(0, 0, 0, 230 * LerpAlpha))
			draw.RoundedBox(0, X, Y, 5, BoxH, FinalColor)
			draw.SimpleText(TextID .. ":", "GMM_TabletFont", X + Margin, Y + 15, FinalColor)
			for i, Txt in ipairs(Lines) do
				draw.SimpleText(Txt, "GMM_TabletFont", X + Margin, Y + 45 + (i-1) * LineHeight, Color(255, 255, 255, 255 * LerpAlpha))
			end
		end
	end)

	function ENT:Draw()
		self:DrawModel()

		local Tint = Vector(0, 1, 0)
		if self.GetTextRare and self.GetTextRare() then
			Tint = Vector(1, 0, 0)
		end

		TabletMaterial:SetVector("$selfillumtint", Tint)

		local Pos = self:GetPos() + self:GetUp() * 1.6
		local Size = 23.8 

		render.SetMaterial(TabletMaterial)
		render.DrawQuadEasy(Pos, self:GetUp(), Size, Size, Color(255, 255, 255), self:GetAngles().y)
	end
end