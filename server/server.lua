ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('orp_bank:deposit')
AddEventHandler('orp_bank:deposit', function(amount)
    local _src = source
	
	local xPlayer = ESX.GetPlayerFromId(_src)
	if amount == nil or amount <= 0 or amount > xPlayer.getMoney() then
		TriggerClientEvent('orp_bank:notify', _src, "error", "[Sikertelen Tranzakció] Érvénytelen összeg")
	else
		xPlayer.removeMoney(amount)
		xPlayer.addAccountMoney('bank', tonumber(amount))
		TriggerClientEvent('orp_bank:notify', _src, "success", "[Sikeres Tranzakció] Sikeresen befizettél a számládra: $"..amount)
	end
end)

RegisterServerEvent('orp_bank:withdraw')
AddEventHandler('orp_bank:withdraw', function(amount)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	local min = 0
	amount = tonumber(amount)
	min = xPlayer.getAccount('bank').money
	if amount == nil or amount <= 0 or amount > min then
		TriggerClientEvent('orp_bank:notify', _src, "error", "[Sikertelen Tranzakció] Érvénytelen összeg")
	else
		xPlayer.removeAccountMoney('bank', amount)
		xPlayer.addMoney(amount)
		TriggerClientEvent('orp_bank:notify', _src, "success", "[Sikeres Tranzakció] Sikeresen levettél a számládról: $"..amount)
	end
end)

RegisterServerEvent('orp_bank:balance')
AddEventHandler('orp_bank:balance', function()
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	balance = xPlayer.getAccount('bank').money
	TriggerClientEvent('orp_bank:info', _src, balance)
end)

RegisterServerEvent('orp_bank:transfer')
AddEventHandler('orp_bank:transfer', function(to, amount)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	local xTarget = ESX.GetPlayerFromId(to)
	local amount = amountt
	local balance = 0

	if xTarget == nil or xTarget == -1 then
		TriggerClientEvent('orp_bank:notify', _src, "error", "[Sikertelen Tranzakció] Hibás számlaszám")
	else
		balance = xPlayer.getAccount('bank').money
		zbalance = xTarget.getAccount('bank').money
		
		if tonumber(_src) == tonumber(to) then
			TriggerClientEvent('orp_bank:notify', _src, "error", "[Sikertelen Tranzakció] Saját maganak nem utalhatsz el pénzt")
		else
			if balance <= 0 or balance < tonumber(amount) or tonumber(amount) <= 0 then
				TriggerClientEvent('orp_bank:notify', _src, "error", "[Sikertelen Tranzakció] Nincs elegendő összeged a tranzakció létrehozáshoz")
			else
				xPlayer.removeAccountMoney('bank', tonumber(amount))
				xTarget.addAccountMoney('bank', tonumber(amount))
				TriggerClientEvent('orp_bank:notify', _src, "success", "[Sikeres Tranzakció] Elutalt összeg: $"..amount.." | Bankszámlaszám: "..to)
				TriggerClientEvent('orp_bank:notify', to, "success", "[Sikeres Tranzakció] Átutalt összeg: $"..amount.." | Bankszámlaszám: ".._src)
			end
		end
	end
end)