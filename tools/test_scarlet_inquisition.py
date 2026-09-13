"""Source regressions for the Inquisition. Does not execute the CK3 engine."""
import unittest
from pathlib import Path

from test_scarlet_maa import block

ROOT = Path(__file__).resolve().parents[1]


def read(path):
    file = ROOT / path
    return file.read_text(encoding="utf-8-sig") if file.exists() else ""


class InquisitionContracts(unittest.TestCase):
    def setUp(self):
        self.effects = read("common/scripted_effects/wc_scarlet_inquisition_effects.txt")
        self.triggers = read("common/scripted_triggers/wc_scarlet_inquisition_triggers.txt")
        self.events = read("events/religion_events/wc_scarlet_inquisition_events.txt")
        self.interaction = block(read("common/character_interactions/wc_religious_interactions.txt"), "send_to_inquisition_interaction")

    def test_unique_case_and_generation(self):
        start = block(self.effects, "wc_inquisition_open_effect")
        self.assertIn("wc_inquisition_hearing_eligible_trigger = yes", block(start, "limit"))
        eligibility = block(self.triggers, "wc_inquisition_hearing_eligible_trigger")
        self.assertIn("NOT = { has_variable = wc_inquisition_stage }", eligibility)
        self.assertIn("is_imprisoned_by = scope:inquisitor", block(start, "limit"))
        self.assertIn("change_variable = { name = wc_inquisition_generation add = 1 }", start)
        match = block(self.triggers, "wc_inquisition_case_matches_trigger")
        self.assertIn("var:wc_inquisition_generation = scope:wc_case_generation", match)
        self.assertIn("has_variable = wc_inquisition_stage", match)

    def test_reward_only_after_success_and_unlocked(self):
        accept = block(self.interaction, "on_accept")
        # The payment must be in the success branch, behind the prisoner lock.
        success = accept[accept.index("limit = { scope:recipient = { is_imprisoned_by = scope:inquisitor } }"):]
        reward = block(success, "if")
        self.assertIn("wc_inquisition_transfer_unlocked_trigger = yes", block(reward, "limit"))
        self.assertIn("add_piety = 150", reward)
        self.assertIn("pay_treasury_or_gold", reward)
        self.assertNotIn("add_piety = 150", self.effects + self.events)
        close = block(self.effects, "wc_inquisition_close_effect")
        self.assertIn("flag = wc_inquisition_cooldown years = 1", close)

    def test_unpaid_transfer_still_gets_a_hearing(self):
        accept = block(self.interaction, "on_accept")
        success = accept[accept.index("limit = { scope:recipient = { is_imprisoned_by = scope:inquisitor } }"):]
        reward = block(success, "if")
        self.assertNotIn("wc_inquisition_open_effect", reward)
        self.assertIn("wc_inquisition_open_effect = yes", success.replace(reward, ""))
        start = block(self.effects, "wc_inquisition_open_effect")
        self.assertNotIn("wc_inquisition_transfer_unlocked_trigger", start)

    def test_three_sentences_and_native_execution(self):
        resolve = block(self.effects, "wc_inquisition_resolve_effect")
        self.assertIn("wc_inquisition_case_valid_trigger = yes", block(resolve, "limit"))
        self.assertIn("execute_prisoner_effect", resolve)
        self.assertIn("release_from_prison = yes", resolve)
        self.assertIn("remove_trait = scarlet_mark", resolve)
        self.assertIn("var:wc_inquisition_sentence = flag:penance", resolve)
        self.assertIn("modifier = scarlet_mark_recently_lifted_modifier", resolve)
        self.assertNotIn("add_secret", self.effects + self.events)
        for sentence in ("acquittal", "penance", "execution"):
            self.assertIn(f"SENTENCE = {sentence}", self.effects)

    def test_verdict_and_appeal_use_shared_weighted_rolls(self):
        for event_id, effect, weights in (
            ("2", "wc_inquisition_roll_sentence_effect", (30, 50, 15)),
            ("4", "wc_inquisition_roll_appeal_effect", (40, 25)),
        ):
            event = block(self.events, f"wc_scarlet_inquisition.{event_id}")
            self.assertIn(f"{effect} = yes", event)
            self.assertEqual(event.count("ai_chance"), 1)
            roll = block(block(self.effects, effect), "random_list")
            for weight in weights:
                outcome = block(roll, str(weight))
                self.assertIn("desc = wc_scarlet_inquisition.", outcome)
                self.assertIn("hidden_effect", outcome)
            self.assertIn("wc_inquisition_known_crime_trigger", roll)
        preview = block(self.interaction, "show_as_tooltip")
        self.assertIn("save_scope_as = wc_accused", preview)
        self.assertIn("wc_inquisition_roll_sentence_effect = yes", preview)
        command = block(self.events, "wc_scarlet_inquisition.3")
        self.assertIn("wc_inquisition_roll_appeal_effect = yes", block(command, "show_as_tooltip"))

    def test_judgment_labels_each_sentence(self):
        loc = read("localization/english/event_localization/wc_scarlet_inquisition_l_english.yml")
        for sentence in ("execution", "penance", "acquittal"):
            line = next(line for line in loc.splitlines() if f"wc_scarlet_inquisition.3.{sentence}:" in line)
            self.assertIn("#bold Sentence:", line)

    def test_execution_only_silences_a_witness_after_actual_death(self):
        resolve = block(self.effects, "wc_inquisition_resolve_effect")
        consequences = block(self.effects, "wc_inquisition_consequences_effect")
        self.assertNotIn("CHANGE = -18", consequences)
        self.assertLess(resolve.index("execute_prisoner_effect"), resolve.index("CHANGE = -18"))
        aftermath = resolve.split("execute_prisoner_effect", 1)[1]
        guard = block(block(aftermath, "if"), "limit")
        self.assertIn("is_alive = no", guard)
        self.assertIn("scope:wc_inquisition_execution_witness = yes", guard)
        self.assertIn("name = wc_inquisition_execution_witness value = no", resolve)

    def test_intervention_and_conditional_hook(self):
        command = block(self.events, "wc_scarlet_inquisition.3")
        for option in ("accept", "plead", "hook", "denounce"):
            self.assertIn(f"name = wc_scarlet_inquisition.{option}", command)
        hook = block(self.effects, "wc_inquisition_hook_effect")
        guard = block(hook, "limit")
        for requirement in ("wc_inquisition_command_valid_trigger = yes", "has_usable_hook = scope:wc_inquisitor", "flag:execution"):
            self.assertIn(requirement, guard)
        self.assertEqual((self.effects + self.events).count("use_hook = scope:wc_inquisitor"), 1)
        self.assertIn("value = flag:penance", hook)

    def test_stale_case_and_release_cleanup(self):
        valid = block(self.triggers, "wc_inquisition_case_valid_trigger")
        for requirement in ("wc_inquisition_case_matches_trigger = yes", "is_alive = yes", "is_imprisoned_by = scope:wc_inquisitor", "faith:scarletism", "faith.religious_head = scope:wc_inquisitor"):
            self.assertIn(requirement, valid)
        hooks = read("common/on_action/wc_scarlet_inquisition_on_actions.txt")
        for name in ("on_release_from_prison", "on_death"):
            self.assertIn("on_actions", block(hooks, name))
        self.assertIn("wc_scarlet_inquisition.9", self.events)
        self.assertNotIn("is_ai = no", self.events)


if __name__ == "__main__":
    unittest.main()
