#!/usr/bin/env python3
"""
I'm A Big Deal — Wowhead NPC Scraper
Pulls NPC data from wowhead.com to enrich the lore database with
quest info, zone locations, and detailed descriptions.

Usage:
  python3 wowhead_scraper.py                    # Scrape notable NPCs
  python3 wowhead_scraper.py --zone "Silvermoon" # Scrape NPCs from a zone
  python3 wowhead_scraper.py --npc 241735        # Scrape a specific NPC ID
  python3 wowhead_scraper.py --search "Ranger"   # Search for NPCs by name

Output: ../data_wowhead.lua
"""

import json
import re
import sys
import time
import urllib.request
import urllib.parse
import os

USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
REQUEST_DELAY = 2.0  # Be respectful to wowhead

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
OUTPUT_PATH = os.path.join(SCRIPT_DIR, "..", "data_wowhead.lua")


def fetch_url(url):
    """Fetch a URL with proper headers."""
    req = urllib.request.Request(url, headers={
        "User-Agent": USER_AGENT,
        "Accept": "text/html,application/json",
    })
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            return resp.read().decode("utf-8", errors="replace")
    except Exception as e:
        print(f"  Error fetching {url}: {e}")
        return None


def scrape_npc_page(npc_id):
    """Scrape a single NPC page from wowhead."""
    url = f"https://www.wowhead.com/npc={npc_id}"
    html = fetch_url(url)
    if not html:
        return None

    result = {"npc_id": npc_id}

    # Extract NPC name from title
    title_match = re.search(r'<h1 class="heading-size-1[^"]*">([^<]+)</h1>', html)
    if title_match:
        result["name"] = title_match.group(1).strip()

    # Extract NPC title/tag (shown under name)
    tag_match = re.search(r'<div class="sub-heading[^"]*">([^<]+)</div>', html)
    if not tag_match:
        tag_match = re.search(r'"tag":"([^"]+)"', html)
    if tag_match:
        result["title"] = tag_match.group(1).strip()

    # Extract description/tooltip text
    tooltip_match = re.search(r'"tooltip_enus":"([^"]*)"', html)
    if tooltip_match:
        tooltip = tooltip_match.group(1)
        # Clean HTML from tooltip
        tooltip = re.sub(r'<[^>]+>', '', tooltip)
        tooltip = tooltip.replace('\\n', ' ').replace('\\r', '').strip()
        if len(tooltip) > 10:
            result["tooltip"] = tooltip

    # Extract location/zone
    zone_match = re.search(r'"location":\[(\d+)\]', html)
    if zone_match:
        result["zone_id"] = int(zone_match.group(1))

    # Look for zone name in breadcrumbs or page content
    zone_name_match = re.search(r'data-tree="[^"]*">([^<]+)</a>\s*&[^;]*;\s*NPCs', html)
    if zone_name_match:
        result["zone"] = zone_name_match.group(1).strip()

    # Extract classification
    if '"classification":3' in html:
        result["classification"] = "rare"
    elif '"classification":2' in html:
        result["classification"] = "rareelite"
    elif '"classification":1' in html:
        result["classification"] = "elite"
    elif '"classification":4' in html:
        result["classification"] = "worldboss"

    # Extract react info (faction)
    if '"react":[-1,1]' in html or '"react":[-1,' in html:
        result["faction"] = "Horde"
    elif '"react":[1,-1]' in html or '"react":[1,' in html:
        result["faction"] = "Alliance"
    elif '"react":[1,1]' in html:
        result["faction"] = "Neutral"

    # Extract level
    level_match = re.search(r'"minlevel":(\d+)', html)
    if level_match:
        result["level"] = int(level_match.group(1))

    # Extract race/type
    type_match = re.search(r'"type":(\d+)', html)
    if type_match:
        type_id = int(type_match.group(1))
        type_names = {
            1: "Beast", 2: "Dragonkin", 3: "Demon", 4: "Elemental",
            5: "Giant", 6: "Undead", 7: "Humanoid", 8: "Critter",
            9: "Mechanical", 10: "Not specified", 11: "Totem",
            12: "Non-combat Pet", 13: "Gas Cloud",
        }
        result["creature_type"] = type_names.get(type_id, "Unknown")

    # Extract quests this NPC starts
    quest_starts = re.findall(r'Starts:\s*<a[^>]*href="/quest=(\d+)[^"]*"[^>]*>([^<]+)</a>', html)
    if quest_starts:
        result["quests_start"] = [{"id": int(q[0]), "name": q[1]} for q in quest_starts[:5]]

    # Extract quests this NPC ends
    quest_ends = re.findall(r'Ends:\s*<a[^>]*href="/quest=(\d+)[^"]*"[^>]*>([^<]+)</a>', html)
    if quest_ends:
        result["quests_end"] = [{"id": int(q[0]), "name": q[1]} for q in quest_ends[:5]]

    # Try to get a description from the comments or page text
    # Wowhead's NPC pages sometimes have a description in the tooltip data
    desc_match = re.search(r'"description_enus":"([^"]*)"', html)
    if desc_match:
        desc = desc_match.group(1).strip()
        desc = re.sub(r'<[^>]+>', '', desc)
        if len(desc) > 10:
            result["description"] = desc

    return result


