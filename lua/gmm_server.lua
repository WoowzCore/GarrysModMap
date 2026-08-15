print("[GMM] BOOTSTRAP STARTED... (SERVER)")

GMM_S = {
	["Clients"] = {
		
	}
}

hook.Add("InitPostEntity", "gmm_MapLoad", function()
	-- Загрузка сервера
	print("[GMM] SERVER LOADED")

	local ServerData = {}

	util.AddNetworkString("gmm_Get_ServerData" )
	util.AddNetworkString("gmm_Send_ServerData")
	
	net.Receive("gmm_Get_ServerData", function(L, Player)
		net.Start("gmm_Send_ServerData")
			net.WriteTable(ServerData)
		net.Send(Player)
	end)
	
	-- ----------------------------------------------------------------------
	
	local PostCleanup = function()
		print("[GMM] SERVER CLEANUP")
	
		local MapEntities = {}
		for _, Entity in ipairs(ents.GetAll()) do
			if IsValid(Entity) then
				local Name = Entity:GetName()
				if Name ~= "" then
					MapEntities[Name] = Entity
				end
			end
		end
	
		-- ----------------------------------------------------------------------
	
		ServerData = {
			["Positions"] = {}
		}
		
		-- ----------------------------------------------------------------------
	
		if GMM["MyMap"] then
	
			local __PROP_CASE = MapEntities["PROP_CASE"]
			local __SPEAKER   = MapEntities["SPEAKER"  ]
		
			local ReportEntity = function(Entity, ID)
				if IsValid(Entity) then
					ServerData["Positions"][ID] = Entity:GetPos()
				else
					ServerData["Positions"][ID] = ErrorPosition
				end
			end
		
			hook.Add("Think", "gmm_MapThink", function()
				ReportEntity(__PROP_CASE, 0)
				ReportEntity(__SPEAKER  , 1)
			end)
			
		end
	end
	
	hook.Add("PostCleanupMap", "gmm_PostCleanupMap_Server", PostCleanup)
	PostCleanup()
	
	-- ----------------------------------------------------------------------
		
	util.AddNetworkString("gmm_ClientInfo")
	
	net.Receive("gmm_ClientInfo", function(L, Player)
		GMM_S["Clients"][Player] = net.ReadTable()
	end)
	
	-- ----------------------------------------------------------------------
	
	local ShakeProp = function(Prop, Power)
		if not IsValid(Prop) then return end
		
		local Phys = Prop:GetPhysicsObject()
		if not IsValid(Phys) then return end
		
		if not Phys:IsMoveable() then return end
		
		local Mass = Phys:GetMass()
		
		local FinalPower = Power * (Mass / 10)
		FinalPower = math.Clamp(FinalPower, Power * 0.5, Power * 5)
		
		local Direction = Vector(
			math.random(-100, 100),
			math.random(-100, 100),
			math.random(  50, 150)
		):GetNormalized()
		
		Phys:ApplyForceCenter(Direction * FinalPower)
		
		local Torque = Vector(
			math.random(-200, 200),
			math.random(-200, 200),
			math.random(-200, 200)
		)
		
		Phys:ApplyTorqueCenter(Torque * (Mass / 10))
	end
	
	local function GetPhysicsProps()
		local Props = {}
		
		for _, Ent in ipairs(ents.GetAll()) do
			if IsValid(Ent) then
				local Class = Ent:GetClass()
				if string.match(Class, "prop_physics") then
					local Phys = Ent:GetPhysicsObject()
					if IsValid(Phys) and Phys:IsMoveable() then
						table.insert(Props, Ent)
					end
				end
			end
		end
		
		return Props
	end
	
	-- ----------------------------------------------------------------------
	-- Аномалии
	
	local Anomaly_Shake = function()
		local Props = GetPhysicsProps()
		
		if #Props == 0 then return end
		
		for _, Prop in ipairs(Props) do
			if math.random() > 0.99 then
				ShakeProp(Prop, (math.random() > 0.9 and 10000000 or 10000) * math.random())
			end
		end
	end
	
	local __Anomaly_Sounds = {
		--"woowz/other/popy.wav",
		--"ambient/opera.wav",
		"ambient/creatures/flies1.wav",
		--"doors/door_chainlink_close2.wav",
		--"combined/citadel/citadel_br_guest_f_cc.wav",
		--"phx/explode04.wav"
	}
	local Anomaly_PlaySound = function()
		local SoundPath = __Anomaly_Sounds[math.random(1, #__Anomaly_Sounds)]
		
		for _, Player in ipairs(player.GetAll()) do
			if IsValid(Player) then
				Player:EmitSound(SoundPath, 100, math.random(50, 150), math.random() * math.random(), CHAN_STATIC)
			end
		end
	end
	
	-- ----------------------------------------------------------------------
	
	local AnomalyTimerSpeed = 5
	timer.Create("gmm_AnomalyTimer", AnomalyTimerSpeed, 0, function()
		local Anomalies = {
			Anomaly_Shake,
			Anomaly_PlaySound
		}
		
		local Index = math.random(1, #Anomalies)
		local Anomaly = Anomalies[Index]
		if Anomaly then
			Anomaly()
		else
			print("[GMM] ANOMALY  [" + Index + "] NOT FOUND!")
		end
	end)
end)