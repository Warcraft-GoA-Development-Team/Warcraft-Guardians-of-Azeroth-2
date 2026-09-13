"""Source contracts for suspicion/HUD; does not substitute for a CK3 playtest."""
import unittest
from pathlib import Path

from test_scarlet_maa import block

ROOT = Path(__file__).resolve().parents[1]


def read(path):
    p = ROOT / path
    return p.read_text(encoding="utf-8-sig") if p.exists() else ""


class SuspicionHudContracts(unittest.TestCase):
    def test_migration_before_any_delta_and_once(self):
        effects = read("common/scripted_effects/wc_balnazzar_effects.txt")
        change = block(effects, "wc_balnazzar_change_suspicion_effect")
        self.assertLess(change.index("wc_balnazzar_migrate_suspicion_effect"), change.index("add = $CHANGE$"))
        migration = block(effects, "wc_balnazzar_migrate_suspicion_effect")
        self.assertIn("NOT = { has_variable = wc_balnazzar_suspicion_v2 }", migration)
        self.assertIn("multiply = 10", migration)
        self.assertIn("var:wc_balnazzar_suspicion >= 9", migration)
        self.assertIn("value = 100", migration)
        self.assertNotIn("remove_variable = wc_balnazzar_exposure_queued", effects)
        self.assertIn("min = 0 max = 100", change)

    def test_pressure_requires_a_free_unresolved_witness_and_full_year(self):
        pressure = block(read("common/scripted_effects/wc_balnazzar_effects.txt"), "wc_balnazzar_witness_pressure_effect")
        for token in ("wc_balnazzar_free_witness_count > 0", "wc_balnazzar_free_witness_count >= 2", "years = 1", "CHANGE = 4", "CHANGE = 8"):
            self.assertIn(token, pressure)
        self.assertIn("wc_balnazzar_pressure_waiting", pressure)

    def test_rumors_inquiry_crisis_exposure(self):
        effects = read("common/scripted_effects/wc_balnazzar_effects.txt")
        for value in (30, 60, 85, 100):
            self.assertIn(f"var:wc_balnazzar_suspicion >= {value}", effects)
        event = block(read("events/story_cycles/wc_story_cycle_balnazzar_events.txt"), "wc_balnazzar_story.0101")
        self.assertIn("var:wc_balnazzar_suspicion >= 30", event)
        self.assertIn("var:wc_balnazzar_suspicion < 100", event)
        discovery = block(read("common/scripted_triggers/00_councillor_triggers.txt"), "spymaster_task_find_secrets_interesting_secret_type_trigger")
        self.assertIn("var:wc_balnazzar_suspicion >= 60", discovery)

    def test_crisis_revalidates_costs_body_and_has_ai_choices(self):
        event = block(read("events/story_cycles/wc_story_cycle_balnazzar_events.txt"), "wc_balnazzar_story.0103")
        self.assertEqual(event.count("ai_chance ="), 3)
        self.assertIn("piety >= major_piety_value", event)
        self.assertIn("add_piety = major_piety_loss", event)
        self.assertIn("add_tyranny = 10", event)
        self.assertIn("wc_balnazzar_crisis_choice_trigger = yes", event)
        self.assertIn("wc_balnazzar_crisis_seen", event)

    def test_hud_reads_story_with_owner_gate_and_no_extra_bottom_item(self):
        gui = read("gui/shared/wc_balnazzar_suspicion.gui")
        self.assertIn("GetProgressBarValueMaxScaled", gui)
        self.assertIn("GetProgressBarValueMaxOtherScaled", gui)
        self.assertIn("wc_balnazzar_suspicion_fraction", gui)
        self.assertIn("GetScriptedGui('wc_balnazzar_suspicion_gui').IsShown", gui)
        guard = read("common/scripted_guis/wc_balnazzar_suspicion_gui.txt")
        self.assertIn("story_owner = root", guard)
        self.assertIn("balnazzar_shed_the_mask", guard)
        hud = read("gui/hud.gui")
        start = hud.rfind("widget = {", 0, hud.index('name = "stress_widget"'))
        stress = block(hud[start:], "widget")
        self.assertIn("wc_balnazzar_suspicion_meter", stress)
        # No stress tooltip on the shared ancestor of the suspicion meter.
        parent = stress.split('widget = {', 1)[0]
        self.assertNotIn('tooltip = "PLAYER_STRESS_TOOLTIP"', parent)
        self.assertIn('alwaystransparent = yes', parent)
        self.assertIn('filter_mouse = none', parent)
        self.assertEqual(stress.count('tooltip = "PLAYER_STRESS_TOOLTIP"'), 1)
        self.assertLess(stress.index('tooltip = "PLAYER_STRESS_TOOLTIP"'),
                        stress.index('wc_balnazzar_suspicion_meter = {}'))
        hit_start = stress.rfind('widget = {', 0, stress.index('name = "stress_hover"'))
        hit = block(stress[hit_start:], 'widget')
        self.assertIn('size = { 110 55 }', hit)
        self.assertIn('tooltip = "PLAYER_STRESS_TOOLTIP"', hit)
        values = read("common/script_values/wc_balnazzar_suspicion_values.txt")
        self.assertIn("global_var:balnazzar_dreadlord_story", values)
        self.assertIn("divide = 100", values)

    def test_native_frame_static_purple_and_tooltip_only_value(self):
        gui = read("gui/shared/wc_balnazzar_suspicion.gui")
        for token in ("size = { 180 108 }", "parentanchor = center",
                      "position = { 0 -48 }", "size = { 60 20 }",
                      "position = { -13 0 }", "size = { 35 35 }",
                      "position = { 41 0 }", "hud_stress_bg.dds",
                      "wc_balnazzar_suspicion.dds", "color = { 0.42 0.16 0.58 0.9 }",
                      "mask_scratches.dds", "mask_rough_edges.dds",
                      "mask_circle.dds", "mask_fade_horizontal.dds", "mask_fade_vertical.dds"):
            self.assertIn(token, gui)
        for token in ("text_single", "GetStress",
                      "progressbar_hud_stress"):
            self.assertNotIn(token, gui)
        self.assertEqual(gui.count('tooltip = "WC_BALNAZZAR_SUSPICION_HUD_TOOLTIP"'), 2)
        # The native frame includes an opaque medallion: the glyph goes above it.
        self.assertLess(gui.index("hud_stress_bg.dds"), gui.index("wc_balnazzar_suspicion.dds"))
        loc = read("localization/english/wc_balnazzar_suspicion_l_english.yml")
        self.assertIn("#T $WC_BALNAZZAR_SUSPICION_HUD_LABEL$#!", loc)
        self.assertIn("wc_balnazzar_suspicion_value')|0]/100", loc)
        # Source arithmetic only: CK3 must still confirm actual pixel widths.
        self.assertEqual(gui.count("'(float)1', '(int32)60'"), 2)
        for value, width in ((0, 0), (30, 18), (60, 36), (85, 51), (100, 60)):
            with self.subTest(value=value):
                self.assertAlmostEqual(value / 100 * 60, width)

    def test_witness_balance_and_warning(self):
        values = read('common/script_values/wc_balnazzar_suspicion_values.txt')
        count = block(values, 'wc_balnazzar_free_witness_count')
        for token in ('every_courtier', 'is_alive = yes', 'is_imprisoned = no',
                      'wc_balnazzar_pending_witness_trigger = yes', 'add = 1', 'max = 2'):
            self.assertIn(token, count)
        decision = block(read('common/decisions/wc_balnazzar_decisions.txt'),
                         'wc_balnazzar_maintain_mask_decision')
        for token in ('wc_balnazzar_free_witness_count > 0', 'CHANGE = -2', 'CHANGE = -10'):
            self.assertIn(token, decision)
        gui = read('gui/shared/wc_balnazzar_suspicion.gui')
        self.assertIn("GreaterThanOrEqualTo_CFixedPoint(GetPlayer.MakeScope.ScriptValue('wc_balnazzar_suspicion_value'), '(CFixedPoint)80')", gui)
        self.assertIn('name = suspicion_pulse_bright', gui)
        loc = read('localization/english/wc_balnazzar_suspicion_l_english.yml')
        self.assertIn("GetPlayer.Custom('WcBalnazzarWitnessPressure')", loc)


if __name__ == "__main__":
    unittest.main()
