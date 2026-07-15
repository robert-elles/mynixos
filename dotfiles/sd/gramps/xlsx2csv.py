#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["openpyxl"]
# ///
"""Convert stammbaum.xlsx to a Gramps-friendly CSV.

- comma-delimited (not semicolon)
- truly empty lines for blank rows (no dangling delimiters)
- drops the first row (the sheet's own Column1..ColumnN header),
  keeping the real section headers (Person, Heirat, Familie, ...) further down
"""

import csv
import datetime
import sys
from pathlib import Path

import openpyxl


def format_cell(value: object) -> str:
    if value is None:
        return ""
    if isinstance(value, datetime.datetime):
        if value.time() == datetime.time(0, 0):
            return value.strftime("%Y-%m-%d")
        return value.isoformat(sep=" ")
    if isinstance(value, datetime.date):
        return value.strftime("%Y-%m-%d")
    return str(value)


def main() -> None:
    src = Path(sys.argv[1] if len(sys.argv) > 1 else Path.home() / "Downloads/personal/stammbaum/stammbaum.xlsx")
    dst = Path(sys.argv[2]) if len(sys.argv) > 2 else src.with_suffix(".csv")

    wb = openpyxl.load_workbook(src, data_only=True)
    ws = wb.active

    rows = list(ws.iter_rows(values_only=True))
    rows = rows[1:]  # drop the sheet's own Column1..ColumnN header row

    with dst.open("w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f, delimiter=",", lineterminator="\n")
        for row in rows:
            cells = [format_cell(v) for v in row]
            if not any(cells):
                f.write("\n")
            else:
                writer.writerow(cells)

    print(f"wrote {dst}")


if __name__ == "__main__":
    main()
