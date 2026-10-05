ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "DOWNLOAD MAP"
ENT.Author = "Woowz11"
ENT.Spawnable = (GMM and GMM["Valid"]) or game.GetMap() == "gmm_garrymod_map_by_woowz_help_me"
ENT.Category = "GMM"

local RandomPhrases = {
    "PLEASE, DOWNLOAD MAP",
    "MAP CONTENT MISSING!",
    "DOWNLOAD GMM ADDONS",
    "ERROR: ASSETS NOT FOUND",
    "CHECK STEAM WORKSHOP",
    "GMM SYSTEM FAILURE",
    "INSTALL MAP ASSETS",
    "WARNING: MISSING CONTENT",
    "SHAME! DOWNLOAD THE CONTENT",
    "DOWNLOAD CONTENT NOW!",
    "ATTENTION! YOU ARE WITHOUT GMM!",
    "WHERE IS GMM?",
    "DOWNLOAD GMM!",
    "USE GMM NOOB!",
    "CLICK HERE TO DOWNLOAD!",
    "COLLIDE AND DOWNLOAD",
    "HIT AND DOWNLOAD",
    "DOWNLOAD! DOWNLOAD! DOWNLOAD!",
    "HERE FREE GMM!",
    "GET GMM!",
    "TAKE GMM!",
    "GMM FREE ONLY HERE!",
    "GMM IN {U} UNIT FROM YOU",
    "FATAL ERROR: GMM_NOT_FOUND",
    "CORE ASSETS: 0%",
    "ENJOY YOUR PINK BOXES",
    "RUNNING WON'T INSTALL CONTENT",
    "I AM THE ERROR YOU CREATED",
    "GMM DELIVERY IN {U} UNITS",
    "DISTANCE TO SALVATION: {U}",
    "YOUR CONSOLE IS SCREAMING",
    "STOP THE LAG, START THE DOWNLOAD",
    "GMM > YOUR FPS",
    "GMM.gma IS CALLING YOU",
    "LOOK AT ME, I AM THE MAP NOW",
    "SYSTEM BLEEDING RED ERRORS",
	"https://steamcommunity.com/sharedfiles/filedetails/?id=3813588732"
}

local RandomPhrasesRare = {
    "DOWNLOAD MAP BITCH!",
    "DOWNLOAD MY MAP! RIGHT NOW!",
    "WHERE MY MAP STUPID?!",
    "I'LL CATCH YOU UP AND YOU'LL DOWNLOAD MY MAP",
    "YOU CAN'T ESCAPE FROM ME",
    "YOU HAVE NO CHOICE",
    "ACCEPT YOUR FATE",
    "YOU ARE ALREADY DOWNLOADING GMM!",
    "I'M FASTER",
    "GMM OR DEATH"
}

local RandomPhrasesSuperRare = {
    "СКАЧАЙ КАРТУ", "Я В СИСТЕМЕ ЗА ТЕБЯ КАРТУ СКАЧАЮ",
    "Я УЖЕ КАЧАЮ", "КАРТА СКАЧИВАЕТСЯ", "Я ЖДУ...",
    "ТЫ ЗНАЕШЬ ЧТО ДЕЛАТЬ", "СКАЧАЙ МОЮ КАРТУ", "GMM УЖЕ УСТАНАВЛИВАЕТСЯ",
    "КАРТА GMM ТВОЯ САМАЯ ЛЮБИМАЯ"
}

local RandomPhrasesGMM = {
    "THANKS FOR DOWNLOADING!",
    "CONGRATULATIONS!",
    "KEEP IT UP!",
    "THANKS!",
    "I'M HAPPY FOR YOU!",
    "YOU'RE WELCOME!"
}

local RandomPhrasesSuperRareGMM = {
    "СПАСИБО ЧТО СКАЧАЛ!",
    "ЧТОБЫ Я БЕЗ ТЕБЯ ДЕЛАЛ!",
    "ПОЗДРАВЛЯЮ!",
    "ТАК ДЕРЖАТЬ!",
    "ПО ДРУГОМУ НИКАК БЫЛО!",
    "НАКОНЕЦ-ТО!"
}

