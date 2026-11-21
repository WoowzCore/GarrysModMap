GMM_S.Func.ShakeProp = function(Prop, Power)
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

GMM_S.Func.GetPhysicsProps = function()
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