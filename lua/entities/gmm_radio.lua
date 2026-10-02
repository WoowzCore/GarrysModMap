AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "RAD-10"
ENT.Author = "Woowz11"
ENT.Category = "GMM"
ENT.Spawnable = GMM["Valid"]

ENT.Delay = 0

local WoowzCoreTracks = {
	"Avith Ortega - Dopamine for Her Professing - Edit","Avith Ortega - Leisure Time","EDARUMA - Recent Past","fadinglight - company","Glwzbll - GLW2000","latex fruit - Loveme2",
	"Lemon Demon - Brodyquest","Seamoon - Six Synergies","Spatial Manufacture Ltd.","t e l e p a t h - track","Visonia - The Amethyst City","Visonia - The Moon Doesn't Want to Look at You",
	"rodr1se - Hardstyle Drill 2009","Rory in early 20s - track","t e l e p a t h - track 2","t e l e p a t h - track 3","t e l e p a t h - track 4","T.G.T.B. - Derelict","Seamoon - Six Synergies",
	"M4 Vaporwave - Murderer Star","mayten - self reflection","Nmesh - track","Oliver Buckland - espial","Oneheart - snowfall","permskiy krai - The Virus","Polligopkalo - bloodyangel.mp666",
	"crossing bridges - Deep Under the Surface of Level 7","Cult Member - The Ravedeath Still Hurts","DJ DR4GM4SHROOM - INTERN3T EXPLOR3R","FM Skyline - body_texture render","FM Skyline - Harlequin","Harold Budd - LAventure","KISYZ - Six Forty Seven",
	"Wayne Hill - Left Bank Two (Vision On Gallery Theme)","Whitewoods - Beat Street","Xxtarlit","yandere - dreamcore","Ray Lynch","alone land","Constant Smiles - Restlessness (I Dont Sleep Well)",
	"Pathetic - escalator","Piers Baron - The Last Night on Earth","Rory in early 20s - track 2","rvfzme - Char","Snow Strippers - Fantasy","Snow Strippers - Wont Be Back Again","VHS Logos - Sony",
	"Noisemaker - Magna Aliqua","Oliver Buckland - vacillate","Betatrip - useless","dxnrm - why i'm here","Lustre - Let Go Like Leaves of Fall","Marc Acardipane - Return to Zero Beztebya","Mietze Conte - d(-_-)b dreaming of your latte art d(-_-)b",
	"Viselnik - Dying Nature","ZanZiglatore","Avith Ortega - Betrayal","Dargaard - Thy Fleeing Time","Green-House - Xylem","Molina - Hey Kids","Nmesh - track 2",
	"naran ratan - Forevertime Journeys II","Oliver Buckland - backroom labyrinth","Oliver Buckland - Dead God Graveyard","Raymond Scott - Portofino 2","Robin Guthrie - Imperial","Sacre - An Ending (Arena Tv Series)","Ssaliva - Arrow",
	"Dottie Evans - Tonight You Belong to Me","dxnrm - restless dreams","Grouper - Poison Tree","Kero Kero Bonito - I'd Rather Sleep","Lifeformed - Undiscovery","Lustre - Petrichor","Mild High Club - Homage",
	"Art Fact - Whom Are You Dancing For_","crossing bridges - Lighters","crossing bridges - WaterWorld43","CXRGI - weeping (Slowed)",
	"special/oldebr_music_0","special/oldebr_music_1","special/oldebr_music_2","special/oldebr_music_3","special/oldebr_music_4","special/oldebr_music_5","special/woowzcore_music",
	"stvrshine - Constant Anxiety","TPFL - track","VAPERROR - Start Up","Yabujin - CHALICE OF MIND","LobotomyCorporation OST  - Second Warning",
	"Mega Degrod - Xleepy","myxtica - Old Doll (out of tune) (slowed)","Paavoharju - Valo tihkuu kaiken lapi","Saul Stokes - Spirit Control","stvrshine - At the Speed of Light",
	"Saul Stokes - The Telecine Ensemble","Blod Besvimelse - Misanthrop","Cult Member - U Weren't Here I Really Miss You","DXXDLY - Eerie","Mega Degrod - Athoth a go!! go!!!",
	"Dargaard - The Infinite","Pye Corner Audio - Hollow Earth","Saul Stokes - Intra-Fantasy"
}