local RandomThanksSounds = {
    "vo/npc/male01/excuseme01.wav",
    "vo/npc/male01/excuseme02.wav",
    "vo/npc/male01/fantastic01.wav",
    "vo/npc/male01/finally.wav",
    "vo/npc/male01/sorry01.wav",
    "vo/npc/male01/sorry02.wav",
    "vo/npc/male01/sorry03.wav",
    "vo/npc/male01/yeah02.wav",
    "vo/npc/male01/whoops01.wav",
    "vo/npc/male01/yougotit02.wav"
}

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "DisplayText")
    self:NetworkVar("Int", 0, "Rarity")
    self:NetworkVar("Bool", 0, "GMM")
end

GMM_ActiveErrors = GMM_ActiveErrors or {}

if SERVER then
	AddCSLuaFile()

	util.AddNetworkString("GMM_OpenMapLink")
    util.AddNetworkString("GMM_HappyEffect")

	function ENT:UpdateTransmitState() return TRANSMIT_ALWAYS end
    
	function ENT:Initialize()
		self:SetModel("models/hunter/blocks/cube025x025x025.mdl") 
		self:SetMoveType(MOVETYPE_NOCLIP)
		self:SetSolid(SOLID_NONE)
		self:SetNoDraw(true)
        
		table.insert(GMM_ActiveErrors, self)
		
		if self:GetDisplayText() == "" then
            local HasGMM = GMM ~= nil
            if math.random() > 0.99 then HasGMM = false end
            self:SetGMM(HasGMM)
            
            local Roll = math.random(1, 10000)
            if Roll == 1 then
                self:SetRarity(2)
                self:SetDisplayText(table.Random(HasGMM and RandomPhrasesSuperRareGMM or RandomPhrasesSuperRare))
            elseif Roll <= 100 then
                self:SetRarity(1)
                self:SetDisplayText(table.Random(HasGMM and RandomPhrasesGMM or RandomPhrasesRare))
            else
                self:SetRarity(0)
                self:SetDisplayText(table.Random(HasGMM and RandomPhrasesGMM or RandomPhrases))
            end
		end
        
        if GMM and not GMM["Valid"] then
            self:SetDisplayText("T H A T   N O T   G M M")
        end

		self.Velocity = Vector(0, 0, 0)
        self.NextAttack = 0
        self.NextTargetFind = 0
        self.NextPhysTouch = 0
        self.TargetPly = nil
        self.Seed = self:EntIndex() * 45 
        self.OrbitOffsetZ = math.random(30, 80)
	end

	function ENT:OnRemove()
		for k, v in ipairs(GMM_ActiveErrors) do
			if v == self then
				table.remove(GMM_ActiveErrors, k)
				break
			end
		end
    end

	function ENT:Think()
        local AnywayWork = not GMM
        
        if not AnywayWork and GetConVar("ai_disabled"):GetBool() then
            self:NextThink(CurTime() + 1)
            return true
        end

        local IgnorePlayers = GetConVar("ai_ignoreplayers"):GetBool()

		local T = CurTime()
        local CurrentPos = self:GetPos()

        if AnywayWork or not IgnorePlayers then
            if (self.NextTargetFind < T) then
				self.NextTargetFind = T + 0.5
				local ClosestDist = 1000000
				self.TargetPly = nil
				for _, ply in ipairs(player.GetAll()) do
					if ply:Alive() and ply:GetObserverMode() == OBS_MODE_NONE then
						local d2 = CurrentPos:DistToSqr(ply:GetPos())
						if d2 < ClosestDist then
							ClosestDist = d2
							self.TargetPly = ply
						end
					end
				end
			end
        end

		if IsValid(self.TargetPly) then
			local CurrentPosition = self:GetPos()
			local PlayerPosition = self.TargetPly:GetPos() + Vector(0, 0, 50)
			local DistanceToPlayer = CurrentPosition:Distance(PlayerPosition)

			local TargetPosition
			
			if DistanceToPlayer > 250 then
				local Time = CurTime() * 0.5
				local OrbitRadius = 150
				local OX = math.sin(Time + self.Seed) * OrbitRadius
				local OY = math.cos(Time + self.Seed) * OrbitRadius
				TargetPosition = self.TargetPly:GetPos() + Vector(OX, OY, self.OrbitOffsetZ)
			else
				TargetPosition = PlayerPosition
			end
			
			local Direction = (TargetPosition - CurrentPosition):GetNormalized()

			if IsValid(self.TargetPly) then
				local PlayerPos = self.TargetPly:GetPos() + Vector(0, 0, 50)
				local Dist = CurrentPos:Distance(PlayerPos)

				local TargetPos
				if Dist > 250 then
					local ox = math.sin(T * 0.5 + self.Seed) * 150
					local oy = math.cos(T * 0.5 + self.Seed) * 150
					TargetPos = self.TargetPly:GetPos() + Vector(ox, oy, self.OrbitOffsetZ)
				else
					TargetPos = PlayerPos
				end
			
				local Direction = (TargetPos - CurrentPos):GetNormalized()
			
				local Separation = Vector(0,0,0)
                for _, other in ipairs(GMM_ActiveErrors) do
                    if other ~= self and IsValid(other) then
                        local oPos = other:GetPos()
                        local diff = CurrentPos - oPos
                        local d2 = diff:LengthSqr()
                        if d2 < 3600 then
                            Separation = Separation + (diff / d2) * 10
                        end
                    end
                end

                local Rarity = self:GetRarity()
                local AccelRate = 0.05
                local MaxSpeed = 80

                if Rarity == 1 then
                    AccelRate, MaxSpeed = 0.25, 350
                elseif Rarity == 2 then
                    AccelRate, MaxSpeed = 1, 1000
                end
				
				self.Velocity = self.Velocity + (Direction * AccelRate) + (Separation * 0.1)
				self.Velocity = self.Velocity * 0.96
				
				if self.Velocity:Length() > MaxSpeed then
					self.Velocity = self.Velocity:GetNormalized() * MaxSpeed
				end
				
				self:SetPos(CurrentPosition + self.Velocity)

				if Dist < 35 and self.NextAttack < T then
					self:CatchPlayer(self.TargetPly)
					self.NextAttack = T + 2
				end

                if self.NextPhysTouch < T then
                    self.NextPhysTouch = T + 0.2
                    for _, ent in ipairs(ents.FindInSphere(CurrentPos, 45)) do
                        if IsValid(ent) and ent:GetClass() == "prop_physics" then
                            local Phys = ent:GetPhysicsObject()
                            if IsValid(Phys) then Phys:ApplyForceCenter(self.Velocity * 50) end
                        end
                    end
                end
			end
		end

		self:NextThink(T + 0.02)
		return true
	end

	function ENT:CatchPlayer(ply)
        local HasGMM = self:GetGMM()
        local Rarity = self:GetRarity()

        if GMM and not GMM["Valid"] then
            ply:EmitSound("music/hl2_song23_suitsong3.mp3", 100)
            ply:Kill()

            net.Start("GMM_HappyEffect")
            net.WriteVector(self:GetPos())
            net.Broadcast()
            
            self:Remove()
            
            return
        end
        
        if not HasGMM then

            if Rarity == 2 then
                ply:EmitSound("common/stuck2.wav", 100)
            else
                ply:EmitSound("vo/eli_lab/al_cavedin_b.wav", 80, math.random(70, 130))
            end

            if Rarity == 2 then
                ply:TakeDamage(10, self, self)
                ply:ScreenFade(SCREENFADE.IN, Color(255, 255, 255, 180), 1, 0)
            else
                ply:ScreenFade(SCREENFADE.IN, Color(Rarity == 0 and 0 or 255, 0, Rarity == 1 and 255 or 0, 100), 0.5, 0)
            end

            net.Start("GMM_OpenMapLink")
            net.Send(ply)
        else
            ply:EmitSound(table.Random(RandomThanksSounds), 100, math.random(90, 110))
            ply:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 180), 0.25, 0)
        end

        util.ScreenShake(ply:GetPos(), 10, 5, 0.8, 500)
        ply:ViewPunch(Angle(math.random(-25, 25), math.random(-25, 25), 0))

        if HasGMM then
            ply:SetHealth(ply:Health() + 10)
            
            net.Start("GMM_HappyEffect")
            net.WriteVector(self:GetPos())
            net.Broadcast()
            
            self:Remove()
        else
            local RandomDir = VectorRand()
            RandomDir.z = 0.1
            RandomDir:Normalize()

            local RandomDist = math.random(3000, 10000)
            local NewPos = ply:GetPos() + (RandomDir * RandomDist) + Vector(0, 0, 100)

            self:SetPos(NewPos)
            self.Velocity = Vector(0, 0, 0)
        end
	end
