#!/usr/bin/env python3

# Load the JSON file
import argparse
import json

acceptedTopSectionTitles = [
    "Articles",
    "Essentials",
    "Styling",
    "Annotations",
    "Advanced",
    "Other",
    "Dependencies",
    "Internal",
    "Extended Modules",
]


def main():
    parser = argparse.ArgumentParser(
        description="Check DocC top sections for unexpected items."
    )
    parser.add_argument(
        "--docc", required=True, type=str, help="Path to doccarchive folder"
    )

    args = parser.parse_args()

    root_file_path = f"{args.docc}/data/documentation/mapboxmaps.json"
    print(f"Checking DocC top sections for unexpected items in {args.docc}")

    with open(root_file_path) as f:
        root = json.load(f)

    errors = []
    for section in root["topicSections"]:
        if section["title"] not in acceptedTopSectionTitles:
            errors.append(f"{section['title']}:")
            for identifier in section["identifiers"]:
                symbol = identifier.replace("doc://com.mapbox.MapboxMaps/documentation/MapboxMaps/", "")
                errors.append(f"- {symbol}")

    if len(errors) > 0:
        print("❌ Unexpected sections found.")
        for error in errors:
            print(error)
        print("Please make sure these symbols are expected to be publicly available and list them in one of the Markdown files in Sources/MapboxMaps/Documentation.docc/API Catalogs")
        exit(1)
    else:
        print("✅ Check passed.")


main()
