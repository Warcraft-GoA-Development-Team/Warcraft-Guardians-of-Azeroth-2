from pathlib import Path


ROOT = Path(__file__).parent
EVENT_ID = "wc_scarlet_stratholme.0001"


def test_retreat_notification_is_gone() -> None:
    event_path = ROOT / "events/wc_events/wc_scarlet_stratholme_events.txt"
    assert not event_path.exists(), event_path
    command_event_path = ROOT / "events/wc_events/wc_scarlet_command_events.txt"
    assert not command_event_path.exists(), command_event_path

    for path in (
        ROOT / "common/scripted_effects/wc_scarlet_stratholme_war_effects.txt",
        ROOT / "localization/english/wc_scarlet_purge_retreat_l_english.yml",
    ):
        assert EVENT_ID not in path.read_text(encoding="utf-8-sig"), path


def test_scarlet_campaign_has_no_alternate_target_or_event() -> None:
    path = ROOT / "common/scripted_effects/wc_scarlet_legacy_effects.txt"
    text = path.read_text(encoding="utf-8-sig")
    assert "c_andorhal" not in text
    assert "set_variable = { name = wc_scarlet_campaign_target value = title:c_stratholme }" in text
    command_effects = (ROOT / "common/scripted_effects/wc_scarlet_command_effects.txt").read_text(encoding="utf-8-sig")
    assert "trigger_event = { id = wc_balnazzar_story.1008 }" not in command_effects


if __name__ == "__main__":
    test_retreat_notification_is_gone()
    test_scarlet_campaign_has_no_alternate_target_or_event()
