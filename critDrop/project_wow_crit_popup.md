---
name: WoW Crit Popup Addon
description: Chrono Trigger-style critical hit popup addon for WoW 12.0 Midnight — animation works, combat detection does NOT
type: project
---

## Project Overview
Building a WoW addon that displays critical hit damage as Chrono Trigger-style popups (pop-in, jiggle, settle, fade). Located at `/mnt/c/Users/jesse/aiproject/WoWCritPopup/` with a live copy deployed to `E:\Blizzard\World of Warcraft\_retail_\Interface\Addons\CritPopup\`.

## Current Status: PARTIALLY WORKING
- **Animation system: WORKS** — `/cp test` shows the popup with AnimationGroup-based pop-in + jiggle + fade
- **Settings panel: UNTESTED** — config.lua built but not verified in 12.0
- **Combat detection: BROKEN** — Cannot detect crits in actual combat

## WoW Version
- **WoW 12.0.1 (Midnight expansion, 2026)**
- **TOC Interface: 120001**
- Player has BugGrabber installed which reports taint errors

## Critical 12.0 API Changes (VERIFIED)
Source: https://warcraft.wiki.gg/wiki/Patch_12.0.0/API_changes

1. **`COMBAT_LOG_EVENT_UNFILTERED` was REMOVED** — Listed in "Removed (138)" section. Does NOT exist in 12.0.
2. **`Frame:RegisterEvent()` is PROTECTED** — Addons cannot call it. Causes ADDON_ACTION_FORBIDDEN.
3. **`FloatingCombatTextFrame` does NOT EXIST** in 12.0.
4. **`SetOffset()` on FontStrings does NOT EXIST** in 12.0.
5. **`GameFontBold` template does NOT EXIST** — Use manual `SetFont("Fonts\\FRIZQT__.TTF", size, "OUTLINE")` instead. Must call SetFont BEFORE SetText.
6. **`frame:IsValid()` does NOT EXIST** — Just check `if frame then`.

## New 12.0 APIs (from wiki research)
1. **`RegisterEventCallback(event, callback, source)`** — Replaces Frame:RegisterEvent. Global function.
2. **`RegisterUnitEventCallback(event, unit, callback)`** — Unit-specific events.
3. **`Frame:RegisterEventCallback`** — Frame method version.
4. **`COMBAT_LOG_EVENT_INTERNAL_UNFILTERED`** — Possible replacement for CLEU (name found in wiki).
5. **`COMBAT_LOG_MESSAGE`** — New event for combat log messages.
6. **`C_CombatLog` namespace** — New APIs: ApplyFilterSettings, SetFilteredEventsEnabled, RefilterEntries, IsCombatLogRestricted.
7. **`C_DamageMeter.GetCombatSessionSourceFromID`** — May provide damage data.
8. **Secret Values system** — Combat data wrapped in secrets; `issecretvalue`, `issecrettable`, `canaccessvalue` functions exist.
9. **`C_Secrets.ShouldCooldownsBeSecret()`, `C_Secrets.ShouldAurasBeSecret()`** — Control what's secret.

## What We Tried (and failed)
1. ❌ `Frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")` — Event doesn't exist
2. ❌ `Frame:RegisterEvent()` at top level — Protected function
3. ❌ `Frame:RegisterEvent()` inside C_Timer.After — Still protected
4. ❌ `Frame:RegisterEvent()` inside ADDON_LOADED handler — Still protected
5. ❌ `pcall(Frame:RegisterEvent)` — Taint fires anyway (BugGrabber catches it), and event doesn't exist regardless
6. ❌ `EventRegistry:RegisterFrameEventAndCallback` — Didn't produce output
7. ✅ `RegisterEventCallback("ADDON_LOADED", ...)` — Works for ADDON_LOADED
8. ❓ `RegisterEventCallback("COMBAT_LOG_EVENT_INTERNAL_UNFILTERED", ...)` — Registered without error but no combat events fired
9. ❓ `RegisterEventCallback("COMBAT_LOG_MESSAGE", ...)` — Untested (fallback path)

## What to Try Next
1. **Check what message appeared in chat on reload** — Did it say "Detection active (INTERNAL_UNFILTERED)" or something else?
2. **Add debug output** to OnCombatLogEvent to see if it's ever called
3. **Try `COMBAT_LOG_MESSAGE` event** — Might be the correct event name
4. **Explore `C_DamageMeter` APIs** — Damage meters still work in 12.0, this namespace may hold the key
5. **Look at MikScrollingBattleText Midnight source** — It exists on CurseForge, so SOMEONE solved this
6. **Try `UNIT_COMBAT` event** via RegisterEventCallback — Older event that might still fire for player damage
7. **Check if `CombatLogGetCurrentEventInfo()` still exists** — It may have been removed too
8. **Research Secret Values** — Combat data might be accessible but wrapped in secrets
9. **Look at the Cell addon PR #457** on GitHub — enderneko/Cell has a PR titled "WoW 12.0.0 (Midnight) Compatibility — Secret Values, CLEU Removal, and Spell Updates" which likely has working code

## File Structure
```
WoWCritPopup/           (source at /mnt/c/Users/jesse/aiproject/)
CritPopup/              (deployed at E:\...\Interface\Addons\)
├── CritPopup.toc       (Interface: 120001)
├── CritPopup.lua       (main addon, settings, handlers, slash commands)
├── animations.lua      (AnimationGroup-based pop-in/jiggle/fade)
├── detection.lua       (combat detection — currently broken)
├── config.lua          (settings panel UI — untested)
├── README.md
├── TESTING.md
├── DEPLOY.md
└── tests/
    └── test_integration.lua
```

## Animation System (WORKING)
Uses AnimationGroup with chained animations:
- Scale 0.01→1.5 (pop-in, 0.08s, order 1)
- Scale 1.5→1.0 (settle, 0.12s, order 2)  
- 5 Translation animations alternating left/right with decreasing amplitude (jiggle, 0.04s each, orders 3-7)
- Hold for configurable duration
- Alpha 1→0 + Translation upward (fade out, 0.5s)

## Design Spec
Full spec at: `docs/superpowers/specs/2026-04-09-wow-crit-popup-addon-design.md`
Implementation plan at: `docs/superpowers/plans/2026-04-09-wow-crit-popup-addon.md`

## Key Reference Links
- [12.0 API changes](https://warcraft.wiki.gg/wiki/Patch_12.0.0/API_changes)
- [12.0 Planned API changes](https://warcraft.wiki.gg/wiki/Patch_12.0.0/Planned_API_changes)
- [Cell addon 12.0 compat PR](https://github.com/enderneko/Cell/pull/457) — Has working CLEU replacement code
- [Combat restrictions eased article](https://www.icy-veins.com/wow/news/combat-addon-restrictions-eased-in-midnight/)
- [MikScrollingBattleText Midnight](https://www.curseforge.com/wow/addons/mikscrollingbattletext-midnight)
- [Secure Execution and Tainting](https://warcraft.wiki.gg/wiki/Secure_Execution_and_Tainting)
