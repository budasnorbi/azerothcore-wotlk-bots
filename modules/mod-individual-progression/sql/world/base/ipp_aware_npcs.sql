SET @IPPPHASE := 65536;

UPDATE `creature_template` SET `ScriptName` = 'npc_ipp_tbc' WHERE `entry` IN (16841, 19254, 16840,
                                                                              20026, 20027, 20053, 20054, 20069, 18542, 20080, 20081, 20082, 21643, 20130,
                                                                              19934, 19936, 19950, 19951, 19959, 22889, 22902, 22835, 22837);

UPDATE `creature_template` SET `ScriptName` = 'npc_ipp_ds2' WHERE `entry` IN (15282, 15270);

UPDATE `creature_template` SET `ScriptName` = 'npc_ipp_aq' WHERE `entry` IN (15293,15306,15191,15181,15306,15599,15183,15194,15176,15270,16091,15701,15612,15613,15540,15704,15693,15431,15903,15180, 15499, 15500, 15498);
# Two Cenarion Scouts - 15609 and 15610 - should be in this progression but they have some quest AI that we don't want to override, so leave them for now

# Light's Hope Chapel
UPDATE `creature` SET `phaseMask` = @IPPPHASE WHERE `id1` IN (11102, 16113, 16112, 16115, 16116, 16131, 16132, 16133, 16134, 16135, 16114, 16376, 16212, 16225, 16228, 16229,
                                                                                 16256, 16283, 16284, 16378);
# The above query adds one undesired creature to the phasing, so put it back to normal
UPDATE `creature` SET `phaseMask` = 1 WHERE `guid` = 56932;

UPDATE `creature_template` SET `ScriptName` = 'npc_ipp_wotlk' WHERE `entry` IN (28602, 29611, 34084);

UPDATE `creature_template` SET `ScriptName` = 'npc_ipp_wotlk_ulduar' WHERE `entry` IN (34252);

UPDATE `creature_template` SET `ScriptName` = 'npc_ipp_wotlk_totc' WHERE `entry` IN (35498, 35577, 35496, 36208, 35500, 35497, 34244, 28701);

# TODO: Harold Winston (32172) has rings from all patches, so he needs special phasing applied - for now make him require ICC progression
UPDATE `creature_template` SET `ScriptName` = 'npc_ipp_wotlk_icc' WHERE `entry` IN (37776, 40160, 37780, 32172);

UPDATE `gameobject_template` SET `ScriptName` = 'gobject_ipp_tbc' WHERE `entry` IN (195141);

-- Drop source for 2.3 Jewelcrafting Recipe
UPDATE `creature_template` SET `ScriptName` = 'npc_ipp_tbc_t4' WHERE `entry` IN (19768, 19227, 23761);

-- Phasing for General Tiras'alan and Dathris Sunstriker - prevent early access to Isle of Quel'Danas
UPDATE `creature_template` SET `ScriptName` = 'npc_ipp_tbc_t5' WHERE `entry` IN (25167, 18594);

