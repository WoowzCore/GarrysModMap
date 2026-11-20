local TimerSecondInterval = 0.05

hook.Add("Think", "gmm_Think", function()
    GMM_C.Player = LocalPlayer()

    local View = render.GetViewSetup()
    if View and View.origin then
        GMM_C.CameraPosition = View.origin
    else
        GMM_C.CameraPosition = EyePos()
    end
end)

timer.Create("gmm_ThinkSecond", TimerSecondInterval, 0, function()
    GMM_C.Environment.Update()

    if GMM.Valid then
        GMM_C.Player:SetDSP(3, true)
    end

    GMM_C.Void.Think()

    -- ----------------------------------------------------------------------

    net.Start("gmm_ClientInfo")
        net.WriteTable({
            Shift = input.IsKeyDown(KEY_LSHIFT) or input.IsKeyDown(KEY_RSHIFT),
            Alt   = input.IsKeyDown(KEY_LALT  ) or input.IsKeyDown(KEY_RALT  )
        })
    net.SendToServer()
end)