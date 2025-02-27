--[[
    Created by iThorgrim

        Parangon with Interface

 You are going to use a script shared by myself (iThorgrim) so i would ask you to respect my work and not to assign this work to you.
 If you want to learn more about World of Warcraft development.

 (Only for French speaking people.)
 Open-Wow -> https://open-wow.eu
 Discord -> https://discord.gg/JUYgbNMwQu

 If you wish to thank me for my work you can make a small donation.
 Paypal ->

 Thank you for using my script, if you have a suggestion or a problem with it please make a topic about it:
 Issues -> https://github.com/iThorgrim-Hub/lua-aio-parangon/issues

 See you soon for a next script.
]] --


local AIO = AIO or require("aio")

local parangon = {

    config = {
        charDbName = 'acore_characters',
        authDbName = 'acore_auth',

        pointsPerLevel = 1,
        minLevel = 1,

        expMulti = 1,
        expMax = 500,

        pveKill = 100,
        pvpKill = 10,

        levelDiff = 3,
    },

    spells = {
        [7464] = 'Strength',
        [7471] = 'Agility',
        [7477] = 'Stamina',
        [7468] = 'Intellect',
        [7474] = 'Spirit',
    },
}

local parangon_addon = AIO.AddHandlers("AIO_Parangon", {})

parangon.account = {}

function parangon_addon.sendInformations(msg, player)
    if(player:IsBot()) then
        return
    end

    local pGuid = player:GetGUIDLow()
    local pAcc = player:GetAccountId()

    local temp = {
        stats = {},
        level = 1,
        points = 1,
    }
    for stat, _ in pairs(parangon.spells) do
        temp.stats[stat] = player:GetData('parangon_stats_' .. stat)
    end

    if not parangon.account[pAcc] then
        parangon.account[pAcc] = {
            level = 1,
            exp = 0,
            exp_max = 0,
        }
    end

    temp.level = parangon.account[player:GetAccountId()].level
    temp.points = player:GetData('parangon_points')
    temp.exps = {
        exp = parangon.account[player:GetAccountId()].exp,
        exp_max = parangon.account[player:GetAccountId()].exp_max
    }

    return msg:Add("AIO_Parangon", "setInfo", temp.stats, temp.level, temp
        .points, temp.exps)
end

AIO.AddOnInit(parangon_addon.sendInformations)

function parangon.setAddonInfo(player)
    if(player:IsBot()) then
        return
    end

    parangon_addon.sendInformations(AIO.Msg(), player):Send(player)
end

function parangon.onServerStart(event)
    AuthDBQuery('CREATE TABLE IF NOT EXISTS `' ..
        parangon.config.authDbName ..
        '`.`account_parangon` (`account_id` INT(11) NOT NULL, `level` INT(11) DEFAULT 1, `exp` INT(11) DEFAULT 0, PRIMARY KEY (`account_id`) );');
    CharDBExecute('CREATE TABLE IF NOT EXISTS `' ..
        parangon.config.charDbName ..
        '`.`characters_parangon` (`account_id` INT(11) NOT NULL, `guid` INT(11) NOT NULL, `strength` TINYINT UNSIGNED DEFAULT 0, `agility` TINYINT UNSIGNED DEFAULT 0, `stamina` TINYINT UNSIGNED DEFAULT 0, `intellect` TINYINT UNSIGNED DEFAULT 0, `spirit` TINYINT UNSIGNED DEFAULT 0, PRIMARY KEY (`account_id`, `guid`));');
    io.write('Eluna :: Parangon System start \n')
end



function parangon_addon.setStats(player)
    if(player:IsBot()) then
        return
    end

    local pLevel = player:GetLevel()

    if pLevel >= parangon.config.minLevel then
        for spell, _ in pairs(parangon.spells) do
            player:RemoveAura(spell)
            player:AddAura(spell, player)
            player:GetAura(spell):SetStackAmount(player:GetData(
                'parangon_stats_' .. spell))
        end
    end
end


