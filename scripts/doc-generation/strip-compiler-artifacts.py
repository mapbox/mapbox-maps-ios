#!/usr/bin/env python3
"""Remove compiler-artifact symbols from DocC symbol graph JSON files.

Newer Swift compilers (Xcode 16.3+) import `char8_t` from auto-generated
-Swift.h bridging headers as a public typealias. When the dependency module
is re-exported (via @_exported import), these symbols leak into the
MapboxMaps documentation. This script strips them from the symbol graphs
before DocC processes them.
"""

import json
import os
import sys

# Symbols that are compiler artifacts and should not appear in public docs.
ARTIFACTS = {"char8_t"}


def strip(path):
    with open(path) as f:
        sg = json.load(f)

    artifact_ids = set()
    filtered_symbols = []
    for sym in sg.get("symbols", []):
        if sym["names"]["title"] in ARTIFACTS:
            artifact_ids.add(sym["identifier"]["precise"])
        else:
            filtered_symbols.append(sym)

    if not artifact_ids:
        return

    sg["symbols"] = filtered_symbols
    sg["relationships"] = [
        r for r in sg.get("relationships", []) if r["source"] not in artifact_ids and r["target"] not in artifact_ids
    ]

    with open(path, "w") as f:
        json.dump(sg, f)

    basepath = os.path.relpath(path, sys.argv[1])
    print(f"  Stripped {artifact_ids} from {basepath}")


def main():
    symbol_graph_dir = sys.argv[1]
    print(f"Stripping compiler artifacts from symbol graphs in {symbol_graph_dir}")
    for root, _, files in os.walk(symbol_graph_dir):
        for name in files:
            if name.endswith(".symbols.json"):
                strip(os.path.join(root, name))


if __name__ == "__main__":
    main()