-- Argent Tournament
UPDATE `creature` SET `phaseMask` = @IPPPHASE WHERE `guid` IN (25, 63129, 63236, 63370, 63371, 65274, 65275, 65283, 65284, 65285, 65325, 65327, 65350, 65351, 65371, 65451,
65522, 65523, 65526, 65901, 66478, 66479, 66741, 66753, 66788, 66790, 66792, 66910, 66941, 67185, 67187, 68005, 68457, 68583, 68906, 68941, 68947, 68987, 68989, 68990, 69010,
69011, 69065, 69077, 69078, 69880, 69973, 69976, 69990, 69992, 69995, 69996, 70000, 70001, 70002, 70003, 70005, 70006, 70007, 70178, 70179, 70180, 70181, 70448, 70539, 70548,
70551, 70950, 71263, 71922, 71978, 71979, 71980, 72212, 72213, 72216, 72217, 72218, 72219, 72220, 72222, 72223, 72349, 72402, 72405, 72406, 72407, 72408, 72485, 72601, 72942,
72964, 73491, 73492, 73493, 73494, 73495, 73496, 73497, 73832, 74052, 74053, 74480, 74701, 74722, 74750, 74751, 74975, 75091, 75175, 75392, 75393, 75471, 75472, 75473, 75602,
75712, 75903, 75904, 75905, 75906, 75910, 75950, 75952, 75997, 76131, 76442, 76443, 76444, 76445, 76719, 76720, 76721, 76722, 76734, 76735, 76736, 81016, 81432, 81433, 81434,
81435, 83022, 83023, 84073, 84074, 84483, 84657, 84658, 84659, 84660, 84661, 84662, 84664, 84665, 84666, 84667, 84697, 84698, 84699, 84700, 84719, 84750, 84751, 84752, 84753,
84754, 84755, 84757, 84766, 84767, 84768, 84769, 84770, 84771, 84772, 84816, 84904, 84905, 84906, 84907, 84908, 84909, 84910, 84911, 84912, 84913, 84914, 84915, 84916, 84917,
84918, 84919, 84920, 84921, 84922, 84923, 84924, 84925, 84926, 84927, 84928, 84929, 84930, 84931, 84932, 84933, 84934, 84935, 84936, 84941, 84942, 84973, 84974, 84975, 84976,
84977, 84978, 84979, 84980, 84981, 84982, 84983, 84984, 84985, 84986, 84987, 84988, 84990, 84991, 84992, 84993, 84994, 84995, 84996, 84997, 84998, 84999, 85000, 85001, 85002,
85003, 85004, 85005, 85006, 85007, 85008, 85009, 85010, 85011, 85012, 85013, 85014, 85015, 85016, 85017, 85018, 85019, 85020, 85021, 85022, 85023, 85024, 85025, 85026, 85027,
85028, 85029, 85030, 85031, 85032, 85033, 85034, 85035, 85036, 85037, 85038, 85039, 85040, 85041, 85042, 85043, 85045, 85046, 85047, 85048, 85049, 85050, 85051, 85052, 85053,
85054, 85055, 85058, 85059, 85061, 85062, 85065, 85066, 85067, 85068, 85069, 85070, 85071, 85072, 85073, 85074, 85078, 85079, 85080, 85081, 85084, 85085, 85088, 85089, 85090,
85094, 85095, 85096, 85099, 85100, 85101, 85102, 85103, 85104, 85105, 85106, 85107, 85108, 85109, 85110, 85111, 85112, 85113, 85114, 85115, 85116, 85117, 85119, 85120, 85122,
85123, 85124, 85125, 85126, 85127, 85128, 85129, 85130, 85131, 85132, 85133, 85134, 85135, 85136, 85139, 85140, 85141, 85142, 85143, 85144, 85145, 85146, 85147, 85148, 85149,
85150, 85151, 85152, 85153, 85154, 85159, 85160, 85161, 85162, 85163, 85164, 85165, 85166, 85167, 85168, 85169, 85170, 85171, 85173, 85174, 85200, 85201, 85202, 85203, 85204,
85205, 123152, 134702, 134703, 152218, 200774, 200775, 200776, 200777, 200778, 200779, 200780, 200781, 200782, 200783, 200784, 200785, 200786, 200787, 200788, 200793, 200794,
200795, 200815, 200816, 200817, 200849, 200850, 200852, 200853, 200854, 200855, 200856, 200857, 200858, 200859, 200860, 200861, 200862, 200863, 200864, 200865, 200866, 200867,
200870, 200871, 200872, 200873, 200874, 200875, 202313, 202314, 202324, 202325, 202326, 202327, 202328, 202329, 202330, 202331, 202332, 202363, 202364, 202365, 202366, 202367,
202368, 202369, 202370, 202371, 202372, 202373, 202375, 202376, 202377, 202378, 202379, 202380, 202381, 202382, 202383, 202384, 202385, 202386, 202387, 202388, 202389, 202390,
202391, 202392, 202393, 202394, 202395, 202396, 202397, 202398, 202399, 202400, 202485, 202486, 203458, 209019, 209020, 209021, 209022, 209023, 209024, 209025, 209026, 209027,
1976767, 1976768, 1976769, 1976770, 1976771, 1976772, 1976773, 1976774, 1976775, 1976776, 1976777, 1976778, 1976779, 1976780, 1976781, 1976782, 1976783, 1976784, 1976785, 1976786,
1976787, 1976788, 1976789, 1976790, 1976791, 1976792, 1976793, 1976794, 1976795, 1976796, 1976797, 1976798, 1976799, 1976800, 1976801, 1976802, 1976803, 1976804, 1976805, 1976806,
1976807, 1976808, 1976809, 1976810, 1976811, 1976812, 1976813, 1976814, 1976815, 1976816);

UPDATE `gameobject` SET `phaseMask` = @IPPPHASE WHERE `guid` IN (58070, 58071, 58072, 58073, 58074, 58075, 58076, 58079, 58087, 58106, 58111, 58115, 58116, 58134, 58143, 58148,
58169, 58171, 58188, 58204, 58216, 58223, 58301, 58311, 58345, 58346, 58444, 58445, 58447, 58448, 58701, 58702, 58704, 58705, 58707, 58709, 58715, 58717, 58718, 58719, 58720,
58723, 58728, 58730, 58733, 58735, 58741, 58743, 58744, 58747, 58748, 58750, 58756, 58768, 58785, 58825, 58831, 58909, 58939, 58941, 58979, 58986, 58989, 59007, 59018, 59026,
59035, 59048, 59088, 59097, 59100, 59108, 59111, 59118, 59136, 59168, 59197, 59219, 59223, 59258, 59263, 59285, 59286, 59298, 59310, 59319, 59337, 59390, 59391, 59392, 59394,
59396, 59397, 59398, 59399, 59401, 59402, 59403, 59404, 59406, 59448, 59451, 59452, 59546, 59561, 59593, 59610, 59619, 59626, 59737, 59741, 59746, 59752, 59758, 59770, 59788,
67916, 100498, 150394, 150395, 150396, 150397, 150398, 150399, 150400, 150401, 150402, 150403, 150404, 151783, 151784, 151785, 151786, 151787, 151788, 151789);