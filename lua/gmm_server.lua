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
		
			hook.Add("Think", "gmm_MapThink", function()
				if IsValid(__PROP_CASE) then
					ServerData["Positions"][0] = __PROP_CASE:GetPos()
				else
					ServerData["Positions"][0] = ErrorPosition
				end
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
				ShakeProp(Prop, 10000 * math.random())
			end
		end
	end
	
	-- ----------------------------------------------------------------------
	
	timer.Create("gmm_AnomalyTimer", 5, 0, function()
		Anomaly_Shake()
	end)
end)