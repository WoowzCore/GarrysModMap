hook.Add("PopulateToolMenu", "gmm_PopulateTools", function()
    spawnmenu.AddToolMenuOption("Utilities", "GMM", "gmm_Menu_Main", "Основное", "", "", function(panel)
        panel:ClearControls()

        panel:Help("Скоро может быть тут что-то появится...")
        panel:Help("")

        local Power = 2
        local Speed = 0.5

        local Canvas = vgui.Create("DPanel", panel)
        Canvas:SetTall(300)
        Canvas:Dock(TOP)
        Canvas:SetPaintBackground(false)

        Canvas.Paint = function(self, w, h)
            local T = CurTime()

            local HueOffset = (T * 120 * Speed) % 360
            for i = 0, h, 6 do
                local Hue = (HueOffset + i * 0.8) % 360
                local C   = HSVToColor(Hue, 0.9, 1)
                surface.SetDrawColor(C.r, C.g, C.b, 120)
                surface.DrawRect(0, i, w, 6)
            end

            for i = 1, math.floor(8 * Power) do
                local Y      = math.random(0, h - 4)
                local StripH = math.random(1, math.floor(8 * Power))
                local Hue    = (T * 300 * Speed + i * 60) % 360
                local C      = HSVToColor(Hue, 1, 1)
                surface.SetDrawColor(C.r, C.g, C.b, math.random(120, 220))
                surface.DrawRect(0, Y, w, StripH)
            end

            draw.NoTexture()
            for i = 1, math.floor(5 * Power) do
                local Hue  = (T * 180 * Speed + i * 90) % 360
                local C    = HSVToColor(Hue, 1, 1)
                local Size = 20 + math.sin(T * Speed * i) * 15 * Power
                local X    = (w / 2) + math.cos(T * Speed * i * 1.3) * (w / 3) * Power
                local Y    = (h / 2) + math.sin(T * Speed * i * 1.7) * (h / 3) * Power
                surface.SetDrawColor(C.r, C.g, C.b, 180)
                surface.DrawRect(X - Size / 2, Y - Size / 2, Size, Size)
            end

            if math.sin(T * Speed * 8) > 0.3 then
                local C = HSVToColor((T * 400 * Speed) % 360, 1, 1)
                surface.SetDrawColor(C.r, C.g, C.b, 255)
                surface.DrawOutlinedRect(0, 0, w, h)
                surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
            end

            surface.SetFont("DermaLarge")
            local Text = "GMM WIP ADDON"
            local TW, TH = surface.GetTextSize(Text)
            local C = HSVToColor((T * 200 * Speed) % 360, 1, 1)
            surface.SetTextColor(C.r, C.g, C.b, 255)
            surface.SetTextPos((w - TW) / 2, (h - TH) / 2)
            surface.DrawText(Text)
        end

        local id = "gmm_FuckedCanvas_" .. tostring(Canvas)
        timer.Create(id, 0, 0, function()
            if IsValid(Canvas) then
                Canvas:InvalidateLayout()
            end
        end)

        Canvas.OnRemove = function()
            timer.Remove(id)
        end
    end)
end)