ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
	
ESX.RegisterServerCallback('hhfw:docOnline' , function(source, cb)
	local src = source
	local Ply = ESX.GetPlayerFromId(src)
	local xPlayers = ESX.GetPlayers()
	local doctor = 0
	local canpay = false
	if Ply.getMoney() >= Config.Price then
		canpay = true
	else
		if Ply.getAccount('bank').money >= Config.Price then
			canpay = true
		end
	end

	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == 'ambulance' then
			doctor = doctor + 1
		end
	end

	cb(doctor, canpay)
end)



RegisterServerEvent('hhfw:charge')
AddEventHandler('hhfw:charge', function()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if xPlayer.getMoney()>= Config.Price then
		xPlayer.removeMoney(Config.Price)
	else
		xPlayer.removeAccountMoney('bank', Config.Price)
	end
end)
