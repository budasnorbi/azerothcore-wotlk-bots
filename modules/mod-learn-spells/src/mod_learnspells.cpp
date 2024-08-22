#include "Player.h"
#include "ScriptMgr.h"
#include "SpellInfo.h"
#include "SpellMgr.h"
#include <string>

std::vector<uint32> professions = {
    //Primary Professions
    164, // Blacksmithing
    165, // Leatherworking
    171, // Alchemy
    182, // Herbalism
    186, // Mining
    197, // Tailoring
    202, // Engineering
    333, // Enchanting
    393, // Skinning
    755, // Jewelcrafting
    773, // Inscription
    // Secondary Professions
    356, // Fishing
    185, // Cooking
    129, // First Aid
};

std::vector<std::pair<std::string, uint32>> skills = {
 {"SWORDS", 43}, {"AXES", 44}, {"BOWS", 45}, {"GUNS", 46}, {"MACES", 54}, {"2H_SWORDS", 55}, {"DEFENSE", 95}, {"STAVES", 136}, {"2H_MACES", 160}, {"2H_AXES", 172}, {"DAGGERS", 173}, {"THROWN", 176}, {"CROSSBOWS", 226},  {"WANDS", 228}, {"POLEARMS", 229}, {"PLATE_MAIL", 293}, {"LEATHER", 414}, {"CLOTH", 415}, {"MAIL", 413}, {"SHIELD", 433}, {"FIST_WEAPONS", 473}, {"LOCKPICKING", 633},
};

class LearnSpellsOnLevelUp : public PlayerScript
{
public:
    LearnSpellsOnLevelUp() : PlayerScript("LearnSpellsOnLevelUp") {}

    void OnFirstLogin(Player *player) override{
        if(player->GetSession()->IsBot()){
            return;
        }

        for (std::pair<std::string, uint32> skillLine : skills) {
            player->SetSkill(skillLine.second, 5, 1, 5);
        }

        for (uint32 skillId : professions)
        {
            player->SetSkill(skillId, 75, 1, 1);

            switch (skillId)
            {
            case 182: // Herbalism
                player->learnSpell(2366, false, false);
                break;
            case 186: // Mining
                player->learnSpell(2575, false, false);
                break;
            case 393: // Skinning
                player->learnSpell(8613, false, false);
                break;
            case 164: // Blacksmithing
                player->learnSpell(2018, false, false);
                break;
            case 165: // Leatherworking
                player->learnSpell(2108, false, false);
                break;
            case 171: // Alchemy
                player->learnSpell(2259, false, false);
                break;
            case 197: // Tailoring
                player->learnSpell(3908, false, false);
                break;
            case 202: // Engineering
                player->learnSpell(4036, false, false);
                break;
            case 333: // Enchanting
                player->learnSpell(7411, false, false);
                break;
            case 755: // Jewelcrafting
                player->learnSpell(25229, false, false);
                break;
            case 773: // Inscription
                player->learnSpell(45357, false, false);
                break;
            case 356: // Fishing
                player->learnSpell(7620, false, false);
                break;
            case 185: // Cooking
                player->learnSpell(2550, false, false);
                break;
            case 129: // First Aid
                player->learnSpell(3273, false, false);
                break;
            default:
                break;
            }
        }
    }

    void OnLearnSpell(Player *player, uint32 spellID) override
    {
        if (player->GetSession()->IsBot()) {
            return;
        }

        learnClasslessSpellRanks(player);
    }

    void OnLevelChanged(Player *player, uint8 oldLevel) override
    {
        if (player->GetSession()->IsBot()) {
            return;
        }

        learnClasslessSpellRanks(player);
    }

    void learnClasslessSpellRanks(Player *player) {
        uint8 playerLevel = player->GetLevel();

        QueryResult result = CharacterDatabase.Query("SELECT spells FROM character_classless WHERE GUID = {}", player->GetGUID().GetRawValue());
        std::vector<uint32_t> spells;

        if (result)
        {
            std::string fields = result->Fetch()[0].Get<std::string>();

            // Split the string by commas
            std::istringstream ss(fields);
            std::string token;

            while (std::getline(ss, token, ','))
            {
                try
                {
                    uint32_t spell = static_cast<uint32_t>(std::stoul(token));
                    spells.push_back(spell);
                }
                catch (const std::invalid_argument& e)
                {
                    std::cerr << "Invalid number: " << token << std::endl;
                }
                catch (const std::out_of_range& e)
                {
                    std::cerr << "Number out of range: " << token << std::endl;
                }
            }
        }

        // Output the spells vector for verification
        for (uint32 spell : spells)
        {
            SpellInfo const* spellInfo = sSpellMgr->GetSpellInfo(spell);
            std::vector<uint32> spellRanks;

            while (spellInfo)
            {
                if (spellInfo->BaseLevel > playerLevel)
                    break;

                if (spellInfo->Id != spell)
                {
                    spellRanks.push_back(spellInfo->Id);
                }

                spellInfo = spellInfo->GetNextRankSpell();
            }

            for (uint32_t spell : spellRanks)
            {
                player->learnSpell(spell, false);
            }
        }
    }
};

void AddSC_LearnAllSpells()
{
    new LearnSpellsOnLevelUp();
}
