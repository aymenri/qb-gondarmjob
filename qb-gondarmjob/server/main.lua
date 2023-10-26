-- Variables

local Plates = {}
local PlayerStatus = {}
local Casings = {}
local BloodDrops = {}
local FingerDrops = {}
local Objects = {}
local QBCore = exports['qb-core']:GetCoreObject()

-- Functions

local function UpdateBlips()
    local dutyPlayers = {}
    local players = QBCore.Functions.GetQBPlayers()
    for k, v in pairs(players) do
        if (v.PlayerData.job.name == "gondarm" or v.PlayerData.job.name == "ambulance") and v.PlayerData.job.onduty then
            local coords = GetEntityCoords(GetPlayerPed(v.PlayerData.source))
            local heading = GetEntityHeading(GetPlayerPed(v.PlayerData.source))
            dutyPlayers[#dutyPlayers+1] = {
                source = v.PlayerData.source,
                label = v.PlayerData.metadata["callsign"],
                job = v.PlayerData.job.name,
                location = {
                    x = coords.x,
                    y = coords.y,
                    z = coords.z,
                    w = heading
                }
            }
        end
    end
    TriggerClientEvent("gondarm:client:UpdateBlips", -1, dutyPlayers)
end

local function CreateBloodId()
    if BloodDrops then
        local bloodId = math.random(10000, 99999)
        while BloodDrops[bloodId] do
            bloodId = math.random(10000, 99999)
        end
        return bloodId
    else
        local bloodId = math.random(10000, 99999)
        return bloodId
    end
end

local function CreateFingerId()
    if FingerDrops then
        local fingerId = math.random(10000, 99999)
        while FingerDrops[fingerId] do
            fingerId = math.random(10000, 99999)
        end
        return fingerId
    else
        local fingerId = math.random(10000, 99999)
        return fingerId
    end
end

local function CreateCasingId()
    if Casings then
        local caseId = math.random(10000, 99999)
        while Casings[caseId] do
            caseId = math.random(10000, 99999)
        end
        return caseId
    else
        local caseId = math.random(10000, 99999)
        return caseId
    end
end

local function CreateObjectId()
    if Objects then
        local objectId = math.random(10000, 99999)
        while Objects[objectId] do
            objectId = math.random(10000, 99999)
        end
        return objectId
    else
        local objectId = math.random(10000, 99999)
        return objectId
    end
end

local function IsVehicleOwned(plate)
    local result = exports.oxmysql:scalarSync('SELECT plate FROM player_vehicles WHERE plate = ?', {plate})
    return result
end

local function GetCurrentCops()
    local amount = 0
    local players = QBCore.Functions.GetQBPlayers()
    for k, v in pairs(players) do
        if v.PlayerData.job.name == "gondarm" and v.PlayerData.job.onduty then
            amount = amount + 1
        end
    end
    return amount
end

local function DnaHash(s)
    local h = string.gsub(s, ".", function(c)
        return string.format("%02x", string.byte(c))
    end)
    return h
end

-- Commands

QBCore.Commands.Add("spikestrip", "اضافة اشواك", {}, false, function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        if Player.PlayerData.job.name == "gondarm" and Player.PlayerData.job.onduty then
            TriggerClientEvent('gondarm:client:SpawnSpikeStrip', src)
        end
    end
end)

QBCore.Commands.Add("grantlicense", "اعطاء رخصة اسلحة", {{name = "id", help = "الايدي"}, {name = "license", help = "الرخصة"}}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "gondarm" and Player.PlayerData.job.grade.level >= 2 then
        if args[2] == "driver" or args[2] == "weapon" then
            local SearchedPlayer = QBCore.Functions.GetPlayer(tonumber(args[1]))
            if SearchedPlayer then
                local licenseTable = SearchedPlayer.PlayerData.metadata["licences"]
                licenseTable[args[2]] = true
                SearchedPlayer.Functions.SetMetaData("licences", licenseTable)
                TriggerClientEvent('QBCore:Notify', SearchedPlayer.PlayerData.source, "لقد حصلت على ترخيص",
                    "success", 5000)
                TriggerClientEvent('QBCore:Notify', src, "لقد منحت ترخيصًا", "success", 5000)
            end
        else
            TriggerClientEvent('QBCore:Notify', src, "نوع الترخيص غير صالح", "error")
        end
    else
        TriggerClientEvent('QBCore:Notify', src, "يجب أن تكون برتبة أكبر", "error")
    end
end)

QBCore.Commands.Add("revokelicense", "سحب رخصة", {{name = "id", help = "الايدي"}, {name = "license", help = "الرخصة"}}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "gondarm" and Player.PlayerData.job.grade.level >= 2 then
        if args[2] == "driver" or args[2] == "weapon" then
            local SearchedPlayer = QBCore.Functions.GetPlayer(tonumber(args[1]))
            if SearchedPlayer then
                local licenseTable = SearchedPlayer.PlayerData.metadata["licences"]
                licenseTable[args[2]] = false
                SearchedPlayer.Functions.SetMetaData("licences", licenseTable)
                TriggerClientEvent('QBCore:Notify', SearchedPlayer.PlayerData.source, "لقد تم إبطال الترخيص",
                    "error", 5000)
                TriggerClientEvent('QBCore:Notify', src, "لقد ألغيت ترخيصًا", "success", 5000)
            end
        else
            TriggerClientEvent('QBCore:Notify', src, "نوع الترخيص غير صالح", "error")
        end
    else
        TriggerClientEvent('QBCore:Notify', src, "يجب أن تكون برتبة أكبر", "error")
    end
end)

