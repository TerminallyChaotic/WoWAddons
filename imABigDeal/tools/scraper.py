#!/usr/bin/env python3
"""
I'm A Big Deal — Lore Database Scraper
Pulls character data from warcraft.wiki.gg and generates the Lua nameOverrides table.

Usage:
  python3 scraper.py              # Full scrape (takes a few minutes)
  python3 scraper.py --quick      # Quick mode: top categories only (~500 chars)
  python3 scraper.py --output     # Print output path

Output: ../data_generated.lua (drop into the addon folder)
"""

import json
import re
import sys
import time
import urllib.request
import urllib.parse
import os

API_URL = "https://warcraft.wiki.gg/api.php"
USER_AGENT = "ImABigDealScraper/1.0 (WoW Addon Lore Database)"
REQUEST_DELAY = 1.5  # seconds between requests

# ============================================================
# Tier Classification
# ============================================================

LEGENDARY_NAMES = {
    "thrall", "go'el", "sylvanas windrunner", "jaina proudmoore",
    "anduin wrynn", "illidan stormrage", "illidan", "arthas menethil",
    "the lich king", "bolvar fordragon", "malfurion stormrage",
    "tyrande whisperwind", "vol'jin", "garrosh hellscream",
    "varian wrynn", "khadgar", "magni bronzebeard", "deathwing",
    "neltharion", "sargeras", "medivh", "aegwynn",
}

EPIC_NAMES = {
    "lor'themar theron", "baine bloodhoof", "genn greymane",
    "thalyssra", "alleria windrunner", "turalyon", "lady liadrin",
    "talanji", "calia menethil", "prophet velen", "velen",
    "alexstrasza", "nozdormu", "wrathion", "kalecgos", "chromie",
    "merithra", "ebyssian", "mayla highmountain", "kael'thas sunstrider",
    "queen azshara", "azshara", "n'zoth", "gul'dan",
    "tirion fordring", "uther the lightbringer", "uther",
    "cenarius", "ysera", "fyrakk", "vyranoth",
    "kil'jaeden", "archimonde", "mannoroth",
}

EPIC_CATEGORIES = {
    "Leaders", "Warchief of the Horde", "High King of the Alliance",
    "Final bosses", "Dragon Aspects", "City bosses",
    "Aspects", "Old Gods", "Titans",
}

RARE_CATEGORIES = {
    "Raid bosses", "Dungeon bosses", "Wardens",
    "Leaders of Azeroth characters",
}

def classify_tier(name, categories, has_character_infobox):
    """Classify a character into a lore tier (1-5)."""
    name_lower = name.lower().strip()
    cat_set = set(categories)

    if name_lower in LEGENDARY_NAMES:
        return 5

    if name_lower in EPIC_NAMES:
        return 4

    if any(c in cat_set for c in EPIC_CATEGORIES):
        return 4

    if any(c in cat_set for c in RARE_CATEGORIES):
        return 3

    if has_character_infobox:
        return 3  # Has a lore infobox = at least Rare

    return 2  # Named NPC with a wiki article = Uncommon


# ============================================================
# Wiki API Functions
# ============================================================

def api_request(params):
    """Make a request to the warcraft.wiki.gg API."""
    params["format"] = "json"
    params["maxlag"] = "5"
    url = API_URL + "?" + urllib.parse.urlencode(params)

    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            return json.loads(resp.read().decode("utf-8"))
    except Exception as e:
        print(f"  API error: {e}")
        return None


def get_subcategories(category):
    """Get all subcategory names for a parent category."""
    subcats = []
    params = {
        "action": "query",
        "list": "categorymembers",
        "cmtitle": f"Category:{category}",
        "cmlimit": "500",
        "cmtype": "subcat",
    }
    data = api_request(params)
    if data and "query" in data:
        for m in data["query"].get("categorymembers", []):
            # Strip "Category:" prefix and convert spaces to underscores
            name = m["title"].replace("Category:", "").replace(" ", "_")
            subcats.append(name)
    return subcats


def get_category_members(category, limit=500):
    """Get all page titles in a category."""
    members = []
    params = {
        "action": "query",
        "list": "categorymembers",
        "cmtitle": f"Category:{category.replace('_', ' ')}",
        "cmlimit": str(min(limit, 500)),
        "cmtype": "page",
    }

    while True:
        data = api_request(params)
        if not data or "query" not in data:
            break

        for m in data["query"].get("categorymembers", []):
            members.append(m["title"])

        if "continue" in data and len(members) < limit:
            params["cmcontinue"] = data["continue"]["cmcontinue"]
            time.sleep(REQUEST_DELAY)
        else:
            break

    return members


