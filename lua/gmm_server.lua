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

    local __Anomaly_Spawn_Common = {
        "prop_physics", "prop_physics", "prop_physics",
        "prop_physics", "prop_physics", "prop_physics",
        "gmm_tablet", "gmm_tablet", "gmm_tablet",
        "prop_physics", "prop_physics", "prop_physics",
        "prop_physics", "prop_physics", "prop_physics",
        "gmm_tablet", "gmm_tablet", "gmm_tablet",
        "gmm_radio"
    }

    local __Anomaly_Spawn_Rare = {
        "npc_crow", "npc_grenade_frag", "sent_ball", "npc_clawscanner",
        "npc_manhack", "npc_cscanner", "npc_stalker", "npc_metropolice",
        "npc_pigeon", "npc_seagull", "npc_headcrab", "npc_antlion_grub",
        "npc_headcrab_fast", "npc_zombie", "npc_citizen", "Refugee",
        "npc_gman", "weapon_crowbar"
    }

    local __Anomaly_Spawn_Models = {
        "models/props_c17/oildrum001.mdl",
        "models/Gibs/HGIBS_rib.mdl",
        "models/Gibs/HGIBS_scapula.mdl",
        "models/props_c17/doll01.mdl",
        "models/props_canal/mattpipe.mdl",
        "models/props_c17/TrapPropeller_Lever.mdl",
        "models/props_junk/PopCan01a.mdl",
        "models/props_junk/GlassBottle01a.mdl",
        "models/props_junk/garbage_glassbottle003a.mdl",
        "models/props_junk/garbage_glassbottle001a.mdl",
        "models/props_junk/garbage_glassbottle002a.mdl",
        "models/props_junk/garbage_plasticbottle003a.mdl",
        "models/props_junk/garbage_metalcan001a.mdl",
        "models/props_junk/garbage_metalcan002a.mdl",
        "models/props_junk/garbage_milkcarton001a.mdl",
        "models/props_junk/garbage_plasticbottle001a.mdl",
        "models/props_junk/garbage_plasticbottle002a.mdl",
        "models/props_junk/garbage_takeoutcarton001a.mdl",
        "models/props_junk/terracotta01.mdl",
        "models/props_junk/Shoe001a.mdl",
        "models/props_c17/tools_wrench01a.mdl",
        "models/props_lab/huladoll.mdl",
        "models/props_c17/lamp001a.mdl",
        "models/props_c17/furnitureshelf001b.mdl",
        "models/props_c17/tools_pliers01a.mdl",
        "models/props_junk/garbage_bag001a.mdl",
        "models/props_lab/box01b.mdl",
        "models/props_lab/box01a.mdl",
        "models/props_junk/wood_crate001a.mdl",
        "models/props_junk/wood_crate002a.mdl",
        "models/props_junk/cardboard_box001a.mdl",
        "models/props_junk/cardboard_box002a.mdl",
        "models/props_junk/cardboard_box003a.mdl",
        "models/props_junk/cardboard_box004a.mdl",
        "models/props_junk/garbage_coffeemug001a.mdl",
        "models/props_junk/cinderblock01a.mdl",
        "models/props_junk/watermelon01.mdl",
        "models/props_junk/propanecanister001a.mdl",
        "models/props_junk/plasticbucket001a.mdl",
        "models/props_junk/metal_paintcan001a.mdl",
        "models/props_junk/metalgascan.mdl",
        "models/props_c17/concrete_barrier001a.mdl",
        "models/props_interiors/pot01a.mdl",
        "models/props_interiors/pot02a.mdl",
        "models/props_c17/metalpot002a.mdl",
        "models/props_c17/metalpot001a.mdl",
        "models/props_c17/grinderclamp01a.mdl",
        "models/props_wasteland/laundry_cart002.mdl",
        "models/props_c17/tv_monitor01.mdl",
        "models/props_trainstation/payphone_reciever001a.mdl",
        "models/props_c17/lampshade001a.mdl",
        "models/props_c17/streetsign004f.mdl",
        "models/props_wasteland/barricade001a.mdl",
        "models/props_wasteland/barricade002a.mdl",
        "models/props_wasteland/dockplank01a.mdl",
        "models/props_debris/wood_board01a.mdl",
        "models/props_debris/wood_board02a.mdl",
        "models/props_debris/wood_board03a.mdl",
        "models/props_debris/wood_board04a.mdl",
        "models/props_debris/wood_board05a.mdl",
        "models/props_debris/wood_board06a.mdl",
        "models/props_debris/wood_board07a.mdl",
        "models/props_canal/winch02d.mdl",
        "models/props_c17/playground_swingset_seat01a.mdl",
        "models/props_wasteland/prison_padlock001a.mdl",
        "models/props_wasteland/prison_padlock001b.mdl",
        "models/props_junk/sawblade001a.mdl",
        "models/props_junk/trafficcone001a.mdl",
        "models/props_junk/wood_pallet001a.mdl",
        "models/Items/item_item_crate.mdl",
        "models/props_wasteland/gear01.mdl",
        "models/props_wasteland/gear02.mdl",
        "models/props_citizen_tech/guillotine001a_wheel01.mdl",
        "models/gibs/airboat_broken_engine.mdl",
        "models/props_vehicles/carparts_tire01a.mdl",
        "models/props_vehicles/tire001c_car.mdl",
        "models/props_vehicles/car003a_physics.mdl",
        "models/props_junk/bicycle01a.mdl",
        "models/props_vehicles/car005a_physics.mdl",
        "models/props_junk/rock001a.mdl",
        "models/props_debris/rebar001b_48.mdl",
        "models/props_debris/rebar004b_48.mdl",
        "models/props_debris/rebar_smallnorm01c.mdl",
        "models/Items/item_item_crate_chunk02.mdl",
        "models/props_wasteland/prison_sinkchunk001e.mdl",
        "models/props_wasteland/cafeteria_table001a_chunk08.mdl",
        "models/gibs/furniture_gibs/furniture_vanity01a_gib05.mdl",
        "models/props_pipes/valvewheel002.mdl",
        "models/maxofs2d/companion_doll.mdl",
        "models/maxofs2d/camera.mdl",
        "models/props_phx/misc/egg.mdl",
        "models/props_phx/misc/potato.mdl",
        "models/props_phx/misc/soccerball.mdl",
        "models/props_phx/misc/potato_launcher_explosive.mdl",
        "models/Gibs/HGIBS.mdl",
        "models/props/cs_office/fire_extinguisher.mdl",
        "models/props_c17/pottery01a.mdl",
        "models/props_c17/pottery02a.mdl",
        "models/props_c17/pottery03a.mdl",
        "models/props_c17/pottery04a.mdl",
        "models/props_c17/pottery05a.mdl",
        "models/props_c17/pottery06a.mdl",
        "models/props_c17/pottery07a.mdl",
        "models/props_c17/pottery08a.mdl",
        "models/props_c17/pottery09a.mdl",
        "models/props_c17/pottery_large01a.mdl",
        "models/props_citizen_tech/transponder.mdl",
        "models/gantry_crane/crane_wheel.mdl",
        "models/gantry_crane/crane_lever.mdl",
        "models/props_trainstation/tracksign02.mdl",
        "models/props_outland/pumpkin01.mdl",
        "models/props_outland/forklift_lever.mdl",
        "models/props_mining/elevator_winch_cog.mdl",
        "models/props_mining/railroad_spike01.mdl",
        "models/props_mining/pickaxe01.mdl",
        "models/props_mining/pickaxe01_head.mdl",
        "models/props_junk/gnome.mdl",
        "models/props_forest/axe.mdl",
        "models/props/cs_office/coffee_mug.mdl",
        "models/props/cs_office/coffee_mug2.mdl",
        "models/props/cs_office/coffee_mug3.mdl",
        "models/props/cs_office/computer_caseb.mdl",
        "models/props/cs_office/computer_caseb_p4a.mdl",
        "models/props/cs_office/computer_caseb_p7a.mdl",
        "models/props/cs_office/computer_caseb_p3a.mdl",
        "models/props/cs_office/computer_caseb_p2a.mdl",
        "models/props/cs_office/computer_mouse.mdl",
        "models/props/cs_office/computer_keyboard.mdl",
        "models/props/cs_office/file_box.mdl",
        "models/props/cs_office/paper_towels.mdl",
        "models/props/cs_office/phone_p2.mdl",
        "models/props/cs_office/projector_p6.mdl",
        "models/props/cs_office/projector_remote.mdl",
        "models/props/cs_office/trash_can_p7.mdl",
        "models/props/cs_office/trash_can_p8.mdl",
        "models/props/cs_office/water_bottle.mdl",
        "models/props/cs_office/snowman_hat.mdl",
        "models/props/cs_italy/orange.mdl",
        "models/props/cs_italy/bananna_bunch.mdl",
        "models/props/cs_italy/bananna.mdl",
        "models/props/de_inferno/claypot01.mdl",
        "models/props/de_inferno/claypot02.mdl",
        "models/props/de_inferno/claypot03.mdl",
        "models/props/de_prodigy/desk_console1b.mdl",
        "models/props/de_tides/vending_hat.mdl",
        "models/props/de_tides/vending_turtle.mdl"
    }
    
    local Anomaly_SpawnEntity = function()
        local Players = player.GetAll()
        if #Players == 0 then return end
        local TargetPlayer = Players[math.random(#Players)]
        
        local SpawnPosition = nil

        for i = 1, 10 do
            local RandomOffset = Vector(math.random(-1500, 1500), math.random(-1500, 1500), math.random(-1500, 1500))
            local ChestPosition = TargetPlayer:GetPos() + RandomOffset
            
            local Trace = util.TraceLine({
                start = ChestPosition,
                endpos = ChestPosition - Vector(0, 0, 1000),
                mask = MASK_SOLID_BRUSHONLY
            })

            if Trace.Hit and not Trace.HitSky then
                local PotentialPosition = Trace.HitPos + Vector(0, 0, 20)
                
                local TooClose = false
                for _, Ply in ipairs(Players) do
                    if Ply:GetPos():Distance(PotentialPosition) < 600 then
                        TooClose = true
                        break
                    end
                end
                
                if not TooClose then
                    local CheckEnts = ents.FindInSphere(PotentialPosition, 30)
                    if #CheckEnts == 0 then
                        SpawnPosition = PotentialPosition
                        break
                    end
                end
            end
        end
        
        if not SpawnPosition then return end
        
        local Pool = (math.random() > 0.95) and __Anomaly_Spawn_Rare or __Anomaly_Spawn_Common
        local Class = Pool[math.random(#Pool)]
        
        local Ent = ents.Create(Class)
        if not IsValid(Ent) then return end
        
        Ent:SetPos(SpawnPosition)
        Ent:SetAngles(Angle(0, math.random(0, 360), 0))

        if Class == "prop_physics" then
            Ent:SetModel(__Anomaly_Spawn_Models[math.random(#__Anomaly_Spawn_Models)])

            local SkinCount = Ent:SkinCount()
            if SkinCount > 1 then
                Ent:SetSkin(math.random(0, SkinCount - 1))
            end
        end
        
        Ent:Spawn()
        Ent:Activate()

        if Ent:IsNPC() then
            Ent:SetSchedule(SCHED_FORCED_GO_RUN)
        end
    end
	
	-- ----------------------------------------------------------------------
	
	local NextAnomalyTick = 0
	local FastModeEndTime = 0
	local ActiveFastAnomaly = nil
	
	GMM.Func.FireAnomaly = function()
		local Anomalies = {
			--{1, Anomaly_Shake},
			--{1, Anomaly_PlaySound},
			--{1, Anomaly_Interact},
            {1,  Anomaly_SpawnEntity}
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