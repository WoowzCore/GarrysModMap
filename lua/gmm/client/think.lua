hook.Add("Think", "gmm_Think", function()
    GMM_C.Player = LocalPlayer()

    local View = render.GetViewSetup()
    if View and View.origin then
        GMM_C.CameraPosition = View.origin
    else
        GMM_C.CameraPosition = EyePos()
    end
end)

timer.Create("gmm_ThinkSecond", 0.05, 0, function()
    GMM_C.Environment.Update()

    GMM_C.Void.Think()

    GMM_C.SendToServerClientInfo()
end)