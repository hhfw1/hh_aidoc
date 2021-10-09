local isESX =  GetResourceState('es_extended') == 'started' or GetResourceState('extendedmode') == 'started'
local isQB =  GetResourceState('qb-core') == 'started'


if isQB then
	
	QBCore = nil
	TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)
	
	QBCore.Functions.CreateCallback('hhfw:docOnline', function(source, cb)
		local src = source
		local Ply = QBCore.Functions.GetPlayer(src)
		local xPlayers = QBCore.Functions.GetPlayers()
		local doctor = 0
		local canpay = false
		if Ply.PlayerData.money["cash"] >= Config.Price then
			canpay = true
		else
			if Ply.PlayerData.money["bank"] >= Config.Price then
				canpay = true
			end
		end

		for i=1, #xPlayers, 1 do
			local xPlayer = QBCore.Functions.GetPlayer(xPlayers[i])
			if xPlayer.PlayerData.job.name == 'ambulance' then
				doctor = doctor + 1
			end
		end

		cb(doctor, canpay)
	end)
elseif isESX then
	
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
end


RegisterServerEvent('hhfw:charge')
AddEventHandler('hhfw:charge', function()
	local src = source
	if isQB then
		local xPlayer = QBCore.Functions.GetPlayer(src)
		if xPlayer.PlayerData.money["cash"] >= Config.Price then
			xPlayer.Functions.RemoveMoney("cash", Config.Price)
		else
			xPlayer.Functions.RemoveMoney("bank", Config.Price)
		end
		TriggerEvent("qb-bossmenu:server:addAccountMoney", 'ambulance', Config.Price)
	elseif isESX then
		local xPlayer = ESX.GetPlayerFromId(src)
		if xPlayer.getMoney()>= Config.Price then
			xPlayer.removeMoney(Config.Price)
		else
			xPlayer.removeAccountMoney('bank', Config.Price)
		end
	end
end)
