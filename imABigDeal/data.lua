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

-- Name lookup table (built at load time for /iabd lookup)
IABD.nameIndex = {}
