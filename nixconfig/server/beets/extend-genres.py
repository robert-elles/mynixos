"""Build the lastgenre whitelist and canonicalization tree.

Whitelist = beets' built-in whitelist + every node of the built-in tree +
MusicBrainz' curated genre list (snapshot of
https://musicbrainz.org/ws/2/genre/all?fmt=txt) + local extras. Without the
MusicBrainz list, lastgenre's whitelist would drop most genres the
musicbrainz plugin writes.

Tree = beets' built-in tree + one extra branch per whitelisted genre the tree
lacks, so lastgenre's canonicalization adds the broader parent genres
("melodic techno" -> "techno" -> "electronic"). The parent is the explicit one
from the extras, else the longest trailing word group that is already a tree
node ("french indie pop" -> "indie pop" -> "pop"). Genres with neither stay
whitelisted without parents.

usage: extend-genres.py BEETS_WHITELIST BEETS_TREE MB_GENRES EXTRAS_JSON OUT_DIR
EXTRAS_JSON maps genre -> parent genre, or null to derive the parent by suffix.
"""
import json
import re
import sys
from pathlib import Path

import yaml


def flatten(elem, path, branches):
    # Mirrors beetsplug.lastgenre.flatten_tree.
    if isinstance(elem, dict):
        for key, val in elem.items():
            flatten(val, [*path, key], branches)
    elif isinstance(elem, list):
        for sub in elem:
            flatten(sub, path, branches)
    else:
        branches.append([*path, str(elem)])


def read_list(path):
    lines = Path(path).read_text(encoding="utf-8").splitlines()
    return {s for line in lines if (s := line.strip().lower()) and not s.startswith("#")}


def nest(path):
    node = path[-1]
    for parent in reversed(path[:-1]):
        node = {parent: [node]}
    return node


def main(wl_path, tree_path, mb_path, extras_path, out_dir):
    tree = yaml.safe_load(Path(tree_path).read_text(encoding="utf-8"))
    branches = []
    flatten(tree, [], branches)

    # Root-first ancestry of every node, as find_parents resolves it (first
    # branch containing the node wins).
    ancestry = {}
    for branch in branches:
        for idx, node in enumerate(branch):
            ancestry.setdefault(node, branch[: idx + 1])
    builtin = set(ancestry)

    extras = {
        k.lower(): (v.lower() if v else None)
        for k, v in json.loads(Path(extras_path).read_text()).items()
    }
    # Navidrome splits genre values on , ; / so such names would arrive as
    # fragments ("death/doom" -> "death", "doom").
    whitelist = {
        g
        for g in read_list(wl_path) | builtin | read_list(mb_path) | set(extras)
        if not re.search(r"[,;/]", g)
    }

    added = []

    def add(genre, parent):
        ancestry[genre] = [*ancestry[parent], genre]
        added.append(nest(ancestry[genre]))

    def suffix_parent(genre):
        words = re.split(r"[\s-]+", genre)
        for i in range(1, len(words)):
            for sep in (" ", "-"):
                if (suffix := sep.join(words[i:])) in ancestry:
                    return suffix
        return None

    # Repeat until nothing changes, so genres can build on earlier additions
    # ("rap" -> "hip hop" lets "french rap" derive "rap").
    explicit = {g: p for g, p in extras.items() if p and g not in builtin}
    auto = whitelist - builtin - set(explicit)
    while True:
        before = len(added)
        for genre, parent in list(explicit.items()):
            if parent in ancestry:
                add(genre, parent)
                del explicit[genre]
        # Shorter genres first so longer ones can derive from them.
        for genre in sorted(auto, key=lambda g: (len(re.split(r"[\s-]+", g)), g)):
            if parent := suffix_parent(genre):
                add(genre, parent)
                auto.discard(genre)
        if len(added) == before:
            break
    if explicit:
        sys.exit(f"extras: parents are not genre tree nodes: {explicit}")

    out = Path(out_dir)
    out.mkdir(parents=True, exist_ok=True)
    (out / "genres.txt").write_text("\n".join(sorted(whitelist)) + "\n", encoding="utf-8")
    (out / "genres-tree.yaml").write_text(
        yaml.safe_dump(tree + added, allow_unicode=True, sort_keys=False), encoding="utf-8"
    )
    print(f"whitelist: {len(whitelist)} genres, tree: +{len(added)} branches")


if __name__ == "__main__":
    main(*sys.argv[1:])