QBCore.Commands.Add("pobject", "اضافة و حدف ادوات الشرطة", {{name = "type",help = " الادوات او اكتب للحدف delete"}}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local type = args[1]:lower()
    if Player.PlayerData.job.name == "gondarm" and Player.PlayerData.job.onduty then
        if type == "pion" then
            TriggerClientEvent("gondarm:client:spawnCone", src)
        elseif type == "barier" then
            TriggerClientEvent("gondarm:client:spawnBarier", src)
        elseif type == "schotten" then
            TriggerClientEvent("gondarm:client:spawnSchotten", src)
        elseif type == "tent" then
            TriggerClientEvent("gondarm:client:spawnTent", src)
        elseif type == "light" then
            TriggerClientEvent("gondarm:client:spawnLight", src)
        elseif type == "delete" then
            TriggerClientEvent("gondarm:client:deleteObject", src)
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'بجب ان تكون داخل الخدمة', 'error')
    end
end)

-- QBCore.Commands.Add("cuff", "Cuff Player (gondarm Only)", {}, false, function(source, args)
    -- local src = source
    -- local Player = QBCore.Functions.GetPlayer(src)
    -- if Player.PlayerData.job.name == "gondarm" and Player.PlayerData.job.onduty then
        -- TriggerClientEvent("gondarm:client:CuffPlayer", src)
    -- else
        -- TriggerClientEvent('QBCore:Notify', src, 'بجب ان تكون داخل الخدمة', 'error')
    -- end
-- end)

QBCore.Commands.Add("escort", "سحب شخص", {}, false, function(source, args)
    local src = source
    TriggerClientEvent("gondarm:client:EscortPlayer", src)
end)

QBCore.Commands.Add("callsign", "امنح نفسك إشارة نداء", {{name = "name", help = "الاسم او اختصارك"}}, false, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.SetMetaData("callsign", table.concat(args, " "))
end)

QBCore.Commands.Add("clearcasings", "حدف الاشارات في الخريطة", {}, false, function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "gondarm" and Player.PlayerData.job.onduty then
        TriggerClientEvent("evidence:client:ClearCasingsInArea", src)
    else
        TriggerClientEvent('QBCore:Notify', src, 'بجب ان تكون داخل الخدمة', 'error')
    end
end)

QBCore.Commands.Add("jail", "سجن شخص", {{name = "id", help = "الايدي"}, {name = "time", help = "الاشهر"}}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "gondarm" and Player.PlayerData.job.onduty then
        local playerId = tonumber(args[1])
        local time = tonumber(args[2])
        if time > 0 then
            TriggerClientEvent("gondarm:client:JailCommand", src, playerId, time)
        else
            TriggerClientEvent('QBCore:Notify', src, 'يجب ان تكون اكثر من 0', 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'بجب ان تكون داخل الخدمة', 'error')
    end
end)

QBCore.Commands.Add("unjail", "اخراج شخص من السجن", {{name = "id", help = "الايدي"}}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "gondarm" and Player.PlayerData.job.onduty then
        local playerId = tonumber(args[1])
        TriggerClientEvent("prison:client:UnjailPerson", playerId)
    else
        TriggerClientEvent('QBCore:Notify', src, 'بجب ان تكون داخل الخدمة', 'error')
    end
end)

QBCore.Commands.Add("clearblood", "مسح الدم", {}, false, function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "gondarm" and Player.PlayerData.job.onduty then
        TriggerClientEvent("evidence:client:ClearBlooddropsInArea", src)
    else
        TriggerClientEvent('QBCore:Notify', src, 'بجب ان تكون داخل الخدمة', 'error')
    end
end)

QBCore.Commands.Add("seizecash", "حجز الأموال", {}, false, function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "gondarm" and Player.PlayerData.job.onduty then
        TriggerClientEvent("gondarm:client:SeizeCash", src)
    else
        TriggerClientEvent('QBCore:Notify', src, 'بجب ان تكون داخل الخدمة', 'error')
    end
end)

-- QBCore.Commands.Add("sc", "Soft Cuff (gondarm Only)", {}, false, function(source)
    -- local src = source
    -- local Player = QBCore.Functions.GetPlayer(src)
    -- if Player.PlayerData.job.name == "gondarm" and Player.PlayerData.job.onduty then
        -- TriggerClientEvent("gondarm:client:CuffPlayerSoft", src)
    -- else
        -- TriggerClientEvent('QBCore:Notify', src, 'بجب ان تكون داخل الخدمة', 'error')
    -- end
-- end)

QBCore.Commands.Add("cam", "فتح الكاميرا", {{name = "camid", help = "رقم"}}, false, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "gondarm" and Player.PlayerData.job.onduty then
        TriggerClientEvent("gondarm:client:ActiveCamera", src, tonumber(args[1]))
    else
        TriggerClientEvent('QBCore:Notify', src, 'بجب ان تكون داخل الخدمة', 'error')
    end
end)

