AddCSLuaFile()

ENT.Type	  = "nextbot"
ENT.Base	  = "base_nextbot"
ENT.PrintName = "TOILET LIVING MAN"
ENT.Author	= "Woowz11"
ENT.Category  = "GMM"
ENT.Spawnable = GMM["Valid"]

local Names = {
	"Toilet Man","John","Gregory","Barry","Steve","Harold","Gerald","Clive","Nigel","Desmond",
	"Mortimer","Archibald","Reginald","Winston","Hubert","Milton","Oswald","Rupert","Cecil","Edgar",
	"Government Man","CEO","Businessman","Epstein","Gold","White","Diamond","Bert","Fish",
	"Man From 3 Letter Agencies","Gregory Mannstein","CIA","FBA","Policeman","Fishman","Banker",
	"Chairman Flush","Executive Porcelain","Boardroom Bog","Director Dunny","President Piss",
	"Manager Midden","Senior Shitter","Chief Toilet Officer","CTO","CEO of Waste","VP of Plumbing",
	"Head of Hygiene","Sanitation Supervisor","Privy Councillor","Latrine Lord","Crapper King",
	"Loo Tenant","Restroom Baron","Bathroom Broker","Toilet Tycoon","Porcelain Partner",
	"Ceramic Consultant","Urinal Executive","Stall Strategist","Bowl Boss","Tank Director",
	"Seat Supervisor","Flush Fund Manager","Pipe President","Drain Director","Cistern Chief",
	"Plunger Partner","Bidet Broker","Outhouse Officer","Commode Commander","Potty President",
	"Waste Manager","Sewer Supervisor","Cesspool CEO","Dung Director",
	"Mr. Sterling","Mr. Blackwood","Mr. Ashford","Mr. Wentworth","Mr. Kingsley","Mr. Pemberton",
	"Mr. Whitmore","Mr. Sinclair","Mr. Harrington","Mr. Fitzgerald","Mr. Chamberlain",
	"Mr. Montgomery","Mr. Ellsworth","Mr. Balthazar","Mr. Cornelius","Mr. Percival","Mr. Leopold",
	"Mr. Bartholomew","Mr. Theodore","Mr. Maximilian",
	"Agent","The Agent","Agent Smith","Agent Brown","Agent Green","Agent Black","Agent Grey",
	"Agent White","Agent Red","Agent Blue","Agent Orange","Agent Purple","Agent Pink","Agent Cyan",
	"Agent Magenta",
	"FBI","NSA","MI6","KGB","FSB","GRU","SVR","MSS","DGSE","BND","Mossad","Interpol",
	"Homeland","Pentagon","White House","Kremlin","Langley",
	"The Company","The Firm","The Bureau","The Agency","The Department","The Office","The Division",
	"The Section","The Branch","The Unit","The Cell","The Group","The Team","The Squad",
	"The Task Force","The Commission","The Committee","The Council","The Board","The Panel",
	"The Syndicate","The Consortium","The Cartel","The Mafia","The Mob","The Family",
	"The Organization","The Corporation","The Enterprise","The Company Man","The Suit","The Man",
	"The Guy","The Dude","The Fellow","The Gentleman","The Chap","The Bloke","The Lad","The Geezer",
	"The Fella","The Person","The Individual","The Entity","The Being","The Figure","The Character",
	"The Player","The Operator","The Handler","The Asset","The Source","The Contact","The Informant",
	"The Witness","The Suspect","The Target","The Mark","The Client","The Customer","The Buyer",
	"The Seller","The Dealer","The Broker","The Trader","The Merchant","The Vendor","The Supplier",
	"The Distributor","The Manufacturer","The Producer","The Creator","The Maker","The Builder",
	"The Founder","The Owner","The Proprietor","The Shareholder","The Investor","The Stakeholder",
	"The Partner","The Associate","The Colleague","The Coworker","The Employee","The Worker",
	"The Laborer","The Staff","The Crew","The Gang","The Posse","The Entourage","The Retinue",
	"The Escort","The Guard","The Security","The Bodyguard","The Protector","The Defender",
	"The Guardian","The Watcher","The Observer","The Overseer","The Supervisor","The Manager",
	"The Director","The Executive","The Officer","The Official","The Administrator","The Bureaucrat",
	"The Politician","The Diplomat","The Ambassador","The Consul","The Envoy","The Emissary",
	"The Representative","The Delegate","The Deputy","The Assistant","The Secretary","The Clerk",
	"The Receptionist","The Intern","The Trainee","The Apprentice","The Novice","The Rookie",
	"The Amateur","The Professional","The Expert","The Specialist","The Consultant","The Advisor",
	"The Counselor","The Mentor","The Coach","The Trainer","The Instructor","The Teacher",
	"The Professor","The Doctor","The Lawyer","The Judge","The Jury","The Prosecutor",
	"The Defendant","The Plaintiff","The Witness","The Bailiff","The Sheriff","The Marshal",
	"The Ranger","The Trooper","The Officer","The Detective","The Inspector","The Constable",
	"The Warden","The Jailer","The Executioner","The Hangman","The Butcher","The Baker",
	"The Candlestick Maker","The Plumber","The Electrician","The Carpenter","The Mason",
	"The Welder","The Mechanic","The Engineer","The Architect","The Designer","The Artist",
	"The Painter","The Sculptor","The Musician","The Singer","The Dancer","The Actor",
	"The Director","The Producer","The Writer","The Author","The Poet","The Journalist",
	"The Reporter","The Anchor","The Host","The Presenter","The Commentator","The Analyst",
	"The Strategist","The Tactician","The Planner","The Coordinator","The Organizer",
	"The Facilitator","The Mediator","The Negotiator","The Arbitrator","The Judge","The Referee",
	"The Umpire","The Official","The Commissioner","The Chairman","The President",
	"The Prime Minister","The Chancellor","The Premier","The Monarch","The King","The Queen",
	"The Prince","The Princess","The Duke","The Duchess","The Earl","The Count","The Baron",
	"The Knight","The Squire","The Page","The Herald","The Scribe","The Scholar","The Sage",
	"The Philosopher","The Thinker","The Genius","The Prodigy","The Mastermind","The Puppeteer",
	"The Manipulator","The Schemer","The Plotter","The Conspirator","The Traitor","The Spy",
	"The Assassin","The Mercenary","The Soldier","The Warrior","The Fighter","The Brawler",
	"The Boxer","The Wrestler","The Martial Artist","The Ninja","The Samurai","The Ronin",
	"The Shogun","The Daimyo","The Emperor","The Shogun","The Sensei","The Master",
	"The Grandmaster","The Legend","The Myth","The Icon","The Idol","The Hero","The Villain",
	"The Antihero","The Protagonist","The Antagonist","The Narrator","The Audience",
	"The Spectator","The Bystander","The Witness","The Participant","The Player","The Pawn",
	"The King","The Queen","The Rook","The Bishop","The Knight","The Gambler","The Joker",
	"The Fool","The Clown","The Jester","The Bard","The Minstrel","The Troubadour",
	"The Wanderer","The Traveler","The Explorer","The Adventurer","The Pioneer","The Settler",
	"The Colonist","The Immigrant","The Refugee","The Exile","The Outcast","The Hermit",
	"The Recluse","The Loner","The Drifter","The Nomad","The Vagabond","The Tramp","The Hobo",
	"The Beggar","The Pauper","The Peasant","The Serf","The Slave","The Servant","The Butler",
	"The Maid","The Cook","The Chef","The Waiter","The Bartender","The Bouncer","The Doorman",
	"The Valet","The Chauffeur","The Driver","The Pilot","The Captain","The Admiral",
	"The General","The Colonel","The Major","The Captain","The Lieutenant","The Sergeant",
	"The Corporal","The Private","The Recruit","The Veteran","The Rookie","The Legend",
	"The Ghost","The Phantom","The Specter","The Wraith","The Shadow","The Shade","The Spirit",
	"The Soul","The Essence","The Being","The Entity","The Presence","The Force","The Power",
	"The Energy","The Vibe","The Aura","The Essence","The Core","The Heart","The Mind",
	"The Body","The Spirit","The Trinity","The One","The All","The Everything","The Nothing",
	"The Void","The Abyss","The Chaos","The Order","The Balance","The Harmony","The Dissonance",
	"The Discord","The Silence","The Noise","The Sound","The Voice","The Echo","The Whisper",
	"The Shout","The Scream","The Cry","The Laugh","The Tear","The Smile","The Frown",
	"The Gaze","The Stare","The Glance","The Look","The Sight","The Vision","The Dream",
	"The Nightmare","The Reality","The Illusion","The Truth","The Lie","The Secret",
	"The Mystery","The Enigma","The Puzzle","The Riddle","The Question","The Answer",
	"The Solution","The Problem","The Challenge","The Test","The Trial","The Ordeal",
	"The Journey","The Quest","The Mission","The Task","The Goal","The Purpose","The Meaning",
	"The Reason","The Cause","The Effect","The Result","The Consequence","The Outcome",
	"The Conclusion","The End","The Beginning","The Middle","The Alpha","The Omega",
	"Klaus Schwab","Mikhail Khodorkovskiy","Sora","Notch","Soros","Bill","Bill Gates","Gustavo",
	"Anatoliy","Trump","Biden","Local","Host","Admin","Administrator","Tyler Durden",
	"Terry A Davis","Brad Pitt","Ryan Gosling","Morgan Freeman","Freeman","Goldman","Silverman",
	"Bronzeman","Acid","Hitman","Killer","Murder","Day","Bombom","Mr. Murder","Mr. Doc","Doc",
	"Document","NPC","Alive Human","Humanoid","GOLU Fan","Cultist","Accountant","Developer",
	"Dev","Operator","Developer VALVE","Developer W-City","Developer WoowzCore",
	"Developer GOLUWorld","Developer PeoplePlayground","Mobile Developer","AD","Zog","Jew",
	"Kyle","Eric","Stan","Kenny","Butters","Butt","You","Welcome here!","Mingebag","Hello",
	"Welcome","Hi","128","Scientist","Archaeologist","Watermelon","Armenian","American Man",
	"Putin","Clinton","God","Allah","Budda","Nazar","Brat","Bro","Dr. House","House","Chaos",
	"Dr. Chaos","Dr. White","Dr. Doc","Solder","Captain","Money","Rubby","Emerald","Lapis",
	"Topaz","Ametist","Opal","Saphire","Quartz","Lua","Moon","Luna","Keyboard Developer",
	"Computer","AI","Network","Discord Mod.","Bot","Greetings","Programmer","Exe File","Matrix",
	"Architect","Matrix Architect","Melon","Brick","Brickwall","The Gun","AK-47","Arab",
	"Ilone Mask","Elone Mask","A-Xi","Car","Sportcar","Sportman","Muscle Man","Snowman",
	"Coca-Man","Drugman","Adolve","Junky","Jenky","Junke","Junkie","Pie","Dir","Dire","Die",
	"Corpse","Living Corpse","Alive Person","Person","Person II","Travis VI",
	"Person One Experiment","Experiment","Web Dev.","Trollface","Grifer","Door","MCreator Dev.",
	"Pylo","Pavel","Pisechnik","Mer","Mayor","Mayo","Candy","Lipstick","Fly","Cockroach","Rock",
	"Roach","Cock","Dog","Math","Sorry","I am Busy","Cashier","Важный хуй бумажный","Error",
	"Invalid","Undefined","Null","Nil","Empty","Java","The Enjoy","Emo","Free Trial","Free",
	"Apple","String","Libre","Linux","Window","Clause","Clown","Claude","Clark","Klark","Kar",
	"Blood","Blark","Fire","Explosion","Boom","Start","Star","Stop","Superstar","YouTuber",
	"TikToker","Influencer","Fluorography","Nicotine","Acid","Superman","Lowman","Highman",
	"Trashman","Hiway","Hay","Hiveman","Bedwars","Bee","Bee Lowston",
	"John Makedonsky Lev Empiro Velikiy VII 6 v Pokolenii","Tsar","King","Burger","Buffer",
	"FrameBuffer","Sangwich","Sand","Freesh Meat","Meat","'She'","Brigadir","GitHub","Git",
	"Application","Case","Safe","Save","Tablet","Copro","Strim","Steam","Gabe","Lebovsky","Sky",
	"Skynet","Rocket","Country","Credit","Credit Card","I got Credit","Skrepka","Woowz","Warning",
	"Flashbank","Qwerty","xD",":)",":(",":|",":/",">:(",":O","-_-","o_o","Atom",
	"Nuclear Power Plant","Follow","Subscriber","License","Man","Woman","Ageeent","Entity",
	"Tryapka","GMan","Boss","Big Boss","Small Boss","Boss Boss","Perftest","Model","Thief",
	"Crime","Lord","Big One","Last","Teeth","Costume","Virus","Sun","Malware","FPS","Content",
	"Token","Tolkien","Plastic Box","Chair","Go Away","Fuck","Gigabyte","CPU","GPU","Anton",
	"Crash","The Crash","Goldsource","Crybird","LIT","Glass Bottle","Cup","Enum","Variable",
	"Value","JavaScript","Rust","Python","CSharp","C++","Lua?","1 Goal","Football","Cancel",
	"Accept","Mr. Pen","Mr. Pencil","Mr. Ink","Homeless","Plankton","Eye","GG","Hammer",
	"Hammer++","Weird","OpenGL Coder","Coder","Vulkan Coder","Skeleton","Bones","Boner","Pups",
	"Map Author","Author","Cat Fan","Hot","Cold","Warm","Ivan","Ilyasikdum","Have a Nice Day",
	"Have a Bad Day","Like","Tea Fan","Green Tea","I'M WATCHING YOU","Next Please","DarkRP",
	"Porn Actor","Pornstar","Family Guy","Guy","Who is At?","I Dont Know","Where I Am?",
	"Sniper","Miner","The Lie","Paper","Cardboard","Shit"
}

