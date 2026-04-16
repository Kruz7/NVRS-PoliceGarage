local QBCore = exports['qb-core']:GetCoreObject()

local InMenu = false

local function DiscordLog(message)
    local embed = {
        {
            ["color"] = 04255,
            ["title"] = "nvrs Police Garage",
            ["description"] = message,
            ["footer"] = {
                ["text"] = "nvrs",
                ["icon_url"] = Config.LogsImage
            },
            ["thumbnail"] = {
                ["url"] = Config.LogsImage,
            },
        }
    }

    PerformHttpRequest(
        Config.WebHook,
        function(_, _, _) end,
        'POST',
        json.encode({
            username = 'nvrs-PoliceGarage',
            embeds = embed,
            avatar_url = Config.LogsImage
        }),
        { ['Content-Type'] = 'application/json' }
    )
end

local function BanPlayerForExploit(src, reason)
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end

    local license = player.PlayerData.license
    local name = GetPlayerName(src) or 'Unknown'
    local expire = 2147483647

    if license then
        MySQL.Async.insert(
            'INSERT INTO bans (name, license, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?)',
            {
                name,
                license,
                reason,
                expire,
                'nvrs-PoliceGarage'
            }
        )
    end

    DiscordLog(('[EXPLOIT BAN] Name: **%s** | ID: **%s** | Reason: **%s**'):format(name, src, reason))
    DropPlayer(src, 'You have been banned for exploiting the police garage.')
end

QBCore.Functions.CreateCallback('NVRS-PoliceGarage:CheckIfActive', function(source, cb)
    if not InMenu then
        TriggerEvent("NVRS-PoliceGarage:server:SetActive", true)
        cb(true)
    else
        cb(false)
        TriggerClientEvent("QBCore:Notify", source, "Someone Is In The Menu Please Wait !", "error")
    end
end)

RegisterNetEvent('NVRS-PoliceGarage:server:SetActive', function(status)
    if status ~= nil then
        InMenu = status
        TriggerClientEvent('NVRS-PoliceGarage:client:SetActive', -1, InMenu)
    else
        TriggerClientEvent('NVRS-PoliceGarage:client:SetActive', -1, InMenu)
    end
end)

RegisterServerEvent("NVRS-PoliceGarage:AddVehicleSQL", function(mods, vehicle, hash, plate)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local matchedConfig
    for _, v in pairs(Config.Vehicles or {}) do
        if v.vehicle == vehicle then
            matchedConfig = v
            break
        end
    end

    if not matchedConfig then
        -- Eski datalardan dolayı false ban olmasın diye sadece logla ve çık
        DiscordLog(('[WARNING] %s (%s) tried to save vehicle not in Config.Vehicles: %s | plate: %s'):
            format(GetPlayerName(src) or 'Unknown', src, tostring(vehicle), tostring(plate)))
        return
    end

    local exists = MySQL.query.await(
        'SELECT 1 FROM player_vehicles WHERE citizenid = ? AND plate = ? LIMIT 1',
        { Player.PlayerData.citizenid, plate }
    )
    if exists and exists[1] then
        return
    end

    MySQL.Async.insert(
        'INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state) VALUES (?, ?, ?, ?, ?, ?, ?)',
        {
            Player.PlayerData.license,
            Player.PlayerData.citizenid,
            vehicle,
            hash,
            json.encode(mods),
            plate,
            0
        }
    )
end)