QBCore.Commands.Add("flagplate", "الإبلاغ عن لوحة", {{name = "plate", help = "رقم اللوحة"}, {name = "reason", help = "السبب"}}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "gondarm" and Player.PlayerData.job.onduty then
        local reason = {}
        for i = 2, #args, 1 do
            reason[#reason+1] = args[i]
        end
        Plates[args[1]:upper()] = {
            isflagged = true,
            reason = table.concat(reason, " ")
        }
        TriggerClientEvent('QBCore:Notify', src, "السيارة (" .. args[1]:upper() .. ") تم الإبلاغ عنه لـ " .. table.concat(reason, " "))
    else
        TriggerClientEvent('QBCore:Notify', src, 'بجب ان تكون داخل الخدمة', 'error')
    end
end)

QBCore.Commands.Add("unflagplate", "الغاء ابلاغ عن سيارة", {{name = "plate", help = "اللوحة"}}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "gondarm" and Player.PlayerData.job.onduty then
        if Plates and Plates[args[1]:upper()] then
            if Plates[args[1]:upper()].isflagged then
                Plates[args[1]:upper()].isflagged = false
                TriggerClientEvent('QBCore:Notify', src, "السيارة (" .. args[1]:upper() .. ") تم الغاء الابلاغ عنها")
            else
                TriggerClientEvent('QBCore:Notify', src, 'لم يتم وضع علامة على السيارة', 'error')
            end
        else
            TriggerClientEvent('QBCore:Notify', src, 'لم يتم وضع علامة على السيارة', 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'بجب ان تكون داخل الخدمة', 'error')
    end
end)

QBCore.Commands.Add("plateinfo", "معلومات لوحة", {{name = "plate",help = "رقم اللوحة"}}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "gondarm" and Player.PlayerData.job.onduty then
        if Plates and Plates[args[1]:upper()] then
            if Plates[args[1]:upper()].isflagged then
                TriggerClientEvent('QBCore:Notify', src, 'السيارة ' .. args[1]:upper() .. ' تم الإبلاغ عنه لـ: ' .. Plates[args[1]:upper()].reason)
            else
                TriggerClientEvent('QBCore:Notify', src, 'لم يتم وضع علامة على السيارة', 'error')
            end
        else
            TriggerClientEvent('QBCore:Notify', src, 'لم يتم وضع علامة على السيارة', 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'بجب ان تكون داخل الخدمة', 'error')
    end
end)

QBCore.Commands.Add("depot", "حجز السيارة مع مخالفة", {{name = "price", help = "السعر"}}, false, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "gondarm" and Player.PlayerData.job.onduty then
        TriggerClientEvent("gondarm:client:ImpoundVehicle", src, false, tonumber(args[1]))
    else
        TriggerClientEvent('QBCore:Notify', src, 'بجب ان تكون داخل الخدمة', 'error')
    end
end)

QBCore.Commands.Add("impound", "حجز السيارة بدون مخلافة", {}, false, function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "gondarm" and Player.PlayerData.job.onduty then
        TriggerClientEvent("gondarm:client:ImpoundVehicle", src, true)
    else
        TriggerClientEvent('QBCore:Notify', src, 'بجب ان تكون داخل الخدمة', 'error')
    end
end)

-- QBCore.Commands.Add("paytow", "Pay Tow Driver (gondarm Only)", {{name = "id",help = "ID of the player"}}, true, function(source, args)
    -- local src = source
    -- local Player = QBCore.Functions.GetPlayer(src)
    -- if Player.PlayerData.job.name == "gondarm" and Player.PlayerData.job.onduty then
        -- local playerId = tonumber(args[1])
        -- local OtherPlayer = QBCore.Functions.GetPlayer(playerId)
        -- if OtherPlayer then
            -- if OtherPlayer.PlayerData.job.name == "tow" then
                -- OtherPlayer.Functions.AddMoney("bank", 500, "gondarm-tow-paid")
                -- TriggerClientEvent('QBCore:Notify', OtherPlayer.PlayerData.source, 'You were paid $500', 'success')
                -- TriggerClientEvent('QBCore:Notify', src, 'You paid the tow truck driver')
            -- else
                -- TriggerClientEvent('QBCore:Notify', src, 'Not a tow truck driver', 'error')
            -- end
        -- end
    -- else
        -- TriggerClientEvent('QBCore:Notify', src, 'بجب ان تكون داخل الخدمة', 'error')
    -- end
-- end)

-- QBCore.Commands.Add("paylawyer", "Pay Lawyer (gondarm, Judge Only)", {{name = "id",help = "ID of the player"}}, true, function(source, args)
    -- local src = source
    -- local Player = QBCore.Functions.GetPlayer(src)
    -- if Player.PlayerData.job.name == "gondarm" or Player.PlayerData.job.name == "judge" then
        -- local playerId = tonumber(args[1])
        -- local OtherPlayer = QBCore.Functions.GetPlayer(playerId)
        -- if OtherPlayer then
            -- if OtherPlayer.PlayerData.job.name == "lawyer" then
                -- OtherPlayer.Functions.AddMoney("bank", 500, "gondarm-lawyer-paid")
                -- TriggerClientEvent('QBCore:Notify', OtherPlayer.PlayerData.source, 'You were paid $500', 'success')
                -- TriggerClientEvent('QBCore:Notify', src, 'You paid a lawyer')
            -- else
                -- TriggerClientEvent('QBCore:Notify', src, 'Person is not a lawyer', "error")
            -- end
        -- end
    -- else
        -- TriggerClientEvent('QBCore:Notify', src, 'بجب ان تكون داخل الخدمة', 'error')
    -- end
-- end)

QBCore.Commands.Add("anklet", "اضافة خلخال تتبع", {}, false, function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "gondarm" and Player.PlayerData.job.onduty then
        TriggerClientEvent("gondarm:client:CheckDistance", src)
    else
        TriggerClientEvent('QBCore:Notify', src, 'بجب ان تكون داخل الخدمة', 'error')
    end
end)

QBCore.Commands.Add("ankletlocation", "تحصيل اماكن خلخال التتبع", {{name="cid", help="الايدي"}}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "gondarm" and Player.PlayerData.job.onduty then
        if args[1] then
            local citizenid = args[1]
            local Target = QBCore.Functions.GetPlayerByCitizenId(citizenid)
            if Target then
                if Target.PlayerData.metadata["tracker"] then
                    TriggerClientEvent("gondarm:client:SendTrackerLocation", Target.PlayerData.source, src)
                else
                    TriggerClientEvent('QBCore:Notify', src, 'هذا الشخص ليس لديه خلخال', 'error')
                end
            end
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'بجب ان تكون داخل الخدمة', 'error')
    end
end)

