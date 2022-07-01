local blipsLoaded = false
local atATM = false
local frontofbank = false
local frontofatm = false
local bankColor = "green"

local bankLocations = {
    {i = 108, c = 77, x = 241.727, y = 220.706, z = 106.286, s = 0.8, n = "Pacific Bank"}, -- blip id, blip color, x, y, z, scale, name/label
	{i = 108, c = 0, x = 150.266, y = -1040.203, z = 29.374, s = 0.7, n = "Fleeca Bank"},
	{i = 108, c = 0, x = -1212.980, y = -330.841, z = 37.787, s = 0.7, n = "Fleeca Bank"},
	{i = 108, c = 0, x = -2962.582, y = 482.627, z = 15.703, s = 0.7, n = "Fleeca Bank"},
	{i = 108, c = 0, x = -112.202, y = 6469.295, z = 31.626, s = 0.7, n = "Fleeca Bank"},
	{i = 108, c = 0, x = 314.187, y = -278.621, z = 54.170, s = 0.7, n = "Fleeca Bank"},
	{i = 108, c = 0, x = -351.534, y = -49.529, z = 49.042, s = 0.7, n = "Fleeca Bank"},
	{i = 108, c = 0, x = 1175.0643310547, y = 2706.6435546875, z = 38.094036102295, s = 0.7, n = "Bank 7"}
}

-- ATM Object Models
local ATMs = {
    -870868698,
    -1126237515,
    -1364697528,
    506770882
}

Citizen.CreateThread(function()
    while true do
        if playerNearATM() then
            frontofatm = true
        end
        if playerNearBank() then
            frontofbank = true
        end

        if not blipsLoaded then
            for k, v in ipairs(bankLocations) do
                local blip = AddBlipForCoord(v.x, v.y, v.z)
		        SetBlipSprite(blip, v.i)
		        SetBlipScale(blip, v.s)
		        SetBlipAsShortRange(blip, true)
			    SetBlipColour(blip, v.c)
		        BeginTextCommandSetBlipName("STRING")
		        AddTextComponentString(tostring(v.n))
		        EndTextCommandSetBlipName(blip) 
            end
            blipsLoaded = true
        end
        Wait(1000)
    end
end)

Citizen.CreateThread(function()
    while true do
        if frontofbank and not frontofatm then
            DisplayHelpText("~INPUT_PICKUP~ ~o~Bank")
            if IsControlJustPressed(0, 38) then
                openPlayersBank('bank')
            end
        elseif frontofatm and not frontofbank then
            DisplayHelpText("~INPUT_PICKUP~ ~o~ATM")
            if IsControlJustPressed(0, 38) then
                openPlayersBank('atm')
            end
        end
        if frontofbank or frontofatm then
            if IsControlJustPressed(0, 322) then
                frontofatm = false
                frontofbank = false
                SetNuiFocus(false, false)
                SendNUIMessage({type = 'close'})
            end
        end
        Wait(0)
    end
end)

function openPlayersBank(type, color)
    local dict = 'anim@amb@prop_human_atm@interior@male@enter'
    local anim = 'enter'
    local pped = PlayerPedId()
    local time = 2500

    RequestAnimDict(dict)

    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(7)
    end

    TaskPlayAnim(pped, dict, anim, 8.0, 8.0, -1, 0, 0, 0, 0, 0)
    exports['progressBars']:startUI(time, "Bankkártya behelyezése...")
    Citizen.Wait(time)
    ClearPedTasks(pped)
    if type == 'bank' then
        SetNuiFocus(true, true)
        bankColor = "green"
        SendNUIMessage({type = 'openBank', color = bankColor})
        TriggerServerEvent('orp_bank:balance')
        atATM = false
    elseif type == 'atm' then
        SetNuiFocus(true, true)
        SendNUIMessage({type = 'openBank', color = bankColor})
        TriggerServerEvent('orp_bank:balance')
        atATM = true
    end
end

function playerNearATM() -- Check if a player is near ATM
    local pped = PlayerPedId()
    local ppos = GetEntityCoords(pped)

    for fa, atmek in pairs(ATMs) do
        local atm = GetClosestObjectOfType(pos.x, pos.y, pos.z, 1.0, atmek, false, false, false)
        local atmPos = GetEntityCoords(atm)
        dist = #(vector3(atmPos) - vector3(ppos))
        if dist <= 2.0 then
            return true
        end
    end
    frontofatm = false
    return false
end

function playerNearBank() -- Checks if a player is near a bank
    local pped = PlayerPedId()
    local ppos = GetEntityCoords(pped)

    for fa, bankok in ipairs(bankLocations) do
        dist = #(vector3(bankok.x, bankok.y, bankok.z) - vector3(ppos))
        if dist <= 3.0 then
            return true
        end
    end
    frontofbank = false
    return false
end

RegisterNetEvent('orp_bank:info')
AddEventHandler('orp_bank:info', function(balance)
    local id = PlayerId()
    local playerName = GetPlayerName(id)

    SendNUIMessage({
		type = "updateBalance",
		balance = balance,
        player = playerName,
	})
end)

RegisterNUICallback('deposit', function(data)
    if not atATM then
        TriggerServerEvent('orp_bank:deposit', tonumber(data.amount))
        TriggerServerEvent('orp_bank:balance')
    else
        exports['mythic_notify']:DoHudText('error', 'ATM-be nem tudsz pénzt berakni, menj el egy bankba!')
    end
end)

RegisterNUICallback('withdrawl', function(data)
    TriggerServerEvent('orp_bank:withdraw', tonumber(data.amount))
    TriggerServerEvent('orp_bank:balance')
end)

RegisterNUICallback('balance', function()
    TriggerServerEvent('orp_bank:balance')
end)

RegisterNetEvent('orp:balance:back')
AddEventHandler('orp:balance:back', function(balance)
    SendNUIMessage({
        type = 'balanceReturn',
        bal = balance
    })
end)

function closePlayersBank()
    local dict = 'anim@amb@prop_human_atm@interior@male@exit'
    local anim = 'exit'
    local pped = PlayerPedId()
    local time = 1800

    RequestAnimDict(dict)

    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(7)
    end

    SetNuiFocus(false, false)
    SendNUIMessage({type = 'closeAll'})
    TaskPlayAnim(pped, dict, anim, 8.0, 8.0, -1, 0, 0, 0, 0, 0)
    exports['progressBars']:startUI(time, "Bankkártya kivétele...")
    Citizen.Wait(time)
    ClearPedTasks(pped)
end

RegisterNUICallback('transfer', function(data)
    TriggerServerEvent('orp_bank:transfer', data.to, data.amount)
    TriggerServerEvent('orp_bank:balance')
end)

RegisterNetEvent('orp_bank:notify')
AddEventHandler('orp_bank:notify', function(type, message)
    exports['mythic_notify']:DoHudText(type, message)
end)

AddEventHandler('onResourceStop', function(resource)
    SetNuiFocus(false, false)
    SendNUIMessage({type = 'closeAll'})
end)

RegisterNUICallback('NUIFocusOff', function()
    closePlayersBank()
end)

function DisplayHelpText(str)
    SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end
