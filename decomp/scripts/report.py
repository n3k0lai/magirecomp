#!/usr/bin/env python3
"""Write an objdiff report, version 2, for the USA ROM.

Matched bytes are source sections, and only after out/magination.gbc matches
the retail image. There is no partial credit. Unmatched bytes stay code, so
the headline is near the compiled-byte percent. Bank tags in
config/categories.txt move a bank to audio, data, or graphics. The cartridge
header is omitted. Audio stays out of the headline code total.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path

import catalog
import progress

ROOT = Path(__file__).resolve().parents[1]
EXPECTED_SHA1 = "9972a7bca43210b4b6c0b3f6ee5d1957a865e12d"
CATEGORY_NAMES = {
    "code": "Code",
    "data": "Data",
    "graphics": "Graphics",
    "audio": "Audio",
}


def sha1(path: Path) -> str:
    digest = hashlib.sha1()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1 << 16), b""):
            digest.update(chunk)
    return digest.hexdigest()


def image_matches(root: Path) -> bool:
    built = root / "out" / "magination.gbc"
    retail = root / "roms" / "magination.gbc"
    if not built.is_file() or not retail.is_file():
        return False
    if built.stat().st_size != progress.ROM_SIZE or retail.stat().st_size != progress.ROM_SIZE:
        return False
    built_sha = sha1(built)
    return built_sha == sha1(retail) == EXPECTED_SHA1


def percent(matched: int, total: int) -> float:
    if total <= 0:
        return 0.0
    return 100.0 * matched / total


def empty_measures() -> dict[str, int | float]:
    return {
        "fuzzy_match_percent": 0.0,
        "total_code": 0,
        "matched_code": 0,
        "matched_code_percent": 0.0,
        "total_data": 0,
        "matched_data": 0,
        "matched_data_percent": 0.0,
        "total_functions": 0,
        "matched_functions": 0,
        "matched_functions_percent": 0.0,
        "complete_code": 0,
        "complete_code_percent": 0.0,
        "complete_data": 0,
        "complete_data_percent": 0.0,
        "total_units": 0,
        "complete_units": 0,
    }


def finish(measures: dict[str, int | float], fuzzy_weight: float) -> dict[str, int | float]:
    total_code = int(measures["total_code"])
    measures["fuzzy_match_percent"] = fuzzy_weight / total_code if total_code else 0.0
    measures["matched_code_percent"] = percent(int(measures["matched_code"]), total_code)
    measures["matched_data_percent"] = percent(
        int(measures["matched_data"]), int(measures["total_data"])
    )
    measures["matched_functions_percent"] = percent(
        int(measures["matched_functions"]), int(measures["total_functions"])
    )
    measures["complete_code_percent"] = percent(int(measures["complete_code"]), total_code)
    measures["complete_data_percent"] = percent(
        int(measures["complete_data"]), int(measures["total_data"])
    )
    return measures


def add_measures(
    total: dict[str, int | float], part: dict[str, int | float], *, code: bool
) -> float:
    if code:
        total["total_code"] = int(total["total_code"]) + int(part["total_code"])
        total["matched_code"] = int(total["matched_code"]) + int(part["matched_code"])
        total["complete_code"] = int(total["complete_code"]) + int(part["complete_code"])
        total["total_functions"] = int(total["total_functions"]) + int(part["total_functions"])
        total["matched_functions"] = int(total["matched_functions"]) + int(
            part["matched_functions"]
        )
        return float(part["fuzzy_match_percent"]) * int(part["total_code"])
    total["total_data"] = int(total["total_data"]) + int(part["total_data"])
    total["matched_data"] = int(total["matched_data"]) + int(part["matched_data"])
    total["complete_data"] = int(total["complete_data"]) + int(part["complete_data"])
    return 0.0


def unit_measures(section: catalog.Section, compared: bool) -> dict[str, int | float]:
    matched = section.matched_source and compared
    measures = empty_measures()
    measures["total_units"] = 1
    measures["complete_units"] = 1 if matched else 0
    size = section.counted_size
    if section.category in ("code", "audio"):
        measures["total_code"] = size
        measures["matched_code"] = size if matched else 0
        measures["complete_code"] = size if matched else 0
        if section.category == "code" and matched:
            measures["total_functions"] = 1
            measures["matched_functions"] = 1
        measures["fuzzy_match_percent"] = 100.0 if matched else 0.0
    else:
        measures["total_data"] = size
        measures["matched_data"] = size if matched else 0
        measures["complete_data"] = size if matched else 0
    return finish(measures, float(measures["fuzzy_match_percent"]) * size)


def item(section: catalog.Section, compared: bool) -> dict:
    matched = section.matched_source and compared
    return {
        "name": section.name,
        "size": section.counted_size,
        "fuzzy_match_percent": 100.0 if matched else 0.0,
        "metadata": {"virtual_address": section.counted_address},
    }


def build(root: Path, *, require_map: bool) -> dict:
    all_sections = catalog.load(root)
    sections = [section for section in all_sections if section.counted_size > 0]
    map_path = root / "out" / "magination.map"
    if map_path.is_file():
        try:
            catalog.check_map(all_sections, catalog.load_map(map_path))
        except ValueError:
            if require_map:
                raise
    elif require_map:
        raise ValueError("missing out/magination.map; run make build")
    compared = image_matches(root)
    rewritten = progress.rewritten_bytes(root)
    source_bytes = sum(section.counted_size for section in sections if section.matched_source)
    if source_bytes != rewritten:
        raise ValueError(
            f"source sections total {source_bytes} bytes, progress.py says {rewritten}"
        )

    units = []
    grouped: dict[str, list[dict[str, int | float]]] = {name: [] for name in CATEGORY_NAMES}
    for section in sections:
        measures = unit_measures(section, compared)
        grouped[section.category].append(measures)
        functions = []
        if section.category == "code" and section.matched_source and compared:
            functions.append(item(section, True))
        metadata: dict[str, object] = {
            "complete": bool(section.matched_source and compared),
            "progress_categories": [section.category],
        }
        if section.source:
            metadata["source_path"] = section.source
        units.append(
            {
                "name": section.name,
                "measures": measures,
                "sections": [item(section, compared)],
                "functions": functions,
                "metadata": metadata,
            }
        )

    headline = empty_measures()
    fuzzy = 0.0
    for category, parts in grouped.items():
        for part in parts:
            headline["total_units"] = int(headline["total_units"]) + 1
            headline["complete_units"] = int(headline["complete_units"]) + int(
                part["complete_units"]
            )
            if category == "code":
                fuzzy += add_measures(headline, part, code=True)
            elif category in ("data", "graphics"):
                add_measures(headline, part, code=False)
    finish(headline, fuzzy)

    categories = []
    for category, parts in grouped.items():
        measures = empty_measures()
        weight = 0.0
        for part in parts:
            measures["total_units"] = int(measures["total_units"]) + 1
            measures["complete_units"] = int(measures["complete_units"]) + int(
                part["complete_units"]
            )
            if category in ("code", "audio"):
                weight += add_measures(measures, part, code=True)
            else:
                add_measures(measures, part, code=False)
        categories.append(
            {
                "id": category,
                "name": CATEGORY_NAMES[category],
                "measures": finish(measures, weight),
            }
        )

    return {
        "version": 2,
        "measures": headline,
        "units": units,
        "categories": categories,
        "compared": compared,
    }


def screen_measures(report: dict) -> dict[str, int | bool]:
    headline = report["measures"]
    by_id = {category["id"]: category["measures"] for category in report["categories"]}

    def take(category: str, field: str) -> int:
        return int(by_id[category][field])

    return {
        "compared": bool(report["compared"]),
        "total_code": int(headline["total_code"]),
        "matched_code": int(headline["matched_code"]),
        "total_data": int(headline["total_data"]),
        "matched_data": int(headline["matched_data"]),
        "total_audio": take("audio", "total_code"),
        "matched_audio": take("audio", "matched_code"),
        "total_graphics": take("graphics", "total_data"),
        "matched_graphics": take("graphics", "matched_data"),
        "total_functions": int(headline["total_functions"]),
        "matched_functions": int(headline["matched_functions"]),
        "total_units": int(headline["total_units"]),
        "complete_units": int(headline["complete_units"]),
    }


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Write the objdiff progress report.")
    parser.add_argument("--measures", action="store_true", help="print the screen totals")
    parser.add_argument("-o", default="out/report.json", help="report path")
    args = parser.parse_args(argv)
    try:
        report = build(ROOT, require_map=not args.measures)
    except ValueError as error:
        print(error, file=sys.stderr)
        return 1
    if args.measures:
        json.dump(screen_measures(report), sys.stdout, separators=(",", ":"))
        sys.stdout.write("\n")
        return 0
    if not report["compared"]:
        print(
            "out/magination.gbc does not match the retail image, so no unit is matched",
            file=sys.stderr,
        )
        return 1
    payload = {key: report[key] for key in ("version", "measures", "units", "categories")}
    destination = ROOT / args.o
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_text(json.dumps(payload, indent=2) + "\n")
    measures = screen_measures(report)
    print(
        f"code {measures['matched_code']} / {measures['total_code']}"
        f"    data {measures['matched_data']} / {measures['total_data']}"
        f"    audio {measures['matched_audio']} / {measures['total_audio']}"
        f"    functions {measures['matched_functions']}"
        f"    units {measures['complete_units']} / {measures['total_units']}"
    )
    print(destination)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
