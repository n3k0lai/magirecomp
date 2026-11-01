"""Unit test for tools/mn_inventory.py status rules (no ROM).

Run: python3 tests/tools/mn_inventory_test.py
"""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "tools"))
import mn_inventory as I  # noqa: E402

fails = 0
for ops, want in (([0x82, 0x4C, 0x00, 0x94], "matches"), ([0x16, 0x00], "diverges"),
                  ([0x58, 0x29], "missing"), ([0x60, 0x84], "diverges")):
    got = I.status(ops)
    if got != want:
        fails += 1
        print("FAIL", ops, got, want)
print("mn_inventory: %d failed" % fails)
sys.exit(1 if fails else 0)
