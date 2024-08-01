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

    sectionTitles = list(map(lambda section: section["title"], root["topicSections"]))
    unexpectedTitles = list(
        filter(lambda title: title not in acceptedTopSectionTitles, sectionTitles)
    )

    if len(unexpectedTitles) > 0:
        print(
            f"""
        Unexpected section titles found: {unexpectedTitles}
        This suggests that you've introduced new public symbols in your pull request, yet they don't seem to be reflected in any of the API catalog.
        """
        )
        exit(1)
    else:
        print("Check passed.")


main()
