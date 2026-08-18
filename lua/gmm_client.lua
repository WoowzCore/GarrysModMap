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
			
			local Text = string.format(
				"X: %.1f  Y: %.1f  Z: %.1f  |  Pitch: %.1f°  Yaw: %.1f°  Roll: %.1f°",
				Position.x, Position.y, Position.z,
				Angle.pitch, Angle.yaw, Angle.roll
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
			
			draw.SimpleText(
				Text,
				"DermaDefaultBold",
				ScrW() / 2, RectY + Padding,
				Color(255, 255, 255, 255),
				TEXT_ALIGN_CENTER,
				TEXT_ALIGN_TOP
			)
		end)
	end
	
	-- ----------------------------------------------------------------------
	
	local TimerSecondInterval = 0.05
	
	local __AmbientSounds = {}
	
	local CreateAmbients = function()
		for i = #__AmbientSounds, 1, -1 do
			local SoundData = __AmbientSounds[i]
			local Channel = SoundData[1]
			if IsValid(Channel) then
				Channel:Stop()
			end
			table.remove(__AmbientSounds, i)
		end
		__AmbientSounds = {}
	
		local CreateAmbient = function(SoundFile, Position, IDistance, ADistance, Volume, Delay)
			SoundFile = "sound/" .. SoundFile
		
			Volume    = Volume    or 1
			IDistance = IDistance or 100
			ADistance = ADistance or 1500
			Delay     = Delay     or 0
			
			sound.PlayFile(SoundFile, "noplay", function(Channel, eID, e)
				if e then error("[GMM] [ERROR]: FAILED PlayFile AMBIENT SOUND [" .. SoundFile .. "]:", eID, e) return end
				if not IsValid(Channel) then error("[GMM] [ERROR]: FAILED PlayFile AMBIENT SOUND [" .. SoundFile .. "]: Channel is not valid!") return end
				
				table.insert(__AmbientSounds, {Channel, Position, Volume, IDistance, ADistance, Delay, SoundFile})
			end)
		end
		
		-- ----------------------------------------------------------------------
		
		if GMM["MyMap"] then
			CreateAmbient("ambient/guit1.wav", Vector(456, -589, 519), 100, 500)
			CreateAmbient("ambient/machines/combine_shield_touch_loop1.wav", Vector(-565, -643, 512), 100, 500)
			CreateAmbient("ambient/forest_night.wav", Vector(1400, 491, 637), 100, 750)
			CreateAmbient("ambient/gas/steam_loop1.wav", Vector(1364, 747, -1984), 100, 500)
			CreateAmbient("ambient/wind/wind_bass.wav", Vector(1084, 1786, 640), 500, 2500, 0.75)
			CreateAmbient("buttons/blip2.wav", 0, 100, 200, 1, 1)
			CreateAmbient("ambient/wind/wind_rooftop1.wav", Vector(1405, 473, 2489), 100, 1000)
			CreateAmbient("ambient/alarms/razortrain_horn1.wav", Vector(0, 0, 0), 100, 500)
			CreateAmbient("woowz/music/concrete_halls.wav", 1, 10, 300, 20)
			CreateAmbient("music/hl1_song25_remix3.mp3", Vector(-2419, 589, 610), 10, 100, 50)
			CreateAmbient("ambient/atmosphere/inside_lighthouse_amb.wav", Vector(-488, -667, 2546), 100, 2000)
			CreateAmbient("ambient/water/corridor_water.wav", Vector(1415, 723, -3854), 100, 2000)
			CreateAmbient("ambient/machines/train_wheels_overhead_loop1.wav", Vector(2444, 647, 96), 10, 200, 0.5)
		end
	end
	
	local UpdateAmbientSounds = function()
		local CurrentTime = RealTime()
	
		for i = #__AmbientSounds, 1, -1 do
			local SoundData = __AmbientSounds[i]
			
			local Channel   = SoundData[1]
			local Position  = SoundData[2]
			local Volume    = SoundData[3]
			local IDistance = SoundData[4]
			local ADistance = SoundData[5]
			local Delay     = SoundData[6]
			local SoundFile = SoundData[7]
			local StartTime = SoundData[8]
			local Working   = SoundData[9]
			local Length    = Channel:GetLength()
			
			if Working == nil then Working = true end
			
			if StartTime == nil or (CurrentTime - StartTime > (Length + Delay)) then
				StartTime = CurrentTime
				Channel:Play()
				__AmbientSounds[i][8] = StartTime
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
			__AmbientSounds[i][9] = Working
			Channel:SetVolume(__Volume)
		end
	end
	
	local PostCleanup = function()
		print("[GMM] CLIENT CLEANUP")
		
		CreateAmbients()
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
		UpdateAmbientSounds()
	
		Player:SetDSP(3, true)
		
		net.Start("gmm_ClientInfo")
			net.WriteTable({
				["Shift"] = input.IsKeyDown(KEY_LSHIFT) or input.IsKeyDown(KEY_RSHIFT),
				["Alt"  ] = input.IsKeyDown(KEY_LALT  ) or input.IsKeyDown(KEY_RALT  )
			})
		net.SendToServer()
	end)
end)