end

if CLIENT then
	local GMM_HUD = {}

	surface.CreateFont("GMM_WorldFontFixed", { font = "Arial", size = 50,weight = 900, extended = true, outline = true,antialias = true })
	surface.CreateFont("GMM_ErrorFont", { font = "Tahoma", size = 16, weight = 800 })
	surface.CreateFont("GMM_ErrorFontSmall", { font = "Tahoma", size = 14, weight = 400 })

	function ENT:Initialize()
		self:SetRenderBounds(Vector(-16384, -16384, -16384), Vector(16384, 16384, 16384))
	end

	net.Receive("GMM_OpenMapLink", function()
		local W, H = 260, 80
		table.insert(GMM_HUD, {
			x = math.random(50, ScrW() - W - 50),
			y = math.random(50, ScrH() - H - 50),
			w = W,
			h = H,
			dieTime = CurTime() + 30
		})
	end)

    net.Receive("GMM_HappyEffect", function()
        local Pos = net.ReadVector()
        local Emitter = ParticleEmitter(Pos)
        for i = 1, 200 do
            local Part = Emitter:Add("effects/energysplash", Pos)
            if Part then
                Part:SetVelocity(VectorRand() * 300 + Vector(0, 0, 200))
                Part:SetDieTime(math.Rand(10, 20))
                Part:SetStartAlpha(255)
                Part:SetEndAlpha(0)
                Part:SetStartSize(math.Rand(2, 3))
                Part:SetEndSize(0)
                Part:SetGravity(Vector(0, 0, -200))
                Part:SetAirResistance(100)
                Part:SetColor(math.random(100, 255), math.random(100, 255), math.random(100, 255))
                Part:SetCollide(true)
                Part:SetBounce(0.5)
                Part:SetRoll(math.Rand(0, 360))
                Part:SetRollDelta(math.Rand(-20, 20))
            end
        end
        Emitter:Finish()
    end)
    
	local NextCache = 0
    local CachedEnts = {}
    local RenderMat = Matrix()
	
	hook.Add("DrawOverlay", "GMM_RenderDownloadMapText", function()
		local T = CurTime()
	
		if NextCache < T then
            CachedEnts = ents.FindByClass("gmm_download_map")
            NextCache = T + 0.2
        end
	
		local LPlayer = LocalPlayer()
		if not IsValid(LPlayer) then return end
		
		local EyePos = LPlayer:EyePos()
        local EyeAngles = LPlayer:EyeAngles()
        local FOV = LPlayer:GetFOV()

		for i = 1, #CachedEnts do
			local Ent = CachedEnts[i]
			if not IsValid(Ent) then continue end
		
			if not Ent.PixVis then Ent.PixVis = util.GetPixelVisibleHandle() end

			local Pos = Ent:GetPos() + Vector(0,0,15)

			local toEnt = (Pos - EyePos):GetNormalized()
            if EyeAngles:Forward():Dot(toEnt) < 0.2 then continue end
			
            local DistSqr = Pos:DistToSqr(EyePos)
            if DistSqr > 4000000 then continue end

            local ScreenData = Pos:ToScreen()
            if not ScreenData.visible then continue end
			
            local Dist = math.sqrt(DistSqr)
            local BaseAlpha = math.Clamp(255 * (1 - (Dist - 400) / 1600), 0, 255)
			
			if BaseAlpha <= 0 and not ScreenData.visible then continue end
			
			local Text = Ent:GetDisplayText() or "HELP ME"
			if string.find(Text, "{U}") then
				Text = string.gsub(Text, "{U}", tostring(math.Round(Dist)))
			end
			
			local Visibility = util.PixelVisible(Pos, 10, Ent.PixVis)
			local WallMultiplier = (Visibility < 0.1) and 0.2 or 1
			local Alpha = BaseAlpha * WallMultiplier

			local CurrentFOV = LPlayer:GetFOV()
			local FOVMultiplier = 75 / CurrentFOV 
			
			local Scale = (150 / Dist) * FOVMultiplier
			
			surface.SetFont("GMM_WorldFontFixed")
			local TW, TH = surface.GetTextSize(Text)
			
			local TX, TY = ScreenData.x, ScreenData.y
			local Wave = math.abs(math.sin(CurTime() * 8)) * 255

			local HasGMM = Ent:GetGMM()
			local Rarity = Ent:GetRarity()
			local MainColor = HasGMM and Color(0, 255, Wave, Alpha) or Color(255, Wave, 0, Alpha)

			if Rarity == 1 then
				MainColor = Color(0, Wave, 255, Alpha)
			elseif Rarity == 2 then
				local hue = (CurTime() * 2000) % 360
				MainColor = HSVToColor(hue, 0.7, 1)

				Scale = Scale * 4
			end

			if GMM and not GMM["Valid"] then
				MainColor = Color(Wave, Wave, 0, Alpha)
			end
			
			RenderMat:Identity()
			RenderMat:Translate(Vector(TX, TY, 0))
			RenderMat:Scale(Vector(Scale, Scale, 1))
			
			cam.PushModelMatrix(RenderMat)
				surface.SetTextColor(0, 0, 0, Alpha * 0.7)
				surface.SetTextPos(-TW / 2 + 5, -TH / 2 + 5)
				surface.DrawText(Text)

				surface.SetTextColor(MainColor.r, MainColor.g, MainColor.b, Alpha)
				surface.SetTextPos(-TW / 2, -TH / 2)
				surface.DrawText(Text)
			cam.PopModelMatrix()
		end
	end)

	hook.Add("HUDPaint", "GMM_RenderDownloadMapText_Warns", function()
		for i = #GMM_HUD, 1, -1 do
			local Panel = GMM_HUD[i]
			if CurTime() > Panel.dieTime then table.remove(GMM_HUD, i) continue end
			
			local X, Y, W, H = Panel.x, Panel.y, Panel.w, Panel.h
			draw.RoundedBox(0, X, Y, W, H, Color(200, 200, 200))
			surface.SetDrawColor(0, 0, 0)
			surface.DrawOutlinedRect(X, Y, W, H)
			draw.RoundedBox(0, X + 2, Y + 2, W - 4, 18, Color(128, 0, 0))
			draw.SimpleText("GMM Error", "GMM_ErrorFont", X + 5, Y + 3, Color(255, 255, 255))
			draw.SimpleText("GMM MISSING!", "GMM_ErrorFont", X + W /2, Y + 35, Color(0, 0, 0), TEXT_ALIGN_CENTER)
			draw.SimpleText("Press [ENTER] to fix this", "GMM_ErrorFontSmall", X + W /2, Y + 55, Color(255, 0, 0), TEXT_ALIGN_CENTER)
		end
	end)

	hook.Add("Think", "GMM_EnterDetector", function()
		if #GMM_HUD > 0 then
			if input.IsKeyDown(KEY_ENTER) then
				gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=3813588732")
				GMM_HUD = {}
				
				notification.AddProgress("GMM_NotifyMapDownloadPlease", "DOWNLOADING MY GMM CONTENT... PLEASE WAIT...")
				timer.Simple(10, function() notification.Kill("GMM_NotifyMapDownloadPlease") end)
			end
		end
	end)
end