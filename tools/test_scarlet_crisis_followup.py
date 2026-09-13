"""Source contracts only; these checks do not simulate CK3."""
import unittest
from pathlib import Path
from test_scarlet_maa import block

ROOT = Path(__file__).resolve().parents[1]

def read(path):
    p = ROOT / path
    return p.read_text(encoding="utf-8-sig") if p.exists() else ""

class ScarletFollowup(unittest.TestCase):
    def test_abandoned_purge_releases_only_its_own_detention(self):
        events = read("events/religion_events/wc_scarlet_purge_events.txt")
        submit = events[events.index("name = wc_scarlet_purge.submit"):]
        custody = block(block(submit, "if"), "if")
        self.assertIn("is_imprisoned = no", block(custody, "limit"))
        marker = "set_variable = { name = wc_inquisition_purge_detention value = scope:wc_purge_authority }"
        self.assertIn(marker, custody)
        self.assertLess(custody.index(marker), custody.index("imprison ="))
        effects = read("common/scripted_effects/wc_scarlet_inquisition_effects.txt")
        discard = block(effects, "wc_inquisition_discard_effect")
        self.assertIn("wc_inquisition_case_matches_trigger = yes", block(discard, "limit"))
        release = block(block(discard, "scope:wc_accused"), "if")
        for guard in ("is_alive = yes", "var:wc_inquisition_purge_detention ?= scope:wc_inquisitor",
                      "var:wc_inquisition_purge_case ?= scope:wc_inquisitor",
                      "is_imprisoned_by = scope:wc_inquisitor"):
            self.assertIn(guard, block(release, "limit"))
        self.assertLess(release.index("wc_inquisition_close_effect = yes"),
                        release.index("release_from_prison = yes"))
        close = block(effects, "wc_inquisition_close_effect")
        self.assertIn("remove_variable = wc_inquisition_purge_detention", close)
        self.assertNotIn("release_from_prison", close)

    def test_accused_commander_cannot_arbitrate_own_sentence(self):
        effects = read("common/scripted_effects/wc_scarlet_inquisition_effects.txt")
        propose = block(effects, "wc_inquisition_propose_effect")
        assign = block(block(propose, "scope:wc_accused"), "if")
        self.assertIn("NOT = { this = scope:wc_court_title.holder }", block(assign, "limit"))
        self.assertIn("name = wc_inquisition_commander", assign)
        self.assertIn("scope:wc_commander = scope:wc_accused", propose)
        triggers = read("common/scripted_triggers/wc_scarlet_inquisition_triggers.txt")
        command = block(triggers, "wc_inquisition_command_valid_trigger")
        self.assertIn("NOT = { this = scope:wc_accused }", command)
        # Old queued self-arbitration cases must expire via the existing watchdog.
        case = block(triggers, "wc_inquisition_case_valid_trigger")
        self.assertIn("NOT = { this = var:wc_inquisition_commander }", block(case, "trigger_if"))

    def test_purge_requires_the_same_available_court_as_a_hearing(self):
        triggers = read("common/scripted_triggers/wc_scarlet_inquisition_triggers.txt")
        court = block(triggers, "wc_inquisition_court_available_trigger")
        for token in ("exists = global_var:wc_scarlet_crusade_title", "exists = holder",
                      "is_alive = yes", "is_adult = yes", "has_faith = faith:scarletism"):
            self.assertIn(token, court)
        for key in ("wc_inquisition_hearing_eligible_trigger", "wc_inquisition_case_valid_trigger"):
            self.assertIn("wc_inquisition_court_available_trigger = yes", block(triggers, key))
        purge = read("common/scripted_triggers/wc_scarlet_purge_triggers.txt")
        self.assertIn("wc_inquisition_court_available_trigger = yes",
                      block(purge, "wc_scarlet_purge_authority_trigger"))
        # A queued summons checks authority again before imprisonment.
        events = read("events/religion_events/wc_scarlet_purge_events.txt")
        submit = events[events.index("name = wc_scarlet_purge.submit"):]
        self.assertLess(submit.index("wc_scarlet_purge_summons_valid_trigger = yes"),
                        submit.index("imprison ="))

    def test_cover_arrest_replaces_inherited_native_scopes(self):
        effect = block(read("common/scripted_effects/wc_nathrezim_cover_effects.txt"),
                       "wc_nathrezim_resist_cover_case_effect")
        arrest = block(block(effect, "random_list"), "60")
        for scope, native in (("wc_cover_witness", "actor"), ("wc_cover_body", "recipient")):
            assignment = f"scope:{scope} = {{ save_scope_as = {native} }}"
            self.assertIn(assignment, arrest)
            self.assertLess(arrest.index(assignment), arrest.index("imprison_character_effect"))

    def test_existing_unresolved_crisis_repairs_missing_penalty_only(self):
        effect = block(read("common/scripted_effects/wc_nathrezim_cover_effects.txt"),
                       "wc_nathrezim_begin_cover_crisis_effect")
        latch = block(effect, "if")
        self.assertNotIn("add_character_modifier", latch)
        repair = block(effect[effect.index(latch) + len(latch):], "if")
        limit = block(repair, "limit")
        for token in ("wc_nathrezim_cover_active_trigger = yes", "has_variable = wc_nathrezim_cover_crisis",
                      "NOT = { has_variable = wc_nathrezim_cover_resolved }",
                      "NOT = { has_character_modifier = wc_nathrezim_contested_identity_modifier }"):
            self.assertIn(token, limit)
        self.assertIn("add_character_modifier = { modifier = wc_nathrezim_contested_identity_modifier }", repair)

    def test_player_purge_disables_native_ai_polling(self):
        decision = block(read("common/decisions/wc_scarlet_purge_decisions.txt"),
                         "wc_scarlet_internal_purge_decision")
        self.assertIn("ai_check_interval = 0", decision)
        self.assertIn("ai_potential = { always = no }", decision)

    def test_public_dathrohan_keeps_story_and_pulse_can_raise_risen(self):
        events = read("events/story_cycles/wc_story_cycle_balnazzar_events.txt")
        router = block(events, "wc_balnazzar_story.2000")
        self.assertIn("NOT = { this = character:60021 }", router)
        risen = block(events, "wc_balnazzar_story.2002")
        self.assertIn("\n\ttrigger = {\n\t\twc_balnazzar_can_raise_risen_trigger = yes", risen)
        self.assertIn("wc_balnazzar_risen_started", block(risen, "immediate"))
        story = read("common/story_cycles/wc_story_cycle_balnazzar.txt")
        self.assertIn("id = wc_balnazzar_story.2002", story)
        gates = read("common/scripted_triggers/wc_balnazzar_triggers.txt")
        gate = block(gates, "wc_balnazzar_can_raise_risen_trigger")
        for token in ("wc_balnazzar_risen_context_trigger = yes", "wc_nathrezim_public_nature", "wc_balnazzar_risen_started", "in_twisting_nether", "is_imprisoned = no"):
            self.assertIn(token, gate)
        immediate = block(risen, "immediate")
        self.assertLess(immediate.index("name = wc_risen_already_revealed"),
                        immediate.index("name = wc_nathrezim_public_nature"))
        self.assertIn("remove_character_flag = wc_balnazzar_risen_started", risen)

    def test_crisis_has_costs_and_native_political_opposition(self):
        effects = read("common/scripted_effects/wc_nathrezim_cover_effects.txt")
        self.assertIn("wc_nathrezim_contested_identity_modifier", block(effects, "wc_nathrezim_begin_cover_crisis_effect"))
        opposition = block(effects, "wc_nathrezim_organize_opposition_effect")
        self.assertIn("can_create_faction", opposition)
        self.assertIn("create_faction", opposition)
        self.assertIn("liberty_faction", opposition)
        events = read("events/story_cycles/wc_nathrezim_cover_events.txt")
        self.assertIn("pay_treasury_or_gold", block(events, "wc_nathrezim_cover.0003"))
        self.assertIn("imprison_character_effect", block(effects, "wc_nathrezim_resist_cover_case_effect"))

    def test_purge_covers_local_subjects_and_never_uses_global_scan(self):
        effects = read("common/scripted_effects/wc_scarlet_purge_effects.txt")
        for token in ("every_courtier", "every_vassal", "wc_scarlet_purge_target_trigger"):
            self.assertIn(token, effects)
        self.assertNotIn("every_living_character", effects)
        triggers = read("common/scripted_triggers/wc_scarlet_purge_triggers.txt")
        target = block(triggers, "wc_scarlet_purge_target_trigger")
        self.assertIn("has_trait = being_undead", target)
        self.assertIn("wc_scarlet_purge_cooldown", target)
        self.assertNotIn("has_faith", target)
        self.assertNotIn("is_theocratic_lessee", target)
        events = read("events/religion_events/wc_scarlet_purge_events.txt")
        for choice in ("submit", "resist", "flee"):
            self.assertIn("wc_scarlet_purge." + choice, events)
        self.assertNotIn("death =", events)

    def test_purge_reuses_trial_with_impartial_judge_and_cleanup(self):
        effects = read("common/scripted_effects/wc_scarlet_purge_effects.txt")
        self.assertIn("wc_inquisition_open_effect = yes", effects)
        triggers = read("common/scripted_triggers/wc_scarlet_inquisition_triggers.txt")
        self.assertIn("wc_inquisition_purge_case", block(triggers, "wc_inquisition_case_valid_trigger"))
        self.assertIn("wc_inquisition_purge_case", block(triggers, "wc_inquisition_hearing_eligible_trigger"))
        effects = read("common/scripted_effects/wc_scarlet_inquisition_effects.txt")
        self.assertIn("remove_variable = wc_inquisition_purge_case", block(effects, "wc_inquisition_close_effect"))
        pulse = read("common/on_action/wc_scarlet_purge_on_actions.txt")
        self.assertIn("on_actions", block(pulse, "quarterly_playable_pulse"))

    def test_summons_rechecks_generation_jurisdiction_and_capture(self):
        triggers = read("common/scripted_triggers/wc_scarlet_purge_triggers.txt")
        valid = block(triggers, "wc_scarlet_purge_summons_valid_trigger")
        for token in ("wc_scarlet_purge_authority_trigger = yes", "has_trait = being_undead",
                      "var:wc_scarlet_purge_generation = scope:wc_purge_generation",
                      "liege ?= scope:wc_purge_authority", "is_courtier_of = scope:wc_purge_authority",
                      "NOT = { has_variable = wc_inquisition_stage }"):
            self.assertIn(token, valid)
        authority = block(triggers, "wc_scarlet_purge_authority_trigger")
        self.assertIn("NOT = { has_trait = being_undead }", authority)
        pulse = read("common/on_action/wc_scarlet_purge_on_actions.txt")
        self.assertIn("on_actions", block(pulse, "on_imprison"))
        captured = block(pulse, "wc_scarlet_purge_captured")
        self.assertIn("var:wc_scarlet_purge_summons ?= scope:imprisoner", captured)
        self.assertIn("wc_scarlet_purge_open_trial_effect = yes", captured)

if __name__ == "__main__":
    unittest.main()
