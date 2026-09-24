from pathlib import Path


ROOT = Path(__file__).parent


def test_balnazzar_branch_has_no_scarlet_unit_content() -> None:
    assert not (ROOT / "common/men_at_arms_types/wc_scarlet_maa_types.txt").exists()
    assert not (ROOT / "common/scripted_triggers/wc_scarlet_maa_triggers.txt").exists()
    assert not (ROOT / "localization/english/wc_scarlet_maa_l_english.yml").exists()
    assert not list((ROOT / "gfx/interface").rglob("wc_scarlet_*.dds"))
    for path in (
        ROOT / "common/men_at_arms_types/00_maa_types.txt",
        ROOT / "common/men_at_arms_types/wc_maa_types.txt",
        ROOT / "common/men_at_arms_types/wc_regional_maa_types.txt",
    ):
        assert "wc_scarlet_maa_member_trigger" not in path.read_text(encoding="utf-8-sig")


if __name__ == "__main__":
    test_balnazzar_branch_has_no_scarlet_unit_content()
