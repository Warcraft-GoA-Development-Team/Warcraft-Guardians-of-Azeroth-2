"""Source regressions for cover transitions; CK3 playtest remains required."""
import unittest
from pathlib import Path

from test_scarlet_maa import block

ROOT = Path(__file__).resolve().parents[1]


def read(path):
    file = ROOT / path
    return file.read_text(encoding="utf-8-sig") if file.exists() else ""


class CoverCrisisContracts(unittest.TestCase):
    def test_noncriminal_secret_remains_interesting_to_spies(self):
        gate = block(read("common/scripted_triggers/00_councillor_triggers.txt"), "spymaster_task_find_secrets_interesting_secret_type_trigger")
        interest = gate.split("secret_is_always_interesting_trigger", 1)[1]
        self.assertIn("secret_type = secret_dreadlord_disguise", interest)

    def test_threshold_is_private_and_latched_on_body(self):
        inquiry = block(read("common/scripted_effects/wc_balnazzar_effects.txt"), "wc_balnazzar_update_inquiry_effect")
        threshold = inquiry.split("var:wc_balnazzar_suspicion >= 100", 1)[1].split("else_if", 1)[0]
        self.assertNotIn("name = wc_balnazzar_exposure_queued", threshold)
        self.assertIn("wc_balnazzar_begin_cover_crisis_effect", threshold)
        adapter = block(read("common/scripted_effects/wc_balnazzar_effects.txt"), "wc_balnazzar_begin_cover_crisis_effect")
        self.assertIn("wc_nathrezim_begin_cover_crisis_effect", adapter)
        common = read("common/scripted_effects/wc_nathrezim_cover_effects.txt")
        self.assertNotIn("global_var:", common)
        begin = block(common, "wc_nathrezim_begin_cover_crisis_effect")
        self.assertIn("name = wc_nathrezim_cover_crisis", begin)
        self.assertNotIn("expose_secret", begin)
        self.assertNotIn("remove_variable = wc_nathrezim_cover_crisis", common)

    def test_preparation_cannot_be_created_during_crisis(self):
        common = read("common/scripted_triggers/wc_nathrezim_cover_triggers.txt")
        self.assertIn("NOT = { has_variable = wc_nathrezim_cover_crisis }", block(common, "wc_nathrezim_can_prepare_cover_trigger"))
        escape = block(common, "wc_nathrezim_can_escape_cover_trigger")
        for value in ("wc_nathrezim_prepared_body", "wc_nathrezim_valid_prepared_body_trigger = yes", "is_imprisoned = no"):
            self.assertIn(value, escape)
        self.assertIn("is_alive = yes", block(common, "wc_nathrezim_valid_prepared_body_trigger"))
        murder = read("common/on_action/schemes/murder_on_actions.txt")
        self.assertIn("wc_balnazzar_prepare_cover_effect = yes", murder)

    def test_body_transfer_does_not_carry_crisis_or_suspicion(self):
        transfer = block(read("events/story_cycles/wc_story_cycle_balnazzar_events.txt"), "wc_balnazzar_story.0110")
        self.assertIn("name = wc_balnazzar_suspicion value = 0", transfer)
        self.assertNotIn("CHANGE = -25", transfer)
        self.assertNotIn("remove_variable = wc_nathrezim_cover_crisis", transfer)
        self.assertIn("wc_nathrezim_prepared_body", transfer)

    def test_every_cover_exit_preserves_legacy_secret_knowers(self):
        exit_effect = block(read("common/scripted_effects/wc_balnazzar_effects.txt"), "remove_dreadlord_disguise_secret_effect")
        self.assertLess(exit_effect.index("wc_nathrezim_preserve_cover_knowledge_effect"), exit_effect.index("remove_character_flag"))
        preserve = block(read("common/scripted_effects/wc_nathrezim_cover_effects.txt"), "wc_nathrezim_preserve_cover_knowledge_effect")
        self.assertIn("every_secret_knower", preserve)
        self.assertIn("wc_nathrezim_demon_witnesses", preserve)
        self.assertNotIn("remove_from_variable_list", preserve)

    def test_public_nature_is_separate_from_imposture(self):
        secret = read("common/secret_types/wc_balnazzar_secret_types.txt")
        self.assertIn("always = no", block(secret, "is_criminal"))
        self.assertIn("wc_nathrezim_demon_witnesses", block(secret, "on_discover"))
        self.assertNotIn("wc_nathrezim_identity_witnesses", block(secret, "on_discover"))
        common = read("common/scripted_effects/wc_nathrezim_cover_effects.txt")
        self.assertIn("wc_nathrezim_imposture_witnesses", common)
        public = block(common, "wc_nathrezim_end_cover_effect")
        for forbidden in ("death =", "spawn_army", "change_title_holder", "raise_undead"):
            self.assertNotIn(forbidden, public)
        pact = block(read("events/story_cycles/wc_story_cycle_balnazzar_events.txt"), "wc_balnazzar_story.1004")
        self.assertIn("wc_nathrezim_identity_witnesses", block(pact, "immediate"))

    def test_political_choices_have_ai_and_authority_rechecks(self):
        events = read("events/story_cycles/wc_nathrezim_cover_events.txt")
        for event in ("wc_nathrezim_cover.0001", "wc_nathrezim_cover.0002"):
            self.assertIn("ai_chance", block(events, event))
        self.assertIn("wc_nathrezim_cover_authority_trigger = yes", events)
        self.assertIn("wc_nathrezim_can_escape_cover_trigger = yes", events)
        self.assertIn("wc_nathrezim_cover_case_valid_trigger = yes", events)

    def test_risen_exception_is_contextual(self):
        risen = block(read("common/scripted_triggers/wc_balnazzar_triggers.txt"), "wc_balnazzar_risen_context_trigger")
        for value in ("this = character:60021", "wc_balnazzar_scarlet_founded", "wc_balnazzar_stratholme_resolved", "wc_scarlet_controls_stratholme_trigger = yes"):
            self.assertIn(value, risen)
        router = block(read("events/story_cycles/wc_story_cycle_balnazzar_events.txt"), "wc_balnazzar_story.2000")
        self.assertIn("wc_balnazzar_risen_context_trigger = yes", router)
        self.assertIn("wc_nathrezim_end_cover_effect = yes", router)
        self.assertNotIn("spawn_army", router)


if __name__ == "__main__":
    unittest.main()
