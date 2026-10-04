if not GMM and CLIENT and game.GetMap() == "gmm_garrymod_map_by_woowz_help_me" then

    local CONFIG = {
        Height      = 30,
        Speed       = 200,
        Text        = "★ DOWNLOAD => https://steamcommunity.com/sharedfiles/filedetails/?id=3776326993 ★   ",
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
        local anchor     = "|"
        local withAnchor = surface.GetTextSize(text .. anchor)
        local anchorW    = surface.GetTextSize(anchor)
        return withAnchor - anchorW
    end

    local topOffset    = 0
    local bottomOffset = 0

	local function DrawMarquee(y, offset, dir, bgColor)
		local sw = ScrW()

		surface.SetDrawColor(bgColor)
		surface.DrawRect(0, y, sw, CONFIG.Height)

		surface.SetFont(CONFIG.Font)
		surface.SetTextColor(CONFIG.TextColor)

		local textW = MeasureText(CONFIG.Text)
		local step  = textW + CONFIG.Gap

		local count = math.ceil(sw / step) + 3

		local startX = offset - step

		local textY = y + (CONFIG.Height - CONFIG.TextSize) / 2

		for i = 0, count do
			local x = startX + i * step
			surface.SetTextPos(x, textY)
			surface.DrawText(CONFIG.Text)
		end
	end

    hook.Add("HUDPaint", "MarqueeHUD", function()
        local ft = FrameTime()

        local textW = MeasureText(CONFIG.Text)
        local step  = textW + CONFIG.Gap

        topOffset    = (topOffset    + CONFIG.Speed * ft * CONFIG.TopDir)    % step
        bottomOffset = (bottomOffset + CONFIG.Speed * ft * CONFIG.BottomDir) % step

        if topOffset    < 0 then topOffset    = topOffset    + step end
        if bottomOffset < 0 then bottomOffset = bottomOffset + step end

        DrawMarquee(0, topOffset, CONFIG.TopDir, CONFIG.TopColor)
        DrawMarquee(ScrH() - CONFIG.Height, bottomOffset, CONFIG.BottomDir, CONFIG.BottomColor)
    end)

end