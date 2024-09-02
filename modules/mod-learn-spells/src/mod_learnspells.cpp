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

        // learn shoot spell
        player->learnSpell(75);
        // learn mail spell
        player->learnSpell(8737);
        // learn plate spell
        player->learnSpell(750);
        // learn shield
        player->learnSpell(9116);


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


};

void AddSC_LearnAllSpells()
{
    new LearnSpellsOnLevelUp();
}
