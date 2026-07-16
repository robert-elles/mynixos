"""Remove all data from the currently open family tree, keeping its database id."""

from gramps.gen.db import DbTxn
from gramps.gui.plug import tool

HANDLE_GETTERS_AND_REMOVERS = [
    ("get_person_handles", "remove_person"),
    ("get_family_handles", "remove_family"),
    ("get_event_handles", "remove_event"),
    ("get_place_handles", "remove_place"),
    ("get_citation_handles", "remove_citation"),
    ("get_source_handles", "remove_source"),
    ("get_repository_handles", "remove_repository"),
    ("get_media_handles", "remove_media"),
    ("get_note_handles", "remove_note"),
    ("get_tag_handles", "remove_tag"),
]


class EmptyFamilyTreeTool(tool.Tool):
    def __init__(self, dbstate, user, options_class, name, callback=None):
        tool.Tool.__init__(self, dbstate, options_class, name)

        db = self.db
        if db.readonly:
            print("Database is read-only, aborting.")
            return

        print(
            "Emptying family tree: "
            f"{db.get_number_of_people()} people, "
            f"{db.get_number_of_families()} families, "
            f"{db.get_number_of_events()} events, "
            f"{db.get_number_of_places()} places, "
            f"{db.get_number_of_sources()} sources, "
            f"{db.get_number_of_citations()} citations, "
            f"{db.get_number_of_repositories()} repositories, "
            f"{db.get_number_of_media()} media, "
            f"{db.get_number_of_notes()} notes, "
            f"{db.get_number_of_tags()} tags."
        )

        with DbTxn("Empty family tree", db) as trans:
            for getter_name, remover_name in HANDLE_GETTERS_AND_REMOVERS:
                getter = getattr(db, getter_name)
                remover = getattr(db, remover_name)
                for handle in list(getter()):
                    remover(handle, trans)

        print("Family tree emptied.")


class EmptyFamilyTreeOptions(tool.ToolOptions):
    """Defines options and provides handling interface."""

    def __init__(self, name, person_id=None):
        tool.ToolOptions.__init__(self, name, person_id)
