# I'm A Big Deal — WoW Lore Significance Addon

## Concept
When you target an NPC, the addon detects how important they are in WoW lore and:
1. Shows a **colored rarity dot** on their portrait frame
2. Pops up a **lore blurb** with who they are and why they matter

Think: rare mob detector, but for *lore importance*.

## Rarity Tiers (WoW item colors)

| Tier | Color | Hex | Examples |
|------|-------|-----|----------|
| **Legendary** | Orange | `#ff8000` | Thrall, Sylvanas, Arthas, Illidan, Jaina |
| **Epic** | Purple | `#a335ee` | Lor'themar, Thalyssra, Khadgar, Baine |
| **Rare** | Blue | `#0070dd` | Zone leaders, dungeon bosses with lore, key questgivers |
| **Uncommon** | Green | `#1eff00` | Minor questgivers with backstory, named NPCs referenced in books |
| **Common** | White | `#ffffff` | Generic named NPCs (innkeepers, vendors with names) |
| **None** | — | — | Unnamed mobs, critters, generic guards (no indicator shown) |

## Core Features

### 1. Portrait Rarity Dot
- Small colored dot (or gem/star) overlaid on the target portrait frame corner
- Color matches the lore tier
- Only shows for Common and above (no dot for nobodies)
- Positioned top-right of the target frame, non-intrusive

### 2. Lore Popup
- Triggered when targeting a Uncommon+ NPC
- Compact toast notification (NOT a full popup that blocks gameplay)
- Shows: Name, Title, Tier, 1-2 sentence lore summary
- Auto-dismisses after a few seconds
- Option to click for more detail (expanded view)
- Cooldown: don't re-show for the same NPC within a session unless requested

### 3. Lore Database
This is the big question. Options:

#### Option A: Bundled Local Database (Recommended for v1)
- Ship a Lua table mapping NPC IDs → { tier, title, blurb }
- Pros: Works offline, fast, no API calls, no TOS issues
- Cons: Manual curation, needs updates for new expansions
- Start with ~500 key lore characters, expand over time
- Community can contribute via GitHub

#### Option B: Wowhead/Wowpedia Scraping
- Fetch data from wowhead.com or warcraft.wiki.gg at runtime
- Pros: Always up to date, massive coverage
- Cons: WoW addons CANNOT make HTTP requests (no socket access)
- Would need an external companion app or pre-scraping tool
- **Not viable for in-game addon alone**

#### Option C: Hybrid (v2+)
- Bundle core database (top ~500 NPCs)
- Companion tool (Python script) that scrapes and generates updated Lua tables
- User runs the updater periodically, it overwrites the data file
- Best of both worlds

### Recommended Approach: Option A for v1, Option C for v2

## Data Structure

```lua
-- data.lua
ImABigDeal_DB = {
  -- [npcID] = { tier, "Title", "Lore blurb" }
  [10182] = { 5, "Warchief of the Horde", "Thrall, born Go'el, was raised as a slave by humans before escaping to unite the Horde. Former Warchief and wielder of the Doomhammer." },  -- Thrall
  [16802] = { 5, "The Banshee Queen", "Sylvanas Windrunner was the Ranger-General of Silvermoon before Arthas killed her and raised her as a banshee. Led the Forsaken and later became Warchief." },  -- Sylvanas
  -- tier: 5=Legendary, 4=Epic, 3=Rare, 2=Uncommon, 1=Common
}
```

## How to Get NPC ID in 12.0

```lua
-- When player targets something:
local guid = UnitGUID("target")
-- GUID format: "Creature-0-XXXX-XXXX-XXXX-NPCID-INSTANCE"
-- Extract NPC ID from GUID:
local npcID = select(6, strsplit("-", guid))
npcID = tonumber(npcID)
-- Then look up: ImABigDeal_DB[npcID]
```

## File Structure

```
imABigDeal/
├── ImABigDeal.toc          -- Addon metadata
├── ImABigDeal.lua          -- Core: target detection, portrait dot, popup
├── data.lua                -- Lore database (NPC ID → tier/title/blurb)
├── ui.lua                  -- Toast popup frame, expanded detail view
├── config.lua              -- Settings panel, slash commands
└── tools/
    └── scraper.py          -- (v2) Wowhead/Wowpedia scraper to generate data.lua
```

## Settings
- Enable/disable portrait dot
- Enable/disable lore popup
- Popup duration (seconds)
- Minimum tier to show popup (e.g., only Rare+)
- Minimum tier to show dot (e.g., only Uncommon+)
- Popup position (top, bottom, side of screen)
- "Already seen" cooldown (don't re-popup same NPC for X minutes)

## Slash Commands
- `/iabd` or `/bigdeal` — Toggle settings
- `/iabd lookup <name>` — Search the database by name
- `/iabd info` — Show info for current target

## Technical Considerations for 12.0
- Use RegisterEventCallback for PLAYER_TARGET_CHANGED (or equivalent)
- Portrait dot: CreateFrame overlaid on TargetFrame (need to find the right anchor)
- No HTTP access — database must be local
- GUID parsing should work the same in 12.0
- Target frame structure may have changed — need to verify anchor points

## MVP Scope (v1)
1. Detect target, extract NPC ID from GUID
2. Look up in bundled database
3. Show colored dot on portrait
4. Show toast popup with name/title/blurb
5. Settings for on/off and minimum tier
6. Ship with ~100-200 iconic lore characters to start

## Data Sourcing Strategy
1. Start with faction leaders and expansion main characters
2. Add raid bosses and dungeon bosses with significant lore
3. Add key questline NPCs
4. Community contributions via GitHub PRs to data.lua
5. (v2) Automated scraper to bulk-generate entries

## Open Questions
- Should we show the dot for hostile/dead NPCs? (Probably yes — you might target a boss corpse)
- Should there be a "discovery" mode where you collect lore entries like achievements?
- Sound on legendary target? (Could be fun but potentially annoying)
- Should the popup show during combat? (Probably not — option to suppress in combat)