def get_page_extracts(titles):
    """Get plain-text intro extracts for up to 20 pages at once."""
    if not titles:
        return {}

    params = {
        "action": "query",
        "titles": "|".join(titles[:20]),
        "prop": "extracts|categories",
        "exintro": "true",
        "exsentences": "2",
        "explaintext": "true",
        "cllimit": "50",
    }

    data = api_request(params)
    if not data or "query" not in data:
        return {}

    results = {}
    pages = data["query"].get("pages", {})
    for page_id, page in pages.items():
        if page_id == "-1" or "missing" in page:
            continue
        title = page.get("title", "")
        extract = page.get("extract", "")
        categories = [c["title"].replace("Category:", "")
                      for c in page.get("categories", [])]
        results[title] = {
            "extract": extract,
            "categories": categories,
        }

    return results


def get_page_infobox_check(titles):
    """Check which pages have Character infobox vs Npcbox."""
    if not titles:
        return {}

    params = {
        "action": "query",
        "titles": "|".join(titles[:20]),
        "prop": "revisions",
        "rvprop": "content",
        "rvslots": "main",
        "rvsection": "0",
    }

    data = api_request(params)
    if not data or "query" not in data:
        return {}

    results = {}
    pages = data["query"].get("pages", {})
    for page_id, page in pages.items():
        if page_id == "-1" or "missing" in page:
            continue
        title = page.get("title", "")
        content = ""
        revs = page.get("revisions", [])
        if revs:
            slots = revs[0].get("slots", {})
            main = slots.get("main", {})
            content = main.get("*", "") if isinstance(main, dict) else ""

        has_char_infobox = "Character infobox" in content or "character infobox" in content.lower()
        results[title] = has_char_infobox

    return results


# ============================================================
# Title Extraction (get a "title" from infobox or first line)
# ============================================================

def extract_title_from_text(extract):
    """Try to extract a character title/role from the extract text."""
    if not extract:
        return ""

    # Common patterns: "X is a Y" or "X was a Y" or "X, the Y"
    patterns = [
        r"is (?:a |an |the )(.+?)(?:\.|,| who| and| that)",
        r"was (?:a |an |the )(.+?)(?:\.|,| who| and| that)",
        r", (?:the |a |an )(.+?)(?:\.|,| who| and| that)",
    ]

    for pattern in patterns:
        match = re.search(pattern, extract, re.IGNORECASE)
        if match:
            title = match.group(1).strip()
            # Clean up and truncate
            if len(title) > 60:
                title = title[:57] + "..."
            return title

    return ""


# ============================================================
# Main Scraper
# ============================================================

def scrape(quick=False):
    """Main scrape function."""
    print("I'm A Big Deal — Lore Database Scraper")
    print("=" * 50)

    # Phase 1: Gather character names from categories
    # Always scrape lore characters + race character categories
    categories_to_scrape = [
        "Lore_characters",
    ]

    # Race-specific categories capture the major characters
    race_cats = get_subcategories("Characters_by_race")
    print(f"Found {len(race_cats)} race categories")
    categories_to_scrape.extend(race_cats)
    time.sleep(REQUEST_DELAY)

    if not quick:
        # Also get organization-based characters
        org_cats = get_subcategories("Characters_by_organization")
        print(f"Found {len(org_cats)} organization categories")
        categories_to_scrape.extend(org_cats)
        time.sleep(REQUEST_DELAY)

    all_titles = set()
    title_source_cats = {}  # track which categories each title came from
    for cat in categories_to_scrape:
        cat_display = cat.replace("_", " ")
        print(f"Fetching Category:{cat_display}...")
        members = get_category_members(cat, limit=2000 if not quick else 500)
        print(f"  Found {len(members)} pages")
        for m in members:
            all_titles.add(m)
            if m not in title_source_cats:
                title_source_cats[m] = []
            title_source_cats[m].append(cat.replace("_", " "))
        time.sleep(REQUEST_DELAY)

    # Filter out non-character pages (disambiguation, lists, etc.)
    filtered = set()
    skip_prefixes = ["List of", "Category:", "Template:", "File:", "User:"]
    for title in all_titles:
        if any(title.startswith(p) for p in skip_prefixes):
            continue
        if " (disambiguation)" in title:
            continue
        filtered.add(title)

    print(f"\nTotal unique character pages: {len(filtered)}")

    # Phase 2: Fetch extracts and categories in batches
    title_list = sorted(filtered)
    characters = {}
    batch_size = 20

    print(f"\nFetching extracts and categories ({len(title_list)} pages)...")
    for i in range(0, len(title_list), batch_size):
        batch = title_list[i:i + batch_size]
        pct = (i / len(title_list)) * 100
        print(f"  [{pct:.0f}%] Batch {i // batch_size + 1}/{(len(title_list) + batch_size - 1) // batch_size}")

        # Get extracts + categories
        extracts = get_page_extracts(batch)
        time.sleep(REQUEST_DELAY)

        # Get infobox info
        infobox_check = get_page_infobox_check(batch)
        time.sleep(REQUEST_DELAY)

        for title in batch:
            if title not in extracts:
                continue

            info = extracts[title]
            extract = info["extract"]
            categories = info["categories"]
            has_char_infobox = infobox_check.get(title, False)

            # Skip pages with very short or empty extracts
            if len(extract) < 20:
                continue

            # Combine API categories with source scrape categories
            all_cats = categories + title_source_cats.get(title, [])
            tier = classify_tier(title, all_cats, has_char_infobox)
            char_title = extract_title_from_text(extract)

            # Clean extract for use as lore blurb
            blurb = extract.strip()
            # Truncate if too long
            if len(blurb) > 250:
                blurb = blurb[:247] + "..."

            characters[title] = {
                "tier": tier,
                "title": char_title,
                "blurb": blurb,
            }

    print(f"\nProcessed {len(characters)} characters with valid data")

    # Phase 3: Generate Lua output
    return generate_lua(characters)