local Texture_Case = {
	"woowz_map/gm_garrymod_map_by_woowz_map_garry_game/model/toiletman/case1",
	"woowz_map/gm_garrymod_map_by_woowz_map_garry_game/model/toiletman/case2",
	"woowz_map/gm_garrymod_map_by_woowz_map_garry_game/model/toiletman/case3",
	"woowz_map/gm_garrymod_map_by_woowz_map_garry_game/model/toiletman/case4",
	"woowz_map/gm_garrymod_map_by_woowz_map_garry_game/model/toiletman/case5",
}

local Texture_Costume = {
	{
		"perftest/gman/gman_back2","perftest/gman/gman_pantsbck1","perftest/gman/gman_barm-1",
		"perftest/gman/gman_suittop2","perftest/gman/gman_pelvis1","perftest/gman/gman_collar1",
		"perftest/gman/gman_arm-r1","perftest/gman/gman_shin1","perftest/gman/gman_arm-l1",
		"perftest/gman/gman_pantsbtm1","perftest/gman/gman_slvtip1"
	},
	{
		"woowz_map/gm_garrymod_map_by_woowz_map_garry_game/model/toiletman/costume1_back",
		"woowz_map/gm_garrymod_map_by_woowz_map_garry_game/model/toiletman/costume1_pants",
		"woowz_map/gm_garrymod_map_by_woowz_map_garry_game/model/toiletman/costume1_arm",
		"woowz_map/gm_garrymod_map_by_woowz_map_garry_game/model/toiletman/costume1_front",
		"woowz_map/gm_garrymod_map_by_woowz_map_garry_game/model/toiletman/costume1_pelvis",
		"woowz_map/gm_garrymod_map_by_woowz_map_garry_game/model/toiletman/costume1_collar",
		"woowz_map/gm_garrymod_map_by_woowz_map_garry_game/model/toiletman/costume1_armr",
		"woowz_map/gm_garrymod_map_by_woowz_map_garry_game/model/toiletman/costume1_shin",
		"woowz_map/gm_garrymod_map_by_woowz_map_garry_game/model/toiletman/costume1_arml",
		"woowz_map/gm_garrymod_map_by_woowz_map_garry_game/model/toiletman/costume1_pantsbottom",
		"woowz_map/gm_garrymod_map_by_woowz_map_garry_game/model/toiletman/costume1_slvtip"
	},
	{
		"woowz_map/gm_garrymod_map_by_woowz_map_garry_game/model/toiletman/costume1_back",
		"woowz_map/gm_garrymod_map_by_woowz_map_garry_game/model/toiletman/costume1_pants",
		"woowz_map/gm_garrymod_map_by_woowz_map_garry_game/model/toiletman/costume1_arm",
		"woowz_map/gm_garrymod_map_by_woowz_map_garry_game/model/toiletman/costume2_front",
		"woowz_map/gm_garrymod_map_by_woowz_map_garry_game/model/toiletman/costume1_pelvis",
		"woowz_map/gm_garrymod_map_by_woowz_map_garry_game/model/toiletman/costume1_collar",
		"woowz_map/gm_garrymod_map_by_woowz_map_garry_game/model/toiletman/costume1_armr",
		"woowz_map/gm_garrymod_map_by_woowz_map_garry_game/model/toiletman/costume1_shin",
		"woowz_map/gm_garrymod_map_by_woowz_map_garry_game/model/toiletman/costume1_arml",
		"woowz_map/gm_garrymod_map_by_woowz_map_garry_game/model/toiletman/costume1_pantsbottom",
		"woowz_map/gm_garrymod_map_by_woowz_map_garry_game/model/toiletman/costume1_slvtip"
	},
	{
		"perftest/gman/gman_back2","perftest/gman/gman_pantsbck1","perftest/gman/gman_barm-1",
		"woowz_map/gm_garrymod_map_by_woowz_map_garry_game/model/toiletman/costume3_front",
		"perftest/gman/gman_pelvis1","perftest/gman/gman_collar1","perftest/gman/gman_arm-r1",
		"perftest/gman/gman_shin1","perftest/gman/gman_arm-l1","perftest/gman/gman_pantsbtm1",
		"perftest/gman/gman_slvtip1"
	},
	{
		"woowz_map/gm_garrymod_map_by_woowz_map_garry_game/model/toiletman/costume1_back",
		"woowz_map/gm_garrymod_map_by_woowz_map_garry_game/model/toiletman/costume1_pants",
		"woowz_map/gm_garrymod_map_by_woowz_map_garry_game/model/toiletman/costume1_arm",
		"woowz_map/gm_garrymod_map_by_woowz_map_garry_game/model/toiletman/costume4_front",
		"woowz_map/gm_garrymod_map_by_woowz_map_garry_game/model/toiletman/costume1_pelvis",
		"woowz_map/gm_garrymod_map_by_woowz_map_garry_game/model/toiletman/costume1_collar",
		"woowz_map/gm_garrymod_map_by_woowz_map_garry_game/model/toiletman/costume1_armr",
		"woowz_map/gm_garrymod_map_by_woowz_map_garry_game/model/toiletman/costume1_shin",
		"woowz_map/gm_garrymod_map_by_woowz_map_garry_game/model/toiletman/costume1_arml",
		"woowz_map/gm_garrymod_map_by_woowz_map_garry_game/model/toiletman/costume1_pantsbottom",
		"woowz_map/gm_garrymod_map_by_woowz_map_garry_game/model/toiletman/costume1_slvtip"
	},
}

