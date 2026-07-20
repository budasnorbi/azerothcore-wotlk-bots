-- ----------------------------------------------------------------------------------------------------------
--  While in-game, just pre-pend any of the commands below with "!" or "."  For example, ".bank" or "!mail".
--  You can also type "#commands" or "$commands" to display the list of available commands.
--
--  Hosted by Aldori15 on Github: https://github.com/Aldori15/global-mail_banking_auctions
-- ----------------------------------------------------------------------------------------------------------

-- Table to store list of possible commands
local commands = {
    bank = { "bank", "openbank" },  -- Chat variations for opening the bank
    mail = { "mail", "mailbox" },  -- Chat variations for opening the mailbox
    auction = { "auctions", "ah", "auctionhouse" },  -- Chat variations for opening the auction house
}

-- PLAYER_EVENT_ON_COMMAND (42) passes (event, player, command, chatHandler).
-- The leading "." or "!" has already been stripped by ChatHandler::ParseCommands.
local function HandleChatCommand(event, player, command, chatHandler)
    -- player is nil when the command comes from the server console
    if not player then
        return
    end

    -- Convert command to lowercase for case-insensitive comparison
    local normalizedCommand = string.lower(command)

    for action, commandList in pairs(commands) do
        for _, cmd in ipairs(commandList) do
            if normalizedCommand == cmd then
                if action == "bank" then
                    player:SendShowBank(player)
                elseif action == "mail" then
                    player:SendShowMailBox()
                elseif action == "auction" then
                    player:SendAuctionMenu(player)
                end
                -- Return false to prevent further processing
                return false
            end
        end
    end
end


RegisterPlayerEvent(42, HandleChatCommand)
