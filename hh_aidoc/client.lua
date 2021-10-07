local isESX =  GetResourceState('es_extended') == 'started' or GetResourceState('extendedmode') == 'started'
local isQB =  GetResourceState('qb-core') == 'started'


local Active = false
local test = nil
local test1 = nil
local Act = true
local spam = true

local isDead = false

if isESX then
	AddEventHandler('playerSpawned', function(spawn)
		isDead = false
	end)

	AddEventHandler('esx:onPlayerDeath', function(data)
		isDead = true
	end)
end


RegisterCommand("help", function(source, args, raw)
	if isQB then
		if (QBCore.Functions.GetPlayerData().metadata["isdead"]) or (QBCore.Functions.GetPlayerData().metadata["inlaststand"]) and spam then
			QBCore.Functions.TriggerCallback('hhfw:docOnline', function(EMSOnline, hasEnoughMoney)

				if EMSOnline <= Config.Doctor and hasEnoughMoney and spam then
					SpawnVehicle(GetEntityCoords(PlayerPedId()))
					TriggerServerEvent('hhfw:charge')
					Notify("Medic is arriving")
				else
					if EMSOnline > Config.Doctor then
						Notify("There is too many medics online", "error")
					elseif not hasEnoughMoney then
						Notify("Not Enough Money", "error")
					else
						Notify("Wait Paramadic is on its Way", "primary")
					end	
				end
			end)
		else
			Notify("This can only be used when dead", "error")
		end
	elseif isESX then
		if isDead and spam then
			ESX.TriggerServerCallback('hhfw:docOnline', function(EMSOnline, hasEnoughMoney)

				if EMSOnline <= Config.Doctor and hasEnoughMoney and spam then
					SpawnVehicle(GetEntityCoords(PlayerPedId()))
					TriggerServerEvent('hhfw:charge')
					Notify("Medic is arriving")
				else
					if EMSOnline > Config.Doctor then
						Notify("There is too many medics online", "error")
					elseif not hasEnoughMoney then
						Notify("Not Enough Money")
					else
						Notify("Wait Paramadic is on its Way")
					end	
				end
			end)
		else
			Notify("This can only be used when dead")
		end
	end
end)



function SpawnVehicle(x, y, z)  
	spam = false
	local vehhash = GetHashKey("ambulance")                                                     
	local loc = GetEntityCoords(PlayerPedId())
	RequestModel(vehhash)
	while not HasModelLoaded(vehhash) do
		Wait(1)
	end
	RequestModel('s_m_m_doctor_01')
	while not HasModelLoaded('s_m_m_doctor_01') do
		Wait(1)
	end
	local spawnRadius = 40                                                    
    local found, spawnPos, spawnHeading = GetClosestVehicleNodeWithHeading(loc.x + math.random(-spawnRadius, spawnRadius), loc.y + math.random(-spawnRadius, spawnRadius), loc.z, 0, 3, 0)

	if not DoesEntityExist(vehhash) then
        mechVeh = CreateVehicle(vehhash, spawnPos, spawnHeading, true, false)                        
        ClearAreaOfVehicles(GetEntityCoords(mechVeh), 5000, false, false, false, false, false);  
        SetVehicleOnGroundProperly(mechVeh)
		SetVehicleNumberPlateText(mechVeh, "HHFW")
		SetEntityAsMissionEntity(mechVeh, true, true)
		SetVehicleEngineOn(mechVeh, true, true, false)
        
        mechPed = CreatePedInsideVehicle(mechVeh, 26, GetHashKey('s_m_m_doctor_01'), -1, true, false)              	
        
        mechBlip = AddBlipForEntity(mechVeh)                                                        	
        SetBlipFlashes(mechBlip, true)  
        SetBlipColour(mechBlip, 5)


		PlaySoundFrontend(-1, "Text_Arrive_Tone", "Phone_SoundSet_Default", 1)
		Wait(2000)
		TaskVehicleDriveToCoord(mechPed, mechVeh, loc.x, loc.y, loc.z, 20.0, 0, GetEntityModel(mechVeh), 524863, 2.0)
		test = mechVeh
		test1 = mechPed
		Active = true
    end
end

Citizen.CreateThread(function()
    while true do
      Citizen.Wait(200)
        if Active or Act then
            local loc = GetEntityCoords(GetPlayerPed(-1))
			local lc = GetEntityCoords(test)
			local ld = GetEntityCoords(test1)
            local dist = Vdist(loc.x, loc.y, loc.z, lc.x, lc.y, lc.z)
			local dist1 = Vdist(loc.x, loc.y, loc.z, ld.x, ld.y, ld.z)
            if dist <= 10 then
				if Active then
					TaskGoToCoordAnyMeans(test1, loc.x, loc.y, loc.z, 1.0, 0, 0, 786603, 0xbf800000)
				end
				if dist1 <= 1 then 
					Active = false
					Act = false
					ClearPedTasksImmediately(test1)
					DoctorNPC()
				end
            end
        end
    end
end)


function DoctorNPC()
	RequestAnimDict("mini@cpr@char_a@cpr_str")
	while not HasAnimDictLoaded("mini@cpr@char_a@cpr_str") do
		Citizen.Wait(1000)
	end

	TaskPlayAnim(test1, "mini@cpr@char_a@cpr_str","cpr_pumpchest",1.0, 1.0, -1, 9, 1.0, 0, 0, 0)
	if isQB then
		QBCore.Functions.Progressbar("revive_doc", "The doctor is giving you medical aid", Config.ReviveTime, false, false, {
			disableMovement = false,
			disableCarMovement = false,
			disableMouse = false,
			disableCombat = true,
		}, {}, {}, {}, function() -- Done
			ClearPedTasks(test1)
			Citizen.Wait(500)
			TriggerServerEvent("hospital:server:RevivePlayer",  GetPlayerServerId(PlayerId()))
			StopScreenEffect('DeathFailOut')	
			Notify("Your treatment is done, you were charged: "..Config.Price, "success")
			RemovePedElegantly(test1)
			DeleteEntity(test)
			spam = true
		end)
	elseif isESX then
		exports['progressBars']:startUI(Config.ReviveTime, "The doctor is giving you medical aid")
		Wait(Config.ReviveTime)
		ClearPedTasks(test1)
		Citizen.Wait(500)
		TriggerServerEvent('esx_ambulancejob:revive', GetPlayerServerId(PlayerId()))
		StopScreenEffect('DeathFailOut')	
		Notify("Your treatment is done, you were charged: "..Config.Price)
		RemovePedElegantly(test1)
		DeleteEntity(test)
		spam = true
	end
end


function Notify(msg, state)
    if isESX then
        ESX.ShowNotification(msg)
    elseif isQB then
        QBCore.Functions.Notify(msg, state)
    end
end