QBCore.Commands.Add("removeanklet", "الغاء خلخال التتبع", {{name="cid", help="الايدي"}}, true,function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "gondarm" and Player.PlayerData.job.onduty then
        if args[1] then
            local citizenid = args[1]
            local Target = QBCore.Functions.GetPlayerByCitizenId(citizenid)
            if Target then
                if Target.PlayerData.metadata["tracker"] then
                    TriggerClientEvent("gondarm:client:SendTrackerLocation", Target.PlayerData.source, src)
                else
                    TriggerClientEvent('QBCore:Notify', src, 'هذا الشخص ليس لديه خلخال', 'error')
                end
            end
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'بجب ان تكون داخل الخدمة', 'error')
    end
end)

QBCore.Commands.Add("takedrivinglicense", "حجز رخصة السياقة", {}, false, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "gondarm" and Player.PlayerData.job.onduty then
        TriggerClientEvent("gondarm:client:SeizeDriverLicense", source)
    else
        TriggerClientEvent('QBCore:Notify', src, 'بجب ان تكون داخل الخدمة', 'error')
    end
end)

QBCore.Commands.Add("takedna", "أخذ عينة من الحمض النووي من شخص", {{name="id", help="الايدي"}}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local OtherPlayer = QBCore.Functions.GetPlayer(tonumber(args[1]))
    if ((Player.PlayerData.job.name == "gondarm") and Player.PlayerData.job.onduty) and OtherPlayer then
        if Player.Functions.RemoveItem("empty_evidence_bag", 1) then
            local info = {
                label = "DNA",
                type = "dna",
                dnalabel = DnaHash(OtherPlayer.PlayerData.citizenid)
            }
            if Player.Functions.AddItem("filled_evidence_bag", 1, false, info) then
                TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items["filled_evidence_bag"], "add")
            end
        else
            TriggerClientEvent('QBCore:Notify', src, "يجب أن يكون معك حقيبة أدلة فارغة", "error")
        end
    end
end)

RegisterNetEvent('gondarm:server:SendTrackerLocation', function(coords, requestId)
    local Target = QBCore.Functions.GetPlayer(source)
    local msg = "" .. Target.PlayerData.charinfo.firstname .. " " .. Target.PlayerData.charinfo.lastname .. " تم وضع علامة على الخريطة"
    local alertData = {
        title = "حلحال التتبع",
        coords = {
            x = coords.x,
            y = coords.y,
            z = coords.z
        },
        description = msg
    }
    TriggerClientEvent("gondarm:client:TrackerMessage", requestId, msg, coords)
    TriggerClientEvent("qb-phone:client:addgondarmAlert", requestId, alertData)
end)

QBCore.Commands.Add('911p', 'ابلاغ الشرطة', {{name='message', help='السرالة'}}, false, function(source, args)
	local src = source
	if args[1] then message = table.concat(args, " ") else message = 'نداء مدني' end
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local players = QBCore.Functions.GetQBPlayers()
    for k,v in pairs(players) do
        if v.PlayerData.job.name == 'gondarm' and v.PlayerData.job.onduty then
            local alertData = {title = 'مكالمة جديدة ', coords = {coords.x, coords.y, coords.z}, description = message}
            TriggerClientEvent("qb-phone:client:addgondarmAlert", v.PlayerData.source, alertData)
            TriggerClientEvent('gondarm:client:gondarmAlert', v.PlayerData.source, coords, message)
        end
    end
end)

-- Items

