"""Import stammbaum.csv into the currently open family tree via the gramps CSV importer library."""

import os

from gramps.gui.plug import tool
from gramps.plugins.importer.importcsv import importData

DEFAULT_CSV_PATH = os.path.expanduser("~/Downloads/personal/stammbaum/stammbaum.csv")


class CsvFamilyImportTool(tool.Tool):
    def __init__(self, dbstate, user, options_class, name, callback=None):
        tool.Tool.__init__(self, dbstate, options_class, name)

        if self.db.readonly:
            print("Database is read-only, aborting import.")
            return

        csv_path = self.options.handler.options_dict.get("csvfile", DEFAULT_CSV_PATH)
        if not os.path.isfile(csv_path):
            print(f"CSV file not found: {csv_path}")
            return

        print(f"Importing {csv_path} ...")
        result = importData(self.db, csv_path, user)
        if result:
            print("Import finished:", result.info_text())
        else:
            print("Import failed.")


class CsvFamilyImportOptions(tool.ToolOptions):
    """Defines options and provides handling interface."""

    def __init__(self, name, person_id=None):
        tool.ToolOptions.__init__(self, name, person_id)
        self.options_dict = {"csvfile": DEFAULT_CSV_PATH}
        self.options_help = {"csvfile": ["=path", "Path to the CSV file to import."]}