def search_npcs(query, limit=50):
    """Search wowhead for NPCs matching a query."""
    encoded = urllib.parse.quote(query)
    url = f"https://www.wowhead.com/search?q={encoded}&type=npcs"
    html = fetch_url(url)
    if not html:
        return []

    # Extract NPC results from the search page
    # Wowhead embeds search results as JSON in the page
    results = []
    npc_matches = re.findall(r'"id":(\d+),"name":"([^"]+)"', html)
    for npc_id, name in npc_matches[:limit]:
        results.append({"npc_id": int(npc_id), "name": name})

    return results


def build_blurb(npc_data):
    """Build a lore blurb from scraped NPC data."""
    parts = []

    if npc_data.get("title"):
        parts.append(npc_data["title"] + ".")

    if npc_data.get("description"):
        parts.append(npc_data["description"])
    elif npc_data.get("tooltip"):
        parts.append(npc_data["tooltip"])

    if npc_data.get("zone"):
        parts.append("Found in " + npc_data["zone"] + ".")

    if npc_data.get("faction"):
        parts.append(npc_data["faction"] + ".")

    if npc_data.get("classification"):
        cl = npc_data["classification"]
        if cl == "rare":
            parts.append("Rare spawn.")
        elif cl == "rareelite":
            parts.append("Rare Elite.")
        elif cl == "worldboss":
            parts.append("World Boss.")

    # Quest info
    quests = npc_data.get("quests_start", [])
    if quests:
        quest_names = [q["name"] for q in quests[:3]]
        parts.append("Starts quests: " + ", ".join(quest_names) + ".")

    quests_end = npc_data.get("quests_end", [])
    if quests_end:
        quest_names = [q["name"] for q in quests_end[:3]]
        parts.append("Ends quests: " + ", ".join(quest_names) + ".")

    blurb = " ".join(parts)
    if len(blurb) > 300:
        blurb = blurb[:297] + "..."
    return blurb


def classify_tier(npc_data):
    """Classify tier based on NPC data."""
    cl = npc_data.get("classification", "normal")
    has_quests = bool(npc_data.get("quests_start") or npc_data.get("quests_end"))

    if cl == "worldboss":
        return 4
    elif cl == "rareelite":
        return 3
    elif cl == "rare":
        return 3
    elif cl == "elite" or has_quests:
        return 2
    else:
        return 2  # Named NPCs are at least Uncommon


def lua_escape(s):
    """Escape a string for Lua."""
    s = str(s)
    s = s.replace("\\", "\\\\")
    s = s.replace('"', "'")
    s = s.replace("\n", " ")
    s = s.replace("\r", "")
    s = s.replace("\t", " ")
    return s


