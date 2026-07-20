print("[GMM] BOOTSTRAP STARTED... (SERVER)")

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
	
		local __PROP_CASE = MapEntities["PROP_CASE"]
		print(__PROP_CASE)
	
		hook.Add("Think", "gmm_MapThink", function()
			if IsValid(__PROP_CASE) then
				ServerData["Positions"][0] = __PROP_CASE:GetPos()
			else
				ServerData["Positions"][0] = ErrorPosition
			end
		end)
	end
	
	hook.Add("PostCleanupMap", "gmm_PostCleanupMap_Server", PostCleanup)
	PostCleanup()
end)