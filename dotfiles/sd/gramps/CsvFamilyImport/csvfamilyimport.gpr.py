"""GRAMPS registration file."""

register(
    TOOL,
    id="csv_family_import",
    name=_("CSV Family Import"),
    description=_("Imports stammbaum.csv into the open family tree using the CSV importer library."),
    version="1.0.0",
    gramps_target_version="6.0",
    status=STABLE,
    fname="csvfamilyimport.py",
    authors=["Robert Elles"],
    authors_email=[""],
    category=TOOL_DBPROC,
    toolclass="CsvFamilyImportTool",
    optionclass="CsvFamilyImportOptions",
    tool_modes=[TOOL_MODE_GUI, TOOL_MODE_CLI],
)
