ESX = nil
local Active = false
local test = nil
local test1 = nil
local spam = true
local isDead = false

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(200)
    end
end)

AddEventHandler('playerSpawned', function(spawn)
	isDead = false
end)

AddEventHandler('esx:onPlayerDeath', function(data)
	isDead = true
end)


Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if isDead and spam then
			if IsControlJustPressed(1, 47) then
				ESX.TriggerServerCallback('hhfw:docOnline', function(EMSOnline, hasEnoughMoney)
					if EMSOnline <= Config.Doctor and hasEnoughMoney and spam then
						SpawnVehicle(GetEntityCoords(PlayerPedId()))
						TriggerServerEvent('hhfw:charge')
						ShowAdvNotification("CHAR_PA_FEMALE", "Doctor", "", "There is no EMS in the city don't worry i will send my PA for you!")
						--Notify("Medic is arriving")
					else
						if EMSOnline > Config.Doctor then
							exports['CRP_Notify']:Alert("Doctor", "We got your signal, please wait", 5000, 'bell')
							--Notify("There is too many medics online", "error")
						elseif not hasEnoughMoney then
							Notify("Not Enough Money")
						else
							Notify("Wait Paramadic is on its Way")
						end	
					end
				end)
			end
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
        if Active then
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
	TriggerEvent("mythic_progbar:client:progress", {
        name = "unique_action_name",
        duration = 10000,
        label = "Giving CPR.",
        useWhileDead = true,
        canCancel = false,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }
    }, function(status)
        if not status then
            -- Do Something If Event Wasn't Cancelled
        end
    end)
	Wait(Config.ReviveTime)
	ClearPedTasks(test1)
	Citizen.Wait(500)
	TriggerEvent('esx_ambulancejob:revive', GetPlayerServerId(PlayerId()))
	ShowAdvNotification("CHAR_PA_FEMALE", "Doctor", "", "Your treatment is done, you were charged : ~g~ $"..Config.Price)
	--Notify("Your treatment is done, you were charged: "..Config.Price)
	Citizen.Wait(5000)
	DeletePed(test1)
	DeleteVehicle(test)
	spam = true
end


function Notify(msg, state)
    ESX.ShowNotification(msg)
end

function ShowAdvNotification(image, title, subtitle, text)
	SetNotificationTextEntry("STRING");
	AddTextComponentString(text);
	SetNotificationMessage(image, image, false, 0, title, subtitle);
	DrawNotification(false, true);
end
