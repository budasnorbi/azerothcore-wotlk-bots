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

local function HandleChatCommand(event, player, message, type, language)
    -- Convert message to lowercase for case-insensitive comparison
    local normalizedMessage = string.lower(message)

    for action, commandList in pairs(commands) do
        for _, command in ipairs(commandList) do
            if normalizedMessage == command then
                if action == "bank" then
                    player:SendShowBank(player)
                elseif action == "mail" then
                    player:SendShowMail(player)
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