def generate_lua(characters):
    """Generate the Lua nameOverrides table."""

    tier_counts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0}
    for char in characters.values():
        tier_counts[char["tier"]] = tier_counts.get(char["tier"], 0) + 1

    lines = []
    lines.append("-- AUTO-GENERATED by tools/scraper.py")
    lines.append("-- Do not edit manually — run the scraper to update")
    lines.append(f"-- Generated: {time.strftime('%Y-%m-%d %H:%M:%S')}")
    lines.append(f"-- Total characters: {len(characters)}")
    lines.append(f"-- Legendary: {tier_counts[5]}, Epic: {tier_counts[4]}, "
                 f"Rare: {tier_counts[3]}, Uncommon: {tier_counts[2]}, "
                 f"Common: {tier_counts[1]}")
    lines.append("")
    lines.append('local ADDON_NAME = "ImABigDeal"')
    lines.append("local IABD = _G[ADDON_NAME]")
    lines.append("")
    lines.append("-- Merge generated entries into nameOverrides")
    lines.append("-- (hand-curated entries in data.lua take priority)")
    lines.append("for name, entry in pairs({")

    # Sort by tier (highest first), then alphabetically
    sorted_chars = sorted(characters.items(),
                          key=lambda x: (-x[1]["tier"], x[0]))

    for name, char in sorted_chars:
        # Escape special characters for Lua strings
        def lua_escape(s):
            s = s.replace("\\", "\\\\")
            s = s.replace('"', "'")       # Replace double quotes with single
            s = s.replace("\n", " ")       # No newlines in strings
            s = s.replace("\r", "")
            s = s.replace("\t", " ")
            return s

        lua_name = lua_escape(name.lower())
        lua_title = lua_escape(char["title"])
        lua_blurb = lua_escape(char["blurb"])

        lines.append(f'  ["{lua_name}"] = {{ {char["tier"]}, '
                     f'"{lua_title}", '
                     f'"{lua_blurb}" }},')

    lines.append("}) do")
    lines.append("  if not IABD.nameOverrides[name] then")
    lines.append("    IABD.nameOverrides[name] = entry")
    lines.append("  end")
    lines.append("end")

    return "\n".join(lines)


def main():
    quick = "--quick" in sys.argv

    if "--output" in sys.argv:
        output_path = os.path.join(os.path.dirname(__file__), "..", "data_generated.lua")
        print(os.path.abspath(output_path))
        return

    lua_output = scrape(quick=quick)

    output_path = os.path.join(os.path.dirname(__file__), "..", "data_generated.lua")
    with open(output_path, "w", encoding="utf-8") as f:
        f.write(lua_output)

    print(f"\nOutput written to: {os.path.abspath(output_path)}")
    print("Add 'data_generated.lua' to your .toc file after data.lua to load it.")


if __name__ == "__main__":
    main()
