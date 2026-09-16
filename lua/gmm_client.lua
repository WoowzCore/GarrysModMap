print("[GMM] BOOTSTRAP STARTED... (CLIENT)")

GMM_C = {
	["Debug"] = nil
}

hook.Add("InitPostEntity", "gmm_PlayerLoad", function()
	-- Загрузка клиента
	print("[GMM] CLIENT LOADED")
	
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
	
	if GMM_C["Debug"] then
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
	
	-- ----------------------------------------------------------------------
	
	local TimerSecondInterval = 0.05
	
	local __AmbientSounds = {}
    local __Particles = {}
	
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
        
        local CreatePartical = function(Partical, Position, Delay)
            local RunFunc = nil

            if Partical == "Bubbles" then
                RunFunc = function()
                    effects.Bubbles(Position, Position, 1, 200)
                end
            end
            
            table.insert(__Particles, {Partical, Position, Delay, RunFunc})
        end
		
		-- ----------------------------------------------------------------------

        if GMM["MyMap_Default"] or GMM["MyMap_Flood"] then
            CreateAmbient("vo/npc/male01/yeah02.wav", 2, 10, 50, 200, nil, 2)
            CreateAmbient("woowz/music/greetings.wav", Vector(392, 488, 1328), 10, 500, 50, nil, 0.9)
            CreateAmbient("ambient/machines/engine4.wav", Vector(-1527, 508, 1401), 10, 500, 10)
            CreateAmbient("ambient/alarms/razortrain_horn1.wav", Vector(0, 0, 0), 100, 500, nil, nil, 2)
            CreateAmbient("woowz/music/concrete_halls.wav", 1, 10, 300, 20)
            CreateAmbient("music/hl1_song25_remix3.mp3", Vector(-2419, 589, 610), 10, 100, 50)
            CreateAmbient("friends/friend_online.wav", Vector(-355, 175, 302), 10, 200, 10, nil, 0.1)
            CreateAmbient("buttons/blip2.wav", 0, 100, 200, 1, 1)
            CreateAmbient("ambient/guit1.wav", Vector(456, -589, 519), 100, 500)
            CreateAmbient("ambient/machines/combine_shield_touch_loop1.wav", Vector(-565, -643, 512), 100, 500)
        end
        
		if GMM["MyMap_Default"] then
			CreateAmbient("ambient/forest_night.wav", Vector(1400, 491, 637), 100, 750)
			CreateAmbient("ambient/gas/steam_loop1.wav", Vector(1364, 747, -1984), 100, 500)
			CreateAmbient("ambient/wind/wind_bass.wav", Vector(1084, 1786, 640), 500, 2500, 0.75)
			CreateAmbient("ambient/wind/wind_rooftop1.wav", Vector(1405, 473, 2489), 100, 1000)
			CreateAmbient("ambient/atmosphere/inside_lighthouse_amb.wav", Vector(-488, -667, 2546), 100, 2000)
			CreateAmbient("ambient/water/corridor_water.wav", Vector(1415, 723, -3854), 100, 2000)
			CreateAmbient("ambient/machines/train_wheels_overhead_loop1.wav", Vector(2444, 647, 96), 10, 200, 0.5)
		end

        if GMM["MyMap_Flood"] then
            CreatePartical("Bubbles", Vector(648, 1135, 16), 0.1)
            CreatePartical("Bubbles", Vector(1352, 176, 240), 1)
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
            local StartTime = ParticalData[5]

            if StartTime == nil or (CurrentTime - StartTime > Delay) then
                StartTime = CurrentTime
                RunFunc()
                __Particles[i][5] = StartTime
            end
        end
	end
	
	local PostCleanup = function()
		print("[GMM] CLIENT CLEANUP")
		
		CreateEnvironment()
	end
	hook.Add("PostCleanupMap", "gmm_PostCleanupMap_Client", PostCleanup)
	PostCleanup()

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
	
		Player:SetDSP(3, true)
		
		net.Start("gmm_ClientInfo")
			net.WriteTable({
				["Shift"] = input.IsKeyDown(KEY_LSHIFT) or input.IsKeyDown(KEY_RSHIFT),
				["Alt"  ] = input.IsKeyDown(KEY_LALT  ) or input.IsKeyDown(KEY_RALT  )
			})
		net.SendToServer()
	end)
end)