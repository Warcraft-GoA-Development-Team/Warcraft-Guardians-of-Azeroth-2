"""Static recruitment/profile regression check; run from any directory."""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
MAA = ROOT / "common/men_at_arms_types"
BASES = (
    "armored_footmen", "light_footmen", "pikemen_unit", "bowmen",
    "crossbowmen", "light_horsemen", "armored_horsemen", "aerial_unit",
)
GATE = "wc_scarlet_maa_member_trigger"


def block(text, key):
    match = re.search(r"(?m)^\s*" + re.escape(key) + r"\s*=\s*\{", text)
    assert match, f"Missing {key}"
    start = match.end()
    depth = 1
    for pos in range(start, len(text)):
        depth += (text[pos] == "{") - (text[pos] == "}")
        if depth == 0:
            return text[start:pos]
    raise AssertionError(f"Unclosed {key}")


def tokens(text):
    return re.sub(r"\s+", "", re.sub(r"#.*", "", text))


def main():
    variants = (MAA / "wc_scarlet_maa_types.txt").read_text(encoding="utf-8-sig")
    loc = (ROOT / "localization/english/wc_scarlet_maa_l_english.yml").read_bytes()
    assert loc.startswith(b"\xef\xbb\xbfl_english:\n")
    for base in BASES:
        filename = "wc_maa_types.txt" if base == "aerial_unit" else "00_maa_types.txt"
        original = block((MAA / filename).read_text(encoding="utf-8-sig"), base)
        variant = block(variants, "wc_scarlet_" + base)
        for field in ("can_recruit", "should_show_when_unavailable", "access_through_subject"):
            assert GATE + "=no" in tokens(block(original, field)), (base, field)
        assert GATE + "=yes" in tokens(block(variant, "can_recruit"))
        assert GATE + "=yes" in tokens(block(variant, "should_show_when_unavailable"))
        assert tokens(block(variant, "access_through_subject")) == "always=no"
        # Membership is the sole change to direct recruitment prerequisites.
        if base == "aerial_unit":
            original = block((MAA / "wc_regional_maa_types.txt").read_text(encoding="utf-8-sig"), "gryphon_rider")
            for field in ("can_recruit", "should_show_when_unavailable", "access_through_subject"):
                assert GATE + "=no" in tokens(block(original, field)), field
            assert tokens(block(variant, "can_recruit")) == GATE + "=yesOR={wc_valid_for_maa_trigger={INNOVATION=taming_the_skies}wc_valid_for_maa_trigger={INNOVATION=gryphon}}"
            assert tokens(block(original, "terrain_bonus")) == tokens(block(variant, "terrain_bonus"))
        else:
            assert tokens(block(original, "can_recruit")).replace(GATE + "=no", "") == tokens(block(variant, "can_recruit")).replace(GATE + "=yes", "")
        for field in ("buy_cost", "low_maintenance_cost", "high_maintenance_cost", "counters", "ai_quality"):
            assert tokens(block(original, field)) == tokens(block(variant, field)), (base, field)
        for field in ("type", "damage", "toughness", "pursuit", "screen", "stack", "provision_cost"):
            pattern = r"(?m)^\s*" + field + r"\s*=\s*(\S+)"
            assert re.findall(pattern, original) == re.findall(pattern, variant), (base, field)
        for suffix in ("", "_flavor"):
            assert f" wc_scarlet_{base}{suffix}:" in loc.decode("utf-8-sig")
    paladins = block(variants, "wc_scarlet_paladins")
    aerial = block(variants, "wc_scarlet_aerial_unit")
    assert tokens(block(aerial, "should_show_when_unavailable")) == GATE + "=yes"
    assert 'wc_scarlet_aerial_unit:0 "Scarlet Gryphon Riders"' in loc.decode("utf-8-sig")
    for value in ("damage=60", "toughness=45", "max_regiments=1", "stack=100"):
        assert value in tokens(paladins)
    assert "special_recruit_only=yes" not in tokens(paladins)
    costs = (ROOT / "common/script_values/00_men_at_arms_values.txt").read_text(encoding="utf-8-sig")
    def constant(name):
        return float(re.search(r"(?m)^@" + name + r"\s*=\s*([\d.]+)\s*$", costs)[1])
    guard_buy = constant("heavy_infantry_recruitment_cost")
    guard_low = constant("heavy_infantry_low_maint_cost")
    for field, base_cost in (("buy_cost", guard_buy), ("low_maintenance_cost", guard_low), ("high_maintenance_cost", guard_low * constant("high_maint_mult"))):
        # MaA costs must be scalar: the engine displayed inline calculation blocks as free.
        gold = re.fullmatch(r"gold=([\d.]+)", tokens(block(paladins, field)))
        assert gold, (field, "expected a numeric gold cost")
        assert abs(float(gold[1]) - 2 * base_cost) < 1e-9, field
    assert tokens(block(paladins, "counters")) == "pikemen=1peasant_militia=2heavy_infantry=1"
    guards = block(variants, "wc_scarlet_armored_footmen")
    terrains = {
        "Guards": (guards, {"forest": (0, 4), "hills": (0, 4), "wetlands": (-4, -2), "jungle": (-4, -2)}),
        "Paladins": (paladins, {"plains": (6, 0), "hills": (0, 6), "wetlands": (-10, -5), "jungle": (-10, -5)}),
    }
    for name, (profile, bonuses) in terrains.items():
        terrain = block(profile, "terrain_bonus")
        for key, (damage, toughness) in bonuses.items():
            assert tokens(block(terrain, key)) == f"damage={damage}toughness={toughness}", (name, key)
    assert tokens(block(paladins, "can_recruit")) == tokens(block(block(variants, "wc_scarlet_armored_footmen"), "can_recruit"))
    trigger = (ROOT / "common/scripted_triggers/wc_scarlet_maa_triggers.txt").read_text(encoding="utf-8-sig")
    assert "exists = global_var:wc_scarlet_crusade_title.holder" in trigger
    assert "this = global_var:wc_scarlet_crusade_title.holder" in trigger
    assert "is_vassal_or_below_of = global_var:wc_scarlet_crusade_title.holder" in trigger
    assert "faith" not in tokens(trigger)
    for key in (*BASES, "paladins"):
        unit = "wc_scarlet_" + key
        profile = block(variants, unit)
        assert not re.search(r"(?m)^\s*illustration\s*=", profile), unit
        assert re.search(r"(?m)^\s*icon\s*=\s*" + unit + r"\s*$", profile), unit
        assert (ROOT / f"gfx/interface/icons/regimenttypes/{unit}.dds").is_file(), unit
        for size in ("big", "small"):
            texture = ROOT / f"gfx/interface/illustrations/men_at_arms_{size}/{unit}.dds"
            assert texture.is_file(), texture
    for path in ("common/decisions/wc_scarlet_and_argent_decisions.txt", "events/wc_events/wc_scarlet_events.txt"):
        text = (ROOT / path).read_text(encoding="utf-8-sig")
        armies = [block(text[m.start():], "spawn_army") for m in re.finditer(r"\bspawn_army = \{", text)]
        for army in armies:
            if "type = wc_scarlet_" in army:
                assert sum(tokens(other) == tokens(army.replace("wc_scarlet_", "")) for other in armies) == 1
            if "name = argent_" in army:
                assert "type = wc_scarlet_" not in army
    print("Scarlet MaA: profiles, gates, subject access, paladin limit and English keys OK")


if __name__ == "__main__":
    main()