local prevTime = os.clock()
-- flags
-- true == add_points
-- false == remove_points
function parangon_addon.setStatsInformation(player, stat, value, flags)
    if(player:IsBot()) then
        return
    end
    if(player:IsInCombat())then
        return
    end

    local currentTime = os.clock()

    if(currentTime - prevTime < 0.1) then
        return
    end

    local pLevel = player:GetLevel()
    local paragonPoints =player:GetData('parangon_points')
    local statValue = player:GetData('parangon_stats_' .. stat)
    local paragonPointsSpend = player:GetData('parangon_points_spend')
    if (pLevel >= parangon.config.minLevel) then
        if flags then
            if ((paragonPoints - value) >= 0 and statValue + value <= 255) then
                player:SetData('parangon_stats_' .. stat,
                    (statValue + value))
                player:SetData('parangon_points',
                    (paragonPoints - value))


                    print('Parangon Points: ' .. paragonPoints)
                player:SetData('parangon_points_spend',
                    (paragonPointsSpend + value))

                SavePlayerPoints(player)
            else
                return false
            end
        else
            if (statValue > 0) then
                player:SetData('parangon_stats_' .. stat,
                    (statValue - value))
                player:SetData('parangon_points',
                    (paragonPoints + value))

                    print('Parangon Points: ' .. paragonPoints)
                player:SetData('parangon_points_spend',
                    (paragonPointsSpend - value))

                SavePlayerPoints(player)
            else
                return false
            end
        end
        parangon.setAddonInfo(player)
    end

    prevTime = currentTime
end

function Player:setParangonInfo(strength, agility, stamina, intellect, spirit)
    self:SetData('parangon_stats_7464', strength)
    self:SetData('parangon_stats_7471', agility)
    self:SetData('parangon_stats_7477', stamina)
    self:SetData('parangon_stats_7468', intellect)
    self:SetData('parangon_stats_7474', spirit)
end

function parangon.onLogin(event, player)
    if(player:IsBot()) then
        return
    end

    local pAcc = player:GetAccountId()
    local pGuid = player:GetGUIDLow()

    local getParangonCharInfo = CharDBQuery(
        'SELECT * FROM `' ..
        parangon.config.charDbName ..
        '`.`characters_parangon` WHERE account_id = ' .. pAcc .. ' AND guid =' .. pGuid)

    -- account_id, guid, strength, agility, stamina, intellect, spirit

    if getParangonCharInfo then
        local strength = getParangonCharInfo:GetUInt8(2)
        local agility = getParangonCharInfo:GetUInt8(3)
        local stamina = getParangonCharInfo:GetUInt8(4)
        local intellect = getParangonCharInfo:GetUInt8(5)
        local spirit = getParangonCharInfo:GetUInt8(6)

        local pointSpend = strength + agility + stamina + intellect + spirit
        player:setParangonInfo(strength, agility, stamina, intellect, spirit)
        player:SetData('parangon_points', pointSpend)
        player:SetData('parangon_points_spend', pointSpend)
    else

        CharDBExecute('INSERT INTO `' ..
            parangon.config.charDbName ..
            '`.`characters_parangon` VALUES (' ..
            pAcc .. ', ' .. pGuid .. ', 0, 0, 0, 0, 0)')
        player:setParangonInfo(0, 0, 0, 0, 0)
        player:SetData('parangon_points', 0)
        player:SetData('parangon_points_spend', 0)
    end



    if not parangon.account[pAcc] then
        parangon.account[pAcc] = {
            level = 1,
            exp = 0,
            exp_max = 0,
        }
    end

    local getParangonAccInfo = AuthDBQuery('SELECT level, exp FROM `' ..
        parangon.config.authDbName ..
        '`.`account_parangon` WHERE account_id = ' .. pAcc)
    if getParangonAccInfo then
        parangon.account[pAcc].level = getParangonAccInfo:GetUInt32(0)
        parangon.account[pAcc].exp = getParangonAccInfo:GetUInt32(1)
        parangon.account[pAcc].exp_max = parangon.config.expMax *
            parangon.account[pAcc].level
    else
        AuthDBExecute('INSERT INTO `' ..
            parangon.config.authDbName ..
            '`.`account_parangon` VALUES (' .. pAcc .. ', 1, 0)')
    end

    parangon_addon.setStats(player)
    player:SetData('parangon_points',
        (parangon.account[pAcc].level * parangon.config.pointsPerLevel) -
        player:GetData('parangon_points'))
end



function parangon.getPlayers(event)
    for _, player in pairs(GetPlayersInWorld()) do
        if(player:IsBot()) then goto continue end
        parangon.onLogin(event, player)
        ::continue::
    end
    io.write('Eluna :: Parangon System start \n')
end



function parangon.onLogout(event, player)
    if(player:IsBot()) then
        return
    end

    SavePlayerPoints(player)

    local pAcc = player:GetAccountId()

    if not parangon.account[pAcc] then
        parangon.account[pAcc] = {
            level = 1,
            exp = 0,
            exp_max = 0,
        }
    end

    local level, exp = parangon.account[pAcc].level, parangon.account[pAcc].exp
    AuthDBExecute('REPLACE INTO `' ..
        parangon.config.authDbName ..
        '`.`account_parangon` VALUES (' ..
        pAcc .. ', ' .. level .. ', ' .. exp .. ')')
