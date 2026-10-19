#!/usr/bin/env python3
"""Tests for the worker's tools (AGENTS.md T1-T3)."""

from __future__ import annotations

import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from lib import sm83  # noqa: E402
from lib.asmlen import length  # noqa: E402
import worker  # noqa: E402


class LengthTests(unittest.TestCase):
    def test_every_opcode_agrees_with_the_decoder(self) -> None:
        # The decoder's text, read back by the progress counter, gives the
        # decoder's own length for every valid opcode and CB opcode.
        for op in range(256):
            for b1 in ([0x34] if op != 0xCB else range(256)):
                rom = bytes([op, b1, 0x12])
                n, text, kind, _ = sm83.decode(rom, 0, 0x4000)
                if kind == "invalid":
                    continue
                self.assertEqual(length(text), n, f"{op:02X} {b1:02X}: {text}")

    def test_names_that_look_like_registers(self) -> None:
        self.assertEqual(length("ld hl, SpendNewEntryMeasures"), 3)
        self.assertEqual(length("ld hl, sp+4"), 2)
        self.assertEqual(length("ld a, [$FF00+c]"), 1)
        self.assertEqual(length("ld [$FF40], a"), 3)
        self.assertEqual(length("ldh [$FF40], a"), 2)
        self.assertIsNone(length("db $01, $02"))


class NamingTests(unittest.TestCase):
    def test_keep_and_name_replies(self) -> None:
        self.assertEqual(worker.parse_name("NAME: KEEP\nEVIDENCE: none\n")[0], None)
        name, ev, _ = worker.parse_name("NAME: ResetSound\nEVIDENCE: src/a.asm:3 clears NR52\nCOMMENT: x\n")
        self.assertEqual(name, "ResetSound")
        self.assertIn("src/a.asm:3", ev)


if __name__ == "__main__":
    unittest.main()
