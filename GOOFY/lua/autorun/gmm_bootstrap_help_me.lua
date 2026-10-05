if SERVER and game.GetMap() == "gmm_garrymod_map_by_woowz_help_me" then
    local function SpawnRandomGMMError()
        if math.random() > 0.05 then return end

        local SpawnPos = Vector(math.random(-10000, 10000), math.random(-3000, 3000), math.random(-10000, 10000))

        local Ent = ents.Create("gmm_download_map")
        if IsValid(Ent) then
            Ent:SetPos(SpawnPos)
            Ent:Spawn()
        end
    end

    timer.Create("GMM_RandomSpawnTimer", not GMM and 0.1 or 1.5, 0, function()
        SpawnRandomGMMError()
    end)
end

if not GMM and CLIENT and game.GetMap() == "gmm_garrymod_map_by_woowz_help_me" then

    local CONFIG = {
        Height      = 30,
        Speed       = 200,
        Text        = "★ DOWNLOAD => https://steamcommunity.com/sharedfiles/filedetails/?id=3813588732 ★   ",
        TextColor   = Color(255, 0, 0),
        TextSize    = 24,
        Font        = "MarqueeFont",
        TopColor    = Color(40, 0, 0, 220),
        BottomColor = Color(40, 0, 0, 220),
        TopDir      = 1,
        BottomDir   = -1,
        Gap         = 200,
    }

    surface.CreateFont("MarqueeFont", {
        font      = "Consolas",
        size      = CONFIG.TextSize,
        weight    = 700,
        antialias = true,
        extended  = true,
    })

    local function MeasureText(text)
        surface.SetFont(CONFIG.Font)
        local Anchor = "|"
        local WithAnchor = surface.GetTextSize(text .. Anchor)
        local AnchorW = surface.GetTextSize(Anchor)
        return WithAnchor - AnchorW
    end

    local TopOffset = 0
    local BottomOffset = 0

	local function DrawMarquee(y, offset, dir, bgColor)
		local SW = ScrW()

		surface.SetDrawColor(bgColor)
		surface.DrawRect(0, y, SW, CONFIG.Height)

		surface.SetFont(CONFIG.Font)
		surface.SetTextColor(CONFIG.TextColor)

		local TextW = MeasureText(CONFIG.Text)
		local Step = TextW + CONFIG.Gap

		local Count = math.ceil(SW / Step) + 3

		local StartX = offset - Step

		local TextY = y + (CONFIG.Height - CONFIG.TextSize) / 2

		for i = 0, Count do
			local x = StartX + i * Step
			surface.SetTextPos(x, TextY)
			surface.DrawText(CONFIG.Text)
		end
	end

    hook.Add("HUDPaint", "MarqueeHUD", function()
        local FT = FrameTime()

        local TextW = MeasureText(CONFIG.Text)
        local Step = TextW + CONFIG.Gap

        TopOffset = (TopOffset + CONFIG.Speed * FT * CONFIG.TopDir)    % Step
        BottomOffset = (BottomOffset + CONFIG.Speed * FT * CONFIG.BottomDir) % Step

        if TopOffset < 0 then TopOffset = TopOffset + Step
        end
        if BottomOffset < 0 then BottomOffset = BottomOffset + Step
        end

        DrawMarquee(0, TopOffset, CONFIG.TopDir, CONFIG.TopColor)
        DrawMarquee(ScrH() - CONFIG.Height, BottomOffset, CONFIG.BottomDir, CONFIG.BottomColor)
    end)

end