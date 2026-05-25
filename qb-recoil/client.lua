local isShooting = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local ped = PlayerPedId()

        if IsPedShooting(ped) and not isShooting then
            isShooting = true
            TriggerRecoil()
        elseif not IsPedShooting(ped) then
            isShooting = false
        end
    end
end)

function TriggerRecoil()
    local ped    = PlayerPedId()
    local weapon = GetSelectedPedWeapon(ped)

    -- Silaha göre ayarlar
    local shakeAmount = 0.10   -- kamera titremesi
    local upAmount    = 0.35   -- yukarı çıkma (derece)
    local returnTime  = 18     -- geri dönüş frame sayısı

    if weapon == GetHashKey("WEAPON_PISTOL") or
       weapon == GetHashKey("WEAPON_COMBATPISTOL") then
        shakeAmount = 0.07
        upAmount    = 0.20
        returnTime  = 15

    elseif weapon == GetHashKey("WEAPON_SMG") or
           weapon == GetHashKey("WEAPON_MICROSMG") then
        shakeAmount = 0.09
        upAmount    = 0.28
        returnTime  = 16

    elseif weapon == GetHashKey("WEAPON_ASSAULTRIFLE") or
           weapon == GetHashKey("WEAPON_CARBINERIFLE") then
        shakeAmount = 0.12
        upAmount    = 0.38
        returnTime  = 18

    elseif weapon == GetHashKey("WEAPON_SNIPERRIFLE") then
        shakeAmount = 0.20
        upAmount    = 0.70
        returnTime  = 25

    elseif weapon == GetHashKey("WEAPON_PUMPSHOTGUN") then
        shakeAmount = 0.18
        upAmount    = 0.60
        returnTime  = 22
    end

    -- Kamera titremesi
    ShakeGameplayCam("HAND_SHAKE", shakeAmount)

    Citizen.CreateThread(function()
        -- Orijinal pitch'i kaydet
        local originalRot = GetGameplayCamRot(2)
        local originalPitch = originalRot.x

        -- Yukarı çık (hızlı, 5 adımda)
        local upSteps = 5
        for i = 1, upSteps do
            Citizen.Wait(10)
            local rot = GetGameplayCamRot(2)
            SetGameplayCamRelativePitch(rot.x + (upAmount / upSteps), 1.0)
        end

        -- Geri dön (yavaş, smooth)
        for i = 1, returnTime do
            Citizen.Wait(14)
            local rot = GetGameplayCamRot(2)
            local diff = originalPitch - rot.x
            if math.abs(diff) < 0.01 then break end
            SetGameplayCamRelativePitch(rot.x + (diff * 0.18), 1.0)
        end

        -- Tam orijinal pozisyona kilitle
        SetGameplayCamRelativePitch(originalPitch, 1.0)

        StopGameplayCamShaking(true)
        isShooting = false
    end)
end