QBCore.Functions.CreateUseableItem("handcuffs", function(source, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.Functions.GetItemByName(item.name) then
        TriggerClientEvent("gondarm:client:CuffPlayerSoft", src)
    end
end)

QBCore.Functions.CreateUseableItem("moneybag", function(source, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.Functions.GetItemByName(item.name) then
        if item.info and item.info ~= "" then
            if Player.PlayerData.job.name ~= "gondarm" then
                if Player.Functions.RemoveItem("moneybag", 1, item.slot) then
                    Player.Functions.AddMoney("cash", tonumber(item.info.cash), "used-moneybag")
                end
            end
        end
    end
end)

-- Callbacks

QBCore.Functions.CreateCallback('gondarm:server:isPlayerDead', function(source, cb, playerId)
    local Player = QBCore.Functions.GetPlayer(playerId)
    cb(Player.PlayerData.metadata["isdead"])
end)

QBCore.Functions.CreateCallback('gondarm:GetPlayerStatus', function(source, cb, playerId)
    local Player = QBCore.Functions.GetPlayer(playerId)
    local statList = {}
    if Player then
        if PlayerStatus[Player.PlayerData.source] and next(PlayerStatus[Player.PlayerData.source]) then
            for k, v in pairs(PlayerStatus[Player.PlayerData.source]) do
                statList[#statList+1] = PlayerStatus[Player.PlayerData.source][k].text
            end
        end
    end
    cb(statList)
end)

QBCore.Functions.CreateCallback('gondarm:IsSilencedWeapon', function(source, cb, weapon)
    local Player = QBCore.Functions.GetPlayer(source)
    local itemInfo = Player.Functions.GetItemByName(QBCore.Shared.Weapons[weapon]["name"])
    local retval = false
    if itemInfo then
        if itemInfo.info and itemInfo.info.attachments then
            for k, v in pairs(itemInfo.info.attachments) do
                if itemInfo.info.attachments[k].component == "COMPONENT_AT_AR_SUPP_02" or
                    itemInfo.info.attachments[k].component == "COMPONENT_AT_AR_SUPP" or
                    itemInfo.info.attachments[k].component == "COMPONENT_AT_PI_SUPP_02" or
                    itemInfo.info.attachments[k].component == "COMPONENT_AT_PI_SUPP" then
                    retval = true
                end
            end
        end
    end
    cb(retval)
end)

QBCore.Functions.CreateCallback('gondarm:GetDutyPlayers', function(source, cb)
    local dutyPlayers = {}
    local players = QBCore.Functions.GetQBPlayers()
    for k, v in pairs(players) do
        if v.PlayerData.job.name == "gondarm" and v.PlayerData.job.onduty then
            dutyPlayers[#dutyPlayers+1] = {
                source = Player.PlayerData.source,
                label = Player.PlayerData.metadata["callsign"],
                job = Player.PlayerData.job.name
            }
        end
    end
    cb(dutyPlayers)
end)

QBCore.Functions.CreateCallback('gondarm:GetImpoundedVehicles', function(source, cb)
    local vehicles = {}
    exports.oxmysql:execute('SELECT * FROM player_vehicles WHERE state = ?', {2}, function(result)
        if result[1] then
            vehicles = result
        end
        cb(vehicles)
    end)
end)

QBCore.Functions.CreateCallback('gondarm:IsPlateFlagged', function(source, cb, plate)
    local retval = false
    if Plates and Plates[plate] then
        if Plates[plate].isflagged then
            retval = true
        end
    end
    cb(retval)
end)

QBCore.Functions.CreateCallback('gondarm:GetCops', function(source, cb)
    local amount = 0
    local players = QBCore.Functions.GetQBPlayers()
    for k, v in pairs(players) do
        if v.PlayerData.job.name == "gondarm" and v.PlayerData.job.onduty then
            amount = amount + 1
        end
    end
    cb(amount)
end)

QBCore.Functions.CreateCallback('gondarm:server:IsgondarmForcePresent', function(source, cb)
    local retval = false
    local players = QBCore.Functions.GetQBPlayers()
    for k, v in pairs(players) do
        if v.PlayerData.job.name == "gondarm" and v.PlayerData.job.grade.level >= 2 then
            retval = true
            break
        end
    end
    cb(retval)
end)

-- Events

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        CreateThread(function()
            exports.oxmysql:execute('DELETE FROM stashitems WHERE stash="gondarmtrash"')
        end)
    end
end)

RegisterNetEvent('gondarm:server:gondarmAlert', function(text)
    local src = source
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local players = QBCore.Functions.GetQBPlayers()
    for k,v in pairs(players) do
        if v.PlayerData.job.name == 'gondarm' and v.PlayerData.job.onduty then
            local alertData = {title = 'ابلاغ جديد ', coords = {coords.x, coords.y, coords.z}, description = text}
            TriggerClientEvent("qb-phone:client:addgondarmAlert", v.PlayerData.source, alertData)
            TriggerClientEvent('gondarm:client:gondarmAlert', v.PlayerData.source, coords, text)
        end
    end
end)

RegisterNetEvent('gondarm:server:TakeOutImpound', function(plate)
    local src = source
    exports.oxmysql:execute('UPDATE player_vehicles SET state = ? WHERE plate  = ?', {0, plate})
    TriggerClientEvent('QBCore:Notify', src, "مركبة غير مقيدة", 'success')
end)

RegisterNetEvent('gondarm:server:CuffPlayer', function(playerId, isSoftcuff)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local CuffedPlayer = QBCore.Functions.GetPlayer(playerId)
    if CuffedPlayer then
        if Player.Functions.GetItemByName("handcuffs") or Player.PlayerData.job.name == "gondarm" then
            TriggerClientEvent("gondarm:client:GetCuffed", CuffedPlayer.PlayerData.source, Player.PlayerData.source, isSoftcuff)
        end
    end
end)

RegisterNetEvent('gondarm:server:EscortPlayer', function(playerId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(source)
    local EscortPlayer = QBCore.Functions.GetPlayer(playerId)
    if EscortPlayer then
        if (Player.PlayerData.job.name == "gondarm" or Player.PlayerData.job.name == "ambulance") or (EscortPlayer.PlayerData.metadata["ishandcuffed"] or EscortPlayer.PlayerData.metadata["isdead"] or EscortPlayer.PlayerData.metadata["inlaststand"]) then
            TriggerClientEvent("gondarm:client:GetEscorted", EscortPlayer.PlayerData.source, Player.PlayerData.source)
        else
            TriggerClientEvent('QBCore:Notify', src, "يجب ان يتم كلبشته لتسحبه", 'error')
        end
    end
end)

RegisterNetEvent('gondarm:server:KidnapPlayer', function(playerId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(source)
    local EscortPlayer = QBCore.Functions.GetPlayer(playerId)
    if EscortPlayer then
        if EscortPlayer.PlayerData.metadata["ishandcuffed"] or EscortPlayer.PlayerData.metadata["isdead"] or
            EscortPlayer.PlayerData.metadata["inlaststand"] then
            TriggerClientEvent("gondarm:client:GetKidnappedTarget", EscortPlayer.PlayerData.source, Player.PlayerData.source)
            TriggerClientEvent("gondarm:client:GetKidnappedDragger", Player.PlayerData.source, EscortPlayer.PlayerData.source)
        else
            TriggerClientEvent('QBCore:Notify', src, "ليس مكلبش او ميت", 'error')
        end
    end
end)

RegisterNetEvent('gondarm:server:SetPlayerOutVehicle', function(playerId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(source)
    local EscortPlayer = QBCore.Functions.GetPlayer(playerId)
    if EscortPlayer then
        if EscortPlayer.PlayerData.metadata["ishandcuffed"] or EscortPlayer.PlayerData.metadata["isdead"] then
            TriggerClientEvent("gondarm:client:SetOutVehicle", EscortPlayer.PlayerData.source)
        else
            TriggerClientEvent('QBCore:Notify', src, "ليس مكلبش او ميت", 'error')
        end
    end
end)

RegisterNetEvent('gondarm:server:PutPlayerInVehicle', function(playerId)
    local src = source
    local EscortPlayer = QBCore.Functions.GetPlayer(playerId)
    if EscortPlayer then
        if EscortPlayer.PlayerData.metadata["ishandcuffed"] or EscortPlayer.PlayerData.metadata["isdead"] then
            TriggerClientEvent("gondarm:client:PutInVehicle", EscortPlayer.PlayerData.source)
        else
           TriggerClientEvent('QBCore:Notify', src, "ليس مكلبش او ميت", 'error')
        end
    end
end)

RegisterNetEvent('gondarm:server:BillPlayer', function(playerId, price)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local OtherPlayer = QBCore.Functions.GetPlayer(playerId)
    if Player.PlayerData.job.name == "gondarm" then
        if OtherPlayer then
            OtherPlayer.Functions.RemoveMoney("bank", price, "paid-bills")
            TriggerEvent('qb-bossmenu:server:addAccountMoney', "gondarm", price)
            TriggerClientEvent('QBCore:Notify', OtherPlayer.PlayerData.source, "لقد تلقيت غرامة قدرها $" .. price)
        end
    end
end)

RegisterNetEvent('gondarm:server:JailPlayer', function(playerId, time)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local OtherPlayer = QBCore.Functions.GetPlayer(playerId)
    local currentDate = os.date("*t")
    if currentDate.day == 31 then
        currentDate.day = 30
    end

    if Player.PlayerData.job.name == "gondarm" then
        if OtherPlayer then
            OtherPlayer.Functions.SetMetaData("injail", time)
            OtherPlayer.Functions.SetMetaData("criminalrecord", {
                ["hasRecord"] = true,
                ["date"] = currentDate
            })
            TriggerClientEvent("gondarm:client:SendToJail", OtherPlayer.PlayerData.source, time)
            TriggerClientEvent('QBCore:Notify', src, "لقد أرسلت الشخص بأكثر من " .. time .. " شهر")
        end
    end
end)

RegisterNetEvent('gondarm:server:SetHandcuffStatus', function(isHandcuffed)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        Player.Functions.SetMetaData("ishandcuffed", isHandcuffed)
    end
end)

RegisterNetEvent('heli:spotlight', function(state)
    local serverID = source
    TriggerClientEvent('heli:spotlight', -1, serverID, state)
end)

-- RegisterNetEvent('gondarm:server:FlaggedPlateTriggered', function(camId, plate, street1, street2, blipSettings)
--     local src = source
--     for k, v in pairs(QBCore.Functions.GetPlayers()) do
--         local Player = QBCore.Functions.GetPlayer(v)
--         if Player then
--             if (Player.PlayerData.job.name == "gondarm" and Player.PlayerData.job.onduty) then
--                 if street2 then
--                     TriggerClientEvent("112:client:SendgondarmAlert", v, "flagged", {
--                         camId = camId,
--                         plate = plate,
--                         streetLabel = street1 .. " " .. street2
--                     }, blipSettings)
--                 else
--                     TriggerClientEvent("112:client:SendgondarmAlert", v, "flagged", {
--                         camId = camId,
--                         plate = plate,
--                         streetLabel = street1
--                     }, blipSettings)
--                 end
--             end
--         end
--     end
-- end)

RegisterNetEvent('gondarm:server:SearchPlayer', function(playerId)
    local src = source
    local SearchedPlayer = QBCore.Functions.GetPlayer(playerId)
    if SearchedPlayer then
        TriggerClientEvent('QBCore:Notify', src, '$'..SearchedPlayer.PlayerData.money["cash"]..' تم تحصيل')
        TriggerClientEvent('QBCore:Notify', SearchedPlayer.PlayerData.source, "يتم تفتيشك")
    end
end)

RegisterNetEvent('gondarm:server:SeizeCash', function(playerId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local SearchedPlayer = QBCore.Functions.GetPlayer(playerId)
    if SearchedPlayer then
        local moneyAmount = SearchedPlayer.PlayerData.money["cash"]
        local info = { cash = moneyAmount }
        SearchedPlayer.Functions.RemoveMoney("cash", moneyAmount, "gondarm-cash-seized")
        Player.Functions.AddItem("moneybag", 1, false, info)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["moneybag"], "add")
        TriggerClientEvent('QBCore:Notify', SearchedPlayer.PlayerData.source, 'تمت مصادرة أموالك')
    end
end)

RegisterNetEvent('gondarm:server:SeizeDriverLicense', function(playerId)
    local src = source
    local SearchedPlayer = QBCore.Functions.GetPlayer(playerId)
    if SearchedPlayer then
        local driverLicense = SearchedPlayer.PlayerData.metadata["licences"]["driver"]
        if driverLicense then
            local licenses = {["driver"] = false, ["business"] = SearchedPlayer.PlayerData.metadata["licences"]["business"]}
            SearchedPlayer.Functions.SetMetaData("licences", licenses)
            TriggerClientEvent('QBCore:Notify', SearchedPlayer.PlayerData.source, 'تمت مصادرة رخصة قيادتك')
        else
            TriggerClientEvent('QBCore:Notify', src, 'بدون رخصة قيادة', 'error')
        end
    end
end)

RegisterNetEvent('gondarm:server:RobPlayer', function(playerId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local SearchedPlayer = QBCore.Functions.GetPlayer(playerId)
    if SearchedPlayer then
        local money = SearchedPlayer.PlayerData.money["cash"]
        Player.Functions.AddMoney("cash", money, "gondarm-player-robbed")
        SearchedPlayer.Functions.RemoveMoney("cash", money, "gondarm-player-robbed")
        TriggerClientEvent('QBCore:Notify', SearchedPlayer.PlayerData.source, "لقد سلب منك $" .. money)
        TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, "لقد سرقت $" .. money)
    end
end)

RegisterNetEvent('gondarm:server:UpdateBlips', function()
    -- KEEP FOR REF BUT NOT NEEDED ANYMORE.
end)

RegisterNetEvent('gondarm:server:spawnObject', function(type)
    local src = source
    local objectId = CreateObjectId()
    Objects[objectId] = type
    TriggerClientEvent("gondarm:client:spawnObject", src, objectId, type, src)
end)

RegisterNetEvent('gondarm:server:deleteObject', function(objectId)
    TriggerClientEvent('gondarm:client:removeObject', -1, objectId)
end)

RegisterNetEvent('gondarm:server:Impound', function(plate, fullImpound, price, body, engine, fuel)
    local src = source
    local price = price and price or 0
    if IsVehicleOwned(plate) then
        if not fullImpound then
            exports.oxmysql:execute(
                'UPDATE player_vehicles SET state = ?, depotprice = ?, body = ?, engine = ?, fuel = ? WHERE plate = ?',
                {0, price, body, engine, fuel, plate})
            TriggerClientEvent('QBCore:Notify', src, "السيارة التي تم أخذها إلى المستودع ب $" .. price .. "!")
        else
            exports.oxmysql:execute(
                'UPDATE player_vehicles SET state = ?, body = ?, engine = ?, fuel = ? WHERE plate = ?',
                {2, body, engine, fuel, plate})
            TriggerClientEvent('QBCore:Notify', src, "سيارة محجوزة")
        end
    end
end)

RegisterNetEvent('evidence:server:UpdateStatus', function(data)
    local src = source
    PlayerStatus[src] = data
end)

RegisterNetEvent('evidence:server:CreateBloodDrop', function(citizenid, bloodtype, coords)
    local bloodId = CreateBloodId()
    BloodDrops[bloodId] = {
        dna = citizenid,
        bloodtype = bloodtype
    }
    TriggerClientEvent("evidence:client:AddBlooddrop", -1, bloodId, citizenid, bloodtype, coords)
end)

RegisterNetEvent('evidence:server:CreateFingerDrop', function(coords)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local fingerId = CreateFingerId()
    FingerDrops[fingerId] = Player.PlayerData.metadata["fingerprint"]
    TriggerClientEvent("evidence:client:AddFingerPrint", -1, fingerId, Player.PlayerData.metadata["fingerprint"], coords)
end)

RegisterNetEvent('evidence:server:ClearBlooddrops', function(blooddropList)
    if blooddropList and next(blooddropList) then
        for k, v in pairs(blooddropList) do
            TriggerClientEvent("evidence:client:RemoveBlooddrop", -1, v)
            BloodDrops[v] = nil
        end
    end
end)

RegisterNetEvent('evidence:server:AddBlooddropToInventory', function(bloodId, bloodInfo)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.Functions.RemoveItem("empty_evidence_bag", 1) then
        if Player.Functions.AddItem("filled_evidence_bag", 1, false, bloodInfo) then
            TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items["filled_evidence_bag"], "add")
            TriggerClientEvent("evidence:client:RemoveBlooddrop", -1, bloodId)
            BloodDrops[bloodId] = nil
        end
    else
        TriggerClientEvent('QBCore:Notify', src, "يجب أن يكون معك حقيبة أدلة فارغة", "error")
    end
end)

RegisterNetEvent('evidence:server:AddFingerprintToInventory', function(fingerId, fingerInfo)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.Functions.RemoveItem("empty_evidence_bag", 1) then
        if Player.Functions.AddItem("filled_evidence_bag", 1, false, fingerInfo) then
            TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items["filled_evidence_bag"], "add")
            TriggerClientEvent("evidence:client:RemoveFingerprint", -1, fingerId)
            FingerDrops[fingerId] = nil
        end
    else
        TriggerClientEvent('QBCore:Notify', src, "يجب أن يكون معك حقيبة أدلة فارغة", "error")
    end
end)

RegisterNetEvent('evidence:server:CreateCasing', function(weapon, coords)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local casingId = CreateCasingId()
    local weaponInfo = QBCore.Shared.Weapons[weapon]
    local serieNumber = nil
    if weaponInfo then
        local weaponItem = Player.Functions.GetItemByName(weaponInfo["name"])
        if weaponItem then
            if weaponItem.info and weaponItem.info ~= "" then
                serieNumber = weaponItem.info.serie
            end
        end
    end
    TriggerClientEvent("evidence:client:AddCasing", -1, casingId, weapon, coords, serieNumber)
end)

RegisterNetEvent('gondarm:server:UpdateCurrentCops', function()
    local amount = 0
    local players = QBCore.Functions.GetQBPlayers()
    for k, v in pairs(players) do
        if v.PlayerData.job.name == "gondarm" and v.PlayerData.job.onduty then
            amount = amount + 1
        end
    end
    TriggerClientEvent("gondarm:SetCopCount", -1, amount)
end)

RegisterNetEvent('evidence:server:ClearCasings', function(casingList)
    if casingList and next(casingList) then
        for k, v in pairs(casingList) do
            TriggerClientEvent("evidence:client:RemoveCasing", -1, v)
            Casings[v] = nil
        end
    end
end)

RegisterNetEvent('evidence:server:AddCasingToInventory', function(casingId, casingInfo)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.Functions.RemoveItem("empty_evidence_bag", 1) then
        if Player.Functions.AddItem("filled_evidence_bag", 1, false, casingInfo) then
            TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items["filled_evidence_bag"], "add")
            TriggerClientEvent("evidence:client:RemoveCasing", -1, casingId)
            Casings[casingId] = nil
        end
    else
        TriggerClientEvent('QBCore:Notify', src, "يجب أن يكون معك حقيبة أدلة فارغة", "error")
    end
end)

RegisterNetEvent('gondarm:server:showFingerprint', function(playerId)
    local src = source
    TriggerClientEvent('gondarm:client:showFingerprint', playerId, src)
    TriggerClientEvent('gondarm:client:showFingerprint', src, playerId)
end)

RegisterNetEvent('gondarm:server:showFingerprintId', function(sessionId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local fid = Player.PlayerData.metadata["fingerprint"]
    TriggerClientEvent('gondarm:client:showFingerprintId', sessionId, fid)
    TriggerClientEvent('gondarm:client:showFingerprintId', src, fid)
end)

RegisterNetEvent('gondarm:server:SetTracker', function(targetId)
    local src = source
    local Target = QBCore.Functions.GetPlayer(targetId)
    local TrackerMeta = Target.PlayerData.metadata["tracker"]
    if TrackerMeta then
        Target.Functions.SetMetaData("tracker", false)
        TriggerClientEvent('QBCore:Notify', targetId, 'خلعك خلع', 'error', 5000)
        TriggerClientEvent('QBCore:Notify', src, 'خلعت الخلخال من ' .. Target.PlayerData.charinfo.firstname .. " " .. Target.PlayerData.charinfo.lastname, 'error', 5000)
        TriggerClientEvent('gondarm:client:SetTracker', targetId, false)
    else
        Target.Functions.SetMetaData("tracker", true)
        TriggerClientEvent('QBCore:Notify', targetId, 'أنت ترتدي خلخال', 'error', 5000)
        TriggerClientEvent('QBCore:Notify', src, 'كنت ترتدي خلخال تتبع ' .. Target.PlayerData.charinfo.firstname .. " " .. Target.PlayerData.charinfo.lastname, 'error', 5000)
        TriggerClientEvent('gondarm:client:SetTracker', targetId, true)
    end
end)

RegisterNetEvent('gondarm:server:SendTrackerLocation', function(coords, requestId)
    local Target = QBCore.Functions.GetPlayer(source)
    local msg = "تم كشف مكان " .. Target.PlayerData.charinfo.firstname .. " " .. Target.PlayerData.charinfo.lastname .. ""
    local alertData = {
        title = "Anklet location",
        coords = {
            x = coords.x,
            y = coords.y,
            z = coords.z
        },
        description = msg
    }
    TriggerClientEvent("gondarm:client:TrackerMessage", requestId, msg, coords)
    TriggerClientEvent("qb-phone:client:addgondarmAlert", requestId, alertData)
end)

RegisterNetEvent('gondarm:server:SyncSpikes', function(table)
    TriggerClientEvent('gondarm:client:SyncSpikes', -1, table)
end)

-- Threads

CreateThread(function()
    while true do
        Wait(1000 * 60 * 10)
        local curCops = GetCurrentCops()
        TriggerClientEvent("gondarm:SetCopCount", -1, curCops)
    end
end)

CreateThread(function()
    while true do
        Wait(5000)
        UpdateBlips()
    end
end)
