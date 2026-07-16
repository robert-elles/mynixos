"""GRAMPS registration file."""

register(
    TOOL,
    id="empty_family_tree",
    name=_("Empty Family Tree"),
    description=_("Removes all people, families, events, places, sources, citations, repositories, media, notes and tags, keeping the family tree's database id."),
    version="1.0.0",
    gramps_target_version="6.0",
    status=STABLE,
    fname="emptyfamilytree.py",
    authors=["Robert Elles"],
    authors_email=[""],
    category=TOOL_DBPROC,
    toolclass="EmptyFamilyTreeTool",
    optionclass="EmptyFamilyTreeOptions",
    tool_modes=[TOOL_MODE_GUI, TOOL_MODE_CLI],
)
