#!/usr/bin/env python3
"""Catalog and report checks. Does not start a slice."""

import unittest
from pathlib import Path

import catalog
import progress
import report

ROOT = Path(__file__).resolve().parents[1]

SAMPLE = """
SECTION "Head", ROM0[$0000]
    INCBIN "roms/magination.gbc", $0, $100
SECTION "Header", ROM0[$0100]
    INCBIN "roms/magination.gbc", $100, $50
SECTION "Reset", ROM0[$0150]
INCLUDE "src/reset.asm"
SECTION "Rest", ROM0[$0160]
    INCBIN "roms/magination.gbc", $160, $3EA0
SECTION "Tune", ROMX[$4000], BANK[1]
    INCBIN "roms/magination.gbc", $4000, $4000
"""


class CatalogTests(unittest.TestCase):
    def test_header_is_omitted_and_bank_tag_wins(self) -> None:
        sections = catalog.parse_scaffold(
            SAMPLE, banks={1: "audio"}, names={}, rom_size=0x8000
        )
        by_name = {section.name: section for section in sections}
        self.assertEqual(by_name["Header"].counted_size, 0)
        self.assertEqual(by_name["Head"].counted_size, 0x100)
        self.assertEqual(by_name["Reset"].kind, "include")
        self.assertEqual(by_name["Reset"].counted_size, 0x10)
        self.assertEqual(by_name["Reset"].category, "code")
        self.assertEqual(by_name["Tune"].category, "audio")
        self.assertEqual(by_name["Tune"].file_address, 0x4000)
        excluded = sum(section.span - section.counted_size for section in sections)
        self.assertEqual(excluded, 0x50)

    def test_map_accepts_a_one_byte_section(self) -> None:
        text = 'SECTION: $0058-$0058 ($0001 byte) ["Serial"]\n'
        path = ROOT / "out" / "map-one-byte-fixture.map"
        path.parent.mkdir(exist_ok=True)
        path.write_text(text)
        try:
            self.assertEqual(catalog.load_map(path), {"Serial": 1})
        finally:
            path.unlink(missing_ok=True)

    def test_section_name_overrides_the_default(self) -> None:
        sections = catalog.parse_scaffold(
            SAMPLE, banks={}, names={"Rest": "data"}, rom_size=0x8000
        )
        rest = next(section for section in sections if section.name == "Rest")
        self.assertEqual(rest.category, "data")

    def test_repo_matches_progress_and_keeps_bank_30_audio(self) -> None:
        sections = catalog.load(ROOT)
        excluded = sum(section.span - section.counted_size for section in sections)
        self.assertEqual(excluded, 0x50)
        source = sum(section.counted_size for section in sections if section.matched_source)
        self.assertEqual(source, progress.rewritten_bytes(ROOT))
        audio = [section for section in sections if section.category == "audio"]
        self.assertTrue(audio)
        self.assertTrue(all(section.file_address // 0x4000 == 0x30 for section in audio))
        self.assertTrue(
            any(section.name == "Update sound" and section.matched_source for section in audio)
        )
        bank_030 = next(section for section in sections if section.name == "ROM Bank 030")
        self.assertEqual(bank_030.category, "data")  # bank $1E: scripts and text
        self.assertEqual(bank_030.file_address // 0x4000, 30)
        built = report.build(ROOT, require_map=False)
        measures = report.screen_measures(built)
        if built["compared"]:
            matched = (
                measures["matched_code"]
                + measures["matched_data"]
                + measures["matched_audio"]
                + measures["matched_graphics"]
            )
            self.assertEqual(matched, source)
        else:
            self.assertEqual(measures["matched_code"], 0)
            self.assertEqual(measures["matched_audio"], 0)
        self.assertGreaterEqual(measures["total_code"], measures["matched_code"])
        for unit in built["units"]:
            for entry in unit["sections"] + unit["functions"]:
                self.assertIn(entry["fuzzy_match_percent"], (0.0, 100.0))


if __name__ == "__main__":
    unittest.main()