local Texture_Shoe = {
	{ "perftest/gman/gman_shoe1", "perftest/gman/gman_footbtm1" },
	{
		"woowz_map/gm_garrymod_map_by_woowz_map_garry_game/model/toiletman/shoe1",
		"woowz_map/gm_garrymod_map_by_woowz_map_garry_game/model/toiletman/shoe1_bottom"
	}
}

local RareModels = {
	"models/player/soldier_stripped.mdl",
	"models/characters/counterterrorist.mdl",
	"models/editor/playerstart.mdl",
	"models/humans/charple02.mdl",
	"models/Humans/Charple01.mdl",
	"models/player/corpse1.mdl",
	"models/humans/group01/male_cheaple.mdl",
	"models/items/hevsuit.mdl",
	"models/player/skeleton.mdl",
	"models/zombie/fast.mdl",
	"models/zombie/zombie_soldier.mdl",
	"models/zombie/classic.mdl",
	"models/player/pissbaby.mdl",
	"models/player/t_leet.mdl",
	"models/magnusson.mdl",
	"models/shadertest/vertexlitbumpedtexturewithselfillum.mdl",
	"models/shadertest/vertexlitenvmappedbumpmap.mdl",
	"models/shadertest/vertexlittextureplusmaskedenvbump.mdl",
	"models/zombie/poison.mdl",
	"models/gman_high.mdl"
}

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "IsMoving")
	self:NetworkVar("Bool", 1, "IsPanicking")
	self:NetworkVar("Bool", 2, "Init")

	self:NetworkVar("Int", 0, "RunSpeed")
	self:NetworkVar("Int", 1, "NameColorR")
	self:NetworkVar("Int", 2, "NameColorG")
	self:NetworkVar("Int", 3, "NameColorB")
	self:NetworkVar("Int", 4, "TextureCase")
	self:NetworkVar("Int", 5, "TextureCostume")
	self:NetworkVar("Int", 6, "TextureShoe")
	self:NetworkVar("Int", 7, "RareModel")
	self:NetworkVar("Int", 8, "PushForce")

	self:NetworkVar("String", 0, "BotName")
