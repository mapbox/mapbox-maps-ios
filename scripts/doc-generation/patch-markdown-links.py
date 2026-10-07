#!/usr/bin/env python3
"""Rewrite links in DocC markdown pages so they point to the hosted pages.

docc writes links as page identifiers, e.g. /documentation/MapboxMaps/MapView,
while pages are hosted at <hosting_base_path>documentation/mapboxmaps/mapview.
docc also leaves some links as doc:// URIs: article links when there are several
modules, and symbol links in asides.

Three passes over each page:
1. Turn doc:// URIs into markdown links.
2. Add the hosting base path to links.
3. Lowercase link paths, keeping the #fragment as is.

Usage: patch-markdown-links.py <docc_archive> <hosting_base_path>
"""

import re
import sys
from pathlib import Path

# <doc://com.mapbox.MapboxMaps/documentation/MapboxMaps/Migrate-to-v11#fragment>
# ``doc://com.mapbox.MapboxMaps/documentation/MapboxMaps/ViewAnnotation``
DOC_LINK = re.compile(r"(<|``)doc://com\.mapbox\.MapboxMaps(/[^#>`]+)(#[^>`]*)?(?:>|``)")


def doc_links_to_markdown_links(text):
    def markdown_link(match):
        opening, path, fragment = match.group(1), match.group(2), match.group(3) or ""
        title = path.split("/")[-1]
        if opening == "``":
            title = f"`{title}`"
        return f"[{title}]({path}{fragment})"

    return DOC_LINK.sub(markdown_link, text)


def add_base_path(text, base_path):
    return text.replace("](/documentation/", f"]({base_path}documentation/")


def lowercase_paths(text, base_path):
    # The path can contain parentheses, e.g. init(coder:). The fragment keeps its case.
    link_path = re.compile(r"\]\((" + re.escape(base_path) + r"(?:[^()\s#]|\([^()\s]*\))+)")
    return link_path.sub(lambda match: "](" + match.group(1).lower(), text)


def main():
    archive, base_path = Path(sys.argv[1]), sys.argv[2]
    if not base_path.endswith("/"):
        base_path += "/"

    for page in archive.glob("documentation/**/*.md"):
        text = page.read_text()
        patched = doc_links_to_markdown_links(text)
        patched = add_base_path(patched, base_path)
        patched = lowercase_paths(patched, base_path)
        if patched != text:
            page.write_text(patched)


if __name__ == "__main__":
    main()
