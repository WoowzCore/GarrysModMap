if GMM["Valid"] then
	print("[GMM] BOOTSTRAP STARTED... (CLIENT)")
end

GMM_C = {
	["Debug"] = nil
}

list.Set("ContentCategoryIcons", "GMM", "icons16/gmm_category")--"icons16/gmm_category" .. math.random(0, 7) .. ".png")

hook.Add("InitPostEntity", "gmm_PlayerLoad", function()
	if GMM["Valid"] then
		-- Загрузка клиента
		print("[GMM] CLIENT LOADED")
	end
	
	GMM_C["Debug"] = (true and (LocalPlayer():SteamID() == Woowz11)) or GMM["CustomDebug"]
	if GMM_C["Debug"] then print("[GMM] DEBUG VERSION") end
	
	-- ----------------------------------------------------------------------
	
	local CameraPosition = Vector(0, 0, 0)
	
	local Player = nil
	
	-- ----------------------------------------------------------------------
	
	local ServerData = {}
	timer.Create("gmm_GetServerData", 0.1, 0, function()
		net.Start("gmm_Get_ServerData")
		net.SendToServer()
	end)
	
	net.Receive("gmm_Send_ServerData", function()
		ServerData = net.ReadTable()
	end)
	
	-- ----------------------------------------------------------------------
	
	if GMM["Valid"] and GMM_C["Debug"] then
		hook.Add("HUDPaint", "gmm_InterfaceDrawCoordinates", function()
			local Position = EyePos()
			local Angle    = EyeAngles()
			
			local Trace = util.TraceLine({
				start  = Position,
				endpos = Position + Angle:Forward() * 32768,
				filter = LocalPlayer(),
				mask   = MASK_SHOT
			})
			
			local HitPos    = Trace.HitPos
			local HitEntity = Trace.Entity
			
			local EntityName = "None"
			if IsValid(HitEntity) then
				EntityName = HitEntity:GetClass()
				if HitEntity:IsPlayer() then
					EntityName = "Player: " .. HitEntity:Nick()
				elseif HitEntity:GetModel() then
					EntityName = EntityName .. " (" .. HitEntity:GetModel() .. ")"
				end
			end
			
			local Text = string.format(
				"X: %.1f  Y: %.1f  Z: %.1f  |  Pitch: %.1f°  Yaw: %.1f°  Roll: %.1f°\n" ..
				"Hit: X: %.1f  Y: %.1f  Z: %.1f | Dist.: %.1f | HitEnt.: %s",
				Position.x, Position.y, Position.z,
				Angle.pitch, Angle.yaw, Angle.roll,
				HitPos.x, HitPos.y, HitPos.z,
				Position:Distance(HitPos),
				EntityName
			)
			
			surface.SetFont("DermaDefaultBold")
			local TextW, TextH = surface.GetTextSize(Text)
			
			local Padding = 10
			local RectX = ScrW() / 2 - TextW / 2 - Padding
			local RectY = 10 - Padding
			local RectW = TextW + Padding * 2
			local RectH = TextH + Padding * 2
			
			draw.RoundedBox(
				8,
				RectX, RectY,
				RectW, RectH,
				Color(0, 0, 0, 180)
			)
			
			local Lines = string.Explode("\n", Text)
			for i, Line in ipairs(Lines) do
				draw.SimpleText(
					Line,
					"DermaDefaultBold",
					ScrW() / 2, RectY + Padding + (i - 1) * (TextH / #Lines),
					Color(255, 255, 255, 255),
					TEXT_ALIGN_CENTER,
					TEXT_ALIGN_TOP
				)
			end
		end)
	end
	
	hook.Add("RenderScreenspaceEffects", "gmm_WaterOverlay", function()
		if not GMM["Valid"] then return end
	
		local Contents = util.PointContents(CameraPosition)
		
		local InWater = bit.band(Contents, CONTENTS_WATER) ~= 0
		local InSlime = bit.band(Contents, CONTENTS_SLIME) ~= 0
		
        if InWater or InSlime then
            DrawMaterialOverlay(InSlime and "woowz_map/gm_garrymod_map_by_woowz_map_garry_game/water_warp_slime" or "woowz_map/gm_garrymod_map_by_woowz_map_garry_game/water_warp", 0.05)
        end
    end)
	
	-- ----------------------------------------------------------------------
	
	local RainEmitter = nil
	local function SpawnRainDrop(Position, Color, Angle__, Power)
		if not RainEmitter then RainEmitter = ParticleEmitter(Position, false) end
		
		Power = Power or 1
		
		local RainTexture = "woowz_map/gm_garrymod_map_by_woowz_map_garry_game/rain"
		local Part = RainEmitter:Add(RainTexture, Position)
		if Part then
			local Gravity = Vector(0, 0, -500)
			local BaseVelocity = Vector(math.random(-10, 10), math.random(-10, 10), -1000) * Power
		
		    if Angle__ then
				BaseVelocity = Angle__:Forward() * Power
			end
			
			local Speed = BaseVelocity:Length()
		
			Part:SetVelocity(BaseVelocity)
			Part:SetDieTime(2)
			Part:SetStartAlpha(255)
			Part:SetEndAlpha(0)
			Part:SetStartSize(0.5)
			Part:SetEndSize(0.5)
			
			local DropLength = math.Clamp(Speed * 0.03, 5, 300)
			Part:SetStartLength(DropLength)
			Part:SetEndLength(DropLength * 0.33)
			
			Part:SetColor(255, 255, 255)
			Part:SetGravity(Gravity)
			
			Part:SetCollide(false) 
			
			Part.LastPos = Position

			Part:SetNextThink(CurTime()) 
			Part:SetThinkFunction(function(P)
				if not P then return end
				local CurrentPos = P:GetPos()
				
				local R, G, B
				if Color then
					R = Color.x
					G = Color.y
					B = Color.z
				else
					local Light = render.ComputeLighting(CurrentPos, Vector(0, 0, 1))
					R = Light.x
					G = Light.y
					B = Light.z
				end
				R = math.min(R * 255, 255)
				G = math.min(G * 255, 255)
				B = math.min(B * 255, 255)
				P:SetColor(R, G, B)
				
				local Trace = util.TraceLine({
					start = P.LastPos,
					endpos = CurrentPos,
					mask = bit.bor(MASK_SOLID, CONTENTS_WATER, CONTENTS_SLIME, CONTENTS_TRANSLUCENT)
				})

				if Trace.Hit or Trace.HitWater then
					local HitPos = Trace.HitPos
					
					for i = 1, 3 do
						local splash = RainEmitter:Add(RainTexture, HitPos)
						if splash then
							splash:SetVelocity(Trace.HitNormal * 10 + VectorRand() * 50)
							splash:SetDieTime(math.Rand(0.3, 0.6))
							splash:SetStartAlpha(50)
							splash:SetEndAlpha(0)
							splash:SetStartSize(math.Rand(1, 3))
							splash:SetEndSize(0)
							splash:SetColor(R, G, B)
							splash:SetGravity(Vector(0, 0, -200))
						end
					end

					P:SetDieTime(0)
					return
				end
				
				P.LastPos = CurrentPos
				P:SetNextThink(CurTime())
			end)
		end
	end
	
	-- ----------------------------------------------------------------------
	
	local TimerSecondInterval = 0.05
	
	local __AmbientSounds = {}
    local __Particles = {}
	local __Zones = {}
	
	game.AddParticles("particles/insect_fx.pcf")
	local CreateEnvironment = function()
		for i = #__AmbientSounds, 1, -1 do
			local SoundData = __AmbientSounds[i]
			local Channel = SoundData[1]
			if IsValid(Channel) then
				Channel:Stop()
			end
			table.remove(__AmbientSounds, i)
		end
		
		__AmbientSounds = {}
        __Particles = {}
		__Zones = {}
        
		local CreateAmbient = function(SoundFile, Position, IDistance, ADistance, Volume, Delay, Speed)
			SoundFile = "sound/" .. SoundFile
		
			Volume    = Volume    or 1
			IDistance = IDistance or 100
			ADistance = ADistance or 1500
			Delay     = Delay     or 0
			Speed     = Speed     or 1
			
			sound.PlayFile(SoundFile, "noplay", function(Channel, eID, e)
				if e then error("[GMM] [ERROR]: FAILED PlayFile AMBIENT SOUND [" .. SoundFile .. "]:", eID, e) return end
				if not IsValid(Channel) then error("[GMM] [ERROR]: FAILED PlayFile AMBIENT SOUND [" .. SoundFile .. "]: Channel is not valid!") return end
				
				Channel:SetPlaybackRate(Speed)
				
				table.insert(__AmbientSounds, {Channel, Position, Volume, IDistance, ADistance, Delay, Speed, SoundFile})
			end)
		end
        
        local CreatePartical = function(Partical, Position, Delay, Angle__, Power)
			Delay = Delay or 0
			Angle__ = Angle__ or Angle(0, 0, 0)
			Power = Power or 0
			
            local RunFunc = nil

            if Partical == "Bubbles" then
                RunFunc = function()
                    effects.Bubbles(Position, Position, 1, 200)
                end
            end
			if Partical == "Fly" then
                RunFunc = function()
                    PrecacheParticleSystem("fly_child")
					ParticleEffect("fly_child", Position, Angle(0, 0, 0))
                end
            end
			if Partical == "Cockroach" then
                RunFunc = function()
                    PrecacheParticleSystem("roach_fx_4")
					ParticleEffect("roach_fx_4", Position, Angle(0, 0, 0))
                end
            end
			if Partical == "Droplet" then
                RunFunc = function()
					local FinalAngle = Angle__
					if type(Angle__) == "function" then
						FinalAngle = Angle__()
					end
				
					SpawnRainDrop(Position, nil, FinalAngle, Power)
                end
            end
            
            table.insert(__Particles, {Partical, Position, Delay, RunFunc, Angle__, Power})
        end
		
		local CreateZone = function(Type, Point1, Point2, Color, Density)
			Point1.z = Point1.z - 2
			Point2.z = Point2.z - 2
		
			Density = Density or 5
		
			table.insert(__Zones, {Type, Point1, Point2, Density, Color})
		end
		
		-- ----------------------------------------------------------------------

        if GMM["MyMap_Default"] or GMM["MyMap_Flood"] or GMM["MyMap_Old"] then
			CreateAmbient("woowz/music/greetings.wav", Vector(392, 488, 1328), 10, 500, 50, nil, 0.9)
			CreateAmbient("woowz/music/concrete_halls.wav", 1, 10, 300, 20)
			CreateAmbient("music/hl1_song25_remix3.mp3", Vector(-2419, 589, 610), 10, 100, 50)
			CreateAmbient("friends/friend_online.wav", Vector(-355, 175, 302), 10, 200, 10, nil, 0.1)
			CreateAmbient("buttons/blip2.wav", 0, 100, 200, 1, 1)
			CreateAmbient("ambient/wind/wind_rooftop1.wav", Vector(1405, 473, 2489), 100, 1000)
			CreateAmbient("ambient/atmosphere/inside_lighthouse_amb.wav", Vector(-488, -667, 2546), 100, 2000)
        end
		
		if GMM["MyMap_Default"] or GMM["MyMap_Flood"] then
			CreateZone("Rain", Vector(-44, -983, 4049), Vector(-629, -275, 2061), Vector(0.5, 0.5, 0.5), 1)
			CreateAmbient("ambient/machines/combine_shield_touch_loop1.wav", Vector(-565, -643, 512), 100, 500)
			CreateAmbient("ambient/alarms/razortrain_horn1.wav", Vector(0, 0, 0), 100, 500, nil, nil, 2)
			CreateAmbient("ambient/machines/engine4.wav", Vector(-1527, 508, 1401), 250, 750, 2)
		end
        
		if GMM["MyMap_Default"] or GMM["MyMap_Old"] then
			CreateAmbient("ambient/forest_night.wav", Vector(1400, 491, 637), 100, 750)
			CreateAmbient("ambient/gas/steam_loop1.wav", Vector(1364, 747, -1984), 100, 500)
			CreateAmbient("ambient/wind/wind_bass.wav", Vector(1084, 1786, 640), 500, 2500, 0.75)
			CreateAmbient("ambient/guit1.wav", Vector(456, -589, 519), 100, 500)
		end
		
		if GMM["MyMap_Default"] then
			CreateAmbient("ambient/water/corridor_water.wav", Vector(1415, 723, -3854), 100, 2000)
			CreateAmbient("ambient/machines/train_wheels_overhead_loop1.wav", Vector(2444, 647, 96), 10, 200, 0.5)
			CreateAmbient("vo/npc/male01/yeah02.wav", 2, 10, 50, 200, nil, 2)
			CreateAmbient("ambient/creatures/town_moan1.wav", Vector(-1264, -389, 579), 10, 100, 1)
			CreateAmbient("ambient/forest_day.wav", Vector(-2354, -624, 656), 200, 1000)
		end

		if GMM["MyMap_Old"] then
			CreateAmbient("ambient/gas/steam_loop1.wav", Vector(1415, 723, -3854), 100, 2000)
			CreateAmbient("vo/npc/male01/yeah02.wav", 2, 10, 50, 200, nil, 4)
		end

        if GMM["MyMap_Flood"] then
            CreatePartical("Bubbles", Vector(648, 1135, 16), 0.1)
            CreatePartical("Bubbles", Vector(1352, 176, 240), 1)
			CreatePartical("Bubbles", Vector(2434, 641, 32), 1.2)
			CreatePartical("Bubbles", Vector(2443, 646, 32), 2.1)
			CreatePartical("Bubbles", Vector(2450, 636, 32), 2.3)
			CreateAmbient("vo/npc/male01/yeah02.wav", 2, 50, 200, 200, nil, 0.75)
			CreateAmbient("ambient/weather/rumble_rain_nowind.wav", Vector(-231, 1546, 9331), 100, 1500)
			CreateAmbient("ambient/weather/rumble_rain_nowind.wav", Vector(-245, 1553, 1181), 100, 500)
			CreateAmbient("ambient/water/lake_water.wav", Vector(1377, 544, 1095), 1000, 1500)
			CreateZone("Rain", Vector(-495, 1616, 992), Vector(-16, 1488, 9231), Vector(0.25, 0.25, 0.25))
			CreateZone("Rain", Vector(1007, 1040, 9232), Vector(-972, 2031, 10203), nil, 15)
			CreateZone("Rain", Vector(-8, 888, 3064), Vector(-352, 1463, 2615), Vector(0.5, 0.5, 0.5))
			CreateZone("Rain", Vector(-503, 1024, 3064), Vector(-384, 1376, 2579), Vector(0.25, 0.25, 0.25))
			CreateAmbient("ambient/weather/rumble_rain_nowind.wav", Vector(-357, 1182, 2679), 100, 500)
			CreateAmbient("ambient/outro/messagepacketsmultiple02.wav", Vector(-1511, 437, 445), 100, 500)
			CreateZone("Rain", Vector(-579, -558, 1200), Vector(-548, -593, 1189), Vector(0.5, 0.5, 0.5), 5)
			CreateZone("Rain", Vector(-451, -738, 1168), Vector(-422, -768, 1149), Vector(0.5, 0.5, 0.5), 5)
			CreateAmbient("ambient/water/water_flow_loop1.wav", Vector(-518, -658, 1011), 50, 350)
			CreateAmbient("ambient/water/drip_loop1.wav", Vector(-488, -667, 2546), 100, 2500)
        end
		
		if GMM["MyMap_Real"] then
			CreatePartical("Cockroach", Vector(322, 212, 432), 240)
			for i = 1, 3 do
				CreatePartical("Droplet", Vector(-969, -306, 424 + 2), 0, function() return Angle(-90 + math.random(-30, 30), math.random(0, 360), 0) end, 300)
			end
			CreateAmbient("ambient/weather/rumble_rain_nowind.wav", Vector(-969, -306, 424 + 2), 50, 400)
			for i = 1, 3 do
				CreatePartical("Droplet", Vector(-969, -954, 424 + 2), 0, function() return Angle(-90 + math.random(-30, 30), math.random(0, 360), 0) end, 300)
			end
			CreateAmbient("ambient/weather/rumble_rain_nowind.wav", Vector(-969, -954, 424 + 2), 50, 400)
			for i = 1, 3 do
				CreatePartical("Droplet", Vector(-73, -954, 424 + 2), 0, function() return Angle(-90 + math.random(-30, 30), math.random(0, 360), 0) end, 300)
			end
			CreateAmbient("ambient/weather/rumble_rain_nowind.wav", Vector(-73, -954, 424 + 2), 50, 400)
			for i = 1, 3 do
				CreatePartical("Droplet", Vector(-73, -306, 424 + 2), 0, function() return Angle(-90 + math.random(-30, 30), math.random(0, 360), 0) end, 300)
			end
			CreateAmbient("ambient/weather/rumble_rain_nowind.wav", Vector(-73, -306, 424 + 2), 50, 400)
			CreateAmbient("ambient/wind/lightwind.wav", Vector(-465, -626, 1515), 200, 500)
		end
	end
    
	local UpdateEnvironment = function()
		local CurrentTime = RealTime()
	
		for i = #__AmbientSounds, 1, -1 do
			local SoundData = __AmbientSounds[i]
			
			local Channel   = SoundData[1 ]
			local Position  = SoundData[2 ]
			local Volume    = SoundData[3 ]
			local IDistance = SoundData[4 ]
			local ADistance = SoundData[5 ]
			local Delay     = SoundData[6 ]
			local Speed     = SoundData[7 ]
			local SoundFile = SoundData[8 ]
			local StartTime = SoundData[9 ]
			local Working   = SoundData[10]
			local Length    = Channel:GetLength()
			
			if Working == nil then Working = true end
			
			if StartTime == nil or (CurrentTime - StartTime > ((Length / Speed) + Delay)) then
				StartTime = CurrentTime
				Channel:Play()
				__AmbientSounds[i][9] = StartTime
			end
			
			if type(Position) == "number" then
				local Target = Position
				if ServerData["Positions"] then
					Position = ServerData["Positions"][Target]
					
					if Position ~= nil then
						if TypeID(Position) ~= TYPE_VECTOR then
							if Working then print("[GMM] [ERROR] FAILED SET TARGET TO SOUND [" .. SoundFile .. "]! TARGET [" .. Target .. "] IS NOT VECTOR!") end
							Working = false
							Position = ErrorPosition
						end
					else
						Position = ErrorPosition
					end
				else
					Position = ErrorPosition
				end
			end
			
			local Distance = CameraPosition:Distance(Position)
			
			local __Volume = 0
			if Distance <= IDistance then
				__Volume = 1
			elseif Distance >= ADistance then
				__Volume = 0
			else
				__Volume = 1 - ((Distance - IDistance) / (ADistance - IDistance))
			end
			
			__Volume = __Volume * Volume
			
			if not Working then __Volume = 0 end
			__AmbientSounds[i][10] = Working
			Channel:SetVolume(__Volume)
		end

        for i = #__Particles, 1, -1 do
            local ParticalData = __Particles[i]
            
            local Partical  = ParticalData[1]
            local Position  = ParticalData[2]
            local Delay     = ParticalData[3]
            local RunFunc   = ParticalData[4]
			local Angle__   = ParticalData[5]
			local Power     = ParticalData[6]
            local StartTime = ParticalData[7]

            if StartTime == nil or (CurrentTime - StartTime > Delay) then
                StartTime = CurrentTime
                RunFunc()
                __Particles[i][7] = StartTime
            end
        end
		
		for _, Zone in ipairs(__Zones) do
			local Type    = Zone[1]
			local P1      = Zone[2]
			local P2      = Zone[3]
			local Density = Zone[4]
			local Color   = Zone[5]
			
			local MinX, MaxX = math.min(P1.x, P2.x), math.max(P1.x, P2.x)
			local MinY, MaxY = math.min(P1.y, P2.y), math.max(P1.y, P2.y)
			local MinZ, MaxZ = math.min(P1.z, P2.z), math.max(P1.z, P2.z)
			
			local Center = (P1 + P2) / 2
			
			local IsNear = CameraPosition:DistToSqr(Center) < (2500*2500)
			local IsInside = (CameraPosition.x >= MinX and CameraPosition.x <= MaxX) and
							 (CameraPosition.y >= MinY and CameraPosition.y <= MaxY) and
							 (CameraPosition.z >= MinZ and CameraPosition.z <= MaxZ)
			
			if IsNear or IsInside then
				if Type == "Rain" then
					for i = 1, Density do
						SpawnRainDrop(Vector(math.random(MinX, MaxX), math.random(MinY, MaxY), math.max(math.min(CameraPosition.z + 1000, MaxZ), MinZ)), Color)
					end
				end
			end
		end
	end
	
	local PostCleanup = function()
		if GMM["Valid"] then
			print("[GMM] CLIENT CLEANUP")
		end
		
		CreateEnvironment()
	end
	hook.Add("PostCleanupMap", "gmm_PostCleanupMap_Client", PostCleanup)
	PostCleanup()

	-- ----------------------------------------------------------------------
	
	if GMM["Valid"] and GMM_C["Debug"] then
		hook.Add("PostDrawTranslucentRenderables", "gmm_DebugDraw", function()
			local CurrentTime = RealTime()
		
			local Developer = GetConVar("developer")
			if not Developer or Developer:GetInt() == 0 then return end
			
			for i = 1, #__AmbientSounds do
				local SoundData = __AmbientSounds[i]
				
				local Channel   = SoundData[1 ]
				local Position  = SoundData[2 ]
				local Volume    = SoundData[3 ]
				local IDistance = SoundData[4 ]
				local ADistance = SoundData[5 ]
				local Delay     = SoundData[6 ]
				local Speed     = SoundData[7 ]
				local SoundFile = SoundData[8 ]
				local StartTime = SoundData[9 ]
				local Working   = SoundData[10]
				local Length    = Channel:GetLength()
				
				if StartTime then
                    if type(Position) == "number" then
                        local Target = Position
                        if ServerData["Positions"] then
                            Position = ServerData["Positions"][Target]

                            if Position ~= nil then
                                if TypeID(Position) ~= TYPE_VECTOR then
                                    Position = ErrorPosition
                                end
                            else
                                Position = ErrorPosition
                            end
                        else
                            Position = ErrorPosition
                        end
                    end

                    local Progress = math.Clamp((CurrentTime - StartTime) / Length, 0, 1)
                    local Alpha = math.Clamp(Volume / 50, 0, 1)

                    local R, G, B = 0, 0, 0

                    if Speed <= 1 then
                        R = 255 * Speed
                        G = 0
                        B = 255 * (1 - Speed)
                    else
                        local T = math.Clamp((Speed - 1) / 5, 0, 1)
                        R = 255 * (1 - T)
                        G = 255 * T
                        B = 0
                    end

                    local Col = Color(
                            R,
                            G,
                            B,
                            255 * Alpha
                    )
                    if CurrentTime - StartTime > (Length / Speed) then
                        Col = Color(255, 255, 255, 255 * Alpha)
                    end

                    render.DrawWireframeSphere(Position, IDistance, 6 + 24 * Progress, 6 + 24 * Progress, Color(0, 255, 0, 255 * Alpha))
                    render.DrawWireframeSphere(Position, ADistance, 6 + 24 * Progress, 6 + 24 * Progress, Col)
                end
			end
		end)
	end

	-- ----------------------------------------------------------------------

	hook.Add("Think", "gmm_Think", function()
		Player = LocalPlayer()
	
		local View = render.GetViewSetup()
		if View and View.origin then
			CameraPosition = View.origin
		else
			CameraPosition = EyePos()
		end
	end)
	
	timer.Create("gmm_ThinkSecond", TimerSecondInterval, 0, function()
		UpdateEnvironment()
	
		if GMM["Valid"] then
			Player:SetDSP(3, true)
		end
		
		net.Start("gmm_ClientInfo")
			net.WriteTable({
				["Shift"] = input.IsKeyDown(KEY_LSHIFT) or input.IsKeyDown(KEY_RSHIFT),
				["Alt"  ] = input.IsKeyDown(KEY_LALT  ) or input.IsKeyDown(KEY_RALT  )
			})
		net.SendToServer()
	end)
end)