end


function parangon.setPlayers(event)
    for _, player in pairs(GetPlayersInWorld()) do
        if(player:IsBot()) then goto continue end
        parangon.onLogout(event, player)
        ::continue::
    end
end



function parangon.setExp(player, victim)
    if(player:IsBot()) then
        return
    end
    local pAcc = player:GetAccountId()

    if not parangon.account[pAcc] then
        return
    end

    local pLevel = player:GetLevel()
    local vLevel = victim:GetLevel()


    local levelDiff = math.abs(vLevel - pLevel)

    if (levelDiff <= parangon.config.levelDiff) and (levelDiff >= 0) then
        local isPlayer = GetGUIDEntry(victim:GetGUID())
        if (isPlayer == 0) then
            parangon.account[pAcc].exp = parangon.account[pAcc].exp +
                parangon.config.pvpKill
            player:SendBroadcastMessage('Your victim gives you ' ..
                parangon.config.pvpKill .. ' Parangon experience points.')
        else
            parangon.account[pAcc].exp = parangon.account[pAcc].exp +
                parangon.config.pveKill
            player:SendBroadcastMessage('Your victim gives you ' ..
                parangon.config.pveKill .. ' Parangon experience points.')
        end
        parangon.setAddonInfo(player)
    end

    if parangon.account[pAcc].exp >= parangon.account[pAcc].exp_max then
        player:SetParangonLevel()
    end
end

function parangon.onKillCreatureOrPlayer(event, player, victim)
    if(player:IsBot()) then
        return
    end

    local pLevel = player:GetLevel()

    if (pLevel >= parangon.config.minLevel) then
        local pGroup = player:GetGroup()
        if pGroup then
            for _, player in pairs(pGroup:GetMembers()) do
                parangon.setExp(player, victim)
            end
        else
            parangon.setExp(player, victim)
        end
    end
end


function Player:SetParangonLevel()
    local pAcc = self:GetAccountId()

    if not parangon.account[pAcc] then
        return
    end


    parangon.account[pAcc].level = parangon.account[pAcc].level + 1

    parangon.account[pAcc].exp = 0
    parangon.account[pAcc].exp_max = parangon.config.expMax *
        parangon.account[pAcc].level

    -- Get the current level and points information
    local pointsSpent = self:GetData('parangon_points_spend') or 0
    local currentLevel = parangon.account[pAcc].level

    -- Calculate the total points that should be available based on the current level
    local totalEarnedPoints = currentLevel * parangon.config.pointsPerLevel

    -- Calculate the new points available to spend
    local newAvailablePoints = totalEarnedPoints - pointsSpent


    -- Update the parangon points
    self:SetData('parangon_points', newAvailablePoints)

    parangon.setAddonInfo(self)

    self:CastSpell(self, 40436, true)
    self:SendNotification(
        '|CFF00A2FFYou have just passed a level of Paragon.\nCongratulations, you are now level ' ..
        parangon.account[pAcc].level .. '!')

end

function SavePlayerPoints(player)
    if(player:IsBot())then
        return
    end

    local pAcc = player:GetAccountId()
    local pGuid = player:GetGUIDLow()

    local strength =  player:GetData('parangon_stats_7464')
    local agility = player:GetData('parangon_stats_7471')
    local stamina = player:GetData('parangon_stats_7477')
    local intellect = player:GetData('parangon_stats_7468')
    local spirit = player:GetData('parangon_stats_7474')

    CharDBQuery('REPLACE INTO `' ..
        parangon.config.charDbName ..
        '`.`characters_parangon` VALUES (' ..
        pAcc ..
        ', ' ..
        pGuid ..
        ', ' ..
        strength ..
        ', ' .. agility .. ', ' .. stamina .. ', ' .. intellect .. ', ' .. spirit .. ')')

    parangon_addon.setStats(player)
end

RegisterPlayerEvent(4, parangon.onLogout)
RegisterPlayerEvent(3, parangon.onLogin)
RegisterPlayerEvent(6, parangon.onKillCreatureOrPlayer)
RegisterPlayerEvent(7, parangon.onKillCreatureOrPlayer)

RegisterServerEvent(16, parangon.setPlayers)
RegisterServerEvent(14, parangon.onServerStart)
RegisterServerEvent(33, parangon.getPlayers)
