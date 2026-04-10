-- I'm A Big Deal — Lore Database
-- tier: 5=Legendary, 4=Epic, 3=Rare, 2=Uncommon, 1=Common
-- Format: [npcID] = { tier, "Title", "Lore blurb" }

local ADDON_NAME = "ImABigDeal"
_G[ADDON_NAME] = _G[ADDON_NAME] or {}
local IABD = _G[ADDON_NAME]

IABD.TIER_LEGENDARY = 5
IABD.TIER_EPIC = 4
IABD.TIER_RARE = 3
IABD.TIER_UNCOMMON = 2
IABD.TIER_COMMON = 1

IABD.tierColors = {
  [5] = { 1.00, 0.50, 0.00 },  -- Orange (Legendary)
  [4] = { 0.64, 0.21, 0.93 },  -- Purple (Epic)
  [3] = { 0.00, 0.44, 0.87 },  -- Blue (Rare)
  [2] = { 0.12, 1.00, 0.00 },  -- Green (Uncommon)
  [1] = { 1.00, 1.00, 1.00 },  -- White (Common)
}

IABD.tierNames = {
  [5] = "Legendary",
  [4] = "Epic",
  [3] = "Rare",
  [2] = "Uncommon",
  [1] = "Common",
}

IABD.loreDB = {

  -- ============================================================
  -- LEGENDARY (Orange) — Franchise-defining characters
  -- ============================================================

  -- Thrall / Go'el (multiple NPC IDs across expansions)
  [4949]  = { 5, "Warchief of the Horde", "Born Go'el, raised as a slave gladiator by Aedelas Blackmoore. Escaped to unite the Horde, led them to Kalimdor, and served as Warchief. Wielder of the Doomhammer and Earth-Warder during the Cataclysm." },
  [17852] = { 5, "Warchief of the Horde", "Born Go'el, raised as a slave gladiator by Aedelas Blackmoore. Escaped to unite the Horde, led them to Kalimdor, and served as Warchief. Wielder of the Doomhammer and Earth-Warder during the Cataclysm." },
  [54972] = { 5, "Warchief of the Horde", "Born Go'el, raised as a slave gladiator by Aedelas Blackmoore. Escaped to unite the Horde, led them to Kalimdor, and served as Warchief. Wielder of the Doomhammer and Earth-Warder during the Cataclysm." },

  -- Sylvanas Windrunner
  [10181] = { 5, "The Banshee Queen", "Former Ranger-General of Silvermoon, killed and raised as a banshee by Arthas. Broke free to lead the Forsaken, became Warchief, then shattered the Helm of Domination to tear open the Shadowlands." },

  -- Jaina Proudmoore
  [4968]  = { 5, "Archmage of the Kirin Tor", "Daughter of Daelin Proudmoore, one of the most powerful mages alive. Founded Theramore, led the Kirin Tor, and has been at the center of nearly every major conflict since the Third War." },

  -- Anduin Wrynn
  [107574] = { 5, "King of Stormwind", "Son of Varian Wrynn, became High King of the Alliance at a young age. A priest-king who seeks peace but was forced into war. Dominated by the Jailer in the Shadowlands before being freed." },
  [1747]   = { 5, "King of Stormwind", "Son of Varian Wrynn, became High King of the Alliance at a young age. A priest-king who seeks peace but was forced into war. Dominated by the Jailer in the Shadowlands before being freed." },

  -- Illidan Stormrage
  [22917] = { 5, "The Betrayer", "Twin brother of Malfurion, imprisoned for 10,000 years for creating a second Well of Eternity. Consumed the Skull of Gul'dan, became a demon hunter, and ultimately sacrificed everything to defeat the Burning Legion." },

  -- Arthas Menethil / The Lich King
  [36597] = { 5, "The Lich King", "Prince of Lordaeron who took up the cursed blade Frostmourne to save his people, only to lose his soul. Merged with the Lich King and sat frozen on the Frozen Throne until his defeat at Icecrown Citadel." },

  -- Bolvar Fordragon
  [27990] = { 5, "The Lich King Reborn", "Highlord of the Alliance, fell at the Wrathgate when Grand Apothecary Putress unleashed the New Plague. Tortured by dragonfire, he donned the Helm of Domination to contain the Scourge as the new Lich King." },

  -- Malfurion Stormrage
  [15362] = { 5, "First of the Druids", "Twin of Illidan, first mortal druid taught by Cenarius himself. Slept in the Emerald Dream for millennia to protect Azeroth. Archdruid of the Night Elves and husband of Tyrande Whisperwind." },

  -- Tyrande Whisperwind
  [7999]  = { 5, "High Priestess of Elune", "Leader of the Night Elves for over 10,000 years. High Priestess of Elune and wife of Malfurion Stormrage. Became the Night Warrior by channeling Elune's darkest fury to avenge Teldrassil." },

  -- Vol'jin
  [10540] = { 5, "Warchief of the Horde", "Son of Sen'jin, leader of the Darkspear trolls. Rose from exile to become Warchief after deposing Garrosh. Mortally wounded at the Broken Shore, his dying act was to name Sylvanas as his successor." },

  -- Garrosh Hellscream
  [18063] = { 5, "Former Warchief", "Son of Grom Hellscream, rose from self-loathing on Draenor to become the most feared Warchief the Horde has known. His reign of conquest ended at the Siege of Orgrimmar, and he was executed in Nagrand." },

  -- Varian Wrynn
  [29611] = { 5, "High King of the Alliance", "King of Stormwind, kidnapped and split into two halves by Onyxia's magic. Fought as a gladiator named Lo'Gosh before reclaiming his throne. Sacrificed himself at the Broken Shore to save the Alliance fleet." },

  -- Khadgar
  [90417] = { 5, "Archmage of the Kirin Tor", "Former apprentice of Medivh, aged prematurely when he helped defeat his master. One of the most powerful mages in Azeroth's history, led the campaign against the Iron Horde on Draenor and against the Burning Legion." },

  -- Magni Bronzebeard
  [2784]  = { 5, "The Speaker", "Former King of Ironforge who was turned to diamond when he performed a ritual to commune with the earth. Became the Speaker for Azeroth, hearing the world-soul's voice and guiding champions to heal its wounds." },

  -- Chromie / Chronormu
  [21107] = { 4, "Ambassador of the Bronze Dragonflight", "A Bronze dragon who prefers her gnome disguise. Guardian of the timeways, she has helped adventurers navigate temporal crises across multiple timelines and expansions." },

  -- ============================================================
  -- EPIC (Purple) — Major faction leaders and key story NPCs
  -- ============================================================

  -- Lor'themar Theron
  [16802] = { 4, "Regent Lord of Quel'Thalas", "Led the Blood Elves after Kael'thas's betrayal. A reluctant leader who guided his people through addiction, invasion, and political upheaval to become one of the Horde's most respected leaders." },

  -- Baine Bloodhoof
  [36648] = { 4, "High Chieftain of the Tauren", "Son of Cairne Bloodhoof, took leadership after his father was killed by Garrosh in a rigged Mak'gora. A voice of reason and honor within the Horde, often caught between loyalty and conscience." },

  -- Genn Greymane
  [29618] = { 4, "King of Gilneas", "Built the Greymane Wall to isolate Gilneas from the world. When the Worgen curse struck his kingdom, he was among those afflicted. Now leads his displaced people as part of the Alliance with a burning hatred for Sylvanas." },

  -- Thalyssra
  [106522] = { 4, "First Arcanist of Suramar", "Led the Nightborne rebellion against Elisande's alliance with the Burning Legion. Freed Suramar from the Nightwell's corruption and brought her people into the Horde." },

  -- Alleria Windrunner
  [103489] = { 4, "Void Ranger", "Eldest Windrunner sister, veteran of the Second War. Was lost in the Twisting Nether for a thousand years before returning infused with Void powers. Now walks a dangerous line between Light and Shadow." },

  -- Turalyon
  [103823] = { 4, "High Exarch of the Army of the Light", "One of the original paladins, fought alongside Alleria in the Second War. Spent a thousand years battling the Burning Legion across the cosmos before returning to lead the Alliance forces." },

  -- Lady Liadrin
  [25697] = { 4, "Matriarch of the Blood Knights", "Former priestess who lost her faith when the Sunwell was destroyed. Pioneered the Blood Knight order by forcibly draining a naaru for Light powers, but later found true redemption when the Sunwell was restored." },

  -- Talanji
  [120740] = { 4, "Queen of the Zandalari", "Daughter of King Rastakhan, became queen after her father's death during the Alliance assault on Dazar'alor. Young but fierce, she brought the ancient Zandalari Empire into the Horde." },

  -- Calia Menethil
  [137555] = { 4, "Princess of Lordaeron", "Sister of Arthas, killed by Sylvanas during a secret meeting with Forsaken dissidents. Resurrected by the Light as an undead, she now represents a possible future for the Forsaken." },

  -- Mayla Highmountain
  [97662] = { 4, "High Chieftain of Highmountain", "United the Highmountain tauren tribes against the drogbar threat and Dargrul the Underking. Descended from Huln Highmountain, who fought in the War of the Ancients." },

  -- Prophet Velen
  [17468] = { 4, "Prophet of the Naaru", "Ancient leader of the Draenei, one of three eredar who refused Sargeras's offer. Has led his people on a 25,000-year exodus across the cosmos, guided by visions of the Light." },

  -- Merithra
  [143380] = { 4, "Aspect of the Green Dragonflight", "Daughter of Ysera, inherited leadership of the green dragonflight after her mother's corruption and sacrifice. Became the new Green Aspect during the Dragonflight's renewal." },

  -- Alexstrasza
  [17499] = { 4, "The Life-Binder", "Queen of the Red Dragonflight and Aspect of Life. Enslaved by the Dragonmaw orcs for years, she endured unspeakable suffering. The most powerful of the Dragon Aspects, she champions all living things." },

  -- Nozdormu
  [15192] = { 4, "The Timeless One", "Aspect of the Bronze Dragonflight, master of time. Cursed with the knowledge of his own death and his eventual corruption into Murozond. Guards the integrity of the one true timeline." },

  -- Wrathion
  [62092] = { 4, "The Black Prince", "Last known uncorrupted Black Dragon, son of Deathwing through a purified egg. A master manipulator who orchestrated events across expansions, always claiming to act for Azeroth's greater good." },

  -- Ebyssian / Ebonhorn
  [97938] = { 4, "The Hidden Dragon", "A Black Dragon who has lived among the Highmountain tauren for generations disguised as the elder Spiritwalker Ebonhorn. One of the few uncorrupted black dragons, loyal to the mortal races." },

  -- Kalecgos
  [58210] = { 4, "Aspect of the Blue Dragonflight", "Became Aspect of Magic after Malygos's madness and death. Previously rescued Anveena Teague, the mortal vessel of the Sunwell's power. A bridge between dragonkind and the mortal races." },

  -- Hamuul Runetotem
  [5769]  = { 3, "Archdruid of the Tauren", "First tauren to study druidism in modern times, trained by Malfurion himself. A key figure in bridging the gap between Night Elf and Tauren druidic traditions." },

  -- ============================================================
  -- RARE (Blue) — Zone leaders, significant dungeon/raid bosses
  -- ============================================================

  -- Darion Mograine
  [51329] = { 3, "Highlord of the Ebon Blade", "Son of Alexandros Mograine, the Ashbringer. Sacrificed himself to free his father's soul, was raised as a Death Knight, and now leads the Knights of the Ebon Blade." },

  -- Nathanos Blightcaller
  [68002] = { 3, "Champion of the Banshee Queen", "First and only human ranger lord of Quel'Thalas in life. In undeath, became Sylvanas's most devoted follower and military commander. Killed by Tyrande during the Fourth War." },

  -- Varok Saurfang
  [110262] = { 3, "High Overlord of the Horde", "Legendary orc warrior who fought in every major Horde conflict since the First War. Carried the guilt of drinking Mannoroth's blood. Died challenging Sylvanas in Mak'gora before the gates of Orgrimmar." },

  -- Muradin Bronzebeard
  [36227] = { 3, "Representative of the Council of Three Hammers", "Brother of Magni and Brann, thought dead after helping Arthas find Frostmourne. Survived with amnesia among the Frostborn dwarves before being restored." },

  -- Brann Bronzebeard
  [51159] = { 3, "Explorer Supreme", "The most famous explorer in Azeroth's history. Member of the Explorer's League, brother of Magni and Muradin. Has a knack for stumbling into ancient titan facilities and world-ending discoveries." },

  -- Rexxar
  [10182] = { 3, "Champion of the Horde", "A half-ogre, half-orc beastmaster and one of the Horde's greatest champions. Bonded with the bear Misha. Helped Thrall establish Orgrimmar and has fought in nearly every major conflict." },

  -- Lady Ashvane
  [130661] = { 3, "Traitor of Kul Tiras", "Priscilla Ashvane, head of the Ashvane Trading Company. Betrayed Kul Tiras by plotting with Azshara and the Naga, leading to the siege of Boralus." },

  -- Flynn Fairwind
  [121239] = { 3, "Captain of the Middenwake", "A charming rogue and captain of questionable reputation in Boralus. Became an unlikely hero during the Fourth War, aiding the Alliance across Kul Tiras." },

  -- Taelia Fordragon
  [120590] = { 3, "Knight of the Alliance", "Daughter of Bolvar Fordragon, raised in Kul Tiras without knowing her father's fate as the Lich King. A skilled warrior who proved herself during the Battle for Azeroth." },

  -- Lillian Voss
  [38895] = { 3, "Forsaken Assassin", "Daughter of a fanatical Scarlet Crusade leader, killed and raised into undeath. Rejected both the living and the Forsaken before eventually finding purpose serving Calia Menethil." },

  -- Taran Zhu
  [61124] = { 3, "Lord of the Shado-Pan", "Leader of the Shado-Pan, the ancient order sworn to protect Pandaria from the Sha. Suspicious of outsiders, he eventually learned to work with both factions against greater threats." },

  -- Chen Stormstout
  [16076] = { 3, "Legendary Brewmaster", "A wandering Pandaren brewmaster who left the Wandering Isle to explore the world. Helped Vol'jin and Thrall during the founding of Durotar. His family's legacy is Stormstout Brewery." },

  -- Lilian Voss
  [46610] = { 3, "Forsaken Assassin", "Daughter of a Scarlet Crusade high priest, killed and raised as Forsaken. Became a deadly rogue who hunted her former allies before accepting her undeath and finding new purpose." },

  -- Shandris Feathermoon
  [40032] = { 3, "General of the Sentinel Army", "Adopted daughter of Tyrande, raised from childhood after her family was killed in the War of the Ancients. Has served as the Night Elves' greatest military commander for over 10,000 years." },

  -- Trade Prince Gallywix
  [35222] = { 3, "Trade Prince of the Bilgewater Cartel", "The greediest goblin alive, which is saying something. Enslaved his own people during Kezan's destruction before being forced to serve the Horde. Eventually ousted for his corruption." },

  -- Ji Firepaw
  [64975] = { 3, "Huojin Representative", "Leader of the Huojin Pandaren who joined the Horde. A passionate warrior from the Wandering Isle who believes in decisive action over passive contemplation." },

  -- Aysa Cloudsinger
  [64974] = { 3, "Tushui Representative", "Leader of the Tushui Pandaren who joined the Alliance. A contemplative monk from the Wandering Isle who values patience, wisdom, and careful thought." },

  -- ============================================================
  -- UNCOMMON (Green) — Notable quest NPCs and supporting characters
  -- ============================================================

  -- Chromie (other IDs)
  [26560] = { 2, "Bronze Dragon in Disguise", "A Bronze dragon who prefers gnome form. Cheerful guardian of the timeways who helps adventurers navigate time-travel shenanigans." },

  -- Mankrik
  [3432]  = { 2, "Grieving Warrior", "An orc warrior in the Barrens, famous for his quest to find his wife — which became one of WoW's most iconic memes. 'Where is Mankrik's wife?' echoed through Barrens chat for years." },

  -- Hemet Nesingwary
  [10264] = { 2, "Big Game Hunter", "The most famous hunter in Azeroth. Has set up hunting camps across multiple continents and expansions. Descended from Hemet Nesingwary Sr., a reference to Ernest Hemingway." },

  -- Nat Pagle
  [12919] = { 2, "Master Angler", "The greatest fisherman in Azeroth. Found fishing off the coast of Dustwallow Marsh, his reputation spans every continent. Reaching Best Friend status with him is a rite of passage." },

  -- Harrison Jones
  [44860] = { 2, "Adventurer and Archaeologist", "Azeroth's most dashing archaeologist, clearly inspired by a certain whip-wielding movie hero. Shows up wherever ancient artifacts are in danger of falling into the wrong hands." },

  -- Maximillian of Northshire
  [38237] = { 2, "Delusional Knight", "A human who believes himself a great paladin on a noble quest in Un'Goro Crater. Mistakes dinosaurs for dragons and plants for damsels. Beloved for his unshakeable optimism." },

  -- Lorewalker Cho
  [61900] = { 2, "Keeper of Pandaren Lore", "Head of the Lorewalkers in Pandaria, a gentle scholar who preserves the history of his people through stories. Serves as guide and narrator throughout the Pandaria experience." },

  -- Koltira Deathweaver
  [16285] = { 2, "Death Knight", "A Blood Elf Death Knight who formed an unlikely friendship with Alliance Death Knight Thassarian. Captured and tortured by Sylvanas for refusing to attack Alliance forces." },

  -- Thassarian
  [30714] = { 2, "Death Knight", "The first Death Knight to rejoin the Alliance. Known for his friendship with Horde Death Knight Koltira Deathweaver, proving bonds can transcend faction lines." },
}