ENT.Tracks = {}

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Playing")
	self:NetworkVar("Bool", 1, "PrikolLoud")
	self:NetworkVar("Int" , 2, "TrackIndex")
	self:NetworkVar("Bool", 3, "Init")
end

function ENT:Initialize()
	local Init = self:GetInit()

	self:SetModel("models/props/cs_office/radio.mdl")

	self:PhysicsInit(SOLID_VPHYSICS   )
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid   (SOLID_VPHYSICS   )

	local PhysicsObject = self:GetPhysicsObject()
	if IsValid(PhysicsObject) then PhysicsObject:Wake() end

	self.PhysgunDisabled = self.m_PlayerCreator == nil

	if SERVER then
		self:SetUseType(SIMPLE_USE)
		
		local BaseURL = "https://woowz11.github.io/woowzsite/source/woowzcore/musics/"
		for _, Track in ipairs(WoowzCoreTracks) do
			table.insert(self.Tracks, BaseURL .. Track .. ".mp3")
		end
		
		if not Init then
			self:SetPrikolLoud(math.random() > 0.95)
			self:SetTrackIndex(math.random(#self.Tracks))
		end
		
		if self:GetPrikolLoud() then
			self:SetColor(Color(255, 255, 0, 255))
		end
		
		if Init and self:GetPlaying() then
			local Index = self:GetTrackIndex() - 1
			if Index < 1 then Index = #self.Tracks end
	
			local Track = self.Tracks[Index]
			if Track then
				net.Start("gmm_radio_Play")
					net.WriteEntity(self)
					net.WriteString(Track)
				net.Broadcast()
			else
				self:SetPlaying(false)
			end
		end
		
		self:SetInit(true)
	end
end

-- ----------------------------------------------------------------------

function ENT:Use(Activator, Caller)
	if not IsValid(Activator) then return end
	if not Activator:IsPlayer() then return end
	
	Activator:PickupObject(self)
	
	if SERVER then
		if GMM["Valid"] then
			local ClientInfo = GMM_S["Clients"][Activator]
			local ShiftPressed = false
			local AltPressed   = false
			if ClientInfo then
				ShiftPressed = ClientInfo["Shift"] or false
				  AltPressed = ClientInfo["Alt"  ] or false
			end
		
			if ShiftPressed or AltPressed then self:Toggle(Activator, AltPressed) end
		else
			self:EmitSound("ambient/voices/squeal1.wav")
		end
	end
end

function ENT:Think()
	if SERVER and self.Delay > 0 then self.Delay = self.Delay - 1 end
end

-- ----------------------------------------------------------------------

if SERVER and GMM["Valid"] then
	util.AddNetworkString("gmm_radio_ShowMessage")
	util.AddNetworkString("gmm_radio_Play")

	function ENT:GetNextTrack(Next)
		local Direction = Next and 1 or -1
	
		local Index = self:GetTrackIndex()
		local Track = self.Tracks[Index]
		
		local NewIndex = Index + Direction
		if NewIndex > #self.Tracks then
			NewIndex = 1
		elseif NewIndex < 1 then
			NewIndex = #self.Tracks
		end
		
		self:SetTrackIndex(NewIndex)
		
		return Track
	end

	function ENT:Toggle(Activator, Pressed)
		if self.Delay > 0 then return end self.Delay = 5
	
		self:EmitSound("buttons/button1.wav")
	
		if self:GetPlaying() then
			self:Stop()
		else
			self:Play(Activator, Pressed)
		end
	end

	function ENT:Play(Activator, Pressed)
		if self:GetPlaying() then return end
		self:SetPlaying(true)
		
		local Track = self:GetNextTrack(Pressed)
		
		net.Start("gmm_radio_Play")
			net.WriteEntity(self)
			net.WriteString(Track)
		net.Broadcast()
		
		net.Start("gmm_radio_ShowMessage")
			net.WriteString((Pressed and "<" or ">") .. " P L A Y: .../woowzsite_old/" .. (Track:match("([^/]+)$")))
		net.Send(Activator)
	end

	function ENT:Stop()
		if not self:GetPlaying() then return end
		self:SetPlaying(false)
		
		net.Start("gmm_radio_Play")
			net.WriteEntity(self)
			net.WriteString("")
		net.Broadcast()
	end
end

-- ----------------------------------------------------------------------

if CLIENT and GMM["Valid"] then
    local __CurrentMessageText = ""
	local __MessageEndTime = 0

	net.Receive("gmm_radio_ShowMessage", function()
		__CurrentMessageText = net.ReadString()
		__MessageEndTime = CurTime() + 3
	end)

	surface.CreateFont("gmm_radio_Font", {
		font = "DermaDefault",
		size = 32,
		weight = 800,
		antialias = true,
		shadow = false
	})

	hook.Add("HUDPaint", "gmm_radio_DrawMessage", function()
		if __MessageEndTime > CurTime() and __CurrentMessageText ~= "" then
			local SW = ScrW()
			local SH = ScrH()
			
			local Alpha = 255
			
			local TimeLeft = __MessageEndTime - CurTime()
			local FadeDuration = 0.5
			if TimeLeft < FadeDuration then
				Alpha = math.Clamp(255 * (TimeLeft / FadeDuration), 0, 255)
			end
			
			local Font = "gmm_radio_Font"
			local OY = 25
			
			local DrawShadow = function(OX__, OY__)
				draw.SimpleText(
					__CurrentMessageText,
					Font,
					SW / 2 + OX__, SH / 2 + OY__ + OY,
					Color(0, 0, 0, Alpha * 0.8),
					TEXT_ALIGN_CENTER,
					TEXT_ALIGN_CENTER
				)
			end
			
			local ShadowOffset = 2
			DrawShadow(ShadowOffset, 0)
			DrawShadow(0, ShadowOffset)
			DrawShadow(ShadowOffset, ShadowOffset)
			DrawShadow(-ShadowOffset, 0)
			DrawShadow(0, -ShadowOffset)
			DrawShadow(-ShadowOffset, -ShadowOffset)
			DrawShadow(ShadowOffset, -ShadowOffset)
			DrawShadow(-ShadowOffset, ShadowOffset)
			
			draw.SimpleText(
				__CurrentMessageText,
				Font,
				SW / 2, SH / 2 + OY,
				Color(255, 255, 255, Alpha),
				TEXT_ALIGN_CENTER,
				TEXT_ALIGN_CENTER
			)
		end
	end)
	
	-- ----------------------------------------------------------------------
	
	local Channels = {}
	
	net.Receive("gmm_radio_Play", function()
		local Ent   = net.ReadEntity()
		local Track = net.ReadString()
		
		if not IsValid(Ent) then return end
		
		if not Channels[Ent] and not IsValid(Channels[Ent]) then
			Channels[Ent] = {
				["Current"] = ""
			}
		end
		
		local CurrentTrack = Channels[Ent]["Current"]
		
		if CurrentTrack == Track then return end
		Channels[Ent]["Current"] = Track
		
		local Hook = "gmm_radio_Think_" .. Ent:EntIndex()
		hook.Remove("Think", Hook)
		
		if Track == "" then
			if Channels[Ent][CurrentTrack] and IsValid(Channels[Ent][CurrentTrack]) then
				Channels[Ent][CurrentTrack]:Pause()
			end
			
			return
		end
		
		local Channel = Channels[Ent][Track]
		
		local PlayChannel = function()
			Channel:SetPos(Ent:GetPos())
			Channel:SetVolume(Ent:GetPrikolLoud() and 2000 or 5)
			Channel:Play()

			hook.Add("Think", Hook, function()
				if not Channel or not IsValid(Channel) then return end
				
				-- похуй, я заебался, пусть память засерают треки
				if not Ent or not IsValid(Ent) then
					hook.Remove("Think", Hook)
					Channel:Stop()
					return
				end
				Channel:SetPos(Ent:GetPos())
			end)
		end
		
		if Channel == nil then
			sound.PlayURL(Track, "3d noblock", function(Channel__, eID, e)
				if IsValid(Channel__) then
					Channels[Ent][Track] = Channel__
					Channel = Channel__
					
					Channel:EnableLooping(true)
					
					PlayChannel()
				else
					print("[GMM] [RADIO] ERROR PLAYING TRACK [" .. Track .. "]!", eID, e)
				end
			end)
		else
			PlayChannel()
		end
	end)
end