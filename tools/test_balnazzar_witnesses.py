"""Source contracts, not CK3 runtime proof. Run with python3."""
import unittest
from pathlib import Path

from test_scarlet_maa import block, tokens

ROOT = Path(__file__).resolve().parents[1]


def read(path):
    return (ROOT / path).read_text(encoding="utf-8-sig")


class WitnessContracts(unittest.TestCase):
    def test_description_priority_and_fallback(self):
        event = block(read("events/story_cycles/wc_story_cycle_balnazzar_events.txt"), "wc_balnazzar_story.0101")
        descriptions = block(block(event, "desc"), "first_valid")
        self.assertEqual(tokens(descriptions), tokens("""
            triggered_desc = {
                trigger = {
                    scope:balnazzar_witness = {
                        OR = {
                            is_spouse_of = root
                            is_close_family_of = root
                            has_relation_friend = root
                            has_relation_best_friend = root
                        }
                    }
                }
                desc = wc_balnazzar_story.0101.desc_close
            }
            triggered_desc = {
                trigger = { scope:balnazzar_witness = { is_councillor_of = root } }
                desc = wc_balnazzar_story.0101.desc_councillor
            }
            desc = wc_balnazzar_story.0101.desc
        """))
        self.assertEqual(tokens(block(event, "immediate")), "wc_balnazzar_open_inquiry_effect=yes")
        opening = block(read("common/scripted_effects/wc_balnazzar_effects.txt"), "wc_balnazzar_open_inquiry_effect")
        self.assertIn("save_scope_as = balnazzar_witness", block(opening, "random_courtier"))

    def test_body_episode_and_single_benefit(self):
        triggers = read("common/scripted_triggers/wc_balnazzar_triggers.txt")
        guard = block(triggers, "wc_balnazzar_associated_witness_trigger") + block(triggers, "wc_balnazzar_pending_witness_trigger")
        for token in ("wc_balnazzar_witness_body", "wc_balnazzar_witness_episode", "wc_balnazzar_witness_resolved", "story_owner =", "wc_balnazzar_disguise_active"):
            self.assertIn(token, guard)
        effects = read("common/scripted_effects/wc_balnazzar_effects.txt")
        result = block(effects, "wc_balnazzar_resolve_witness_effect")
        self.assertLess(result.index("name = wc_balnazzar_witness_resolved"), result.index("wc_balnazzar_change_suspicion_effect"))

    def test_only_actual_murder(self):
        self.assertNotIn("wc_balnazzar_change_suspicion_effect", read("common/on_action/schemes/murder_on_actions.txt"))
        hooks = read("common/on_action/wc_balnazzar_on_actions.txt")
        death = block(hooks, "wc_balnazzar_witness_death")
        for token in ("scope:killer", "has_variable = wc_balnazzar_witness_murder", "wc_balnazzar_resolve_witness_effect"):
            self.assertIn(token, death)
        self.assertNotIn("death_reason =", death)
        for name in ("known_murder_effect", "unknown_murder_effect"):
            murder = block(read("common/scripted_effects/00_murder_effects.txt"), name)
            self.assertLess(murder.index("wc_balnazzar_record_witness_murder_effect"), murder.index("override_death_killer_effect"))
            self.assertIn("limit = { is_alive = yes }", murder)
            self.assertIn("remove_variable = wc_balnazzar_witness_murder", murder)
        self.assertIn("on_actions", block(hooks, "sway_success"))

    def test_native_choices_no_instant_reward(self):
        event = block(read("events/story_cycles/wc_story_cycle_balnazzar_events.txt"), "wc_balnazzar_story.0101")
        self.assertNotIn("imprison =", event)
        self.assertNotIn("CHANGE = -", event)
        for scheme in ("sway", "abduct", "murder"):
            self.assertIn("SCHEME = " + scheme, event)

    def test_native_start_and_mark_ai(self):
        effects = block(read("common/scripted_effects/wc_balnazzar_effects.txt"), "wc_balnazzar_start_witness_scheme_effect")
        self.assertIn("feast_learnt_habits_modifier", effects)
        interaction = block(read("common/character_interactions/wc_religious_interactions.txt"), "request_scarlet_mark_interaction")
        self.assertIn("ai_recipients = courtiers", interaction)
        self.assertIn("wc_balnazzar_pending_witness_trigger = yes", block(interaction, "ai_will_do"))

    def test_final_sentences_and_political_acquittal(self):
        effects = read("common/scripted_effects/wc_scarlet_inquisition_effects.txt")
        opening = block(effects, "wc_inquisition_open_effect")
        for token in ("requested_my_scarlet_mark", "wc_inquisition_accuser", "wc_inquisition_witness_episode"):
            self.assertIn(token, opening)
        self.assertIn("wc_balnazzar_associated_witness_trigger = yes", opening)
        final = block(effects, "wc_inquisition_resolve_effect")
        self.assertLess(final.index("wc_inquisition_consequences_effect"), final.index("execute_prisoner_effect"))
        consequences = block(effects, "wc_inquisition_consequences_effect")
        for token in ("wc_inquisition_known_crime_trigger = no", "opinion = -20", "scope:wc_inquisitor", "wc_inquisition_accuser", "wc_inquisition_witness_episode"):
            self.assertIn(token, consequences)
        for change in (-8, 15):
            self.assertIn(f"CHANGE = {change}", consequences)
        self.assertIn("CHANGE = -18", final)
        self.assertIn("wc_balnazzar_associated_witness_trigger = yes", consequences)
        self.assertIn("wc_balnazzar_change_suspicion_effect = { CHANGE = 15 }", consequences)

    def test_discovery_gate_does_not_forget_secrets(self):
        gate = block(read("common/scripted_triggers/00_councillor_triggers.txt"), "spymaster_task_find_secrets_interesting_secret_type_trigger")
        for token in ("secret_type = secret_dreadlord_disguise", "var:wc_balnazzar_suspicion >= 60", "story_owner = scope:suitable_secret.secret_owner"):
            self.assertIn(token, gate)
        secret = read("common/secret_types/wc_balnazzar_secret_types.txt")
        self.assertNotIn("suspicion", block(secret, "is_valid"))
        self.assertIn("name = wc_balnazzar_exposure_queued", block(secret, "on_expose"))
        self.assertNotIn("remove_secret", gate)

    def test_concurrent_results_and_stale_associations(self):
        triggers = read("common/scripted_triggers/wc_balnazzar_triggers.txt")
        choice = block(triggers, "wc_balnazzar_inquiry_choice_valid_trigger")
        self.assertIn("var:wc_balnazzar_witness_episode = scope:wc_witness_episode", choice)
        self.assertIn("var:wc_balnazzar_witness_body = root", choice)
        pending = block(triggers, "wc_balnazzar_pending_witness_trigger")
        self.assertIn("NOT = { has_variable = wc_balnazzar_witness_resolved }", pending)
        self.assertIn("wc_balnazzar_associated_witness_trigger = yes", pending)
        active = block(triggers, "wc_balnazzar_associated_witness_trigger")
        self.assertIn("story_owner = prev.var:wc_balnazzar_witness_body", active)
        case = block(read("common/scripted_effects/wc_scarlet_inquisition_effects.txt"), "wc_inquisition_consequences_effect")
        for guard in ("wc_inquisition_case_valid_trigger = yes", "var:wc_inquisition_accuser = var:wc_balnazzar_witness_body", "var:wc_inquisition_witness_episode = var:wc_balnazzar_witness_episode"):
            self.assertIn(guard, case)
        # Every reduction takes the shared one-shot path; execution waits for death.
        self.assertIn("wc_balnazzar_resolve_witness_effect = { CHANGE = -8 }", case)
        final = block(read("common/scripted_effects/wc_scarlet_inquisition_effects.txt"), "wc_inquisition_resolve_effect")
        self.assertIn("wc_balnazzar_resolve_witness_effect = { CHANGE = -18 }", final)
        self.assertNotIn("wc_balnazzar_change_suspicion_effect = { CHANGE = -", case)


if __name__ == "__main__":
    unittest.main()