def generate_lua(npcs):
    """Generate Lua output from scraped NPC data."""
    lines = []
    lines.append("-- AUTO-GENERATED by tools/wowhead_scraper.py")
    lines.append(f"-- Generated: {time.strftime('%Y-%m-%d %H:%M:%S')}")
    lines.append(f"-- Total NPCs: {len(npcs)}")
    lines.append("")
    lines.append('local ADDON_NAME = "ImABigDeal"')
    lines.append("local IABD = _G[ADDON_NAME]")
    lines.append("")
    lines.append("-- Merge wowhead data into nameOverrides")
    lines.append("for name, entry in pairs({")

    for npc in sorted(npcs, key=lambda x: (-x.get("tier", 2), x.get("name", ""))):
        name = lua_escape(npc.get("name", "").lower())
        title = lua_escape(npc.get("title", ""))
        blurb = lua_escape(npc.get("blurb", ""))
        tier = npc.get("tier", 2)

        if name and blurb:
            lines.append(f'  ["{name}"] = {{ {tier}, "{title}", "{blurb}" }},')

    lines.append("}) do")
    lines.append("  if not IABD.nameOverrides[name] then")
    lines.append("    IABD.nameOverrides[name] = entry")
    lines.append("  end")
    lines.append("end")

    return "\n".join(lines)


def scrape_npc_list(npc_ids):
    """Scrape a list of NPC IDs."""
    results = []
    total = len(npc_ids)

    for i, npc_id in enumerate(npc_ids):
        pct = (i / total) * 100
        print(f"  [{pct:.0f}%] Scraping NPC {npc_id}...")

        data = scrape_npc_page(npc_id)
        if data and data.get("name"):
            data["tier"] = classify_tier(data)
            data["blurb"] = build_blurb(data)
            results.append(data)
            print(f"    -> {data['name']}: {data.get('title', '(no title)')}")
        else:
            print(f"    -> Failed or no data")

        time.sleep(REQUEST_DELAY)

    return results


def main():
    args = sys.argv[1:]

    if "--npc" in args:
        # Scrape a specific NPC
        idx = args.index("--npc")
        npc_id = int(args[idx + 1])
        print(f"Scraping NPC {npc_id}...")
        data = scrape_npc_page(npc_id)
        if data:
            data["tier"] = classify_tier(data)
            data["blurb"] = build_blurb(data)
            print(json.dumps(data, indent=2))

            # Also append to output file
            lua = generate_lua([data])
            with open(OUTPUT_PATH, "w", encoding="utf-8") as f:
                f.write(lua)
            print(f"\nWritten to: {OUTPUT_PATH}")
        else:
            print("Failed to scrape NPC")
        return

    if "--search" in args:
        # Search for NPCs
        idx = args.index("--search")
        query = args[idx + 1]
        print(f"Searching wowhead for '{query}'...")
        results = search_npcs(query)
        if results:
            print(f"Found {len(results)} NPCs:")
            for r in results:
                print(f"  NPC {r['npc_id']}: {r['name']}")

            # Scrape each result
            print(f"\nScraping {len(results)} NPCs...")
            npc_ids = [r["npc_id"] for r in results]
            scraped = scrape_npc_list(npc_ids)

            lua = generate_lua(scraped)
            with open(OUTPUT_PATH, "w", encoding="utf-8") as f:
                f.write(lua)
            print(f"\nWritten {len(scraped)} NPCs to: {OUTPUT_PATH}")
        else:
            print("No results found")
        return

    # Default: scrape a curated list of notable NPC IDs
    # These are commonly-encountered 12.0 Midnight NPCs
    print("I'm A Big Deal — Wowhead NPC Scraper")
    print("=" * 50)
    print("Use --search <query> to find specific NPCs")
    print("Use --npc <id> to scrape a specific NPC ID")
    print()
    print("To scrape an NPC you found in-game:")
    print("  1. Target the NPC and type /iabd info")
    print("  2. Note the NPC ID from the output")
    print("  3. Run: python3 wowhead_scraper.py --npc <id>")
    print()
    print("To search for NPCs:")
    print("  python3 wowhead_scraper.py --search \"Ranger\"")
    print()
    print("To bulk scrape from a list of IDs:")
    print("  Create a file 'npc_ids.txt' with one ID per line")
    print("  python3 wowhead_scraper.py --bulk npc_ids.txt")

    if "--bulk" in args:
        idx = args.index("--bulk")
        filename = args[idx + 1]
        with open(filename, "r") as f:
            npc_ids = [int(line.strip()) for line in f if line.strip().isdigit()]
        print(f"\nScraping {len(npc_ids)} NPCs from {filename}...")
        scraped = scrape_npc_list(npc_ids)

        lua = generate_lua(scraped)
        with open(OUTPUT_PATH, "w", encoding="utf-8") as f:
            f.write(lua)
        print(f"\nWritten {len(scraped)} NPCs to: {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
