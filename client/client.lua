local QBCore = exports['qb-core']:GetCoreObject()

local InPreview = false

local InMenu = false

local PlayerJob = {}

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
	QBCore.Functions.GetPlayerData(function(PlayerData)
		PlayerJob = PlayerData.job
	end)
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

AddEventHandler('onClientResourceStart',function(resource)
	if GetCurrentResourceName() == resource then
        QBCore.Functions.GetPlayerData(function(PlayerData)
            if PlayerData.job then
                PlayerJob = PlayerData.job
            end
        end)
	end
end)

function InZone()
    for k, v in pairs(Config.RepairLocations) do
        local pos = GetEntityCoords(PlayerPedId(), true)
        if (GetDistanceBetweenCoords(pos.x, pos.y, pos.z, v.coords.x, v.coords.y, v.coords.z, false) < v.distance ) then
            return true
        end
        return false
    end
end

function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

function ShowHelpNotification(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

RegisterNetEvent('NVRS-PoliceGarage:Menu', function(type)
    local Menu = {
        {
            header = "Polis Garajı",
            txt = "View Vehicles",
            params = {
                event = "NVRS-PoliceGarage:Catalog",
                args = type
            }
        }
    }
    -- Menu[#Menu+1] = {
    --     header = "Araç İncele",
    --     txt = "View Vehicles",
    --     params = {
    --         event = "CL-PoliceGarage:PreviewCarMenu"
    --     }
    -- }
    Menu[#Menu+1] = {
        header = "Araçlarım",
        txt = "View Vehicles",
        params = {
            event = "NVRS-PoliceGarage:OwnedCars"
        }
    }
    if not Config.UseMarkerInsteadOfMenu then
        Menu[#Menu+1] = {
            header = "⬅ Store Vehicle",
            params = {
                event = "NVRS-PoliceGarage:StoreVehicle"
            }
        }
    end
    Menu[#Menu+1] = {
        header = "⬅ Close Menu",
        params = {
            event = "qb-menu:client:closeMenu"
        }
    }
    exports["qb-menu"]:openMenu(Menu)
end)

RegisterNetEvent("NVRS-PoliceGarage:OwnedCars", function()
    local vehicleMenu = {
        {
            header = "Polis Garajı",
            isMenuHeader = true,
        }
    }

    QBCore.Functions.TriggerCallback("NVRS-PoliceGarage:GetPoliceVehicles", function(data)
        for k, v in pairs(data) do
            vehicleMenu[#vehicleMenu+1] = {
                header = v.vehicle,
                txt = v.plate,
                params = {
                    event = "NVRS-PoliceGarage:SpawnGarageVehicle",
                    args = {vehicle = v.vehicle, plate = v.plate}
                }
            }
            exports["qb-menu"]:openMenu(vehicleMenu)
        end
    end)
end)

RegisterNetEvent("NVRS-PoliceGarage:Catalog", function(type)
    local gradeLevel = 0
    local vehicleMenu = {
        {
            header = "Police Garage",
            isMenuHeader = true,
        }
    }

    if type then
        for i=1, #Config.Boats do
            if Config.Boats[i].grade == "isboss" then
                if PlayerJob.isboss == true then
                    vehicleMenu[#vehicleMenu+1] = {
                        header = Config.Boats[i].vehiclename,
                        txt = "Buy: " .. Config.Boats[i].vehiclename .. "<br> Price: " .. Config.Boats[i].price .. "$",
                        params = {
                            event = "NVRS-PoliceGarage:ChoosePayment",
                            args = {
                                price = Config.Boats[i].price,
                                vehiclename = Config.Boats[i].vehiclename,
                                vehicle = Config.Boats[i].vehicle
                            }
                        }
                    }
                end
            else
                if PlayerJob.grade.level >= Config.Boats[i].grade and (Config.Boats[i].job == PlayerJob.name or not Config.Boats[i].job) then
                    vehicleMenu[#vehicleMenu+1] = {
                        header = Config.Boats[i].vehiclename,
                        txt = "Buy: " .. Config.Boats[i].vehiclename .. "<br> Price: " .. Config.Boats[i].price .. "$",
                        params = {
                            event = "NVRS-PoliceGarage:ChoosePayment",
                            args = {
                                price = Config.Boats[i].price,
                                vehiclename = Config.Boats[i].vehiclename,
                                vehicle = Config.Boats[i].vehicle
                            }
                        }
                    }
                end
            end
        end
    else
        for i=1, #Config.Vehicles do
            if Config.Vehicles[i].grade == "isboss" then
                if PlayerJob.isboss == true then
                    vehicleMenu[#vehicleMenu+1] = {
                        header = Config.Vehicles[i].vehiclename,
                        txt = "Buy: " .. Config.Vehicles[i].vehiclename .. "<br> Price: " .. Config.Vehicles[i].price .. "$",
                        params = {
                            event = "NVRS-PoliceGarage:ChoosePayment",
                            args = {
                                price = Config.Vehicles[i].price,
                                vehiclename = Config.Vehicles[i].vehiclename,
                                vehicle = Config.Vehicles[i].vehicle
                            }
                        }
                    }
                end
            else
                if PlayerJob.grade.level >= Config.Vehicles[i].grade and (Config.Vehicles[i].job == PlayerJob.name or not Config.Vehicles[i].job) then
                    vehicleMenu[#vehicleMenu+1] = {
                        header = Config.Vehicles[i].vehiclename,
                        txt = "Buy: " .. Config.Vehicles[i].vehiclename .. "<br> Price: " .. Config.Vehicles[i].price .. "$",
                        params = {
                            event = "CL-PoliceGarage:ChoosePayment",
                            args = {
                                price = Config.Vehicles[i].price,
                                vehiclename = Config.Vehicles[i].vehiclename,
                                vehicle = Config.Vehicles[i].vehicle
                            }
                        }
                    }
                end
            end
        end
    end
    vehicleMenu[#vehicleMenu+1] = {
        header = "⬅ Go Back",
        params = {
            event = "NVRS-PoliceGarage:Menu"
        }
    }
    exports["qb-menu"]:openMenu(vehicleMenu)
end)

RegisterNetEvent("NVRS-PoliceGarage:ChoosePayment", function(data)
    local Payment = exports["qb-input"]:ShowInput({
        header = "Choose Payment Method",
        submitText = "Choose",
        inputs = {
            { 
                text = 'Payment Type', 
                name = 'paymenttype', 
                type = 'radio', 
                isRequired = true,
                options = { 
                    { 
                        value = "cash", 
                        text = "Cash" 
                    }, 
                    { 
                        value = "bank", 
                        text = "Bank" 
                    } 
                } 
            }
        }
    })
    if Payment ~= nil then
        TriggerServerEvent("NVRS-PoliceGarage:TakeMoney", Payment.paymenttype, data.price, data.vehiclename, data.vehicle)
    end
end)

RegisterNetEvent('NVRS-PoliceGarage:PreviewCarMenu', function()
    local PreviewMenu = {
        {
            header = "Preview Menu",
            isMenuHeader = true
        }
    }
    for k, v in pairs(Config.Vehicles) do
        PreviewMenu[#PreviewMenu+1] = {
            header = v.vehiclename,
            txt = "Preview: " .. v.vehiclename,
            params = {
                event = "NVRS-PoliceGarage:PreviewVehicle",
                args = {
                    vehicle = v.vehicle,
                }
            }
        }
    end
    PreviewMenu[#PreviewMenu+1] = {
        header = "⬅ Go Back",
        params = {
            event = "NVRS-PoliceGarage:Menu"
        }
    }
    exports["qb-menu"]:openMenu(PreviewMenu)
end)

CreateThread(function()
    while true do
        local plyPed = PlayerPedId()
        local plyCoords = GetEntityCoords(plyPed) 
        local letSleep = true
        
        if PlayerJob.type == "leo" then
            for k, v in pairs(Config.RepairLocations) do 
                local dist= #(plyCoords - v.coords)
                if dist < 20.0 then
                    letSleep = false
                    DrawMarker(36, v.coords.x, v.coords.y, v.coords.z + 0.2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.7, 0.7, 0.5, 0.5, 0, 0, 0, 255, true, false, false, true, false, false, false)
                    if Config.UseMarkerInsteadOfMenu then
                        if dist < 2.0 and not IsPedInAnyVehicle(PlayerPedId(), false) then
                            DrawText3D(v.coords.x, v.coords.y, v.coords.z, "~g~E~w~ - Police Garajı") 
                            if IsControlJustReleased(0, 38) then
                                if v.type then
                                    TriggerEvent("NVRS-PoliceGarage:Menu", v.type)
                                else
                                    TriggerEvent("NVRS-PoliceGarage:Menu")
                                end
                            end
                        end
                        if dist < 3.0 then
                            if IsPedInAnyVehicle(PlayerPedId(), false) then   
                                DrawText3D(v.coords.x, v.coords.y, v.coords.z, "~g~E~w~ - Park Et") 
                            end
                        end
                        if dist < 3.0 then
                            if IsControlJustReleased(0, 38) and IsPedInAnyVehicle(PlayerPedId(), false) then
                                TriggerEvent("NVRS-PoliceGarage:StoreVehicle")
                            end
                        end
                    else
                        if dist < 1.5 then
                            DrawText3D(v.coords.x, v.coords.y, v.coords.z, "~g~E~w~ - Police Garajı") 
                            if IsControlJustReleased(0, 38) then
                                if v.type then
                                    TriggerEvent("NVRS-PoliceGarage:Menu", v.type)
                                else
                                    TriggerEvent("NVRS-PoliceGarage:Menu")
                                end
                            end
                        end
                    end
                end
            end

            for k, v in pairs(Config.BoatsLocations) do
                local dist= #(plyCoords - v.coords)
                if dist < 20.0 then
                    letSleep = false
                    DrawMarker(36, v.coords.x, v.coords.y, v.coords.z + 0.2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.7, 0.7, 0.5, 0.5, 0, 0, 0, 255, true, false, false, true, false, false, false)

                    if dist < 2.0 and not IsPedInAnyVehicle(PlayerPedId(), false) then
                        DrawText3D(v.coords.x, v.coords.y, v.coords.z, "~g~E~w~ - Bot Cikar") 
                        if IsControlJustReleased(0, 38) then
                            QBCore.Functions.SpawnVehicle(`wardenboat`, function(veh)
                                local VehicleProps = QBCore.Functions.GetVehicleProperties(veh)
                                SetVehicleNumberPlateText(veh, "PD"..tostring(math.random(1000, 9999)))
                                exports[Config.FuelSystem]:SetFuel(veh, 100.0)
                                TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
                                TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
                                SetVehicleEngineOn(veh, true, true)
                            end, {x = v.spawnCoords.x, y = v.spawnCoords.y, z = v.spawnCoords.z}, true)
                        end
                    end
                end

                if #(plyCoords - vector3(v.despawnCoords.x, v.despawnCoords.y, v.despawnCoords.z)) < 10.0 then
                    if IsPedInAnyVehicle(PlayerPedId(), false) then   
                        letSleep = false
                        DrawText3D(v.despawnCoords.x, v.despawnCoords.y, v.despawnCoords.z, "~g~E~w~ - Park Et") 
                        if #(plyCoords - vector3(v.despawnCoords.x, v.despawnCoords.y, v.despawnCoords.z)) < 2.0 and IsPedInAnyVehicle(PlayerPedId(), false) then
                            if dist < 3.0 then
                                if IsControlJustReleased(0, 38) then
                                    DeleteVehicle(GetVehiclePedIsIn(plyPed, false))
                                    SetEntityCoords(plyPed, v.coords.x, v.coords.y, v.coords.z)
                                end
                            end
                        end
                    end
                end
            end
            for k, v in pairs(Config.OrtakHeli) do
                local dist= #(plyCoords - v.coords)
                if dist < 20.0 then
                    letSleep = false
                    DrawMarker(36, v.coords.x, v.coords.y, v.coords.z + 0.2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.7, 0.7, 0.5, 0.5, 0, 0, 0, 255, true, false, false, true, false, false, false)

                    if dist < 2.0 and not IsPedInAnyVehicle(PlayerPedId(), false) then
                        DrawText3D(v.coords.x, v.coords.y, v.coords.z, "~g~E~w~ - Helikopter Cikar") 
                        if IsControlJustReleased(0, 38) then
                            QBCore.Functions.SpawnVehicle(`PD150JYZS22`, function(veh)
                                local VehicleProps = QBCore.Functions.GetVehicleProperties(veh)
                                SetVehicleNumberPlateText(veh, "PD"..tostring(math.random(1000, 9999)))
                                if k == "sheriff" then
                                    SetVehicleLivery(veh, 0) --1
                                elseif k == "state" then
                                    SetVehicleLivery(veh, 0) --2
                                elseif k == "police" then
                                    SetVehicleLivery(veh, 0)
                                else
                                    SetVehicleLivery(veh, 0)
                                end
                                exports[Config.FuelSystem]:SetFuel(veh, 100.0)
                                TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
                                TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
                                SetVehicleEngineOn(veh, true, true)
                            end, {x = v.spawnCoords.x, y = v.spawnCoords.y, z = v.spawnCoords.z}, true)
                        end
                    end
                end
                if #(plyCoords - vector3(v.despawnCoords.x, v.despawnCoords.y, v.despawnCoords.z)) < 10.0 then
                    if IsPedInAnyVehicle(PlayerPedId(), false) then   
                        letSleep = false
                        DrawText3D(v.despawnCoords.x, v.despawnCoords.y, v.despawnCoords.z, "~g~E~w~ - Park Et") 
                        if #(plyCoords - vector3(v.despawnCoords.x, v.despawnCoords.y, v.despawnCoords.z)) < 2.0 and IsPedInAnyVehicle(PlayerPedId(), false) then
                            if dist < 3.0 then
                                if IsControlJustReleased(0, 38) then
                                    DeleteVehicle(GetVehiclePedIsIn(plyPed, false))
                                    SetEntityCoords(plyPed, v.coords.x, v.coords.y, v.coords.z)
                                end
                            end
                        end
                    end
                end 
            end
        end

        if letSleep then
            Wait(2000)
        end

        Wait(1)
    end
end)

RegisterNetEvent('NVRS-PoliceGarage:client:SetActive', function(status)
    InMenu = status
end)

RegisterNetEvent('NVRS-PoliceGarage:StoreVehicle', function()
    local ped = PlayerPedId()
    local car = GetVehiclePedIsIn(PlayerPedId(),true)
    if IsPedInAnyVehicle(ped, false) then
        QBCore.Functions.TriggerCallback("NVRS-PoliceGarage:getVehiclePlate", function(pass)
            if pass ~= false then
                local VehicleProps = QBCore.Functions.GetVehicleProperties(car)
                TriggerServerEvent("NVRS-PoliceGarage:SetVehicleProperties", QBCore.Functions.GetPlate(car), VehicleProps)
                TriggerServerEvent("NVRS-PoliceGarage:SetVehicleStatus", QBCore.Functions.GetPlate(car), 1)
                TaskLeaveVehicle(ped, car, 1)
                Citizen.Wait(2000)
                DeleteVehicle(car)
                DeleteEntity(car)
            else
                QBCore.Functions.Notify("Bu araç sana ait değil!", "error")
            end
        end, QBCore.Functions.GetPlate(car))
    else
        QBCore.Functions.Notify("You Are Not In Any Vehicle !", "error")
    end
end)

RegisterNetEvent("NVRS-PoliceGarage:SpawnVehicle", function(vehicle, garage)
    QBCore.Functions.SpawnVehicle(vehicle, function(veh)
        local VehicleProps = QBCore.Functions.GetVehicleProperties(veh)
        SetVehicleNumberPlateText(veh, "PD"..tostring(math.random(1000, 9999)))
        exports[Config.FuelSystem]:SetFuel(veh, 100.0)
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
        SetVehicleEngineOn(veh, true, true)
        TriggerServerEvent("NVRS-PoliceGarage:AddVehicleSQL", VehicleProps, vehicle, GetHashKey(veh), QBCore.Functions.GetPlate(veh))
    end, {x = GetEntityCoords(PlayerPedId()).x, y = GetEntityCoords(PlayerPedId()).y, z = GetEntityCoords(PlayerPedId()).z, h = GetEntityHeading(PlayerPedId())}, true)
end)

RegisterNetEvent("NVRS-PoliceGarage:SpawnGarageVehicle", function(vehicle)
    QBCore.Functions.SpawnVehicle(vehicle.vehicle, function(veh)
        SetVehicleNumberPlateText(veh, tostring(vehicle.plate))
        QBCore.Functions.TriggerCallback("NVRS-PoliceGarage:getVehicleMods", function(mods)
            exports[Config.FuelSystem]:SetFuel(veh, 100.0)
            TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
            TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
            SetVehicleEngineOn(veh, true, true)
            print(json.encode(mods))
            QBCore.Functions.SetVehicleProperties(veh, mods)
            TriggerServerEvent("NVRS-PoliceGarage:SetVehicleStatus", QBCore.Functions.GetPlate(veh), 0)
        end, QBCore.Functions.GetPlate(veh))
    end, {x = GetEntityCoords(PlayerPedId()).x, y = GetEntityCoords(PlayerPedId()).y, z = GetEntityCoords(PlayerPedId()).z, h = GetEntityHeading(PlayerPedId())}, true)
end)

RegisterNetEvent("NVRS-PoliceGarage:PreviewVehicle", function(data)
    if Config.UsePreviewMenuSync then
        QBCore.Functions.TriggerCallback('NVRS-PoliceGarage:CheckIfActive', function(result)
            if result then
                InPreview = true
                local coords = vector4(439.22729, -1021.972, 28.610841, 99.184043)
                QBCore.Functions.SpawnVehicle(data.vehicle, function(veh)
                    SetEntityVisible(PlayerPedId(), false, 1)
                    if Config.SetVehicleTransparency == 'low' then
                        SetEntityAlpha(veh, 400)
                    elseif Config.SetVehicleTransparency == 'medium' then
                        SetEntityAlpha(veh, 93)
                    elseif Config.SetVehicleTransparency == 'high' then
                        SetEntityAlpha(veh, 40)
                    elseif Config.SetVehicleTransparency == 'none' then
                    end
                    FreezeEntityPosition(PlayerPedId(), true)
                    SetVehicleNumberPlateText(veh, "POL"..tostring(math.random(1000, 9999)))
                    exports['LegacyFuel']:SetFuel(veh, 0.0)
                    FreezeEntityPosition(veh, true)
                    SetVehicleEngineOn(veh, false, false)
                    DoScreenFadeOut(200)
                    Citizen.Wait(500)
                    DoScreenFadeIn(200)
                    SetVehicleUndriveable(veh, true)
                    VehicleCam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", 434.03289, -1022.814, 28.730619, 50, 0.00, 282.17034, 80.00, false, 0)
                    SetCamActive(VehicleCam, true)
                    RenderScriptCams(true, true, 500, true, true)
                    Citizen.CreateThread(function()
                        while true do
                            if InPreview then
                                ShowHelpNotification("Press ~INPUT_FRONTEND_RRIGHT~ To Close")
                            elseif not InPreview then
                                break
                            end
                            if IsControlJustReleased(0, 177) then
                                SetEntityVisible(PlayerPedId(), true, 1)
                                FreezeEntityPosition(PlayerPedId(), false)
                                PlaySoundFrontend(-1, "NO", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
                                QBCore.Functions.DeleteVehicle(veh)
                                DoScreenFadeOut(200)
                                Citizen.Wait(500)
                                DoScreenFadeIn(200)
                                RenderScriptCams(false, false, 1, true, true)
                                InPreview = false
                                TriggerServerEvent("NVRS-PoliceGarage:server:SetActive", false)
                                break
                            end
                            Citizen.Wait(1)
                        end
                    end)
                end, coords, true)
            end
        end)
    else
        InPreview = true
        local coords = vector4(439.22729, -1021.972, 28.610841, 99.184043)
        QBCore.Functions.SpawnVehicle(data.vehicle, function(veh)
            SetEntityVisible(PlayerPedId(), false, 1)
            if Config.SetVehicleTransparency == 'low' then
                SetEntityAlpha(veh, 400)
            elseif Config.SetVehicleTransparency == 'medium' then
                SetEntityAlpha(veh, 93)
            elseif Config.SetVehicleTransparency == 'high' then
                SetEntityAlpha(veh, 40)
            elseif Config.SetVehicleTransparency == 'none' then
                
            end
            FreezeEntityPosition(PlayerPedId(), true)
            SetVehicleNumberPlateText(veh, "POL"..tostring(math.random(1000, 9999)))
            exports['LegacyFuel']:SetFuel(veh, 0.0)
            FreezeEntityPosition(veh, true)
            SetVehicleEngineOn(veh, false, false)
            DoScreenFadeOut(200)
            Citizen.Wait(500)
            DoScreenFadeIn(200)
            SetVehicleUndriveable(veh, true)
            VehicleCam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", 434.03289, -1022.814, 28.730619, 50, 0.00, 282.17034, 80.00, false, 0)
            SetCamActive(VehicleCam, true)
            RenderScriptCams(true, true, 500, true, true)
            Citizen.CreateThread(function()
                while true do
                    if InPreview then
                        ShowHelpNotification("Press ~INPUT_FRONTEND_RRIGHT~ To Close")
                    elseif not InPreview then
                        break
                    end
                    if IsControlJustReleased(0, 177) then
                        SetEntityVisible(PlayerPedId(), true, 1)
                        FreezeEntityPosition(PlayerPedId(), false)
                        PlaySoundFrontend(-1, "NO", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
                        QBCore.Functions.DeleteVehicle(veh)
                        DoScreenFadeOut(200)
                        Citizen.Wait(500)
                        DoScreenFadeIn(200)
                        RenderScriptCams(false, false, 1, true, true)
                        InPreview = false
                        TriggerServerEvent("NVRS-PoliceGarage:server:SetActive", false)
                        break
                    end
                    Citizen.Wait(1)
                end
            end)
        end, coords, true)
    end
end)

RegisterNetEvent("NVRS-PoliceGarage:CheckZone", function()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if IsPedInAnyVehicle(PlayerPedId(), true) then
        if InZone() then
            SetVehicleEngineHealth(veh, 1000)
            SetVehiclePetrolTankHealth(veh, 1000)
            SetVehicleFixed(veh)
            SetVehicleDeformationFixed(veh)
            SetVehicleUndriveable(veh, false)
            SetVehicleEngineOn(veh, true, true)
            QBCore.Functions.Notify("Vehicle Fixed !", "success", 3000)
        else
            QBCore.Functions.Notify("You are not in a repair zone !", "error", 3000)
        end
    else
        QBCore.Functions.Notify("You are not in any vehicle !", "error")
    end
end)