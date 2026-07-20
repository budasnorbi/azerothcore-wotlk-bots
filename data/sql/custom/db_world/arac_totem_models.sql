-- ARAC support: totem models for races that cannot normally be shamans.
--
-- `player_totem_model` ships with art only for the four vanilla/TBC shaman races
-- (Orc 2, Dwarf 3, Tauren 6, Troll 8, Draenei 11). With arac.sql installed every
-- race can roll shaman, and ObjectMgr::GetModelForTotem() logs
--   "TotemSlot {} with RaceID ({}) have no totem model data defined"
-- for each missing pair, falling back to display id 0.
--
-- There is no client art for e.g. Gnome or Undead totems, so each missing race
-- borrows the totem set of a same-faction race:
--   Alliance (Human 1, Night Elf 4, Gnome 7)  -> Dwarf models
--   Horde    (Undead 5, Goblin 9, Blood Elf 10) -> Orc models
--
-- TotemID: 1 = Fire, 2 = Earth, 3 = Water, 4 = Air

DELETE FROM `player_totem_model` WHERE `RaceID` IN (1, 4, 5, 7, 9, 10);
INSERT INTO `player_totem_model` (`TotemID`, `RaceID`, `ModelID`) VALUES
-- Human (Dwarf models)
(1, 1, 30754),
(2, 1, 30753),
(3, 1, 30755),
(4, 1, 30736),
-- Night Elf (Dwarf models)
(1, 4, 30754),
(2, 4, 30753),
(3, 4, 30755),
(4, 4, 30736),
-- Gnome (Dwarf models)
(1, 7, 30754),
(2, 7, 30753),
(3, 7, 30755),
(4, 7, 30736),
-- Undead (Orc models)
(1, 5, 30758),
(2, 5, 30757),
(3, 5, 30759),
(4, 5, 30756),
-- Goblin (Orc models)
(1, 9, 30758),
(2, 9, 30757),
(3, 9, 30759),
(4, 9, 30756),
-- Blood Elf (Orc models)
(1, 10, 30758),
(2, 10, 30757),
(3, 10, 30759),
(4, 10, 30756);