RegisterServerEvent('NVRS-PoliceGarage:TakeMoney', function(paymenttype, price, vehiclename, vehicle)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local name = GetPlayerName(src) or 'Unknown'

    if not Player then
        return
    end

    if paymenttype ~= 'cash' and paymenttype ~= 'bank' then
        BanPlayerForExploit(src, ('Invalid payment type (%s)'):format(tostring(paymenttype)))
        return
    end

    local job = Player.PlayerData.job or {}
    local matchedConfig

    for _, v in pairs(Config.Vehicles or {}) do
        if v.vehicle == vehicle then
            matchedConfig = v
            break
        end
    end

    if not matchedConfig then
        for _, v in pairs(Config.Boats or {}) do
            if v.vehicle == vehicle then
                matchedConfig = v
                break
            end
        end
    end

    if not matchedConfig then
        BanPlayerForExploit(src, ('Tried to buy unknown vehicle model (%s)'):format(tostring(vehicle)))
        return
    end

    if matchedConfig.price ~= price or matchedConfig.vehiclename ~= vehiclename then
        BanPlayerForExploit(
            src,
            ('Price/name mismatch. Expected %s / %s, got %s / %s'):
                format(matchedConfig.price, matchedConfig.vehiclename, tostring(price), tostring(vehiclename))
        )
        return
    end

    if matchedConfig.job and job.name ~= matchedConfig.job then
        BanPlayerForExploit(
            src,
            ('Job mismatch. Required %s, player job %s'):format(matchedConfig.job, tostring(job.name))
        )
        return
    end

    if not matchedConfig.job and job.type and job.type ~= 'leo' then
        BanPlayerForExploit(src, ('Non-LEO job (%s) tried to buy police vehicle'):format(tostring(job.name)))
        return
    end

    if Player.Functions.GetMoney(paymenttype) >= price then
        TriggerClientEvent("NVRS-PoliceGarage:SpawnVehicle", src, vehicle)
        Player.Functions.RemoveMoney(paymenttype, price)
        TriggerClientEvent('QBCore:Notify', src, 'Vehicle Successfully Bought', "success")
        DiscordLog(
            ('New Vehicle Bought By: **%s** ID: **%s** Bought: **%s** For: **%s$**'):
                format(name, src, vehiclename, price)
        )
    else
        TriggerClientEvent('QBCore:Notify', src, 'You Dont Have Enough Money !', "error")
    end
end)

QBCore.Commands.Add('prepair', 'Repair Your Police Vehicle (Can Be Used Only In Police Station)', {}, false, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == 'police' then
        TriggerClientEvent("NVRS-PoliceGarage:CheckZone", src)
    else
        TriggerClientEvent('QBCore:Notify', src, 'You are not a police officer.', "error")              
    end
end)

QBCore.Functions.CreateCallback("NVRS-PoliceGarage:GetPoliceVehicles", function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local vehicles = {}

    if Player then
        MySQL.query('SELECT * FROM player_vehicles WHERE citizenid = ?', {Player.PlayerData.citizenid}, function(result)
            if result[1] then
                for k, v in pairs(Config.Vehicles) do
                    for i, s in pairs(result) do
                        if v["vehicle"] == s.vehicle and s.state == 1 then
                            vehicles[#vehicles+1] = s
                        end
                    end
                end
                cb(vehicles)
            end
        end)
    end
end)

RegisterServerEvent('NVRS-PoliceGarage:SetVehicleProperties')
AddEventHandler('NVRS-PoliceGarage:SetVehicleProperties', function(plate, mods)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end

    local data = MySQL.query.await(
        'SELECT citizenid FROM player_vehicles WHERE plate = ? LIMIT 1',
        { plate }
    )

    if not data or not data[1] then
        -- Plaka bulunamadı, sadece görmezden gel
        return
    end

    if data[1].citizenid ~= player.PlayerData.citizenid then
        BanPlayerForExploit(src, ('Tried to change vehicle properties for plate %s they do not own'):format(tostring(plate)))
        return
    end

    MySQL.update('UPDATE player_vehicles SET mods = ? WHERE plate = ?', { json.encode(mods), plate })
end)

QBCore.Functions.CreateCallback('NVRS-PoliceGarage:getVehiclePlate', function(source, cb, plate)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    local data = MySQL.query.await('SELECT * FROM player_vehicles WHERE citizenid = ? AND plate = ?', {xPlayer.PlayerData.citizenid, plate})

    if data[1] ~= nil then
        cb(true)
    else
        cb(false)
    end
end)

RegisterServerEvent('NVRS-PoliceGarage:SetVehicleStatus')
AddEventHandler('NVRS-PoliceGarage:SetVehicleStatus', function(plate, state)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end

    local data = MySQL.query.await(
        'SELECT citizenid FROM player_vehicles WHERE plate = ? LIMIT 1',
        { plate }
    )

    if not data or not data[1] then
        return
    end

    if data[1].citizenid ~= player.PlayerData.citizenid then
        BanPlayerForExploit(src, ('Tried to change vehicle status for plate %s they do not own'):format(tostring(plate)))
        return
    end

    MySQL.update('UPDATE player_vehicles SET state = ? WHERE plate = ?', { state, plate })
end)

QBCore.Functions.CreateCallback('NVRS-PoliceGarage:getVehicleMods', function(source, cb, plate)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    local data = MySQL.query.await('SELECT * FROM player_vehicles WHERE citizenid = ? AND plate = ?', {xPlayer.PlayerData.citizenid, plate})

    if data[1] ~= nil then
        cb(json.decode(data[1].mods))
    else
        cb(false)
    end
end)