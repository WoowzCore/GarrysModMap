print("[GMM] BOOTSTRAP STARTED... (SERVER)")

GMM_S = {
	["Clients"] = {
		
	}
}

hook.Add("InitPostEntity", "gmm_MapLoad", function()
	-- Загрузка сервера
	print("[GMM] SERVER LOADED")
	print("[GMM] Map: " .. game.GetMap())

	local ServerData = {
        ["Positions"] = {}
    }

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
	
		if GMM["MyMap_Default"] or GMM["MyMap_Flood"] or GMM["MyMap_Old"] then
			local __PROP_CASE = MapEntities["PROP_CASE"]
			local __SPEAKER   = MapEntities["SPEAKER"  ]
			local __TURTLE    = MapEntities["PROP_TURTLE"]
		
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
				ReportEntity(__TURTLE   , 2)
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
	
	concommand.Add("gmm_anomaly", function(Player, CMD, Args)
		print("[GMM] Fire anomaly!")
		GMM.Func.FireAnomaly()
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
	
	local __Anomaly_Sounds_Rare = {
		"woowz/other/popy.wav",
		"ambient/3dmeagle.wav",
		"ambient/alarms/razortrain_horn1.wav",
		"ambient/alarms/train_horn2.wav",
		"ambient/alarms/train_horn_distant1.wav",
		"ambient/animal/bird17.wav",
		"ambient/animal/frog_1.wav",
		"ambient/animal/horse_2.wav",
		"ambient/animal/snake3.wav",
		"ambient/chatter/arabic_radio4.wav",
		"ambient/chatter/cb_radio_chatter_2.wav",
		"ambient/chatter/italian_radio4.wav",
		"ambient/creatures/seagull_idle2.wav",
		"ambient/creatures/teddy.wav",
		"ambient/creatures/town_child_scream1.wav",
		"ambient/creatures/town_zombie_call1.wav",
		"ambient/energy/newspark01.wav",
		"ambient/energy/newspark02.wav",
		"ambient/energy/newspark05.wav",
		"ambient/energy/powerdown2.wav",
		"ambient/fire/ignite.wav",
		"ambient/fire/mtov_flame2.wav",
		"ambient/intro/alyxremove.wav",
		"ambient/intro/debris03.wav",
		"ambient/levels/canals/critter1.wav",
		"ambient/levels/canals/critter7.wav",
		"ambient/levels/canals/drip2.wav",
		"ambient/levels/canals/drip3.wav",
		"ambient/levels/canals/drip4.wav",
		"ambient/levels/canals/drip1.wav",
		"ambient/levels/canals/toxic_slime_gurgle5.wav",
		"ambient/levels/caves/ol04_gearengage.wav",
		"ambient/levels/citadel/advisor_lift.wav",
		"ambient/levels/citadel/datatransrandom03.wav",
		"ambient/levels/citadel/datatransrandom02.wav",
		"ambient/levels/citadel/datatransrandom01.wav",
		"ambient/levels/citadel/strange_talk1.wav",
		"ambient/levels/citadel/strange_talk10.wav",
		"ambient/levels/citadel/strange_talk11.wav",
		"ambient/levels/citadel/strange_talk3.wav",
		"ambient/levels/citadel/strange_talk4.wav",
		"ambient/levels/citadel/strange_talk5.wav",
		"ambient/levels/citadel/strange_talk6.wav",
		"ambient/levels/citadel/strange_talk7.wav",
		"ambient/levels/citadel/strange_talk8.wav",
		"ambient/levels/citadel/strange_talk9.wav",
		"ambient/levels/coast/seagulls_ambient5.wav",
		"ambient/levels/forest/crik3.wav",
		"ambient/levels/labs/coinslot1.wav",
		"ambient/levels/launch/1stfiringwarning.wav",
		"ambient/levels/launch/launchvoice.wav",
		"ambient/levels/prison/radio_random1.wav",
		"ambient/levels/prison/radio_random10.wav",
		"ambient/levels/prison/radio_random11.wav",
		"ambient/levels/prison/radio_random12.wav",
		"ambient/levels/prison/radio_random13.wav",
		"ambient/levels/prison/radio_random14.wav",
		"ambient/levels/prison/radio_random15.wav",
		"ambient/levels/prison/radio_random2.wav",
		"ambient/levels/prison/radio_random3.wav",
		"ambient/levels/prison/radio_random4.wav",
		"ambient/levels/prison/radio_random5.wav",
		"ambient/levels/prison/radio_random6.wav",
		"ambient/levels/prison/radio_random7.wav",
		"ambient/levels/prison/radio_random8.wav",
		"ambient/levels/prison/radio_random9.wav",
		"ambient/machines/keyboard1_clicks.wav",
		"ambient/machines/hydraulic_1.wav",
		"ambient/machines/machine1_hit1.wav",
		"ambient/machines/pneumatic_drill_4.wav",
		"ambient/materials/cupdrop.wav",
		"ambient/materials/flush1.wav",
		"ambient/materials/flush2.wav",
		"ambient/materials/dinnerplates1.wav",
		"ambient/materials/dinnerplates2.wav",
		"ambient/materials/dinnerplates3.wav",
		"ambient/materials/dinnerplates4.wav",
		"ambient/materials/dinnerplates5.wav",
		"ambient/materials/metal_big_impact_scrape1.wav",
		"ambient/materials/metal_groan.wav",
		"ambient/materials/platedrop1.wav",
		"ambient/materials/platedrop2.wav",
		"ambient/materials/platedrop3.wav",
		"ambient/materials/squeeker2.wav",
		"ambient/materials/vent_scurry_medium.wav",
		"ambient/misc/brass_bell_c.wav",
		"ambient/misc/brass_bell_d.wav",
		"ambient/misc/brass_bell_e.wav",
		"ambient/misc/brass_bell_f.wav",
		"ambient/misc/carhonk1.wav",
		"ambient/misc/carhonk2.wav",
		"ambient/misc/carhonk3.wav",
		"ambient/misc/hammer1.wav",
		"ambient/misc/hammer2.wav",
		"ambient/misc/hammer3.wav",
		"ambient/misc/metal2.wav",
		"ambient/office/button1.wav",
		"ambient/office/officenews.wav",
		"ambient/outro/messagepacket01.wav",
		"ambient/outro/messagepacket02.wav",
		"ambient/outro/thunder01.wav",
		"ambient/outro/thunder02.wav",
		"ambient/outro/thunder03.wav",
		"ambient/outro/thunder04.wav",
		"ambient/outro/thunder05.wav",
		"ambient/outro/thunder06.wav",
		"ambient/outro/thunder07.wav",
		"ambient/tones/elev1.wav",
		"ambient/tones/equip1.wav",
		"ambient/tones/equip2.wav",
		"ambient/tones/equip3.wav",
		"ambient/tones/equip4.wav",
		"ambient/tones/equip5.wav",
		"ambient/tones/floor1.wav",
		"ambient/voices/citizen_beaten3.wav",
		"ambient/voices/citizen_beaten4.wav",
		"ambient/voices/citizen_beaten5.wav",
		"ambient/voices/cough1.wav",
		"ambient/voices/cough2.wav",
		"ambient/voices/cough4.wav",
		"ambient/voices/cough3.wav",
		"ambient/voices/f_scream1.wav",
		"ambient/voices/m_scream1.wav",
		"ambient/voices/playground_memory.wav",
		"ambient/voices/squeal1.wav",
		"buttons/blip2.wav",
		"buttons/button16.wav",
		"common/bugreporter_succeeded.wav",
		"common/wpn_hudoff.wav",
		"common/wpn_denyselect.wav",
		"common/wpn_moveselect.wav",
		"common/wpn_select.wav",
		"doors/door1_move.wav",
		"doors/door_locked2.wav",
		"doors/latchlocked2.wav",
		"friends/friend_join.wav",
		"friends/friend_online.wav",
		"friends/message.wav",
		"garrysmod/balloon_pop_cute.wav",
		"garrysmod/content_downloaded.wav",
		"garrysmod/save_load1.wav",
		"garrysmod/save_load2.wav",
		"garrysmod/save_load3.wav",
		"garrysmod/save_load4.wav",
		"garrysmod/ui_click.wav",
		"hl1/fvox/bell.wav",
		"hl1/fvox/biohazard_detected.wav",
		"hl1/fvox/fuzz.wav",
		"hl1/fvox/near_death.wav",
		"hl1/fvox/warning.wav",
		"items/ammo_pickup.wav",
		"player/breathe1.wav",
		"player/geiger1.wav",
		"player/pl_burnpain1.wav",
		"resource/warning.wav",
		"ui/hint.wav",
		
		"vo/npc/male01/question26.wav",
		"vo/npc/male01/question06.wav",
		"vo/npc/male01/runforyourlife01.wav",
		"vo/npc/male01/yeah02.wav",
		"vo/npc/male01/moan04.wav",
		"vo/npc/male01/hi02.wav",
		"vo/npc/male01/fantastic01.wav"
	}

	local __Anomaly_Sounds_Common = {
		"ambient/creatures/flies1.wav",
		"ambient/animal/flies4.wav",
		"ambient/alarms/warningbell1.wav",
		"ambient/animal/cow.wav",
		"ambient/animal/crow.wav",
		"ambient/animal/dog1.wav",
		"ambient/animal/dog4.wav",
		"ambient/animal/dog_growl_behind_wall_1.wav",
		"ambient/animal/dog_med_inside_bark_4.wav",
		"ambient/animal/rodent_scratch_short_1.wav",
		"ambient/animal/rodent_scratch_1.wav",
		"ambient/creatures/pigeon_idle3.wav",
		"ambient/creatures/rats1.wav",
		"ambient/creatures/rats2.wav",
		"ambient/creatures/rats3.wav",
		"ambient/creatures/rats4.wav",
		"ambient/creatures/town_moan1.wav",
		"ambient/creatures/town_muffled_cry1.wav",
		"ambient/creatures/town_scared_sob2.wav",
		"ambient/creatures/town_scared_sob1.wav",
		"ambient/creatures/town_scared_breathing2.wav",
		"ambient/creatures/town_scared_breathing1.wav",
		"ambient/energy/power_off1.wav",
		"ambient/explosions/exp1.wav",
		"ambient/explosions/exp2.wav",
		"ambient/explosions/exp3.wav",
		"ambient/explosions/exp4.wav",
		"ambient/intro/debris01.wav",
		"ambient/intro/debris02.wav",
		"ambient/levels/canals/toxic_slime_gurgle2.wav",
		"ambient/levels/canals/toxic_slime_gurgle3.wav",
		"ambient/levels/canals/toxic_slime_gurgle4.wav",
		"ambient/levels/canals/toxic_slime_gurgle6.wav",
		"ambient/levels/canals/windchime2.wav",
		"ambient/levels/canals/windchime4.wav",
		"ambient/levels/canals/windchime5.wav",
		"ambient/levels/canals/windchine1.wav",
		"ambient/levels/caves/dist_grub5.wav",
		"ambient/levels/caves/dist_grub3.wav",
		"ambient/levels/caves/dist_grub4.wav",
		"ambient/levels/caves/dist_grub2.wav",
		"ambient/levels/caves/dist_grub1.wav",
		"ambient/levels/coast/antlion_hill_ambient1.wav",
		"ambient/levels/coast/coastbird7.wav",
		"ambient/levels/gman/gman_seg_00_01_03.wav",
		"ambient/levels/gman/gman_seg_00_21_05.wav",
		"ambient/levels/gman/gman_sgnature_shrt.wav",
		"ambient/levels/labs/teleport_mechanism_windup3.wav",
		"ambient/levels/labs/teleport_mechanism_windup2.wav",
		"ambient/levels/labs/teleport_mechanism_windup1.wav",
		"ambient/levels/launch/debris01.wav",
		"ambient/levels/launch/debris02.wav",
		"ambient/levels/streetwar/building_rubble1.wav",
		"ambient/levels/streetwar/building_rubble2.wav",
		"ambient/levels/streetwar/building_rubble3.wav",
		"ambient/levels/streetwar/building_rubble4.wav",
		"ambient/levels/streetwar/building_rubble5.wav",
		"ambient/materials/creaking.wav",
		"ambient/materials/icegrind1.wav",
		"ambient/materials/metal4.wav",
		"ambient/materials/metal5.wav",
		"ambient/materials/metal9.wav",
		"ambient/materials/metal_stress1.wav",
		"ambient/materials/metal_stress2.wav",
		"ambient/materials/metal_stress3.wav",
		"ambient/materials/metal_stress4.wav",
		"ambient/materials/metal_stress5.wav",
		"ambient/materials/rock1.wav",
		"ambient/materials/rock2.wav",
		"ambient/materials/rock3.wav",
		"ambient/materials/rock4.wav",
		"ambient/materials/rock5.wav",
		"ambient/materials/rustypipes1.wav",
		"ambient/materials/rustypipes2.wav",
		"ambient/materials/rustypipes3.wav",
		"ambient/materials/shipgroan1.wav",
		"ambient/materials/shipgroan2.wav",
		"ambient/materials/shipgroan3.wav",
		"ambient/materials/shipgroan4.wav",
		"ambient/materials/squeekyfloor1.wav",
		"ambient/materials/squeekyfloor2.wav",
		"ambient/materials/wood_creak1.wav",
		"ambient/materials/wood_creak2.wav",
		"ambient/materials/wood_creak3.wav",
		"ambient/materials/wood_creak4.wav",
		"ambient/materials/wood_creak5.wav",
		"ambient/materials/wood_creak6.wav",
		"ambient/misc/clank1.wav",
		"ambient/misc/clank2.wav",
		"ambient/misc/clank3.wav",
		"ambient/misc/clank4.wav",
		"ambient/misc/metal3.wav",
		"ambient/misc/metal6.wav",
		"ambient/misc/metal7.wav",
		"ambient/misc/metal8.wav",
		"ambient/misc/metal9.wav",
		"ambient/misc/tink1.wav",
		"ambient/water/distant_drip1.wav",
		"ambient/water/distant_drip2.wav",
		"ambient/water/distant_drip3.wav",
		"ambient/water/distant_drip4.wav",
		"ambient/water/distant_wave1.wav",
		"ambient/water/distant_wave2.wav",
		"ambient/water/distant_wave3.wav",
		"ambient/wind/wind_hit1.wav",
		"ambient/wind/wind_hit2.wav",
		"ambient/wind/wind_hit3.wav",
		"ambient/wind/wind_gust_10.wav",
		"ambient/wind/wind_gust_2.wav",
		"ambient/wind/wind_gust_8.wav",
		"buttons/lightswitch2.wav"
	}
	local Anomaly_PlaySound = function()
		local Pool
		if math.random() < 0.1 then
			Pool = __Anomaly_Sounds_Rare
		else
			Pool = __Anomaly_Sounds_Common
		end
	
		local SoundPath = Pool[math.random(1, #Pool)]
		
		for _, Player in ipairs(player.GetAll()) do
			if IsValid(Player) then
				Player:EmitSound(SoundPath, 100, math.random(50, 150), math.random() * math.random(), CHAN_STATIC)
			end
		end
	end
	
	local Anomaly_Interact = function()
		local InteractClasses = {
			"func_button",
			"func_rot_button",
			"prop_door_rotating",
			"func_door",
			"func_door_rotating",
			"button_target",
			"prop_button",
			"func_movelinear",
			"func_typewriter"
		}
		
		local Found = {}
		for _, Class in ipairs(InteractClasses) do
			local EntsByClass = ents.FindByClass(Class)
			for _, Entity in ipairs(EntsByClass) do
				table.insert(Found, Entity)
			end
		end
		
		if #Found == 0 then return end
		
		local Random = Found[math.random(1, #Found)]
		
		if IsValid(Random) then
			Random:Fire("Use")
		end
	end
	
	-- ----------------------------------------------------------------------
	
	local NextAnomalyTick = 0
	local FastModeEndTime = 0
	local ActiveFastAnomaly = nil
	
	GMM.Func.FireAnomaly = function()
		local Anomalies = {
			{1, Anomaly_Shake},
			{1, Anomaly_PlaySound},
			{1, Anomaly_Interact},
		}
	
		local Anomaly = nil
		
		if ActiveFastAnomaly then
			Anomaly = ActiveFastAnomaly
		else
			local TotalWeight = 0
			for _, A in ipairs(Anomalies) do
				TotalWeight = TotalWeight + A[1]
			end
			
			local RandomChoice = math.random(1, TotalWeight)
			local CurrentWeight = 0
			
			for _, A in ipairs(Anomalies) do
				CurrentWeight = CurrentWeight + A[1]
				if RandomChoice <= CurrentWeight then
					Anomaly = A[2]
					break
				end
			end
			
			if math.random() < 0.005 then
				FastModeEndTime = CurTime() + math.random(5, 30)
				ActiveFastAnomaly = Anomaly
			end
		end
		
		if Anomaly then
			Anomaly()
		else
			print("[GMM] ANOMALY SELECTION FAILED!")
		end
	end
	
	if GMM["DoAnomalies"] then
		timer.Create("gmm_AnomalyTimer", 0.1, 0, function()
			local T = CurTime()
			
			if ActiveFastAnomaly then
				if T > FastModeEndTime then
					ActiveFastAnomaly = nil
					NextAnomalyTick = T + 5
				else
					GMM.Func.FireAnomaly()
				end
			else
				if T >= NextAnomalyTick then
					GMM.Func.FireAnomaly()
					NextAnomalyTick = T + 5
				end
			end
		end)
	end
end)