-- Name-based lookup (fallback when NPC ID isn't in the database)
-- Built from loreDB entries but keyed by character name
IABD.nameLookup = {}

-- Maps common NPC names to their lore entry
-- This catches all phased/expansion variants of a character
IABD.nameOverrides = {
  ["thrall"]                  = { 5, "Warchief of the Horde", "Born Go'el, raised as a slave gladiator by Aedelas Blackmoore. Escaped to unite the Horde, led them to Kalimdor, and served as Warchief. Wielder of the Doomhammer and Earth-Warder during the Cataclysm." },
  ["go'el"]                   = { 5, "Warchief of the Horde", "Born Go'el, raised as a slave gladiator by Aedelas Blackmoore. Escaped to unite the Horde, led them to Kalimdor, and served as Warchief. Wielder of the Doomhammer and Earth-Warder during the Cataclysm." },
  ["sylvanas windrunner"]     = { 5, "The Banshee Queen", "Former Ranger-General of Silvermoon, killed and raised as a banshee by Arthas. Broke free to lead the Forsaken, became Warchief, then shattered the Helm of Domination to tear open the Shadowlands." },
  ["jaina proudmoore"]        = { 5, "Archmage of the Kirin Tor", "Daughter of Daelin Proudmoore, one of the most powerful mages alive. Founded Theramore, led the Kirin Tor, and has been at the center of nearly every major conflict since the Third War." },
  ["lady jaina proudmoore"]   = { 5, "Archmage of the Kirin Tor", "Daughter of Daelin Proudmoore, one of the most powerful mages alive. Founded Theramore, led the Kirin Tor, and has been at the center of nearly every major conflict since the Third War." },
  ["anduin wrynn"]            = { 5, "King of Stormwind", "Son of Varian Wrynn, became High King of the Alliance at a young age. A priest-king who seeks peace but was forced into war. Dominated by the Jailer in the Shadowlands before being freed." },
  ["king anduin wrynn"]       = { 5, "King of Stormwind", "Son of Varian Wrynn, became High King of the Alliance at a young age. A priest-king who seeks peace but was forced into war. Dominated by the Jailer in the Shadowlands before being freed." },
  ["illidan stormrage"]       = { 5, "The Betrayer", "Twin brother of Malfurion, imprisoned for 10,000 years for creating a second Well of Eternity. Consumed the Skull of Gul'dan, became a demon hunter, and ultimately sacrificed everything to defeat the Burning Legion." },
  ["illidan"]                 = { 5, "The Betrayer", "Twin brother of Malfurion, imprisoned for 10,000 years for creating a second Well of Eternity. Consumed the Skull of Gul'dan, became a demon hunter, and ultimately sacrificed everything to defeat the Burning Legion." },
  ["the lich king"]           = { 5, "The Lich King", "Prince of Lordaeron who took up Frostmourne to save his people, only to lose his soul. Merged with the Lich King and sat frozen on the Frozen Throne until his defeat at Icecrown Citadel." },
  ["arthas menethil"]         = { 5, "The Lich King", "Prince of Lordaeron who took up Frostmourne to save his people, only to lose his soul. Merged with the Lich King and sat frozen on the Frozen Throne until his defeat at Icecrown Citadel." },
  ["bolvar fordragon"]        = { 5, "The Lich King Reborn", "Highlord of the Alliance, fell at the Wrathgate. Tortured by dragonfire, he donned the Helm of Domination to contain the Scourge as the new Lich King." },
  ["highlord bolvar fordragon"] = { 5, "The Lich King Reborn", "Highlord of the Alliance, fell at the Wrathgate. Tortured by dragonfire, he donned the Helm of Domination to contain the Scourge as the new Lich King." },
  ["malfurion stormrage"]     = { 5, "First of the Druids", "Twin of Illidan, first mortal druid taught by Cenarius himself. Slept in the Emerald Dream for millennia. Archdruid of the Night Elves and husband of Tyrande Whisperwind." },
  ["tyrande whisperwind"]     = { 5, "High Priestess of Elune", "Leader of the Night Elves for over 10,000 years. Became the Night Warrior by channeling Elune's darkest fury to avenge Teldrassil." },
  ["tyrande"]                 = { 5, "High Priestess of Elune", "Leader of the Night Elves for over 10,000 years. Became the Night Warrior by channeling Elune's darkest fury to avenge Teldrassil." },
  ["vol'jin"]                 = { 5, "Warchief of the Horde", "Son of Sen'jin, leader of the Darkspear trolls. Rose from exile to become Warchief. Mortally wounded at the Broken Shore, naming Sylvanas as successor." },
  ["garrosh hellscream"]      = { 5, "Former Warchief", "Son of Grom Hellscream, rose to become the most feared Warchief. His reign of conquest ended at the Siege of Orgrimmar." },
  ["varian wrynn"]            = { 5, "High King of the Alliance", "King of Stormwind, fought as gladiator Lo'Gosh before reclaiming his throne. Sacrificed himself at the Broken Shore to save the Alliance fleet." },
  ["king varian wrynn"]       = { 5, "High King of the Alliance", "King of Stormwind, fought as gladiator Lo'Gosh before reclaiming his throne. Sacrificed himself at the Broken Shore to save the Alliance fleet." },
  ["khadgar"]                 = { 5, "Archmage of the Kirin Tor", "Former apprentice of Medivh, aged prematurely when he helped defeat his master. One of the most powerful mages in Azeroth's history." },
  ["archmage khadgar"]        = { 5, "Archmage of the Kirin Tor", "Former apprentice of Medivh, aged prematurely when he helped defeat his master. One of the most powerful mages in Azeroth's history." },
  ["magni bronzebeard"]       = { 5, "The Speaker", "Former King of Ironforge turned to diamond. Became the Speaker for Azeroth, hearing the world-soul's voice." },

  -- Epic
  ["lor'themar theron"]       = { 4, "Regent Lord of Quel'Thalas", "Led the Blood Elves after Kael'thas's betrayal. Guided his people through addiction, invasion, and upheaval to become one of the Horde's most respected leaders." },
  ["regent lord lor'themar theron"] = { 4, "Regent Lord of Quel'Thalas", "Led the Blood Elves after Kael'thas's betrayal. Guided his people through addiction, invasion, and upheaval to become one of the Horde's most respected leaders." },
  ["baine bloodhoof"]         = { 4, "High Chieftain of the Tauren", "Son of Cairne, took leadership after his father was killed by Garrosh. A voice of reason and honor within the Horde." },
  ["genn greymane"]           = { 4, "King of Gilneas", "Built the Greymane Wall to isolate Gilneas. Afflicted by the Worgen curse, now leads his displaced people with a burning hatred for Sylvanas." },
  ["king genn greymane"]      = { 4, "King of Gilneas", "Built the Greymane Wall to isolate Gilneas. Afflicted by the Worgen curse, now leads his displaced people with a burning hatred for Sylvanas." },
  ["first arcanist thalyssra"] = { 4, "First Arcanist of Suramar", "Led the Nightborne rebellion against Elisande's alliance with the Burning Legion. Freed Suramar and brought her people into the Horde." },
  ["thalyssra"]               = { 4, "First Arcanist of Suramar", "Led the Nightborne rebellion against Elisande's alliance with the Burning Legion. Freed Suramar and brought her people into the Horde." },
  ["alleria windrunner"]      = { 4, "Void Ranger", "Eldest Windrunner sister, lost in the Twisting Nether for a thousand years. Returned infused with Void powers, walking a dangerous line between Light and Shadow." },
  ["turalyon"]                = { 4, "High Exarch of the Army of the Light", "One of the original paladins. Spent a thousand years battling the Burning Legion across the cosmos before returning to lead Alliance forces." },
  ["high exarch turalyon"]    = { 4, "High Exarch of the Army of the Light", "One of the original paladins. Spent a thousand years battling the Burning Legion across the cosmos before returning to lead Alliance forces." },
  ["lady liadrin"]            = { 4, "Matriarch of the Blood Knights", "Former priestess who pioneered the Blood Knight order. Found true redemption when the Sunwell was restored." },
  ["queen talanji"]           = { 4, "Queen of the Zandalari", "Daughter of King Rastakhan, became queen after her father's death at Dazar'alor. Brought the ancient Zandalari Empire into the Horde." },
  ["talanji"]                 = { 4, "Queen of the Zandalari", "Daughter of King Rastakhan, became queen after her father's death at Dazar'alor. Brought the ancient Zandalari Empire into the Horde." },
  ["calia menethil"]          = { 4, "Princess of Lordaeron", "Sister of Arthas, killed by Sylvanas, resurrected by the Light as undead. Represents a possible future for the Forsaken." },
  ["prophet velen"]           = { 4, "Prophet of the Naaru", "Ancient leader of the Draenei, one of three eredar who refused Sargeras's offer. Led his people on a 25,000-year exodus guided by the Light." },
  ["velen"]                   = { 4, "Prophet of the Naaru", "Ancient leader of the Draenei, one of three eredar who refused Sargeras's offer. Led his people on a 25,000-year exodus guided by the Light." },
  ["alexstrasza"]             = { 4, "The Life-Binder", "Queen of the Red Dragonflight and Aspect of Life. Enslaved by the Dragonmaw orcs, she endured unspeakable suffering. Champions all living things." },
  ["alexstrasza the life-binder"] = { 4, "The Life-Binder", "Queen of the Red Dragonflight and Aspect of Life. Enslaved by the Dragonmaw orcs, she endured unspeakable suffering. Champions all living things." },
  ["nozdormu"]                = { 4, "The Timeless One", "Aspect of the Bronze Dragonflight. Cursed with knowledge of his own corruption into Murozond. Guards the one true timeline." },
  ["wrathion"]                = { 4, "The Black Prince", "Last uncorrupted Black Dragon, son of Deathwing. A master manipulator who claims to act for Azeroth's greater good." },
  ["kalecgos"]                = { 4, "Aspect of the Blue Dragonflight", "Became Aspect of Magic after Malygos's madness and death. A bridge between dragonkind and mortal races." },
  ["chromie"]                 = { 4, "Ambassador of the Bronze Dragonflight", "A Bronze dragon who prefers gnome form. Guardian of the timeways, helping adventurers navigate temporal crises." },
  ["chronormu"]               = { 4, "Ambassador of the Bronze Dragonflight", "A Bronze dragon who prefers gnome form. Guardian of the timeways, helping adventurers navigate temporal crises." },
  ["merithra"]                = { 4, "Aspect of the Green Dragonflight", "Daughter of Ysera, inherited the green dragonflight. Became the new Green Aspect during the Dragonflight's renewal." },
  ["ebyssian"]                = { 4, "The Hidden Dragon", "A Black Dragon disguised as Spiritwalker Ebonhorn among the Highmountain tauren for generations. One of the few uncorrupted black dragons." },
  ["spiritwalker ebonhorn"]   = { 4, "The Hidden Dragon", "A Black Dragon disguised as Spiritwalker Ebonhorn among the Highmountain tauren for generations. One of the few uncorrupted black dragons." },
  ["mayla highmountain"]      = { 4, "High Chieftain of Highmountain", "United the Highmountain tauren tribes against the drogbar threat. Descended from Huln Highmountain of the War of the Ancients." },

  -- Rare
  ["darion mograine"]         = { 3, "Highlord of the Ebon Blade", "Son of Alexandros Mograine, the Ashbringer. Sacrificed himself to free his father's soul, raised as a Death Knight, now leads the Knights of the Ebon Blade." },
  ["highlord darion mograine"] = { 3, "Highlord of the Ebon Blade", "Son of Alexandros Mograine, the Ashbringer. Sacrificed himself to free his father's soul, raised as a Death Knight, now leads the Knights of the Ebon Blade." },
  ["varok saurfang"]          = { 3, "High Overlord of the Horde", "Legendary orc warrior who fought in every major Horde conflict since the First War. Died challenging Sylvanas in Mak'gora before Orgrimmar." },
  ["high overlord saurfang"]  = { 3, "High Overlord of the Horde", "Legendary orc warrior who fought in every major Horde conflict since the First War. Died challenging Sylvanas in Mak'gora before Orgrimmar." },
  ["muradin bronzebeard"]     = { 3, "Council of Three Hammers", "Brother of Magni and Brann. Thought dead after helping Arthas find Frostmourne, survived with amnesia among the Frostborn." },
  ["brann bronzebeard"]       = { 3, "Explorer Supreme", "The most famous explorer in Azeroth. Has a knack for stumbling into titan facilities and world-ending discoveries." },
  ["rexxar"]                  = { 3, "Champion of the Horde", "Half-ogre, half-orc beastmaster. Bonded with the bear Misha. Helped Thrall establish Orgrimmar." },
  ["flynn fairwind"]          = { 3, "Captain of the Middenwake", "A charming rogue and captain of questionable reputation in Boralus. Unlikely hero of the Fourth War." },
  ["taelia fordragon"]        = { 3, "Knight of the Alliance", "Daughter of Bolvar Fordragon, raised in Kul Tiras without knowing her father became the Lich King." },
  ["lillian voss"]            = { 3, "Forsaken Assassin", "Daughter of a Scarlet Crusade leader, killed and raised as Forsaken. Became a deadly rogue before finding new purpose." },
  ["taran zhu"]               = { 3, "Lord of the Shado-Pan", "Leader of the ancient order sworn to protect Pandaria from the Sha." },
  ["chen stormstout"]         = { 3, "Legendary Brewmaster", "Wandering Pandaren brewmaster who helped Vol'jin and Thrall during the founding of Durotar." },
  ["shandris feathermoon"]    = { 3, "General of the Sentinel Army", "Adopted daughter of Tyrande. The Night Elves' greatest military commander for over 10,000 years." },
  ["trade prince gallywix"]   = { 3, "Trade Prince of the Bilgewater Cartel", "The greediest goblin alive. Enslaved his own people during Kezan's destruction. Eventually ousted for corruption." },
  ["nathanos blightcaller"]   = { 3, "Champion of the Banshee Queen", "First human ranger lord of Quel'Thalas in life. Sylvanas's most devoted follower in undeath. Killed by Tyrande." },

  -- Uncommon
  ["mankrik"]                 = { 2, "Grieving Warrior", "An orc warrior in the Barrens, famous for the quest to find his wife — one of WoW's most iconic memes." },
  ["hemet nesingwary"]        = { 2, "Big Game Hunter", "The most famous hunter in Azeroth. Has set up hunting camps across multiple continents." },
  ["nat pagle"]               = { 2, "Master Angler", "The greatest fisherman in Azeroth. Found fishing off Dustwallow Marsh, his reputation spans every continent." },
  ["harrison jones"]          = { 2, "Adventurer and Archaeologist", "Azeroth's most dashing archaeologist, inspired by a certain whip-wielding movie hero." },
  ["maximillian of northshire"] = { 2, "Delusional Knight", "Believes himself a great paladin in Un'Goro Crater. Mistakes dinosaurs for dragons. Beloved for his unshakeable optimism." },
  ["lorewalker cho"]          = { 2, "Keeper of Pandaren Lore", "Head of the Lorewalkers, a gentle scholar who preserves Pandaren history through stories." },

  -- ============================================================
  -- EXPANDED: Blood Elf / Silvermoon characters
  -- ============================================================
  ["grand magister rommath"]  = { 3, "Grand Magister of Quel'Thalas", "Leader of the Blood Elf magi, fiercely loyal to his people. Studied under Kael'thas in Dalaran and brought arcane knowledge back to rebuild Silvermoon after the Scourge invasion." },
  ["rommath"]                 = { 3, "Grand Magister of Quel'Thalas", "Leader of the Blood Elf magi, fiercely loyal to his people. Studied under Kael'thas in Dalaran and brought arcane knowledge back to rebuild Silvermoon after the Scourge invasion." },
  ["halduron brightwing"]     = { 3, "Ranger-General of Silvermoon", "Commander of the Farstriders, the elite ranger order of Quel'Thalas. Took the mantle after Sylvanas's death and Nathanos's departure." },
  ["arator the redeemer"]     = { 3, "Son of Turalyon and Alleria", "Half-elf paladin, son of two legendary heroes. Spent most of his life believing both parents were dead. Now serves the Army of the Light." },
  ["arator"]                  = { 3, "Son of Turalyon and Alleria", "Half-elf paladin, son of two legendary heroes. Spent most of his life believing both parents were dead. Now serves the Army of the Light." },
  ["kael'thas sunstrider"]    = { 4, "The Sun King", "Last of the Sunstrider dynasty, prince of the Blood Elves. Led his people to Outland seeking a cure for their magic addiction, but fell to madness and allied with the Burning Legion." },
  ["kael'thas"]               = { 4, "The Sun King", "Last of the Sunstrider dynasty, prince of the Blood Elves. Led his people to Outland seeking a cure for their magic addiction, but fell to madness and allied with the Burning Legion." },

  -- ============================================================
  -- EXPANDED: Alliance notable NPCs
  -- ============================================================
  ["mathias shaw"]            = { 3, "Spymaster of SI:7", "Leader of Stormwind's intelligence agency. A master of espionage who was replaced by a Dreadlord impersonator during the Legion invasion." },
  ["master mathias shaw"]     = { 3, "Spymaster of SI:7", "Leader of Stormwind's intelligence agency. A master of espionage who was replaced by a Dreadlord impersonator during the Legion invasion." },
  ["lady katherine proudmoore"] = { 3, "Lord Admiral of Kul Tiras", "Mother of Jaina Proudmoore, ruler of Kul Tiras. Blamed Jaina for Daelin's death and exiled her before eventually reconciling during the Fourth War." },
  ["katherine proudmoore"]    = { 3, "Lord Admiral of Kul Tiras", "Mother of Jaina Proudmoore, ruler of Kul Tiras. Blamed Jaina for Daelin's death and exiled her before eventually reconciling during the Fourth War." },
  ["moira thaurissan"]        = { 3, "Queen of the Dark Iron", "Daughter of Magni Bronzebeard, married the Dark Iron Emperor and bore his heir. Now sits on the Council of Three Hammers representing the Dark Iron clan." },
  ["high exarch yrel"]        = { 3, "Champion of Draenor", "Draenei paladin who rose from a timid refugee to the greatest champion of alternate Draenor. Became the leader of the Lightbound, forcibly converting orcs to the Light." },
  ["yrel"]                    = { 3, "Champion of Draenor", "Draenei paladin who rose from a timid refugee to the greatest champion of alternate Draenor. Became the leader of the Lightbound, forcibly converting orcs to the Light." },

  -- ============================================================
  -- EXPANDED: Horde notable NPCs
  -- ============================================================
  ["rokhan"]                  = { 3, "Shadow Hunter of the Darkspear", "Veteran troll shadow hunter, served under Vol'jin and Thrall. Became the Horde's representative on the Horde Council after Sylvanas's departure." },
  ["first arcanist thalyssra"] = { 4, "First Arcanist of Suramar", "Led the Nightborne rebellion against Elisande's alliance with the Burning Legion. Freed Suramar and brought her people into the Horde." },
  ["geya'rah"]                = { 3, "Overlord of the Mag'har", "Daughter of alternate-Durotan and Draka from Draenor. Led the Mag'har orcs to Azeroth to escape Yrel's forced Light conversion." },
  ["ji firepaw"]              = { 3, "Huojin Representative", "Leader of the Huojin Pandaren who joined the Horde. A passionate warrior from the Wandering Isle." },
  ["aysa cloudsinger"]        = { 3, "Tushui Representative", "Leader of the Tushui Pandaren who joined the Alliance. Values patience, wisdom, and careful thought." },
  ["gazlowe"]                 = { 3, "Trade Prince of the Bilgewater Cartel", "The goblin who replaced Gallywix. Actually competent and relatively honest — by goblin standards. Built half the Horde's infrastructure." },
  ["boss mida"]               = { 2, "Goblin Entrepreneur", "One of the most successful goblin businesswomen in Orgrimmar. Runs operations in the Goblin Slums and is one of Gallywix's chief rivals." },

  -- ============================================================
  -- EXPANDED: Dragonflight characters
  -- ============================================================
  ["vyranoth"]                = { 4, "Incarnate of the Frost", "One of the Primal Incarnates imprisoned by the Titans. After her release, she eventually chose to ally with the Dragon Aspects against Fyrakk." },
  ["fyrakk"]                  = { 4, "Incarnate of Shadowflame", "One of the Primal Incarnates, embodiment of fire and fury. Sought to corrupt the World Tree Amirdrassil with shadowflame before being defeated." },
  ["sabellian"]               = { 3, "Son of Deathwing", "A Black Dragon who fled to Outland and remained uncorrupted. Returned to the Dragon Isles to compete with Wrathion for leadership of the Black Dragonflight." },
  ["senegos"]                 = { 2, "Ancient Blue Dragon", "One of the oldest living Blue Dragons, slowly dying of age in Azsuna. Mentor and guardian who aided adventurers despite his fading strength." },

  -- ============================================================
  -- EXPANDED: Villains and bosses
  -- ============================================================
  ["deathwing"]               = { 5, "The Destroyer", "Neltharion the Earth-Warder, driven mad by the Old Gods' whispers. Shattered Azeroth during the Cataclysm before being destroyed by the Dragon Aspects and mortal champions." },
  ["neltharion"]              = { 5, "The Earth-Warder", "Original Aspect of the Black Dragonflight before his corruption. Created the Dragon Soul to enslave the other flights. Became the monster known as Deathwing." },
  ["sargeras"]                = { 5, "The Dark Titan", "Once the champion of the Pantheon, driven mad by witnessing the Void's corruption. Created the Burning Legion to scour all life from the universe rather than let it fall to the Void." },
  ["queen azshara"]           = { 4, "Queen of the Naga", "Once the most beautiful and powerful ruler of the Night Elf empire. Her pact with N'Zoth transformed her people into Naga. Rules from her sunken palace of Nazjatar." },
  ["azshara"]                 = { 4, "Queen of the Naga", "Once the most beautiful and powerful ruler of the Night Elf empire. Her pact with N'Zoth transformed her people into Naga. Rules from her sunken palace of Nazjatar." },
  ["n'zoth"]                  = { 4, "The Corruptor", "Last of the Old Gods active on Azeroth. Master of deception and madness, pulled the strings behind countless schemes before being destroyed by the Heart of Azeroth." },
  ["gul'dan"]                 = { 4, "Darkness Incarnate", "The orc warlock who first offered the Horde to the Burning Legion. His skull became a weapon of immense power. An alternate version repeated his treachery on Draenor." },
  ["ragnaros"]                = { 3, "The Firelord", "Elemental Lord of Fire, servant of the Old Gods. Summoned into Blackrock Mountain by the Dark Iron dwarves, later defeated permanently in the Firelands." },
  ["ragnaros the firelord"]   = { 3, "The Firelord", "Elemental Lord of Fire, servant of the Old Gods. Summoned into Blackrock Mountain by the Dark Iron dwarves, later defeated permanently in the Firelands." },
  ["kel'thuzad"]              = { 3, "Archlich of Naxxramas", "Former mage of the Kirin Tor who became Arthas's most loyal servant. Commanded Naxxramas and orchestrated the Plague of Undeath across Lordaeron." },
  ["lei shen"]                = { 3, "The Thunder King", "Mogu emperor who stole the power of the Titans. United the Mogu Empire through tyranny and enslaved the Pandaren for millennia before his defeat." },
  ["the thunder king"]        = { 3, "The Thunder King", "Mogu emperor who stole the power of the Titans. United the Mogu Empire through tyranny and enslaved the Pandaren for millennia before his defeat." },
  ["denathrius"]              = { 3, "Sire of Revendreth", "The original vampire, ruler of Revendreth in the Shadowlands. Secretly allied with the Jailer and hoarded anima while his realm starved." },
  ["sire denathrius"]         = { 3, "Sire of Revendreth", "The original vampire, ruler of Revendreth in the Shadowlands. Secretly allied with the Jailer and hoarded anima while his realm starved." },

  -- ============================================================
  -- EXPANDED: Classic / beloved NPCs
  -- ============================================================
  ["tirion fordring"]         = { 4, "Highlord of the Argent Crusade", "Exiled paladin who befriended the orc Eitrigg. Took up the Ashbringer to lead the assault on Icecrown Citadel. Shattered Frostmourne and freed Arthas's soul." },
  ["highlord tirion fordring"] = { 4, "Highlord of the Argent Crusade", "Exiled paladin who befriended the orc Eitrigg. Took up the Ashbringer to lead the assault on Icecrown Citadel. Shattered Frostmourne and freed Arthas's soul." },
  ["uther the lightbringer"]  = { 4, "First Paladin", "The first of the Knights of the Silver Hand, mentor to Arthas. Murdered by his own student at Andorhal. His soul was split between Bastion and the Maw in the Shadowlands." },
  ["uther"]                   = { 4, "First Paladin", "The first of the Knights of the Silver Hand, mentor to Arthas. Murdered by his own student at Andorhal. His soul was split between Bastion and the Maw in the Shadowlands." },
  ["cenarius"]                = { 4, "Lord of the Forest", "Demigod son of Elune and Malorne, father of druidism. Taught Malfurion the ways of nature. Killed by Grom Hellscream, later restored in the Emerald Dream." },
  ["medivh"]                  = { 4, "The Last Guardian", "The final Guardian of Tirisfal, corrupted by Sargeras before birth. Opened the Dark Portal that brought the Horde to Azeroth. Later returned as a prophet to warn of the Burning Legion." },
  ["ysera"]                   = { 4, "The Dreamer", "Aspect of the Green Dragonflight, guardian of the Emerald Dream. Corrupted by the Emerald Nightmare and slain by Tyrande, her spirit found peace among the stars of Ardenweald." },
  ["cairne bloodhoof"]        = { 3, "High Chieftain of the Tauren", "Father of Baine, one of Thrall's most trusted allies. Killed in a Mak'gora against Garrosh when the young Warchief's weapon was secretly poisoned by the Grimtotem." },
  ["saurfang"]                = { 3, "High Overlord of the Horde", "Legendary orc warrior who fought in every Horde conflict since the First War. Died challenging Sylvanas in Mak'gora before Orgrimmar." },
  ["hogger"]                  = { 2, "Terror of Elwynn Forest", "A gnoll riverpaw leader who has been terrorizing low-level Alliance players since 2004. The most infamous level 11 elite in WoW history." },
  ["linken"]                  = { 2, "Adventurer of Un'Goro", "A gnome found in Un'Goro Crater with a fairy companion and amnesia. His entire questline is an elaborate homage to The Legend of Zelda." },
  ["mylune"]                  = { 2, "Guardian of the Small", "A dryad in Hyjal obsessed with saving tiny woodland creatures. Known for her over-the-top enthusiasm for anything cute and furry." },
  ["chromie"]                 = { 4, "Ambassador of the Bronze Dragonflight", "A Bronze dragon who prefers gnome form. Guardian of the timeways, helping adventurers navigate temporal crises." },
}

-- Organization/faction pattern matching
-- If an NPC's name contains a keyword, show the org lore
-- Checked as fallback when no individual character match found
-- Format: { "keyword", tier, "Org Name", "Lore blurb" }
IABD.orgPatterns = {
  -- Major cosmic forces
  { "burning legion",     4, "The Burning Legion", "An infinite army of demons created by the fallen Titan Sargeras to scour all life from the universe. Responsible for the Sundering, the Horde's corruption, and three major invasions of Azeroth." },
  { "scourge",            4, "The Scourge", "An undead army originally created by the Burning Legion as a weapon against Azeroth. Commanded by the Lich King from Icecrown Citadel, the Scourge devastated Lordaeron and nearly consumed the world." },
  { "old god",            4, "The Old Gods", "Eldritch cosmic horrors imprisoned beneath Azeroth by the Titans. C'Thun, Yogg-Saron, N'Zoth, and Y'Shaarj whispered madness into the minds of mortals and corrupted the Black Dragonflight." },

  -- Major villain factions
  { "twilight's hammer",  3, "Twilight's Hammer", "A nihilistic cult devoted to the Old Gods and the destruction of all life. Originally an orc clan, they were transformed into a doomsday cult by Cho'gall and served Deathwing during the Cataclysm." },
  { "twilight hammer",    3, "Twilight's Hammer", "A nihilistic cult devoted to the Old Gods and the destruction of all life. Originally an orc clan, they were transformed into a doomsday cult by Cho'gall and served Deathwing during the Cataclysm." },
  { "twilight cultist",   3, "Twilight's Hammer", "A nihilistic cult devoted to the Old Gods and the destruction of all life. Originally an orc clan, they were transformed into a doomsday cult by Cho'gall and served Deathwing during the Cataclysm." },
  { "twilight prophet",   3, "Twilight's Hammer", "A nihilistic cult devoted to the Old Gods and the destruction of all life. Originally an orc clan, they were transformed into a doomsday cult by Cho'gall and served Deathwing during the Cataclysm." },
  { "scarlet crusad",     3, "Scarlet Crusade", "A fanatical order of zealots dedicated to eradicating the undead — and anyone they suspect of being sympathetic to them. Their paranoia made them nearly as dangerous as the Scourge itself." },
  { "scarlet monk",       3, "Scarlet Crusade", "A fanatical order of zealots dedicated to eradicating the undead — and anyone they suspect of being sympathetic to them. Their paranoia made them nearly as dangerous as the Scourge itself." },
  { "scarlet warrior",    3, "Scarlet Crusade", "A fanatical order of zealots dedicated to eradicating the undead — and anyone they suspect of being sympathetic to them. Their paranoia made them nearly as dangerous as the Scourge itself." },
  { "scarlet champion",   3, "Scarlet Crusade", "A fanatical order of zealots dedicated to eradicating the undead — and anyone they suspect of being sympathetic to them. Their paranoia made them nearly as dangerous as the Scourge itself." },
  { "scarlet commander",  3, "Scarlet Crusade", "A fanatical order of zealots dedicated to eradicating the undead — and anyone they suspect of being sympathetic to them. Their paranoia made them nearly as dangerous as the Scourge itself." },
  { "defias",             3, "Defias Brotherhood", "A criminal organization led by Edwin VanCleef. Originally the stonemasons who rebuilt Stormwind, they turned to crime after the nobles refused to pay them." },
  { "iron horde",         3, "The Iron Horde", "An alternate-timeline Horde created when Garrosh traveled to Draenor and convinced Grom to reject the Blood of Mannoroth. An industrial war machine that invaded Azeroth." },
  { "mogu",               3, "The Mogu", "Ancient titan-forged turned flesh who ruled Pandaria as brutal tyrants, enslaving the Pandaren for millennia. Their thunder king Lei Shen stole the power of a Titan Keeper." },
  { "mantid",             3, "The Mantid", "An insectoid race of Pandaria that worships the Old God Y'Shaarj. Every century they swarm in a devastating assault that the Pandaren's Great Wall was built to repel." },
  { "naga",               3, "The Naga", "Former Highborne night elves transformed by Queen Azshara's pact with the Old God N'Zoth during the Sundering. They dwell in the seas and serve their queen from Nazjatar." },
  { "qiraji",             3, "The Qiraji", "Insectoid servants of the Old God C'Thun, imprisoned behind the Scarab Wall in Silithus. The opening of Ahn'Qiraj was one of WoW's most iconic world events." },
  { "nerub",              3, "The Nerubians", "An ancient spider-like race that built a vast underground empire called Azjol-Nerub beneath Northrend. The Lich King waged war against them and raised many as undead." },
  { "sha of ",            3, "The Sha", "Physical manifestations of negative emotions unleashed when the Old God Y'Shaarj was killed, leaving behind its dark essence across Pandaria." },
  { "primalist",          3, "The Primalists", "Proto-dragon followers of the Primal Incarnates who reject the Titan-imposed order of the Dragon Aspects. They seek to return the world to its primal state." },

  -- Troll empires
  { "zandalari",          3, "The Zandalari Empire", "The oldest and most powerful troll civilization, rulers of the golden city of Dazar'alor. The progenitor race from which all other troll tribes descended." },
  { "amani",              3, "The Amani Tribe", "Forest trolls of Zul'Aman. Ancient enemies of the high elves of Quel'Thalas, they have waged war against elven civilization for thousands of years." },
  { "gurubashi",          3, "The Gurubashi Tribe", "Jungle trolls of Stranglethorn Vale, centered on Zul'Gurub. Their worship of the blood god Hakkar led to their empire's downfall." },
  { "drakkari",           3, "The Drakkari Tribe", "Ice trolls of Northrend who sacrificed their own loa gods for power against the Scourge — and it wasn't enough." },
  { "farraki",            3, "The Farraki Tribe", "Sand trolls of Tanaris who once built the mighty city of Zul'Farrak in the desert. Driven to desperation by the encroaching sands." },

  -- Dragonflights
  { "black dragon",       3, "Black Dragonflight", "Once the Earthwarders, corrupted by the Old Gods through Neltharion who became Deathwing. Nearly destroyed before being reborn in the Dragon Isles." },
  { "blue dragon",        3, "Blue Dragonflight", "Guardians of magic, led by Malygos then Kalecgos. Nearly destroyed when Malygos's madness led him to wage war on mortal spellcasters." },
  { "red dragon",         3, "Red Dragonflight", "Protectors of all life, led by Alexstrasza. Enslaved by the Dragonmaw orcs during the Second War, enduring immense suffering." },
  { "green dragon",       3, "Green Dragonflight", "Guardians of the Emerald Dream, led by Ysera then Merithra. Nearly lost to the Emerald Nightmare." },
  { "bronze dragon",      3, "Bronze Dragonflight", "Watchers of time itself, led by Nozdormu. They patrol the timeways against those who would alter history." },
  { "infinite dragon",    3, "Infinite Dragonflight", "Corrupted Bronze Dragons led by Murozond — the future version of Nozdormu. They seek to alter the timeline." },

  -- Player-allied organizations
  { "kirin tor",          2, "The Kirin Tor", "An elite order of mages based in the floating city of Dalaran. They serve as neutral peacekeepers and guardians of dangerous magical knowledge." },
  { "cenarion",           2, "Cenarion Circle", "An order of druids dedicated to protecting nature, named for Cenarius. They maintain the balance between wilds and civilization." },
  { "earthen ring",       2, "The Earthen Ring", "A shamanistic organization maintaining the balance of elemental forces. Critical in preventing the Cataclysm from tearing the world apart." },
  { "argent crusad",      2, "The Argent Crusade", "A holy order formed from the Argent Dawn and Knights of the Silver Hand. Led the assault on Icecrown Citadel against the Lich King." },
  { "argent dawn",        2, "The Argent Dawn", "A holy order formed from the Argent Dawn and Knights of the Silver Hand. Led the assault on Icecrown Citadel against the Lich King." },
  { "argent champion",    2, "The Argent Crusade", "A holy order formed from the Argent Dawn and Knights of the Silver Hand. Led the assault on Icecrown Citadel against the Lich King." },
  { "ebon blade",         2, "Knights of the Ebon Blade", "Death Knights freed from the Lich King's control. Led by Darion Mograine, they fight to prove the undead can serve a righteous cause." },
  { "illidari",           2, "The Illidari", "Demon Hunters trained by Illidan who sacrificed their eyes and absorbed demonic power. Released from imprisonment to combat the Legion." },
  { "shado-pan",          2, "The Shado-Pan", "Elite Pandaren military order founded by Emperor Shaohao to protect against the Sha and external threats." },
  { "nightborne",         2, "The Nightborne", "Night elves of Suramar who sheltered beneath a magical barrier for 10,000 years. Rebelled against Elisande and joined the Horde." },
  { "lightforged",        2, "Lightforged Draenei", "Draenei infused with the Light during their thousand-year war against the Burning Legion aboard the Vindicaar." },
  { "void elf",           2, "Void Elves", "Blood elves exiled from Silvermoon for studying the Void. Rescued by Alleria Windrunner, they harness shadow magic." },
  { "blood knight",       2, "Blood Knights", "The paladin order of the Blood Elves, originally powered by draining a naaru. Found genuine faith after the Sunwell's restoration." },
  { "farstrider",         2, "Farstriders", "Elite ranger order of Quel'Thalas, defenders of the Blood Elf homeland for thousands of years." },
  { "sunreaver",          2, "The Sunreavers", "Blood Elf members of the Kirin Tor in Dalaran, led by Aethas Sunreaver." },
  { "silver covenant",    2, "The Silver Covenant", "High Elf loyalists in Dalaran led by Vereesa Windrunner. They represent the remnants who refused to become Blood Elves." },
  { "forsaken deathguard", 2, "The Forsaken", "Undead who broke free from the Lich King, led by Sylvanas from the Undercity. Feared by the living and reviled by the Scourge alike." },
  { "forsaken apothecary", 2, "The Forsaken", "Undead who broke free from the Lich King, led by Sylvanas from the Undercity. Feared by the living and reviled by the Scourge alike." },
  { "deathguard",         2, "The Forsaken", "Undead who broke free from the Lich King, led by Sylvanas from the Undercity. Feared by the living and reviled by the Scourge alike." },
  { "dark ranger",        2, "The Forsaken", "Undead who broke free from the Lich King, led by Sylvanas from the Undercity. Feared by the living and reviled by the Scourge alike." },
  { "sentinel huntress",  2, "The Sentinels", "The military force of the Night Elves, led by Shandris Feathermoon. Guardians of Kalimdor's forests for ten thousand years." },
  { "sentinel commander", 2, "The Sentinels", "The military force of the Night Elves, led by Shandris Feathermoon. Guardians of Kalimdor's forests for ten thousand years." },
  { "night elf sentinel",  2, "The Sentinels", "The military force of the Night Elves, led by Shandris Feathermoon. Guardians of Kalimdor's forests for ten thousand years." },
  { "warden ",            2, "The Watchers", "Night Elf order founded by Maiev Shadowsong to guard Illidan's prison. Pursued him across worlds with single-minded determination." },
  { "venture co",         2, "Venture Company", "A ruthless goblin mining conglomerate that strips natural resources with zero regard for the environment or locals." },
  { "syndicate",          2, "The Syndicate", "Former Alteraci nobles who lost their kingdom after the Second War. They scheme to reclaim their power from the shadows." },
  { "grimtotem",          2, "Grimtotem Tribe", "A renegade tauren tribe that rejected Cairne's peaceful ways. They poisoned Garrosh's weapon in his Mak'gora against Cairne." },
  { "dark iron",          2, "Dark Iron Clan", "Dwarves who summoned Ragnaros and were enslaved by him for centuries. Now led by Moira Thaurissan on the Council of Three Hammers." },
  { "wildhammer",         2, "Wildhammer Clan", "Dwarves of the Hinterlands known for their bond with gryphons and their shamanistic traditions. Members of the Council of Three Hammers." },
  { "frostwolf",          2, "Frostwolf Clan", "The orc clan of Thrall's father Durotan. One of the few clans that refused to drink Mannoroth's blood. Known for their bond with wolves." },
  { "warsong",            2, "Warsong Clan", "Fierce orc warriors led by Grom Hellscream. First to drink Mannoroth's blood, and first to be freed when Grom killed Mannoroth." },
  { "blackrock",          2, "Blackrock Clan", "The largest and most militaristic orc clan, once led by Blackhand and then Orgrim Doomhammer. They occupied Blackrock Mountain." },
  { "dragonmaw",          2, "Dragonmaw Clan", "Orcs notorious for enslaving Alexstrasza and her red dragons during the Second War using the Demon Soul." },
  { "shadowmoon",         2, "Shadowmoon Clan", "An orc clan of warlocks and mystics, originally led by Ner'zhul. Their mastery of shadow magic made them feared across Draenor." },
}