end

function ENT:Initialize()
	local Init = SERVER and self:GetInit() or false
	
	self:SetModel("models/perftest/gman.mdl")

	if SERVER then
		self:SetIsMoving(true)
		self:SetMaxHealth(100)
		self:SetHealth(100)
		self:SetBloodColor(BLOOD_COLOR_MECH)

		self:SetIsPanicking(false)

		if not Init then
			self:SetBotName(Names[math.random(#Names)])
			self:SetNameColorR(math.random(100, 255))
			self:SetNameColorG(math.random(100, 255))
			self:SetNameColorB(math.random(100, 255))
			self:SetRunSpeed(math.random(30, 200))
			self:SetPushForce(math.random(0, 1000))
		end

		self:SetCollisionBounds(Vector(-4, -4, 0), Vector(4, 4, 65))
		self:SetCustomCollisionCheck(true)

		self.loco:SetDesiredSpeed(self:GetRunSpeed())
		self.loco:SetAcceleration(400)
		self.loco:SetDeceleration(400)
		self.loco:SetStepHeight(18)
		self.loco:SetJumpHeight(90)

		self.NextJumpTime	  = 0
		self.NextObstacleCheck = 0
		self.NextPushTime	  = 0
		self.PushCooldown	  = 0.5
		self.LastPos		   = self:GetPos()
		self.LastPosTime	   = CurTime()
		self.StuckThreshold	= 3
		self.NextTeleportTime  = 0
		self.TeleportCooldown  = 2
		self.NextRestTime	  = CurTime() + math.random(15, 40)
		self.NextFootstepTime  = 0
		self.NextRandomTeleportCheck = CurTime() + math.random(10, 30)
		self.PathTimeout = 15
		self.PathStartTime = 0
		self.NextGroundFix = 0

		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:PhysicsInit(SOLID_BBOX)
		self:SetSolid(SOLID_BBOX)
		self:SetCollisionGroup(COLLISION_GROUP_NPC)

		local Phys = self:GetPhysicsObject()
		if IsValid(Phys) then
			Phys:Wake()
			Phys:EnableGravity(true)
			Phys:SetMass(80)
			Phys:SetMaterial("metal")
		end

		local RareModelIndex = self:GetRareModel() or 0

		if SERVER and not Init then
			if math.random() > 0.95 then
				self:SetRareModel(math.random(1, #RareModels))
			end

			if self:GetRareModel() == 0 then
				self:SetTextureCase(math.random(1, #Texture_Case))
				self:SetTextureCostume(math.random(1, #Texture_Costume))
				self:SetTextureShoe(math.random(1, #Texture_Shoe))
			end

			RareModelIndex = self:GetRareModel()
		end

		local ModelPath = (RareModelIndex == 0) and "models/perftest/gman.mdl" or RareModels[RareModelIndex]
		self:SetModel(ModelPath)

		if RareModelIndex == 13 then self:SetSkin(1) end

		timer.Simple(0, function()
			if not IsValid(self) then return end
			self:SnapToGround()

			if self:GetRareModel() == 0 then
				self:SetSubMaterial(19, Texture_Case[self:GetTextureCase()])

				local Costume = Texture_Costume[self:GetTextureCostume()]
				self:SetSubMaterial(0 , Costume[1 ])
				self:SetSubMaterial(1 , Costume[2 ])
				self:SetSubMaterial(3 , Costume[3 ])
				self:SetSubMaterial(4 , Costume[4 ])
				self:SetSubMaterial(5 , Costume[5 ])
				self:SetSubMaterial(8 , Costume[6 ])
				self:SetSubMaterial(10, Costume[7 ])
				self:SetSubMaterial(11, Costume[8 ])
				self:SetSubMaterial(12, Costume[9 ])
				self:SetSubMaterial(17, Costume[10])
				self:SetSubMaterial(18, Costume[11])

				local Shoe = Texture_Shoe[self:GetTextureShoe()]
				self:SetSubMaterial(6 , Shoe[1])
				self:SetSubMaterial(13, Shoe[2])
			end
		end)

		self:SetInit(true)
	end
end

if SERVER then
	local function IsToiletMan(Ent)
		return IsValid(Ent) and Ent:GetClass() == "gmm_toiletman"
	end
	
	local MAX_WORLD_DIST = 20000
	local MIN_WORLD_Z	 = -16000
	local MAX_WORLD_Z	 = 16000

	local function IsReasonablePos(Pos)
		if not Pos then return false end
		if not util.IsInWorld(Pos) then return false end
		if Pos.z < MIN_WORLD_Z or Pos.z > MAX_WORLD_Z then return false end
		if math.abs(Pos.x) > MAX_WORLD_DIST or math.abs(Pos.y) > MAX_WORLD_DIST then return false end
		return true
	end

	function ENT:SnapToGround()
		local mins, maxs = self:GetCollisionBounds()
		if not mins or not maxs then return false end

		local Pos = self:GetPos()
		local Tr = util.TraceHull({
			start  = Pos + Vector(0, 0, 8),
			endpos = Pos - Vector(0, 0, 500),
			filter = self,
			mins   = mins + Vector(1, 1, 0),
			maxs   = maxs - Vector(1, 1, 0.1),
			mask   = MASK_NPCSOLID
		})

		if not Tr.Hit or Tr.StartSolid then return false end

		local NewPos = Tr.HitPos - Vector(0, 0, mins.z)
		if not IsReasonablePos(NewPos) then return false end

		self:SetPos(NewPos)
		self.IsJumping = false
		self:SetLocalVelocity(Vector(0, 0, 0))
		return true
	end

	    function ENT:FixStuckInGeometry()
        local mins, maxs = self:GetCollisionBounds()
        if not mins or not maxs then return end

        local Pos = self:GetPos()
        if not IsReasonablePos(Pos) then
            self:TeleportToRandomNavArea()
            return
        end

        local Tr = util.TraceHull({
            start  = Pos,
            endpos = Pos,
            filter = self,
            mins   = mins,
            maxs   = maxs,
            mask   = MASK_NPCSOLID
        })

        if not Tr.StartSolid then return end

        for z = 8, 128, 8 do
            local TestPos = Pos + Vector(0, 0, z)
            if not IsReasonablePos(TestPos) then break end

            local Check = util.TraceHull({
                start  = TestPos,
                endpos = TestPos,
                filter = self,
                mins   = mins,
                maxs   = maxs,
                mask   = MASK_NPCSOLID
            })
            if not Check.StartSolid then
                self:SetPos(TestPos)
                self:SetLocalVelocity(Vector(0, 0, 0))
                self:SnapToGround()
                return
            end
        end

        self:TeleportToRandomNavArea()
    end

	function ENT:IsWallAhead()
		local StartPos = self:GetPos() + Vector(0, 0, 30)
		local Tr = util.TraceHull({
			start  = StartPos,
			endpos = StartPos + self:GetForward() * 35,
			filter = self,
			mins   = Vector(-8, -8, -8),
			maxs   = Vector(8, 8, 8),
			mask   = MASK_NPCSOLID
		})

		if not Tr.Hit then return false, nil end
		if IsToiletMan(Tr.Entity) then return false, Tr end
		return Tr.HitNormal.z < 0.5, Tr
	end

	function ENT:CheckAndRest()
		if self:IsResting() then return true end
		if self:GetIsPanicking() then return false end
		if CurTime() < self.NextRestTime then return false end

		self.RestUntil = CurTime() + math.random(3, 8)
		self.NextRestTime = self.RestUntil + math.random(20, 50)
		return true
	end

	function ENT:IsResting()
		return self.RestUntil and CurTime() < self.RestUntil
	end

	function ENT:EndRest()
		self.RestUntil = nil
		self.loco:SetDesiredSpeed(self:GetRunSpeed())
		self:StartActivity(self:GetIsMoving() and ACT_WALK or ACT_IDLE)
	end

	function ENT:KeepUpright()
		local Ang = self:GetAngles()
		Ang.p = 0
		Ang.r = 0
		self:SetAngles(Ang)
	end

	function ENT:OnInjured(dmg)
		local Attacker = dmg:GetAttacker()
		if GetConVar("ai_ignoreplayers"):GetBool() and IsValid(Attacker) and Attacker:IsPlayer() then return end

		if dmg:IsDamageType(DMG_BULLET) then
			self:EmitSound("physics/metal/metal_solid_impact_bullet" .. math.random(1, 4) .. ".wav", 75, 100)
		end

		self.LastAttacker = Attacker
		self:SetIsPanicking(true)
		self.PanicEndTime = CurTime() + 12

		self.loco:SetDesiredSpeed(math.random(260, 320))
		self:EmitSound("npc/headcrab/pain" .. math.random(1, 3) .. ".wav", 90, math.random(70, 90))
		self:EmitSound("physics/metal/metal_box_impact_hard" .. math.random(1, 3) .. ".wav", 80, math.random(90, 110))

		local effectdata = EffectData()
		effectdata:SetOrigin(dmg:GetDamagePosition())
		effectdata:SetNormal(dmg:GetDamageForce():GetNormalized() * -1)
		effectdata:SetMagnitude(2)
		effectdata:SetScale(1)
		util.Effect("ManhackSparks", effectdata)
	end

	function ENT:FleeFromAttacker()
		if not self:GetIsPanicking() then return end
		if CurTime() < (self.NextFleePathTime or 0) then return end
		self.NextFleePathTime = CurTime() + 0.5

		local Target = self.LastAttacker
		if not IsValid(Target) or (Target:IsPlayer() and not Target:Alive()) then
			local dist = 999999
			for _, p in ipairs(player.GetAll()) do
				local d = self:GetPos():DistToSqr(p:GetPos())
				if d < dist then dist = d; Target = p end
			end
		end

		if not IsValid(Target) then return end

		local AwayDir = (self:GetPos() - Target:GetPos()):GetNormalized()
		AwayDir.z = 0
		self.FleeTarget = self:GetPos() + AwayDir * 500 + VectorRand() * 100
	end

	function ENT:OnKilled(dmg)
		if self.Died then return end
		self.Died = true

		local Pos = self:GetPos() + Vector(0, 0, 30)

		if math.random() > 0.2 then
			local Prop = ents.Create("prop_physics")
			if IsValid(Prop) then
				local DropProps = {
					"models/props_c17/BriefCase001a.mdl",
					"models/props_c17/SuitCase001a.mdl",
					"models/props_c17/SuitCase_Passenger_Physics.mdl",
					"models/props/cs_assault/money.mdl",
					"models/props_combine/breenclock.mdl",
					"models/props_lab/clipboard.mdl",
					"models/props_junk/garbage_coffeemug001a.mdl",
					"models/props_junk/PopCan01a.mdl",
					"models/props_junk/garbage_newspaper001a.mdl",
					"models/props_lab/binderredlabel.mdl",
					"models/props_trainstation/payphone_reciever001a.mdl",
					"models/weapons/w_package.mdl",
					"models/props_lab/huladoll.mdl",
					"models/props_lab/desklamp01.mdl",
					"models/props_junk/watermelon01_chunk01c.mdl",
					"models/food/burger.mdl",
					"models/food/hotdog.mdl",
					"models/maxofs2d/balloon_gman.mdl",
					"models/dav0r/tnt/tnttimed.mdl",
					"models/maxofs2d/hover_rings.mdl",
					"models/props_phx/misc/potato_launcher_explosive.mdl",
					"models/props_phx/misc/potato.mdl",
					"models/xqm/hydcontrolbox.mdl",
					"models/mechanics/various/211.mdl",
					"models/props_phx/misc/fender.mdl",
					"models/props_phx/misc/egg.mdl",
					"models/maxofs2d/camera.mdl",
					"models/props_c17/cashregister01a.mdl",
					"models/props_c17/doll01.mdl",
					"models/props_combine/breenbust.mdl",
					"models/props_junk/Shovel01a.mdl",
					"models/props_c17/tools_wrench01a.mdl",
					"models/props_lab/binderblue.mdl",
					"models/props_lab/binderbluelabel.mdl",
					"models/props_lab/bindergraylabel01a.mdl",
					"models/props_lab/bindergreen.mdl",
					"models/props_lab/bindergraylabel01b.mdl",
					"models/props_lab/bindergreenlabel.mdl",
					"models/props_junk/watermelon01.mdl",
					"models/props_lab/cactus.mdl",
					"models/props_lab/harddrive01.mdl",
					"models/props_c17/computer01_keyboard.mdl",
					"models/props_junk/Shoe001a.mdl",
					
					"!weapon_crowbar",
					"!weapon_frag",
					"!weapon_pistol",
					"!weapon_stunstick",
					"!weapon_357",
					"!weapon_smg1",
					"!weapon_bugbait",
					"!weapon_slam",
					"!weapon_physgun",
					"!weapon_physcannon",
					"!gmm_tablet",
					"!npc_grenade_frag",
					"!combine_mine",
					"!item_healthvial",
					"!item_healthkit",
					"!item_battery",
					"!item_ammo_357",
					"!item_ammo_smg1",
					"!item_ammo_pistol",
					"!item_ammo_smg1_grenade",
					"!sent_ball",
					"!npc_antlion_grub",
					"!npc_manhack"
				}
				
				local Chosen = table.Random(DropProps)

				if Chosen:sub(1, 1) == "!" then
					local ClassName = Chosen:sub(2)
					local Spawned = ents.Create(ClassName)
					if IsValid(Spawned) then
						Spawned:SetPos(Pos)
						Spawned:SetAngles(Angle(0, math.random(0, 360), 0))
						Spawned:Spawn()
						Spawned:Activate()

						local Phys = Spawned:GetPhysicsObject()
						if IsValid(Phys) then
							Phys:Wake()
							Phys:ApplyForceCenter(Vector(math.random(-300, 300), math.random(-300, 300), 400))
							Phys:AddAngleVelocity(Vector(math.random(-200, 200), math.random(-200, 200), math.random(-200, 200)))
						end
					end
				else
					local Prop = ents.Create("prop_physics")
					if IsValid(Prop) then
						Prop:SetModel(Chosen)
						Prop:SetPos(Pos)
						Prop:SetAngles(Angle(0, math.random(0, 360), 0))
						Prop:Spawn()
						Prop:Activate()

						local Phys = Prop:GetPhysicsObject()
						if IsValid(Phys) then
							Phys:Wake()
							Phys:ApplyForceCenter(Vector(math.random(-300, 300), math.random(-300, 300), 400))
							Phys:AddAngleVelocity(Vector(math.random(-200, 200), math.random(-200, 200), math.random(-200, 200)))
						end
					end
				end
				end
		end

		local EffectData__ = EffectData()
		EffectData__:SetOrigin(Pos)
		EffectData__:SetScale(2)
		util.Effect("cball_explode", EffectData__)
		util.Effect("StriderSweep", EffectData__)

		local SparkData = EffectData()
		SparkData:SetOrigin(Pos)
		SparkData:SetNormal(Vector(0, 0, 1))
		SparkData:SetMagnitude(15)
		SparkData:SetScale(2)
		util.Effect("metal sparks", SparkData, true, true)

		sound.Play("npc/headcrab/pain" .. math.random(1, 3) .. ".wav", Pos, 90, math.random(70, 90))
		self:EmitSound("physics/metal/metal_box_break" .. math.random(1, 2) .. ".wav", 90, math.random(70, 90))
		self:EmitSound("ambient/energy/zap1.wav", 80, math.random(70, 90))

		local SelfRef = self
		timer.Simple(0.1, function()
			if IsValid(SelfRef) then SelfRef:Remove() end
		end)
	end

	function ENT:GetWallSlideDir(Tr)
		local Forward = self:GetForward()
		local Normal  = Tr.HitNormal
		Normal.z = 0
		Normal:Normalize()

		local Slide = Forward - Normal * Forward:Dot(Normal)
		Slide.z = 0

		if Slide:LengthSqr() < 0.001 then
			Slide = Vector(-Normal.y, Normal.x, 0)
			if math.random() < 0.5 then Slide = -Slide end
		end

		Slide:Normalize()
		return Slide
	end

	function ENT:PlayFootstep()
		if CurTime() < self.NextFootstepTime then return end

		local Speed = self:GetRunSpeed() or 100
		self.NextFootstepTime = CurTime() + math.Clamp(200 / Speed * 0.3, 0.3, 1.2)

		local StepNum = math.random(1, 4)
		local Tr = util.TraceLine({
			start = self:GetPos() + Vector(0, 0, 10),
			endpos = self:GetPos() - Vector(0, 0, 30),
			filter = self,
			mask = MASK_SOLID
		})

		local SoundPath = "npc/footsteps/hardboot_generic" .. StepNum .. ".wav"

		if Tr.Hit and Tr.SurfaceProps then
			local SurfaceName = util.GetSurfacePropName(Tr.SurfaceProps)
			local Map = {
				Concrete = "concrete", Tile = "concrete",
				Metal = "metal", MetalGrate = "metal", SolidMetal = "metal",
				Wood = "wood", Wood_Panel = "wood", Wood_Solid = "wood",
				Grass = "grass",
				Dirt = "dirt", Mud = "dirt",
				Sand = "sand",
				Water = "water", Wade = "water",
				Snow = "snow",
				Glass = "glass",
			}
			if Map[SurfaceName] then
				SoundPath = "player/footsteps/" .. Map[SurfaceName] .. StepNum .. ".wav"
			end
		end

		self:EmitSound(SoundPath, 65, math.random(95, 105))
	end

	-- Ищет безопасную точку на земле около TargetPos (или nil, если не нашёл)
	function ENT:FindSafeGroundPos(TargetPos)
		if not TargetPos or not util.IsInWorld(TargetPos) then return nil end
		if TargetPos.z < -10000 then return nil end

		local mins, maxs = self:GetCollisionBounds()
		if not mins or not maxs then
			mins = Vector(-4, -4, 0)
			maxs = Vector(4, 4, 65)
		end

		local Tr = util.TraceHull({
			start  = TargetPos + Vector(0, 0, 300),
			endpos = TargetPos - Vector(0, 0, 300),
			filter = self,
			mins   = mins,
			maxs   = maxs,
			mask   = MASK_NPCSOLID
		})

		if not Tr.Hit or Tr.StartSolid then return nil end

		local SpawnPos = Tr.HitPos - Vector(0, 0, mins.z)
		if not util.IsInWorld(SpawnPos) then return nil end
		return SpawnPos
	end

	function ENT:TeleportToRandomNavArea(TargetPos)
        local SpawnPos

        if TargetPos then
            SpawnPos = self:FindSafeGroundPos(TargetPos)
        else
            local Area = navmesh.GetNearestNavArea(self:GetPos(), false, 2000, true, true)
            if Area and Area:IsValid() then
                SpawnPos = self:FindSafeGroundPos(Area:GetRandomPoint())
            end
        end

        -- Fallback: если навмеша нет — пробуем случайную точку через GetAllNavAreas
        if not SpawnPos then
            local AllAreas = navmesh.GetAllNavAreas()
            if #AllAreas > 0 then
                for _ = 1, 10 do
                    local Area = AllAreas[math.random(#AllAreas)]
                    if Area and Area:IsValid() then
                        SpawnPos = self:FindSafeGroundPos(Area:GetRandomPoint())
                        if SpawnPos then break end
                    end
                end
            end
        end

        -- Совсем fallback: прижимаем к земле
        if not SpawnPos then
            self:SnapToGround()
            return
        end

        local E1 = EffectData()
        E1:SetOrigin(self:GetPos())
        E1:SetScale(1)
        util.Effect("cball_explode", E1)
        util.Effect("StriderSweep", E1)

        self:SetPos(SpawnPos)
        self:SetLocalVelocity(Vector(0, 0, 0))
        self:SetSequence(0)
        self:StartActivity(ACT_WALK)
		
		self.IsJumping = false

        self.LastPos     = SpawnPos
        self.LastPosTime = CurTime()

        local E2 = EffectData()
        E2:SetOrigin(SpawnPos)
        E2:SetScale(1)
        util.Effect("cball_explode", E2)
        util.Effect("StriderSweep", E2)
    end

	function ENT:TryRandomTeleport()
		if CurTime() < self.NextRandomTeleportCheck then return end
		self.NextRandomTeleportCheck = CurTime() + math.random(15, 40)

		if math.random(1, 20) ~= 1 then return end
		if not self:GetIsMoving() then return end

		local AllAreas = navmesh.GetAllNavAreas()
		if #AllAreas == 0 then return end

		local Area = AllAreas[math.random(#AllAreas)]
		if not Area or not Area:IsValid() then return end

		local TargetPos = Area:GetRandomPoint()
		if TargetPos:DistToSqr(self:GetPos()) < (500 * 500) then return end

		self:TeleportToRandomNavArea(TargetPos)
	end

	function ENT:CheckAndTeleportIfStuck()
		if CurTime() < self.NextTeleportTime then return end

		local CurPos = self:GetPos()
		local Dx, Dy = CurPos.x - self.LastPos.x, CurPos.y - self.LastPos.y
		if math.sqrt(Dx * Dx + Dy * Dy) > 5 then
			self.LastPos	 = CurPos
			self.LastPosTime = CurTime()
			return
		end

		local Vel = self:GetVelocity()
		if math.sqrt(Vel.x * Vel.x + Vel.y * Vel.y) < 10
		   and CurTime() - self.LastPosTime > self.StuckThreshold then
			if not self:SnapToGround() then
				self:TeleportToRandomNavArea()
			end
			self.NextTeleportTime = CurTime() + self.TeleportCooldown
			self.LastPos		  = self:GetPos()
			self.LastPosTime	  = CurTime()
		end
	end

	function ENT:PushAwayFromOtherToiletMen()
		local mins, maxs = self:GetCollisionBounds()
		if not mins or not maxs then return end

		for _, Other in ipairs(ents.FindInSphere(self:GetPos(), 50)) do
			if Other ~= self and IsToiletMan(Other) then
				local Diff = self:GetPos() - Other:GetPos()
				local Dist = Diff:Length()

				if Dist < 40 and Dist > 0 then
					Diff.z = 0
					Diff:Normalize()

					local NewPos = self:GetPos() + Diff * ((40 - Dist) * 0.5)
					local Tr = util.TraceHull({
						start  = NewPos,
						endpos = NewPos,
						filter = self,
						mins   = mins,
						maxs   = maxs,
						mask   = MASK_NPCSOLID
					})

					if not Tr.StartSolid then
						self:SetPos(NewPos)
						self:SnapToGround()
					end
				end
			end
		end
	end

	function ENT:HandleObstacles()
		local Tr = util.TraceHull({
			start  = self:GetPos() + Vector(0, 0, 40),
			endpos = self:GetPos() + Vector(0, 0, 40) + self:GetForward() * 35,
			filter = self,
			mins   = Vector(-12, -12, -20),
			maxs   = Vector(12, 12, 20),
			mask   = MASK_SHOT
		})

		local Ent = Tr.Entity
		if not IsValid(Ent) or IsToiletMan(Ent) then return end

		local Class = Ent:GetClass()

		if Class == "func_breakable_surf" then
			local Dmg = DamageInfo()
			Dmg:SetDamage(Ent:Health() + 10)
			Dmg:SetAttacker(self)
			Dmg:SetInflictor(self)
			Dmg:SetDamageType(DMG_CLUB)
			Dmg:SetDamagePosition(Tr.HitPos)
			Ent:TakeDamageInfo(Dmg)

			local Forward = self:GetForward()
			Ent:Fire("Shatter", Forward.x .. " " .. Forward.y .. " " .. Forward.z)
		elseif Class:find("breakable") then
			local Dmg = DamageInfo()
			Dmg:SetDamage(Ent:Health() + 10)
			Dmg:SetAttacker(self)
			Dmg:SetInflictor(self)
			Dmg:SetDamageType(DMG_CLUB)
			Dmg:SetDamagePosition(Tr.HitPos)
			Ent:TakeDamageInfo(Dmg)
			Ent:Fire("Shatter", "0.5 0.5 256")
			Ent:Fire("Break")
		elseif Class:find("button") then
			Ent:Fire("Use")
		elseif Class:find("door") then
			if GMM.Func.CanOpenDoor(Ent) then
				Ent:Fire("Use")
				Ent:Fire("Open")
			end
		elseif Class == "prop_physics" then
			Ent:Fire("Use")
			local Phys = Ent:GetPhysicsObject()
			if IsValid(Phys) then
				Phys:ApplyForceCenter(self:GetForward() * 8000)
			end
		end
	end

		-- Прыжок через препятствие + возврат анимации после приземления
	function ENT:HandleJump()
		-- Если бот в прыжке и уже приземлился — вернуть анимацию ходьбы
		if self.IsJumping and self:IsOnGround() then
			self.IsJumping = false
			if self:GetIsMoving() then
				self:StartActivity(ACT_WALK)
			else
				self:StartActivity(ACT_IDLE)
			end
		end

		if self:IsResting() or not self:IsOnGround() then return end
		if CurTime() < self.NextJumpTime then return end
		if self.IsJumping then return end

		local StartPos = self:GetPos() + Vector(0, 0, 10)
		local Tr = util.TraceHull({
			start  = StartPos,
			endpos = StartPos + self:GetForward() * 35,
			filter = self,
			mins   = Vector(-6, -6, -6),
			maxs   = Vector(6, 6, 6),
			mask   = MASK_NPCSOLID
		})

		if Tr.Hit and Tr.HitNormal.z < 0.4 and not IsToiletMan(Tr.Entity)
		   and not (IsValid(Tr.Entity) and Tr.Entity:IsPlayer()) then
			self:StartActivity(ACT_JUMP)
			self.loco:Jump()
			self.NextJumpTime = CurTime() + 2
			self.IsJumping    = true
		end
	end

	-- Общая логика во время движения
	function ENT:CommonLogic()
		if not self:IsResting() then
			self:CheckAndTeleportIfStuck()
			self:PushAwayFromOtherToiletMen()
			self:TryRandomTeleport()
			self:PlayFootstep()
		end

		if CurTime() > self.NextObstacleCheck then
			self:HandleObstacles()
			self.NextObstacleCheck = CurTime() + 0.2
		end

		self:HandleJump()
	end

	function ENT:OnContact(Ent)
		if not IsValid(Ent) then return end

		if self:IsResting() and (Ent:IsPlayer() or IsToiletMan(Ent)) then
			self.RestUntil = 0
		end

		if Ent:IsPlayer() and Ent:Alive() then
			if GetConVar("ai_ignoreplayers"):GetBool() or GetConVar("ai_disabled"):GetBool() then return end
			if Ent:GetMoveType() == MOVETYPE_NOCLIP then return end
			if CurTime() < self.NextPushTime then return end

			self.NextPushTime = CurTime() + self.PushCooldown

			local PushForce = self:GetPushForce()
			if PushForce > 150 then
				local PushDir = (Ent:GetPos() - self:GetPos()):GetNormalized()
				PushDir.z = 0

				Ent:SetVelocity(PushDir * PushForce + Vector(0, 0, math.floor(PushForce * 0.2)))
				Ent:ViewPunch(Angle(math.random(-5, 5), math.random(-5, 5), 0))
				Ent:TakeDamage(1, self, self)

				self:EmitSound("physics/body/body_medium_impact_soft" .. math.random(1, 7) .. ".wav", 75, math.random(95, 110))
			end
		end
	end

	function ENT:RunBehaviour()
		while true do
			if GetConVar("ai_disabled"):GetBool() then
				self.loco:SetDesiredSpeed(0)
				self:StartActivity(ACT_IDLE)
				coroutine.yield()

			elseif self:GetIsPanicking() then
				if CurTime() > self.PanicEndTime then
					self:SetIsPanicking(false)
					self.loco:SetDesiredSpeed(self:GetRunSpeed())
				else
					self:StartActivity(ACT_RUN)
					self:FleeFromAttacker()
					if self.FleeTarget then
						self.loco:Approach(self.FleeTarget, 1)
					end
					coroutine.yield()
				end

			else
				if self:CheckAndRest() then
					self.loco:SetDesiredSpeed(0)
					self.loco:ClearStuck()
					self:StartActivity(ACT_IDLE)
					self:SetSequence(0)

					while self:IsResting() do
						if CurTime() > self.NextObstacleCheck then
							self:HandleObstacles()
							self.NextObstacleCheck = CurTime() + 0.2
						end
						coroutine.yield()
					end
					self:EndRest()
				end

				if not self:GetIsMoving() then
					self:StartActivity(ACT_IDLE)
					coroutine.wait(1)
					coroutine.yield()
					continue
				end

				local MyArea = navmesh.GetNavArea(self:GetPos(), 100)
				local UseNavmesh = MyArea ~= nil and MyArea:IsValid()

				if UseNavmesh then
					local NearbyAreas = navmesh.Find(self:GetPos(), 2000, 50, 200)
					if #NearbyAreas > 0 then
						local Success = false

						for _ = 1, 5 do
							local Nav = NearbyAreas[math.random(#NearbyAreas)]
							local Pos = Nav:GetRandomPoint()

							local PathObj = Path("Follow")
							PathObj:SetMinLookAheadDistance(200)
							PathObj:SetGoalTolerance(20)
							PathObj:Compute(self, Pos)

							if PathObj:IsValid() then
								local PathEnd = PathObj:GetEnd()
								if PathEnd:DistToSqr(Pos) < (300 * 300) then
									self:StartActivity(ACT_WALK)
									self.LastPos	   = self:GetPos()
									self.LastPosTime   = CurTime()
									self.PathStartTime = CurTime()

									while PathObj:IsValid() and self:GetIsMoving() do
										if GetConVar("ai_disabled"):GetBool() then
											self.loco:SetDesiredSpeed(0)
											self:StartActivity(ACT_IDLE)
											break
										end

										PathObj:Update(self)
										self:CommonLogic()

										local WallHit, Tr = self:IsWallAhead()
										if WallHit then
											local SlideDir = self:GetWallSlideDir(Tr)
											self.loco:FaceTowards(self:GetPos() + SlideDir * 100)
											self.loco:Approach(self:GetPos() + SlideDir * 200, 1)
										end

										if CurTime() - self.PathStartTime > self.PathTimeout then break end
										coroutine.yield()
									end

									Success = true
									break
								end
							end
						end

						if not Success then
							self:StartActivity(ACT_IDLE)
							coroutine.wait(1)
						end
					else
						self:StartActivity(ACT_IDLE)
						coroutine.wait(1)
					end

				else
					-- Нет навмеша — блуждание
					self:StartActivity(ACT_WALK)

					local RandomDir = VectorRand()
					RandomDir.z = 0
					local WanderTarget = self:GetPos() + RandomDir:GetNormalized() * 1000
					local WanderTimeout = CurTime() + math.random(5, 10)
					local WanderStartTime = CurTime()

					while CurTime() < WanderTimeout and self:GetIsMoving() do
						if GetConVar("ai_disabled"):GetBool() then
							self.loco:SetDesiredSpeed(0)
							self:StartActivity(ACT_IDLE)
							break
						end

						self.loco:FaceTowards(WanderTarget)
						self.loco:Approach(WanderTarget, 1)
						self:CommonLogic()

						local WallHit, Tr = self:IsWallAhead()
						if WallHit then
							local SlideDir = self:GetWallSlideDir(Tr)
							WanderTarget = self:GetPos() + SlideDir * 800
							self.loco:FaceTowards(self:GetPos() + SlideDir * 100)
						end

						if self:GetPos():DistToSqr(WanderTarget) < (50 * 50) then break end
						if CurTime() - WanderStartTime > self.PathTimeout then break end
						coroutine.yield()
					end

					self:StartActivity(ACT_IDLE)
					coroutine.wait(math.random(1, 2))
					self.LastPos	 = self:GetPos()
					self.LastPosTime = CurTime()
				end

				coroutine.yield()
			end
		end
	end

	function ENT:Think()
        self:KeepUpright()

        local Pos = self:GetPos()
        if not IsReasonablePos(Pos) then
            self:TeleportToRandomNavArea()
        elseif CurTime() > self.NextGroundFix then
            self.NextGroundFix = CurTime() + 0.5
            self:FixStuckInGeometry()
        end

        self:NextThink(CurTime() + 0.05)
        return true
    end
end

if CLIENT then
	local NICK_NEAR_DIST  = 300
	local NICK_FAR_DIST   = 600
	local NICK_FADE_SPEED = 3

	function ENT:Initialize()
		self.NickAlpha = 0
	end

	function ENT:Think()
		local Ply = LocalPlayer()
		if not IsValid(Ply) then return end

		local Dist = self:GetPos():Distance(Ply:GetPos())

		local TargetAlpha
		if Dist <= NICK_NEAR_DIST then
			TargetAlpha = 1
		elseif Dist >= NICK_FAR_DIST then
			TargetAlpha = 0
		else
			TargetAlpha = 1 - (Dist - NICK_NEAR_DIST) / (NICK_FAR_DIST - NICK_NEAR_DIST)
		end

		self.NickAlpha = Lerp(FrameTime() * NICK_FADE_SPEED, self.NickAlpha or 0, TargetAlpha)

		self:NextThink(CurTime() + 0.05)
		return true
	end

	function ENT:Draw()
		self:DrawModel()

		local Alpha = self.NickAlpha or 0
		if Alpha <= 0.01 then return end

		local Pos = self:GetPos() + Vector(0, 0, 80)
		local Ang = Angle(0, LocalPlayer():EyeAngles().y - 90, 90)

		cam.Start3D2D(Pos, Ang, 0.2)
		draw.SimpleText(
			self:GetBotName(),
			"ChatFont",
			0, 0,
			Color(self:GetNameColorR(), self:GetNameColorG(), self:GetNameColorB(), 255 * Alpha),
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_CENTER
		)
		cam.End3D2D()
	end
end